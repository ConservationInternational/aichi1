import pandas as pd
import numpy as np
from pymongo import MongoClient
import os

os.chdir('/home/ec2-user/aichi1/')

countries = pd.read_csv('countries.csv')
countries.columns = ['fullname', 'country']

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

def rescaledf(df, bycol, rescalecol):
    '''Rescale according to the max in rescalecol,
    For each group in bycol'''
    
    newdf = pd.DataFrame()
    
    for i in df[bycol].unique():
        sel = df[df[bycol]==i]
        sel[rescalecol] = sel[rescalecol]/max(sel[rescalecol])*100
        newdf = pd.concat([newdf, sel])
    
    return(newdf)

#Rescale PER MONTH
twitter = pd.DataFrame(twitter)
twitter = rescaledf(twitter, 'month', 'twitter')

news = pd.DataFrame(news)
news = rescaledf(news, 'month', 'news')

comb = pd.merge(pd.merge(trends, twitter, how='outer', on=['country', 'month']), news, how='outer', on=['country', 'month'])
comb[comb==0] = np.NaN

comb['overall'] = comb[['trends', 'twitter', 'news']].mean(axis=1)

comb = pd.merge(comb, countries, how='inner', on=['country'])

#Temporary!! Subset to just November for easier visualization for now.
comb = comb[comb.month=='2017-11']

comb.to_csv('indicator.csv', index=False)

f = open('index_template.html', 'r')
html = f.read()
f.close()

html = html.replace("~~~Insert data here~~~", comb.to_csv(index=False))

f = open('myapp/public/index.html', 'w')
f.write(html)
f.close()






