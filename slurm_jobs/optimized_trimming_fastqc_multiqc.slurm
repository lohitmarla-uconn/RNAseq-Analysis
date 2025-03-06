#!/bin/bash
#SBATCH --job-name=RNA_Seq_Processing
#SBATCH --output=RNA_Seq_Processing.log
#SBATCH --error=RNA_Seq_Processing.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=6:00:00  # Increased time since no parallelism
#SBATCH --partition=general
#SBATCH --qos=general

echo "🚀 Starting RNA-Seq Processing Pipeline (Sequential Mode)..."

# ✅ Manually Set Java 11 (Fixes 'ExitOnOutOfMemoryError' issue)
export JAVA_HOME=$HOME/java11/jdk-11.0.26+4
export PATH=$JAVA_HOME/bin:$PATH

# ✅ Load required modules
module purge
module load Trimmomatic/0.39
module load fastqc
module load MultiQC/1.15

# ✅ Define Directories
DEDUP_DIR="/scratch/lmarla/rna_seq_data/dedup_reads"
TRIMMED_DIR="/scratch/lmarla/rna_seq_data/quality_trimmed_reads_trimmomatic"
FASTQC_DIR="/scratch/lmarla/rna_seq_data/fastqc_quality_trimmed_trimmomatic"
MULTIQC_DIR="/scratch/lmarla/rna_seq_data/multiqc_quality_trimmed_trimmomatic"

# ✅ Create Output Directories if they don't exist
mkdir -p $TRIMMED_DIR $FASTQC_DIR $MULTIQC_DIR

# ✅ Get List of Input Files (Only R1 files, process sequentially)
FILES=($(ls $DEDUP_DIR/*_R1_001.fastq_trimmed_dedup.fastq.gz))

# ✅ Process Each Sample Sequentially
for r1_file in "${FILES[@]}"; do
    # Extract Sample Name
    base=$(basename "$r1_file" _R1_001.fastq_trimmed_dedup.fastq.gz)
    r2_file="$DEDUP_DIR/${base}_R2_001.fastq_trimmed_dedup.fastq.gz"

    echo "🔬 Processing sample: $base"

    # Step 1: ✅ Run Trimmomatic
    if [[ -f "$r1_file" && -f "$r2_file" ]]; then
        echo "⚙️ Running Trimmomatic..."
        java -Xmx50G -XX:+UseParallelGC -jar /isg/shared/apps/Trimmomatic/0.39/trimmomatic-0.39.jar PE -threads 16 -phred33 \
            $r1_file \
            $r2_file \
            $TRIMMED_DIR/${base}_R1_cleaned.fastq.gz \
            $TRIMMED_DIR/${base}_R1_unpaired.fastq.gz \
            $TRIMMED_DIR/${base}_R2_cleaned.fastq.gz \
            $TRIMMED_DIR/${base}_R2_unpaired.fastq.gz \
            SLIDINGWINDOW:4:25 MINLEN:50

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

    # Step 2: ✅ Run FastQC
    echo "🔍 Running FastQC..."
    mkdir -p $FASTQC_DIR/$base
    fastqc -t 16 -o $FASTQC_DIR/$base $TRIMMED_DIR/${base}_R1_cleaned.fastq.gz $TRIMMED_DIR/${base}_R2_cleaned.fastq.gz

    echo "✅ FastQC completed for: $base"
done

# Step 3: ✅ Run MultiQC After All Samples Processed
echo "📊 Running MultiQC..."
multiqc -o $MULTIQC_DIR $FASTQC_DIR

echo "✅ MultiQC Report Generated"
echo "🎉 RNA-Seq Processing Pipeline Completed Successfully!"

