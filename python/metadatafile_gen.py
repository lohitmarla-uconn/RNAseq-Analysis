import pandas as pd

# Define the metadata
data = {
    'sampleid': ['K12', 'K13', 'K15', 'K16', 'K17', 'K18', 'K19', 'K20', 'K21', 'K6', 'K7', 'K8', 'K9',
                 'W10', 'W11', 'W12', 'W16', 'W17', 'W18', 'W19', 'W1', 'W20', 'W2', 'W3', 'W4', 'W6', 'W8', 'K10'],
    'size': ['large', 'large', 'large', 'large', 'large', 'large', 'large', 'large', 'large', 'small', 'small', 'small', 'small',
             'large', 'large', 'large', 'large', 'large', 'large', 'large', 'small', 'large', 'small', 'small', 'small', 'small', 'small', 'large'],
    'type': ['KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT', 'KT',
             'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'WT', 'KT']
}

# Create a DataFrame
metadata_df = pd.DataFrame(data)

# Set 'SampleID' as the index
metadata_df.set_index('sampleid', inplace=True)

# Save the DataFrame to a CSV file
metadata_df.to_csv(r'C:\Users\lohit marla\Documents\RNAseq-Analysis\conf\metadata.csv')
