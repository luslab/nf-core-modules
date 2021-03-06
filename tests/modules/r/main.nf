#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

def analysis_scripts = [:]
analysis_scripts.r_test = file("$projectDir/bin/r_test.R", checkIfExists: true)

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include { R } from '../../../modules/r/main.nf' addParams(script: analysis_scripts.r_test)
include { ASSERT_CHANNEL_COUNT } from '../../../test_workflows/assertions/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/
test_data = [
    [[id:"sample1"], "${params.test_data_dir}metadata/10x_test.csv"]
] 

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

Channel
    .from(test_data)
    .map{row -> [row[0], file(row[1], checkIfExists: true)]}
    .set {ch_test}

workflow {
    R (ch_test)
    ASSERT_CHANNEL_COUNT( R.out.r_output, "r_output", 1)
}