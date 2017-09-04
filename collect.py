import tweepy
import datetime
import os
import pymongo
from pymongo import MongoClient

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
    post['count'] = post['count'] + 1
    db.posts.save(post)

class StdOutListener(tweepy.StreamListener):
    def on_data(self, data):
        print(type(data))

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
