#! /usr/bin/python3

# This program takes the outputs of collate_metadata.py and
# collect_cctyper_output.py and merges them into one DataFrame object
# then prints only relevant fields to file

import pandas as pd
import os
# shorten long commands
from os.path import isfile, join
# many european countries use country codes in a different field
# for consistency, maps codes to countries
from country_dictionary import countrydict

# gives paths to locations of all three files
metadatapath = '../../resources/ngmetadata_compiled.csv'
ngstarpath = '../../resources/ngngstar_compiled.csv'
cctyperpath = '../../results/ng/crisprcasgenes.csv'

# reads all three into DataFrames
comp_metadata = pd.read_csv(metadatapath)
comp_ngstar = pd.read_csv(ngstarpath)
comp_cctyper = pd.read_csv(cctyperpath)

# changes names of field containing file id to 'id' (and for metadata
# first changes internal usage name to something else) and sets it as
# the index for all three DataFrames
comp_ngstar.rename(columns={'Genome Name': 'id'}).set_index('id')
comp_metadata.rename(columns={'id': 'accessname'}).set_index('id')
comp_metadata.rename(columns={'displayname':'id'}).set_index('id')

# joins all three DataFrames into one DataFrame along index (implicit)
bigcomp = comp_metadata.join(comp_ngstar).join(comp_cctyper)
# loop to do data cleanup
for row in bigcomp:
    # identifies our duplicate named fastas, assigns the metadata
    # from xxxx1234.fasta to xxxx1234_1.fasta
    if row[id].endswith('_1'):
        bigcomp[row['id']] = bigcomp[row['id'].strip('_1')]
    # finds entries that use Reporting country instead of Country
    # uses dict to map code to country name then puts that in Country
    if row['Reporting country']:
        if row['Reporting country'] in countrydict:
            row['Country'] = countrydict[row['Reporting country']]
    # finds entries that use country instead of Country
    # puts country entry in Country
    if row['country']:
        row['Country'] = row['country']
    # US entries use United States or USA interchangeably
    # more recent entries tend to use USA so for consistency change
    # United States entries in Country to USA
    if row['Country'] = 'United States':
        row['Country'] = 'USA'

# print to file specifying relevant columns only
# incomplete because lacking amrfinder++ results
bigcomp.to_csv('../../results/statsdata.csv', columns=[
    'id','day','month','year', 'Country', 'latitude', 'longitude','NgStar Version', 'ST', 'penA', 'mtrR','porB'
    'ponA', 'gyrA', 'parC', '23S', 'operon', 'start', 'end', 'prediction', 'complete_interference',
    'complete_adaptation', 'Best_type', 'Genes', 'Positions'
])
