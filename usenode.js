var http = require('http');
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/TWITTER";

http.createServer(function (req, res) {
	MongoClient.connect(url, function(err, db) {
		if (err) throw err;
		db.collection("test_langdef.posts").find({}).toArray(function(err, result) {
			if (err) throw err;
			res.write(result.map(i => i.lang + ' ' + i.count).join('\n'));
			res.end();
			db.close();
		});
	});
}).listen(8080);
