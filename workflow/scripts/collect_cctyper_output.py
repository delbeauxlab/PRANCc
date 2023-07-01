#! /usr/bin/python3

import pandas as pd

# create output files so snakemake runs
open(snakemake.output, 'a').close()

'''for csv_file in snakemake.input:
    try:
        results = pd.read_csv(csv_file, sep='\t')
        results['id'] = csv_file.strip'''

print(snakemake.input[0])
