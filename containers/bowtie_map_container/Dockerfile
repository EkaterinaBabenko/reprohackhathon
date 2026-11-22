FROM ubuntu:22.04

# --- 1. Metadonnees de reproductibilite (visibles via `docker inspect`) ------
LABEL org.opencontainers.image.title="bowtie" \
      org.opencontainers.image.version="0.12.7" \
      org.opencontainers.image.authors="Julien Notarangelo" \
      org.opencontainers.image.description="Bowtie 0.12.7 (official prebuilt linux-x86_64 binaries) + samtools (Ubuntu package) for the bowtie map step" \
      org.opencontainers.image.source="https://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.7/"

# Version figee + URL figee + empreinte SHA-256 OFFICIELLE publiee par
# SourceForge : si l'archive change, le build echoue. C'est ce qui rend la
# reconstruction fidele meme si le site evolue.
ENV BOWTIE_VERSION="0.12.7" \
    BOWTIE_URL="https://downloads.sourceforge.net/project/bowtie-bio/bowtie/0.12.7/bowtie-0.12.7-linux-x86_64.zip" \
    BOWTIE_SHA256="a6e802da218e9c07ca729f4ee5871380adc40a82746d741418b97bb24bfee4c1"

# --- 2. Dependances, en une seule couche --------------------------------------
# libstdc++6 + zlib1g : bibliotheques de runtime des binaires precompiles.
# samtools : tri/indexation du BAM dans la meme etape.
# wget/unzip/ca-certificates : telechargement de l'archive.
# On nettoie le cache apt dans le MEME RUN, sinon les fichiers supprimes
# restent ancre's dans la couche precedente.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        unzip \
        libstdc++6 \
        zlib1g \
        samtools && \
    rm -rf /var/lib/apt/lists/*

# --- 3. Recuperer et installer les binaires precompiles -----------------------
# /opt/src = zone de travail ; elle sera supprimee a la fin de ce RUN.
WORKDIR /opt/src

RUN wget -q "$BOWTIE_URL" -O bowtie-bin.zip && \
    # Verifie l'integrite de l'archive (ligne qui echoue si le contenu
    # ne correspond plus a l'empreinte figee).
    echo "$BOWTIE_SHA256  bowtie-bin.zip" | sha256sum -c - && \
    unzip -q bowtie-bin.zip && \
    rm bowtie-bin.zip && \
    # Localiser les binaires de facon robuste, quelle que soit la structure
    # de l'archive (dossier bowtie-0.12.7/ ou extraction a plat).
    BIN_DIR="$(dirname "$(find . -type f -name bowtie-build -print -quit)")" && \
    cp "$BIN_DIR/bowtie" "$BIN_DIR/bowtie-build" "$BIN_DIR/bowtie-inspect" /usr/local/bin/ && \
    cd / && \
    rm -rf /opt/src

# --- 4. Auto-test --------------------------------------------------------------
RUN bowtie --version && samtools --version

# --- 5. Comportement par defaut ------------------------------------------------
CMD ["bash"]