#!/bin/bash

# ============================================================
# QUALITY CONTROL AND TRIMMING
# FastQC + MultiQC + fastp
# ============================================================

# Stop the script if an error occurs:
set -euo pipefail

# Number of threads:
THREADS=8

# Directories:
BASE_DIR="$(pwd)"
RAW_DIR="$BASE_DIR/FASTQ/RAW_FASTQ"
CLEAN_DIR="$BASE_DIR/FASTQ/CLEAN_FASTQ"
QC_DIR="$BASE_DIR/QC"
FASTQC_RAW_DIR="$QC_DIR/FastQC_RAW"
MULTIQC_RAW_DIR="$QC_DIR/MultiQC_RAW"
FASTQC_CLEAN_DIR="$QC_DIR/FastQC_CLEAN"
MULTIQC_CLEAN_DIR="$QC_DIR/MultiQC_CLEAN"
FASTP_REPORT_DIR="$QC_DIR/fastp_REPORTS"
SAMPLE_LIST="$BASE_DIR/all_sample.txt"

# Create directories:
mkdir -p \
    "$QC_DIR" \
    "$FASTQC_RAW_DIR" \
    "$MULTIQC_RAW_DIR" \
    "$FASTQC_CLEAN_DIR" \
    "$MULTIQC_CLEAN_DIR" \
    "$FASTP_REPORT_DIR"

# Create the sample list:
echo ">>> Creating the sample list..."

find "$RAW_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.R1.fastq.gz" \
    -exec basename {} \; \
    | sed 's/\.R1\.fastq\.gz$//' \
    | sort -u \
    > "$SAMPLE_LIST"

# Check whether samples are available:
if [ ! -s "$SAMPLE_LIST" ]; then
    echo "ERROR: no .R1.fastq.gz samples found in $RAW_DIR" >&2
    exit 1
fi

echo ">>> Number of samples: $(wc -l < "$SAMPLE_LIST")"

# Check read pairs and prepare file lists for FastQC:
echo ">>> Checking paired-end files..."

RAW_FILES=()
CLEAN_FILES=()

while IFS= read -r SAMPLE; do

    R1="$RAW_DIR/${SAMPLE}.R1.fastq.gz"
    R2="$RAW_DIR/${SAMPLE}.R2.fastq.gz"

    if [ ! -s "$R1" ]; then
        echo "ERROR: R1 missing or empty: $R1" >&2
        exit 1
    fi

    if [ ! -s "$R2" ]; then
        echo "ERROR: R2 missing or empty: $R2" >&2
        exit 1
    fi

    RAW_FILES+=("$R1" "$R2")

    CLEAN_FILES+=(
        "$CLEAN_DIR/${SAMPLE}.R1.clean.fastq.gz"
        "$CLEAN_DIR/${SAMPLE}.R2.clean.fastq.gz"
    )

done < "$SAMPLE_LIST"

echo ">>> All paired-end files were found."

# Initial quality control with FastQC:
echo ">>> Running FastQC on raw reads..."

fastqc \
    --threads "$THREADS" \
    --outdir "$FASTQC_RAW_DIR" \
    "${RAW_FILES[@]}"

# MultiQC for raw reads:
echo ">>> Running MultiQC on raw reads..."

multiqc \
    "$FASTQC_RAW_DIR" \
    --outdir "$MULTIQC_RAW_DIR" \
    --force

# Processing with fastp:
echo ">>> Running fastp..."
echo ">>> Removing adapters and filtering by quality and length..."

while IFS= read -r SAMPLE; do

    R1="$RAW_DIR/${SAMPLE}.R1.fastq.gz"
    R2="$RAW_DIR/${SAMPLE}.R2.fastq.gz"

    OUT_R1="$CLEAN_DIR/${SAMPLE}.R1.clean.fastq.gz"
    OUT_R2="$CLEAN_DIR/${SAMPLE}.R2.clean.fastq.gz"

    HTML_REPORT="$FASTP_REPORT_DIR/${SAMPLE}.fastp.html"
    JSON_REPORT="$FASTP_REPORT_DIR/${SAMPLE}.fastp.json"

    echo ">>> Processing $SAMPLE..."

    fastp \
        -i "$R1" \
        -I "$R2" \
        -o "$OUT_R1" \
        -O "$OUT_R2" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 15 \
        --length_required 50 \
        --thread "$THREADS" \
        --html "$HTML_REPORT" \
        --json "$JSON_REPORT" \
        --report_title "fastp report for ${SAMPLE}"

done < "$SAMPLE_LIST"

echo ">>> Processing with fastp completed."

# FastQC after processing:
echo ">>> Running FastQC on processed reads..."

fastqc \
    --threads "$THREADS" \
    --outdir "$FASTQC_CLEAN_DIR" \
    "${CLEAN_FILES[@]}"

# MultiQC after processing:
echo ">>> Running MultiQC on processed reads..."

multiqc \
    "$FASTQC_CLEAN_DIR" \
    "$FASTP_REPORT_DIR" \
    --outdir "$MULTIQC_CLEAN_DIR" \
    --force

echo ">>> RNA-Seq quality control completed successfully!"
