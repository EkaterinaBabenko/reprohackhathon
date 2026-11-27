/*
 * Workflow Projet 2 : Toxoplasma gondii mouse brain RNA-Seq (Hu et al., Frontiers in
 * Microbiology 2020) -- reproduction de la Fig. 2B (Venn des DETs à d11 et d33).
 *
 * Réutilise les modules du workflow-persister quand c'est possible :
 *   DOWNLOAD_SRA  <- persister (adapté : champ timepoint)
 *   TRIMMING      <- persister (cutadapt -> Trimmomatic 0.39, outil de l'article)
 *   DOWNLOAD_REF  <- persister (URLs NCBI -> Ensembl GRCm38 release 100)
 *   BUILD_TRANSCRIPTOME, SALMON_INDEX, SALMON_QUANT : nouveaux (remplacent
 *   BOWTIE_INDEX + BOWTIE_MAP + FEATURECOUNTS : quantification Salmon per-transcrit)
 *   DESEQ2        <- persister (counts featureCounts -> quant.sf Salmon, design 2x2)
 */

/*
 * Include modules
 */

include { DOWNLOAD_SRA }        from "./modules/download_sra.nf"
include { TRIMMING }           from "./modules/trimming.nf"
include { DOWNLOAD_REF }        from "./modules/download_ref.nf"
include { BUILD_TRANSCRIPTOME } from "./modules/build_transcriptome.nf"
include { SALMON_INDEX }        from "./modules/salmon_index.nf"
include { SALMON_QUANT }        from "./modules/salmon_quant.nf"
include { DESEQ2 }              from "./modules/deseq2.nf"
include { VENN }                from "./modules/venn.nf"


/*
 * Pipeline parameters
 */

 params {
    samplesheet: Path
 }

 workflow {

    main:

    // create a channel for outputs
    samples_ch = channel.fromPath(params.samplesheet)
                        .splitCsv(header: true) // split the .csv --> one array / row
                        .map { row -> tuple(row.sample, row.condition, row.timepoint, row.SRR) } // tuple: easier to use

    // downloading samples (fasterq-dump + gzip)
    download_ch = DOWNLOAD_SRA(samples_ch)

    // trimming samples (Trimmomatic 0.39)
    trimmed_ch = TRIMMING(download_ch.reads)

    // downloading the mouse reference genome (GRCm38, Ensembl 100) and annotations
    genome_reference = DOWNLOAD_REF()
    genome_fasta = genome_reference.fasta // reference genome
    genome_gff = genome_reference.gff     // genome annotations

    // build the transcriptome (cDNA fasta) from genome + annotation
    transcriptome = BUILD_TRANSCRIPTOME(genome_fasta, genome_gff).transcriptome

    // salmon index on the transcriptome
    salmon_index = SALMON_INDEX(transcriptome).index

    // quantification per sample (per-transcript counts, quant.sf)
    quant_ch = SALMON_QUANT(trimmed_ch.reads, salmon_index)

    // differential transcript expression (DESeq2 on quant.sf, design 2x2)
    deseq2_ch = DESEQ2(quant_ch.quant.map { sample, condition, timepoint, quant_dir -> quant_dir }.collect(),
                       channel.fromPath(params.samplesheet))

    // Venn diagram of DETs d11 vs d33 (Fig. 2B)
    venn_ch = VENN(deseq2_ch.det_d11, deseq2_ch.det_d33)

    publish:
        det_d11 = deseq2_ch.det_d11
        det_d33 = deseq2_ch.det_d33
        results = deseq2_ch.results
        session_info = deseq2_ch.session_info
        venn_counts = venn_ch.counts
        venn_plot = venn_ch.plot_png

 }

 output {
    }
    det_d11 {
        path { "DESEQ2" }
    }
    det_d33 {
        path { "DESEQ2" }
    }
    results {
        path { "DESEQ2" }
    }
    session_info {
        path { "DESEQ2" }
    }
    venn_counts {
        path { "VENN" }
    }
    venn_plot {
        path { "VENN" }
    }
 }
