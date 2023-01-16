import sys
import csv
from collections import defaultdict


class MatchCrisprSystem():

    typeia = ['Cas5', 'Cas7', 'Cas8', 'Cas11']
    typeib = ['Cas5', 'Cas7', 'cas8']  # types I-B, types I-C
    typeid = ['Cas3', 'Cas5', 'Cas7', 'Cas10']
    typeie = ['Cas5', 'Cas6', 'Cas7', 'Cas8']  # types I-E, I-F1, I-F2, I-G
    typeif2 = ['Cas5', 'Cas6', 'Cas7']
    typeiva = ['Cas5', 'Cas7']  # types IV-A
    typeivb = ['Cas5', 'Cas7']  # types IV-B, IV-C
    typeiiia = ['Cas5', 'Cas7', 'Cas10', 'Cas11']  # types III-A, III-B, III-D, III-F
    typeiiic = ['Cas5', 'Cas10', 'Cas11']
    typeiiie = ['Cas7', 'Cas11']
    typeii = ['Cas9']  # types II-a, II-B, II-C1, II-C2
    typev = ['Cas12']  # types V-A, V-B1, V-B2, V-C, V-D, V-E, V-F1, V-F2, V-F3, V-G, V-H, V-I, V-K, V-U1,
    # V-U2, V-U3, V-U4
    typevi = ['Cas13']  # types VI-A, VI-B1, VI-B2, VI-C, VI-D
    effectorcomplexes = {'typeia': typeia, 'typeib typeic': typeib, 'typeid': typeid,
                         'typeie typeif1 type if2 typeig': typeie, 'typeif2': typeif2, 'typeiva': typeiva,
                         'typeivb typeivc': typeivb, 'typeiiia iiib iiid iiif': typeiiia, 'typeiiic': typeiiic,
                         'typeiiie': typeiiie, 'typeii': typeii, 'typev': typev, 'typevi': typevi}

    @classmethod
    def typespresent(self, obsgenes, systemgenesnames,systemgenestargets):
        genedict = {}
        obvsset = set()
        systemsset = set()
        returnslist = ''
        for target in systemgenestargets:
            genedict.update({target: False})
            for gene in obsgenes:
                if target in gene:
                    if target == 'cas1':
                        if target == gene:
                            genedict.update({target: True})
                            obvsset.add(gene)
                    else:
                        obvsset.add(gene)
                    genedict.update({target: True})
                    obvsset.add(gene)
        if genedict:
            if all(genedict.values()):
                systemsset.add(systemgenesnames)
        return systemsset

    @classmethod
    def obvsgenes(self, obsgenes, systemgenesnames,systemgenestargets):
        genedict = {}
        obvsset = set()
        systemsset = set()
        returnslist = ''
        for target in systemgenestargets:
            genedict.update({target: False})
            for gene in obsgenes:
                if target in gene:
                    if target == 'cas1':
                        if target == gene:
                            genedict.update({target: True})
                            obvsset.add(gene)
                    else:
                        obvsset.add(gene)
                    genedict.update({target: True})
                    obvsset.add(gene)
        if genedict:
            if all(genedict.values()):
                systemsset.add(systemgenesnames)
        return obvsset

file_name = sys.argv[1]

# create a list of name matches for proteins of interest
genetargets = ['Cas', 'csc1', 'csy2', 'csf3', 'csm4', 'cmr3', 'csx10', 'csf2', 'csm2', 'cmr5', 'cse2',
               'csa5', 'csm2', 'csm3', 'cpf1', 'c2c1', 'c2c3', 'c2c5', 'c2c2', 'csx28', 'csx27',
               'c2c7', 'WYL']
columns = defaultdict(list)  # create a dictionary object to load csv file into

# read a csv file, creating a dictionary where first row becomes dictionary key for list of all entries
with open(file_name) as csvfile:
    spamreader = csv.DictReader(csvfile)
    for row in spamreader:
        for (k, v) in row.items():
            columns[k].append(v)
# print(columns.keys())
# print(columns['protein.name'])

proteinlist = columns['protein.name']

# compare proteinlist against genetarget to see if any interesting matches
'''
matches = []

for target in genetargets:
    #matches = [match for match in proteinlist if target in match]
    for match in proteinlist:
        if target in match:
            matches.append(match)
'''

# in list comprehension form
matches = [match for match in proteinlist for target in genetargets if target in match]

effectorcomplexes = MatchCrisprSystem.effectorcomplexes

'''for targets in effectorcomplexes:
    print(MatchCrisprSystem.typespresent(typefalse, targets, effectorcomplexes[targets]))'''

systemfound = set()
obvsgenes = set()


for targets in effectorcomplexes:
    k = MatchCrisprSystem.typespresent(matches, targets, effectorcomplexes[targets])
    l = MatchCrisprSystem.obvsgenes(matches, targets, effectorcomplexes[targets])
    for genes in k:
        systemfound.add(genes)
    for genes in l:
        obvsgenes.add(genes)

print(systemfound)
print(obvsgenes)

csvstring = ['', '', '', '']
csvstring[0] = file_name
if systemfound:
    csvstring[1] = ', '.join(systemfound)
else: csvstring[1] = 'No system detected'
csvstring[2] = ', '.join(obvsgenes)
csvstring[3] = ', '.join(matches)


with open('E:\\testfile2.csv', 'a', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(csvstring)