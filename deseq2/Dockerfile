# Image pour l'étape d'expression différentielle (module DESEQ2).
#
# Le papier utilise R 3.4.1 + DESeq2 1.16 (Bioconductor 3.5). Ces versions ne sont plus
# installables de façon fiable (dépôts et dépendances système obsolètes) : on utilise des
# versions récentes, épinglées pour la reproductibilité (R 4.3.3 + Bioconductor 3.18 +
# DESeq2 1.42.0). Les paramètres de DESeq2 restent ceux par défaut, comme dans le papier.
#
# Construction :  docker build -t deseq2:latest deseq2/

FROM rocker/r-ver:4.3.3

# procps : requis par Nextflow (commande `ps`) pour suivre les processus dans le conteneur
# libxml2 / libcurl / libssl : dépendances système de packages Bioconductor (XML, RCurl)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        procps libxml2-dev libcurl4-openssl-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Bioconductor 3.18 (compatible R 4.3) puis DESeq2 en version épinglée
RUN R -q -e 'install.packages("BiocManager", repos = "https://cloud.r-project.org")' \
    && R -q -e 'BiocManager::install(version = "3.18", ask = FALSE, update = FALSE)' \
    && R -q -e 'BiocManager::install("DESeq2", ask = FALSE, update = FALSE)' \
    && R -q -e 'stopifnot(as.character(packageVersion("DESeq2")) == "1.42.0")'

CMD ["R"]
