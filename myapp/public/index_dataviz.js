var data = d3.select('#data').html().trim();
var data = JSON.parse(data);

//Get current date
var d = new Date();
d.setDate(d.getDate() - 3); //Add a three day lag because of webhose.io
var year = d.getFullYear();
var month = d.getUTCMonth() + 1;
var monthyear = year + '-' + month;

d3.select("#trendsbutton")
  .on("click", function (){
    var selection = 'trends'
    
    updateGraph(data, "#E6673e", selection, "#barchart", 500);
    updateMap(data, "#E6673e", selection);
});

d3.select("#twitterbutton")
  .on("click", function (){
    var selection = 'twitter'
    
    updateGraph(data, "#1A5EAB", selection, "#barchart", 500);
    updateMap(data, "#1A5EAB", selection);
});

d3.select("#newsbutton")
  .on("click", function (){
    var selection = 'news'
    
    updateGraph(data, "#5b5c61", selection, "#barchart", 500);
    updateMap(data, "#5b5c61", selection);
});

d3.select("#overallbutton")
  .on("click", function (){
    var selection = 'overall'
    
    updateGraph(data, "#357d57", selection, "#barchart", 500);
    updateMap(data, "#357d57", selection);
});

