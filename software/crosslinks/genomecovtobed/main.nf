include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CROSSLINKS_GENOMECOVTOBED {
    tag "$meta.id"
    label "low_cores"
    label "low_mem"
    label "regular_queue"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://containers.biocontainers.pro/s3/SingImgsRepo/biocontainers/v1.2.0_cv1/biocontainers_v1.2.0_cv1.img"
    } else {
        container "biocontainers/biocontainers:v1.2.0_cv1"
    }

    input:
    tuple val(meta_pos), path(bed_pos)
    tuple val(meta_neg), path(bed_neg)

    output:
    tuple val(meta_pos), path("*.bed"), emit: bed
    path "*.version.txt"              , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    awk '{OFS="\t"}{if(FNR==NR) {print(\$1, \$2, \$2+1, ".", \$3, "+")} else {print(\$1, \$2, \$2+1, ".", \$3, "-")}}' \\
        $bed_pos \\
        $bed_neg \\
        | sort -k1,1 -k2,2n > ${prefix}.bed

    echo \$(awk --version 2>&1) | sed 's/^.*awk version //' > ${software}.version.txt
    """
}
