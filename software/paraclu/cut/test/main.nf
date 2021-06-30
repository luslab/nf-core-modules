#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

// include { initOptions; saveFiles; getSoftwareName } from '../functions'
// params.options = [:]
// options        = initOptions(params.options)

include { ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_CUT; ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_VERSION } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_LINE_NUMBER   } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_MD5 } from '../../../../test_workflows/assertions/main.nf'
include { PARACLU_CUT } from '../main.nf' addParams( options: params.modules['paraclu_cut'] ) 

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/paraclu/sample1.sigxls.tsv.gz"],
    [[id: 'sample4'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/paraclu/sample4.sigxls.tsv.gz"]
]

// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_sigxls }

expected_line_counts = [
    sample1: 7,
    sample4: 4
]

expected_md5_hashes = [
    sample1: "fce464b22027b514946e59347a07fce3",
    sample4: "8fa2dc20c946b94dde73c1241183384f"
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    PARACLU_CUT { ch_sigxls }

    ASSERT_CHANNEL_COUNT_CUT( PARACLU_CUT.out.peaks, "PARACLU_CUT", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( PARACLU_CUT.out.version, "PARACLU_VERSION", 2 )
    ASSERT_LINE_NUMBER( PARACLU_CUT.out.peaks, "PARACLU_CUT", expected_line_counts )
    ASSERT_MD5( PARACLU_CUT.out.peaks, "PARACLU_CUT", expected_md5_hashes )

}