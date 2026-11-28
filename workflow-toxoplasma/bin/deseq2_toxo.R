# Analyse d'expression différentielle des transcrits (Projet 2, Toxoplasma gondii,
# Hu et al. 2020) avec DESeq2, à partir des quantifications Salmon (quant.sf).
# Adapté de workflow-persister/bin/deseq2_analysis.R.
#
# Usage : deseq2_toxo.R <dossier_quant> <samples.csv> [pvalue] [log2fc]
#   dossier_quant : dossier contenant les sous-dossiers <sample>/quant.sf (sortie SALMON_QUANT)
#   samples.csv   : colonnes sample, condition, timepoint, SRR
#   pvalue        : seuil de p-value AJUSTÉE (padj, BH ; défaut 0.05, comme dans l'article)
#   log2fc        : seuil sur |log2 fold-change| (défaut 1.5, comme dans l'article)
#
# Sorties (dossier courant) :
#   deseq2_results_d11.csv / deseq2_results_d33.csv : résultats complets par timepoint
#   det_d11.csv / det_d33.csv : transcrits différentiellement exprimés (DETs), avec
#                               direction (up/down) -> pour le diagramme de Venn (Fig. 2B)
#   sessionInfo.txt : versions de R et de DESeq2 (Material & Methods du rapport)

suppressPackageStartupMessages(library(DESeq2))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage : deseq2_toxo.R <dossier_quant> <samples.csv> [pvalue] [log2fc]")
}
quant_dir   <- args[1]
samples_file <- args[2]
p_cutoff    <- if (length(args) >= 3) as.numeric(args[3]) else 0.05   # padj (p-value ajustée BH, Résultats de l'article)
lfc_cutoff  <- if (length(args) >= 4) as.numeric(args[4]) else 1.5    # |log2FC| >= 1.5 (papier)

# ---- Lecture des quantifications Salmon -------------------------------------------
# Chaque quant.sf : colonnes Name, Length, EffectiveLength, TPM, NumReads
samples <- read.csv(samples_file, stringsAsFactors = FALSE)
stopifnot(all(c("sample", "condition", "timepoint") %in% colnames(samples)))

quant_files <- file.path(quant_dir, samples$sample, "quant.sf")
missing <- quant_files[!file.exists(quant_files)]
if (length(missing) > 0) {
  stop("quant.sf manquants : ", paste(missing, collapse = ", "))
}

qlist <- lapply(quant_files, function(f) {
  q <- read.delim(f, stringsAsFactors = FALSE)
  setNames(q$NumReads, q$Name)
})
counts <- do.call(cbind, qlist)
colnames(counts) <- samples$sample
# Garder les transcrits présents dans tous les échantillons (intersection des noms)
counts <- counts[rowSums(is.na(counts)) == 0, , drop = FALSE]
counts <- round(counts)   # DESeq2 attend des comptages entiers

# ---- Plan d'expérience 2x2 : condition (infected/control) x timepoint (d11/d33) -----
col_data <- data.frame(
  condition  = factor(samples$condition),
  timepoint  = factor(samples$timepoint),
  row.names  = samples$sample
)
# Référence : control (log2FC > 0 = plus exprimé chez l'infecté)
col_data$condition <- relevel(col_data$condition, ref = "control")

message("Échantillons : ", paste(rownames(col_data), col_data$condition,
                                 col_data$timepoint, sep = "=", collapse = ", "))
message("Transcrits : ", nrow(counts), " | seuils : padj < ", p_cutoff, ", |log2FC| >= ", lfc_cutoff)

# Choix documenté (consigne : "test each timepoint separately or fit an interaction
# model") : on teste chaque timepoint séparément (In vs WT à d11, puis In vs WT à d33)
# en ajustant le modèle sur le sous-ensemble d'échantillons de ce timepoint.
run_contrast <- function(tp) {
  keep <- col_data$timepoint == tp
  dds_tp <- DESeqDataSetFromMatrix(countData = counts[, keep, drop = FALSE],
                                   colData = droplevels(col_data[keep, , drop = FALSE]),
                                   design = ~ condition)
  dds_tp <- DESeq(dds_tp)
  res <- results(dds_tp, contrast = c("condition", "infected", "control"), alpha = 0.05)
  res_df <- as.data.frame(res)
  res_df$transcript <- rownames(res_df)
  res_df <- res_df[order(res_df$pvalue, na.last = TRUE), ]
  write.csv(res_df, sprintf("deseq2_results_%s.csv", tp), row.names = FALSE)

det <- res_df[!is.na(res_df$padj) & res_df$padj < p_cutoff &
              !is.na(res_df$log2FoldChange) & abs(res_df$log2FoldChange) >= lfc_cutoff, ]
  det$direction <- ifelse(det$log2FoldChange > 0, "up", "down")
  write.csv(det[, c("transcript", "log2FoldChange", "pvalue", "padj", "direction")],
            sprintf("det_%s.csv", tp), row.names = FALSE)
  message(sprintf("[%s] DETs (padj < %g, |log2FC| >= %g) : %d (%d up, %d down)",
                  tp, p_cutoff, lfc_cutoff, nrow(det),
                  sum(det$direction == "up"), sum(det$direction == "down")))
  det
}

det_d11 <- run_contrast("d11")
det_d33 <- run_contrast("d33")

message("Fig. 2B (papier) : Venn des DETs d11 vs d33 -- à reproduire à partir de det_d11.csv et det_d33.csv")

writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
