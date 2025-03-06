#!/bin/bash
#SBATCH --job-name=RNASeq_Pipeline
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/RNASeq_Pipeline_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/RNASeq_Pipeline_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load STAR
module load SAMtools
module load Subread  # For featureCounts

# Define base directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
GENOME_DIR="$BASE_DIR/genome_index"
GENOME_FASTA="$BASE_DIR/genom_data/ncbi_dataset/data/GCF_000001635.27/GCF_000001635.27_GRCm39_genomic.fna"
GENOME_GTF="$BASE_DIR/genom_data/ncbi_dataset/data/GCF_000001635.27/genomic.gtf"
READS_DIR="$BASE_DIR/dedup_reads"
ALIGN_DIR="$BASE_DIR/aligned_reads"
QC_DIR="$BASE_DIR/alignment_qc"
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts"

# Create necessary directories
mkdir -p $GENOME_DIR $ALIGN_DIR $QC_DIR $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Step 1: Index Genome
echo ">>> Step 1: Indexing Genome with STAR"
STAR --runThreadN 16 \
     --runMode genomeGenerate \
     --genomeDir $GENOME_DIR \
     --genomeFastaFiles $GENOME_FASTA \
     --sjdbGTFfile $GENOME_GTF \
     --sjdbOverhang 99

# Step 2: Align Reads with STAR
echo ">>> Step 2: Aligning Reads with STAR"
for sample in $READS_DIR/*_R1_final.fastq.gz; do
    base=$(basename $sample _R1_final.fastq.gz)
    R1="$READS_DIR/${base}_R1_final.fastq.gz"
#!/bin/bash
#SBATCH --job-name=RNASeq_Pipeline
#SBATCH --output=/scratch/lmarla/rna_seq_data/logs/RNASeq_Pipeline_%A.log
#SBATCH --error=/scratch/lmarla/rna_seq_data/logs/RNASeq_Pipeline_%A.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

# Load required modules
module load STAR
module load SAMtools
module load Subread  # For featureCounts

# Define base directories
BASE_DIR="/scratch/lmarla/rna_seq_data"
GENOME_DIR="$BASE_DIR/genome_index"
GENOME_FASTA="$BASE_DIR/genom_data/ncbi_dataset/data/GCF_000001635.27/GCF_000001635.27_GRCm39_genomic.fna"
GENOME_GTF="$BASE_DIR/genom_data/ncbi_dataset/data/GCF_000001635.27/genomic.gtf"
READS_DIR="$BASE_DIR/quality_trimmed_reads"
ALIGN_DIR="$BASE_DIR/aligned_reads"
QC_DIR="$BASE_DIR/alignment_qc"
FEATURE_COUNTS_DIR="$BASE_DIR/feature_counts"

# 🚨 Cleanup: Remove previous intermediate files (to prevent conflicts)
echo ">>> Cleaning up old outputs before rerunning the pipeline..."
rm -rf $GENOME_DIR/*  # Remove previous genome index
rm -rf $ALIGN_DIR/*    # Remove previous alignment files
rm -rf $QC_DIR/*       # Remove previous quality check files
rm -rf $FEATURE_COUNTS_DIR/*  # Remove previous feature counts

# 🚀 Create fresh directories
mkdir -p $GENOME_DIR $ALIGN_DIR $QC_DIR $FEATURE_COUNTS_DIR $BASE_DIR/logs

# Step 1: Index Genome
echo ">>> Step 1: Indexing Genome with STAR"
STAR --runThreadN 16 \
     --runMode genomeGenerate \
     --genomeDir $GENOME_DIR \
     --genomeFastaFiles $GENOME_FASTA \
     --sjdbGTFfile $GENOME_GTF \
     --sjdbOverhang 99

# Step 2: Align Reads with STAR
echo ">>> Step 2: Aligning Reads with STAR"
for sample in $READS_DIR/*_R1_final.fastq.gz; do
    base=$(basename $sample _R1_final.fastq.gz)
    R1="$READS_DIR/${base}_R1_final.fastq.gz"
    R2="$READS_DIR/${base}_R2_final.fastq.gz"

    STAR --runThreadN 16 \
         --genomeDir $GENOME_DIR \
         --readFilesIn $R1 $R2 \
         --readFilesCommand zcat \
         --outFileNamePrefix $ALIGN_DIR/${base}_ \
         --outSAMtype BAM SortedByCoordinate
done

# Step 3: Quality Check Aligned Reads
echo ">>> Step 3: Checking Alignment Quality with SAMtools"
for bam in $ALIGN_DIR/*_Aligned.sortedByCoord.out.bam; do
    base=$(basename $bam _Aligned.sortedByCoord.out.bam)

    samtools flagstat $bam > $QC_DIR/${base}_alignment_stats.txt
    samtools idxstats $bam > $QC_DIR/${base}_idxstats.txt
    samtools view -F 4 -c $bam > $QC_DIR/${base}_mapped_reads_count.txt
done

# Step 4: Count Features with featureCounts
echo ">>> Step 4: Counting Features with featureCounts"
featureCounts -T 16 -p -t exon -g gene_id \
-a $GENOME_GTF \
-o $FEATURE_COUNTS_DIR/gene_counts.txt \
$ALIGN_DIR/*.bam

echo ">>> RNA-Seq Pipeline Completed Successfully"

