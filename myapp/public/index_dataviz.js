function whichTransitionEvent(){
  var t,
      el = document.createElement("fakeelement");

  var transitions = {
    "transition"      : "transitionend",
    "OTransition"     : "oTransitionEnd",
    "MozTransition"   : "transitionend",
    "WebkitTransition": "webkitTransitionEnd"
  }

  for (t in transitions){
    if (el.style[t] !== undefined){
      return transitions[t];
    }
  }
}

var transitionEvent = whichTransitionEvent();

$("#geobutton").click(function() {
  $('.transform').addClass('transform-active');
  $(this).one(transitionEvent, function(event){
    var selection = 'trends'
    wipeall();
    setupMap();
  });
});

$("#tsbutton").click(function() {
  $('.transform').addClass('transform-active');
  $(this).one(transitionEvent, function(event){
    wipeall();
    setupTS();
    updateTS("US");
  });
});

wipeall = function(){
  d3.select("#mapselect").html("")
  d3.select("#maptitle").html("");
  d3.select("#maptext").html("");
  d3.select("#bartitle").html("");
  d3.select("#bartext").html("");
  d3.select("#tstitle").html("");
  d3.select("#tsselect").html("");
  d3.select("#tstext").html("");
  d3.select("#map").html("");
  d3.select("#tschart").html("");
  d3.select("#barchart").html("");
  d3.select("#tsbuttons").html("");
}


