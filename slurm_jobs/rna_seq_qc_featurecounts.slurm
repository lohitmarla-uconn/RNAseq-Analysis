#!/bin/bash
#SBATCH --job-name=RNASeq_QC_FeatureCounts
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/RNASeq_QC_FeatureCounts_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/RNASeq_QC_FeatureCounts_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load SAMtools
module load Subread  # For FeatureCounts

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
ALIGN_DIR="$BASE_DIR/aligned_reads"  # STAR output
QC_DIR="$BASE_DIR/alignment_qc"
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts"
GENOME_DIR="$BASE_DIR/genome_index"

# Create necessary directories
mkdir -p $QC_DIR $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Remove old QC and feature count files if they exist
echo ">>> Cleaning up old QC and feature count files..."
rm -f $QC_DIR/*.txt
rm -f $FEATURE_COUNTS_DIR/gene_counts.txt

# Step 1: Quality Check of Aligned Reads Using SAMtools
echo ">>> Checking Alignment Quality with SAMtools"
for bam in $ALIGN_DIR/*_Aligned.sortedByCoord.out.bam; do
    base=$(basename $bam _Aligned.sortedByCoord.out.bam)

    samtools flagstat $bam > $QC_DIR/${base}_alignment_stats.txt
    samtools idxstats $bam > $QC_DIR/${base}_idxstats.txt
    samtools view -F 4 -c $bam > $QC_DIR/${base}_mapped_reads_count.txt
done

# Step 2: Count Features Using FeatureCounts
echo ">>> Counting Features with FeatureCounts"
featureCounts -T 8 -p -t exon -g gene_id \
-a $GENOME_DIR/annotations.gtf \
-o $FEATURE_COUNTS_DIR/gene_counts.txt \
$ALIGN_DIR/*.bam

echo ">>> RNA-Seq QC and Feature Counting Completed Successfully!"

