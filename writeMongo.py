import pymongo
from pymongo import MongoClient

client = MongoClient()

client = MongoClient('localhost', 27017)

db = client.TWITTER.test_lang

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

	
	
