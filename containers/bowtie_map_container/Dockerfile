FROM ubuntu:latest

# --- 1. Metadonnees de reproductibilite ------
LABEL org.opencontainers.image.title="bowtie" \
      org.opencontainers.image.version="0.12.7" \
      org.opencontainers.image.authors="Julien Notarangelo" \
      org.opencontainers.image.description="Bowtie 0.12.7 (compiled from the original SourceForge sources) + samtools (Debian package) for the bowtie map step" \
      org.opencontainers.image.source="https://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.7/"

ENV BOWTIE_VERSION="0.12.7" \
    BOWTIE_URL="https://downloads.sourceforge.net/project/bowtie-bio/bowtie/0.12.7/bowtie-0.12.7-src.zip"

# --- 2. Outils de compilation ------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        zlib1g-dev \
        samtools \
        ca-certificates \
        wget \
        unzip && \
    rm -rf /var/lib/apt/lists/*

#--- 3. Telecharger et compiler les sources -------

WORKDIR /opt/src

RUN wget -q "$BOWTIE_URL" -O bowtie-src.zip && \
    # Si BOWTIE_SHA256 est defini (voir plus haut), decommenter la ligne :
    # echo "$BOWTIE_SHA256  bowtie-src.zip" | sha256sum -c - && \
    unzip -q bowtie-src.zip && \
    rm bowtie-src.zip && \
    cd bowtie-0.12.7 && \
    # Les sources datent de 2010 : on force le dialecte C++98 (le compilateur
    # moderne par defaut (C++17) refuse l'ancien code). Compiler en parallele.
    make -j"$(nproc)" CXX="g++ -std=gnu++98" && \
    # Rendre les 3 binaires disponibles comme commandes standard.
    cp bowtie bowtie-build bowtie-inspect /usr/local/bin/ && \
    # Nettoyage dans le MEME RUN : le compilateur et les sources ne restent
    # pas dans l'image finale.
    cd / && \
    rm -rf /opt/src

CMD ["bash"]