process SAMTOOLS_SORT {
    tag "${sample}"
    container "biocontainers/samtools:v1.9-4-deb_cv1"

    input:
    tuple val(sample), val(condition), path(sam)

    output:
    tuple val(sample), val(condition), path("${sample}.bam"), path("${sample}.bam.bai"), emit: bam

    script:
    """
    samtools sort -@ 2 -o ${sample}.bam ${sam}
    samtools index ${sample}.bam
    """
}