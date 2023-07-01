#! /Users/cloudy/miniconda3/envs/pandas/bin/python

import pandas as pd

ngstarafricaasiaspain = pd.read_csv("/Users/cloudy/PRACS/ngbin/africaasiaspain/ngstar.csv")
ngstarus = pd.read_csv("/Users/cloudy/PRACS/ngbin/aus/ngstar.csv")
ngstarnz = pd.read_csv("/Users/cloudy/PRACS/ngbin/nz/ngstar.csv")
ngstarnordic = pd.read_csv("/Users/cloudy/PRACS/ngbin/nordic/ngstar.csv")
ngstarseurope = pd.read_csv("/Users/cloudy/PRACS/ngbin/southerneurope/ngstar.csv")
ngstardenmark = pd.read_csv("/Users/cloudy/PRACS/ngbin/denmark/ngstar.csv")
ngstarhawaii = pd.read_csv("/Users/cloudy/PRACS/ngbin/hawaii/ngstar.csv")
ngstar1983 = pd.read_csv("/Users/cloudy/PRACS/ngbin/1983/ngstar.csv")
ngstar2013 = pd.read_csv("/Users/cloudy/PRACS/ngbin/2013/ngstar.csv")
ngstar2019 = pd.read_csv("/Users/cloudy/PRACS/ngbin/2019/ngstar.csv")
ngstar2020 = pd.read_csv("/Users/cloudy/PRACS/ngbin/2020/ngstar.csv")
ngstarsa = pd.read_csv("/Users/cloudy/PRACS/ngbin/sa/ngstar.csv")
ngstaruksouth = pd.read_csv("/Users/cloudy/PRACS/ngbin/uksouth/ngstar.csv")
ngstaruknorth = pd.read_csv("/Users/cloudy/PRACS/ngbin/uknorth/ngstar.csv")

ngstarlist = [ngstarnz,ngstarsa,ngstarus,ngstar1983,ngstar2013,ngstar2019,
    ngstar2020,ngstarhawaii,ngstarnordic,ngstardenmark,ngstarseurope,
    ngstarafricaasiaspain,ngstaruknorth,ngstaruksouth]
