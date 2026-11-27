// Production du MA-plot (figure c de l'article) à partir de la sortie de DESeq2.
// Entrées : deseq2_results.csv (baseMean, log2FoldChange, padj...)
// Sorties : ma_plot.png
//
// Appel du script R : ma_plot.R

process MA_PLOT {
    tag "ma_plot"
    label 'process_low'
    container "deseq2:latest"

    input:
    path results

    output:
    path "ma_plot.png", emit: plot

    script:
    def padj = params.deseq2_padj ?: 0.05
    """
    ma_plot.R ${results} ${padj}
    """

    stub:
    """
    touch ma_plot.png
    """
}