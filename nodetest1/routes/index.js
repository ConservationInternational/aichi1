var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

/* GET Hello World page. */
router.get('/helloworld', function(req, res) {
    res.render('helloworld', { title: 'Hello, World!' });
});

router.get('/data', function(req, res) {
    var db = req.db;
    var twitter = db.get('TWITTER-BASELINE').aggregate([ 
	{$project : {"country": "$country",
             "day": "$day",     
             "twitter-rate" : {$divide: ['$any', '$baseline']}
    }}]);
    res.send(twitter);    
});

module.exports = router;
