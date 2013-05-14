/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready",
"dojo/dom-style",
"dojo/window",
"dojo/on"

], function(ready, domStyle, dojoWindow,dojoOn){
     ready(function(){
     
var NotifyArea = dijit.byId('id_notify_area');     

         // logic that requires that Dojo is fully initialized should go here
var ViewPortWin = dojoWindow.getBox();         

var BodyApp = dojo.byId('myapp');
BodyApp.adjustElements = function(){
h_body = domStyle.get(this, 'height');         
h_id_usaga_menu_header = domStyle.get('id_usaga_menu_header', 'height'); 
h_id_account_titlebar =   domStyle.get('id_account_titlebar', 'height');      
//alert(ViewPortWin.h-h_id_usaga_menu_header-h_id_account_titlebar+'px');
domStyle.set('id_usaga_account', 'height', ViewPortWin.h-h_id_usaga_menu_header-h_id_account_titlebar+'px');
dijit.byId('id_tagcontainer').resize();
}
         
dojoOn(window, "resize", function() { 
console.log('window on resize');
BodyApp.adjustElements();
NotifyArea.setText('Ha cambiado el tamaño de la ventana');
 })



NotifyArea.setText('uSAGA - Abonados');
//Se ajusta al tamaño de la pantalla actual

BodyApp.adjustElements();
/*
setTimeout(function(){
//alert('ajusta');
BodyApp.adjustElements();
}, 5000);
*/


     });
});
