// modules/build_transcriptome.nf
// Construction du transcriptome (fasta cDNA) à partir du génome et de l'annotation GFF3..
//
// Outil : gffread (extrait les séquences des transcrits à partir du génome + GFF3).
//
// Entrées : - reference.fasta (génome GRCm38)  <- DOWNLOAD_REF.fasta
//           - reference.gff3  (annotation)      <- DOWNLOAD_REF.gff
// Sortie  : path "transcripts.fa" (cDNA), emit: transcriptome -> SALMON_INDEX

process BUILD_TRANSCRIPTOME {
    tag "GRCm38.cDNA"
    label 'process_high'   // génome souris ~2.7 Gb : étape lourde

    container "${params.containers.gffread}"

    input:
    path genome_fasta
    path genome_gff

    output:
    path "transcripts.fa", emit: transcriptome

    script:
    """
    gffread -w transcripts.fa -g ${genome_fasta} ${genome_gff}
    """
}
