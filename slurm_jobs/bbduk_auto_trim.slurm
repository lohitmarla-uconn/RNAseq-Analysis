#!/bin/bash
#SBATCH --job-name=bbduk_trim
#SBATCH --output=bbduk_trim_%j.log
#SBATCH --error=bbduk_trim_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=4:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load BBMap module (which includes bbduk.sh)
module load bbmap

# Define input and output directories
INPUT_DIR="/scratch/lmarla/rna_seq_data/raw_data/"
OUTPUT_DIR="/scratch/lmarla/rna_seq_data/cleaned_reads/"

# Create output directory if not exists
mkdir -p $OUTPUT_DIR

echo "Starting BBDuk adapter trimming..."

# Run BBDuk on each FASTQ file
for file in $INPUT_DIR/*.fastq; do
    filename=$(basename "$file" .fastq.gz)
    
    bbduk.sh in=$file \
             out=$OUTPUT_DIR/${filename}_trimmed.fastq.gz \
             ref=adapters \
             ktrim=r k=23 mink=11 hdist=1 \
             tpe tbo \
             qtrim=r trimq=20 minlen=50
done

echo "BBDuk trimming complete. Cleaned files are in $OUTPUT_DIR"

