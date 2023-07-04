#! /usr/bin/python3

import pandas as pd
import os
from os.path import isfile, join

countrydict = {
    'AT': '',
    'BE': '',
    'CY': '',
    'CZ': '',
    'EE': '',
    'FR': '',
    'DE': '',
    'EL': '',
    'HU': '',
    'IT': '',
    'LV': '',
    'MT': '',
    'NL': '',
    'PL': '',
    'SI': '',
    'SK': '',
    'IS': '',
    'FI': '',
    'NO': '',
    'SE': '',
    'DK': '',
    'IE': ''
        }

metadatapath = '../../resources/ngmetadata_compiled.csv'
ngstarpath = '../../resources/ngngstar_compiled.csv'
cctyperpath = '../../results/ng/crisprcasgenes.csv'

comp_metadata = pd.read_csv(metadatapath)
comp_ngstar = pd.read_csv(ngstarpath)
comp_cctyper = pd.read_csv(cctyperpath)

comp_ngstar.rename(columns={'Genome Name': 'id'}).set_index('id')
comp_metadata.rename(columns={'id': 'accessname'}).set_index('id')
comp_metadata.rename(columns={'displayname':'id'}).set_index('id')

bigcomp = comp_metadata.join(comp_ngstar).join(comp_cctyper)
for row in bigcomp:
    if row[id].endswith('_1'):
        bigcomp[row['id']] = bigcomp[row['id'].strip('_1')]
    if row['Reporting country']:
        if row['Reporting country'] in countrydict:
            row['Country'] = countrydict[row['Reporting country']]
    if row['country']:
        row['Country'] = row['country']
    if row['Country'] = 'United States':
        row['Country'] = 'USA'

bigcomp.to_csv('../../results/statsdata.csv', columns=[
    'id','day','month','year', 'Country', 'latitude', 'longitude','NgStar Version', 'ST', 'penA', 'mtrR','porB'
    'ponA', 'gyrA', 'parC', '23S', 'operon', 'start', 'end', 'prediction', 'complete_interference',
    'complete_adaptation', 'Best_type', 'Genes', 'Positions'
])
