var http = require('http');
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/TWITTER";

http.createServer(function (req, res) {
	MongoClient.connect(url, function(err, db) {
		if (err) throw err;
		db.collection('TWITTER-BASELINE').aggregate([{"$group" : {"_id": {"month" : '$month', 
										  "country": "$country"}, 
									  "basecount" : {"$sum" : '$baseline'}, 
									  "anycount" : {"$sum": "$any"}}},
							     {"$project" : {'twitterrate' : { "$divide": ["$anycount", "$basecount"]}}}
			]).toArray(function(err, result) {
				if (err) throw err;
				res.write('country,month,twitterrate\n' + result.map(i =>
							i._id['country'] + ',' + 
							i._id['month'] + ',' +  
							i.twitterrate).join('\n'));
				res.end();
				db.close();
		});
	});
}).listen(8080);

http.createServer(function (req, res) {
	MongoClient.connect(url, function(err, db) {
		if (err) throw err;
		db.collection('WEBHOSE-BASELINE').aggregate([{"$group" : {"_id": {"month" : '$month', 
										  "country": "$country"}, 
									  "basecount" : {"$sum" : '$baseline'}, 
									  "anycount" : {"$sum": "$any"}}},
							     {"$project" : {'newsrate' : { "$divide": ["$anycount", "$basecount"]}}}
			]).toArray(function(err, result) {
				if (err) throw err;
				res.write('country,month,newsrate\n' + result.map(i =>
							i._id['country'] + ',' + 
							i._id['month'] + ',' +  
							i.newsrate).join('\n'));
				res.end();
				db.close();
		});
	});
}).listen(8081);

