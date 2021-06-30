#!/usr/bin/env nextflow
/*
========================================================================================
    LUSLAB BASIC PIPELINE
========================================================================================
    Github : https://github.com/luslab
    Website: https://luslab.github.io/
    Author : Charlotte West
----------------------------------------------------------------------------------------
*/

/* ENABLE DSL2 */
nextflow.enable.dsl = 2

/*
========================================================================================
    PARAMETER INITIALISATION
========================================================================================
*/

/*
========================================================================================
    CHANNEL INITIALISATION
========================================================================================
*/

if (params.input)     { ch_input     = file(params.input)     } else { exit 1, "Input samplesheet not specified!" }

/*
========================================================================================
    MODULE INCLUSIONS
========================================================================================
*/

include { luslab_header as LUSLAB_HEADER } from "./software/luslab_util/main"
include { ULTRAPLEX } from "./software/ultraplex/main" addParams(options: [ publish_dir: 'ultraplex_single' ] )

/*
========================================================================================
    MAIN WORKFLOW
========================================================================================
*/

/*
* Luslab header
*/
log.info LUSLAB_HEADER()

workflow {

    /*
     * CHANNEL MANIPULATION: Read in samplesheet, validate and stage input files 
     */
    Channel
        .fromPath( ch_input )
        .splitCsv(header:true)
        .view()
        .map { row -> processRow(row) }
        .view()
        .set { ch_meta_fastq }


    /*
     * MODULE: Demultiplex FastQs
     */
    ULTRAPLEX( ch_meta_fastq, ch_barcode )

}

/*
========================================================================================
    END
========================================================================================
*/