#!/bin/bash
# Lance le workflow Toxoplasma (Projet 2).
# L'image Apptainer Salmon 1.2.0 est téléchargée à la volée (non versionnée dans git) :
# elle est placée dans containers/ (dossier ignoré par git, voir .gitignore).
set -euo pipefail

cd "$(dirname "$0")"

SALMON_IMAGE_URL="https://zenodo.org/records/22144681/files/salmon_1.2.0.img?download=1"
SALMON_IMAGE="containers/salmon_1.2.0.img"

if [ ! -f "$SALMON_IMAGE" ]; then
    echo "Téléchargement de l'image Salmon 1.2.0 depuis Zenodo..."
    mkdir -p containers
    wget -q "$SALMON_IMAGE_URL" -O "$SALMON_IMAGE"
fi

nextflow run main.nf -profile apptainer "$@"
