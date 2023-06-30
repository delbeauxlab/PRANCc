#! /Users/cloudy/miniconda3/envs/pandas/bin/python

import pandas as pd

metadataafricaasiaspain = pd.read_csv("/Users/cloudy/PRACS/africaasiaspain/metadata.csv")
metadataus = pd.read_csv("/Users/cloudy/PRACS/ausnz/aus/metadata.csv")
metadatanz = pd.read_csv("/Users/cloudy/PRACS/ausnz/nz/metadata.csv")
metadatanordic = pd.read_csv("/Users/cloudy/PRACS/europe/nordic/metadata.csv")
metadataseurope = pd.read_csv("/Users/cloudy/PRACS/europe/southerneurope/metadata.csv")
metadatadenmark = pd.read_csv("/Users/cloudy/PRACS/europe/denmark/metadata.csv")
metadatahawaii = pd.read_csv("/Users/cloudy/PRACS/na/hawaii/metadata.csv")
metadata1983 = pd.read_csv("/Users/cloudy/PRACS/na/1983/metadata.csv")
metadata2013 = pd.read_csv("/Users/cloudy/PRACS/na/2013/metadata.csv")
metadata2019 = pd.read_csv("/Users/cloudy/PRACS/na/2019/metadata.csv")
metadata2020 = pd.read_csv("/Users/cloudy/PRACS/na/2020/metadata.csv")
metadatasa = pd.read_csv("/Users/cloudy/PRACS/sa/metadata.csv")
metadatauksouth = pd.read_csv("/Users/cloudy/PRACS/uk/uksouth/metadata.csv")
metadatauknorth = pd.read_csv("/Users/cloudy/PRACS/uk/uknorth/metadata.csv")

metadatalist = [metadatanz,metadatasa,metadataus,metadata1983,metadata2013,metadata2019,
    metadata2020,metadatahawaii,metadatanordic,metadatadenmark,metadataseurope,
    metadataafricaasiaspain,metadatauknorth,metadatauksouth]
