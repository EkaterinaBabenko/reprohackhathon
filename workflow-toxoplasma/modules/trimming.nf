// Nettoyage des lectures avec Trimmomatic v0.39 (outil de l'article Hu et al. 2020,
// image staphb/trimmomatic:0.39).
//
// Entrée  : tuple (sample, condition, timepoint, *.fastq.gz)  <- DOWNLOAD_SRA
// Sortie  : tuple (sample, condition, timepoint, *.trimmed.fastq.gz), emit: reads -> SALMON_QUANT
//
// HYPOTHÈSES :
//   - lectures paired-end -> mode PE,
//     on garde uniquement les reads appariés (fichiers *.unpaired supprimés).
//   - adaptateurs : TruSeq (ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10), standard Illumina.
//   - qualité : SLIDINGWINDOW:4:20 + MINLEN:25.

process TRIMMING {
    tag "${sample}"
    label 'process_medium'

    container "${params.containers.trimmomatic}"   // image Damona Trimmomatic 0.39 (voir nextflow.config)

    input:
    tuple val(sample), val(condition), val(timepoint), path(reads)

    output:
    tuple val(sample), val(condition), val(timepoint), path("*.trimmed.fastq.gz"), emit: reads

    script:
    // Le jar Trimmomatic est localisé dans l'image (chemin standard biocontainers/Damona)
    def jar = '/Trimmomatic-0.39/trimmomatic-0.39.jar'
    // Basenames des entrées (ex. SRR7657878_1.fastq.gz -> SRR7657878_1), calculés en Groovy
    def B1 = reads[0].name.replace('.fastq.gz', '')
    def B2 = reads[1].name.replace('.fastq.gz', '')
    """
    java -jar ${jar} PE -threads ${task.cpus} \\
        ${reads[0]} ${reads[1]} \\
        ${B1}.trimmed.fastq.gz ${B1}.unpaired.fastq.gz \\
        ${B2}.trimmed.fastq.gz ${B2}.unpaired.fastq.gz \\
        ILLUMINACLIP:/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10 \\
        SLIDINGWINDOW:4:20 MINLEN:25

    # On ne conserve que les reads appariés (les unpaired sont des orphelins)
    rm -f *.unpaired.fastq.gz
    """
}
