#!/usr/bin/env Rscript
# MA-plot à partir de deseq2_results.csv
# Usage : ma_plots.R <deseq2_results.csv> [padj]
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Usage : ma_plots.R <deseq2_results.csv> [padj]")
padj_cutoff <- if (length(args) >= 2) as.numeric(args[2]) else 0.05

res <- read.csv(args[1], check.names = FALSE)
res <- res[!is.na(res$baseMean) & res$baseMean > 0 & !is.na(res$log2FoldChange), ]
sig <- !is.na(res$padj) & res$padj < padj_cutoff

png("ma_plot.png", width = 1000, height = 800, res = 150)
plot(res$baseMean, res$log2FoldChange, log = "x", pch = 20, cex = 0.5,
     col = ifelse(sig, "red", "grey60"),
     xlab = "Moyenne des comptages normalisés", ylab = "log2 fold change (persisters / contrôles)",
     main = sprintf("MA-plot (padj < %g)", padj_cutoff))
abline(h = 0, lty = 2)
legend("topright", legend = c("significatif", "non significatif"),
       col = c("red", "grey60"), pch = 20, bty = "n")
invisible(dev.off())
