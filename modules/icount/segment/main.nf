include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ICOUNT_SEGMENT {
    tag "$gtf"
    label "low_cores"
    label "low_mem"
    label "regular_queue"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:"icount_summary", meta:[:], publish_by_meta:[]) }

    conda (params.enable_conda ? "bioconda::icount-mini=2.0.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/icount-mini:2.0.3--pyh5e36f6f_0"
    } else {
        container "quay.io/biocontainers/icount-mini:2.0.3--pyh5e36f6f_0"
    }

    input:
    path(gtf)
    path(fai)

    output:
    path("icount_segmentation.gtf")       , emit: gtf
    path("regions.gtf.gz")       , emit: regions
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    def filename = "icount_segmentation"
    def prefix   = options.suffix ? "${filename}${options.suffix}" : "${filename}"
    """
    iCount-Mini segment \\
        $gtf \\
        ${prefix}.gtf \\
        $fai
    echo \$(iCount-Mini -v) > ${software}.version.txt
    """
}
