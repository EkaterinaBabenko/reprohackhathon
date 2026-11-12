process DOWNLOAD_SRA {
    tag "${sample}.id"
    label 'process_medium'

    container "staphb/sratoolkit"

    input:
    tuple val(sample), val(condition), val(sra_id)

    output:
    tuple val(sample), val(condition), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    script:
    """
    fasterq-dump --threads 1 --progress ${sra_id}
    gzip *.fastq
    """
}
