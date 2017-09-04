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

os.chdir('/home/ec2-user')

def getLangValue(lang):
    post = db.posts.find_one({'lang': lang})
    if post is None:
        db.posts.insert({'lang': lang, 'count': 0})
        return 0
    else:
        return post['count']

def incrementLang(lang):
    post = db.posts.find_one({'lang': lang})
    if post is None:
        db.posts.insert({'lang': lang, 'count': 1})
    else:
        post['count'] = post['count'] + 1
        db.posts.save(post)

class StdOutListener(tweepy.StreamListener):
    def on_data(self, data):
        out = json.loads(data)
        lang = out.get('lang')
        incrementLang(lang)
        
        return True
    
    def on_error(self, status):
        print('error!')
        f = open('errorlong.txt', 'w')
        f.write(str(datetime.datetime.now())+str(status))
        f.close()

#Connect to MongoDB
client = MongoClient()
client = MongoClient('localhost', 27017)
db = client.TWITTER.test_langdef

#Connect to Twitter
l = StdOutListener()
auth = tweepy.OAuthHandler(consumerKey, consumerSecret)
auth.set_access_token(accessToken, accessTokenSecret)

stream = tweepy.Stream(auth, l)
stream.sample()
