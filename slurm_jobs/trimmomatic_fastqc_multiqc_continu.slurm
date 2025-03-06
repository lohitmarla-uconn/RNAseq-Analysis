#!/bin/bash
#SBATCH --job-name=FastQC_MultiQC
#SBATCH --output=FastQC_MultiQC_%j.log
#SBATCH --error=FastQC_MultiQC_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=3:00:00
#SBATCH --partition=general
#SBATCH --qos=general

echo "🚀 Starting FastQC and MultiQC Pipeline..."

# Load necessary modules
module purge
module load fastqc
module load MultiQC/1.15

# Define directories
TRIMMED_DIR="/scratch/lmarla/rna_seq_data/quality_trimmed_reads_trimmomatic"
FASTQC_DIR="/scratch/lmarla/rna_seq_data/fastqc_quality_trimmed_trimmomatic"
MULTIQC_DIR="/scratch/lmarla/rna_seq_data/multiqc_quality_trimmed_trimmomatic"

# Ensure output directories exist
mkdir -p $FASTQC_DIR
mkdir -p $MULTIQC_DIR

# Get a list of all fastq files in the trimmed directory
FILES=($(ls $TRIMMED_DIR/*_R[12]_cleaned.fastq.gz))

echo "🔍 Found ${#FILES[@]} FASTQ files for FastQC analysis."

# Run FastQC in parallel using all available CPUs
echo "⚙️ Running FastQC..."
fastqc -t 16 -o $FASTQC_DIR "${FILES[@]}"

# Check if FastQC completed successfully
if [[ $? -eq 0 ]]; then
    echo "✅ FastQC completed successfully!"
else
    echo "❌ FastQC encountered an error!"
    exit 1
fi

# Run MultiQC on the FastQC reports
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

