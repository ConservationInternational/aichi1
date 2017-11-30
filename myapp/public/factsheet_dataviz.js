var select;
var selection;

var data = d3.select('#data').html().trim();
var data = JSON.parse(data);

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
    left: 267
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

function updateMap(data, color){

  var mapdat = data.map(function(d){
    var geoJson = JSON.parse(d.geo);
    geoJson['properties']['variable'] = +d.variable;
    geoJson['properties']['fullname'] = d.fullname;
    return geoJson;
  });

  mapdat = {'type': 'FeatureCollection',
            'features': mapdat};

  var w = 1000;
  var h = 500;

  var minZoom;
  var maxZoom;

  var projection = d3.geo
    .equirectangular()
    .center([0,15])
    .scale([w/(2*Math.PI)])
    .translate([w/2, h/2]);

  var path = d3.geo.path()
    .projection(projection);

  var graticule = d3.geo.graticule();

  var svg = d3.select("#map").append("svg")
    .attr("width", w)
    .attr("height", h);

  var values = mapdat.features.map(function(d) {
    return d.properties.variable;
  });

  var colorRange = generateColor(color, "#FFFFFF", 5 )

  var colorFunc = d3.scale.quantile()
    .domain(values)
    .range(colorRange)
    
  svg.selectAll(".land")
    .data(mapdat.features)
    .enter().append('path')
    .attr('class', 'land')
    .attr('d', path)
    .attr("fill", function(d){
      var out = colorFunc(d.properties.variable);
      //Not sure why this is necessary but it seems to be so
      if (d.properties.variable == 0) {
        out = "#FFFFFF";
      };
      return out;
    });
};

var selection = 'overall';
    
sel = data.map(function (d) {
  return {
    fullname: d.fullname,
    variable: +d[selection],
    geo: d.geo
  };
});

updateGraph(sel, "#1A5EAB");
updateMap(sel, "#357D57");


