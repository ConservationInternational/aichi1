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
issues_melt = pd.melt(issues.drop('google_topic_id', axis=1)
species = pd.read_csv('species_list.csv', header=None)

s3 = boto3.resource('s3')

#Connect to MongoDB
client = MongoClient()
client = MongoClient('localhost', 27017)
twittercon = client.TWITTER['TWITTER-DETAIL']
baselinecon = client.TWITTER['TWITTER-BASELINE']

os.chdir('/home/ec2-user')

def increment(incDict, incStr, db):
    """Takes a dictionary, finds documents in already established db 
    if no document matches the already-exisiting dictionary, a new one is added with value 'count' at 0
    if a document already exists, the value for 'count' is incremented by one
    """
    post = db.find_one(incDict)
    if post is None:
        incDict[incStr] = 1      
        db.insert(incDict)
    else:
        post[incStr] = post[incStr] + 1
        db.save(post)

def look_using_generator(df, value):
    """given a df and a value, returns the row and column names where the dataframe matches that value
    found on stackoverflow at: https://stackoverflow.com/questions/35108108/pandas-get-each-values-index-and-columns-values
    """
    return [(row[0], df.columns[row.index(value)-1]) for row in df.itertuples() if value in row[1:]]

class StdOutListener(tweepy.StreamListener):
    def on_data(self, data):
        now = str(datetime.datetime.now())
        month = now[:7]
        day = now()[:10]

        out = json.loads(data)
        
        #Capture full spatial tweets to s3 bucket
        if out.get('coordinates') is not None:
            s3.Bucket('geo-raw').put_object(Key=day + '/' + now, Body=data)
 
        #Get country and increment baseline
        #Dont collect anything if country is unidentifiable
        if out.get('place') is not None and out.get('place') != '':
            country = out.get('place').get('country_code')
        else:
            country = resolver.resolve_tweet(out)[1].country
        if country:
            increment({'country': country, 'month': month, 'day': day}, 'baseline', baselinecon)
        else:
            return True

        #Also track tweets with any, make sure we only track once
        anytweet = True

        #Check species
        for s in species[0]:
            if s.lower() in out.get('text').lower():
                increment({'country': country, 'month': month, 'day': day, 'species': s}, 'count', twittercon)
                if anytweet:
                    increment({'country': country, 'month': month, 'day': day}, 'any', baselinecon)
                    anywteet = False

        #Check issues
        for i in issues_melt[1]:
            if i.lower() in out.get('text').lower():
                row,lang = look_using_generator(issues, i)[0]
                eng = issues.get_value(row, 'en')
                increment({'country': country, 'month': month, 'day': day, 'issue': eng, 'language': lang}, 'count', twittercon)
                if anytweet:
                    increment({'country': country, 'month': month, 'day':day}, 'any', baselinecon)
                    anytweet = False

        return True


    def on_error(self, status):
        print('error!')
        f = open('errorlong.txt', 'w')
        f.write(str(datetime.datetime.now())+str(status))
        f.close()

#Connect to Twitter
l = StdOutListener()
auth = tweepy.OAuthHandler(consumerKey, consumerSecret)
auth.set_access_token(accessToken, accessTokenSecret)

stream = tweepy.Stream(auth, l)
stream.sample()
