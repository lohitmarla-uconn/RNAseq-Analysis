import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pydeseq2.dds import DeseqDataSet  # Correct import statement
import re

# Load gene expression data
counts_df = pd.read_csv(r'C:\Users\lohit marla\Documents\RNAseq-Analysis\data\rna_seq_counts_matrix.csv', index_col=0)

# Load metadata
metadata_df = pd.read_csv(r'C:\Users\lohit marla\Documents\RNAseq-Analysis\conf\metadata.csv', index_col=0)

# Ensure 'type' column in metadata is a factor
metadata_df['type'] = metadata_df['type'].astype('category')

def is_unwanted_gene(gene_name):
    # Check for unwanted prefixes
    if re.match(r'^(GM|gm|Gm|IG|ig|Ig)', gene_name):
        return True
    # Check for unwanted suffix
    if gene_name.lower().endswith('rik'):
        return True
    return False

# Apply the function to filter out unwanted genes
filtered_counts_df = counts_df[~counts_df.index.to_series().apply(is_unwanted_gene)]

# Initialize DESeq2 object
dds = DeseqDataSet(
    counts=filtered_counts_df,
    metadata=metadata_df,
    design="~ type",
    control_genes="Geneid"
)

# Run DESeq2 analysis
dds.run_deseq()

# Get results
res_df = dds.get_results()

# Filter significant genes
alpha = 0.05
log2_fc_threshold = 1.0
significant_genes_df = res_df[
    (res_df['padj'] < alpha) &
    (abs(res_df['log2FoldChange']) >= log2_fc_threshold)
]

# Plot settings
plt.figure(figsize=(10, 6))
sns.scatterplot(
    x=res_df['log2FoldChange'],
    y=-np.log10(res_df['padj']),
    hue=res_df.index.isin(significant_genes_df.index),
    palette={True: 'red', False: 'blue'},
    legend=False
)
plt.xlabel('Log2 Fold Change')
plt.ylabel('-Log10 Adjusted P-Value')
plt.title('Volcano Plot of Differential Expression')
plt.axhline(-np.log10(alpha), linestyle='--', color='grey')
plt.axvline(log2_fc_threshold, linestyle='--', color='grey')
plt.axvline(-log2_fc_threshold, linestyle='--', color='grey')
plt.show()