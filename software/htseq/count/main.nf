// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process HTSEQ_COUNT {
    tag "$meta.id"
    label "min_cores"
    label "low_mem"
    label "regular_queue"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::htseq=0.13.5" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/htseq:0.13.5--py39h70b41aa_1"
    } else {
        container "quay.io/biocontainers/htseq:0.13.5--py39h70b41aa_1"
    }

    input:
    tuple val(meta), path(bam)
    path gtf

    output:

    tuple val(meta), path("${prefix}"), emit: counts
    path "*.version.txt"              , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    htseq-count \\
        ${options.args} \\
        ${bam} \\
        ${gtf} \\
        --nprocesses $task.cpus
        >
        ${prefix}


    htseq-count --version > ${software}.version.txt
    """
}
