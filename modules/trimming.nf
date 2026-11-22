
process TRIMMING {

    container "reprohack/cutadapt:1.11"

    tag "${sample}.id"

    label 'process_medium'

    input:
    tuple val(sample), val(condition), path(reads)

    output:
    tuple val(sample), val(condition), path("*.trimmed.fastq.gz"), emit: reads

    script:
    """
    cutadapt -q 20 -m 25 -a AGATCGGAAGAGC -o ${sample}.trimmed.fastq.gz ${reads}
    """
}
