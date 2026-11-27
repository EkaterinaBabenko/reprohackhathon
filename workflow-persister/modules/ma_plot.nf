// MA-plot des résultats DESeq2 (bin/ma_plots.R, dans le PATH du process)
process MA_PLOT {
    tag "ma_plot"

    container "deseq2:latest" // même image que DESEQ2 (R)

    input:
    path results // deseq2_results.csv

    output:
    path "ma_plot.png", emit: plot

    script:
    def padj = params.deseq2_padj ?: 0.05
    """
    ma_plots.R ${results} ${padj}
    """

    stub:
    """
    touch ma_plot.png
    """
}
