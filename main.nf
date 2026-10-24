
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

    // create a channel for outputs
    samples_ch = channel.fromPath(params.samplesheet)
                        .view { samples -> "Before split: ${samples}"}
                        .splitCsv(header: true) // split the .csv --> one array / row
                        .map { row -> tuple(row.sample, row.condition, row. sra_id) } // transform the array in a tuple: easier to use

    // downloading samples
    download_ch = DOWNLOAD_SRA(samples_ch)
    //trimming samples
    trimmed_ch = TRIMMING(download_ch)

    // downleading the reference genome and the genome annotations
    genome_reference = DOWNLOAD_REF()
    genome_fasta = genome_reference.fasta
    genome_gff = genome_reference.gff
    bowtie_index = BOWTIE_INDEX(genome_fasta)

    // mapping
    mapped_ch = BOWTIE_MAP(trimmed_ch, bowtie_index)

    // Readcount per gene


    publish:

 }

 output {

 }