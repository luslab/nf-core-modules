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
include { PARACLU_CUT } from '../main.nf' addParams( options: params.modules['paraclu_cut'] ) 

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/paraclu/sample1.paraclu.tsv.gz"],
    [[id: 'sample2'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/paraclu/sample2.paraclu.tsv.gz"]
]


// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_sigxls }

expected_line_counts = [
    sample1: 7,
    sample2: 0
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    PARACLU_CUT { ch_sigxls }

    ASSERT_CHANNEL_COUNT_CUT( PARACLU_CUT.out.peaks, "PARACLU_CUT", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( PARACLU_CUT.out.version, "PARACLU_VERSION", 2 )
    ASSERT_LINE_NUMBER( PARACLU_CUT.out.peaks, "PARACLU_CUT", expected_line_counts )

}