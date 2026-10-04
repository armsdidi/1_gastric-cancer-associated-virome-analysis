#!/bin/bash

# ============================================================
# TAXONOMIC CLASSIFICATION WITH Kraken2
# ============================================================

# Stop the script if an error occurs:
set -euo pipefail

# Number of threads:
THREADS=8

# Directories:
BASE_DIR="$(pwd)"
NONHUMAN_DIR="$BASE_DIR/FASTQ/NON-HUMAN_FASTQ"
REP_DIR="$BASE_DIR/KRAKEN_REPORTS"
KRAKEN_DB="$BASE_DIR/DATABASES/KRAKEN2/kraken_db"
SAMPLE_LIST="$BASE_DIR/all_sample.txt"

# Create the output directory:
mkdir -p "$REP_DIR"

# Create the sample list:
echo ">>> Creating the sample list..."

find "$NONHUMAN_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.nonhuman_R1.fastq.gz" \
    -exec basename {} \; \
    | sed 's/\.nonhuman_R1\.fastq\.gz$//' \
    | sort -u \
    > "$SAMPLE_LIST"

# Check whether samples are available:
if [ ! -s "$SAMPLE_LIST" ]; then
    echo "ERROR: no samples found in $NONHUMAN_DIR" >&2
    exit 1
fi

echo ">>> Number of samples: $(wc -l < "$SAMPLE_LIST")"

# Check paired-end files before processing:
while IFS= read -r SAMPLE; do

    R1="$NONHUMAN_DIR/${SAMPLE}.nonhuman_R1.fastq.gz"
    R2="$NONHUMAN_DIR/${SAMPLE}.nonhuman_R2.fastq.gz"

    if [ ! -s "$R1" ] || [ ! -s "$R2" ]; then
        echo "ERROR: R1 or R2 file missing or empty for $SAMPLE" >&2
        exit 1
    fi

done < "$SAMPLE_LIST"

# Perform taxonomic classification:
echo ">>> Starting classification with Kraken2..."

while IFS= read -r SAMPLE; do

    echo ">>> Processing: $SAMPLE"

    kraken2 \
        --threads "$THREADS" \
        --db "$KRAKEN_DB" \
        --report "$REP_DIR/${SAMPLE}.report" \
        --output "$REP_DIR/${SAMPLE}.kraken" \
        --use-names \
        --gzip-compressed \
        --paired \
        "$NONHUMAN_DIR/${SAMPLE}.nonhuman_R1.fastq.gz" \
        "$NONHUMAN_DIR/${SAMPLE}.nonhuman_R2.fastq.gz" \
        2> "$REP_DIR/${SAMPLE}.kraken2.log"

    echo ">>> Completed: $SAMPLE"

done < "$SAMPLE_LIST"

echo ">>> Taxonomic classification completed successfully!"
