#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for htseq...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { VELOCYTO_RUNSMARTSEQ2 } from '../main.nf' addParams( options: params.modules['velocyto_smartseq2'] )  
include { ASSERT_CHANNEL_COUNT } from '../../../../test_workflows/assertions/main.nf'
include { MD5 } from '../../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

test_data_gtf = "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/gtf/chr1.gtf"

test_data_bam= [
    [[id:"sample1"], "https://github.com/luslab/nf-core-test-data/blob/main/data/bam_bai/S1_chr1_test.bam?raw=true", "https://github.com/luslab/nf-core-test-data/blob/main/data/bam_bai/S1_chr1_test.bam.bai?raw=true"],
    [[id:"sample2"], "https://github.com/luslab/nf-core-test-data/blob/main/data/bam_bai/S2_chr1_test.bam?raw=true", "https://github.com/luslab/nf-core-test-data/blob/main/data/bam_bai/S2_chr1_test.bam.bai?raw=true"]
]

Channel
    .from(test_data_bam)
    .map { row -> [ row[0], [file(row[1], checkIfExists: true)], [file(row[2], checkIfExists: true)] ] }
    .set { ch_bam }

 Channel
    .value(file(test_data_gtf))
    .set { ch_gtf }

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    VELOCYTO_RUNSMARTSEQ2( ch_bam, ch_gtf )

    //Check count
    ASSERT_CHANNEL_COUNT( VELOCYTO_RUNSMARTSEQ2.out.velocyto, "velocyto", 2)
    ASSERT_CHANNEL_COUNT( VELOCYTO_RUNSMARTSEQ2.out.version, "version", 2)

    //Check MD5
    MD5( VELOCYTO_RUNSMARTSEQ2.out.velocyto )
}