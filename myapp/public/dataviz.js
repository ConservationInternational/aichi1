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

console.log(twitter)
