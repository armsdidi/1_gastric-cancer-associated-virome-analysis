# Gastric Cancer-Associated Virome Analysis

## Overview

This repository contains Shell and R scripts developed for the characterization of the **gastric cancer-associated virome** using metatranscriptomic RNA-Seq data.

The workflow was designed to investigate the composition and diversity of viral communities across gastric tissues and their associations with clinicopathological features of gastric cancer. The analyses include raw read preprocessing, host-read removal, viral taxonomic classification, taxonomic filtering, viral composition, alpha and beta diversity, community profiling and clustering, and differential abundance analysis.

---

## Workflow

The analytical workflow is organized into eight sequential steps:

* **Raw RNA-Seq reads**
↓
* **1. Quality control and preprocessing** — fastp
↓
* **2. Human host-read removal** — Bowtie2
↓
* **3. Viral taxonomic classification** — Kraken2
↓
* **4. Viral taxa filtering** — R
↓
* **5. Viral composition and relative abundance** — R
↓
* **6. Alpha and beta diversity** — R
↓
* **7. Community patterns and clustering** — R
↓
* **8. Differential abundance analysis** — R

---

## Repository Structure

### `1_Quality_control_and_preprocessing.sh`

Performs quality control and preprocessing of raw paired-end RNA-Seq reads.

The script uses **fastp** to remove adapters, trim low-quality bases, filter low-quality reads, and generate quality-control reports for each sample.

**Main output:** cleaned paired-end FASTQ files suitable for downstream analyses.

---

### `2_Removing_host_contamination.sh`

Removes sequencing reads originating from the human host.

Preprocessed reads are aligned against the human reference genome using **Bowtie2**, and unmapped reads are retained for subsequent microbial and viral analyses.

**Main output:** host-depleted paired-end reads.

---

### `3_Taxonomic_classification.sh`

Performs taxonomic classification of host-depleted reads using **Kraken2** and a viral reference database.

**Main output:** Kraken2 classification reports containing viral taxonomic assignments and read counts.

---

### `4_Filtering_viral_taxa.Rmd`

Kraken2 classification reports were subsequently integrated and explored in **RStudio** using the **pavian** package

Processes and filters the viral taxonomic classification results before downstream ecological analyses.

This step removes viral taxa considered unsuitable for the characterization of the human gastric virome and generates the filtered viral abundance table used in subsequent analyses.

**Main output:** curated viral abundance table.

---

### `5_Viral_composition.Rmd`

Characterizes the taxonomic composition of the gastric virome.

The analyses include viral prevalence, abundance, relative abundance, genome type, host-associated viral groups, and comparisons of viral composition across gastric tissue groups.

**Main output:** descriptive statistics and visualizations of gastric viral composition.

---

### `6_Alpha_and_beta_diversity.Rmd`

Evaluates within-sample and between-sample viral diversity.

Alpha diversity is assessed using metrics such as **Observed richness** and the **Shannon diversity index**.

Beta diversity is evaluated using ecological distance metrics and ordination approaches, including **Bray–Curtis dissimilarity** and **Principal Coordinates Analysis (PCoA)**. Statistical differences in community structure are assessed using **PERMANOVA** and **PERMDISP**.

Analyses are performed across gastric tissue groups and selected clinicopathological characteristics.

**Main output:** diversity estimates, statistical tests, and ordination plots.

---

### `7_Community_patterns_and_clustering.Rmd`

Investigates patterns of viral community organization across gastric samples.

Viral community dissimilarity is estimated using **Jensen–Shannon divergence (JSD)**, followed by **Partitioning Around Medoids (PAM)** clustering to identify recurrent viral community profiles.

Cluster structure is further explored using ordination methods and associations with tissue type and clinicopathological characteristics.

**Main output:** viral community clusters and associated visualizations.

---

### `8_Differential_abundance.Rmd`

Identifies viral taxa with differential abundance between gastric tissue groups and clinicopathological categories.

Differential abundance analyses are performed using **LEfSe (Linear Discriminant Analysis Effect Size)** to identify taxa associated with specific biological or clinical groups.

**Main output:** differentially abundant viral taxa and corresponding effect-size visualizations.

---

## Main Analyses

The repository covers the following analytical components:

* RNA-Seq quality control and preprocessing
* Human host-read depletion
* Viral taxonomic classification
* Viral taxonomic filtering
* Viral prevalence and relative abundance
* Viral genome and host-group characterization
* Alpha diversity
* Beta diversity and ordination
* PERMANOVA and PERMDISP
* Jensen–Shannon divergence
* PAM clustering
* Differential abundance analysis using LEfSe
* Associations with clinicopathological features

---

## Requirements and Dependencies

### Command-line tools

The preprocessing and taxonomic classification steps require:

* **fastp**
* **Bowtie2**
* **Kraken2**

### R

Downstream analyses were performed in **R** using packages including:

* `pavian`
* `phyloseq`
* `microbiome`
* `vegan`
* `microbiomeMarker`
* `ggplot2`
* `circlize`
* `ComplexHeatmap`
* `ade4`
* `cluster`
* `philentropy`
* `factoextra`

Additional R packages used for data manipulation and visualization are specified within the corresponding R Markdown scripts.

---

## Input Data

The workflow was developed for **paired-end metatranscriptomic RNA-Seq data from human gastric tissue samples**.

The main input files include:

* Raw paired-end FASTQ files
* Human reference genome/index for host-read removal
* Kraken2 viral reference database
* Sample metadata containing tissue and clinicopathological information

Raw sequencing data and clinical metadata are **not included in this repository**.

Users interested in reproducing the workflow should adapt file paths, reference databases, metadata, and computational resources according to their local environment.

---

## Reproducibility

Scripts are numbered according to the recommended execution order.

Shell scripts (`.sh`) contain the initial preprocessing and taxonomic classification steps, whereas R Markdown files (`.Rmd`) contain the downstream statistical, ecological, and visualization analyses.

File paths, computational resources, reference databases, and sample metadata may need to be modified before running the workflow in a different computational environment.

---

## Research Context

This workflow was developed as part of a research project investigating the **gastric cancer-associated virome** using metatranscriptomic sequencing.

The study explores how viral communities differ across gastric tissues and whether virome characteristics are associated with clinicopathological features of gastric cancer.

---

## Publication

Results generated using this workflow contributed to the following publication:

**Comprehensive analysis of the gastric metatranscriptome reveals specific viral signatures associated with gastric cancer**

*International Microbiology* (2026)

DOI: `10.1007/s10123-026-00867-4`

---

## License

This project is distributed under the **MIT License**. See the `LICENSE` file for details.

---

## Author

**Diego Pereira**

Bioinformatics Scientist | PhD in Genetics and Molecular Biology | Transcriptomic and Metagenomic Data Analysis

