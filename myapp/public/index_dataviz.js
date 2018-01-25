
d3.select("#trendsbutton")
  .on("click", function (){
    var selection = 'trends'
    
    updateGraph("#E6673e", selection, "#barchart", 500);
    updateMap("#E6673e", selection);
});

d3.select("#twitterbutton")
  .on("click", function (){
    var selection = 'twitter'
    
    updateGraph("#1A5EAB", selection, "#barchart", 500);
    updateMap("#1A5EAB", selection);
});

d3.select("#newsbutton")
  .on("click", function (){
    var selection = 'news'
    
    updateGraph("#5b5c61", selection, "#barchart", 500);
    updateMap("#5b5c61", selection);
});

d3.select("#overallbutton")
  .on("click", function (){
    var selection = 'overall'
    
    updateGraph("#357d57", selection, "#barchart", 500);
    updateMap("#357d57", selection);
});

