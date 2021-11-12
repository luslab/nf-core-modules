#!/usr/bin/env nextflow

nextflow.enable.dsl=2
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CELLRANGER_MKGTF {
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }

    container "streitlab/custom-nf-modules-cellranger:latest"
    
    input:
    path gtf
    
    output:
    path '*.gtf'            , emit: gtf
    path '*.version.txt'    , emit: version
    
    script:
    def software = getSoftwareName(task.process)
    
    """
    cellranger mkgtf \\
        ${gtf} \\
        ${gtf.baseName}_mkgtf.gtf \\
        ${options.args}
    echo \$(cellranger --version 2>&1) | sed 's/^.*cellranger //; s/ .*\$//' > ${software}.version.txt
    """
}
