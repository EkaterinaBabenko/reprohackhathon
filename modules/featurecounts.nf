process FEATURECOUNTS {
    input:
    path bams
    path gff

    output:
    path 'counts.txt', emit: counts

    script:
    """
     featureCounts --extraAttributes Name -t gene -g ID -s 1 -F GTF -T ${task.cpus} -a ${gff} -o counts.txt ${bams}
    """
}