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

include {ULTRAPLEX as ULTRAPLEX_SINGLE} from '../../../modules/ultraplex/main.nf'
include {ULTRAPLEX as ULTRAPLEX_PAIRED} from '../../../modules/ultraplex/main.nf'
include {ULTRAPLEX as ULTRAPLEX_ARGS} from '../../../modules/ultraplex/main.nf'
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER as ASSERT_LINE_NUMBER_SINGLE;
    ASSERT_LINE_NUMBER as ASSERT_LINE_NUMBER_SINGLE_NOMATCH;
    ASSERT_LINE_NUMBER as ASSERT_LINE_NUMBER_ARGS;
    ASSERT_LINE_NUMBER as ASSERT_LINE_NUMBER_ARGS_NOMATCH;
    ASSERT_LINE_NUMBER as ASSERT_LINE_NUMBER_PAIRED
    ASSERT_MD5 as ASSERT_MD5_SINGLE;
    ASSERT_MD5 as ASSERT_MD5_SINGLE_NOMATCH;
    ASSERT_MD5 as ASSERT_MD5_ARGS;
    ASSERT_MD5 as ASSERT_MD5_ARGS_NOMATCH;
    ASSERT_MD5 as ASSERT_MD5_PAIRED } from "../../../test_workflows/assertions/main.nf"


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

single_end_valid_reads_hashes = [
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG: "dd5ca5a3b0d7f9a029b0cb3c7eab12ce",
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC: "46859593cf07ea79f80a2aaa4586b5de",
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT: "be96d6811322b0fe39824d6943c5c7c6",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC: "7075f8565c0d3a36624ead7eb5f5f464",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT: "ef8c0e2201f2f90a44b5b748d502d76f",
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG: "6d8b4ad6873a342b9c459c5b8c97137f",
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG: "b4950cd651b9a48bd2c3ddaab5407ad1",
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC: "7801a8f532919579e30ee9968c98ecf0",
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT: "3d4051f529d26e0a6f34faeddc8208f8"
]

single_end_no_match_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_no_match: 2596,
    ultraplex_demux_5bc_NNCCANN_3bc_no_match: 2624,
    ultraplex_demux_5bc_NNGCGNN_3bc_no_match: 2596
]

