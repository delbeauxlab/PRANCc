#!/usr/bin/env python3

import pandas as pd
import os

# create output files so snakemake runs
#open(snakemake.output, 'a').close()

# move to directory cctyper results are in
os.chdir('../../results/ng/cctyperresults')

# lists all files and folders and puts it into pathlist list
pathlist = os.listdir()

# create an empty list for pandas DataFrame objects to later merge
cctyperlist = []

# loop over all entries in pathlist
for csv_file in pathlist:
    # only acts on files that aren't hidden or system files
    if not csv_file.startswith('.'):
        try:
            # read cas_operons.tab inside given folder, if exists
            results = pd.read_csv(csv_file + '/cas_operons.tab', sep='\t')
            # adds a field to DataFrame under 'id' based on directory
            # splits path/to/folder.fasta to ['path','to','folder.fasta']
            # takes last entry of that list then splits to ['folder','fasta']
            # then takes first entry of that - 'folder' and puts that
            # into id field of Data Frame
            results['id'] = csv_file.split('/')[-1].split('.')[0]
            # adds this results DataFrame to cctyper list
            cctyperlist.append(results)
        except:
            # if it fails for any reason - usually because
            # /cas_operons.tab doesn't exist - fails and prints folder
            print('It didn\'t like ' + csv_file)

# concatenates all DataFrames in list together into single file
# prefer doing this than adding  in loop so that it keeps a header row
cctypermerge = pd.concat(cctyperlist)

# prints that DataFrame to a file
cctypermerge.to_csv('cas_operons_compiled.csv')
