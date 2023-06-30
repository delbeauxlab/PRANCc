#! /usr/bin/python3

import pandas as pd

# create output files so snakemake runs
open(snakemake.output[0], 'a').close()

# make a list object for pd.concat
concatlist = []

# read all csv files from input and put them in concatlist
for csv_file in list(snakemake.input):
    try:
        csv_member = pd.read_csv(csv_file)
        concatlist.append(csv_member)
    except:
        print("no result for" + csv_file)


# concatenate the files with pandas
metadata = pd.concat(concatlist).drop_duplicates().reset_index(drop=True)

metadata.to_csv(snakemake.output[0], mode='a')

#for object in snakemake.input:
#    print(object)
#print(snakemakelist[0])
