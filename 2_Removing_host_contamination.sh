#!/bin/bash

# ============================================================
# HUMAN READ REMOVAL WITH Bowtie2
# ============================================================

# Stop the script if an error occurs:
set -euo pipefail

# Number of threads:
THREADS=8

# Directories:
BASE_DIR="$(pwd)"
CLEAN_DIR="$BASE_DIR/FASTQ/CLEAN_FASTQ"
NONHUMAN_DIR="$BASE_DIR/FASTQ/NON-HUMAN_FASTQ"
LOG_DIR="$BASE_DIR/QC/Bowtie2"
BOWTIE_INDEX="$BASE_DIR/DATABASES/BOWTIE2/hg38"
SAMPLE_LIST="$BASE_DIR/all_sample.txt"

# Create directories:
mkdir -p "$LOG_DIR"

# Create the sample list:
echo ">>> Creating the sample list..."

find "$CLEAN_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.R1.clean.fastq.gz" \
    -exec basename {} \; \
    | sed 's/\.R1\.clean\.fastq\.gz$//' \
    | sort -u \
    > "$SAMPLE_LIST"

# Check whether samples are available:
if [ ! -s "$SAMPLE_LIST" ]; then
    echo "ERROR: no samples found in $CLEAN_DIR" >&2
    exit 1
fi

echo ">>> Number of samples: $(wc -l < "$SAMPLE_LIST")"

# Check paired-end files before processing:
while IFS= read -r SAMPLE; do

    R1="$CLEAN_DIR/${SAMPLE}.R1.clean.fastq.gz"
    R2="$CLEAN_DIR/${SAMPLE}.R2.clean.fastq.gz"

    if [ ! -s "$R1" ] || [ ! -s "$R2" ]; then
        echo "ERROR: R1 or R2 file missing or empty for $SAMPLE" >&2
        exit 1
    fi

done < "$SAMPLE_LIST"

# Start human read removal:
echo ">>> Starting human read removal..."

while IFS= read -r SAMPLE; do

    echo ">>> Processing: $SAMPLE"

    # Aligning reads against the human genome and retaining unmapped paired-end reads:
    bowtie2 \
        -x "$BOWTIE_INDEX" \
        -1 "$CLEAN_DIR/${SAMPLE}.R1.clean.fastq.gz" \
        -2 "$CLEAN_DIR/${SAMPLE}.R2.clean.fastq.gz" \
        -p "$THREADS" \
        --very-sensitive \
        --un-conc-gz "$NONHUMAN_DIR/${SAMPLE}.nonhuman_R%.fastq.gz" \
        -S /dev/null \
        2> "$LOG_DIR/${SAMPLE}.bowtie2.log"

    echo ">>> Completed: $SAMPLE"

done < "$SAMPLE_LIST"

echo ">>> Processing with Bowtie2 completed successfully!"
