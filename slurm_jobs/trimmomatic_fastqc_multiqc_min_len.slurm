#!/bin/bash
#SBATCH --job-name=Trimmomatic_FastQC_MultiQC
#SBATCH --output=Trimmomatic_FastQC_MultiQC_%A.log
#SBATCH --error=Trimmomatic_FastQC_MultiQC_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=6:00:00
#SBATCH --partition=general
#SBATCH --qos=general

echo "🚀 Starting Further Trimmomatic Processing + FastQC + MultiQC Pipeline..."

# Load necessary modules
module purge
module load java/11.0.11
module load Trimmomatic/0.39
module load fastqc
module load MultiQC/1.15

# Define directories
TRIMMED_INPUT_DIR="/scratch/lmarla/rna_seq_data/quality_trimmed_reads"  # Pre-trimmed reads
FINAL_TRIMMED_DIR="/scratch/lmarla/rna_seq_data/final_trimmed_reads_trimmomatic_min_len"  # Further processed reads
FASTQC_DIR="/scratch/lmarla/rna_seq_data/fastqc_final_trimmed_min"
MULTIQC_DIR="/scratch/lmarla/rna_seq_data/multiqc_final_trimmed_min"

# Create output directories if they don't exist
mkdir -p $FINAL_TRIMMED_DIR
mkdir -p $FASTQC_DIR
mkdir -p $MULTIQC_DIR

# Get all R1 files from pre-trimmed reads
FILES=($(ls $TRIMMED_INPUT_DIR/*_R1_cleaned.fastq.gz))

echo "🔍 Found ${#FILES[@]} pre-trimmed samples for further processing."

# Process each sample sequentially
for r1_file in "${FILES[@]}"; do
    base=$(basename "$r1_file" _R1_cleaned.fastq.gz)
    r2_file="$TRIMMED_INPUT_DIR/${base}_R2_cleaned.fastq.gz"

    echo "⚙️ Processing sample: $base"

    # Step 1: Run Further Trimmomatic Processing
    if [[ -f "$r1_file" && -f "$r2_file" ]]; then
        echo "✂️ Running Trimmomatic on $base..."
        java -Xmx50G -XX:+UseParallelGC -jar /isg/shared/apps/Trimmomatic/0.39/trimmomatic-0.39.jar PE -threads 16 -phred33 \
            $r1_file \
            $r2_file \
            $FINAL_TRIMMED_DIR/${base}_R1_final.fastq.gz \
            $FINAL_TRIMMED_DIR/${base}_R1_unpaired_final.fastq.gz \
            $FINAL_TRIMMED_DIR/${base}_R2_final.fastq.gz \
            $FINAL_TRIMMED_DIR/${base}_R2_unpaired_final.fastq.gz \
            SLIDINGWINDOW:4:25 MINLEN:50 HEADCROP:5 CROP:90

        if [[ $? -eq 0 ]]; then
            echo "✅ Trimmomatic completed for: $base"
        else
            echo "❌ Trimmomatic failed for: $base"
            exit 1
        fi
    else
        echo "⚠️ Skipping $base: One or both paired-end files are missing!"
        exit 1
    fi

    # Step 2: Run FastQC on further processed reads
    echo "📊 Running FastQC for: $base"
    fastqc -t 16 -o $FASTQC_DIR $FINAL_TRIMMED_DIR/${base}_R1_final.fastq.gz $FINAL_TRIMMED_DIR/${base}_R2_final.fastq.gz

    echo "✅ FastQC completed for: $base"
done

# Step 3: Run MultiQC on FastQC reports
echo "📊 Running MultiQC on FastQC reports..."
multiqc -o $MULTIQC_DIR $FASTQC_DIR

echo "✅ MultiQC report generated successfully!"
echo "🎉 Trimmomatic Further Processing + FastQC + MultiQC Pipeline Completed Successfully!"

