var path = require('path');
var express = require('express');
var logger = require('morgan');
var app = express();

// Log the requests
app.use(logger('dev'));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Route for everything else.
app.get('/Biodiversity Engagement Indicator.pdf', function(req, res){
  var file = __dirname + 'public/Biodiveristy Engagement Indicator.pdf';
  res.download(file);
});

// Fire it up!
app.listen(3000);
console.log('Listening on port 3000');
