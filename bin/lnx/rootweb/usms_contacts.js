	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
"dojox/xml/DomParser",
'dojo/store/Memory',
  "dijit/form/FilteringSelect", 
"dojo/Evented",
"dojo/data/ItemFileReadStore",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
  "dijit/form/CheckBox",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojox/grid/cells/dijit",
"dojox/data/XmlStore"
], function(ready, on, DomParser, Memory, FilteringSelect, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, CheckBox, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

/////////////////
///// BASIC /////
// Account basic elements


var GlobalObject = {
IdContact: 0,
GridStore: usms_contacts_ItemFileReadStore,
dijit: {
Grid: dijit.byId("usms.contacts.gridx")
},
LoadGrid: function(){

var store = new dojox.data.XmlStore({url: "usms_getcontactslistidcontactname_xml", sendQuery: true, rootItem: 'row'});

var request = store.fetch({onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};
myData.identifier = "unique_id";

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i,
idcontact: dataxml.getNumber(i, "idcontact"),
enable: dataxml.getBool(i, "enable"),
name: dataxml.getStringB64(i, "name"),
};
i++;
}

GlobalObject.GridStore.clearOnClose = true;
	GlobalObject.GridStore.data = myData;
	GlobalObject.GridStore.close();

		GlobalObject.dijit.Grid.store = null;
		GlobalObject.dijit.Grid.setStore(GlobalObject.GridStore);

},
onError: function(e){
alert(e);
}
});
}
}


	if (GlobalObject.dijit.Grid) {
// Captura el evento cuando se hace click en una fila
dojo.connect(GlobalObject.dijit.Grid, 'onRowClick', function(event){
//LoadFormAccountUser(this.cell(event.rowId, 1, true).data());
});
		// Optionally change column structure on the grid
		GlobalObject.dijit.Grid.setColumns([
			{field:"idcontact", name: "id", width: '0px'},
			{field:"enable", name: "*", width: '20px'},
			{field:"name", name: "Nombre"},
		]);
GlobalObject.dijit.Grid.startup();
GlobalObject.LoadGrid();
}



////////////////// FUNCIONES CARGAN AL INICIO //////////////////////////
//dijit.byId('account.location.geox').constraints = {pattern: '###.################'};
//dijit.byId('account.location.geoy').constraints = {pattern: '###.################'};



     });
});
