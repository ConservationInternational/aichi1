var MongoClient = require('mongodb').MongoClient;
var url = "mongodb:localhost:27017/TWEETS";

MongoClient.connect(url, function(err, db) {
	if (err) throw err;
	db.collection("test_langdef").find({}).toArray(function(err, result) {
		if (err) throw err;
		console.log(result);
		db.close();
	});
});