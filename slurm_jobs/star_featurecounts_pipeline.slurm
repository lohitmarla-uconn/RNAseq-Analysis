#!/bin/bash
#SBATCH --job-name=STAR_FeatureCounts
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/STAR_FeatureCounts_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/STAR_FeatureCounts_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4  # Reduce CPU threads to avoid excessive RAM usage
#SBATCH --mem=64G  # Allocate enough RAM to prevent crashes
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load STAR
module load samtools/1.15
module load subread/2.0.1

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
GENOME_DIR="$BASE_DIR/genome_index"
READS_DIR="$BASE_DIR/quality_trimmed_reads_trimmomatic"
ALIGN_DIR="$BASE_DIR/aligned_reads_trimmomatic"
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts"
QC_DIR="$BASE_DIR/alignment_qc"

# Create output directories
mkdir -p $ALIGN_DIR $FEATURE_COUNTS_DIR $QC_DIR $BASE_DIR/logs

# Define input files
SAMPLE="K18-LCL9061_L1"
R1="$READS_DIR/${SAMPLE}_R1_cleaned.fastq.gz"
R2="$READS_DIR/${SAMPLE}_R2_cleaned.fastq.gz"
BAM_FILE="$ALIGN_DIR/${SAMPLE}_Aligned.sortedByCoord.out.bam"

# Check if input files exist
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "Error: FASTQ files not found!"
    exit 1
fi

echo ">>> Running STAR alignment for: $SAMPLE"

# Run STAR with memory optimizations
STAR --runThreadN 4 \
     --limitGenomeGenerateRAM 20000000000 \
     --genomeDir "$GENOME_DIR" \
     --readFilesIn "$R1" "$R2" \
     --readFilesCommand zcat \
     --outFileNamePrefix "$ALIGN_DIR/${SAMPLE}_" \
     --outSAMtype BAM SortedByCoordinate \
     --sjdbOverhang 99 \
     --outFilterMatchNmin 30 \
     --outFilterScoreMinOverLread 0.2 \
     --outFilterMatchNminOverLread 0.2 \
     --alignIntronMin 20 \
     --alignIntronMax 1000000 \
     --alignMatesGapMax 1000000 \
     --outSAMunmapped Within

echo ">>> STAR Alignment Completed Successfully!"

# Step 2: Quality Check of Aligned Reads Using SAMtools
echo ">>> Running Alignment Quality Check with SAMtools"

samtools flagstat $BAM_FILE > $QC_DIR/${SAMPLE}_alignment_stats.txt
samtools idxstats $BAM_FILE > $QC_DIR/${SAMPLE}_idxstats.txt
samtools view -F 4 -c $BAM_FILE > $QC_DIR/${SAMPLE}_mapped_reads_count.txt

echo ">>> Quality Check Completed!"

# Step 3: Run FeatureCounts
echo ">>> Running FeatureCounts for Gene Quantification"

featureCounts -T 4 -p -t exon -g gene_id \
-a "$GENOME_DIR/annotations.gtf" \
-o "$FEATURE_COUNTS_DIR/gene_counts.txt" \
$BAM_FILE

echo ">>> FeatureCounts Completed Successfully!"
