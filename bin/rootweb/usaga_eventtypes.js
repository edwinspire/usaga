/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']
require(["dojo/ready",  
"dojo/on",
"dojo/Evented",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
"dijit/form/CheckBox",
  "dijit/form/NumberTextBox",
  "dijit/form/TextBox",
"gridx/modules/VirtualVScroller",
"jspire/Gridx",
"jspire/request/Xml",
"dojox/data/XmlStore"
], function(ready, on, Evented, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, CheckBox, NumberTextBox, TextBox, VirtualVScroller, jsGridx, RXml) {
	ready(function() {
		// logic that requires that Dojo is fully initialized should go here
		var MH = dijit.byId('idMH');
		var G = dijit.byId('idGridx');
		G.set('editable', true);
		G.columns( {
			name: true, priority: true, manual: true, treatment: true, accountdefault: true, groupdefault: true, note: true, enable_datetime: true, na_timeout: true, na_closable: true, na_snd: true, na_img: true
		}
		);
		MH.on("onchangedeventtypestable", function() {
			G.load();
		}
		);
		/*
var MH = dijit.byId('idMH');  
dojo.connect(ItemFileWriteStore_1, 'onSet', function(item, attribute, oldValue, newValue){
SaveData(item);
});
var GridxTable = dijit.byId('gridxdata');
var BCargar = dijit.byId('getdata');
BCargar.on('click', function(){
LoadGrid();
});
	if (GridxTable) {
		// Optionally change column structure on the grid
		GridxTable.setColumns([
			{field:"ideventtype", name: "id", width: '20px'},
			{field:"name", name: "Nombre"},
			{field:"label", name: "Etiqueta", editable: 'true'},
			{field:"priority", name: "Prioridad", editable: 'true'},
			{field:"manual", name: "manual" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'},
			{field:"treatment", name: "Tratamiento" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'},
			{field:"accountdefault", name: "accountdefault" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'},
			{field:"groupdefault", name: "groupdefault" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'},
			{field:"note", name: "nota" , editable: 'true'}
		]);
	GridxTable.pagination.setPageSize(25);
GridxTable.startup();
}
function SaveData(item){
  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "fun_eventtypes_edit_xml.usaga",
    content: {ideventtype: item.ideventtype, label: item.label, priority: item.priority, note: item.note, accountdefault: item.accountdefault, groupdefault: item.groupdefault, manual: item.manual, ts: item.ts, treatment: item.treatment},
    handleAs: "xml",
    load: function(dataX){
var xmld = new RXml.getFromXhr(dataX, 'row');
if(xmld.length > 0){
MH.notification.notify({message: xmld.getStringFromB64(0, 'outpgmsg')}); 
}
LoadGrid();
    },
    error: function(errorx){
MH.notification.notify({message: errorx}); 
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}
function LoadGrid(){
var store = new dojox.data.XmlStore({url: "fun_view_eventtypes_xml.usaga", sendQuery: true, rootItem: 'row'});
var request = store.fetch({onComplete: function(itemsrow, r){
var dataxml = new RXml.getFromXmlStore(store, itemsrow);
numrows = itemsrow.length;
var myData = {identifier: "unique_id", items: []};
var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i,
ideventtype: dataxml.getNumber(i, "ideventtype"),
name: dataxml.getStringFromB64(i, "name"),
label: dataxml.getStringFromB64(i, "label"),
priority: dataxml.getNumber(i, "priority"),
accountdefault: dataxml.getBool(i, "accountdefault"),
groupdefault: dataxml.getBool(i, "groupdefault"),
manual: dataxml.getBool(i, "manual"),
treatment: dataxml.getBool(i, "treatment"),
note: dataxml.getStringFromB64(i, "note"),
ts: dataxml.getString(i, "ts")
};
i++;
}
ItemFileWriteStore_1.clearOnClose = true;
	ItemFileWriteStore_1.data = myData;
	ItemFileWriteStore_1.close();
		GridxTable.store = null;
		GridxTable.setStore(ItemFileWriteStore_1);
},
onError: function(e){
MH.notification.notify({message: e}); 
}
});
}
// Se hace este timeout porque la pagina demora en crearse y al cargar no muestra nada.
setTimeout(LoadGrid, 10000);
*/
	}
	);
}
);
