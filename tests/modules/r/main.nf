#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { R } from '../../../modules/r/main.nf'
include { ASSERT_CHANNEL_COUNT; ASSERT_MD5 } from '../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/
test_data = [
    [[id:"sample1"], "${params.test_data_dir}metadata/10x_test.csv"]
] 

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

expected_hashes = [
    sample1: "27e07fdd6723105c0d09fa573816308e"
]

Channel
    .from(test_data)
    .map{row -> [row[0], file(row[1], checkIfExists: true)]}
    .set {ch_test}

workflow {
    R (
        file("$projectDir/bin/r_test.R", checkIfExists: true),
        ch_test
    )
    ASSERT_CHANNEL_COUNT( R.out.r_output, "r_output", 1)
    ASSERT_CHANNEL_COUNT( R.out.versions, "versions", 1)

    ASSERT_MD5( R.out.r_output, "r_output", expected_hashes)
}
