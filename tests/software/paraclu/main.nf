#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PARACLU } from '../../../software/paraclu/main.nf' addParams( options: [:] )

workflow test_paraclu {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    PARACLU ( input )
}