single_end_no_match_hashes = [
    ultraplex_demux_5bc_NNGCGNN_3bc_no_match: "80e7cb67b7a2e06f39b40032c263f4ef",
    ultraplex_demux_5bc_NNCCANN_3bc_no_match: "dc922af64362244c01863cc6a4f2e0dc",
    ultraplex_demux_5bc_NNATGNN_3bc_no_match: "1c21cc3476f027b66504812808d19af9"
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

single_end_zero_phred_valid_reads_hashes = [
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG: "575da2a57ea0bd159b3bccec74aa2ff5",
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC: "2686690141610e2fa21ce4b5f64961a0",
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT: "1083022230796784d7f69ca11df6b2fa",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC: "e121be78cfb234724d3510fcace6b952",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT: "52c32a63ecc87f0dc2f63c80deac6316",
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG: "a012bc5a021866baf2ff8091a3a8efca",
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG: "6786ca9395b1cbd4cb9aa66ce5555bb8",
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC: "c0fc2552ee00d6b3a9e455d74359a1b6",
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT: "aa47223a9a958c9cd11cc8d4b2e68c0c"
]

single_end_zero_phred_no_match_line_count = [
    ultraplex_demux_5bc_NNATGNN_3bc_no_match: 2556,
    ultraplex_demux_5bc_NNCCANN_3bc_no_match: 2556,
    ultraplex_demux_5bc_NNGCGNN_3bc_no_match: 2556
]

single_end_zero_phred_no_match_hashes = [
    ultraplex_demux_5bc_NNGCGNN_3bc_no_match: "3b9051e6c7c2c1f88c0b5517d5c69788",
    ultraplex_demux_5bc_NNCCANN_3bc_no_match: "f4ead754bccd3a8b323c1f3ccd158422",
    ultraplex_demux_5bc_NNATGNN_3bc_no_match: "9cb80f89605d8b283f75749929191fc7"
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

paired_end_valid_reads_hashes = [
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC_Fwd: "4e06a3acf4c255984c99422603f3e885",
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT_Fwd: "0e0fb2326b7d8c5934557983b02511ef",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG_Fwd: "f74d82229e369467911c788465f598b0",
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC_Rev: "2f6eaddd40c5b421fe6228302f356350",
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG_Rev: "15d50fa39bfddabfd62e5f8d5a25184b",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT_Rev: "521985cd50372c18c8cbcb4b2f724d85",
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG_Rev: "b6cceac1916e7ac043b949490ccac122",
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC_Rev: "373a60ee2cf239e58c330d55c9769924",
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT_Fwd: "cce5fea5454578316ec0ee5de757196f",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNTG_Rev: "f96c8aafe6be26708a80fc229d62f523",
    ultraplex_demux_5bc_NNATGNN_3bc_NNAT_Rev: "5dc9622f97c08ef043a6593a350fdb9c",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNCC_Rev: "befa4fcfe6a42b658fac0c830769f040",
    ultraplex_demux_5bc_NNGCGNN_3bc_NNAT_Fwd: "1e9506a8c321653d5c0289d226f01551",
    ultraplex_demux_5bc_NNATGNN_3bc_NNTG_Fwd: "93e2e57ade3cf5afef3d18b2bc17283f",
    ultraplex_demux_5bc_NNATGNN_3bc_NNCC_Fwd: "e0fc008aa324381576b29731ceefe94a",
    ultraplex_demux_5bc_NNCCANN_3bc_NNCC_Fwd: "4e82201590de288649689c0c8c160057",
    ultraplex_demux_5bc_NNCCANN_3bc_NNTG_Fwd: "9a90f19672e5167bc39f95729f137f0d",
    ultraplex_demux_5bc_NNCCANN_3bc_NNAT_Rev: "c75a3e9c5d4d00d6d2e1e965dec9b2fa"
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/
  
workflow {
    ULTRAPLEX_SINGLE ( ch_fastq_single_end, barcodes )

    ULTRAPLEX_SINGLE.out.fastq
        .map{ it[1] }
        .flatten()
        .map{ [ ["id": it.getSimpleName()], it ] }
        .set{ ch_valid_reads_single }

    ULTRAPLEX_SINGLE.out.no_match_fastq
        .map{ it[1] }
        .flatten()
        .map{ [ ["id": it.getSimpleName()], it ] }
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
    ASSERT_LINE_NUMBER_SINGLE (
        ch_valid_reads_single,
        "single_valid_reads",
        single_end_valid_reads_line_count
    )
    ASSERT_LINE_NUMBER_SINGLE_NOMATCH (
        ch_no_match_reads_single,
        "single_no_match",
        single_end_no_match_line_count
    )
    ASSERT_MD5_SINGLE (
        ch_valid_reads_single,
        "single_valid_reads",
        single_end_valid_reads_hashes
    )
    ASSERT_MD5_SINGLE_NOMATCH (
        ch_no_match_reads_single,
        "single_no_match",
        single_end_no_match_hashes
    )

    // DIFFERENT ARGS

    ULTRAPLEX_ARGS ( ch_fastq_single_end, barcodes )

    ULTRAPLEX_ARGS.out.fastq
        .map{ it[1] }
        .flatten()
        .map{ [ ["id": it.getSimpleName()], it ] }
        .set{ ch_valid_reads_single_args }

    ULTRAPLEX_ARGS.out.no_match_fastq
        .map{ it[1] }
        .flatten()
        .map{ [ ["id": it.getSimpleName()], it ] }
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
    ASSERT_LINE_NUMBER_ARGS (
        ch_valid_reads_single_args,
        "single_valid_reads_args",
        single_end_zero_phred_valid_reads_line_count
    )
    ASSERT_LINE_NUMBER_ARGS_NOMATCH (
        ch_no_match_reads_single_args,
        "single_no_match_args",
        single_end_zero_phred_no_match_line_count
    )
    ASSERT_MD5_ARGS (
        ch_valid_reads_single_args,
        "single_valid_reads_args",
        single_end_zero_phred_valid_reads_hashes
    )
    ASSERT_MD5_ARGS_NOMATCH (
        ch_no_match_reads_single_args,
        "single_no_match_args",
        single_end_zero_phred_no_match_hashes
    )


    // PAIRED END

    ULTRAPLEX_PAIRED ( ch_fastq_paired_end, barcodes )

    ULTRAPLEX_PAIRED.out.fastq
        .map{ it[1] }
        .flatten()
        .map{ [ ["id": it.getSimpleName()], it ] }
        .set{ ch_valid_reads_paired }

    // Testing channel outputs
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_PAIRED.out.fastq, "fastq", 1)
    // Checking that 18 files are returned
    ASSERT_CHANNEL_COUNT( ch_valid_reads_paired, "fastq", 18)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_PAIRED.out.no_match_fastq, "no_match_fastq", 0)
    ASSERT_CHANNEL_COUNT( ULTRAPLEX_PAIRED.out.report, "report", 1)

    // Testing fastq output lengths
    ASSERT_LINE_NUMBER_PAIRED (
        ch_valid_reads_paired,
        "paired_valid_reads_args",
        paired_end_valid_reads_line_count
    )
    ASSERT_MD5_PAIRED (
        ch_valid_reads_paired,
        "paired_valid_reads_args",
        paired_end_valid_reads_hashes
    )
}
