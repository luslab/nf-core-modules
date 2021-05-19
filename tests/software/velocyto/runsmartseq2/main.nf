#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { VELOCYTO_RUNSMARTSEQ2 } from '../../../../software/velocyto/runsmartseq2/main.nf' addParams( options: [:] )

workflow test_velocyto_runsmartseq2 {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    VELOCYTO_RUNSMARTSEQ2 ( input )
}
