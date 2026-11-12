process FEATURECOUNTS {

    container "biocontainers/subread:v1.6.3dfsg-1-deb_cv1"

    input:
    path bams
    path gff

    output:
    path 'counts.txt', emit: counts

    script:
    """
     featureCounts --extraAttributes Name -t gene -g ID -s 1 -F GFF -T ${task.cpus} -a ${gff} -o counts.txt ${bams}
    """
}