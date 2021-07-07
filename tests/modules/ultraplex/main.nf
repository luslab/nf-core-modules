#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for ultraplex...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

params.verbose = true

/*------------------------------------------------------------------------------------*/
/* Module inclusions
--------------------------------------------------------------------------------------*/

include {ULTRAPLEX as ULTRAPLEX_SINGLE} from '../../../modules/ultraplex/main.nf' addParams(options: [ publish_dir: 'ultraplex_single' ] )
include {ULTRAPLEX as ULTRAPLEX_PAIRED} from '../../../modules/ultraplex/main.nf' addParams(options: [ publish_dir: 'ultraplex_paired' ] )
include {ULTRAPLEX as ULTRAPLEX_ARGS} from '../../../modules/ultraplex/main.nf' addParams(options: [ publish_dir: 'ultraplex_single_args', args: '--phredquality 0' ] )
include {ASSERT_CHANNEL_COUNT} from '../../../test_workflows/assertions/test/main.nf'
//include {ASSERT_LINE_NUMBER as line_count_1; ASSERT_LINE_NUMBER as line_count_2; ASSERT_LINE_NUMBER as line_count_3; ASSERT_LINE_NUMBER as line_count_4; ASSERT_LINE_NUMBER as line_count_5} from "../../../test_workflows/assertions/main.nf"


/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

test_data_single_end = [
    [[id:'single_end'],
        "${params.test_data_dir}fasta/ultraplex_reads1.fastq.gz"]
]

test_data_paired_end = [
    [[id:'paired_end'], [
        "${params.test_data_dir}fasta/ultraplex_reads1.fastq.gz",
        "${params.test_data_dir}fasta/ultraplex_reads2.fastq.gz"]]
]

barcodes = "${params.test_data_dir}csv/ultraplex_barcodes_5_and_3.csv"

Channel
    .from(test_data_single_end)
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_fastq_single_end }

Channel
    .from(test_data_paired_end)
    .map { row -> [ row[0], [file(row[1][0], checkIfExists: true),
                             file(row[1][1], checkIfExists: true)] ] }
    .set { ch_fastq_paired_end }

Channel
    .value(file(barcodes))
    .set { barcodes }

single_end_valid_reads_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT: 248,
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC: 260,
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG: 256,
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT: 236,
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC: 252,
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG: 248,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT: 260,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC: 260,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG: 244
]

single_end_no_match_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_no_match: 2596,
    ultraplex_demux_5bc_NNCCANN_3bc_no_match: 2624,
    ultraplex_demux_5bc_NNGCGNN_3bc_no_match: 2596
]

single_end_zero_phred_valid_reads_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT: 268,
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC: 268,
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG: 268,
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT: 268,
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC: 268,
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG: 268,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT: 268,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC: 268,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG: 268
]

single_end_zero_phred_no_match_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_no_match: 2556,
    ultraplex_demux_5bc_NNCCANN_3bc_no_match: 2556,
    ultraplex_demux_5bc_NNGCGNN_3bc_no_match: 2556
]

paired_end_valid_reads_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT_Fwd: 1120,
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT_Rev: 1120,
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC_Fwd: 1120,
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC_Rev: 1120,
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG_Fwd: 1120,
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG_Rev: 1120,
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT_Fwd: 1120,
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT_Rev: 1120,
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC_Fwd: 1120,
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC_Rev: 1120,
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG_Fwd: 1120,
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG_Rev: 1120,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT_Fwd: 1120,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT_Rev: 1120,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC_Fwd: 1120,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC_Rev: 1120,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG_Fwd: 1120,
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG_Rev: 1120
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    ULTRAPLEX_SINGLE ( ch_fastq_single_end, barcodes )

    ULTRAPLEX_SINGLE.out.fastq
        .map{ it[1] }
        .flatten()
        .map{ [ it.getSimpleName(), it ] }
        .set{ ch_valid_reads_single }

    ULTRAPLEX_SINGLE.out.no_match_fastq
        .map{ it[1] }
        .flatten()
        .map{ [ it.getSimpleName(), it ] }
        .set{ ch_no_match_reads_single }

    // Testing channel outputs
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_SINGLE.out.fastq, "fastq", 1)
    // Checking that 9 files are returned
    ASSERT_CHANNEL_COUNT( ch_valid_reads_single , "fastq", 9)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_SINGLE.out.no_match_fastq, "no_match_fastq", 1)
    // Checking that 3 no_match files are returned
    ASSERT_CHANNEL_COUNT( ch_no_match_reads_single, "no_match_fastq", 3)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_SINGLE.out.report, "report", 1)

    // Testing fastq output lengths
    //line_count_1( ch_valid_reads_single, "single_valid_reads",
    //    single_end_valid_reads_line_count )
    //line_count_2( ch_no_match_reads_single, "single_no_match",
    //    single_end_no_match_line_count )

    // DIFFERENT ARGS

    ULTRAPLEX_ARGS ( ch_fastq_single_end, barcodes )

    ULTRAPLEX_ARGS.out.fastq
        .map{ it[1] }
        .flatten()
        .map{ [ it.getSimpleName(), it ] }
        .set{ ch_valid_reads_single_args }

    ULTRAPLEX_ARGS.out.no_match_fastq
        .map{ it[1] }
        .flatten()
        .map{ [ it.getSimpleName(), it ] }
        .set{ ch_no_match_reads_single_args }

    // Testing channel outputs
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_ARGS.out.fastq, "fastq", 1)
    // Checking that 9 files are returned
    ASSERT_CHANNEL_COUNT( ch_valid_reads_single_args , "fastq", 9)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_ARGS.out.no_match_fastq, "no_match_fastq", 1)
    // Checking that 3 no_match files are returned
    ASSERT_CHANNEL_COUNT( ch_no_match_reads_single_args, "no_match_fastq", 3)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_ARGS.out.report, "report", 1)

    // Testing fastq output lengths
    //line_count_3( ch_valid_reads_single_args, "single_valid_reads_args",
    //    single_end_zero_phred_valid_reads_line_count )
    //line_count_4( ch_no_match_reads_single_args, "single_no_match_args",
    //    single_end_zero_phred_no_match_line_count )

    // PAIRED END

    ULTRAPLEX_PAIRED ( ch_fastq_paired_end, barcodes )

    ULTRAPLEX_PAIRED.out.fastq
        .map{ it[1] }
        .flatten()
        .map{ [ it.getSimpleName(), it ] }
        .set{ ch_valid_reads_paired }

    // Testing channel outputs
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_PAIRED.out.fastq, "fastq", 1)
    // Checking that 18 files are returned
    ASSERT_CHANNEL_COUNT( ch_valid_reads_paired, "fastq", 18)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_PAIRED.out.no_match_fastq, "no_match_fastq", 0)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_PAIRED.out.report, "report", 1)

    // // Testing fastq output lengths
    //line_count_5( ch_valid_reads_paired, "paired_valid_reads_args",
    //    paired_end_valid_reads_line_count )
}