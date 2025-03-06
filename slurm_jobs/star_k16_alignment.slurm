#!/bin/bash
#SBATCH --job-name=STAR_K16
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/K16_STAR_FeatureCounts_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/K16_STAR_FeatureCounts_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load STAR
module load samtools
module load subread  # FeatureCounts

# Define base directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
GENOME_DIR="$BASE_DIR/genome_index"
READS_DIR="$BASE_DIR/final_trimmed_reads_trimmomatic_min_len"
OUTPUT_DIR="$BASE_DIR/aligned_reads_K16"  # New folder for output
QC_DIR="$BASE_DIR/alignment_qc_K16"  # Separate folder for QC
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts_K16"  # Separate FeatureCounts output

# Create necessary directories
mkdir -p $OUTPUT_DIR $QC_DIR $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Define input files
SAMPLE="K10-LCL9055_L1" 
R1="$READS_DIR/${SAMPLE}_R1_final.fastq.gz"
R2="$READS_DIR/${SAMPLE}_R2_final.fastq.gz"
BAM_FILE="$OUTPUT_DIR/${SAMPLE}_Aligned.sortedByCoord.out.bam"

# Check if input files exist
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "❌ Error: FASTQ files not found!"
    exit 1
fi

echo ">>> Running STAR alignment for: $SAMPLE"

# Run STAR Alignment
STAR --runThreadN 8 \
     --genomeDir "$GENOME_DIR" \
     --readFilesIn "$R1" "$R2" \
     --readFilesCommand zcat \
     --outFileNamePrefix "$OUTPUT_DIR/${SAMPLE}_" \
     --outSAMtype BAM SortedByCoordinate \
     --sjdbOverhang 99 \
     --outFilterMatchNmin 30 \
     --outFilterScoreMinOverLread 0.2 \
     --outFilterMatchNminOverLread 0.2 \
     --alignIntronMin 20 \
     --alignIntronMax 1000000 \
     --alignMatesGapMax 1000000 \
     --outSAMunmapped Within

echo "✅ STAR Alignment Completed for $SAMPLE!"

# Step 2: Perform Quality Check using SAMtools
echo "📊 Running Alignment Quality Check with SAMtools"

samtools flagstat $BAM_FILE > $QC_DIR/${SAMPLE}_alignment_stats.txt
samtools idxstats $BAM_FILE > $QC_DIR/${SAMPLE}_idxstats.txt
samtools view -F 4 -c $BAM_FILE > $QC_DIR/${SAMPLE}_mapped_reads_count.txt

echo "✅ Quality Check Completed!"

# Step 3: Run FeatureCounts
echo "📊 Running FeatureCounts for Gene Quantification"

featureCounts -T 8 -p -t exon -g gene_id \
-a "$GENOME_DIR/annotations.gtf" \
-o "$FEATURE_COUNTS_DIR/gene_counts.txt" \
$BAM_FILE

echo "✅ FeatureCounts Completed Successfully!"

