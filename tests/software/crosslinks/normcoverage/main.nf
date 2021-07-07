#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

// include { initOptions; saveFiles; getSoftwareName } from '../functions'
// params.options = [:]
// options        = initOptions(params.options)

include { ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_NORMCOVERAGE; ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_VERSION } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_LINE_NUMBER   } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_MD5 } from '../../../../test_workflows/assertions/main.nf'
include { CROSSLINKS_NORMCOVERAGE } from '../../../../software/crosslinks/normcoverage/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "${params.test_data_dir}crosslinks/sample1.xl.bed.gz"],
    [[id: 'sample4'], "${params.test_data_dir}crosslinks/sample4.xl.bed.gz"]
]

// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_crosslinks }

expected_line_counts = [
    sample1: 254,
    sample4: 194
]

expected_md5_hashes = [
    sample1: "3c8585d76e284f59ce75e9ba1d77acd6",
    sample4: "ae1f0992f7635fa768047bb5695edf0e"
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    CROSSLINKS_NORMCOVERAGE { ch_crosslinks }

    ASSERT_CHANNEL_COUNT_NORMCOVERAGE( CROSSLINKS_NORMCOVERAGE.out.bedgraph, "CROSSLINKS_NORMCOVERAGE", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( CROSSLINKS_NORMCOVERAGE.out.version, "CROSSLINKS_VERSION", 2 )
    ASSERT_LINE_NUMBER( CROSSLINKS_NORMCOVERAGE.out.bedgraph, "CROSSLINKS_NORMCOVERAGE", expected_line_counts )
    ASSERT_MD5( CROSSLINKS_NORMCOVERAGE.out.bedgraph, "CROSSLINKS_NORMCOVERAGE", expected_md5_hashes )

}