
process DESEQ2 {
    tag "toxo_2x2"
    label 'process_medium'

    container "${params.containers.deseq2}" // image locale, recette dans ../deseq2/Dockerfile (Projet 1) ; défini dans nextflow.config

    input:
    path quants   // dossiers <sample>/ contenant chacun quant.sf
    path samplesheet // data/samples.csv

    output:
    path "det_d11.csv",            emit: det_d11
    path "det_d33.csv",            emit: det_d33
    path "deseq2_results_*.csv",   emit: results
    path "sessionInfo.txt",        emit: session_info

    script:
    // Seuils de l'article de Hu et al. 2020 : p-value < 0.05 (NON ajustée) et |log2FC| >= 1.5
    def pvalue = params.deseq2_pvalue ?: 0.05
    def log2fc = params.deseq2_log2fc ?: 1.5
    """
    deseq2_toxo.R . ${samplesheet} ${pvalue} ${log2fc}
    """

    stub:
    """
    touch det_d11.csv det_d33.csv deseq2_results_d11.csv deseq2_results_d33.csv sessionInfo.txt
    """
}
