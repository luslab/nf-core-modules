#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PARACLU_CUT } from '../../../../software/paraclu/cut/main.nf' addParams( options: [:] )

workflow test_paraclu_cut {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    PARACLU_CUT ( input )
}
