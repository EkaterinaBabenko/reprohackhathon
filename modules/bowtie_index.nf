// modules/bowtie_index.nf
// Construction de l'index Bowtie (v0.12.7, Bowtie 1) à partir du génome de référence.
// Entrée  : fasta du génome complet (S. aureus NCTC 8325, CP000253.1)
// Sortie  : tuple (nom de l'index, fichiers *.ebwt), à passer au module bowtie_map

process BOWTIE_INDEX {
    tag "${genome_fasta.simpleName}" // Affiche ce qui se passe dans le terminal quand c'est lancé
    //container params.bowtie_container          // défini dans nextflow.config
    //publishDir "${params.outdir}/bowtie_index", mode: 'copy'  //déjà dans nextflow.config

    container "biocontainers/bowtie:v1.2.2dfsg-4-deb_cv1"

    input:
    path genome_fasta

    output:
    tuple val(index_name), path("${index_name}*.ebwt"), emit: index

    script:
    index_name = genome_fasta.simpleName       // ex. "reference"
    """
    bowtie-build ${genome_fasta} ${index_name}
    """

    stub:
    index_name = genome_fasta.simpleName
    """
    for s in 1 2 3 4 rev.1 rev.2; do touch ${index_name}.\$s.ebwt; done
    """
}