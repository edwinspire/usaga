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
var h_body = domStyle.get('myapp', 'height');         
var h_id_usaga_menu_header = domStyle.get('id_usaga_menu_header', 'height'); 
var h_id_account_titlebar =   domStyle.get('id_account_titlebar', 'height');      
domStyle.set('id_tabcontainer_master', 'height', ViewPortWin.h-h_id_usaga_menu_header-h_id_account_titlebar+'px');
}
         
//alert(ViewPortWin.h+' '+h_body+'  '+h_id_usaga_menu_header+'  '+h_id_account_titlebar);

dojoOn(window, "resize", function() { 
console.log('window on resize');
BodyApp.adjustElements();
NotifyArea.setText('Ha cambiado el tamaño de la ventana');
 })



NotifyArea.setText('uSAGA - Abonados');
//Se ajusta al tamaño de la pantalla actual
BodyApp.adjustElements();


     });
});
