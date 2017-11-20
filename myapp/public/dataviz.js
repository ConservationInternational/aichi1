var data = d3.select('#data').html().trim();
  data = d3.csv.parse(data, function (d) {
    return {
      fullname: d.fullname,
      month: d.month,
      trends: +d.trends,
      twitter: +d.twitter,
      news: +d.news,
      overall: +d.overall
    };
  });

var data = data.filter(function(d){
  return d.overall != 0;
});

var data = data.sort(function(a, b){
  if(a.overall > b.overall) return -1;
  if(a.overall < b.overall) return 1;
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
  top: 25,
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
  .attr('width', 0);

bars.exit()
  .remove();

bars.attr('x', 0)
  .attr('y', function(d) {
    return y(d.fullname);
  })
  .attr('height', y.rangeBand())
  .transition()
  .attr('width', function(d) {
    return x(d.overall);
  });
