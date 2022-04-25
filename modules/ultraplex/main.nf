process ULTRAPLEX {
    tag "${meta.id}"
    label "max_cores"
    label "max_memory"
    label "regular_queue"

    conda (params.enable_conda ? "bioconda::ultraplex=1.2.5--py38h4a8c8d9_0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ultraplex:1.2.5--py38h4a8c8d9_0' :
        'quay.io/biocontainers/ultraplex:1.2.5--py38h4a8c8d9_0' }"

    input:
    tuple val(meta), path(reads)
    path(barcode_file)

    output:
    tuple val(meta), path("*[!no_match].fastq.gz"),              emit: fastq
    tuple val(meta), path("*no_match.fastq.gz"), optional: true, emit: no_match_fastq
    path "*.log",                                                emit: report
    path "versions.yml",                                         emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def ultraplex_version = "1.2.5"
    def args = task.ext.args ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    read_list = reads.collect{it.toString()}
    if (read_list.size > 1){
        ultraplex_command = """ultraplex \\
        --inputfastq ${read_list[0]} \\
        --input_2 ${read_list[1]} \\
        --barcodes $barcode_file \\
        --threads ${task.cpus} ${args}"""
    } else {
        ultraplex_command = """ultraplex \\
        --inputfastq ${read_list[0]} \\
        --barcodes $barcode_file \\
        --threads ${task.cpus} ${args}"""
    }

    """
    ${ultraplex_command}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ultraplex: $ultraplex_version
    END_VERSIONS
    """
}
