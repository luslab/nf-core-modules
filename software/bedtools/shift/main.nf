include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process BEDTOOLS_SHIFT {
    tag "$meta.id"
    label "low_cores"
    label "low_mem"
    label "regular_queue"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::bedtools=2.30.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bedtools:2.30.0--h7d7f7ad_1"
    } else {
        container "quay.io/biocontainers/bedtools:2.30.0--h7d7f7ad_1"
    }

    input:
    tuple val(meta), path(bed)
    path fai

    output:
    tuple val(meta), path('*.bed'), emit: bed
    path  '*.version.txt'         , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    bedtools \\
        shift \\
        -i $bed \\
        -g $fai \\
        $options.args \\
        > ${prefix}.bed
    bedtools --version | sed -e "s/bedtools v//g" > ${software}.version.txt
    """
}
