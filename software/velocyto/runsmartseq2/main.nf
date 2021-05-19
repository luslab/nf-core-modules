// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process VELOCYTO_RUNSMARTSEQ2 {
    tag "$meta.id"
    label "avg_cores"
    label "avg_mem"
    label "regular_queue"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::velocyto.py=0.17.17" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/velocyto.py:0.17.17--py38h9af456f_3"
    } else {
        container "quay.io/biocontainers/velocyto.py:0.17.17--py38h9af456f_3"
    }

    input:
    tuple val(meta), path(bam), path(bai)
    path gtf

    output:
    tuple val(meta), path("*.loom"), emit: velocyto
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    velocyto \\
        run-smartseq2 \\
        $options.args \\
        -o . \\
        $bam \\
        $gtf \\

    """
}
