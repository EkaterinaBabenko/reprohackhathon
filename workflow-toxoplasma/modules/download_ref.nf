// Téléchargement du génome de référence souris et de son annotation.
// Les URLs Ensembl (Mus_musculus.GRCm38) sont en paramètres (params.genome_url / params.gff_url dans nextflow.config).
//
// Entrée  : aucune
// Sorties : path "reference.fasta" (génome décompressé), emit: fasta -> BUILD_TRANSCRIPTOME
//           path "reference.gff3"  (annotation décompressée), emit: gff  -> BUILD_TRANSCRIPTOME

process DOWNLOAD_REF {
    label 'process_low'

    container "${params.containers.sratoolkit}"   // même image que DOWNLOAD_SRA (contient wget) ; défini dans nextflow.config

    output:
    path "reference.fasta", emit: fasta
    path "reference.gff3",  emit: gff

    script:
    """
    wget -q -O reference.fasta.gz ${params.genome_url}
    wget -q -O reference.gff3.gz  ${params.gff_url}
    gunzip reference.fasta.gz reference.gff3.gz
    """
}
