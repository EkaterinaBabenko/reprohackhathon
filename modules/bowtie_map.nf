// Mapping des reads trimmés sur le génome avec Bowtie 1 (0.12.7, paramètres par défaut), puis tri et indexation du BAM avec samtools
// Entrées : - tuple (sample, fastq.gz trimmé)             <- sortie de TRIMMING
//           - tuple (nom de l'index, fichiers *.ebwt)     <- sortie de BOWTIE_INDEX
// Sorties : - tuple (sample, BAM trié, index .bai)        -> FEATURECOUNTS
//           - log de bowtie (% de reads alignés)          -> utile pour le rapport

process BOWTIE_MAP {
    tag "${sample}"                      // un process par échantillon : on voit lequel tourne

    input:
    tuple val(sample), path(reads)
    tuple val(index_name), path(index_files)

    output:
    tuple val(sample), path("${sample}.bam"), path("${sample}.bam.bai"), emit: bam //emit pour accéder aux sorties par leur nom
    path "${sample}.bowtie.log",                                        emit: log

    script:
    // Bowtie 1 : reads single-end (65 nt dans le papier), pas d'option -q ni --best :
    // "default parameters" dans le papier. -S : sortie SAM, envoyée directement à samtools.
    // La substitution de processus <(...) demande bash : déjà imposé par process.shell
    // dans nextflow.config. La sortie d'erreur de bowtie (statistiques) va dans le .log.
    """
    bowtie -p ${task.cpus} -S ${index_name} <(gunzip -c ${reads}) 2> ${sample}.bowtie.log \\
        | samtools sort -@ ${task.cpus} -o ${sample}.bam -

    samtools index ${sample}.bam
    """

    stub:
    """
    touch ${sample}.bam ${sample}.bam.bai ${sample}.bowtie.log
    """
}