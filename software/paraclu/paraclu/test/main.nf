#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

// include { initOptions; saveFiles; getSoftwareName } from '../functions'
// params.options = [:]
// options        = initOptions(params.options)

include { ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_SIGXLS; ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_VERSION } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_LINE_NUMBER   } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_MD5 } from '../../../../test_workflows/assertions/main.nf'
include { PARACLU } from '../main.nf' addParams( options: params.modules['paraclu'] ) 

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample1.xl.bed.gz"],
    [[id: 'sample4'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/crosslinks/sample4.xl.bed.gz"]
]

// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_crosslinks }

expected_line_counts = [
    sample1: 81,
    sample4: 58
]

expected_md5_hashes = [
    sample1: "502ce598c665dae472a681a66cb241a7",
    sample4: "b92fb62a4f8871ec9a5956c8f0822c48"
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    PARACLU { ch_crosslinks }

    ASSERT_CHANNEL_COUNT_SIGXLS( PARACLU.out.sigxls, "PARACLU_SIGXL", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( PARACLU.out.version, "PARACLU_VERSION", 2 )
    ASSERT_LINE_NUMBER( PARACLU.out.sigxls, "PARACLU", expected_line_counts )
    ASSERT_MD5( PARACLU.out.sigxls, "PARACLU", expected_md5_hashes )

}