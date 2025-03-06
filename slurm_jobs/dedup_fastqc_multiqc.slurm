#!/bin/bash
#SBATCH --job-name=dedup_fastqc_multiqc
#SBATCH --output=dedup_fastqc_multiqc_%j.log
#SBATCH --error=dedup_fastqc_multiqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --partition=general
#SBATCH --qos=general

echo "Starting deduplication, FastQC, and MultiQC workflow..."

# Load necessary modules
module load bbmap
module load fastqc
module load MultiQC/1.15

# Define directories
TRIMMED_DIR="/scratch/lmarla/rna_seq_data/cleaned_reads"
DEDUP_DIR="/scratch/lmarla/rna_seq_data/dedup_reads"
FASTQC_DIR="/scratch/lmarla/rna_seq_data/fastqc_dedup_reports"
MULTIQC_DIR="/scratch/lmarla/rna_seq_data/multiqc_dedup_reports"

# Ensure output directories exist
mkdir -p $DEDUP_DIR
mkdir -p $FASTQC_DIR
mkdir -p $MULTIQC_DIR

echo "Step 1: Checking input files..."
ls -lh $TRIMMED_DIR/*.fastq.gz

echo "Step 2: Removing PCR duplicates with clumpify.sh..."
for file in $TRIMMED_DIR/*.fastq.gz; do
    filename=$(basename "$file" .fastq.gz)
    clumpify.sh in="$file" out="$DEDUP_DIR/${filename}_dedup.fastq.gz" dedupe
done

echo "Step 3: Running FastQC on deduplicated reads..."
fastqc -o $FASTQC_DIR $DEDUP_DIR/*.fastq.gz

echo "Step 4: Generating MultiQC report..."
multiqc -o $MULTIQC_DIR $FASTQC_DIR

echo "Pipeline completed successfully! Reports stored in $MULTIQC_DIR"

