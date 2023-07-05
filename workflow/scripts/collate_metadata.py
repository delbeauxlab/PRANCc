#! /usr/bin/python3

import pandas as pd
import os
# already imported from os but shortens long commands
from os.path import isfile, join

#os.chdir('../../resources/ng')
#pathlist = os.listdir()

# sets path for location of metadata files
path = '../../resources/ng'
# goes through directory and only adds entries that are files, not
# folders to onlyfiles list
onlyfiles = [f for f in os.listdir(path) if isfile(join(path, f))]

# create empty list objects to concatenate seperately
metadatalist = []
ngstarlist = []

# loop over all files in directory
for file in onlyfiles:
    # only act on files that start with metadata - so not ngstar
    if file.startswith('metadata'):
        # attempt to do following commands, if error than do except
        try:
            # read metadata files, then add DataFrame to metadatalist
            metadata = pd.read_csv(join(path,file), sep=',')
            # print(metadata.iloc[0])
            metadatalist.append(metadata)
        except:
            print(file + ' didn\'t work')
    # exactly the same as above, but for ngstar files
    if file.startswith('ngstar'):
        try:
            ngstar = pd.read_csv(join(path,file), sep=',')
            ngstarlist.append(ngstar)
        except:
            print(file + 'didn\'t work')
# concatenates all DataFrames in list, then checks for duplicates
# based on displayname and Genome Name - the name of the .fasta file
# connected drops duplicates and keeps only first entry '''
metaconcat = pd.concat(metadatalist).drop_duplicates(subset=['displayname'], keep='first', ignore_index=True)
ngconcat = pd.concat(ngstarlist).drop_duplicates(subset=['Genome Name'], keep='first', ignore_index=True)
# prints both to seperate files
metaconcat.to_csv(path + 'metadata_compiled.csv')
ngconcat.to_csv(path + 'ngstar_compiled.csv')

print(metaconcat)
print(ngconcat)
