/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready",
'dojo/request',
"jspire/request/Xml"
], function(ready, R, RXml){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

var _lastidnotify = 0;

function getNotifications(){
var tx = this;
   R.post('notification_system.usms', {
            // Parse data from xml
		data: {lastidnotify: _lastidnotify},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'notification');

 dojo.forEach(d, function(item, i){
ix = d.getNumber(i, 'id');
console.log(ix);
if(ix > _lastidnotify){
//postMessage('k');
//t.notification.notify({message: d.getStringFromB64(i, 'body')});
_lastidnotify = ix;
}
});

setTimeout(getNotifications, 2000);

                },
                function(error){
                    // Display the error returned
//t.notification.notify({message: error});
setTimeout(getNotifications(), 2000);
                }
            );
}

getNotifications();

     });
});
