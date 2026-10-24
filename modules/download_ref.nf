process DOWNLOAD_REF {
    label 'process_low'

    output:
    path "genome.fna", emit: fasta
    path "versions.yml", emit: versions

    script:
    """
    # Téléchargement du génome de référence S. aureus (exemple via NCBI/wget ou curl selon dispo)
    # Remplacer par l'URL ou l'outil adapté au projet
    curl -o genome.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/465/GCF_000013465.1_ASM1346v1_genomic.fna.gz"
    gunzip genome.fna.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        curl: \$(curl --version | head -n 1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
