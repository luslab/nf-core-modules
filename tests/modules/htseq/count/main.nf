#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for htseq...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { HTSEQ_COUNT } from '../../../../modules/htseq/count/main.nf' addParams( options: [args: '-f bam -s no -m union'] )  
include { ASSERT_CHANNEL_COUNT } from '../../../../test_workflows/assertions/main.nf'
include { MD5 } from '../../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

test_data_gtf = "${params.test_data_dir}gtf/chr1.gtf"

test_data_bam= [
    [[id:"sample1"], "${params.test_data_dir}bam_bai/S1_chr1_test.bam?raw=true", "${params.test_data_dir}bam_bai/S1_chr1_test.bam.bai?raw=true"],
    [[id:"sample2"], "${params.test_data_dir}bam_bai/S2_chr1_test.bam?raw=true", "${params.test_data_dir}bam_bai/S2_chr1_test.bam.bai?raw=true"]
]

Channel
    .from(test_data_bam)
    .map { row -> [ row[0], [file(row[1], checkIfExists: true)], [file(row[2], checkIfExists: true)] ] }
    .set { ch_bam }

 Channel
    .value(file(test_data_gtf))
    .set { ch_gtf }

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    HTSEQ_COUNT( ch_bam, ch_gtf )

    //Check count
    ASSERT_CHANNEL_COUNT( HTSEQ_COUNT.out.counts, "counts", 2)
    ASSERT_CHANNEL_COUNT( HTSEQ_COUNT.out.version, "version", 2)

    //Check MD5
    MD5( HTSEQ_COUNT.out.counts )
}