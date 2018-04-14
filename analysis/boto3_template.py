import boto3
import json


s3client = boto3.client('s3')
s3resource = boto3.resource('s3')

paginator = s3client.get_paginator('list_objects')
pages = paginator.paginate(Bucket='catch-species')
files = []
for p in pages:
    for x in p['Contents']:
        files.append(x['Key'])


content_object = s3resource.Object('catch-species', files[0])
file_content = content_object.get()['Body'].read().decode('utf-8')
json_content = json.loads(file_content)