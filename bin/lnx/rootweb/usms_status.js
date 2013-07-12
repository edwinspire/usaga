
require(["dojo/ready", "dojox/socket", "dojo/on","dojo/Evented","dojo/cookie"
], function(ready){

  ready(function(){

/*
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
*/
/*
var wsUri = "ws://localhost:8081/uhttp-websocket-echo.uhttp"; var output;  
function init() { output = document.getElementById("myapp"); testWebSocket(); }  function testWebSocket() { websocket = new WebSocket(wsUri); websocket.onopen = function(evt) { onOpen(evt) }; websocket.onclose = function(evt) { onClose(evt) }; websocket.onmessage = function(evt) { onMessage(evt) }; websocket.onerror = function(evt) { onError(evt) }; }  function onOpen(evt) { writeToScreen("CONNECTED"); doSend("WebSocket rocks"); }  function onClose(evt) { writeToScreen("DISCONNECTED"); }  function onMessage(evt) { writeToScreen('<span style="color: blue;">RESPONSE: ' + evt.data+'</span>'); websocket.close(); }  function onError(evt) { writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data); }  function doSend(message) { writeToScreen("SENT: " + message);  websocket.send(message); }  function writeToScreen(message) { var pre = document.createElement("p"); pre.style.wordWrap = "break-word"; pre.innerHTML = message; output.appendChild(pre); }  window.addEventListener("load", init, false); 

testWebSocket();
*/

  });
});

