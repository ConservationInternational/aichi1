function updateGraph(data, color, id, n) {
  var data = data.filter(function(d){
    return d.variable != 0;
  });
  
  var data = data.sort(function(a, b){
    if(a.variable > b.variable) return -1;
    if(a.variable < b.variable) return 1;
    return 0;
  });

  var data = data.slice(0, n);
  
  var countries = data.map(function(d){
    return d.fullname;
  });
  
  var width = 1000;
  var height = 15*countries.length;

  var svg = d3.select(id)
    .append('svg')
    .attr('width', width)
    .attr('height', height);
  
  var margins = {
    top: 22,
    right: 20,
    bottom: 0,
    left:100, 
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

  var geodata = d3.select('#countriesgeo').html().trim();
  geodata = d3.csv.parse(geodata, function (d) {
    return {
      fullname: d.fullname,
      country: d.country,
      geo: d.geo,
    };
  });
  
  var mapdat = geodata.map(function(d){
    var geoJson = JSON.parse(d.geo);
    geoJson['properties']['country'] = d.country;
    geoJson['properties']['fullname'] = d.fullname;
    return geoJson;
  });
  
  mapdat = {'type': 'FeatureCollection',
  		'features': mapdat} 

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

  var values = data.map(function(d) {
    return d.variable;
  });

  var colorRange = generateColor(color, "#FFFFFF", 10);

  colorFunc = d3.scale.quantile()
    .domain(values)
    .range(colorRange);
    
  svg.selectAll(".land")
    .data(mapdat.features)
    .enter().append('path')
    .attr('class', 'land')
    .attr('d', path)
    .each(function(d){
      var country = data.filter(function(c){
        return c.fullname == d.properties['fullname']
      })
      d.variable = country[0].variable;
    })
    .attr("fill", function(d){
      var out = colorFunc(d.variable);
      //Not sure why this is necessary but it seems to be so
      if (d.variable == 0) {
        out = "#FFFFFF";
      };
      return out;
    });

  var ls_w = 90, ls_h = 20;

  qrange = function(func) {
    var a = [0];
    for (var i=0; i<100; i++) {
      if (func(i) != func(i + 1)){
        a.push(i + 1);
      }
    }
    return a;
  }

  var breaks = qrange(colorFunc);

  var legend = svg.selectAll("legend")
    .data(breaks)
    .enter().append("g")
    .attr("class", "legend");

  var start = (w - ls_w*breaks.length + ls_w)/2

  legend.append("rect")
    .attr("y", 480)
    .attr("x", function(d, i){ return w - (i*ls_w) - start;})
    .attr("width", ls_w)
    .attr("height", ls_h)
    .style("fill", function(d, i) { return colorFunc(d); })

  breaks.push(100);

  svg.selectAll(".legend-label")
    .data(breaks)
    .enter().append("text")
    .attr('class', "legend-label")
    .attr("y", 477)
    .attr("x", function(d, i) { return w - (i*ls_w) + ls_w - start - 5; })
    .text(function(d) { return d; });

};

$('#id1 p').each(function() {
    var text = $(this).text();
    $(this).text(text.replace('MONTH YEAR', moment().format('MMMM YYYY'))); 
});

d3.csv('indicator.csv', function(error, data){
  if (error) throw err;

  var monthyear = moment().format('YYYY-M')
  
  data = data.filter(function (d) {
	return (d.month == monthyear);
  });
  
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
});
