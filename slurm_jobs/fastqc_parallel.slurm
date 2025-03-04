#!/bin/bash
#SBATCH --job-name=fastqc_analysis
#SBATCH --output=fastqc_%j.log
#SBATCH --error=fastqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8  # Adjust based on available resources
#SBATCH --mem=32G  # Adjust if needed
#SBATCH --time=4:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load FastQC module
module load fastqc/0.12.1
module load parallel 

# Define directories
DATA_DIR="/scratch/lmarla/rna_seq_data/cleaned_reads"
REPORT_DIR="/scratch/lmarla/rna_seq_data/fastqc_reports"

# Create output directory if it doesn't exist
mkdir -p $REPORT_DIR

echo "Running FastQC on all W*, K*, and *.fastq-011 files..."

# Find all matching FASTQ files and run FastQC in parallel
find $DATA_DIR -type f \( -name "W*.fastq.gz" -o -name "K*.fastq.gz" -o -name "*.fastq-011" \) | parallel -j 8 "fastqc -o $REPORT_DIR {}"

#find $DATA_DIR -type f \( -name "K10-LCL9055_L1_R1_001.fastq" \) | parallel -j 8 "fastqc -o $REPORT_DIR {}"
echo "FastQC analysis complete. Reports are stored in $REPORT_DIR"

