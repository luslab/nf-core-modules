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



include {ICOUNT_PEAKS} from '../main.nf' addParams( options: [args: '--half_window 3 --fdr 0.05'] )
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER as ASSERT_PEAKS_LINE_NUMBER;
    ASSERT_LINE_NUMBER as ASSERT_SCORES_LINE_NUMBER;
    ASSERT_MD5 as ASSERT_PEAKS_MD5;
    ASSERT_MD5 as ASSERT_SCORES_MD5
} from "../../../../test_workflows/assertions/main.nf"

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

// Define test data
test_beds = [
    [
        [id:"sample1"],
        "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample1.xl.bed.gz"
    ],
    [
        [id:"sample2"],
        "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample2.xl.bed.gz"
    ]
]

// Define test data input channels 

// Seg file channel
Channel
    .value("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/gtf/icount_segmentation.gtf.gz")
    .set {ch_seg}

// Bed/seg channel
Channel
    .from(test_beds)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set {ch_bed}

expected_peak_line_counts = [
    sample1: 5,
    sample2: 2
]

expected_scores_line_counts = [
    sample1: 255,
    sample2: 57
]

expected_peak_hashes = [
    sample1: "78b3dc666a38dc54409399b9e96fbef8",
    sample2: "d87724228144e5cb44ec71c7e1085889"
]

expected_scores_hashes = [
    sample1: "477c7bec8b1a1faf209afc514235a111",
    sample2: "f27b128d4d457dadb6890e2e127fdf86"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    ICOUNT_PEAKS( ch_bed, ch_seg) 

    ASSERT_CHANNEL_COUNT( ICOUNT_PEAKS.out.peaks, "peaks", 2)
    ASSERT_CHANNEL_COUNT( ICOUNT_PEAKS.out.scores, "scores", 2)
    ASSERT_CHANNEL_COUNT( ICOUNT_PEAKS.out.version, "version", 2)

    ASSERT_PEAKS_LINE_NUMBER( ICOUNT_PEAKS.out.peaks, "peaks", expected_peak_line_counts)
    ASSERT_SCORES_LINE_NUMBER( ICOUNT_PEAKS.out.scores, "scores", expected_scores_line_counts)

    ASSERT_PEAKS_MD5( ICOUNT_PEAKS.out.peaks, "peaks", expected_peak_hashes)
    ASSERT_SCORES_MD5( ICOUNT_PEAKS.out.scores, "scores", expected_scores_hashes)
}
