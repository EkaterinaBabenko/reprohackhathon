library(ggplot2)
library(ggrepel)

res <- read.csv("deseq2_results.csv")
res <- res[!is.na(res$padj), ]
res$log2baseMean <- log2(res$baseMean)
res$Significatif  <- res$padj < 0.05
res$gene         <- res$Name
res$categorie    <- ifelse(res$Significatif, "Significatif", "Non-significatif")

# Lecture des gènes impliqués dans la traduction lus dans le fichier KEGG (cf biblio article)
lignes <- readLines("kegg_translation.txt")

# On extrait tous les identifiants (ex R = ARN ribosomique et T = ARN de transfert)
ids_traduction <- unique(unlist(regmatches(lignes, gregexpr("SAOUHSC_[A-Z]?[0-9]+", lignes))))

# Aminoacyl-tRNA synthetases : on garde les identifiants numériques seuls, ce qui exclut les ARNt (lettre T)
debut   <- grep("00970 Aminoacyl-tRNA", lignes)
fin     <- grep("03013 Nucleocytoplasmic", lignes)
bloc_aa <- lignes[debut:(fin - 1)]
ids_aaRS <- unique(unlist(regmatches(bloc_aa, gregexpr("SAOUHSC_[0-9]+", bloc_aa))))
res$aaRS <- res$gene %in% ids_aaRS

# Gènes à étiqueter recherché dans KEGG
liste_sao <- readLines("https://rest.kegg.jp/list/sao")
noms_cibles <- c("frr", "infA", "infB", "infC", "tsf", "pth")
motif <- paste0("\t(", paste(noms_cibles, collapse = "|"), ")[;,]")
lignes_cibles <- grep(motif, liste_sao, value = TRUE)

ids_cibles   <- sub("^sao:(SAOUHSC_[0-9]+).*", "\\1", lignes_cibles)
noms_trouves <- sub(paste0(".*\t(", paste(noms_cibles, collapse = "|"), ")[;,].*"),
                    "\\1", lignes_cibles)

if (!"pth" %in% noms_trouves) {
  lignes_pth <- grep("peptidyl-tRNA hydrolase", liste_sao, value = TRUE)
  lignes_cibles <- c(lignes_cibles, lignes_pth)
  ids_cibles    <- c(ids_cibles, sub("^sao:(SAOUHSC_[0-9]+).*", "\\1", lignes_pth))
  noms_trouves  <- c(noms_trouves, rep("pth", length(lignes_pth)))
}

etiquettes <- res[res$gene %in% ids_cibles, ]
etiquettes$nom <- noms_trouves[match(etiquettes$gene, ids_cibles)]

# Génes tracés (KEGG + ceux étiquetés)
traduction <- res[res$gene %in% c(ids_traduction, ids_cibles), ]
cat("Gènes tracés :", nrow(traduction), "(attendu : environ 153 + 6)\n")

# Graphique
couleurs <- c("Non-significatif" = "grey50", "Significatif" = "#E8352B")

