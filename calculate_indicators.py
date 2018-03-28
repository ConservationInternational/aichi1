import pandas as pd
import numpy as np
from pymongo import MongoClient
import os

#os.chdir('D://Documents and Settings/mcooper/GitHub/aichi1/')
os.chdir('/home/ec2-user/aichi1/')

countries = pd.read_csv('countrynames.csv', na_filter=False)

#Connect to MongoDB
client = MongoClient('localhost', 27017)
trendscon = client.TWITTER['TRENDS']
twittercon = client.TWITTER['TWITTER-BASELINE']
newscon = client.TWITTER['WEBHOSE-BASELINE']

#Get Google Trends Data in JSON
trends = []
cursor = trendscon.aggregate([{'$group' : {'_id' : {'country' : '$country', 'month' : '$month'}, "trends" : {"$avg" : "$rate"}}}])
for doc in cursor:
    trends.append({'country' : doc['_id']['country'],
                   'month' : doc['_id']['month'],
                   'trends' : doc['trends']})

#Get Twitter Data in JSON
twitter = []
cursor = twittercon.aggregate([{"$group" : {"_id": {"month" : '$month', "country": "$country"}, "basecount" : {"$sum" : '$baseline'},"anycount" : {"$sum": "$any"}}},
                               {"$project" : {'twitter' : { "$divide": ["$anycount", "$basecount"]}}}])
for doc in cursor:
    twitter.append({'country' : doc['_id']['country'],
                   'month' : doc['_id']['month'],
                   'twitter' : doc['twitter']})

#Get News Data in JSON
news = []
cursor = newscon.aggregate([{"$group" : {"_id": {"month" : '$month', "country": "$country"}, "basecount" : {"$sum" : '$baseline'},"anycount" : {"$sum": "$any"}}},
                            {"$project" : {'news' : { "$divide": ["$anycount", "$basecount"]}}}])
for doc in cursor:
    news.append({'country' : doc['_id']['country'],
                 'month' : doc['_id']['month'],
                 'news' : doc['news']})

#Any 0 means never any data, lets remove that
trends = pd.DataFrame(trends)
trends.loc[trends.trends==0, 'trends'] = np.NaN

#Rescale PER MONTH
twitter = pd.DataFrame(twitter)
twitter['twitter_absolute'] = twitter['twitter']
twitter['twitter'] = twitter['twitter']/0.01 * 100
twitter['twitter'][twitter['twitter'] > 100] = 100

news = pd.DataFrame(news)
news['news_absolute'] = news['news']
news['news'] = news['news']/0.25 * 100
news['news'][news['news'] > 100] = 100

#Fix Month and Date Format Issues
def reformatMonthStr(string):
    if len(string)==7 and string[5]=='0':
        string = string[:5] + string[6:]
    return(string)

twitter['month'] = twitter['month'].apply(reformatMonthStr)
trends['month'] = trends['month'].apply(reformatMonthStr)

#Merge it all together
comb = pd.merge(pd.merge(trends, twitter, how='outer', on=['country', 'month']), news, how='outer', on=['country', 'month'])
comb[comb==0] = np.NaN


#Get overall indicator, only where 2 sources exist    
comb['overall'] = comb[['trends', 'twitter', 'news']].mean(axis=1)
NAsums = comb[['trends', 'twitter', 'news']].isnull().sum(axis=1)
comb['overall'][NAsums == 2] = np.NaN
    
comb = pd.merge(comb, countries, how='inner', on=['country'])

comb = comb[comb.month != '2017-10']

comb.to_csv('myapp/public/indicator.csv', index=False)


comb.to_csv('myapp/public/indicator.csv', index=False)
comb.to_csv('myapp/public/indicator.csv', index=False)
comb.to_csv('myapp/public/indicator.csv', index=False)
