#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info ("Starting tests for test_flows...")

/*------------------------------------------------------------------------------------*/
/* Module inclusions
/*------------------------------------------------------------------------------------*/

include { ASSERT_CHANNEL_COUNT } from '../main.nf'
include { ASSERT_LINE_NUMBER   } from '../main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
/*------------------------------------------------------------------------------------*/

Channel
    .from(1,2,3,4,5,6,7,8,9,10)
    .set {ch_items}

line_count_test_data = [
    [[sample_id: 'yeast'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/fasta/S-cerevisiae-prot.fa"],
    [[sample_id: 'human'], "https://raw.githubusercontent.com/luslab/nf-core-test-data/main/data/fasta/homosapien-hg37-chr21.fa.gz"]
]

Channel
    .from(line_count_test_data)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set {ch_wc_test}

expected_line_counts = [
    yeast: 12004,
    human: 802166
]

/*------------------------------------------------------------------------------------*/
/* Main workflow
/*------------------------------------------------------------------------------------*/

workflow {
    // Run the test with a pass condition
    ASSERT_CHANNEL_COUNT( ch_items, "test_channel", 10 )

    ASSERT_LINE_NUMBER( ch_wc_test, "wc_test_channel", expected_line_counts )
}