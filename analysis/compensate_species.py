import boto3
import pandas as pd
from pymongo import MongoClient
import os
import json
import carmen
import datetime

os.chdir('/home/ec2-user/aichi1/collect-twitter/')

#print('Load geocoding resolver')
resolver = carmen.get_resolver(order=['profile'])
resolver.load_locations()

issues = pd.read_csv('issues.csv', encoding='utf-8')
issues_melt = pd.melt(issues.drop('google_topic_id', axis=1))
issues_met = issues_melt.loc[issues_melt['value'] != 'XyEf9fAl2IuV6u97aM7a']

s3client = boto3.client('s3')
s3resource = boto3.resource('s3')

paginator = s3client.get_paginator('list_objects')
pages = paginator.paginate(Bucket='catch-species')
files = []
for p in pages:
    for x in p['Contents']:
        files.append(x['Key'])


s3 = boto3.resource('s3')

content_object = s3.Object('test', 'sample_json.txt')
file_content = content_object.get()['Body'].read().decode('utf-8')
json_content = json.loads(file_content)
print(json_content['Details'])

def increment(incDict, incStr, db):
    """Takes a dictionary, finds documents in already established db 
    if no document matches the already-exisiting dictionary, a new one is added with value 'count' at 0
    if a document already exists, the value for 'count' is incremented by one
    """
    post = db.find_one(incDict)
    if post is None:
        incDict[incStr] = 1
        if incStr == 'baseline':
            incDict['any'] = 0
        db.insert(incDict)
    elif incStr in post:
        post[incStr] = post[incStr] + 1
        db.save(post)
    else:
        post[incStr] = 1
        db.save(post)

#Connect to MongoDB
client = MongoClient('localhost', 27017)
baselinecon = client.TWITTER['TWITTER-BASELINE']

for f in files:
    print(f)
    content_object = s3resource.Object('catch-species', f)
    file_content = content_object.get()['Body'].read().decode('utf-8')
    out = json.loads(file_content)
    
    if out.get('place') is not None and out.get('place') != '':
        country = out.get('place').get('country_code')
    else:
        country = resolver.resolve_tweet(out)
        if country:
            country = country[1].country
    
    dates = out.get('created_at').replace('+0000 ', '')
    date = datetime.datetime.strptime(dates, '%a %b %d %H:%M:%S %Y')
    
    month = date.strftime('%Y-%m')
    
    day = date.strftime('%Y-%m-%d')
    
    text = out.get('text')
    
    anykeys = False
    
    for i in issues_melt['value']:
        if i.lower() in out.get('text').lower():
            anykeys = True
    
    if not anykeys:
        increment({'country': country, 'month': month, 'day':day}, 'just_species', baselinecon)