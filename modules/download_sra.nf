process DOWNLOAD_SRA {
    tag "${sample}.id"
    label 'process_medium'

    container "staphb/sratoolkit"

    input:
    tuple val(sample), val(condition), val(SRA_id)

    output:
    tuple val(sample), val(condition), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    script:
    """
    fasterq-dump --threads 2 --progress ${SRA_id}
    gzip *.fastq
    """
}
