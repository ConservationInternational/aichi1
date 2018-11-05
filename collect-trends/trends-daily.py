import pandas as pd
from pytrends.request import TrendReq

data = pd.read_csv("~/aichi1/collect-twitter/issues.csv", encoding='utf-8')
kw_list = data['google_topic_id'].tolist()
keyword = data['en'].tolist()

countries = pd.read_csv("~/aichi1/countries.csv", encoding='utf-8', na_filter=False)

pytrends = TrendReq(hl='en-US', tz=360)

all = pd.DataFrame({})

#Manually create timeframe like this:
timeframe = '2017-11-01 2018-04-30'

for i in range(0,len(kw_list)):
    pytrends.build_payload([kw_list[i]], timeframe=timeframe, cat=0, geo='', gprop='')
    out = pytrends.interest_over_time()
    
    out['date'] = out.index
    out['keyword'] = keyword[i]
    out = out.drop(['isPartial'], axis=1)
    
    out.columns = ['score', 'date', 'keyword']
         
    all = pd.concat([all, out])

#Manually create timeframe like this:
timeframe = '2018-05-01 2018-10-31'

for i in range(0,len(kw_list)):
    pytrends.build_payload([kw_list[i]], timeframe=timeframe, cat=0, geo='', gprop='')
    out = pytrends.interest_over_time()
    
    out['date'] = out.index
    out['keyword'] = keyword[i]
    out = out.drop(['isPartial'], axis=1)
    
    out.columns = ['score', 'date', 'keyword']
         
    all = pd.concat([all, out])

all.to_csv('DAILYTRENDS.csv', index=False)

all.to_csv('~/aichi1/myapp/public/csvs/DAILYTRENDS.csv', index=False)

