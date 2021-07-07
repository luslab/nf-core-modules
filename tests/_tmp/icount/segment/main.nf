#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ICOUNT_SEGMENT } from '../../../../software/icount/segment/main.nf' addParams( options: [:] )

workflow test_icount_segment {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    ICOUNT_SEGMENT ( input )
}
