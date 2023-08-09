import pandas as pd
import os

os.chdir('../../results/ng/amr')

pathlist = os.listdir()

#pathlist = ['ECDC_AT18_980030.fasta.log', 'ECDC_AT18_980031.fasta.log']


# each file is the results of one isolate and is a list of amr genes and locations
# to merge with cctyper results, going to create a list of dataframes - the isolate, a list of starts, ends, etc
amrentries = []

for log in pathlist:
    if not log.startswith('.'):
        try:
            results = pd.read_csv(log, sep='\t')
            amrcontigid = []
            amrstart = []
            amrstop = []
            amrgenesymbol = []

            for field in results['Contig id']:
                amrcontigid.append(field)
            for field in results['Start']:
                amrstart.append(field)
            for field in results['Stop']:
                amrstop.append(field)
            for field in results['Gene symbol']:
                amrgenesymbol.append(field)

            amrdict = {'id': log.split('/')[-1].split('.')[0], 'AMR Contig id': amrcontigid,
                'AMR Start': amrstart, 'AMR Stop': amrstop, 'AMR Gene symbol': amrgenesymbol }
            #print(amrdict)
            #amrentries.append(pd.DataFrame(data=amrdict))
            amrentries.append(amrdict)
        except:
            print('didn\'t like log ' + log)

amrmerge = pd.DataFrame(data=amrentries)
#amrmerge = pd.concat(amrentries)

os.chdir('..')

amrmerge.to_csv('amrresultsmerge.csv')
