import pandas as pd
import os

# Load and Simulate Gene Expression Data
k16 = pd.read_csv(r"C:\Users\lohit marla\Documents\RNAseq-Analysis\data\gene_counts_all.csv", skiprows=1)
w16 = pd.read_csv(r"C:\Users\lohit marla\Documents\RNAseq-Analysis\data\gene_counts_k10.csv", skiprows=1)

# Merge on 'Geneid'
join_table = k16.merge(w16, on="Geneid")

# Drop columns ending with '_y'
join_table = join_table.loc[:, ~join_table.columns.str.endswith('_y')]

# Rename BAM file path columns to sample names
def extract_sample_name(col_name):
    col_name = col_name.replace('_x', '')
    if col_name.startswith('/scratch/lmarla/rna_seq_data/aligned_reads/'):
        return col_name.split('/')[-1].split('-')[0]  # Extracts W3 from the filename
    if "K10-LCL9055_L1_Aligned.sortedByCoord.out.bam" in col_name:
        return "K10"  # Rename specifically if needed
    return col_name  # Keep other column names unchanged

join_table.columns = [extract_sample_name(col) for col in join_table.columns]

# Select only required columns
selected_columns = ['Geneid', 'Chr', 'Start', 'End', 'Strand', 'Length'] + [
    col for col in join_table.columns if col not in ['Geneid', 'Chr', 'Start', 'End', 'Strand', 'Length']
]

join_table = join_table[selected_columns]

# Print updated column names
print(join_table.columns)

print(join_table.head())

# Write the final RNA-Seq counts matrix to a CSV file
output_file = r"C:\Users\lohit marla\Documents\RNAseq-Analysis\data\rna_seq_counts_matrix.csv"
join_table.to_csv(output_file, index=False)
