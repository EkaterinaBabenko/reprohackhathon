# Reprohackathon - Projet 1 : persisters de *S. aureus*

Reproduction partielle de l'analyse RNA-Seq de
[Peyrusson et al., *Nature Communications*, 2020](https://www.nature.com/articles/s41467-020-15966-7)
(« Intracellular *Staphylococcus aureus* persisters upon antibiotic exposure »), avec un workflow
**Nextflow** et des **conteneurs** (Docker).

> Statut : en cours de développement. Les sections marquées `TODO` seront complétées au fil du projet.

## 1. Objectif

Identifier les gènes différentiellement exprimés entre les bactéries **persisters** intracellulaires
et les bactéries **contrôles**, puis reproduire deux figures du papier :

- **Fig. 3c** : MA-plot des gènes liés à la traduction ;
- **Supp. Fig. 3** : MA-plot du jeu de données RNA-Seq complet.

Les données brutes sont publiques (GEO : GSE139659, lectures SRA). Référence : génome *S. aureus*
NCTC 8325 (NCBI CP000253.1) et son annotation.

## 2. Workflow

```
Lectures SRA ──> Trimming ──> Mapping ──> Comptage par gène ──> Expression différentielle ──> MA-plots
 (fasterq-dump)  (cutadapt)   (bowtie)    (featureCounts)          (DESeq2)
```

| Étape | Outil (version du papier) | Module |
|---|---|---|
| Téléchargement des lectures | SRA Toolkit (`fasterq-dump`) | `modules/download_sra.nf` |
| Téléchargement génome + annotation | `wget` (NCBI) | `modules/download_ref.nf` |
| Nettoyage des lectures | cutadapt 1.11 | `modules/trimming.nf` |
| Index du génome | Bowtie 0.12.7 | `modules/bowtie_index.nf` |
| Mapping | Bowtie 0.12.7 + samtools | `modules/bowtie_map.nf` |
| Comptage | featureCounts 1.4.6-p3 (Subread) | `modules/featurecounts.nf` |
| Expression différentielle | R 3.4.1 + DESeq2 1.16 | `modules/deseq2.nf` |

Chaque étape s'exécute dans son propre conteneur (recettes dans `containers/`).

## 3. Structure du dépôt

```
.
├── main.nf                  # assemblage du workflow
├── nextflow.config          # paramètres, ressources, conteneurs, profils
├── run.sh                   # lancement en une commande
├── samplesheet.csv          # échantillons : sample, condition, srr
├── modules/                 # un fichier .nf par étape
├── containers/              # une recette (Dockerfile / .def) par outil
├── bin/                     # scripts R et Python (DESeq2, MA-plots, annotations)
├── test/                    # jeu de test minuscule
└── docs/
    ├── assumptions.md       # hypothèses faites quand le papier est silencieux
    └── report/              # sections du rapport
```

## 4. Prérequis

- [Nextflow](https://www.nextflow.io/) (version : `TODO`) et Java (`TODO`)
- **Docker** *ou* **Apptainer** (`TODO` : lequel est disponible sur la VM ?)
- Git, accès Internet (téléchargement des données et des images)
- Ressources conseillées : `TODO` CPU, `TODO` Go de RAM, `TODO` Go de disque

## 5. Lancer l'analyse

```bash
git clone <TODO : url du dépôt>
cd <TODO : nom du dossier>

# Run complet (par exemple sur la VM, avec Apptainer)
./run.sh
# équivalent à : nextflow run main.nf -profile vm,apptainer

# Run rapide sur le jeu de test
nextflow run main.nf -profile test,vm,apptainer

# Reprendre un run interrompu
nextflow run main.nf -profile vm,apptainer -resume
```

Profils disponibles : `standard`, `vm` (environnement) ; `docker`, `apptainer`, `singularity`
(moteur de conteneurs) ; `test` (jeu de test). Ils se combinent avec une virgule.

> `TODO` : vérifier que ces commandes fonctionnent sur une machine propre avant le rendu.

## 6. Paramètres principaux

Définis dans `nextflow.config`, modifiables en ligne de commande (`--nom_parametre valeur`).

| Paramètre | Valeur par défaut | Rôle |
|---|---|---|
| `--samplesheet` | `samplesheet.csv` | liste des échantillons |
| `--outdir` | `results` | dossier de sortie |
| `--cutadapt_quality` | `20` | seuil de qualité (`-q`) |
| `--cutadapt_minlen` | `25` | longueur minimale après trimming (`-m`) |
| `--cutadapt_adapter` | `null` | adaptateur à retirer (`TODO` : décision) |
| `--deseq2_padj` | `0.05` | seuil de p-value ajustée |

## 7. Résultats produits

```
results/
├── 01_download/     # FASTQ, génome, annotation
├── 02_trimming/     # lectures nettoyées
├── 03_mapping/      # index Bowtie et fichiers BAM
├── 04_counts/       # counts.txt (featureCounts)
├── 05_deseq2/       # tables de résultats, MA-plots
└── pipeline_info/   # timeline, rapport d'exécution, trace, DAG
```

`TODO` : ajouter les figures obtenues et le nombre de gènes différentiellement exprimés
(le papier en rapporte 1477 : 710 sur-exprimés et 767 sous-exprimés chez les persisters).

## 8. Hypothèses et choix

Le papier ne précise pas tout. Chaque choix fait pour combler un manque (seuil de qualité,
adaptateur, options de featureCounts, etc.) est noté et justifié dans le rapport.

## 9. Conteneurs

| Outil | Version | Image / recette |
|---|---|---|
| SRA Toolkit | `TODO` | `containers/sratoolkit/` |
| cutadapt | 1.11 | `containers/cutadapt/` |
| Bowtie + samtools | 0.12.7 | `containers/bowtie/` |
| Subread (featureCounts) | 1.4.6-p3 | `containers/subread/` |
| R + DESeq2 | `TODO` | `containers/deseq2/` |

`TODO` : indiquer comment construire les images (`docker build ...` ou `apptainer build ...`).

## 10. Équipe et références

- Membres : Ekaterina BABENKO, Julien NOTARANGELO, Jules VAN OVERBEKE, Ela XIONG
- Encadrement : Frédéric Lemoine, Thomas Cokelaer (Institut Pasteur)
- Papier : Peyrusson F. et al., *Nat. Commun.* **11**, 2200 (2020).
  [doi:10.1038/s41467-020-15966-7](https://doi.org/10.1038/s41467-020-15966-7)