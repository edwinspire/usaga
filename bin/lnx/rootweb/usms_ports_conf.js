	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojo/request",
"jspire/request/Xml",
"jspire/Gridx",
"_usms_parity/_usms_parity",
"dojox/grid/cells/dijit",
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/TooltipDialog",
"dijit/popup",
"dijit/form/CheckBox",
"dijit/form/Select",
"_usms_stopbits/_usms_stopbits",
"_usms_handshake/_usms_handshake"
], function(ready, on, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller, request, RXml, jsGridx, wParity){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

var NotifyArea = dijit.byId('id_notify_area');  


var GridxTable = dijit.byId('gridxt');
GridxTable.IdToDelete = [];

	if (GridxTable) {

		// Optionally change column structure on the grid
		GridxTable.setColumns([

			{field:"unique_id", name: "#", width: '20px'},
			{field:"enable", name: "*", width: '20px', editor: "dijit/form/CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true},
			{field:"port", name: "port", width: '20%', editable: true},
			{field:"databits", name: "databits", editable: true},
			{field:"baudrate", name: "baudrate", editable: true},
			{field:"parity", name: "Paridad", editor: "_usms_parity/_usms_parity", editable: true, alwaysEditing: true},
			{field:"stopbits", name: "StopBits", editor: "_usms_stopbits/_usms_stopbits", editable: true, alwaysEditing: true},
			{field:"handshake", name: "HandShake", editor: "_usms_handshake/_usms_handshake", editable: true, alwaysEditing: true},
			{field:"note", name: "note", editable: true, width: '25%'}
		]);
GridxTable.startup();
}

GridxTable.Clear= function(){
GridxTable.selected = [];
GridxTable._setData({identifier: "unique_id", items: []});
}

GridxTable._setData = function(data){
	ItemFileWriteStore_1.clearOnClose = true;
	ItemFileWriteStore_1.data = data;
	ItemFileWriteStore_1.close();
		GridxTable.store = null;
		GridxTable.setStore(ItemFileWriteStore_1);
}

GridxTable.Delete = function(){

var num = GridxTable.IdToDelete.length;
if(num > 0){

request.post('tableserialport_delete.usms', {
   handleAs: "xml",
data: {idports: GridxTable.IdToDelete.toString()}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');
//alert(xmld.getStringFromB64(0, 'message'));
if(xmld.length > 0){
NotifyArea.notify({message: xmld.getStringFromB64(0, 'message')});
}
GridxTable.Load();
}, function(error){
NotifyArea.notify({message: error});
});

}else{
NotifyArea.notify({message: 'No hay registros seleccionados'});
}

}



GridxTable.Load = function(){

GridxTable.IdToDelete = [];

            // Request the text file
            request.get("gettableserialport.usms", {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i+1,
idport: d.getNumber(i, "idport"),
port: d.getStringFromB64(i, "port"),
parity: d.getString(i, "parity"),
baudrate: d.getNumber(i, "baudrate"),
databits: d.getNumber(i, "databits"),
stopbits: d.getString(i, "stopbits"),
handshake: d.getString(i, "handshake"),
enable: d.getBool(i, "enable"),
note: d.getStringFromB64(i, "note")
};
i++;
}

GridxTable._setData(myData);

                },
                function(error){
                    // Display the error returned
NotifyArea.notify({message: error});
GridxTable.Clear();
                }
            );

}

// Guarda los datos
GridxTable.SaveItem = function(item){

request.post('serialportedit.usms', {
   handleAs: "xml",
data: item
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');
//alert(xmld.getStringFromB64(0, 'message'));
if(xmld.length > 0){
NotifyArea.notify({message: xmld.getStringFromB64(0, 'message')});
}
GridxTable.Load();
}, function(error){
NotifyArea.notify({message: error});
});

}


        var myDialog = dijit.byId('idDialogNew');

        dojo.connect(dojo.byId('new'), 'onclick', function(){
            dijit.popup.open({
                popup: myDialog,
                around: dojo.byId('new')
            });
        });
//--
        dojo.connect(dojo.byId('newcancel'), 'onclick', function(){
dijit.popup.close(myDialog);
});
//--
        dojo.connect(dojo.byId('newok'), 'onclick', function(){
dijit.popup.close(myDialog);
GridxTable.SaveItem({idgroup: 0, enable: dijit.byId('idenable').get('checked'), name: dijit.byId('idname').get('value'), note: dijit.byId('idnote').get('value'), ts: '1990-01-01'});
dojo.byId('idformnew').reset();
});
//--
        dojo.connect(dojo.byId('getdata'), 'onclick', function(){
GridxTable.Load();
});

//--
        var myDialogDelete = dijit.byId('iddialogdelete');
myDialogDelete.dijitOwner(dijit.byId('delete'), 'Click').on('onok', function(){

if(GridxTable.IdToDelete.length > 0){
GridxTable.Delete();
}else{
NotifyArea.notify({message: 'No hay registros seleccionados'});
}
});


	dojo.connect(ItemFileWriteStore_1, 'onSet', function(item, attribute, oldValue, newValue){
GridxTable.SaveItem(item);
});





// Capturamos el evento onSelectionChange de la gridx 
dojo.connect(GridxTable.select.row, 'onSelectionChange', function(selected){
GridxTable.IdToDelete = [];
numsel = selected.length;
var i = 0;
while(i<numsel){
GridxTable.store.fetch({query: {unique_id: selected[i]}, onItem: function(item){
GridxTable.IdToDelete[i] = GridxTable.store.getValue(item, 'idport');
} 
});
i++;
}
});





     });
});
