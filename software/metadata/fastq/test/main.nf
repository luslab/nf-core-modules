#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for metadata...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { FASTQ_METADATA as META_SE; FASTQ_METADATA as META_PE } from '../main.nf'
include { ASSERT_CHANNEL_COUNT } from '../../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    META_SE("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/metadata/paired_end_test.csv")
    META_PE("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/metadata/single_end_test.csv")
    
    META_SE.out.metadata | view
    META_PE.out.metadata | view

    // Check count
    ASSERT_CHANNEL_COUNT( META_SE.out.metadata, "metadata_fastq", 3)
    ASSERT_CHANNEL_COUNT( META_PE.out.metadata, "metadata_fastq", 3)
}