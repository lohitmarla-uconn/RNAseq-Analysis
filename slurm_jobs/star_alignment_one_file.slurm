#!/bin/bash
#SBATCH --job-name=STAR_OneFile
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/STAR_OneFile_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/STAR_OneFile_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4  # Reduce CPU threads to avoid excessive RAM usage
#SBATCH --mem=128G  # Allocate enough RAM to prevent crashes
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load STAR
module load SAMtools

# Define directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
GENOME_DIR="$BASE_DIR/genome_index"
READS_DIR="$BASE_DIR/quality_trimmed_reads_trimmomatic"
ALIGN_DIR="$BASE_DIR/aligned_reads_trimmomatic"

# Create output directory
mkdir -p $ALIGN_DIR $BASE_DIR/logs

# Define input files
SAMPLE="K18-LCL9061_L1"
R1="$READS_DIR/${SAMPLE}_R1_cleaned.fastq.gz"
R2="$READS_DIR/${SAMPLE}_R2_cleaned.fastq.gz"

# Check if input files exist
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "Error: FASTQ files not found!"
    exit 1
fi

echo ">>> Running STAR alignment for: $SAMPLE"

# Run STAR with memory optimizations
STAR --runThreadN 4 \
     --limitGenomeGenerateRAM 20000000000 \  # Limit RAM usage to 20GB
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

