process DOWNLOAD_SRA {
    tag "${sample}.id"
    label 'process_medium'

    container "reprohack/sratoolkit:3.4.1"

    input:
    tuple val(sample), val(condition), val(SRA_id)

    output:
    tuple val(sample), val(condition), path("*.fastq.gz"), emit: reads

    script:
    """
    fasterq-dump --progress ${SRA_id}
    gzip *.fastq
    """
}
