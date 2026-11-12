#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(DESeq2))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
    stop("Usage: Rscript deseq2_analysis.R counts.txt samples.csv")
}

# Lire les comptages bruts de featureCounts.
counts_table <- read.delim(
    args[1],
    comment.char = "#",
    check.names = FALSE,
    stringsAsFactors = FALSE
)

# Lire les noms des échantillons et leurs conditions.
samples <- read.csv(args[2], stringsAsFactors = FALSE)

if (!all(c("sample", "condition") %in% names(samples))) {
    stop("Le CSV doit contenir les colonnes sample et condition.")
}
if (anyNA(samples$sample) || anyDuplicated(samples$sample)) {
    stop("Les noms d'échantillons doivent être renseignés et uniques.")
}
if (anyNA(samples$condition) ||
    !setequal(samples$condition, c("control", "persister"))) {
    stop("Les conditions attendues sont control et persister.")
}
if (!"Geneid" %in% names(counts_table)) {
    stop("La colonne Geneid est absente du fichier featureCounts.")
}
if (anyNA(counts_table$Geneid) ||
    anyDuplicated(counts_table$Geneid)) {
    stop("Les identifiants de gènes doivent être renseignés et uniques.")
}

# Les BAM du pipeline sont nommés <sample>.bam.
# Retrouver leurs colonnes, même si featureCounts inclut un chemin.
column_samples <- sub("\\.bam$", "", basename(names(counts_table)))

positions <- vapply(samples$sample, function(sample_name) {
    hits <- which(column_samples == sample_name)
    if (length(hits) != 1) {
        stop(paste("Colonne BAM absente ou ambiguë pour", sample_name))
    }
    hits
}, integer(1))

# Réordonner les comptages dans l'ordre du tableau des conditions.
count_matrix <- as.matrix(counts_table[, positions, drop = FALSE])

if (!is.numeric(count_matrix) ||
    anyNA(count_matrix) ||
    any(!is.finite(count_matrix)) ||
    any(count_matrix < 0) ||
    any(count_matrix != floor(count_matrix))) {
    stop("Les comptages doivent être des entiers positifs ou nuls.")
}

rownames(count_matrix) <- counts_table$Geneid
colnames(count_matrix) <- samples$sample

coldata <- data.frame(
    condition = factor(
        samples$condition,
        levels = c("control", "persister")
    ),
    row.names = samples$sample
)

# Normalisation, estimation des dispersions et test de Wald.
dds <- DESeqDataSetFromMatrix(
    countData = count_matrix,
    colData = coldata,
    design = ~ condition
)

dds <- DESeq(dds)

# Positif = plus exprimé chez les persisters.
res <- results(
    dds,
    contrast = c("condition", "persister", "control"),
    alpha = 0.05,
    pAdjustMethod = "BH",
    independentFiltering = TRUE
)

results_table <- data.frame(
    GeneID = rownames(res),
    as.data.frame(res),
    row.names = NULL
)

results_table$DEG <- (
    !is.na(results_table$padj) & results_table$padj < 0.05
)

results_table <- results_table[
    order(results_table$padj, na.last = TRUE),
]

write.table(
    results_table,
    "deseq2_results.tsv",
    sep = "\t", quote = FALSE, row.names = FALSE
)

write.table(
    results_table[results_table$DEG, ],
    "deseq2_DEGs.tsv",
    sep = "\t", quote = FALSE, row.names = FALSE
)

# Conserver les objets et versions pour la reproductibilité.
saveRDS(dds, "deseq2_dds.rds")
saveRDS(res, "deseq2_results.rds")
writeLines(capture.output(sessionInfo()), "deseq2_sessionInfo.txt")

message("Nombre de gènes différentiellement exprimés : ",
        sum(results_table$DEG))
