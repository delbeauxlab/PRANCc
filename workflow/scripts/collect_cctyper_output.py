#! /usr/bin/python3

import pandas as pd
import os

# create output files so snakemake runs
#open(snakemake.output, 'a').close()

os.chdir('../../results/ng/cctyperresults')
#pathlist = os.listdir("../../results/ng/cctyperresults")
pathlist = os.listdir()

cctyperlist = []

for csv_file in pathlist:
    if not csv_file.startswith('.'):
        try:
            results = pd.read_csv(csv_file + '/cas_operons.tab', sep='\t')
            results['id'] = csv_file.split('/')[-1].split('.')[0]
            #print(results['id'])
            cctyperlist.append(results)
        except:
            print('It didn\'t like ' + csv_file)

cctypermerge = pd.concat(cctyperlist)

cctypermerge.to_csv('cas_operons_compiled.csv')
