
require(["dojo/ready", "dojox/geo/openlayers/Map", 'dojo/request', 'jspire/request/Xml', 
          "dojox/geo/openlayers/WidgetFeature", "dojox/geo/openlayers/Layer", "_usms_mappoint/_usms_mappoint"
], function(ready, Map, R, RXml,   WidgetFeature, Layer, MapPoint){

  ready(function(){

var IdAccount = dojo.byId('map').getAttribute('data-usaga-idaccount');

    var map = new Map("map");
    // This is New York location
    var GeoPosition = {
      longitude : -78.3983,
      latitude : -0.2074 
    };

if(IdAccount > 0){
   R.get('fun_view_account_location_byid_xml.usaga', {
		query: {idaccount: IdAccount},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

if(numrows > 0){
GeoPosition.latitude = d.getFloat(0, "geox");
GeoPosition.longitude = d.getFloat(0, "geoy");
}

////////////////////////////////////}
var mapPointMaster = new MapPoint();
mapPointMaster.setTooltip('Abonado '+IdAccount, 'Dirección:', 'Calle A y Calle B, casa verde esquinera');

    var descr = {
      longitude : GeoPosition.longitude,
      latitude : GeoPosition.latitude,
      widget : mapPointMaster,
      width : 15,
      height : 15
    };
    feature = new WidgetFeature(descr);

    layer = new Layer();
    layer.addFeature(feature);
    map.addLayer(layer);





    map.fitTo({
      position : [ GeoPosition.longitude, GeoPosition.latitude ],
      extent : 0
    });

//map.getOLMap().zoomTo(100); 
//alert(GeoPosition.longitude+' >>> '+ GeoPosition.latitude);
                },
                function(error){
                    // Display the error returned
console.log(error);
//t.emit('notify_message', {message: error}); 
                }
            );


}else{
    // fit to New York with 0.1 degrees extent
    map.fitTo({
      position : [ GeoPosition.longitude, GeoPosition.latitude ],
      extent : 0.1
    });
}
















  });
});

