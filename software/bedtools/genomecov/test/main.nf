#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for bedtools genomecov...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/

include { BEDTOOLS_GENOMECOV } from '../main.nf' addParams( options: [args: "-dz"] )
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER;
    ASSERT_MD5
} from "../../../../test_workflows/assertions/main.nf"

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

test_data = [
    [
        [id: 'sample1'],
        "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample1.xl.bed.gz"
    ],
    [
        [id: 'sample4'],
        "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample4.xl.bed.gz"
    ]
]

// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_crosslinks }

Channel
    .value(
        "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/fai/chr6.fai"
    )
    .set { ch_fai }

expected_line_count = [
    sample1: 254,
    sample4: 194
]

expected_hash = [
    sample1: "8b6c760a2867f2a4b2716c696d3226d1",
    sample4: "ad316b0562663f4bf40e793e8241eb2c"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    BEDTOOLS_GENOMECOV( ch_crosslinks, ch_fai) 

    ASSERT_CHANNEL_COUNT( BEDTOOLS_GENOMECOV.out.bed, "bed", 2)
    ASSERT_CHANNEL_COUNT( BEDTOOLS_GENOMECOV.out.version, "version", 2)

    ASSERT_LINE_NUMBER( BEDTOOLS_GENOMECOV.out.bed, "bed", expected_line_count)

    ASSERT_MD5( BEDTOOLS_GENOMECOV.out.bed, "bed", expected_hash)
}
