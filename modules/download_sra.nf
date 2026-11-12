process DOWNLOAD_SRA {
    tag "${sample}.id"
    label 'process_medium'

    container "biocontainers/fastqc:v0.11.9_cv8"

    input:
    tuple val(sample), val(condition), val(sra_id)

    output:
    tuple val(sample), val(condition), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    script:
    """
    fasterq-dump --split-files --threads ${task}.cpus ${sra_id}
    pigz *.fastq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sra-tools: \$(fasterq-dump --version 2>&1 | grep '^fasterq-dump' | cut -d' ' -f2)
    END_VERSIONS
    """
}
