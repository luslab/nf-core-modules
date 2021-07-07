#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for metadata...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include {BAM_METADATA} from '../main.nf'
include { ASSERT_CHANNEL_COUNT } from '../../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    BAM_METADATA("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/metadata/bam_test.csv")

    BAM_METADATA.out.metadata | view

    // Check count
    ASSERT_CHANNEL_COUNT( BAM_METADATA.out.metadata, "metadata_bam", 3)
}