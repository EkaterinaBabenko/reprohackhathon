// modules/download_sra.nf
// Téléchargement des lectures brutes SRA avec fasterq-dump (SRA Toolkit), puis gzip.

// Entrée  : tuple (sample, condition, timepoint, SRA_id)   <- lecture du samples.csv
// Sortie  : tuple (sample, condition, timepoint, *.fastq.gz), emit: reads -> TRIMMING

process DOWNLOAD_SRA {
    tag "${sample}"
    label 'process_medium'

    container "${params.containers.sratoolkit}"   // défini dans nextflow.config

    input:
    tuple val(sample), val(condition), val(timepoint), val(SRR)

    output:
    tuple val(sample), val(condition), val(timepoint), path("*.fastq.gz"), emit: reads

    script:
    """
    fasterq-dump --threads ${task.cpus} --progress ${SRR}
    gzip *.fastq
    """
}
