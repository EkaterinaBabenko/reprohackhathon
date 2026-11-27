// Analyse d'expression différentielle des transcrits avec DESeq2 (script bin/deseq2_toxo.R),
// sur les quantifications Salmon. Adapté du DESEQ2 du Projet 1.
//
// Entrées : - liste des dossiers <sample>/ contenant chacun quant.sf  <- SALMON_QUANT
//           - data/samples.csv (sample, condition, timepoint, SRR)
// Sorties : - det_d11.csv / det_d33.csv  (DETs up/down par timepoint), emit: det_d11/det_d33 -> Venn Fig. 2B
//           - deseq2_results_*.csv (tables complètes), emit: results
//           - sessionInfo.txt (versions R/DESeq2 pour le rapport), emit: session_info
//
// Seuils de l'article de Hu et al. 2020 : p < 0.05 NON ajustée et |log2FC| >= 1.5
// (params.deseq2_pvalue / params.deseq2_log2fc dans nextflow.config).
// Design 2x2 (condition x timepoint) testé par timepoint : In vs WT à d11, puis à d33.

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
