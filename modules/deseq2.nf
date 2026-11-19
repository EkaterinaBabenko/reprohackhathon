// Analyse d'expression différentielle (persisters vs contrôles) avec DESeq2.
// Entrées : - counts.txt de featureCounts 
//           - data/samples.csv (sample, condition, SRA_id)
// Sorties : - deseq2_results.csv : table complète (baseMean, log2FoldChange, pvalue, padj...)
//           - normalized_counts.csv : comptages normalisés (utile pour les MA-plots / heatmap)
//           - sessionInfo.txt : versions R / DESeq2 (traçabilité pour le rapport)
//
// Le script bin/deseq2_analysis.R est automatiquement dans le PATH du process
// (Nextflow ajoute le dossier bin/ du projet).
// L'image doit être construite à partir de deseq2/Dockerfile (R + DESeq2) :
//   docker build -t deseq2:latest deseq2/

process DESEQ2 {
    tag "persisters_vs_controls"
    label 'process_medium'

    container "deseq2:latest" // image locale, recette dans deseq2/Dockerfile

    input:
    path counts // counts.txt (featureCounts)
    path samplesheet // data/samples.csv

    output:
    path "deseq2_results.csv",     emit: results
    path "normalized_counts.csv",  emit: normalized
    path "sessionInfo.txt",        emit: session_info

    script:
    // Seuil de p-value ajustée : le papier utilise FDR < 0.05 (params.deseq2_padj si défini)
    def padj = params.deseq2_padj ?: 0.05
    """
    deseq2_analysis.R ${counts} ${samplesheet} ${padj}
    """

    stub:
    """
    touch deseq2_results.csv normalized_counts.csv sessionInfo.txt
    """
}
