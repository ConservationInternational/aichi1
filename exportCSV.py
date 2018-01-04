import pandas as pd
from pymongo import MongoClient
import boto3

s3 = boto3.resource('s3')
client = MongoClient('localhost', 27017)

def writeDfToS3Csv(df, name):
    s3.Bucket('ci-tweet-csv-dumps').put_object(Key=name + '.csv', Body=df.to_csv(index=False))

def getDfFromMongo(conname):
    temp = []
    for i in client.TWITTER[c].find():
        temp.append(i)
    df = pd.DataFrame(temp)
    del df['_id']
    return df

for c in ['TRENDS', 'TWITTER-BASELINE', 'TWITTER-DETAIL', 'WEBHOSE-BASELINE', 'WEBHOSE-DETAIL']:
    df = getDfFromMongo(c)
    writeDfToS3Csv(df, c)

