#!/bin/bash
#SBATCH --job-name=STAR_Alignment
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/STAR_Alignment_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/STAR_Alignment_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load STAR
module load SAMtools

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
GENOME_DIR="$BASE_DIR/genome_index"
READS_DIR="$BASE_DIR/cleaned_reads"
ALIGN_DIR="$BASE_DIR/aligned_reads"

# Create output directory
mkdir -p $ALIGN_DIR $BASE_DIR/logs

# Run STAR alignment for each sample
echo ">>> Starting STAR alignment for all samples..."
for R1 in $READS_DIR/*_R1_001.fastq_trimmed.fastq.gz; do
    base=$(basename $R1 _R1_001.fastq_trimmed.fastq.gz)
    R2="$READS_DIR/${base}_R2_001.fastq_trimmed.fastq.gz"

    # Check if R2 file exists
    if [[ ! -f "$R2" ]]; then
        echo "Skipping $base: Missing FASTQ files"
        continue
    fi

    echo ">>> Aligning sample: $base"

    STAR --runThreadN 8 \
         --genomeDir $GENOME_DIR \
         --readFilesIn "$R1" "$R2" \
         --readFilesCommand zcat \
         --outFileNamePrefix $ALIGN_DIR/${base}_ \
         --outSAMtype BAM SortedByCoordinate \
         --sjdbOverhang 99 \
         --outFilterMatchNmin 30 \
         --outFilterScoreMinOverLread 0.2 \
         --outFilterMatchNminOverLread 0.2 \
         --alignIntronMin 20 \
         --alignIntronMax 1000000 \
         --alignMatesGapMax 1000000 \
         --outSAMunmapped Within

    echo ">>> Finished aligning: $base"
done

echo ">>> STAR Alignment Completed Successfully!"

