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
    """
    java -jar ${jar} PE -threads ${task.cpus} \\
        ${reads[0]} ${reads[1]} \\
        ${sample}.trimmed.fastq.gz ${sample}.unpaired.fastq.gz \\
        ${sample}.trimmed.fastq.gz ${sample}.unpaired.fastq.gz \\
        ILLUMINACLIP:/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10 \\
        SLIDINGWINDOW:4:20 MINLEN:25

    # On ne conserve que les reads appariés (les unpaired sont des orphelins)
    rm -f *.unpaired.fastq.gz
    """
}
