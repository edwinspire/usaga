
require(["dojo/ready", "dojox/geo/openlayers/Map"], function(ready, Map){

  ready(function(){
    var map = new Map("map");
    // This is New York location
    var ny = {
      longitude : -78.3983,
      latitude : -0.2074 
    };
    // fit to New York with 0.1 degrees extent
    map.fitTo({
      position : [ ny.longitude, ny.latitude ],
      extent : 0.1
    });


map.getOLMap().zoomTo(90); 
alert(dojo.byId('map').getAttribute('data-usaga-idaccount'))















  });
});

