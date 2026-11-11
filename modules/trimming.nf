
process TRIMMING {

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
    def args = "-q ${params.cutadapt_quality} -m ${params.cutadapt_minlen}"
    def prefix = task.ext.prefix ?: "${sample.id}"

    if (sample.single_end) {
        """
        cutadapt \\
            --cores $task.cpus \\
            $args \\
            -o ${prefix}.trim.fastq.gz \\
            $reads

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cutadapt: \$(cutadapt --version)
        END_VERSIONS
        """
    } else {
        """
        cutadapt \\
            --cores $task.cpus \\
            $args \\
            -o ${prefix}_1.trim.fastq.gz \\
            -p ${prefix}_2.trim.fastq.gz \\
            ${reads[0]} ${reads[1]}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cutadapt: \$(cutadapt --version)
        END_VERSIONS
        """
    }
}
