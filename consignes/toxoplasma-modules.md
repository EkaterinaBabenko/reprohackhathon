# Workflow Toxoplasma — modules et réutilisation du workflow persister

Projet 2 du hackathon (Hu et al., *Frontiers in Microbiology* 2020, PRJNA483261) :
reproduire la **Fig. 2B** (diagramme de Venn des transcrits différentiellement exprimés,
DETs, à d11 et d33). Ce document décrit, module par module et dans l'ordre du workflow,
ce qui est réutilisé de `workflow-persister/` et ce qui est adapté ou nouveau.

Workflow : `Lectures SRA → Trimmomatic → Salmon index → Salmon quant → DESeq2 → Venn`

## Tableau récapitulatif

| # | Module (`workflow-toxoplasma/modules/`) | Origine | Changement par rapport au persister | Documentation |
|---|---|---|---|---|
| 1 | `download_sra.nf` | persister (réutilisé) | tuple de sortie + champ `timepoint` (samples.csv toxo : `sample,condition,timepoint,SRR`) ; correction du `tag` (`${sample}.id` → `${sample}`) | |
| 2 | `trimming.nf` | persister (adapté) | cutadapt → **Trimmomatic v0.39** (outil de l'article, conteneur Damona) ; mode **PE** (lectures paired-end confirmées) | https://github.com/usadellab/Trimmomatic |
| 3 | `download_ref.nf` | persister (adapté) | URLs NCBI (S. aureus CP000253.1) → **Ensembl release 100, GRCm38** (fasta toplevel + GFF3), avec `gunzip` | |
| 4 | `build_transcriptome.nf` | **nouveau** | construit le fasta cDNA (gffread) à partir du génome + GFF3 ; prérequis de l'index Salmon | |
| 5 | `salmon_index.nf` | **nouveau** (remplace `bowtie_index.nf`) | `salmon index` (v1.2.0, Damona), type `quasi`, k=31 | https://salmon.readthedocs.io/en/latest/salmon.html|
| 6 | `salmon_quant.nf` | **nouveau** (remplace `bowtie_map.nf` + `featurecounts.nf`) | `salmon quant` PE (`-1`/`-2`) par échantillon → `quant.sf` (comptages par transcrit), `-l A`, `--validateMappings` | https://salmon.readthedocs.io/en/latest/salmon.html|
| 7 | `deseq2.nf` + `bin/deseq2_toxo.R` | persister (adapté) | entrée = `quant.sf` Salmon (et non `counts.txt` featureCounts) ; design 2×2 testé **par timepoint** ; seuils du papier (p < 0.05 non ajustée, \|log2FC\| ≥ 1.5) ; sorties `det_d11.csv` / `det_d33.csv` pour le Venn | |

Non repris du persister : `bowtie_index.nf`, `bowtie_map.nf`, `featurecounts.nf`
(remplacés par la chaîne Salmon, le Projet 2 n'utilisant pas d'aligneur classique).

## Hypothèses et choix à justifier dans le rapport

Le papier ne précise pas (consigne : "make and document reasonable choices") :

1. **Single- vs paired-end** : résolu — les lectures de PRJNA483261 sont **paired-end**
   (confirmé), les modules 2 et 6 utilisent donc le mode PE (`Trimmomatic PE`,
   `salmon quant -1/-2`).
2. **Trimming** : `ILLUMINACLIP:TruSeq3-*.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:25`
   (seuil de qualité 20 et MINLEN 25, mêmes hypothèses que le Projet 1).
3. **Salmon** : k-mère 31 (défaut), index `quasi`, librairie `-l A` (auto),
   `--validateMappings`.
4. **DESeq2** : test **par timepoint** (In vs WT à d11, puis à d33) plutôt que modèle
   d'interaction — les deux options sont suggérées par la consigne. Seuils du papier :
   p-value < 0.05 **non ajustée** et |log2FC| ≥ 1.5.
5. **Référence** : génome souris GRCm38, Ensembl release 100 (fasta `dna.toplevel` +
   GFF3), URLs dans `download_ref.nf`. Génome ~2.7 Gb : prévoir espace disque/temps.
6. **Conteneurs** : exécutés avec **Apptainer** (voir section « Conteneurs » ci-dessous).
   Salmon 1.2.0 : image `salmon_1.2.0.img` téléchargée depuis Zenodo
   (https://zenodo.org/records/22144681), placée dans `workflow-toxoplasma/containers/`.
   Trimmomatic 0.39 (`staphb/trimmomatic:0.39`), SRA Toolkit (`staphb/sratoolkit`),
   gffread (`getwilds/gffread`) : images Docker Hub appelées via le préfixe `docker://` ;
   DESeq2 : image locale `deseq2:latest` construite depuis `../workflow-persister/deseq2`
   (recette du Projet 1), appelée via `docker-daemon://`.

## Assemblage

- `main.nf` : chaîne les 7 modules dans l'ordre ci-dessus.
- `data/samples.csv` : 12 échantillons (2 conditions × 2 timepoints × 3 réplicats) ;
  mapping run → condition reconstruit depuis les métadonnées SRA (PRJNA483261) et la
  section Materials & Methods de l'article.

## Configuration (`nextflow.config`)

- `params.samplesheet = 'data/samples.csv'`, `params.deseq2_pvalue = 0.05`,
  `params.deseq2_log2fc = 1.5`.
- **Conteneurs centralisés** dans `params.containers.*` (un nom d'image par outil) ;
  les modules y font référence via `${params.containers.<outil>}`.
- **Ressources par label** : `process_low` / `process_medium` / `process_high`
  (posés dans chaque module), définissant cpus/mémoire/temps par défaut.
- **Un bloc `withName:` par process** : container, cpus, mémoire, `publishDir`
  (résultats publiés dans `results/01_download`, `02_trimming`, `03_reference`,
  `04_quant`, `05_deseq2`, plus `pipeline_info/` pour timeline/report/trace/DAG).
- **Profils** : `docker`, `apptainer` (moteur de conteneurs — un seul à la fois, choisis
  via `-profile`), `singularity` (variante si la VM n'a que l'ancien binaire).

## Conteneurs : passage à Apptainer

Tous les conteneurs du workflow toxoplasma sont exécutés avec **Apptainer** :

```bash
nextflow run main.nf -profile apptainer
```

- `docker.enabled` et `apptainer.enabled` sont **mutuellement exclusifs** dans Nextflow :
  le profil `apptainer` pose `apptainer.enabled = true` et `docker.enabled = false`.
- Dans ce profil, les images du Docker Hub sont appelées avec le préfixe `docker://`
  (Apptainer les convertit automatiquement en `.sif`) et l'image locale DESeq2 avec
  `docker-daemon://deseq2:latest` (lue depuis le daemon Docker local).
- **Salmon 1.2.0** (version de l'article) : image `salmon_1.2.0.img` de Zenodo
  (record 22144681), fichier local référencé par `${projectDir}/containers/salmon_1.2.0.img`.
  C'est cette version qui rend `--type quasi -k 31` valide (supprimé en Salmon ≥ 1.10).
- Prérequis : `apptainer` installé sur la machine de lancement (`which apptainer`),
  sinon `singularity` (profil `singularity`).
