
require(["dojo/ready", "dojox/socket"
], function(ready){

  ready(function(){


var socket = dojox.socket("/uhttp-websocket-echo.uhttp");
socket.on("message", function(event){
  var data = event.data;
  switch(data.action){
    case "create": store.notify(data.object); break;
    case "update": store.notify(data.object, data.object.id); break;
    case "delete": store.notify(undefined, data.object.id); break;
    default: // some other action
  }
});




  });
});

