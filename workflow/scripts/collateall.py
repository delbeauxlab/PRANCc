#! /usr/bin/python3

# This program takes the outputs of collate_metadata.py and
# collect_cctyper_output.py and collect_amrfinderplusplus_output.py and merges them into one DataFrame object
# then prints only relevant fields to file

import pandas as pd
import os
# shorten long commands
from os.path import isfile, join
# many european countries use country codes in a different field
# for consistency, maps codes to countries
from country_dictionary import countrydict

# gives paths to locations of all four files
metadatapath = '../../resources/ngmetadata_compiled.csv'
ngstarpath = '../../resources/ngngstar_compiled.csv'
cctyperpath = '../../results/ng/cctyperresults/cas_operons_compiled.csv'
amrpath = '../../results/ng/amrresultsmerge.csv'

# reads all four into DataFrames
comp_metadata = pd.read_csv(metadatapath)
comp_ngstar = pd.read_csv(ngstarpath)
comp_cctyper = pd.read_csv(cctyperpath)
comp_amr = pd.read_csv(amrpath)

# changes names of field containing file id to 'id' (and for metadata
# first changes internal usage name to something else) and sets it as
# the index for all three DataFrames
comp_ngstar = comp_ngstar.rename(columns={'Genome Name': 'id'})
comp_metadata = comp_metadata.rename(columns={'id': 'accessname'}).rename(columns={'displayname':'id'})

# create a list of fields from ngstar and metadata entries to account for lack of duplicate metadata
comp_metadata_fields = ['day','month','year', 'Country', 'latitude', 'longitude', 'Reporting country', 'country', 'Version', 'penA', 'mtrR',
    'porB', 'ponA', 'gyrA', 'parC', '23S']

bigcomp = comp_amr.merge(comp_cctyper, how='outer', on='id').merge(comp_ngstar, how='outer', on='id').merge(comp_metadata, how='outer', on='id')
bigcomp = bigcomp.set_index('id', drop=True)

# joins all four DataFrames into one DataFrame along index (implicit)
# bigcomp = comp_metadata.merge(comp_ngstar, on='id', how='left').merge(comp_cctyper, on='id', how='left').merge(comp_amr, on='id', how='left')
# loop to do data cleanup

for id in list(bigcomp.index.values):
    # identifies our duplicate named fastas, assigns the metadata from xxxx1234.fasta to xxxx1234_1.fasta
    if id.endswith('_1'):
        if id[:-2] in list(bigcomp.index.values):
            bigcomp.loc[id, comp_metadata_fields] = bigcomp.loc[id[:-2], comp_metadata_fields]
    # checks if entry uses Reporting country, then maps country code to Country with countrydict
    if str(bigcomp.loc[id,'Reporting country']) in countrydict:
        bigcomp.loc[id, 'Country'] = countrydict[bigcomp.loc[id, 'Reporting country']]
    # pandas assigns NaN if no value, which is a float, so check if exists by checking if its a string
    # only values we care about are strings anyway, so checks for existance and compatibility
    if type(bigcomp.loc[id, 'country']) == str:
        bigcomp.loc[id, 'Country'] = bigcomp.loc[id, 'country']
    # US entries use United States or USA interchangeably
    # more recent entries tend to use USA so for consistency change
    # United States entries in Country to USA
    if str(bigcomp.loc[id, 'Country']) == 'United States':
        bigcomp.loc[id, 'Country'] = 'USA'

# rename some columns to avoid confusion
bigcomp = bigcomp.rename(columns={'Version': 'NgStar Version', 'Operon': 'Cas Operon', 'Start': 'Cas Start',
    'End': 'Cas End', 'Prediction': 'Cas Prediction'})


# print to file specifying relevant columns only
bigcomp.to_csv('../../results/statsdata.csv', columns=[
    'day','month','year', 'Country', 'latitude', 'longitude','NgStar Version', 'ST', 'penA', 'mtrR','porB',
    'ponA', 'gyrA', 'parC', '23S', 'Cas Operon', 'Cas Start', 'Cas End', 'Cas Prediction', 'Complete_Interference',
    'Complete_Adaptation', 'Best_type', 'Genes', 'Positions', 'AMR Contig id', 'AMR Start', 'AMR Stop',
    'AMR Gene symbol'
])
