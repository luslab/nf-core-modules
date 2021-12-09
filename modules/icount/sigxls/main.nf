include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ICOUNT_SIGXLS {
    tag "$meta.id"
    label "low_cores"
    label "low_mem"
    label "regular_queue"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:"icount_sigxls", meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::icount-mini=2.0.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/icount-mini:2.0.3--pyh5e36f6f_0"
    } else {
        container "quay.io/biocontainers/icount-mini:2.0.3--pyh5e36f6f_0"
    }

    input:
    tuple val(meta), path(bed)
    path(segmentation)

    output:
    tuple val(meta), path("*.sigxls.bed.gz"), emit: sigxls
    tuple val(meta), path("*.scores.tsv")  , emit: scores
    path "*.version.txt"                   , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    iCount-Mini sigxls \\
        $segmentation \\
        $bed \\
        ${prefix}.sigxls.bed.gz \\
        --scores ${prefix}.scores.tsv \\
        $options.args
    echo \$(iCount-Mini -v) > ${software}.version.txt
    """
}