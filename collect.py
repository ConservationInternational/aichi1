consumerKey = 'JB2xtTk0AkYuHXKOGaIMrNlUF'
consumerSecret = '3fwYUygwZoIwTnXCAs6thHmzC6bhlZ8PKjNPAWH1ly0yeyhJPp'
accessToken = '2494659504-3400UHuDCBO5L99Lg4vkGaKXFgQnbgGsnrxBIeJ'
accessTokenSecret = 'lX0bDuQRuEYkHMeXUr5eRUDYwg27M0i2iO5oFYel8Rmoh'

import tweepy
import datetime
import os
import pymongo
from pymongo import MongoClient
import json
import boto3
import pandas as pd
import carmen

resolver = carmen.get_resolver(order=['profile'])
resolver.load_locations()

issues = pd.read_csv('issues.csv')
species = pd.read_csv('species_list.csv', header=None)

s3 = boto3.resource('s3')

os.chdir('/home/ec2-user')

def increment(incDict):
    post = db.find_one(incDict)
    if post is None:
        
        db.insert(

def incrementIssueValue(month, country, issue, day, language):
    post = db.find_one({{'month': month, 'country': country, 'issue': issue, 'day': day, 'language': language}})
    if post is None:
        db.insert({'month': month, 'date': day, 'country': country, 'issue': issue, 'day': day, 'language': language, 'count': 1})
    else:
        post['count'] = post['count'] + 1
        db.save(post)

def incrementSpeciesValue(month, country, species, day):
    post = db.find_one({'month': month, 'country': country, 'species': species, 'day', day})
    if post is None:
        db.insert({'month': month, 'country': country, 'species': species, 'dau', day, 'count': 1})
    else:
        post['count'] = post['count'] + 1
        db.save(post)

def incrementAnyValue(month, 

class StdOutListener(tweepy.StreamListener):
    def on_data(self, data):
        month = str(datetime.datetime.now())[:7]
        day = str(datetime.datetime.now())[8:10]

        out = json.loads(data)

        if out.get('place') is not None and out.get('place') != '':
            country = out.get('place').get('country_code')
        else:
            country = resolver.resolve_tweet(out)[1].country
        
        for s in species[0]:
            if s in out.get('text')

        lang = out.get('lang')
        
        if out.get('place') is not None:
            cty = out.get('place').get('country_code')
        else:
            cty = 'xx'

        if out.get('coordinates') is not None:
            s3.Bucket('geo-raw').put_object(Key=str(datetime.datetime.now())[:10]
 + '/' + str(datetime.datetime.now()), Body=data)
        
        incrementValue(lang, cty)        

        return True
    
    def on_error(self, status):
        print('error!')
        f = open('errorlong.txt', 'w')
        f.write(str(datetime.datetime.now())+str(status))
        f.close()

#Connect to MongoDB
client = MongoClient()
client = MongoClient('localhost', 27017)
db = client.TWITTER['country-language']

#Connect to Twitter
l = StdOutListener()
auth = tweepy.OAuthHandler(consumerKey, consumerSecret)
auth.set_access_token(accessToken, accessTokenSecret)

stream = tweepy.Stream(auth, l)
stream.sample()
