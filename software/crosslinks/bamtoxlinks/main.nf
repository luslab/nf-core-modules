//
// Extracts the coverage of the first nucleotide of each read from a BAM file
//

include { BEDTOOLS_BAMTOBED                             } from '../../../nf-core/software/bedtools/bamtobed/main.nf' addParams( options: [:] )
include { BEDTOOLS_SHIFT                                } from '../../bedtools/shift/main.nf'                        addParams( options: [args: '-m 1 -p -1', suffix: '_shifted'] )
include { BEDTOOLS_GENOMECOV as BEDTOOLS_GENOMECOV_PLUS } from '../../bedtools/genomecov/main.nf'                    addParams( options: [args: '-dz -strand + -5', suffix: '_pos'] )
include { BEDTOOLS_GENOMECOV as BEDTOOLS_GENOMECOV_NEG  } from '../../bedtools/genomecov/main.nf'                    addParams( options: [args: '-dz -strand - -5', suffix: '_neg'] )
include { CROSSLINKS_GENOMECOVTOBED                     } from '../../crosslinks/genomecovtobed/main.nf'             addParams( options: [:] )

workflow BAM_TO_XLINKS {
    take:
    bam
    fai

    main:
    // Convert the BAM to a BED file
    BEDTOOLS_BAMTOBED ( bam )

    // Shift the BED file
    BEDTOOLS_SHIFT ( BEDTOOLS_BAMTOBED.out.bed , fai)

    // Calculate the coverage for xlinks on + strand
    BEDTOOLS_GENOMECOV_PLUS ( BEDTOOLS_SHIFT.out.bed , fai)

    // Calculate the coverage for xlinks on - strand
    BEDTOOLS_GENOMECOV_NEG ( BEDTOOLS_SHIFT.out.bed , fai)

    // Convert to BED format
    CROSSLINKS_GENOMECOVTOBED(
        BEDTOOLS_GENOMECOV_PLUS.out.bed.join(BEDTOOLS_GENOMECOV_NEG.out.bed)
    )

    emit:
    bed              = CROSSLINKS_GENOMECOVTOBED.out.bed
    bedtools_version = BEDTOOLS_BAMTOBED.out.version
    awk_version      = CROSSLINKS_GENOMECOVTOBED.out.version
}
