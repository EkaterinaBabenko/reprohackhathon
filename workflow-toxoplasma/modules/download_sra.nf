// modules/download_sra.nf
// Téléchargement des lectures brutes depuis le CDN ENA (EBI), directement en FASTQ.gz
// (paired-end : 2 fichiers par run), sans passer par fasterq-dump.
// Pattern d'URL ENA : vol1/fastq/<6 premiers car. du SRR>/<dernier chiffre, 3 digits>/<SRR>/<SRR>_N.fastq.gz
// ex. SRR7657876 -> https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR765/006/SRR7657876/SRR7657876_1.fastq.gz

// Entrée  : tuple (sample, condition, timepoint, SRA_id, fastq_1, fastq_2)  <- samples.csv (URLs ENA)
// Sortie  : tuple (sample, condition, timepoint, *.fastq.gz), emit: reads -> TRIMMING

process DOWNLOAD_SRA {
    tag "${sample}"
    label 'process_medium'

    container "${params.containers.sratoolkit}"   // défini dans nextflow.config

    input:
    tuple val(sample), val(condition), val(timepoint), val(SRR), val(fastq_1), val(fastq_2)

    output:
    tuple val(sample), val(condition), val(timepoint), path("*.fastq.gz"), emit: reads

    script:
    """
    # Paired-end : 2 fichiers par run, URLs fournies dans le samples.csv, déjà en .gz
    wget -q -O ${SRR}_1.fastq.gz ${fastq_1}
    wget -q -O ${SRR}_2.fastq.gz ${fastq_2}
    """
}
