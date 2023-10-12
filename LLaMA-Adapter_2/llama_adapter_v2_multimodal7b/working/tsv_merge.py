import pandas as pd

# List of your tsv files
files = ['tagwalk_caption_1000.tsv', 'tagwalk_caption_3000.tsv', 'tagwalk_caption_5000.tsv', 
         'tagwalk_caption_7500.tsv', 'tagwalk_caption_10000.tsv', 'tagwalk_caption_12975.tsv']

# Create a list to hold dataframes
df_list = []

# Read each file and append it to the df_list
for file in files:
    df = pd.read_csv(file, sep='\t')
    df_list.append(df)

# Concatenate all dataframes in the df_list
merged_df = pd.concat(df_list)

# Write the merged dataframe to a new tsv file
#merged_df.to_csv('tagwalk_caption_2000_merged.tsv', sep='\t', index=False)
merged_df.to_csv('tagwalk_caption_full_merged.tsv', sep='\t', index=False, encoding='utf-8')
