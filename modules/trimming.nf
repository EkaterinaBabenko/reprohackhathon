
process TRIMMING {

    container "biocontainers/cutadapt:v1.18-1-deb-py3_cv1"

    tag "${sample}.id"

    label 'process_medium'

    conda "bioconda::cutadapt=4.4"

    container "quay.io/biocontainers/cutadapt:4.4--py310h1425a21_0"

    input:
    tuple val(sample), val(condition), path(reads)

    output:
    tuple val(sample), val(condition), path("*.trim.fastq.gz"), emit: reads
    path "versions.yml", emit: versions

    script:
    cutadapt -q 20 -m 25 -a 'AGATCGGAAGAGC' -o ${sample}.trimmed.fastq.gz ${reads}
}
