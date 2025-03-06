#!/bin/bash
#SBATCH --job-name=QC_FeatureCounts
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/QC_FeatureCounts_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/QC_FeatureCounts_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load samtools
module load subread  # For featureCounts

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
ALIGN_DIR="$BASE_DIR/aligned_reads"
QC_DIR="$BASE_DIR/alignment_qc_all"
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts_all"
GTF_FILE="/scratch/lmarla/rna_seq_data/genom_data/ncbi_dataset/data/GCF_000001635.27/genomic.gtf"

# Create necessary directories
mkdir -p $QC_DIR $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Step 1: Run SAMtools QC on all BAM files
echo "📊 Running SAMtools Quality Check on all BAM files..."

for BAM in $ALIGN_DIR/*.bam; do
    SAMPLE=$(basename $BAM _Aligned.sortedByCoord.out.bam)
    
    echo "📝 Processing QC for: $SAMPLE"

    samtools flagstat $BAM > $QC_DIR/${SAMPLE}_alignment_stats.txt
    samtools idxstats $BAM > $QC_DIR/${SAMPLE}_idxstats.txt

    echo "✅ QC Completed for: $SAMPLE"
done

echo "📊 SAMtools QC Completed for All Samples!"

# Step 2: Run FeatureCounts on all BAM files
echo "📊 Running FeatureCounts on all BAM files..."

featureCounts -T 8 -p -t exon -g gene_id \
-a $GTF_FILE \
-o $FEATURE_COUNTS_DIR/gene_counts.txt \
$ALIGN_DIR/*.bam

echo "✅ FeatureCounts Completed for All Samples!"

