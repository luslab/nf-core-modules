#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

// include { initOptions; saveFiles; getSoftwareName } from '../functions'
// params.options = [:]
// options        = initOptions(params.options)

include { ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_CONVERT; ASSERT_CHANNEL_COUNT as ASSERT_CHANNEL_COUNT_VERSION } from '../../../../test_workflows/assertions/main.nf'
include { ASSERT_LINE_NUMBER   } from '../../../../test_workflows/assertions/main.nf'
include { PARACLU_CONVERT } from '../main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

test_data = [
    [[id: 'sample1'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/paraclu/sample1.peaks.tsv.gz"],
    [[id: 'sample4'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/paraclu/sample4.peaks.tsv.gz"]
]

// Define test data input channels
Channel
    .from( test_data )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_peaks }

expected_line_counts = [
    sample1: 7,
    sample4: 4
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {

    PARACLU_CONVERT { ch_peaks }

    ASSERT_CHANNEL_COUNT_CONVERT( PARACLU_CONVERT.out.peaks, "PARACLU_CONVERT", 2 )
    ASSERT_CHANNEL_COUNT_VERSION( PARACLU_CONVERT.out.version, "PARACLU_VERSION", 2 )
    ASSERT_LINE_NUMBER( PARACLU_CONVERT.out.peaks, "PARACLU_CONVERT", expected_line_counts )

}