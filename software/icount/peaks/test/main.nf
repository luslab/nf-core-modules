#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for iCount...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/



include {ICOUNT_PEAKS} from '../main.nf' addParams( options: [args: '--half_window 3 --fdr 0.05'] )
// include {assert_channel_count} from '../../../workflows/test_flows/main.nf'

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

// Define test data
test_beds = [
    [
        [id:"sample1"],
        "https://raw.githubusercontent.com/luslab/luslab-nf-modules/master/test_data/icount/sample1.xl.bed.gz"
    ],
    [
        [id:"sample2"],
        "https://raw.githubusercontent.com/luslab/luslab-nf-modules/master/test_data/icount/sample2.xl.bed.gz"
    ]
]

// Define test data input channels 

// Seg file channel
Channel
    .value(        "https://raw.githubusercontent.com/luslab/luslab-nf-modules/master/test_data/icount/segmentation.gtf.gz")
    .set {ch_seg}

// Bed/seg channel
Channel
    .from(test_beds)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set {ch_bed}

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

workflow {
    // Run iCount
    ICOUNT_PEAKS( ch_bed, ch_seg) 

    // Collect file names and view output
    // icount.out.peaks | view
    // icount.out.peak_scores | view
    // icount.out.clusters | view

    // assert_channel_count( icount.out.peaks, "peaks", 2)
    // assert_channel_count( icount.out.peak_scores, "peak_scores", 2)
    // assert_channel_count( icount.out.clusters, "clusters", 2)
}