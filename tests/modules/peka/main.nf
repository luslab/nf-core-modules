#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Log
log.info ("Starting tests for PEKA...")

/*------------------------------------------------------------------------------------*/
/* Define params
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------*/
/* Module inclusions 
--------------------------------------------------------------------------------------*/

include {PEKA} from '../../../modules/peka/main.nf' addParams( options: [args: "-sr intron UTR3"] )
include {
    ASSERT_CHANNEL_COUNT;
    ASSERT_LINE_NUMBER as ASSERT_DISTRIBUTION_LINE_NUMBER;
    ASSERT_LINE_NUMBER as ASSERT_CLUSTER_LINE_NUMBER
} from "../../../test_workflows/assertions/main.nf"

/*------------------------------------------------------------------------------------*/
/* Define input channels
--------------------------------------------------------------------------------------*/

peka_repo = "https://raw.githubusercontent.com/ulelab/peka/main/"

// Peaks channel
test_peaks = [
    [
        [id:"K562-TIA1"],
        "${peka_repo}TestData/inputs/K562-TIA1-chr20.xl_peaks.bed.gz"
    ]
]
Channel
    .from(test_peaks)
    .map{ row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set{ ch_peaks }

// Crosslinks channel
test_crosslinks = [
    [
        [id:"K562-TIA1"],
        "${peka_repo}TestData/inputs/K562-TIA1-chr20.xl.bed.gz"
    ]
]
Channel
    .from(test_crosslinks)
    .map{ row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set{ ch_crosslinks }

// Genome channel
Channel
    .value("${params.test_data_dir}fasta/GRCh38.p12.chr20.masked.fa")
    .set {ch_genome}

// FAI channel
Channel
    .value("${params.test_data_dir}fai/GRCh38.p12.chr20.masked.fa.fai")
    .set {ch_fai}

// GTF channel
Channel
    .value("${params.test_data_dir}gtf/sorted.regions.chr20.gtf.gz")
    .set {ch_gtf}

expected_distribution_line_counts = [
    "K562-TIA1_intron": 1025,
    "K562-TIA1_UTR3": 1025
]

expected_cluster_line_counts = [
    "K562-TIA1_intron": 298,
    "K562-TIA1_UTR3": 298
]

/*------------------------------------------------------------------------------------*/
/* Run tests
--------------------------------------------------------------------------------------*/

// As PEKA returns multiple files for each sample, one per feature, this
// function takes the id from meta, appends the feature to the id, and returns
// that feature
unfold_meta = { it ->
    it[1].collect{ n ->
        meta = [id: it[0].id + "_" + n.getSimpleName().split('_')[-1]]
        [meta, n]
    }
}

workflow {
    PEKA(
        ch_peaks,
        ch_crosslinks,
        ch_genome,
        ch_fai,
        ch_gtf
    )

    ASSERT_CHANNEL_COUNT( PEKA.out.distribution, "distribution", 1)
    ASSERT_CHANNEL_COUNT( PEKA.out.cluster, "cluster", 1)
    ASSERT_CHANNEL_COUNT( PEKA.out.pdf, "pdf", 1)
    ASSERT_CHANNEL_COUNT( PEKA.out.version, "version", 1)

    ASSERT_DISTRIBUTION_LINE_NUMBER(
        PEKA.out.distribution.map( unfold_meta ).flatten().collate(2),
        "distribution",
        expected_distribution_line_counts
    )
    ASSERT_CLUSTER_LINE_NUMBER(
        PEKA.out.cluster.map( unfold_meta ).flatten().collate(2),
        "cluster",
        expected_cluster_line_counts
    )

}

