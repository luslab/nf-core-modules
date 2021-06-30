#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BEDTOOLS_SHIFT } from '../../../../software/bedtools/shift/main.nf' addParams( options: [:] )

workflow test_bedtools_shift {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    BEDTOOLS_SHIFT ( input )
}
