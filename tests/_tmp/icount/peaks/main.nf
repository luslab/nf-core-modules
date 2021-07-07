#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ICOUNT_PEAKS } from '../../../../software/icount/peaks/main.nf' addParams( options: [:] )

workflow test_icount_peaks {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    ICOUNT_PEAKS ( input )
}
