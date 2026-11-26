// modules/deseq2.nf
// Analyse d'expression différentielle des transcrits (Projet 2) avec DESeq2.
// Adapté de workflow-persister/modules/deseq2.nf : l'entrée n'est plus le counts.txt
// de featureCounts mais l'ensemble des quant.sf de Salmon (comptages par transcrit),
// et les seuils sont ceux de l'article de Hu et al. 2020 (p < 0.05 non ajustée,
// |log2FC| >= 1.5), pour produire les DETs des deux timepoints (Fig. 2B, Venn).
//
// Entrées : - liste des quant.sf (un dossier <sample>/ par échantillon) <- SALMON_QUANT
//           - data/samples.csv (sample, condition, timepoint, SRR)
// Sorties : - det_d11.csv / det_d33.csv   : DETs up/down par timepoint (Venn Fig. 2B)
//           - deseq2_results_d11/d33.csv  : tables complètes
//           - sessionInfo.txt             : versions R/DESeq2 pour le rapport
//
// Expression : deseq2_toxo.R <dossier_quant> <samples.csv> [pvalue] [log2fc]
// L'image est construite à partir de deseq2/Dockerfile (R + DESeq2, recette du Projet 1) :
//   docker build -t deseq2:latest ../deseq2/

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
