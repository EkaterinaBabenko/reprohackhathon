FROM bioconductor/release_core2:R3.4.1_Bioc3.5@sha256:943b212fe4125b05f70d80c6f903c581feddc9cd84221818107fd56f0c77ae62

USER root

RUN Rscript -e ' \
    urls <- c( \
      "https://cran.r-project.org/src/contrib/Archive/locfit/locfit_1.5-9.1.tar.gz", \
      "https://cran.r-project.org/src/contrib/Archive/RcppArmadillo/RcppArmadillo_0.7.900.2.0.tar.gz", \
      "https://bioconductor.org/packages/3.5/bioc/src/contrib/genefilter_1.58.1.tar.gz", \
      "https://bioconductor.org/packages/3.5/bioc/src/contrib/geneplotter_1.54.0.tar.gz", \
      "https://bioconductor.org/packages/3.5/bioc/src/contrib/DESeq2_1.16.1.tar.gz" \
    ); \
    packages <- c("locfit", "RcppArmadillo", "genefilter", "geneplotter", "DESeq2"); \
    for (i in seq_along(urls)) { \
      install.packages(urls[i], repos = NULL, type = "source"); \
      if (!requireNamespace(packages[i], quietly = TRUE)) { \
        stop(paste("Installation impossible :", packages[i])); \
      } \
    }; \
    stopifnot(as.character(getRversion()) == "3.4.1"); \
    stopifnot(as.character(packageVersion("DESeq2")) == "1.16.1"); \
    library(DESeq2)'

WORKDIR /data

CMD ["Rscript"]
