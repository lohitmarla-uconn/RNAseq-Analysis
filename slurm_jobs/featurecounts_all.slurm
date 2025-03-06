#!/bin/bash
#SBATCH --job-name=featureCounts
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/featureCounts_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/featureCounts_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load subread  # Provides featureCounts

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
ALIGN_DIR="$BASE_DIR/aligned_reads"
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts_all"
GTF_FILE="/scratch/lmarla/rna_seq_data/genom_data/ncbi_dataset/data/GCF_000001635.27/genomic.gtf"

# Create necessary directories
mkdir -p $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Run featureCounts on all BAM files
echo "Running featureCounts on all BAM files..."

featureCounts -T 8 -p -t exon -g gene_id \
-a $GTF_FILE \
-o $FEATURE_COUNTS_DIR/gene_counts.txt \
$ALIGN_DIR/*.bam

echo "featureCounts Completed for All Samples!"
