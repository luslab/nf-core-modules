#!/usr/bin/env nextflow

nextflow.enable.dsl=2
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CELLRANGER_MKREF {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }

    container "streitlab/custom-nf-modules-cellranger:latest"

    input:
    path gtf
    path fasta

    output:
    path 'reference' , emit: reference
    path '*.version.txt'    , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    cellranger mkref \\
        --genome=reference \\
        --genes=${gtf} \\
        --fasta=${fasta} \\
        --nthreads=${task.cpus}
    echo \$(cellranger --version 2>&1) | sed 's/^.*cellranger //; s/ .*\$//' > ${software}.version.txt
    """
}
