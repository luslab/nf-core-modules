#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { HTSEQ_COUNT } from '../../../../software/htseq/count/main.nf' addParams( options: [:] )

workflow test_htseq_count {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    HTSEQ_COUNT ( input )
}
