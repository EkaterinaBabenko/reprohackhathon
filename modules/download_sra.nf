process DOWNLOAD_SRA {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::sra-tools=3.0.0 bioconda::pigz=2.6"
    container "quay.io/biocontainers/sra-tools:3.0.0--h87f3376_0"

    input:
    tuple val(sample), val(condition), val(sra_id)

    output:
    tuple val(sample), val(condition), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    script:
    """
    fasterq-dump --split-files --threads $task.cpus $sra_id
    pigz *.fastq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sra-tools: \$(fasterq-dump --version 2>&1 | grep '^fasterq-dump' | cut -d' ' -f2)
    END_VERSIONS
    """
}
