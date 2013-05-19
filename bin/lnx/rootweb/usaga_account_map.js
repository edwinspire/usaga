
require(["dojo/ready", "dojox/geo/openlayers/Map", 'dojo/request', 'jspire/request/Xml'
], function(ready, Map, R, RXml){

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

    map.fitTo({
      position : [ GeoPosition.longitude, GeoPosition.latitude ],
      extent : 0
    });

map.getOLMap().zoomTo(50); 
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

