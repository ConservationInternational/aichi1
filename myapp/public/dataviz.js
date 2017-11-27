var select;
var selection;

var data = d3.select('#data').html().trim();
var data = JSON.parse(data);

d3.select("#trendsbutton")
  .on("click", function (){
    var selection = 'trends'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection]
      };
    });

    d3.select('#barchart').html("");

    updateGraph(sel, "#357D57");
});

d3.select("#twitterbutton")
  .on("click", function (){
    var selection = 'twitter'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection]
      };
    });

    d3.select('#barchart').html("");

    updateGraph(sel, "#1A5EAB");
});

d3.select("#newsbutton")
  .on("click", function (){
    var selection = 'news'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection]
      };
    });

    d3.select('#barchart').html("");

    updateGraph(sel, "#E6673E");
});

d3.select("#overallbutton")
  .on("click", function (){
    var selection = 'overall'
    
    sel = data.map(function (d) {
      return {
        fullname: d.fullname,
        variable: +d[selection]
      };
    });

    d3.select('#barchart').html("");

    updateGraph(sel, "#5b5c61");
});

function updateGraph(data, color) {
  var data = data.filter(function(d){
    return d.variable != 0;
  });
  
  var data = data.sort(function(a, b){
    if(a.variable > b.variable) return -1;
    if(a.variable < b.variable) return 1;
    return 0;
  });
  
  var countries = data.map(function(d){
    return d.fullname;
  });
  
  var width = 1000;
  var height = 15*countries.length;

  var svg = d3.select('#barchart')
    .append('svg')
    .attr('width', width)
    .attr('height', height);
  
  var margins = {
    top: 70,
    right: 20,
    bottom: 0,
    left: 300
  };
  
  var graphWidth = width - margins.right - margins.left;
  var graphHeight = height - margins.top - margins.bottom;
  
  var chart = svg.append('g')
    .attr('transform', 'translate(' + margins.left + ',' + margins.top + ')');
  
  var x = d3.scale.linear()
    .range([0, graphWidth])
    .domain([0, 100]);
  
  var y = d3.scale.ordinal()
    .domain(countries)
    .rangeBands([0, graphHeight], 0.1, 0.1);
  
  var xAxis = d3.svg.axis()
    .scale(x)
    .orient("top");
  
  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");
  
  chart.append("g")
    .classed("x axis", true)
    .call(xAxis);
  
  chart.append("g")
    .classed("y axis", true)
    .call(yAxis);

  var bars = chart.selectAll('rect.bar')
    .data(data);
  
  bars.enter()
    .append('rect')
    .attr('class', 'bar')
    .attr('width', 0)
    .attr('fill', color);
  
  bars.exit()
    .remove();
  
  bars.attr('x', 0)
    .attr('y', function(d) {
      return y(d.fullname);
    })
    .attr('height', y.rangeBand())
    .transition()
    .attr('width', function(d) {
      return x(d.variable);
    });
}
