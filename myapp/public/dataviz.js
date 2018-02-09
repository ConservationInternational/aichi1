function setupTS(){
   var tstitle = d3.select("#tstitle")
    .text("Time Series Graphs of Data Sources and Overall Indicator");

  var tstext = d3.select("#tstext")
    .text("Select a county and data sources to see a time series graph with scores for each data source in that country.");

  var countries = ["Select a Country", "Afghanistan", "Åland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antigua & Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia & Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Cook Islands", "Costa Rica", "Côte d’Ivoire", "Croatia", "Cuba", "Curaçao", "Cyprus", "Czechia", "Congo - Kinshasa", "Denmark", "Djibouti", "Dominican Republic", "Dominica", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Islas Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea-Bissau", "Guinea", "Guyana", "Haiti", "Heard Island & McDonald Islands", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia (FYROM)", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar (Burma)", "Namibia", "Nauru", "Nepal", "Netherlands", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "North Korea", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Congo - Brazzaville", "Réunion", "Romania", "Russia", "Rwanda", "St. Barthélemy", "St. Martin", "St. Helena", "St. Kitts & Nevis", "St. Lucia", "St. Pierre & Miquelon", "St. Vincent & Grenadines", "Samoa", "San Marino", "São Tomé & Príncipe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Sint Maarten", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia & South Sandwich Islands", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard & Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad & Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks & Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States Minor Outlying Islands", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "U.S. Virgin Islands", "Wallis & Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]

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
    .on('change', buttonchange)

  var choices = [];

  function onchange(){
    selectCountry = d3.select("#countryselect").property('value');
    updateTS(selectCountry, choices);
  }

  function buttonchange(){
    choices = [];
    d3.selectAll("#ckbox").each(function(d){
      cb = d3.select(this);
      if(cb.property("checked")){
        choices.push(cb.property("value"));
      }
    });
    updateTS(selectCountry, choices);
  };
};

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

  function onchange() {
    var monthLabel = d3.select('#monthselect').property('value');
    var monthValue = timeValues[timeLabels.indexOf(monthLabel)]

    var varValue = d3.select("#varselect").property('value');
    
    if(varValue == "Twitter Data"){
      updateMap("#1A5EAB", "twitter", monthValue)
    }
    if(varValue == "Internet Newspaper Data"){
      updateMap("#5b5c61", "news", monthValue)
    }
    if(varValue == "Google Trends Data"){
      updateMap("#E6673e", "trends", monthValue)
    }
    if(varValue == "Overall Indicator"){
      updateMap("#357d57", "overall", monthValue)
    }
  };
};

function updateGraph(color, selection, id, n, monthyear) {
  d3.select(id)
    .html("");

  d3.csv('indicator.csv', function(error, data){
    if (error) throw err;

  d3.select('#barchart').html("");

  data = data.filter(function (d) {
    return (d.month == monthyear);
  }).map(function (d) {
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
  var height = 12*countries.length;

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
    .style("font", "9px times")
    .classed("y axis", true)
    .call(yAxis);

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
    .attr('width', function(d) {
      return x(d.variable);
    })
});
}

function updateMap(color, selection, monthyear){
  d3.select("#map").
    html("");
  d3.select("#barchart").
    html("");

  d3.csv('indicator.csv', function(error, data){
    if (error) throw error;

  d3.select("#map").html("");

  var sel = data.filter(function(d){
    return(d.month == monthyear);
  }).map(function (d) {
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

  updateGraph(color, selection, "#barchart", 500, monthyear)
});
};

function updateTS(country, selection) {
  d3.select("#tschart")
    .html("");

  d3.csv('indicator.csv', function(error, tsdata){
    if (error) throw error;

  var parseDate = d3.time.format("%Y-%m");

  var tsdata = tsdata.filter(function(d){
    return (d.fullname == country);
  }).map(function(d) {
    d.pmonth = parseDate.parse(d.month);
    return d;
  }).sort(function(a, b){
    if(a.pmonth > b.pmonth) return -1;
    if(a.pmonth < b.pmonth) return 1;
    return 0;
  });

 
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

  // function for the y grid lines
  function make_y_axis() {
    return d3.svg.axis()
      .scale(y)
      .orient("left")
      //.ticks(5)
  }

  var values = [];

  for (var i = 0; i < selection.length; i++) {
    values = values.concat(tsdata.map(function(d) { return +d[selection[i]]; }));
  }

  y.domain([0, d3.max(values)]);

  var svg = d3.select("#tschart")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  x.domain([moment('2017-10-20'), moment()]);
  
  // Draw the y Grid lines
  svg.append("g")
    .attr("class", "grid")
    .call(make_y_axis()
      .tickSize(-width, 0, 0)
      .tickFormat("")
    );  

  var g = svg.selectAll()
    .data(tsdata).enter().append("g");

  if (selection.indexOf('twitter') > -1){
    var twline = d3.svg.line()
      .x(function(d) { return x(d.pmonth); })
      .y(function(d) { return y(d.twitter); })

    svg.append("path")
      .datum(tsdata)
      .attr("stroke", "#1A5EAB")
      .attr('fill', "transparent")
      .attr('stroke-width', 3)
      .attr("class", "line")
      .attr("d", twline);

    g.append("circle")
      .attr("fill", "#1A5EAB")
      .attr("r", 4)
      .attr("cx", function(d) { return x(d.pmonth); })
      .attr("cy", function(d) { return y(d.twitter); })
  }

  if (selection.indexOf('trends') > -1){
     var trline = d3.svg.line()
      .x(function(d) { return x(d.pmonth); })
      .y(function(d) { return y(d.trends); })

    svg.append("path")
      .datum(tsdata)
      .attr("stroke", "#E6673e")
      .attr('fill', "transparent")
      .attr('stroke-width', 3)
      .attr("class", "line")
      .attr("d", trline);

    g.append("circle")
      .attr("fill", "#E6673e")
      .attr("r", 4)
      .attr("cx", function(d) { return x(d.pmonth); })
      .attr("cy", function(d) { return y(d.trends); })
 
  }

  if (selection.indexOf('news') > -1){
    var nline = d3.svg.line()
      .x(function(d) { return x(d.pmonth); })
      .y(function(d) { return y(d.news); })

    svg.append("path")
      .datum(tsdata)
      .attr("stroke", "#5b5c61")
      .attr('fill', "transparent")
      .attr('stroke-width', 3)
      .attr("class", "line")
      .attr("d", nline);

    g.append("circle")
      .attr("fill", "#5b5c61")
      .attr("r", 4)
      .attr("cx", function(d) { return x(d.pmonth); })
      .attr("cy", function(d) { return y(d.news); })
  }

  if (selection.indexOf('overall') > -1){
    var oline = d3.svg.line()
      .x(function(d) { return x(d.pmonth); })
      .y(function(d) { return y(d.overall); })

    svg.append("path")
      .datum(tsdata)
      .attr("stroke", "#356d57")
      .attr('fill', "transparent")
      .attr('stroke-width', 6)
      .attr("class", "line")
      .attr("d", oline);

     g.append("circle")
      .attr("fill", "#357d57")
      .attr("r", 5)
      .attr("cx", function(d) { return x(d.pmonth); })
      .attr("cy", function(d) { return y(d.overall); })
  }

  var dif = moment().diff(moment('2017-10-20'), 'months', true)

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
});
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
