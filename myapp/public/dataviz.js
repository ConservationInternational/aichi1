function updateGraph(data, color, selection, id, n) {
  d3.select('#barchart').html("");

  data = data.map(function (d) {
    return {
      fullname: d.fullname,
      variable: +d[selection],
      geo: d.geo
    };
  });

  var data = data.filter(function(d){
    return (d.variable != 0);
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
    //.on("mouseover", graphMouseOver)
    //.on("mouseout", graphMouseOut);
}

function updateMap(data, color, selection){
  d3.select("#map").html("");

  var sel = data.map(function (d) {
    return {
      fullname: d.fullname,
      variable: +d[selection],
      geo: d.geo
    };
  });

  var mapdat = sel.map(function(d){
    var geoJson = JSON.parse(d.geo);
    geoJson['properties']['variable'] = +d.variable;
    geoJson['properties']['fullname'] = d.fullname;
    return geoJson;
  });

  mapdat = {'type': 'FeatureCollection',
            'features': mapdat};

  var w = 1000;
  var h = 500;

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

  var colorRange = generateColor(color, "#FFFFFF", 10);

  colorFunc = d3.scale.quantile()
    .domain(values)
    .range(colorRange);
  
  var tooltip = d3.select('#map')
    .append("div")
    .style("position", "absolute")
    .style("z-index", "10")
    .style("color", "black")
    .style("font-weight", "bold")
    .style("background-color", "white")
    .style("border", "1px solid #000000")
    .style("border-radius", "15px")
    .style("padding-right", "10px")
    .style("padding-left", "10px")
    .style("visibility", "hidden");
 
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
    })
    .on("mouseover", function(d){
      d3.select(this)
        .style("stroke-width", 2);
      tooltip
        .style("visibility", "visible")
        .text((d.properties.fullname + ': ' +  Math.round(d.properties.variable*10)/10).replace(/: 0$/, ": No Data"))
    })
    .on("mousemove", function(){return tooltip.style("top", (event.pageY-10)+"px").style("left",(event.pageX+10)+"px");})
    .on("mouseout", function(d){
      d3.select(this)
        .style("stroke-width", 0.5);
      tooltip
        .style("visibility", "hidden");
    })
    .on("click", function(d){
      var countryname = d.properties['alpha-2'];
      d3.select('#tschart').html("");
      updateTS(data, countryname);
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

  var maxval = d3.max(mapdat.features, function(d){
    return Math.round(d.properties.variable);
  });

  breaks.push(maxval);

  svg.selectAll(".legend-label")
    .data(breaks)
    .enter().append("text")
    .attr('class', "legend-label")
    .attr("y", 477)
    .attr("x", function(d, i) { return w - (i*ls_w) + ls_w - start - 5; })
    .text(function(d) { return d; });

};

function updateTS(data, country) {
  var parseDate = d3.time.format("%Y-%m");

  console.log(data);

  var tsdata = data.filter(function(d){
    return (d.country == country);
  }).map(function(d) {
    d.month = parseDate.parse(d.month);
    return d;
  }).sort(function(a, b){
    if(a.month > b.month) return -1;
    if(a.month < b.month) return 1;
    return 0;
  });

  var margin = {top: 50, right: 30, bottom: 60, left: 90},
      width = 1000 - margin.left - margin.right,
      height = 618 - margin.top - margin.bottom;

  var x = d3.time.scale()
    .range([0, width]);

  var y = d3.scale.linear()
    .range([height, 0]);

  var xAxis = d3.svg.axis()
    .scale(x)
	.ticks(d3.time.months,tsdata.length)
	//makes the xAxis ticks a little longer than the xMinorAxis ticks
    .tickSize(10)
    .orient("bottom");

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

  var oline = d3.svg.line()
    .x(function(d) { return x(d.month); })
    .y(function(d) { return y(d.overall); })

  var twline = d3.svg.line()
    .x(function(d) { return x(d.month); })
    .y(function(d) { return y(d.twitter); })

  var trline = d3.svg.line()
    .x(function(d) { return x(d.month); })
    .y(function(d) { return y(d.trends); })

  var nline = d3.svg.line()
    .x(function(d) { return x(d.month); })
    .y(function(d) { return y(d.news); })

  // function for the y grid lines
  function make_y_axis() {
    return d3.svg.axis()
      .scale(y)
      .orient("left")
      //.ticks(5)
  }

  var svg = d3.select("#tschart")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  x.domain([d3.min(tsdata, function(d) { return d.month.getTime() - 2.628e+9; }),
            d3.max(tsdata, function(d) { return d.month.getTime() + 2.628e+9; })]);
  y.domain([0, d3.max([].concat(tsdata.map(function(d) { return d.overall; }),
                                tsdata.map(function(d) { return d.twitter; }),
                                tsdata.map(function(d) { return d.trends; }),
                                tsdata.map(function(d) { return d.news; })))]);

  // Draw the y Grid lines
  svg.append("g")
    .attr("class", "grid")
    .call(make_y_axis()
      .tickSize(-width, 0, 0)
      .tickFormat("")
    );

  svg.append("path")
    .datum(tsdata)
    .attr("stroke", "#356d57")
    .attr('fill', "transparent")
    .attr('stroke-width', 5)
    .attr("class", "line")
    .attr("d", oline);
    
 svg.append("path")
    .datum(tsdata)
    .attr("stroke", "#5b5c61")
    .attr('fill', "transparent")
    .attr('stroke-width', 5)
    .attr("class", "line")
    .attr("d", nline);

 svg.append("path")
    .datum(tsdata)
    .attr("stroke", "#E6673e")
    .attr('fill', "transparent")
    .attr('stroke-width', 5)
    .attr("class", "line")
    .attr("d", trline);

 svg.append("path")
    .datum(tsdata)
    .attr("stroke", "#1A5EAB")
    .attr('fill', "transparent")
    .attr('stroke-width', 5)
    .attr("class", "line")
    .attr("d", twline);

  var g = svg.selectAll()
    .data(tsdata).enter().append("g");

  g.append("circle")
    .attr("fill", "#357d57")
    .attr("r", 5)
    .attr("cx", function(d) { return x(d.month); })
    .attr("cy", function(d) { return y(d.overall); })
 
  g.append("circle")
    .attr("fill", "#5b5c61")
    .attr("r", 5)
    .attr("cx", function(d) { return x(d.month); })
    .attr("cy", function(d) { return y(d.news); })

  g.append("circle")
    .attr("fill", "#E6673e")
    .attr("r", 5)
    .attr("cx", function(d) { return x(d.month); })
    .attr("cy", function(d) { return y(d.trends); })
  
  g.append("circle")
    .attr("fill", "#1A5EAB")
    .attr("r", 5)
    .attr("cx", function(d) { return x(d.month); })
    .attr("cy", function(d) { return y(d.twitter); })
 
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
    .selectAll(".tick text");

  svg.append("text")      // text label for the x-axis
    .attr("x", width / 2 )
    .attr("y",  height + margin.bottom)
    .style("text-anchor", "middle")
    .text("Month");

  svg.append("text")      // text label for the y-axis
    .attr("y",30 - margin.left)
    .attr("x",50 - (height / 2))
    .attr("transform", "rotate(-90)")
    .style("text-anchor", "end")
    .style("font-size", "16px")
    .text("Score");

  svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
};
