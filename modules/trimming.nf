
process TRIMMING {

    container "pipecraft/cutadapt:5.2-pc1.2.0"

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
