#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for Clippy...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/

include {CLIPPY} from '../../../modules/clippy/main.nf'
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER as ASSERT_PEAKS_LINE_NUMBER;
    ASSERT_LINE_NUMBER as ASSERT_SUMMITS_LINE_NUMBER;
    ASSERT_MD5 as ASSERT_PEAKS_MD5;
    ASSERT_MD5 as ASSERT_SUMMITS_MD5
} from "../../../test_workflows/assertions/main.nf"

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

// GTF file channel
Channel
    .value("${params.test_data_dir}gtf/icount_segmentation.gtf.gz")
    .set {ch_gtf}

// FAI file channel
Channel
    .value("${params.test_data_dir}fai/hg38_genome.fa.fai")
    .set {ch_fai}

// Bed/seg channel
Channel
    .from(test_beds)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set {ch_bed}

expected_peak_line_counts = [
    sample1: 2,
    sample4: 1
]

expected_summits_line_counts = [
    sample1: 26,
    sample4: 12
]

expected_peak_hashes = [
    sample1: "6a085d080615c47c5460be340f8d73f4",
    sample4: "235ebe1d97ea960ae5b7851996386d1e"
]

expected_summits_hashes = [
    sample1: "1ce87295742299f7d3c649360c798abc",
    sample4: "aaf7cf02c2406fed0ded98d965d503a1"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    CLIPPY( ch_bed, ch_gtf, ch_fai)

    ASSERT_CHANNEL_COUNT( CLIPPY.out.peaks, "peaks", 2)
    ASSERT_CHANNEL_COUNT( CLIPPY.out.summits, "summits", 2)
    ASSERT_CHANNEL_COUNT( CLIPPY.out.versions, "versions", 2)

    ASSERT_PEAKS_LINE_NUMBER( CLIPPY.out.peaks, "peaks", expected_peak_line_counts)
    ASSERT_SUMMITS_LINE_NUMBER( CLIPPY.out.summits, "summits", expected_summits_line_counts)

    ASSERT_PEAKS_MD5( CLIPPY.out.peaks, "peaks", expected_peak_hashes)
    ASSERT_SUMMITS_MD5( CLIPPY.out.summits, "summits", expected_summits_hashes)
}
