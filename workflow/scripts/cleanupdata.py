#!/usr/bin/env python3

# This program will take the output of collateall.py and clean the input
# For example data like year will be ints, etc
# In future this will be all in collateall.py but want to have the output ready
# to go then worry about future workflows.

import pandas as pd
import os

statscsv = pd.read_csv('../../results/statsdata.csv', dtype={
    'id': 'string',
    'day': 'int64',
    'month': 'int64',
    'year': 'int64',
    'Country': 'string',
    'latitude': 'string',
    'longitude': 'string',
    'NgStar Version': 'string',
    'ST': 'string',
    'penA': 'string',
    'mtrR': 'string',
    'porB': 'int64',
    'ponA': 'int64',
    'gyrA': 'int64',
    'parC': 'int64',
    '23S': 'int64',
    'Cas Operon': 'string',
    'Cas Start': 'int64',
    'Cas End': 'int64',
    'Cas Prediction': 'string',
    'Complete Interference': 'object',
    'Complete Adaptation': 'object',
    'Best_type': 'string',
    'Genes': 'object',
    'Positions': 'object',
    'AMR Contig id': 'object',
    'AMR Start': 'object',
    'AMR Stop': 'object',
    'AMR Gene symbol': 'object'
})

statscsv.to_csv('../../results/statsdataclean.csv')