#!/bin/bash
#SBATCH --job-name=unzip_parallel
#SBATCH --output=unzip_%j.log
#SBATCH --error=unzip_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16  # Adjust based on available cores
#SBATCH --mem=64G  # Adjust based on file sizes
#SBATCH --time=4:00:00  # Adjust based on estimated decompression time
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load pigz  # Multi-threaded gzip
module load parallel  # GNU Parallel for running jobs in parallel

# Define the working directory
DATA_DIR="/scratch/lmarla/rna_seq_data"

# Move to the data directory
cd $DATA_DIR

echo "Starting parallel decompression of .gz files..."
# Parallelly decompress .gz files using pigz
ls *.fastq.gz 2>/dev/null | parallel -j 8 "pigz -d {}"

echo "Starting parallel extraction of .zip files..."
# Parallelly unzip all .zip files
ls *.zip 2>/dev/null | parallel -j 4 "unzip -o {} -d $DATA_DIR"

echo "Decompression complete!"

