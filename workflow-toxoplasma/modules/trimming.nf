// modules/trimming.nf
// Nettoyage des lectures avec Trimmomatic v0.39 (outil nommé dans l'article de Hu et al. 2020,
// conteneur fourni sur Damona), en remplacement du cutadapt utilisé dans le Projet 1.
//
// Entrée  : tuple (sample, condition, timepoint, *.fastq.gz)   <- sortie de DOWNLOAD_SRA
// Sortie  : tuple (sample, condition, timepoint, reads trimmés), emit: reads -> SALMON_QUANT
//
// HYPOTHÈSES (le papier ne les précise pas, à justifier dans le rapport) :
//   - lectures paired-end (confirmé : PRJNA483261 est en 2x lectures) -> mode PE,
//     on garde uniquement les reads appariés (fichiers *.unpaired supprimés).
//   - adaptateurs : TruSeq (ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10), standard Illumina.
//   - qualité : SLIDINGWINDOW:4:20 (seuil 20, même hypothèse que le Projet 1) + MINLEN:25.

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
    def jar = '/usr/local/share/trimmomatic/trimmomatic.jar'
    """
    # Paired-end : fasterq-dump produit ${sample}_1.fastq.gz et ${sample}_2.fastq.gz
    java -jar ${jar} PE -threads ${task.cpus} \\
        ${sample}_1.fastq.gz ${sample}_2.fastq.gz \\
        ${sample}_1.trimmed.fastq.gz ${sample}_1.unpaired.fastq.gz \\
        ${sample}_2.trimmed.fastq.gz ${sample}_2.unpaired.fastq.gz \\
        ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:25

    # On ne conserve que les reads appariés (les unpaired sont des orphelins)
    rm -f *.unpaired.fastq.gz
    """
}
