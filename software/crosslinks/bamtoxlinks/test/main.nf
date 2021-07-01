#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for bamtoxlinks...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/

include { BAM_TO_XLINKS } from './modules/external/crosslinks/bamtoxlinks/main.nf'
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER;
    ASSERT_MD5
} from "../../../../test_workflows/assertions/main.nf"

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/bam_bai/sample1.bam"],
    [[id: 'sample2'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/bam_bai/sample2.bam"]
]

// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_crosslinks }

Channel
    .value("https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/fai/chr6.fai")
    .set { ch_fai }

expected_line_counts = [
    sample1: 207,
    sample2: 111
]

expected_hashes = [
    sample1: "8a3dbf71bd894803948bdac88da3faf5",
    sample2: "3363ce174ad06a3675d55d966f2ffd0a"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    BAM_TO_XLINKS( ch_crosslinks, ch_fai ) 

    ASSERT_CHANNEL_COUNT( BAM_TO_XLINKS.out.bed, "bed", 2)
    ASSERT_CHANNEL_COUNT( BAM_TO_XLINKS.out.awk_version, "awk_version", 2)
    ASSERT_CHANNEL_COUNT( BAM_TO_XLINKS.out.bedtools_version, "bedtools_version", 2)

    ASSERT_LINE_NUMBER( BAM_TO_XLINKS.out.bed, "bed", expected_line_counts)

    ASSERT_MD5( BAM_TO_XLINKS.out.bed, "bed", expected_hashes)
}
