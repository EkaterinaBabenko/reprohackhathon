
/*
 * Include modules
 */

include { DOWNLOAD_SRA } from "./modules/download_sra.nf"

include { DOWNLOAD_REF } from "./modules/download_ref.nf"

include { TRIMMING } from "./modules/trimming.nf"

include { BOWTIE_INDEX } from "./modules/bowtie_index.nf"

include { BOWTIE_MAP } from "./modules/bowtie_map.nf"

include { FEATURECOUNTS } from "./modules/featurecounts.nf"

include { MA_PLOT } from "./modules/ma_plot.nf"

include { DESEQ2 } from "./modules/deseq2.nf"


/*
 * Pipeline parameters
 */

 params {
    samplesheet: Path
    deseq2_padj: Float = 0.05 // seuil de p-value ajustée (comme dans l'article)
 }

 workflow {

    main:

    // create a channel for outputs
    samples_ch = channel.fromPath(params.samplesheet)
                        .view { samples -> "Before split: ${samples}"}
                        .splitCsv(header: true) // split the .csv --> one array / row
                        .view { samples -> "After split: ${samples}"}
                        .map { row -> tuple(row.sample, row.condition, row.SRA_id) } // transform the array in a tuple: easier to use
                        .view { samples -> "After map: ${samples}"}

    // downloading samples
    download_ch = DOWNLOAD_SRA(samples_ch)

    //trimming samples
    trimmed_ch = TRIMMING(download_ch.reads)

    // downloading the reference genome and the genome annotations
    genome_reference = DOWNLOAD_REF()
    genome_fasta = genome_reference.fasta // reference genome
    genome_gff = genome_reference.gff // genome annotations
    bowtie_index = BOWTIE_INDEX(genome_fasta)

    // mapping
    mapped_ch = BOWTIE_MAP(trimmed_ch.reads, bowtie_index)
        .bam
        .map { sample, condition, bam, bai -> bam }

    // Readcount per gene
    counts_ch = FEATURECOUNTS(mapped_ch.collect(), genome_gff)
    counts = counts_ch.counts // counts array
    summary = counts_ch.summary // summary array

    // Analyse d'expression différentielle
    deseq2_ch = DESEQ2(counts, file(params.samplesheet))

    // MA-plot
    ma_ch = MA_PLOT(deseq2_ch.results)

    publish:
        counts_matrix = counts
        summary_matrix = summary
        deseq2_results = deseq2_ch.results
        normalized_counts = deseq2_ch.normalized
        session_info = deseq2_ch.session_info
        ma_plot = ma_ch.plot

 }

 output {
    counts_matrix {
        path { "FEATURECOUNTS" }
    }
    summary_matrix {
        path { "FEATURECOUNTS" }
    }
    deseq2_results {
        path { "DESEQ2" }
    }
    normalized_counts {
        path { "DESEQ2" }
    }
    session_info {
        path { "DESEQ2" }
    }
    ma_plot {
        path { "MA_PLOT" }
    }
 }