#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PARACLU_CONVERT } from '../../../../software/paraclu/convert/main.nf' addParams( options: [:] )

workflow test_paraclu_convert {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    PARACLU_CONVERT ( input )
}
