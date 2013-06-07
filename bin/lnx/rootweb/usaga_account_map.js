
require(["dojo/ready", "dojox/geo/openlayers/Map", 'dojo/request', 'jspire/request/Xml', 
          "dojox/geo/openlayers/WidgetFeature", "dojox/geo/openlayers/Layer", "_usms_mappoint/_usms_mappoint"
], function(ready, Map, R, RXml,   WidgetFeature, Layer, MapPoint){

  ready(function(){

var IdAccount = dojo.byId('map').getAttribute('data-usaga-idaccount');
//var IdAccount = 1;
    var map = new Map("map");
    // This is New York location
    var GeoPosition = {
      longitude : -78.3983,
      latitude : -0.2074 
    };


map.addPoint = function(_latitude, _longitude, _tooltiptext, _image){
if(Math.abs(_latitude)>0 && Math.abs(_longitude)>0){
var mapPointMaster = new MapPoint();
mapPointMaster.set('image', _image);
mapPointMaster.setTooltip(_tooltiptext);

    var descr = {
      longitude : _longitude,
      latitude : _latitude,
      widget : mapPointMaster,
      width : 20,
      height : 20
    };
    feature = new WidgetFeature(descr);

    layer = new Layer();
    layer.addFeature(feature);
    this.addLayer(layer);
}
}

var SliderZoom = dijit.byId('id_zoom');
SliderZoom.on('Change', function(v){
map.getOLMap().zoomTo(Math.round(v));
});


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

map.addPoint(GeoPosition.latitude, GeoPosition.longitude, 'Abonado', 'media-record-6.png');

    map.fitTo({
      position : [ GeoPosition.longitude, GeoPosition.latitude ],
      extent : 0.01
    });

  SliderZoom.maximum = map.getOLMap().getNumZoomLevels()-1;
SliderZoom.set('value', map.getOLMap().getZoom());
map.getOLMap().zoomTo(Math.round(SliderZoom.get('value')));

//////////////////////////////////////////////////////////
// Obtenemos las coordenadas de los contactos de la cuenta
   R.get('fun_view_account_contacts_address_xml.usaga', {
		query: {idaccount: IdAccount},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var dc = new RXml.getFromXhr(response, 'row');
numrows = d.length;
i = 0;
while(i<numrows){
map.addPoint(dc.getFloat(i, "geox"), dc.getFloat(i, "geoy"), dc.getStringFromB64(i ,'title')+' '+dc.getStringFromB64(i ,'lastname')+' '+dc.getStringFromB64(i ,'firstname'), 'im-user.png');
i++;
}


                },
                function(error){
                    // Display the error returned
console.log(error);
//t.emit('notify_message', {message: error}); 
                }
            );






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

