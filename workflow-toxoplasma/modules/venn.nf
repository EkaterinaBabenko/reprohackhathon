// Diagramme de Venn des DETs à d11 et d33 (Fig. 2B de Hu et al. 2020),
// via le script bin/venn_diagram.R (R base, aucun package externe).
// Le conteneur DESeq2 (R) est réutilisé.
//
// Entrées : - det_d11.csv  <- DESEQ2.det_d11
//           - det_d33.csv  <- DESEQ2.det_d33
// Sorties : - venn_counts.csv (effectifs par zone), emit: counts
//           - venn_diagram.png / venn_diagram.pdf (figure), emit: plot

process VENN {
    tag "venn_d11_vs_d33"
    label 'process_low'

    container "${params.containers.deseq2}"   // image R/DESeq2 (voir nextflow.config)

    input:
    path det_d11
    path det_d33

    output:
    path "venn_counts.csv",                 emit: counts
    path "venn_diagram.png",                emit: plot_png
    path "venn_diagram.pdf",                emit: plot_pdf

    script:
    """
    Rscript ${projectDir}/bin/venn_diagram.R ${det_d11} ${det_d33}
    """

    stub:
    """
    touch venn_counts.csv venn_diagram.png venn_diagram.pdf
    """
}
