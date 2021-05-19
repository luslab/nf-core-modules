#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for iCount...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/



include {ICOUNT_SEGMENT} from '../main.nf' addParams( options: [:] )
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER;
    ASSERT_MD5
} from "../../../../test_workflows/assertions/main.nf"

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

Channel
    .value("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/gtf/gencode.v35.chr21.gtf")
    .set {ch_gtf}

Channel
    .value("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/fai/chr21.fai")
    .set {ch_fai}

expected_line_count = [
    icount_segmentation: 37189,
]

expected_hash = [
    icount_segmentation: "9b45451d777e17d1f0e1ec002d0f3af0"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    ICOUNT_SEGMENT( ch_gtf, ch_fai) 

    ASSERT_CHANNEL_COUNT( ICOUNT_SEGMENT.out.gtf, "gtf", 1)
    ASSERT_CHANNEL_COUNT( ICOUNT_SEGMENT.out.version, "version", 1)

    ICOUNT_SEGMENT.out.gtf
        .map{ [[id: "icount_segmentation"], it] }
        .set{ icount_segmentation }

    ASSERT_LINE_NUMBER( icount_segmentation, "gtf", expected_line_count)

    ASSERT_MD5( icount_segmentation, "gtf", expected_hash)
}
