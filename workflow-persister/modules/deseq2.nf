// Analyse d'expression différentielle (persisters vs contrôles) avec DESeq2.
// Entrées : - counts.txt de featureCounts 
//           - data/samples.csv (sample, condition, SRA_id)
// Sorties : - deseq2_results.csv : table complète (baseMean, log2FoldChange, pvalue, padj...)
//           - normalized_counts.csv : comptages normalisés (utile pour les MA-plots / heatmap)
//           - sessionInfo.txt : versions de R et de DESeq2 pour la partie Matériel et Méthodes du rapport
//
// Expression pour utiliser le script R : deseq2_analysis.R <counts.txt> <samples.csv> [padj]
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
    // Nous prenons le même seuil de p-value ajustée que dans l'article : 0.05
    def padj = params.deseq2_padj ?: 0.05 // padj pour p-value ajustée, valeur par défaut de 0.05 comme dans l'article
    """
    deseq2_analysis.R ${counts} ${samplesheet} ${padj}
    """

    stub:
    """
    touch deseq2_results.csv normalized_counts.csv sessionInfo.txt
    """
}
