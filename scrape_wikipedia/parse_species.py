#Data downloaded from Catalogue of life: http://www.catalogueoflife.org/DCA_Export/archive.php
f = open('D://Documents and Settings/mcooper/Desktop/2017-09-29-archive-complete/taxa.txt')

import pandas as pd

out = pd.read_csv('D://Documents and Settings/mcooper/Desktop/2017-09-29-archive-complete/taxa.txt', sep='\t')

def getName(tax):
    sel = tax.split(' ')[0:2]
    if len(sel) < 2:
        return 'ERROR'
    if len(sel[1]) < 1:
        return 'ERROR'
    if sel[1][0].islower():
        return ' '.join(sel)
    else:
        return 'ERROR'
        
out['name'] = out['scientificName'].apply(getName)


sel = out['name'].unique()

f = open('D://Documents and Settings/mcooper/GitHub/aichi1/scrape_wikipedia/species.csv', 'w')

for i in sel:
    f.write(i + '\n')

f.close()