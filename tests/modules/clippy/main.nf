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
    sample1: 1,
    sample4: 1
]

expected_summits_line_counts = [
    sample1: 26,
    sample4: 13
]

expected_peak_hashes = [
    sample1: "4d2c3fab6ce49cae7cc56e94e5cc20b0",
    sample4: "1bd965210ff9d6d523fd0bdf46bb137b"
]

expected_summits_hashes = [
    sample1: "6047b4a5e14021a9d4e61fd97b04ae9a",
    sample4: "58ab0d9fb902851e0f0dbb9c7dc3fdce"
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
