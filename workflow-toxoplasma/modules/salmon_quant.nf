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
    # Paired-end : ${reads} = les 2 fichiers *.trimmed.fastq.gz produits par TRIMMING
    # (staged dans le work dir, ordre alphabétique : _1 avant _2)
    salmon quant -i ${index} -l A \\
        -1 ${reads[0]} -2 ${reads[1]} \\
        -p ${task.cpus} -o ${sample} --validateMappings
    """
}
