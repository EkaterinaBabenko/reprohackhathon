// Construction de l'index Salmon.
// Quantifie avec Salmon (sans aligneur).
//
// Entrée  : path transcripts.fa (cDNA)              <- BUILD_TRANSCRIPTOME
// Sortie  : path "salmon_index" (dossier d'index), emit: index -> SALMON_QUANT
//
// HYPOTHÈSE : k-mère de 31 (valeur par défaut de Salmon,
// recommandée pour des lectures >= 75 nt) et index de type "quasi" (quasi-mapping).

process SALMON_INDEX {
    tag "salmon_index"
    label 'process_high'   // index sur le transcriptome souris : lourd

    container "${params.containers.salmon}"   // image Damona Salmon 1.2.0 (voir nextflow.config)

    input:
    path transcriptome

    output:
    path "salmon_index", emit: index

    script:
    """
    salmon index -t ${transcriptome} -i salmon_index --type quasi -k 31
    """
}
