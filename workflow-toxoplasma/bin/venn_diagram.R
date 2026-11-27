# Diagramme de Venn des DETs (Fig. 2B de Hu et al. 2020) : DETs à d11 vs d33.
#
# Usage : venn_diagram.R <det_d11.csv> <det_d33.csv>
#   det_*.csv : sorties du module DESEQ2 (colonnes transcript, log2FoldChange, pvalue, direction)
#
# Sorties (dossier courant) :
#   venn_counts.csv   : effectifs (d11 seul, d33 seul, intersection), up/down dans chaque zone
#   venn_diagram.png / venn_diagram.pdf : diagramme de Venn à 2 cercles (R base, sans package)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage : venn_diagram.R <det_d11.csv> <det_d33.csv>")
}
det_d11 <- read.csv(args[1], stringsAsFactors = FALSE)
det_d33 <- read.csv(args[2], stringsAsFactors = FALSE)

t11 <- unique(det_d11$transcript)
t33 <- unique(det_d33$transcript)

only11  <- setdiff(t11, t33)
only33  <- setdiff(t33, t11)
both    <- intersect(t11, t33)

# direction (up/down) dans l'intersection
both_up   <- sum(det_d11$transcript %in% both & det_d11$direction == "up")
both_down <- sum(det_d11$transcript %in% both & det_d11$direction == "down")

counts <- data.frame(
  zone        = c("d11_only", "d33_only", "both", "total_d11", "total_d33"),
  n_transcripts = c(length(only11), length(only33), length(both), length(t11), length(t33)),
  stringsAsFactors = FALSE
)
write.csv(counts, "venn_counts.csv", row.names = FALSE)

message(sprintf("DETs d11 : %d | d33 : %d | communs : %d (up=%d, down=%d) | d11 seul : %d | d33 seul : %d",
                length(t11), length(t33), length(both), both_up, both_down,
                length(only11), length(only33)))

# ---- Diagramme de Venn à 2 cercles (graphics de base : symbols() trace des cercles) ----
draw_venn <- function(file) {
  if (grepl("\\.pdf$", file)) pdf(file, width = 7, height = 6) else png(file, width = 900, height = 750)
  par(mar = c(1, 1, 3, 1))
  plot(0, 0, type = "n", xlim = c(-2.2, 2.2), ylim = c(-1.6, 1.6), axes = FALSE,
       xlab = "", ylab = "", main = "DETs : d11 (acute) vs d33 (chronique) -- Fig. 2B")
  symbols(-0.7, 0, circles = 1, add = TRUE, inches = FALSE, fg = "steelblue", lwd = 2)
  symbols( 0.7, 0, circles = 1, add = TRUE, inches = FALSE, fg = "darkorange", lwd = 2)
  text(-1.15, 1.25, "d11", col = "steelblue", font = 2, cex = 1.2)
  text( 1.15, 1.25, "d33", col = "darkorange", font = 2, cex = 1.2)
  text(-1.15, 0, length(only11), font = 2, cex = 1.4)
  text( 1.15, 0, length(only33), font = 2, cex = 1.4)
  text( 0,    0, sprintf("%d\n(up %d / down %d)", length(both), both_up, both_down), font = 2, cex = 1.1)
  dev.off()
}
draw_venn("venn_diagram.png")
draw_venn("venn_diagram.pdf")
