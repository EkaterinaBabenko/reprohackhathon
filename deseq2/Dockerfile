# Image pour l'étape d'expression différentielle (module DESEQ2).
#
# Versions du papier (Peyrusson et al., Nat. Commun. 2020, section Methods) :
#   R 3.4.1 + Bioconductor DESeq2 1.16 (Bioconductor 3.5).
# On utilise exactement ces versions :
#   - rocker/r-ver:3.4.1 fournit R 3.4.1 (base Debian stretch) ;
#   - DESeq2 et ses dépendances Bioconductor viennent du dépôt archivé Bioconductor 3.5
#     (DESeq2 1.16.1, correctif de la 1.16.0, dernière version de la branche 1.16) ;
#   - les dépendances CRAN viennent d'un instantané daté de CRAN (Posit Package Manager).
#   Les paramètres de DESeq2 restent ceux par défaut, comme dans le papier.
#
# Contournements nécessaires car l'infrastructure de 2017 a disparu :
#   - Debian stretch est archivé : les dépôts apt pointent vers archive.debian.org ;
#   - MRAN (dépôt CRAN daté par défaut de rocker/r-ver 3.x) est fermé : on le remplace
#     par packagemanager.posit.co (le premier instantané disponible date du 2017-10-10) ;
#   - biocLite.R (installeur de Bioconductor 3.5) n'est plus servi : on appelle
#     install.packages() directement sur les dépôts Bioconductor 3.5.
#
# Construction :  docker build -t deseq2:latest deseq2/

FROM rocker/r-ver:3.4.1

# Debian stretch : dépôts archivés (la validité des fichiers Release a expiré).
RUN rm -f /etc/apt/sources.list.d/* \
    && echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive

# procps : requis par Nextflow (commande `ps`) pour suivre les processus dans le conteneur
# libxml2 / libcurl / libssl : dépendances système de packages Bioconductor (XML, RCurl)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        procps libxml2-dev libcurl4-openssl-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Dépôts utilisés pour installer DESeq2 : CRAN daté + Bioconductor 3.5 (compatible R 3.4)
ENV CRAN_SNAPSHOT=https://packagemanager.posit.co/cran/2017-10-10 \
    BIOC_REPO=https://bioconductor.org/packages/3.5

RUN R -q -e ' \
      options(download.file.method = "libcurl", Ncpus = 4); \
      repos <- c(CRAN = Sys.getenv("CRAN_SNAPSHOT"), \
                 BioCsoft = paste0(Sys.getenv("BIOC_REPO"), "/bioc"), \
                 BioCann  = paste0(Sys.getenv("BIOC_REPO"), "/data/annotation"), \
                 BioCexp  = paste0(Sys.getenv("BIOC_REPO"), "/data/experiment")); \
      install.packages("DESeq2", repos = repos); \
      stopifnot(as.character(getRversion()) == "3.4.1", \
                startsWith(as.character(packageVersion("DESeq2")), "1.16")); \
      library(DESeq2)'

CMD ["R"]
