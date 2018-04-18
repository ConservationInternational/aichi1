# -*- coding: utf-8 -*-
"""
Created on Mon Oct 02 11:56:48 2017

@author: mcooper
"""

from pymongo import MongoClient
import os
import pandas as pd
import webhoseio
import time
from datetime import datetime, timedelta
import boto3
import json

s3 = boto3.resource('s3')

os.chdir('/home/ec2-user/aichi1/collect-webhose')

#print('Establish connections')
client = MongoClient('localhost', 27017)
detailcon = client.TWITTER['WEBHOSE-DETAIL']
baselinecon = client.TWITTER['WEBHOSE-BASELINE']

###########################
#Define Functions
#############################
def chunks(l, n):
	"""Yield successive n-sized chunks from l."""
	for i in xrange(0, len(l), n):
		yield l[i:i + n]

def increment(incDict, incStr, db):
	"""Takes a dictionary, finds documents in already established db 
	if no document matches the already-exisiting dictionary, a new one is added with value incStr at 0
	if a document already exists, the value for incStr is incremented by one
	"""
	post = db.find_one(incDict)
	if post is None:
		incDict[incStr] = 1	  
		db.insert(incDict)
	elif incStr in post:
		post[incStr] = post[incStr] + 1
		db.save(post)
	else:
		post[incStr] = 1
		db.save(post)

def look_using_generator(df, value):
	"""given a df and a value, returns the row and column names where the dataframe matches that value
	found on stackoverflow at: https://stackoverflow.com/questions/35108108/pandas-get-each-values-index-and-columns-values
	"""
	return [(row[0], df.columns[row.index(value)-1]) for row in df.itertuples() if value in row[1:]]

############################
#Read in files
###############################

issues = pd.read_csv('../collect-twitter/issues.csv', encoding='utf-8')
issues_melt = pd.melt(issues.drop('google_topic_id', axis=1))
issues_melt = issues_melt.loc[issues_melt['value'] != 'XyEf9fAl2IuV6u97aM7a']


########################
#Get times
########################

#print('get times')
twodaysago = datetime.now() - timedelta(days=2)
yesterday = datetime.now() - timedelta(days=1)

month = str(twodaysago.year) + '-' + str(twodaysago.month)
day = str(yesterday.year) + '-' + str(yesterday.month) + '-' + str(yesterday.day)

twodaysago = str(twodaysago.year) + '-' + str(twodaysago.month) + '-' + str(twodaysago.day)
yesterday = str(yesterday.year) + '-' + str(yesterday.month) + '-' + str(yesterday.day)

start = str(int(time.mktime(datetime.strptime(twodaysago, "%Y-%m-%d").timetuple()) * 1000))
stop = str(int(time.mktime(datetime.strptime(yesterday, "%Y-%m-%d").timetuple()) * 1000))

#####################################
#Build word list chunks
#####################################

wordlists = list(chunks(list(issues_melt['value']), 40))
	
################################################
#Urls get messy.  Lets try it with their package
################################################

webhoseio.config(token="1abb8030-bf0f-4ce3-80a4-d2093d1a2763")

countries = pd.read_csv('../countries.csv', na_filter=False)
countries = countries['alpha-2'].tolist()


#See if it happens at the same spot.  UUIDs used to be 10365.  Run it again and see if UUIDs is the same length
uuids = []
for wl in wordlists:
        d = {}
	q = '("' + '" OR "'.join(wl) + '") published:>' + start + ' published:<' + stop + ' site_type:news'
	query_params = {"q": q, "ts":start}
	output = webhoseio.query("filterWebContent", query_params)  
	while len(output['posts']) > 0:
		for i in output['posts']:
			if i['uuid'] not in uuids:
				anytweet = True
				country = i['thread']['country']
				if country == 'KS':
					country = 'KR'
				if country in countries:
					for w in issues_melt['value']:
						if w.lower() in i['text'].lower():
							row,lang = look_using_generator(issues, w)[0]
							eng = issues.get_value(row, 'en')
							increment({'country': country, 'month': month, 'day': day, 'issue': eng, 'language': lang}, 'count', detailcon)
							if anytweet:
								increment({'country': country, 'month': month, 'day': day}, 'any', baselinecon)
								anytweet = False							
								#Append to dict to write
                                                                article = json.dumps(i, ensure_ascii=False).encode('utf8')
								d[lang + '_' + country + '_' + day + '_' + i['uuid']]=article
			uuids.append(i['uuid'])
		output = webhoseio.get_next()
        #Wtie items in dict
        for art in d:
            s3.Bucket('catch-webhose').put_object(Key=art, Body=d[art])

#print('Ended keyword search with ' + str(output['requestsLeft']) + ' available\n------------------------------')

#############################################
#Get baseline rates for every observed country
###############################################

#print('Checking all countries for baseline\n\n')
for country in countries:
	q = "thread.country:" + country + ' published:>' + start + ' published:<' + stop + ' site_type:news'
	query_params = {"q": q, "ts":start}
	output = webhoseio.query("filterWebContent", query_params)
	
	size = output['totalResults']
	
	if size > 0:
		incDict = {'country': country, 'month': month, 'day': day}
		post = baselinecon.find_one(incDict)
		if post is None:
			incDict['any'] = 0
			incDict['baseline'] = size
			baselinecon.insert(incDict)
		else:
			post['baseline'] = size
			baselinecon.save(post)

#print('Country search ended with ' + str(output['requestsLeft']) + ' available\n\n')
#print('The processed ended up using ' + str(beginRequests - output['requestsLeft']) + ' total requests')
