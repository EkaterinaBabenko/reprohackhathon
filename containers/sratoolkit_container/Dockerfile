FROM ubuntu:24.04
WORKDIR opt/src
RUN apt-get update
RUN apt-get install -y wget
RUN wget --output-document sratoolkit.tar.gz 'https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.4.1/sratoolkit.3.4.1-ubuntu64.tar.gz' 
RUN tar -xzf sratoolkit.tar.gz
RUN rm sratoolkit.tar.gz
ENV PATH=$PATH:/opt/src/sratoolkit.3.4.1-ubuntu64/bin
