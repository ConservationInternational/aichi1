import boto3
import json
import carmen

s3client = boto3.client('s3')
s3resource = boto3.resource('s3')

paginator = s3client.get_paginator('list_objects')
pages = paginator.paginate(Bucket='catch-twitter-sample')
files = []
for p in pages:
    for x in p['Contents']:
        files.append(x['Key'])

locations = []
for f in files:		
	content_object = s3resource.Object('catch-twitter-sample', f)
	file_content = content_object.get()['Body'].read().decode('utf-8')
	out = json.loads(file_content)
	
	if out.keys() == ['delete']:
		pass
	else:
		country = resolver.resolve_tweet(out)
		if country:
			country = country[1].country
		
		locations.append(country)
	
	print(files.index(f))



