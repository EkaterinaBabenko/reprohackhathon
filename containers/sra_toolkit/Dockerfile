# Image pour le téléchargement SRA (download_sra) : SRA Toolkit + wget + pigz.
# pigz = compression gzip parallélisée (remplace gzip quand on part de fasterq-dump).
#
# Construction :  docker build -t reprohack/sratoolkit-pigz:3.4.1 containers/sra_toolkit/
# Utilisation dans nextflow.config :  params.containers.sratoolkit = 'reprohack/sratoolkit-pigz:3.4.1'

FROM ubuntu:24.04

WORKDIR /opt/src

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        pigz \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget --output-document sratoolkit.tar.gz \
        'https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.4.1/sratoolkit.3.4.1-ubuntu64.tar.gz' \
    && tar -xzf sratoolkit.tar.gz \
    && rm sratoolkit.tar.gz

ENV PATH=$PATH:/opt/src/sratoolkit.3.4.1-ubuntu64/bin

CMD ["bash"]
