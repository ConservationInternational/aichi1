import pandas as pd
from pytrends.request import TrendReq
import datetime
import time
from pymongo import MongoClient
import os
from sshtunnel import SSHTunnelForwarder

MONGO_HOST = "34.195.2.46"
MONGO_DB = "TWITTER"
MONGO_USER = "ec2-user"
MONGO_PASS = ""

server = SSHTunnelForwarder(
    MONGO_HOST,
    ssh_username=MONGO_USER,
    ssh_password=MONGO_PASS,
	ssh_pkey="~/.ssh/id_rsa",
    remote_bind_address=('127.0.0.1', 27017)
)

server.start()

#Connect to Mongodb
client = MongoClient('127.0.0.1', server.local_bind_port) # server.local_bind_port is assigned local port
trendscon = client.TWITTER['TRENDS']

data = pd.read_csv("issues.csv", encoding='utf-8')
kw_list = data['google_topic_id'].tolist()
keyword = data['en'].tolist()

countries = pd.read_csv("countries.csv", encoding='utf-8', na_filter=False)

today = datetime.date.today()
first = today.replace(day=1)
lastMonth = first - datetime.timedelta(days=1)
lastMonth.strftime("%Y%m")

today = datetime.date.today()
#Get all data from previous month if the date is the first
if today.day==1:
    yesterday = today - datetime.timedelta(days=1)
    begin = yesterday.replace(day=1).strftime("%Y-%m-%d")
    end = yesterday.strftime("%Y-%m-%d")
    month = yesterday.strftime("%Y-%m")
    
#Or get all data from the 1st of this month to today
else:
    begin = today.replace(day=1).strftime("%Y-%m-%d")
    end = today.strftime("%Y-%m-%d")
    month = today.strftime("%Y-%m")

timeframe = begin + ' ' + end

pytrends = TrendReq(hl='en-US', tz=360)
for i in range(0,len(kw_list)):
    pytrends.build_payload([kw_list[i]], timeframe=timeframe, cat=0, geo='', gprop='')
    out = pytrends.interest_by_region(resolution='COUNTRY')
    
    out['name'] = out.index
    
    #Check Google Trends country names match our country names
    #for n in out['name']:
    #    if n not in countries['name'].tolist():
    #        print('WARNING! ' + n + ' missing from countries table')
    
    comb = pd.merge(out, countries, how='outer', on='name')
    comb = comb.fillna(0)
    
    for j in range(0, len(comb['alpha-2'])):
        incDict = {'country' : comb['alpha-2'][j], 'month' : month, 'issue': keyword[i]}
        rate = comb[kw_list[i]][j]
        
        post = trendscon.find_one(incDict)
        if post is None:
            incDict['rate'] = rate
            trendscon.insert(incDict)
        else:
            post['rate'] = rate
            trendscon.save(post)
    
    time.sleep(10)
    
server.stop()
