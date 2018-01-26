buttonclick = function(){
  var attrstring = "font-size: 20px; border-radius: 12px; height: 75px; width: 175px;"
  var geobutton = document.getElementById("geobutton")
  var tsbutton = document.getElementById("tsbutton")
  var buttondiv = document.getElementById("buttons")

  geobutton.setAttribute("style", attrstring)
  tsbutton.setAttribute("style", attrstring)
  buttons.setAttribute("style", "margin-left: 75px")
}

wipeall = function(){
  d3.select("#maptitle").html("");
  d3.select("#maptext").html("");
  d3.select("#bartitle").html("");
  d3.select("#bartext").html("");
  d3.select("#tstitle").html("");
  d3.select("#tstext").html("");
  d3.select("#map").html("");
  d3.select("#tschart").html("");
  d3.select("#barchart").html("");
}


d3.select("#geobutton")
  .on("click", function (){
    var selection = 'trends'

    wipeall()
    
    updateMap("#E6673e", selection);
});

d3.select("#tsbutton")
  .on("click", function (){
    wipeall()

    updateTS("US");
});

