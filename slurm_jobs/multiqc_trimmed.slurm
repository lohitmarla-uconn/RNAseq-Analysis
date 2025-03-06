#!/bin/bash
#SBATCH --job-name=multiqc_trimmed
#SBATCH --output=multiqc_trimmed_%j.log
#SBATCH --error=multiqc_trimmed_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=1:00:00
#SBATCH --partition=general
#SBATCH --qos=general


# Load MultiQC (if installed locally)

module load python/3.8.1
module load MultiQC/1.15
module load openssl/1.1.1
export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64:/isg/shared/apps/openssl/1.1.1/lib:$LD_LIBRARY_PATH

# Define directories
TRIMMED_FASTQ_DIR="/scratch/lmarla/rna_seq_data/trimmed_fastq"
MULTIQC_OUTPUT="/scratch/lmarla/rna_seq_data/multiqc_trimmed_reports"

# Generate a unique report name using the SLURM Job ID
REPORT_NAME="multiqc_report_trimmed"

# Run MultiQC and store the report with a unique name
multiqc -o $MULTIQC_OUTPUT/$REPORT_NAME $TRIMMED_FASTQ_DIR

echo "MultiQC analysis complete! Report stored as $MULTIQC_OUTPUT/$REPORT_NAME.html"

