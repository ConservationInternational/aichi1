var news;
var twitter;

d3.csv("twitter.csv", function(d) {
  return {
    country : d.country,
    month : d.month,
    twitter : +d.twitterrate
  };
}, function(data) {
  twitter = data;
});

d3.csv("news.csv", function(d) {
  return {
    country : d.country,
    month : d.month,
    news : +d.newsrate
  };
}, function(data) {
  news = data;
});

//Test barchart

var width = 500;
var height = 400;

var svg = d3.select('.barchart')
  .append('svg')
  .attr('width', width)
  .attr('height', height);

var max_twitter = d3.max(twitter, function(d) {
  return d.twitter;
});
