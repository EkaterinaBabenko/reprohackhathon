process SAMTOOLS_SORT {
    tag "${sample}"
    container "biocontainers/samtools:v1.9-4-deb_cv1"

    input:
    tuple val(sample), val(condition), path(sam)

    output:
    tuple val(sample), val(condition), path("${sample}.bam"), path("${sample}.bam.bai"), emit: bam

    script:
    """
    samtools sort -@ ${task.cpus} -o ${sample}.bam ${sam}
    samtools index ${sample}.bam
    """
}