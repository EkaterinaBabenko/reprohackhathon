// Données single-end
process TRIMMING {

    container "pipecraft/cutadapt:5.2-pc1.2.0"

    tag "${sample}"

    input:
    tuple val(sample), val(condition), path(reads)

    output:
    tuple val(sample), val(condition), path("*.trimmed.fastq.gz"), emit: reads

    script:
    """
    cutadapt -q 20 -m 25 -a AGATCGGAAGAGC -j ${task.cpus} -o ${sample}.trimmed.fastq.gz ${reads}
    """
}
