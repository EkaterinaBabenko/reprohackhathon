
process DOWNLOAD_REF {
    label 'process_low'

    container "${params.containers.sratoolkit}"   // même image que DOWNLOAD_SRA (contient wget) ; défini dans nextflow.config

    output:
    path "reference.fasta", emit: fasta
    path "reference.gff3",  emit: gff

    script:
    """
    wget -q -O reference.fasta.gz "https://ftp.ensembl.org/pub/release-100/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.toplevel.fa.gz"
    wget -q -O reference.gff3.gz  "https://ftp.ensembl.org/pub/release-100/gff3/mus_musculus/Mus_musculus.GRCm38.100.gff3.gz"
    gunzip reference.fasta.gz reference.gff3.gz
    """
}
