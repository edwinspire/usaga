	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
'dojo/store/Memory',
"dojo/Evented",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojo/request",
"dojox/grid/cells/dijit",
"dojox/data/XmlStore", 
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/TooltipDialog",
"dijit/popup"
], function(ready, on, Memory, Evented, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller, request){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here


var ObjectTable = {
IdToDelete: [] 
} 

        var myDialog = dijit.byId('idDialogNew');

        dojo.connect(dojo.byId('new'), 'onclick', function(){
            dijit.popup.open({
                popup: myDialog,
                around: dojo.byId('new')
            });
        });

        dojo.connect(dojo.byId('newcancel'), 'onclick', function(){
dijit.popup.close(myDialog);
});

        dojo.connect(dojo.byId('newok'), 'onclick', function(){
dijit.popup.close(myDialog);
SaveData({idnotiftempl: 0, description: dijit.byId('newdescrip').get('value'), message: dijit.byId('newMsg').get('value'), ts: '1990-01-01'});
});

        dojo.connect(dojo.byId('getdata'), 'onclick', function(){
LoadGrid();
});


        var myDialogDelete = dijit.byId('iddialogdelete');
myDialogDelete.setowner('delete', 'onclick').on('onok', function(){
//TODO: Reimplementar esta funcion para que el borrado se lo haga en la base de datos y no enviando registro por registro ya que resulta ineficiente este procedimiento.
i = 0;
num = ObjectTable.IdToDelete.length;
while(i<num){
SaveData({idnotiftempl: ObjectTable.IdToDelete[i]*-1, description: '', message: '', ts: '1990-01-01'});
i++;
}
});


	dojo.connect(ItemFileWriteStore_1, 'onSet', function(item, attribute, oldValue, newValue){
//alert('Edita '+ item.idnotiftempl);
SaveData(item);
});

var GridxTable = dijit.byId('gridxt');

dojo.connect(GridxTable.select.row, 'onSelectionChange', function(selected){

ObjectTable.IdToDelete = [];
numsel = selected.length;

i = 0;
while(i<numsel){
ObjectTable.IdToDelete[i] = GridxTable.cell(selected[i], 1, true).data();
i++;
}

});

	if (GridxTable) {

		// Optionally change column structure on the grid
		GridxTable.setColumns([
			{field:"idgroup", name: "id", width: '20px'},
			{field:"enable", name: "*", editable: 'true'},
			{field:"name", name: "Nombre", editable: 'true'},
			{field:"note", name: "Nota" , editable: 'true'}
		]);
GridxTable.startup();
}


function SaveData(item){

  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "notificationtemplatesedit.usaga",
    content: {idnotiftempl: item.idnotiftempl, description: item.description, message: item.message, ts: item.ts},
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspireTableXmlDoc(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringB64(0, 'outpgmsg'));

}

LoadGrid();

    },
    error: function(errorx){
alert(errorx);
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}

function LoadGrid(){

ObjectTable.IdToDelete = [];

            // Request the text file
            request.get("fun_view_groups_xml.usaga", {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new jspire.XmlDocFromXhr(response, 'row');

numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i,
idgroup: d.getNumber(i, "idgroup"),
name: d.getStringFromB64(i, "name"),
note: d.getStringFromB64(i, "note"),
enable: d.getBool(i, "enable"),
ts: d.getString(i, "ts")
};
i++;
}
ItemFileWriteStore_1.clearOnClose = true;
	ItemFileWriteStore_1.data = myData;
	ItemFileWriteStore_1.close();

		GridxTable.store = null;
		GridxTable.setStore(ItemFileWriteStore_1);
                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );
}

// Se hace este timeout porque la pagina demora en crearse y al cargar no muestra nada.
//setTimeout(LoadGrid, 10000);













     });
});
