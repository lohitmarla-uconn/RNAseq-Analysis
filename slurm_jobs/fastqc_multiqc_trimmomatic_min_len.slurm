#!/bin/bash
#SBATCH --job-name=FastQC_MultiQC_Final
#SBATCH --output=FastQC_MultiQC_Final_%A.log
#SBATCH --error=FastQC_MultiQC_Final_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=3:00:00
#SBATCH --partition=general
#SBATCH --qos=general

echo "🚀 Running FastQC & MultiQC on Final Trimmomatic Processed Reads..."

# Load necessary modules
module purge
module load fastqc
module load MultiQC/1.15

# Define directories
FINAL_TRIMMED_DIR="/scratch/lmarla/rna_seq_data/final_trimmed_reads_trimmomatic_min_len"  # Final processed reads
FASTQC_DIR="/scratch/lmarla/rna_seq_data/fastqc_final_trimmed_min_len"
MULTIQC_DIR="/scratch/lmarla/rna_seq_data/multiqc_final_trimmed_min_len"

# Create output directories if they don't exist
mkdir -p $FASTQC_DIR
mkdir -p $MULTIQC_DIR

# Get all _final.fastq.gz files
FILES=($(ls $FINAL_TRIMMED_DIR/*_final.fastq.gz))

echo "🔍 Found ${#FILES[@]} final trimmed FASTQ files for analysis."

# Step 1: Run FastQC on all final trimmed files
echo "📊 Running FastQC..."
#fastqc -t 16 -o $FASTQC_DIR "${FILES[@]}"

# Check if FastQC completed successfully
#if [[ $? -eq 0 ]]; then
#    echo "✅ FastQC completed successfully!"
#else
#    echo "❌ FastQC encountered an error!"
#    exit 1
#fi

# Step 2: Run MultiQC on FastQC reports
echo "📊 Running MultiQC..."
multiqc -o $MULTIQC_DIR $FASTQC_DIR

# Check if MultiQC completed successfully
if [[ $? -eq 0 ]]; then
    echo "✅ MultiQC report generated successfully!"
else
    echo "❌ MultiQC encountered an error!"
    exit 1
fi

echo "🎉 FastQC & MultiQC Pipeline Completed Successfully!"