p <- ggplot(traduction, aes(x = log2baseMean, y = log2FoldChange)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_point(aes(color = categorie), size = 2) +
  
  geom_point(data = traduction[traduction$aaRS, ],
             aes(shape = "AA-tRNA synthetases"),
             fill = NA, color = "black", size = 3.5, stroke = 1) +
  
  geom_text_repel(data = etiquettes, aes(label = nom),
                  xlim = c(19, NA), direction = "y", hjust = 0,
                  fontface = "italic", size = 5,
                  segment.color = "black", segment.size = 0.5,
                  min.segment.length = 0, box.padding = 0.5,
                  max.overlaps = Inf, seed = 1) +
  
  scale_color_manual(values = couleurs, name = NULL) +
  scale_shape_manual(values = 21, name = NULL,
                     labels = expression(italic("AA-tRNA synthetases"))) +
  scale_x_continuous(breaks = seq(0, 18, 2)) +
  scale_y_continuous(breaks = -5:4) +
  coord_cartesian(xlim = c(0, 23), ylim = c(-5.5, 4.5)) +
  guides(color = guide_legend(order = 1),
         shape = guide_legend(order = 2,
                              override.aes = list(size = 2.5, stroke = 0.8))) +
  labs(x = expression(Log[2]~base~Mean),
       y = expression(Log[2]~Fold~Change)) +
  theme_classic(base_size = 14) +
  theme(legend.position        = "inside",
        legend.position.inside = c(0.01, 0.01),
        legend.justification   = c(0, 0),
        legend.box             = "vertical",
        legend.box.just        = "left",
        legend.background      = element_blank(),
        legend.key.size        = unit(0.4, "cm"),
        legend.text            = element_text(size = 10),
        legend.margin          = margin(0, 0, 0, 0),
        legend.spacing.y       = unit(0, "cm"))

print(p)
ggsave("ma_plot.png", p, width = 8, height = 5, dpi = 300)




# Production du MA-plot réduit

# Graphique
couleurs <- c("Non-significatif" = "grey50", "Significatif" = "#E8352B")

p <- ggplot(traduction, aes(x = log2baseMean, y = log2FoldChange)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_point(aes(color = categorie), size = 2) +
  
  geom_point(data = traduction[traduction$aaRS, ],
             aes(shape = "AA-tRNA synthetases"),
             fill = NA, color = "black", size = 3.5, stroke = 1) +
  
  geom_text_repel(data = etiquettes, aes(label = nom),
                  xlim = c(19, NA), direction = "y", hjust = 0,
                  fontface = "italic", size = 5,
                  segment.color = "black", segment.size = 0.5,
                  min.segment.length = 0, box.padding = 0.5,
                  max.overlaps = Inf, seed = 1) +
  
  scale_color_manual(values = couleurs, name = NULL) +
  scale_shape_manual(values = 21, name = NULL,
                     labels = expression(italic("AA-tRNA synthetases"))) +
  scale_x_continuous(breaks = seq(0, 18, 2)) +
  scale_y_continuous(breaks = -5:4) +
  coord_cartesian(xlim = c(0, 23), ylim = c(-5.5, 4.5)) +
  guides(color = guide_legend(order = 1),
         shape = guide_legend(order = 2,
                              override.aes = list(size = 2.5, stroke = 0.8))) +
  labs(x = expression(Log[2]~base~Mean),
       y = expression(Log[2]~Fold~Change)) +
  theme_classic(base_size = 14) +
  theme(legend.position        = "inside",
        legend.position.inside = c(0.01, 0.01),
        legend.justification   = c(0, 0),
        legend.box             = "vertical",
        legend.box.just        = "left",
        legend.background      = element_blank(),
        legend.key.size        = unit(0.4, "cm"),
        legend.text            = element_text(size = 10),
        legend.margin          = margin(0, 0, 0, 0),
        legend.spacing.y       = unit(0, "cm"))

print(p)
ggsave("ma_plot.png", p, width = 8, height = 5, dpi = 300)





# Production du MA-plot du jeu de données RNA-seq complet

# On reproduit les triangles (valeurs sur y qui dépassent 4)
res$depasse  <- abs(res$log2FoldChange) > 4
res$lfc_trace <- pmax(pmin(res$log2FoldChange, 4), -4)

# significatifs : points noirs, sinon points rouges
res_tout <- res[order(res$Significatif), ]

p2 <- ggplot(res_tout, aes(x = baseMean, y = lfc_trace)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_point(aes(color = Significatif, shape = depasse), size = 0.8) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "#E8352B")) +
  scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 17)) +
  scale_x_log10(breaks = 10^c(0, 2, 4),
                labels = expression(10^0, 10^2, 10^4)) +
  scale_y_continuous(breaks = c(-4, -2, 0, 2, 4)) +
  labs(x = "Mean of normalized counts",
       y = expression(log[2]~fold~change)) +
  theme_gray(base_size = 12) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank())

print(p2)
ggsave("total_plot.png", p2, width = 8, height = 5, dpi = 300)