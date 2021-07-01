#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CROSSLINKS_GENOMECOVTOBED } from '../../../../software/crosslinks/genomecovtobed/main.nf' addParams( options: [:] )

workflow test_crosslinks_genomecovtobed {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    CROSSLINKS_GENOMECOVTOBED ( input )
}
