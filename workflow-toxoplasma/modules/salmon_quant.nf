// HYPOTHÈSES :
//   - lectures paired-end (confirmé : PRJNA483261 est en 2x lectures) -> -1/-2
//   - type de librairie : -l A (détection automatique de l'orientation / strandedness)
//   - --validateMappings : validation des alignements quasi (recommandé, plus robuste)

process SALMON_QUANT {
    tag "${sample}"
    label 'process_medium'

    container "${params.containers.salmon}"   // image Damona Salmon 1.2.0 (voir nextflow.config)

    input:
    tuple val(sample), val(condition), val(timepoint), path(reads) // <- TRIMMING
    path index                                                    // <- SALMON_INDEX

    output:
    tuple val(sample), val(condition), val(timepoint), path("${sample}"), emit: quant

    script:
    """
    # Paired-end : on passe les deux fichiers trimmés à Salmon
    salmon quant -i ${index} -l A \\
        -1 ${sample}_1.trimmed.fastq.gz -2 ${sample}_2.trimmed.fastq.gz \\
        -p ${task.cpus} -o ${sample} --validateMappings
    """
}
