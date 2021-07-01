#!/bin/bash

rm -rf modules

nf-core modules install --tool bedtools/bamtobed .
nf-core modules -r luslab/nf-core-modules -b feat-get-crosslinks install --tool bedtools/genomecov .
nf-core modules -r luslab/nf-core-modules -b feat-get-crosslinks install --tool bedtools/shift .
nf-core modules -r luslab/nf-core-modules -b feat-get-crosslinks install --tool crosslinks/genomecovtobed .

mkdir -p modules/external/crosslinks/bamtoxlinks
cp ../*.nf modules/external/crosslinks/bamtoxlinks/
cp ../*.yml modules/external/crosslinks/bamtoxlinks/

nextflow run main.nf
