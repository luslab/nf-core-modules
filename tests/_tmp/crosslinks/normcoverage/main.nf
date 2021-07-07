#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CROSSLINKS_NORMCOVERAGE } from '../../../../software/crosslinks/normcoverage/main.nf' addParams( options: [:] )

workflow test_crosslinks_normcoverage {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    CROSSLINKS_NORMCOVERAGE ( input )
}
