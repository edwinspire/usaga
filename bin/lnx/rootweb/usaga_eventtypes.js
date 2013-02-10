	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
"dojox/xml/DomParser",
'dojo/store/Memory',
"dojo/Evented",
"dojo/data/ItemFileReadStore",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojox/grid/cells/dijit",
"dojox/data/XmlStore", 
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/TooltipDialog",
"dijit/popup",
"dijit/form/CheckBox"
], function(ready, on, DomParser, Memory, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
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


        var myDialogDelete = dijit.byId('dialogdeleteselection');

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

var GridCalls = dijit.byId('gridxnotif');

dojo.connect(GridCalls.select.row, 'onSelectionChange', function(selected){

ObjectTable.IdToDelete = [];
numsel = selected.length;

i = 0;
while(i<numsel){
ObjectTable.IdToDelete[i] = GridCalls.cell(selected[i], 1, true).data();
i++;
}

});

	if (GridCalls) {
var eargs = jspire.dijit.gridx.EditorArgsToBoolean;
		// Optionally change column structure on the grid
		GridCalls.setColumns([
			{field:"ideventtype", name: "id", width: '20px'},
			{field:"name", name: "Nombre"},
			{field:"label", name: "Etiqueta", editable: 'true'},
			{field:"accountdefault", name: "accountdefault" ,  editor: "dijit.form.CheckBox", editorArgs: eargs, alwaysEditing: 'true'},
			{field:"groupdefault", name: "groupdefault" ,  editor: "dijit.form.CheckBox", editorArgs: eargs, alwaysEditing: 'true'},
			{field:"note", name: "nota" , editable: 'true'}
		]);
GridCalls.startup();
}


function SaveData(item){

  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "fun_eventtypes_edit_xml.usaga",
    content: {ideventtype: item.ideventtype, name: item.name, priority: item.priority, note: item.note, accountdefault: item.accountdefault, groupdefault: item.groupdefault, ts: item.ts},
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspire.XmlDocFromXhr(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringFromB64(0, 'outpgmsg'));


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

var store = new dojox.data.XmlStore({url: "fun_view_eventtypes_xml.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({onComplete: function(itemsrow, r){

var dataxml = new jspire.XmlDocFromXmlStore(store, itemsrow);

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
note: dataxml.getStringFromB64(i, "note"),
ts: dataxml.getString(i, "ts")
};
i++;
}

ItemFileWriteStore_1.clearOnClose = true;
	ItemFileWriteStore_1.data = myData;
	ItemFileWriteStore_1.close();

		GridCalls.store = null;
		GridCalls.setStore(ItemFileWriteStore_1);
},
onError: function(e){
alert(e);
}
});

}

// Se hace este timeout porque la pagina demora en crearse y al cargar no muestra nada.
setTimeout(LoadGrid, 10000);













     });
});
