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
		db.collection("country-language").find({}).toArray(function(err, result) {
			if (err) throw err;
			res.write(result.sort(function(a, b){
						    if(a.country < b.country) return -1;
						    if(a.country > b.country) return 1;
						    return 0;
						}).map(i => i.country + '-' + i.lang + ' ' + i.count).join('\n'));
			res.end();
			db.close();
		});
	});
}).listen(8080);
