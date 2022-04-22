process CLIPPY {
    tag "$meta.id"
    label "avg_cores"
    label "high_mem"
    label "regular_queue"

    conda (params.enable_conda ? "bioconda::clippy=1.3.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/clippy:1.3.1--pyhdfd78af_2' :
        'quay.io/biocontainers/clippy:1.3.1--pyhdfd78af_2' }"

    input:
    tuple val(meta), path(crosslinks)
    path(gtf)
    path(fai)

    output:
    tuple val(meta), path("$prefix*_broadPeaks.bed.gz"), emit: peaks
    tuple val(meta), path("$prefix*[0-9].bed.gz"),       emit: summits
    path "versions.yml",                                 emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    """
    clippy -i $crosslinks \
        -o $prefix \
        -a $gtf \
        -g $fai \
        -t ${task.cpus} \
        $args
    gzip -n *_broadPeaks.bed
    gzip -n *[0-9].bed
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        clippy: \$(clippy -v)
    END_VERSIONS
    """
}
