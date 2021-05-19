/*------------------------------------------------------------------------------------*/
/* Processes
--------------------------------------------------------------------------------------*/

process COUNT_LINES {
    label "min_cores"
    label "min_mem"
    label "regular_queue"

    tag "$meta.sample_id"

    container "biocontainers/biocontainers:v1.2.0_cv1"

    input:
    tuple val(meta), path(input_file)

    output:
    tuple val(meta), stdout, emit: line_count

    // Treats gzipped and uncompressed files similarly
    script:
    """
    echo -n "\$(zcat -f $input_file | wc -l)"
    """
}

/*------------------------------------------------------------------------------------*/
/* Workflows
--------------------------------------------------------------------------------------*/

// Check number of items in an output channel
workflow ASSERT_CHANNEL_COUNT {
    take: 
    test_channel
    channel_name
    expected

    main:
        test_channel.count()
            .subscribe{
                channel_count = it
                if(channel_count != expected) {
                    throw new Exception(channel_name + " channel count is " + channel_count + ", expected count is " + expected);
                }
        }
}

workflow ASSERT_LINE_NUMBER {
    take: 
    test_channel
    channel_name
    expected_line_counts

    main:
        COUNT_LINES(test_channel)

        COUNT_LINES.out.subscribe {
            if(expected_line_counts[it[0].sample_id] != it[1].toInteger()) {
                throw new Exception("Error with channel " + channel_name + ": Sample " + it[0].sample_id + " is expected to have " + expected_line_counts[it[0].sample_id] + " lines, but has " + it[1])
            }
        }
}