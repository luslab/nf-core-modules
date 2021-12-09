#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for iCount sigxls...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/

include {ICOUNT_SIGXLS} from '../../../../modules/icount/sigxls/main.nf' addParams( options: [args: '--half_window 3 --fdr 0.05'] )
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
        "${params.test_data_dir}crosslinks/sample1.xl.bed.gz"
    ],
    [
        [id:"sample4"],
        "${params.test_data_dir}crosslinks/sample4.xl.bed.gz"
    ]
]

// Define test data input channels 

// Seg file channel
Channel
    .value("${params.test_data_dir}gtf/icount_segmentation.gtf.gz")
    .set {ch_seg}

// Bed/seg channel
Channel
    .from(test_beds)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set {ch_bed}

expected_peak_line_counts = [
    sample1: 5,
    sample4: 4
]

expected_scores_line_counts = [
    sample1: 255,
    sample4: 195
]

expected_peak_hashes = [
    sample1: "4984fdc8e94ef357bd99dad420a098be",
    sample4: "22d80735d26199e75cf87e632c1b76e4"
]

expected_scores_hashes = [
    sample1: "477c7bec8b1a1faf209afc514235a111",
    sample4: "b0384def31f9f125ad03558d181c7b05"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    ICOUNT_SIGXLS( ch_bed, ch_seg) 

    ASSERT_CHANNEL_COUNT( ICOUNT_SIGXLS.out.peaks, "peaks", 2)
    ASSERT_CHANNEL_COUNT( ICOUNT_SIGXLS.out.scores, "scores", 2)
    ASSERT_CHANNEL_COUNT( ICOUNT_SIGXLS.out.version, "version", 2)

    ASSERT_PEAKS_LINE_NUMBER( ICOUNT_SIGXLS.out.peaks, "peaks", expected_peak_line_counts)
    ASSERT_SCORES_LINE_NUMBER( ICOUNT_SIGXLS.out.scores, "scores", expected_scores_line_counts)

    ASSERT_PEAKS_MD5( ICOUNT_SIGXLS.out.peaks, "peaks", expected_peak_hashes)
    ASSERT_SCORES_MD5( ICOUNT_SIGXLS.out.scores, "scores", expected_scores_hashes)
}
