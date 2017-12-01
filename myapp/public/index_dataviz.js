var data = d3.select('#data').html().trim();
var data = JSON.parse(data);

d3.select("#trendsbutton")
  .on("click", function (){
    var selection = 'trends'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection],
	geo: d.geo
      };
    });

    d3.select('#barchart').html("");
    d3.select('#map').html("");

    updateGraph(sel, "#E6673e", "#barchart", 500);
    updateMap(sel, "#E6673e");
});

d3.select("#twitterbutton")
  .on("click", function (){
    var selection = 'twitter'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection],
	geo: d.geo
      };
    });

    d3.select('#barchart').html("");
    d3.select('#map').html("");

    updateGraph(sel, "#1A5EAB", "#barchart", 500);
    updateMap(sel, "#1A5EAB");
});

d3.select("#newsbutton")
  .on("click", function (){
    var selection = 'news'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection],
	geo: d.geo
      };
    });

    d3.select('#barchart').html("");
    d3.select('#map').html("");

    updateGraph(sel, "#5b5c61", "#barchart", 500);
    updateMap(sel, "#5b5c61");
});

d3.select("#overallbutton")
  .on("click", function (){
    var selection = 'overall'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection],
	geo: d.geo
      };
    });

    d3.select('#barchart').html("");
    d3.select('#map').html("");

    updateGraph(sel, "#357d57", "#barchart", 500);
    updateMap(sel, "#357d57");
});

