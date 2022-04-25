process R {
    tag "$meta.id"
    label 'process_low'

    container "luslab/nf-modules-r:latest"

    input:
    path(script)
    tuple val(meta), path('input/*')

    output:
    tuple val(meta), file('*'), emit: r_output
    path "versions.yml",        emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    """
    Rscript \\
        $script \\
        --cores $task.cpus \\
        --runtype nextflow \\
        $args

    rm -r input
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$(echo \$(R --version 2>&1) | sed -n 1p | sed 's/^.*version //; s/ (.*//')
    END_VERSIONS
    """
}
