#! /usr/bin/python3

import pandas as pd
import os
from os.path import isfile, join

#os.chdir('../../resources/ng')
#pathlist = os.listdir()
path = '../../resources/ng'
onlyfiles = [f for f in os.listdir(path) if isfile(join(path, f))]

metadatalist = []
ngstarlist = []

for file in onlyfiles:
    if file.startswith('metadata'):
        try:
            metadata = pd.read_csv(join(path,file), sep=',')
            print(metadata.iloc[0])
            metadatalist.append(metadata)
        except:
            print(file + ' didn\'t work')
    if file.startswith('ngstar'):
        try:
            ngstar = pd.read_csv(join(path,file), sep=',')
            ngstarlist.append(ngstar)
        except:
            print(file + 'didn\'t work')

metaconcat = pd.concat(metadatalist).drop_duplicates(subset=['displayname'], keep='first', ignore_index=True)
ngconcat = pd.concat(ngstarlist).drop_duplicates(subset=['Genome Name'], keep='first', ignore_index=True)
metaconcat.to_csv(path + 'metadata_compiled.csv')
ngconcat.to_csv(path + 'ngstar_compiled.csv')

print(metaconcat)
print(ngconcat)

'''# create output files so snakemake runs
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
#print(snakemakelist[0])'''
