function setupTS(){
   var tstitle = d3.select("#tstitle")
    .text("Time Series Graphs of Data Sources and Overall Indicator");

  var tstext = d3.select("#tstext")
    .text("Select a county and data sources to see a time series graph with scores for each data source in that country.");

  var countries = d3.select('#countriesgeo').html().trim();
  countries = d3.csv.parse(countries, function (d) {
    return d.fullname;
  });

  countries.unshift("Select a Country");

  var tsselect = d3.select("#tsselect")
    .append('select')
    .attr('class', 'select')
    .attr('id', 'countryselect')
    .on('change', onchange)

  var tsoptions = tsselect
    .selectAll('option')
    .data(countries).enter()
    .append('option')
    .text(function (d) {return d; });

  var newsradio = d3.select("#tsbuttons")
    .html('<form>   <div class="ck-button" id="twitterbox">     <label>     <input type="checkbox" id="ckbox" name="tsbox" value="twitter"><span>Twitter</span>     </label>   </div>   <div class="ck-button" id="newsbox">     <label>     <input type="checkbox" id="ckbox" name="tsbox" value="news"><span>Internet Newspapers</span>     </label>   </div>   <div class="ck-button" id="trendsbox">     <label>     <input type="checkbox" id="ckbox" name="tsbox" value="trends"><span>Google Trends</span>     </label>   </div>   <div class="ck-button" id="overallbox">     <label>     <input type="checkbox"  id="ckbox" name="tsbox" value="overall"><span>Overall Indicator</span>     </label>   </div> </form> ')
    .on('change', onchange)

  //Get the month
  var dateStart = moment('2017-11-01');
  var dateEnd = moment();
  var timeValues = [''];
  var timeLabels = ['Select a Month'];

  while (dateEnd > dateStart  || dateStart.format('M') === dateEnd.format("M")){
    timeValues.push(dateStart.format('YYYY-M'));
    timeLabels.push(dateStart.format('MMMM YYYY'));
    dateStart.add(1, 'month');
  }

  var margin = {top: 50, right: 8, bottom: 80, left: 80},
      width = 800 - margin.left - margin.right,
      height = 618 - margin.top - margin.bottom;

  var x = d3.time.scale()
    .range([0, width]);

  var y = d3.scale.linear()
    .range([height, 0]);

  var xAxis = d3.svg.axis()
    .scale(x)
    .tickFormat(d3.time.format("%b %Y"))
	//makes the xAxis ticks a little longer than the xMinorAxis ticks
    .tickSize(10)
    .orient("bottom");

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

  y.domain([0, 5]);

  var svg = d3.select("#tschart")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  x.domain([moment('2017-10-20'), moment().startOf('month').add(10, 'days')]);
  
  var dif = moment().startOf('month').add(10, 'days').diff(moment('2017-10-20'), 'months', true)

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis.ticks(dif))
    .selectAll(".tick text")
    .call(wrap, 35);

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

  timeValues.shift();

  data = timeValues.map(function(d){
    return {
      pmonth: moment(d, 'YYYY-M'),
      twitter: +0,
      trends: +0,
      news: +0,
      overall: +0,
    };
  });

  var circles = svg.selectAll()
    .data(data).enter().append('circle');

  var paths = svg.selectAll()
    .data(data).enter().append('path');

  //Setup Twitter
  var twline = d3.svg.line()
    .x(function(d) { return console.log(x(d.pmonth)); x(d.pmonth); })
    .y(function(d) { return console.log(y(d.twitter)); y(d.twitter); })
  
  paths
    .attr("stroke", "transparent")
    .attr('fill', "transparent")
    .attr('stroke-width', 3)
    .attr("class", "line")
    .attr("d", twline);

  circles
    .attr("fill", "transparent")
    .attr("r", 4)
    .attr("cx", function(d) { return x(d.pmonth); })
    .attr("cy", function(d) { return y(d.twitter); })
 
  //Setup Trends
  var trline = d3.svg.line()
    .x(function(d) { return x(d.pmonth); })
    .y(function(d) { return y(d.trends); })

  paths
    .attr("stroke", "transparent")
    .attr('fill', "transparent")
    .attr('stroke-width', 3)
    .attr("class", "line")
    .attr("d", trline);

  circles
    .attr("fill", "transparent")
    .attr("r", 4)
    .attr("cx", function(d) { return x(d.pmonth); })
    .attr("cy", function(d) { return y(d.trends); })

  //News
  var nline = d3.svg.line()
    .x(function(d) { return x(d.pmonth); })
    .y(function(d) { return y(d.news); })

  paths
    .attr("stroke", "transparent")
    .attr('fill', "transparent")
    .attr('stroke-width', 3)
    .attr("class", "line")
    .attr("d", nline);

  circles
    .attr("fill", "transparent")
    .attr("r", 4)
    .attr("cx", function(d) { return x(d.pmonth); })
    .attr("cy", function(d) { return y(d.news); })

  //Overall
  var oline = d3.svg.line()
    .x(function(d) { return x(d.pmonth); })
    .y(function(d) { return y(d.overall); })

  paths
    .attr("stroke", "transparent")
    .attr('fill', "transparent")
    .attr('stroke-width', 6)
    .attr("class", "line")
    .attr("d", oline);

  circles
    .attr("fill", "transparent")
    .attr("r", 5)
    .attr("cx", function(d) { return x(d.pmonth); })
    .attr("cy", function(d) { return y(d.overall); })
 
  function onchange(){
    var selectCountry = d3.select("#countryselect").property('value');

    var choices = [];
    d3.selectAll("#ckbox").each(function(d){
      cb = d3.select(this);
      if(cb.property("checked")){
        choices.push(cb.property("value"));
      }
    });

   d3.csv('indicator.csv', function(error, tsdata){
      if (error) throw error;

      var tsdata = tsdata.filter(function(d){
        return (d.fullname == selectCountry);
      }).map(function(d) {
        d.pmonth = moment(d.month, 'YYYY-M');
        return d;
      }).sort(function(a, b){
        if(a.pmonth > b.pmonth) return -1;
        if(a.pmonth < b.pmonth) return 1;
        return 0;
      });

      var values = []

      for (var i = 0; i < choices.length; i++) {
        values = values.concat(tsdata.map(function(d) { return +d[choices[i]]; }));
      };

      if (selectCountry == 'Select a Country' | choices.length == 0){
        y.domain([0, 5])
        svg.select(".y")
          .transition()
          .duration(1500)
          .call(yAxis);
        return;
      }

      var max = values.reduce(function(a, b) {
        return Math.max(a, b);
      });

      y.domain([0, max]);

      // Draw the y Grid lines
      svg.select(".y")
        .transition()
        .duration(1500)
        .call(yAxis);  

      if (choices.indexOf('twitter') > -1){
        var twline = d3.svg.line()
          .x(function(d) { return x(d.pmonth); })
          .y(function(d) { return y(d.twitter); })

        /*paths.selectAll("path")
          .transition()
          .duration(1500)
          .attr("stroke", "#1A5EAB")
          .attr('fill', "transparent")
          .attr('stroke-width', 3)
          .attr("class", "line")
          .attr("d", twline);
*/
        circles.selectAll("circle")
          .transition()
          .duration(1500)
          .attr("fill", "#1A5EAB")
          .attr("r", 4)
          .attr("cx", function(d) { return x(d.pmonth); })
          .attr("cy", function(d) { return y(d.twitter); })
      };

    
      if (choices.indexOf('trends') > -1){
         var trline = d3.svg.line()
          .x(function(d) { return x(d.pmonth); })
          .y(function(d) { return y(d.trends); })
    
        paths.selectAll("path")
          .transition()
          .duration(1500)
          .attr("stroke", "#E6673e")
          .attr('fill', "transparent")
          .attr('stroke-width', 3)
          .attr("class", "line")
          .attr("d", trline);
    
        circles.selectAll("circle")
          .transition()
          .duration(1500)
          .attr("fill", "#E6673e")
          .attr("r", 4)
          .attr("cx", function(d) { return x(d.pmonth); })
          .attr("cy", function(d) { return y(d.trends); })
     
      };
    
      if (choices.indexOf('news') > -1){
        var nline = d3.svg.line()
          .x(function(d) { return x(d.pmonth); })
          .y(function(d) { return y(d.news); })
    
        paths.selectAll("path")
          .transition()
          .duration(1500)
          .attr("stroke", "#5b5c61")
          .attr('fill', "transparent")
          .attr('stroke-width', 3)
          .attr("class", "line")
          .attr("d", nline);
    
        circles.selectAll("circle")
          .transition()
          .duration(1500)
          .attr("fill", "#5b5c61")
          .attr("r", 4)
          .attr("cx", function(d) { return x(d.pmonth); })
          .attr("cy", function(d) { return y(d.news); })
      };
    
      if (choices.indexOf('overall') > -1){
        var oline = d3.svg.line()
          .x(function(d) { return x(d.pmonth); })
          .y(function(d) { return y(d.overall); })
    
        paths.selectAll("path")
          .transition()
          .duration(1500)
          .attr("stroke", "#356d57")
          .attr('fill', "transparent")
          .attr('stroke-width', 6)
          .attr("class", "line")
          .attr("d", oline);
    
        circles.selectAll("circle")
          .transition()
          .duration(1500)
          .attr("fill", "#357d57")
          .attr("r", 5)
          .attr("cx", function(d) { return x(d.pmonth); })
          .attr("cy", function(d) { return y(d.overall); })
      };
    });  
  };
};

