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

s3 = boto3.resource('s3')

today = str(datetime.datetime.now() - datetime.timedelta(1))[:10]

os.chdir('/home/ec2-user')

def getValue(lang, country):
    post = db.find_one({'lang': lang, 'country': country})
    if post is None:
        db.insert({'lang': lang, 'country': country, 'count': 0})
        return 0
    else:
        return post['count']

def incrementValue(lang, country):
    post = db.find_one({'lang': lang, 'country': country})
    if post is None:
        db.insert({'lang': lang, 'country': country, 'count': 1})
    else:
        post['count'] = post['count'] + 1
        db.save(post)

class StdOutListener(tweepy.StreamListener):
    def on_data(self, data):
        out = json.loads(data)

        lang = out.get('lang')
        
        if out.get('place') is not None:
            cty = out.get('place').get('country_code')
        else:
            cty = 'xx'

        if out.get('coordinates') is not None:
            s3.Bucket('geo-raw').put_object(Key=today + '/' + str(datetime.datetime.now()), Body=data)
        
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
