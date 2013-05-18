/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready",
"dojo/dom-style",
"dojo/window",
"dojo/on",
"jspire/Gridx",
'dojo/request',
'jspire/request/Xml'
], function(ready, domStyle, dojoWindow,dojoOn, jsGridx, R, RXml){
     ready(function(){

 dijit.byId('id_account_titlebar').set('label', 'Abonados');
     
var NotifyArea = dijit.byId('id_notify_area');  
var Account = dijit.byId('id_account_basic_data');
var Location = dijit.byId('id_account_location_widget');
var LocationMB = dijit.byId('id_account_location_menubar');  
var GridxA = dijit.byId('id_account_contact_gridx');
var ContactW = dijit.byId('id_account_contact_widgetx');    


Location.on('notify_message', function(m){
NotifyArea.notify({message: m.message});
});


LocationMB.on('onnew', function(){
Location.set('idaddress', 0);
});

LocationMB.on('ondelete', function(){
Location.address.delete();
});

LocationMB.on('onsave', function(){
if(Account.Id > 0){
Location.save();
}
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
 })

Account.on('notify_message', function(n){
NotifyArea.notify({message: n.message});
});
Account.on('onloadaccount', function(x){
if(x.idaccount > 0){
Account.DisabledContentPanes(false);
Location.set('idaddress', x.idaddress);
GridxA.Load();
}else{
Account.DisabledContentPanes(true);
}

});

Account.DisabledContentPanes= function(disabled){

dijit.byId('ContentPaneTiempos').attr('disabled',  true);
dijit.byId('ContentPaneLocaliz').attr('disabled',  disabled);
dijit.byId('ContentPaneContactos').attr('disabled',  disabled);
dijit.byId('ContentPaneUsers').attr('disabled',  disabled);
dijit.byId('ContentPaneEventos').attr('disabled',  disabled);
}


// ### SECCION CONTACTOS ###
	if (GridxA) {
// Captura el evento cuando se hace click en una fila
dojo.connect(GridxA, 'onRowClick', function(evt){
var t = GridxA;
d = t.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
t.store.fetch({query: {unique_id: d}, onItem: function(item){
ContactW.Load(t.store.getValue(item, 'idaccount'), t.store.getValue(item, 'idcontact'));
//AC.ResetOnSelectContact();
//AC.LoadFormContact(id);

}
});

});
		GridxA.setColumns([
			{field:"unique_id", name: "#", width: '20px'},
			{field:"enable_as_contact", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true},
			{field:"priority", name: "priority", width: '20px'},
			{field:"name", name: "nombre", width: '150px'},
			{field:"appointment", name: "Designacion"}
		]);
GridxA.startup();
}

GridxA.Clear= function(){
	id_account_contact_store.clearOnClose = true;
	id_account_contact_store.data = {identifier: "unique_id", items: []};
	id_account_contact_store.close();
GridxA.store = null;
GridxA.setStore(id_account_contact_store);
}

GridxA.Load = function(){
//this.ResetOnSelectContact();
if(Account.Id > 0){

   R.get('getaccountcontactsgrid.usaga', {
		query: {idaccount: Account.Id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

var myData = {identifier: "unique_id", items: []};


if(numrows > 0){

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id: i+1,
idcontact: d.getNumber(i, "idcontact"), 
idaccount: d.getNumber(i, "idaccount"), 
enable_as_contact: d.getBool(i, "enable_as_contact"),
priority: d.getNumber(i, "prioritycontact"),    
name: d.getStringFromB64(i, "lastname")+' '+d.getStringFromB64(i, "firstname"),
appointment: d.getStringFromB64(i, "appointment")
};

i++;
}


}

	id_account_contact_store.clearOnClose = true;
	id_account_contact_store.data = myData;
	id_account_contact_store.close();

		GridxA.store = null;
		GridxA.setStore(id_account_contact_store);

//t.emit('onloadaccount', {idaccount: t.Id, idaddress: t._idaddress}); 
//t.emit('notify_message', {message: t.account_select.get('displayedValue')+' cargado'}); 
                },
                function(error){
                    // Display the error returned
console.log(error);
//t.emit('onloadaccount', {idaccount: 0, idaddress: 0}); 
//t.emit('notify_message', {message: error}); 
                }
            );


}else{
this.Clear();
}


return this;
},


















//# FUNCIONES QUE SE EJECUTAN CUANDO SE HA CARGADO LA PAGINA #//
NotifyArea.notify({message: 'uSAGA - Abonados'});
//Se ajusta al tamaño de la pantalla actual
BodyApp.adjustElements();
Account.DisabledContentPanes(true);


     });
});
