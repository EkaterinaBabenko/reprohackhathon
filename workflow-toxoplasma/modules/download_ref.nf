// modules/download_ref.nf
// Téléchargement du génome de référence souris et de son annotation (Projet 2, Hu et al. 2020).
// Adapté de workflow-persister/modules/download_ref.nf : les URLs NCBI (S. aureus CP000253.1)
// sont remplacées par les URLs Ensembl release 100, GRCm38 (consigne du projet, p.9) :
//   - génome  : Mus_musculus.GRCm38.dna.toplevel.fa.gz  (~2.7 Gb compressé -> prévoir l'espace disque)
//   - annotation : Mus_musculus.GRCm38.100.gff3.gz
//
// Entrée  : aucune
// Sorties : path "reference.fasta"  (génome décompressé), emit: fasta -> BUILD_TRANSCRIPTOME
//           path "reference.gff3"   (annotation décompressée), emit: gff   -> BUILD_TRANSCRIPTOME

process DOWNLOAD_REF {
    label 'process_low'

    container "staphb/sratoolkit"   // image déjà utilisée pour DOWNLOAD_SRA (contient wget)

    input:

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