function wrap(text, width) {
  text.each(function() {
    var text = d3.select(this),
        words = text.text().split(/\s+/).reverse(),
        word,
        line = [],
        lineNumber = 0,
        lineHeight = 1.1, // ems
        y = text.attr("y"),
        dy = parseFloat(text.attr("dy")),
        tspan = text.text(null).append("tspan").attr("x", 0).attr("y", y).attr("dy", dy + "em");
    while (word = words.pop()) {
      line.push(word);
      tspan.text(line.join(" "));
      if (tspan.node().getComputedTextLength() > width) {
        line.pop();
        tspan.text(line.join(" "));
        line = [word];
        tspan = text.append("tspan").attr("x", 0).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
      }
    }
  });
}

function setupMap(){ 
  //Update text for header and 
  var maptitle = d3.select("#maptitle")
    .text("Map of Data Sources and Overall Indicator By Country");

  var maptext = d3.select("#maptext")
    .text("Select a data source and a month to see a world map and a barchart with scores for a given month for each country.");

  //Get the month
  var dateStart = moment('2017-11-01');
  var dateEnd = moment();
  var timeValues = [''];
  var timeLabels = ['Select a Month'];

  while (dateEnd > dateStart  || dateStart.format('M') === dateEnd.format("M")){
    timeValues.push(dateStart.format('YYYY-M'));
    timeLabels.push(dateStart.format('MMMM YYYY'));
    dateStart.add(1, 'month');
  }

  var mselect = d3.select("#mapselect")
    .append('select')
    .attr('class', 'select')
    .attr('id', 'monthselect')
    .on('change', onchange)

  var moptions = mselect
    .selectAll('option')
    .data(timeLabels).enter()
    .append('option')
    .text(function (d) {return d; });

  //Create thematic dropdown 
  var dataoptions = [{'label': "Select a Data Source", 'color': 'color:#000000'},
		     {'label': "Twitter Data", 'color': "color:#1A5EAB"},
                     {'label': "Internet Newspaper Data", "color": "color:#5b5c62"},
                     {'label': "Google Trends Data", "color": "color:#e6673e"},
                     {'label': "Overall Indicator", "color": "color:#357d57"}];

  var select = d3.select("#mapselect")
    .append('select')
    .attr('class','select')
    .attr('id', 'varselect')
    .on('change',onchange)

  var options = select
    .selectAll('option')
    .data(dataoptions).enter()
    .append('option')
    .text(function (d) { return d.label; })
    .attr('style', function(d) {return d.color});

  //////////////////////
  //Setup Map Here
  //////////////////////
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

  var projection = d3.geo
    .equirectangular()
    .center([0,15])
    .scale([w/(2*Math.PI)])
    .translate([w/2, h/2]);

  var path = d3.geo.path()
    .projection(projection);

  var graticule = d3.geo.graticule();

  var mapsvg = d3.select("#map").append("svg")
    .attr("width", w)
    .attr("height", h);

  mapsvg.selectAll(".land")
    .data(mapdat.features)
    .enter().append('path')
    .attr('id', function(d){
      return d.properties['alpha-2'];
    })
    .attr('class', 'land')
    .attr('d', path)
    .attr('fill', '#FFFFFF');


  ///////////////////////
  //Setup Bar Graph here
  /////////////////////
  
  var countries = geodata.map(function(d){
    return(d.fullname);
  });

  var width = 1000;
  var height = 18*countries.length;

  var svg = d3.select('#barchart')
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
    .attr('class', 'xaxis')
    .call(xAxis);
  
  chart.append("g")
    .attr('class', 'yaxis')
    .style("font", "12px times")
    .call(yAxis);

  var bars = chart.selectAll('rect.bar')
    .data(geodata.map(function(d){
       return {
         fullname: d.fullname,
         country: d.country,
       };
     }))
    .enter()
    .append('rect')
    .attr('width', 0)
    .attr('id', function(d){
      return d.country;
    })
    .attr('y', function(d){
      return y(d.fullname);
    })
    .attr('fill', '#FFFFFF');

  function onchange() {
    var monthLabel = d3.select('#monthselect').property('value');
    var monthyear = timeValues[timeLabels.indexOf(monthLabel)]

    var varValue = d3.select("#varselect").property('value');

    if (monthLabel == 'Select a Month' | varValue == 'Select a Data Source'){
      return;
    }
    
    if(varValue == "Twitter Data"){
      var color = "#1a5eab";
      var selection = "twitter";
    }
    if(varValue == "Internet Newspaper Data"){
      var color = "#5b5c61";
      var selection = "news";
    }
    if(varValue == "Google Trends Data"){
      var color = "#E6673e";
      var selection = "trends";
    }
    if(varValue == "Overall Indicator"){
      var color = "#357d57";
      var selection = "overall";
    }

    d3.csv('indicator.csv', function(error, data){
      if (error) throw err;

      data = data.filter(function (d) {
        return (d.month == monthyear);
      }).map(function (d) {
        return {
          country: d.country,
          fullname: d.fullname,
          variable: +d[selection],
        };
      });

      ///////////////////
      //Barchart Action
      ////////////////////

 
      var bardata = data;//.filter(function(d){
      //  return (d.variable != 0);
      //});
     
      var bardata = bardata.sort(function(a, b){
        if(a.variable > b.variable) return -1;
        if(a.variable < b.variable) return 1;
        return 0;
      });
   
      var newcountries = bardata.map(function(d){
        return d.fullname;
      });


      var height = 18*newcountries.length;
      var graphHeight = height - margins.top - margins.bottom;
  
      var y = d3.scale.ordinal()
        .domain(newcountries)
        .rangeBands([0, graphHeight], 0.1, 0.1);

      var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

      chart.select(".yaxis")
        .transition()
        .duration(1500)
        .call(yAxis);

      bars.each(function(d){
           var variable = bardata.filter(function(cc){
             return cc.country == d.country;
           })
           d.variable = variable[0].variable;
        })
        .attr('class', 'bar')
     
      var colorRange = generateColor(color, "#FFFFFF", 10);
    
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
    
      bars
        .on("mouseover", function(d){
          d3.select(this)
            .style("fill", colorRange[5]);
          tooltip
            .style("visibility", "visible")
            .text((d.fullname + ': ' +  Math.round(d.variable*10)/10).replace(/: 0$/, ": No Data"))
        })
        .on("mousemove", function(){return tooltip.style("top", (event.pageY-10)+"px").style("left",(event.pageX+10)+"px");})
        .on("mouseout", function(d){
          d3.select(this)
            .style("fill", color);
          tooltip
            .style("visibility", "hidden");
        })
        .transition()
        .duration(1500)
        .attr('y', function(d) {
          return y(d.fullname);
        })
        .attr('height', y.rangeBand())
        .attr('width', function(d) {
          if (d.variable == 'NaN'){
            d.variable = 0;
          }
          return x(d.variable);
        })
        .attr('fill', color)    
 

      //////////////////////
      //Map Action
      ////////////////////
    
      var values = data.map(function(d) {
        return d.variable;
      });

      var colorRange = generateColor(color, "#FFFFFF", 10);
    
      colorFunc = d3.scale.quantile()
        .domain(values)
        .range(colorRange);

      mapsvg.selectAll('.land')
        .each(function(d){
          var country = data.filter(function(c){
            return c.country == d.properties['alpha-2']
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
        })
        .on("mouseover", function(d){
          d3.select(this)
            .style("stroke-width", 2);
          tooltip
            .style("visibility", "visible")
            .text((d.properties.fullname + ': ' +  Math.round(d.variable*10)/10).replace(/: 0$/, ": No Data"))
        })
        .on("mousemove", function(){return tooltip.style("top", (event.pageY-10)+"px").style("left",(event.pageX+10)+"px");})
        .on("mouseout", function(d){
          d3.select(this)
            .style("stroke-width", 0.5);
          tooltip
            .style("visibility", "hidden");
        })
    
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
    
      d3.selectAll(".legend").remove();

      d3.selectAll(".legend-label").remove();

      var legend = mapsvg.selectAll("legend")
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
        return Math.round(d.variable);
      });
    
      breaks.push(maxval);
    
      mapsvg.selectAll(".legend-label")
        .html('')
        .data(breaks)
        .enter().append("text")
        .attr('class', "legend-label")
        .attr("y", 477)
        .attr("x", function(d, i) { return w - (i*ls_w) + ls_w - start - 5; })
        .text(function(d) { return d; });
    });
  };
};


