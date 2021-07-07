#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for metadata...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { FASTQ_METADATA_10X } from '../main.nf'
include { ASSERT_CHANNEL_COUNT } from '../../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    FASTQ_METADATA_10X("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/metadata/10x_test.csv")

    FASTQ_METADATA_10X.out.metadata | view

    // Check count
    ASSERT_CHANNEL_COUNT( FASTQ_METADATA_10X.out.metadata, "metadata_10x", 1)
}