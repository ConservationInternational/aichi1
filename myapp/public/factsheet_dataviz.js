var data = d3.select('#data').html().trim();
var data = JSON.parse(data);

var selection = 'overall';
    
sel = data.map(function (d) {
  return {
    fullname: d.fullname,
    variable: +d[selection],
    geo: d.geo
  };
});

updateGraph(sel, "#357D57", "#overallchart", 10);
updateMap(sel, "#357D57");


var selection = 'twitter';
    
sel = data.map(function (d) {
  return {
    fullname: d.fullname,
    variable: +d[selection],
    geo: d.geo
  };
});

updateGraph(sel, "#1A5EAB", "#twitterchart", 10);

var selection = 'news';
    
sel = data.map(function (d) {
  return {
    fullname: d.fullname,
    variable: +d[selection],
    geo: d.geo
  };
});

updateGraph(sel, "#5b5c61", "#newschart", 10);

var selection = 'trends';
    
sel = data.map(function (d) {
  return {
    fullname: d.fullname,
    variable: +d[selection],
    geo: d.geo
  };
});

updateGraph(sel, "#E6673E", "#trendschart", 10);
