#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --output=multiqc_%j.log
#SBATCH --error=multiqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=1:00:00
#SBATCH --partition=general
#SBATCH --qos=general

module load MultiQC/1.12  # Load MultiQC module (if available)

# Define directories
FASTQC_DIR="/scratch/lmarla/rna_seq_data/fastqc_reports/"
MULTIQC_OUTPUT="/scratch/lmarla/rna_seq_data/multiqc_reports"

# Create output directory if not exists
mkdir -p $MULTIQC_OUTPUT

# Run MultiQC
multiqc -o $MULTIQC_OUTPUT $FASTQC_DIR

echo "MultiQC analysis complete! Reports stored in $MULTIQC_OUTPUT"

