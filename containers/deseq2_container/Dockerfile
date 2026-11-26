FROM r-base:3.4.1
WORKDIR opt/src
RUN echo 'install.packages("BiocManager")'>install.packages.R && echo 'BiocManager::install(version="3.5",ask=FALSE)'>>install.packages.R && echo 'BiocManager::install("DESeq2",ask=FALSE)'>>install.packages.R
RUN Rscript install.packages.R

