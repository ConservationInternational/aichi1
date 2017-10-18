import pandas as pd

cities = pd.read_csv('D://Documents and Settings/mcooper/GitHub/aichi1/build_geolocation_database/cities15000.txt', sep='\t', quoting=3, 
                     names=['geonameid','name','asciiname','alternatenames','latitude','longitude','feature_class','feature_code','country','cc2','admin1_code','admin2_code','admin3_code','admin4_code','population','elevation','dem','timezone','modification date'])

#sort by population ascending, so it alwasy goes with the biggest one
cities = cities[cities['population'] > 20000].sort_values(['population'])
cities['city'] = cities['name']
cities['admin'] = ''
cities = cities[['city', 'admin', 'asciiname', 'alternatenames','country']]

alladmin = pd.read_csv('D://Documents and Settings/mcooper/GitHub/aichi1/build_geolocation_database/allCountries.txt', sep='\t',
                       quoting=3, names=['geonameid','name','asciiname','alternatenames','latitude','longitude','feature_class','feature_code','country','cc2','admin1_code','admin2_code','admin3_code','admin4_code','population','elevation','dem','timezone','modification date'])

#PCLI = countries
#ADM1 = admin 1
#ADM2 = admin 2

country = alladmin[alladmin['feature_code'].isin(['PCLI'])]
country['admin'] = country['name']
country['city'] = ''
country = country[['city', 'admin', 'asciiname', 'alternatenames', 'country']]

admin = alladmin[alladmin['feature_code'].isin(['ADM1', 'ADM2'])]
admin['admin'] = admin['name']
admin['city'] = ''
admin = admin[['city', 'admin', 'asciiname', 'alternatenames', 'country']]
admin = admin[pd.notnull(admin.country)]
admin = admin.sort_values('country')


dat = pd.concat([admin, cities, country])

#make aliases
dat['comma'] = ','
dat.alternatenames.fillna(dat.admin, inplace=True)
dat['aliases'] = (dat['admin'] + dat['comma'] + dat['asciiname'] + dat['comma'] + dat['alternatenames']).apply(lambda x: str(x).split(','))
dat['id'] = map(str, range(0, dat.shape[0]))

dat = dat[['city', 'admin', 'asciiname', 'aliases','country', 'id']]

#write json
f = open('D:/Documents and Settings/mcooper/GitHub/carmen-python/carmen/data/locations.json', 'w')

for row in dat[['city', 'admin', 'country', 'aliases', 'id']].iterrows():
    row[1].to_json(f, force_ascii=False)
    f.write('\n')

f.close()
