#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Don't overwrite global params.modules, create a copy instead and use that within the main script.
def analysis_scripts = [:]
analysis_scripts.r_test = file("$baseDir/bin/r_test.R", checkIfExists: true)

include {R} from '../main.nf' addParams(script: analysis_scripts.r_test)

// Define test data
test_data = [
    [[id:"sample1"], "$baseDir/../../../test_data/r/test.csv"]
] 

// Define test data channel
Channel
    .from(test_data)
    .map{row -> [row[0], file(row[1], checkIfExists: true)]}
    .set {ch_test}

workflow {
    R (ch_test)
}