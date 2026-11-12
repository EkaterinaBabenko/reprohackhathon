process DESEQ2 {

    tag "persister_vs_control"

    container "reprohack/deseq2:1.16.1"

    publishDir "${projectDir}/results/deseq2", mode: 'copy'

    input:
    path counts
    path samplesheet
    path analysis_script

    output:
    path "deseq2_results.tsv", emit: results
    path "deseq2_DEGs.tsv", emit: degs
    path "deseq2_dds.rds", emit: dds
    path "deseq2_results.rds", emit: results_rds
    path "deseq2_sessionInfo.txt", emit: versions

    script:
    """
    Rscript ${analysis_script} ${counts} ${samplesheet}
    """
}
