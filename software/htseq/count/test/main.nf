#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for htseq...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

params.verbose = true
// params.modules['htseq_count'].args = '-f bam -s no -m union'

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { HTSEQ_COUNT } from '../main.nf' addParams( options: params.modules['htseq_count'] )  
include { ASSERT_CHANNEL_COUNT } from '../../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

test_data_bam= [
    [[id:"sample1"], "https://github.com/luslab/nf-core-test-data/blob/main/data/bam/S1_chr1_test.bam"],
    [[id:"sample2"], "https://github.com/luslab/nf-core-test-data/blob/main/data/bam/S2_chr1_test.bam"]
]

test_data_gtf = "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/gtf/chr1.gtf"

// testDataPairedEnd= [
//     [[sample_id:"sample1"], "$baseDir/../../../test_data/htseq/S1_chr1_test.bam"],
//     [[sample_id:"sample2"], "$baseDir/../../../test_data/htseq/S2_chr1_test.bam"]
// ]

Channel
    .from(test_data_bam)
    // .map { row -> [ row[0], [file(row[1], checkIfExists: true)]]}
    .map { row -> [ row[0], [row[1]]] }
    .set { ch_bam }

 Channel
    .value(file(test_data_gtf))
    .set { ch_gtf }

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    HTSEQ_COUNT( ch_bam, ch_gtf )

    //Check count
    ASSERT_CHANNEL_COUNT( HTSEQ_COUNT.out.counts, "counts", 2)
    ASSERT_CHANNEL_COUNT( HTSEQ_COUNT.out.version, "version", 2)
}