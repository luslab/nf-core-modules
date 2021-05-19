// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process R {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }

    container "luslab/nf-modules-r:latest"

    input:
    tuple val(meta), path('input/*')

    output:
    tuple val(meta), file('*'), emit: r_output
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    Rscript \\
        $params.script \\
        --cores $task.cpus \\
        --runtype nextflow \\
        $options.args

    rm -r input
    echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' > ${software}.version.txt
    """
}
