#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

// include { initOptions; saveFiles; getSoftwareName } from '../functions'
// params.options = [:]
// options        = initOptions(params.options)

include { ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_SIGXL; ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_VERSION } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_LINE_NUMBER   } from '../../../../test_workflows/assertions/main.nf'
include { PARACLU } from '../main.nf' addParams( options: params.modules['paraclu'] ) 

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample1.xl.bed.gz"],
    [[id: 'sample2'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample2.xl.bed.gz"]
]


// Define test data input channels
Channel
    .from(test_data)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set {ch_crosslinks}

expected_line_counts = [
    sample1: 81,
    sample2: 15
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    PARACLU { ch_crosslinks }

    ASSERT_CHANNEL_COUNT_SIGXL( PARACLU.out.sigxl, "PARACLU_SIGXL", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( PARACLU.out.version, "PARACLU_VERSION", 2 )
    ASSERT_LINE_NUMBER( PARACLU.out.sigxl, "PARACLU", expected_line_counts )

}