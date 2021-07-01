#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BEDTOOLS_GENOMECOV } from '../../../../software/bedtools/genomecov/main.nf' addParams( options: [:] )

workflow test_bedtools_genomecov {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    BEDTOOLS_GENOMECOV ( input )
}
