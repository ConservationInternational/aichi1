var http = require('http');
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/TWITTER";

Array.prototype.sortOn = function(key){
    this.sort(function(a, b){
        if(a[key] < b[key]){
            return -1;
        }else if(a[key] > b[key]){
            return 1;
        }
        return 0;
    });
}


http.createServer(function (req, res) {
	MongoClient.connect(url, function(err, db) {
		if (err) throw err;
		var twitter = db.getCollection('TWITTER-BASELINE').aggregate([ 
{$project : {"country": "$country",
             "day": "$day",     
             "twitter-rate" : {$divide: ['$any', '$baseline']}
             }}]);
		var news = db.getCollection('WEBHOSE-BASELINE').aggregate([
{$match : {baseline: {$ne: 0}}},
{$project : {"country": "$country",
             "day": "$day",     
             "webhose-rate" : {$divide: ['$any', '$baseline']}
             }}]);
			res.end();
			db.close();
		});
	});
}).listen(8080);
