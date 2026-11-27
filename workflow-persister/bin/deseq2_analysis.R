# Expression différentielle persisters vs contrôles avec DESeq2.
#
# Expression pour utiliser ce script R : deseq2_analysis.R <counts.txt> <samples.csv> [padj]
#   counts.txt  : sortie de featureCounts (colonnes Geneid, Name, Chr, Start, End, Strand, Length, puis une colonne par fichier BAM/SAM)
#   data/samples.csv : colonnes sample, condition, SRA_id
#   padj : seuil de p-value ajustée (défaut 0.05, qui est la valeur du papier)
#
# Sorties (dossier courant) :
#   deseq2_results.csv : résultats pour tous les gènes (+ colonne `significant`)
#   normalized_counts.csv : comptages normalisés (facteurs de taille DESeq2)
#   sessionInfo.txt : versions de R et des packages

suppressPackageStartupMessages(library(DESeq2))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage : deseq2_analysis.R <counts.txt> <samples.csv> [padj]")
}
counts_file <- args[1]
samples_file <- args[2]
padj_cutoff <- if (length(args) >= 3) as.numeric(args[3]) else 0.05
if (is.na(padj_cutoff)) stop("Le seuil padj doit être un nombre : ", args[3])

# Condition de référence : les contrôles (log2FC > 0 = plus exprimé chez les persisters)
ref_condition <- "control"

# ---- Lecture des comptages ---------------------------------------------------------
# featureCounts ajoute une ligne de commentaire "# Program:..." en tête de fichier.
raw <- read.delim(counts_file, comment.char = "#", check.names = FALSE,
                  stringsAsFactors = FALSE)

annot_cols <- c("Geneid", "Name", "Chr", "Start", "End", "Strand", "Length")
sample_cols <- setdiff(colnames(raw), annot_cols)

counts <- as.matrix(raw[, sample_cols, drop = FALSE])
rownames(counts) <- raw$Geneid
# Les colonnes portent le nom du fichier : "persister_1.bam" -> "persister_1"
colnames(counts) <- sub("\\.(bam|sam)$", "", basename(colnames(counts)))

# Nom du gène (colonne `Name`, option --extraAttributes de featureCounts) si présent
gene_names <- if ("Name" %in% colnames(raw)) raw$Name else rep(NA_character_, nrow(raw))

# ---- Plan d'expérience ---------------------------------------------------------------
samples <- read.csv(samples_file, stringsAsFactors = FALSE)
stopifnot(all(c("sample", "condition") %in% colnames(samples)))

missing <- setdiff(colnames(counts), samples$sample)
if (length(missing) > 0) {
  stop("Échantillons des comptages absents de ", samples_file, " : ",
       paste(missing, collapse = ", "))
}
samples <- samples[match(colnames(counts), samples$sample), ]
if (!ref_condition %in% samples$condition) {
  stop("Condition de référence '", ref_condition, "' absente de ", samples_file)
}
col_data <- data.frame(condition = factor(samples$condition),
                       row.names = samples$sample)
col_data$condition <- relevel(col_data$condition, ref = ref_condition)

message("Échantillons : ", paste(rownames(col_data), col_data$condition, sep = "=",
                                 collapse = ", "))
message("Gènes : ", nrow(counts), " | seuil padj : ", padj_cutoff)

# ---- DESeq2 ----------------------------------------------------------------------------
# Paramètres par défaut (test de Wald, filtrage indépendant, ajustement de
# Benjamini-Hochberg), comme dans le papier ; alpha = seuil de padj pour le filtrage.
dds <- DESeqDataSetFromMatrix(countData = counts, colData = col_data,
                              design = ~ condition)
dds <- DESeq(dds)

res <- results(dds, alpha = padj_cutoff)
res_df <- as.data.frame(res)
res_df$significant <- !is.na(res_df$padj) & res_df$padj < padj_cutoff

out <- data.frame(Geneid = rownames(res_df), Name = gene_names, res_df,
                  row.names = NULL, check.names = FALSE)
out <- out[order(out$padj, na.last = TRUE), ]
write.csv(out, "deseq2_results.csv", row.names = FALSE)

norm <- data.frame(Geneid = rownames(counts), Name = gene_names,
                   counts(dds, normalized = TRUE), row.names = NULL, check.names = FALSE)
write.csv(norm, "normalized_counts.csv", row.names = FALSE)

# ---- Résumé ----------------------------------------------------------------------------
n_sig <- sum(out$significant)
n_up <- sum(out$significant & out$log2FoldChange > 0, na.rm = TRUE)
n_down <- sum(out$significant & out$log2FoldChange < 0, na.rm = TRUE)
message(sprintf("Gènes différentiellement exprimés (padj < %g) : %d (%d sur-exprimés, %d sous-exprimés chez les persisters)",
                padj_cutoff, n_sig, n_up, n_down))
message("Papier : 1477 gènes (710 sur-exprimés, 767 sous-exprimés)")

writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
