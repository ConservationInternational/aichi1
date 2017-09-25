from instagram.client import InstagramAPI

access_token = ""
client_secret = ""
api = InstagramAPI(access_token=access_token, client_secret=client_secret)

locations = api.location_search(lat=40.7588959, lng=-73.9852126, distance=750)

for i in locations:
    l_id = i.id
    print(l_id + ' ' + i.name)
    print(api.location_recent_media(location_id=l_id))

api.media_search(lat=40.7588959, lng=-73.9852126)

