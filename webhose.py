# -*- coding: utf-8 -*-
"""
Created on Mon Oct 02 11:56:48 2017

@author: mcooper
"""

import json
from collections import defaultdict
import urllib


###########################################################################
# Collect number of articles for country with keyword 'biodiversity'
#
# URL created at https://webhose.io/web-content-api
###########################################################################
url = 'http://webhose.io/filterWebContent?token=1abb8030-bf0f-4ce3-80a4-d2093d1a2763&format=json&ts=1504372913899&sort=crawled&q=biodiversity%20published%3A%3E1504324800000%20site_type%3Anews'
response = urllib.urlopen(url)
data = json.loads(response.read())

dd = defaultdict(int)
for i in data['posts']:
    dd[i['thread']['country']] += 1

while data['moreResultsAvaiable'] > 0:
    print(data['moreResultsAvailable'])
    url = 'http://webhose.io' + data['next']
    response = urllib.urlopen(url)
    data = json.loads(response.read())

    for i in data['posts']:
        dd[i['thread']['country']] += 1

dd.pop('')
dd.pop(None)

###############################################
#Get baseline rates for every observed country
###############################################
countries = {}
for country in dd:
    url = 'http://webhose.io/filterWebContent?token=1abb8030-bf0f-4ce3-80a4-d2093d1a2763&format=json&ts=1504373339998&sort=crawled&q=site_type%3Anews%20thread.country%3A' + country + '%20published%3A%3E1504324800000'
    response = urllib.urlopen(url)
    data = json.loads(response.read())
    
    countries[country] = data['totalResults']
    
    print(country)


#######################################
#Plot Results
########################################
import matplotlib.pyplot as plt

rate = {}
for c in countries:
    rate[c] = float(dd[c])/float(countries[c])

plt.bar(range(len(rate)), rate.values(), color='g')
plt.xticks(range(len(rate)), rate.keys())
plt.show()


