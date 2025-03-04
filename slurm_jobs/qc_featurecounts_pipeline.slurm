#!/bin/bash
#SBATCH --job-name=QC_FeatureCounts
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/QC_FeatureCounts_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/QC_FeatureCounts_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4  # Optimize for general cluster use
#SBATCH --mem=32G  # Reduce memory usage as STAR is skipped
#SBATCH --time=6:00:00  # Shorter job since alignment is already done
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load samtools/1.9
module load subread/2.0  # FeatureCounts

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
ALIGN_DIR="$BASE_DIR/aligned_reads"  # BAM files already created
QC_DIR="$BASE_DIR/alignment_qc"  # QC results directory
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts"  # FeatureCounts output directory
GENOME_DIR="$BASE_DIR/genome_index"

# Create necessary output directories
mkdir -p $QC_DIR $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Run SAMtools Quality Check on all BAM files
echo ">>> Running Alignment Quality Check with SAMtools"

for BAM_FILE in $ALIGN_DIR/*_Aligned.sortedByCoord.out.bam; do
    SAMPLE=$(basename $BAM_FILE _Aligned.sortedByCoord.out.bam)

    echo ">>> Processing: $SAMPLE"

    samtools flagstat $BAM_FILE > $QC_DIR/${SAMPLE}_alignment_stats.txt
    samtools idxstats $BAM_FILE > $QC_DIR/${SAMPLE}_idxstats.txt
    samtools view -F 4 -c $BAM_FILE > $QC_DIR/${SAMPLE}_mapped_reads_count.txt
done

echo ">>> Quality Check Completed!"

# Run FeatureCounts on all BAM files
echo ">>> Running FeatureCounts for Gene Quantification"

featureCounts -T 4 -p -t exon -g gene_id \
-a "$GENOME_DIR/annotations.gtf" \
-o "$FEATURE_COUNTS_DIR/gene_counts.txt" \
$ALIGN_DIR/*.bam

echo ">>> FeatureCounts Completed Successfully!"

