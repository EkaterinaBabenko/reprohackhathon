
/*
 * Include modules
 */

include { DOWNLOAD_SRA } from ./modules/download_sra.nf

include { DOWNLOAD_REF } from ./modules/download_ref.nf

include { TRIMMING } from ./modules/trimming.nf

include { BOWTIE_INDEX } from ./modules/bowtie_index.nf

include { BOWTIE_MAP } from ./modules/bowtie_map.nf

include { FEATURECOUNTS } from ./modules/featurecounts.nf

include { DESEQ2 } from ./modules/deseq2.nf


/*
 * Pipeline parameters
 */

 params {
    samplesheet: Path = 'data/samples.csv' // colonnes : sample, condition, sra_id
 }

 workflow {

    main:

    publish:

 }

 output {

 }