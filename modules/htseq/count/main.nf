process HTSEQ_COUNT {
    tag "$meta.id"
    label "min_cores"
    label "low_mem"
    label "regular_queue"

    conda (params.enable_conda ? "bioconda::htseq=0.13.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/htseq:0.13.5--py39h70b41aa_1' :
        'quay.io/biocontainers/htseq:0.13.5--py39h70b41aa_1' }"

    input:
    tuple val(meta), path(bam), path (bai)
    path gtf

    output:
    tuple val(meta), path("*.tsv"), emit: counts
    path "versions.yml",            emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    """
    htseq-count \\
        $args \\
        ${bam} \\
        ${gtf} \\
        --nprocesses $task.cpus \\
        > ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htseq-count: \$(htseq-count --version)
    END_VERSIONS
    """
}
