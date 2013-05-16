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

 dijit.byId('id_account_titlebar').set('label', 'Abonados');
     
var NotifyArea = dijit.byId('id_notify_area');  

var Account = dijit.byId('id_account_basic_data');

var Location = dijit.byId('id_account_location_widget');
var LocationMB = dijit.byId('id_account_location_menubar');  

Location.on('notify_message', function(m){
NotifyArea.setText(m.message);
});


LocationMB.on('onnew', function(){
Location.set('idaddress', 0);
});

LocationMB.on('ondelete', function(){
Location.address.delete();
});

LocationMB.on('onsave', function(){
Location.save();
});

Location.on('onsave', function(l){
Account.set('idaddress', l.idaddress);
});


var BodyApp = dojo.byId('myapp');
BodyApp.adjustElements = function(){
h = dojoWindow.getBox().h - domStyle.get('id_usaga_menu_header', 'height') - domStyle.get('id_account_titlebar', 'height');

domStyle.set('id_usaga_account', 'height', h+'px');
console.log('window on resize to: '+h);
dijit.byId('id_tagcontainer').resize();
}
         
dojoOn(window, "resize", function() { 
BodyApp.adjustElements();
//NotifyArea.setText('Ha cambiado el tamaño de la ventana');
 })

Account.on('notify_message', function(n){
NotifyArea.setText(n.message);
});
Account.on('onloadaccount', function(x){
if(x.idaccount > 0){
Account.DisabledContentPanes(false);
Location.set('idaddress', x.idaddress);
}else{
Account.DisabledContentPanes(true);
}

});

Account.DisabledContentPanes= function(disabled){

dijit.byId('ContentPaneTiempos').attr('disabled',  disabled);
dijit.byId('ContentPaneLocaliz').attr('disabled',  disabled);
dijit.byId('ContentPaneContactos').attr('disabled',  disabled);
dijit.byId('ContentPaneUsers').attr('disabled',  disabled);
dijit.byId('ContentPaneEventos').attr('disabled',  disabled);
}



















//# FUNCIONES QUE SE EJECUTAN CUANDO SE HA CARGADO LA PAGINA #//
NotifyArea.setText('uSAGA - Abonados');
//Se ajusta al tamaño de la pantalla actual
BodyApp.adjustElements();
Account.DisabledContentPanes(true);


     });
});
