#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

// include { initOptions; saveFiles; getSoftwareName } from '../functions'
// params.options = [:]
// options        = initOptions(params.options)

include { ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_COVERAGE; ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_VERSION } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_LINE_NUMBER   } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_MD5 } from '../../../../test_workflows/assertions/main.nf'
include { CROSSLINKS_COVERAGE } from '../../../../modules/crosslinks/coverage/main.nf'

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
    sample1: "ff9b521a5df120954cecda3d1a0ca6e9",
    sample4: "d8864451152a2047ee005d0ae79f204a"
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    CROSSLINKS_COVERAGE { ch_crosslinks }

    ASSERT_CHANNEL_COUNT_COVERAGE( CROSSLINKS_COVERAGE.out.bedgraph, "CROSSLINKS_CONVERT", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( CROSSLINKS_COVERAGE.out.version, "CROSSLINKS_VERSION", 2 )
    ASSERT_LINE_NUMBER( CROSSLINKS_COVERAGE.out.bedgraph, "CROSSLINKS_CONVERT", expected_line_counts )
    ASSERT_MD5( CROSSLINKS_COVERAGE.out.bedgraph, "CROSSLINKS_CONVERT", expected_md5_hashes )

}
