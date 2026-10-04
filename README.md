# Gastric Cancer-Associated Virome Analysis Pipeline

Shell and R Markdown scripts for characterizing viral communities in human gastric tissues using paired-end metatranscriptomic RNA-Seq data. The workflow covers preprocessing, host-read removal, viral classification, taxonomic filtering, composition, diversity, clustering, and differential abundance in relation to tissue type and clinicopathological characteristics.

**Keywords:** gastric cancer; virome; metatranscriptomics; RNA-Seq; viral communities; bioinformatics.

## Project identifiers

| Resource | Identifier or location |
| --- | --- |
| Source code | [GitHub repository](https://github.com/armsdidi/1_gastric-cancer-associated-virome-analysis) |
| Related publication | *Comprehensive analysis of the gastric metatranscriptome reveals specific viral signatures associated with gastric cancer*. International Microbiology (2026). |
| Article DOI | [10.1007/s10123-026-00867-4](https://doi.org/10.1007/s10123-026-00867-4) |
| License | [MIT](LICENSE) |
| Author | [Diego Pereira](https://github.com/armsdidi) |

The article DOI identifies the publication, not an archived software release. A software DOI is not currently documented.

## Workflow and repository structure

Run the scripts in numerical order. Additional inputs and a report-export step are required; the repository is not a fully automated end-to-end workflow.

| Step | Script | Analysis and output |
| --- | --- | --- |
| 1 | [1_Quality_control_and_preprocessing.sh](1_Quality_control_and_preprocessing.sh) | FastQC and MultiQC before/after fastp adapter trimming and quality/length filtering; cleaned paired FASTQ and QC reports |
| 2 | [2_Removing_host_contamination.sh](2_Removing_host_contamination.sh) | Bowtie2 alignment against hg38; paired reads not aligning concordantly to the human reference |
| 3 | [3_Taxonomic_classification.sh](3_Taxonomic_classification.sh) | Kraken2 classification; per-sample taxonomic reports |
| 4 | [4_Filtering_viral_taxa.Rmd](4_Filtering_viral_taxa.Rmd) | Integration and filtering of exported tables; `virus_tab.xlsx` |
| 5 | [5_Viral_composition.Rmd](5_Viral_composition.Rmd) | Prevalence, abundance, genome type, and host-group composition |
| 6 | [6_Alpha_and_beta_diversity.Rmd](6_Alpha_and_beta_diversity.Rmd) | Alpha diversity, Bray–Curtis PCoA, PERMANOVA, and PERMDISP |
| 7 | [7_Community_patterns_and_clustering.Rmd](7_Community_patterns_and_clustering.Rmd) | Jensen–Shannon divergence and PAM community clustering |
| 8 | [8_Differential_abundance.Rmd](8_Differential_abundance.Rmd) | LEfSe comparisons across tissue and clinical categories |

## Data availability and access

The source code and documentation are publicly accessible through GitHub without authentication for reading or cloning. Raw reads, reference databases, exported taxonomic tables, clinical metadata, and analysis results are not included.

**Study-data accessions and access conditions are not yet documented here.** Exact reproduction of the study requires additional information. Before distributing a complete study package, document:

- Sequencing archive, study/run accessions, direct links, and sample-to-run mapping.
- Locations and reuse terms for processed abundance and viral annotation tables.
- Whether de-identified clinical metadata are open, controlled, or unavailable, with any applicable access procedure.
- Human reference source/release and index construction procedure.
- Viral database source, version/build date, download identifier, and checksums.

[ENA](https://www.ebi.ac.uk/ena/browser/home) is an example of a sequencing archive; this link is not a study-specific accession. Public code availability does not imply that all study inputs are openly available.

## Input formats

| Input | Expected format or structure | Step |
| --- | --- | --- |
| Raw paired reads | Gzip FASTQ: `<sample>.R1.fastq.gz`, `<sample>.R2.fastq.gz` | 1 |
| Cleaned reads | Gzip FASTQ: `<sample>.R1.clean.fastq.gz`, `<sample>.R2.clean.fastq.gz` | 2 |
| Host-depleted reads | Gzip FASTQ: `<sample>.nonhuman_R1.fastq.gz`, `<sample>.nonhuman_R2.fastq.gz` | 3 |
| Human reference | Bowtie2 index configured by `BOWTIE_INDEX` | 2 |
| Viral database | Kraken2 database directory configured by `KRAKEN_DB` | 3 |
| Exported classification tables | `virus_tab1.tsv` through `virus_tab10.tsv`, with taxon name, lineage, and numeric sample counts | 4 |
| Viral abundance | `virus_tab.xlsx`: `Taxon` identifier column followed by numeric sample-count columns | 5–8 |
| Clinical metadata | `clinical_data.xlsx`: one row per sample, identifier in `samples_diego` | 5–8 |
| Viral annotations | `virus_hosp.xlsx`: includes `Taxon`, `Virus_Group`, `Genome_Type` | 5 |

Kraken2 reports must be integrated/exported before use as the TSV inputs of step 4. The original workflow describes using **Pavian** for this intermediate step. Review the import code for the full expected structure; the ten exported files reflect the original dataset organization.

### Metadata fields used in comparisons

| Field | Meaning | Categories used in the scripts |
| --- | --- | --- |
| `samples_diego` | Unique sample identifier | Must match abundance-table column names |
| `Tissue` | Tissue category | `GC` (gastric cancer), `NT` (normal tissue) |
| `Lauren` | Histological classification | `Intestinal`, `Diffuse` |
| `Neoadjuvant` | Treatment status | `Treated`, `Untreated` |
| `Tumor_site` | Tumor location | `Cardia`, `Non-Cardia` |
| `TNM` | Stage | `I`, `II`, `III`, `IV` |

Several R analyses explicitly subset `GC` and `NT`; adapt these subsets to analyze other tissue categories. Keep sample identifiers consistent across files and inspect the sample-name transformations in step 4. Preserve raw counts and document conversions to relative abundance.

FASTQ and TSV facilitate exchange between tools. XLSX is the current input format for downstream analyses. When releasing tables, add TSV/CSV copies, a data dictionary, taxonomic identifiers, and the reference taxonomy version. Changing file formats also requires adapting the import code.

## Requirements and dependencies

The Shell steps require **Bash**, **Conda**, **FastQC**, **MultiQC**, **fastp**, **Bowtie2**, **Kraken2**, a human reference index, and a viral classification database.

Install FastQC, MultiQC, fastp, Bowtie2, and Kraken2 in a dedicated Conda environment. Activate that environment before running the Bash scripts. The current scripts use the working directory as `BASE_DIR` and configure 8 threads per tool; adjust paths and resources for your system.

The R Markdown scripts load:

`readxl`, `dplyr`, `tibble`, `tidyr`, `openxlsx`, `purrr`, `ggplot2`, `colorspace`, `gridExtra`, `grid`, `circlize`, `ggvenn`, `ComplexHeatmap`, `vegan`, `ggpubr`, `microbiome`, `phyloseq`, `patchwork`, `ade4`, `cluster`, `philentropy`, `factoextra`, `microbiomeMarker`, and `scales`.

Pavian is used for report integration/exploration. RStudio can be used to execute the `.Rmd` chunks; rendering requires R Markdown tooling such as `rmarkdown` and `knitr`.

**Exact software/package versions are not recorded, and no environment lockfile or container is supplied.** Record tool versions and R `sessionInfo()` with each analysis.

## Execution

### 1. Obtain and identify the code

```bash
git clone https://github.com/armsdidi/1_gastric-cancer-associated-virome-analysis.git
cd 1_gastric-cancer-associated-virome-analysis
git rev-parse HEAD
```

Record the commit identifier with the results.

### 2. Install tools in a Conda environment

Create a dedicated environment and install the command-line tools:

```bash
conda create -n gastric_virome --override-channels -c conda-forge -c bioconda \
    fastqc multiqc fastp bowtie2 kraken2
```

Activate the environment before running any Bash script, including in each new terminal session:

```bash
conda activate gastric_virome
```

The environment name is an example; use your own name if the tools are already installed in another Conda environment. Reference databases must be downloaded and configured separately.

### 3. Configure inputs and paths

Edit directory variables, reference paths, and resource settings in scripts 1–3. Run the scripts from the project root so `BASE_DIR="$(pwd)"` resolves correctly. Prepare the input directories and check paired-read naming conventions. Ensure `FASTQ/CLEAN_FASTQ` and `FASTQ/NON-HUMAN_FASTQ` exist; the scripts create their QC/report directories.

### 4. Execute the Bash steps sequentially

With the Conda environment active, run each script only after the preceding step has completed successfully:

```bash
bash 1_Quality_control_and_preprocessing.sh
bash 2_Removing_host_contamination.sh
bash 3_Taxonomic_classification.sh
```

Inspect logs, QC reports, and outputs before proceeding.

Bowtie2's `--un-conc-gz` retains pairs that do not align concordantly; this does not by itself establish that both mates are free of human sequence.

### 5. Prepare downstream tables

Integrate/export Kraken2 reports using Pavian and prepare step 4's TSV inputs. Review its sample renaming and filtering. The hard-coded `1:987` and `1:451` column ranges are dataset-specific and must match the actual table dimensions.

Run step 4 to produce `virus_tab.xlsx`. Provide `clinical_data.xlsx` and, for step 5, `virus_hosp.xlsx` in the R working directory, or update the input paths.

### 6. Run the R analyses

Open steps 5–8 in RStudio and run the relevant chunks after checking sample matching, group definitions, and inputs. Review each document before rendering it in full. Save tables, figures, parameters, and session information with the results.

## Parameters visible in the scripts

| Component | Implemented settings |
| --- | --- |
| FastQC / MultiQC | Quality assessment and report aggregation before and after preprocessing |
| fastp | Paired-end adapter detection; qualified Phred threshold 15; minimum length 50; 8 threads |
| Bowtie2 | hg38 index prefix; `--very-sensitive`; 8 threads; `--un-conc-gz` |
| Kraken2 | Paired-end classification; `--use-names`; gzip input; 8 threads |
| Filtering | Lineages matching `Viruses`; samples and taxa with total counts greater than 4 at their respective filtering steps |
| Diversity | Alpha diversity including richness and Shannon; Bray–Curtis ordination; PERMANOVA and PERMDISP |
| Clustering | Jensen–Shannon divergence and PAM |
| LEfSe | CPM normalization; Kruskal–Wallis cutoff 0.05; LDA cutoff 2.5 for tissue and 2 for clinical comparisons |

Consult the scripts for complete statistical settings. Review thresholds before reuse with another dataset. RNA-Seq taxonomic assignments alone do not establish productive viral infection or causality in gastric cancer.

## FAIR alignment

This README makes identifiers, input formats, access limitations, methods, and reuse terms explicit. **README changes alone do not establish full FAIR compliance.** FAIR concerns data and metadata as well as software.

| Principle | Documented here | Remaining work |
| --- | --- | --- |
| **Findable** | Title, keywords, repository URL, related article DOI | Archive a software release with a persistent identifier; add study accessions and dataset metadata |
| **Accessible** | Public code access and explicit information about absent inputs | Specify data access URLs/procedures, restrictions, and preservation arrangements |
| **Interoperable** | Formats, metadata fields, group labels, shared sample identifiers | Provide machine-readable schemas, taxonomic identifiers, and exchange-format table copies |
| **Reusable** | MIT license, execution order, dependencies, parameters, adaptation requirements | Record exact versions and reference provenance; supply example inputs, environment specification, and data reuse terms |

## Citation

When using this workflow, cite the associated article:

> *Comprehensive analysis of the gastric metatranscriptome reveals specific viral signatures associated with gastric cancer*. International Microbiology (2026). https://doi.org/10.1007/s10123-026-00867-4

Also cite this repository with the commit or release used. Cite external tools, databases, and datasets according to their respective guidance. An archived software release and `CITATION.cff` would support a more precise software citation.

## License

Source code and repository documentation are distributed under the [MIT License](LICENSE), copyright © 2026 Diego Pereira. Retain the license and copyright notice when redistributing applicable material.

This license does not grant rights to external sequencing data, clinical metadata, databases, or third-party software; their own terms apply.

## Author and support

**Diego Pereira**

Bioinformatics Scientist | PhD in Genetics & Molecular Biology | NGS | R | Linux/Bash | Metagenomics & Metatranscriptomics.

Use [GitHub Issues](https://github.com/armsdidi/1_gastric-cancer-associated-virome-analysis/issues) for questions, bug reports, or suggestions. Include the script, commit, software versions, and a reproducible description without identifiable clinical information.

