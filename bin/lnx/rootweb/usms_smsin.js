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
"gridx/modules/extendedSelect/Row"

], function(ready, on, DomParser, Memory, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here


var ObjectTable = {
RowSeleted: 0 
} 


	dojo.connect(ItemFileWriteStore_1, 'onSet', function(item, attribute, oldValue, newValue){
//alert('Edita '+ item.idnotiftempl);
SaveData(item);
});

var GridCalls = dijit.byId('gridxnotif');

dojo.connect(GridCalls.select.row, 'onSelectionChange', function(selected){
//	dom.byId('rowSelectedCount').value = selected.length;
//	dom.byId('rowStatus').value = selected.join("\n");
//alert(selected.length +' > ' +selected);

//alert(GridCalls.cell(selected[0], 2, true).data());
// TODO, hacer que todo el id para incluirlo en la matriz
ObjectTable.RowSeleted = selected;

});

	if (GridCalls) {
/*
// Captura el evento cuando se hace click en una fila
dojo.connect(GridCalls, 'onRowClick', function(event){
//alert(this.cell(event.rowId, 2, true).data());
CP.IdPhone = this.cell(event.rowId, 2, true).data();
});
*/
		// Optionally change column structure on the grid
		GridCalls.setColumns([
			{field:"idnotiftempl", name: "id", width: '20px'},
			{field:"description", name: "Descripción", editable: 'true'},
			{field:"message", name: "Mensaje" , editable: 'true'}
		]);
GridCalls.startup();
}


function SaveData(item){

  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "opensaganotificationtemplatesedit",
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

var store = new dojox.data.XmlStore({url: "opensagagetviewnotificationtemplates", sendQuery: true, rootItem: 'row'});

var request = store.fetch({onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i,
idnotiftempl: dataxml.getNumber(i, "idnotiftempl"),
description: dataxml.getStringB64(i, "description"),
message: dataxml.getStringB64(i, "message"),
ts: dataxml.getString(i, "ts")
};
i++;
}


myData.items[i] = {
unique_id: i,
idnotiftempl: 0,
description: '',
message: '',
ts: '1990-01-01'
};

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
setTimeout(LoadGrid, 5000);













     });
});




/*
require(["dojo/ready"], function(ready){
     ready(function(){

  var formpg = dojo.byId("idformFiltro");
  dojo.connect(formpg, "onsubmit", 'GetSMSOutTable');

	var myGridX = dijit.byId("idsmsouttable");
	if (myGridX) {


		// Optionally change column structure on the grid
		myGridX.setColumns([

			{field:"idsmsout", name: "id",  width: '25px'},
			{field:"dateload", name: "dateload",  width: '30px'},
			{field:"idprovider", name: "idprovider",  width: '40px'},
			{field:"idsmstype", name: "idsmstype",  width: '25px'},
			{field:"idphone", name: "idphone",  width: '25px'},
			{field:"phone", name: "phone", width: '75px'},
			{field:"datetosend", name: "datetosend",  width: '40px'},
			{field:"message", name: "message", width: '150px'},
			{field:"dateprocess", name: "dateprocess",  width: '40px'},
			{field:"process", name: "process",  width: '25px'},

			{field:"priority", name: "priority",  width: '25px'},
			{field:"attempts", name: "attempts",  width: '25px'},
			{field:"idprovidersent", name: "idprovidersent",  width: '25px'},
			{field:"slices", name: "slices",  width: '25px'},
			{field:"slicessent", name: "slicessent",  width: '25px'},
			{field:"messageclass", name: "messageclass",  width: '25px'},
			{field:"report", name: "report", dataType: "boolean",  width: '25px'},
			{field:"maxslices", name: "maxslices"},
			{field:"enablemessageclass", name: "enablemessageclass"},
			{field:"idport", name: "idport",  width: '25px'},
			{field:"flag1", name: "flag1",  width: '25px'},
			{field:"flag2", name: "flag2",  width: '25px'},
			{field:"flag3", name: "flag3",  width: '25px'},
			{field:"flag4", name: "flag4",  width: '25px'},
			{field:"flag5", name: "flag5",  width: '25px'},
			{field:"retryonfail", name: "retryonfail",  width: '25px'},
			{field:"maxtimelive", name: "maxtimelive",  width: '25px'},
			{field:"note", name: "note", width: '150px'}
		]);

myGridX.startup();


}
//SizeContent();

     });
});



// Ajusta el tamaño de la tabla adecuadamente
function SizeContent(){
//alert(document.getElementById("idcontentgrid").offsetWidth+' '+document.getElementById("idcontentgrid").offsetHeight);
//alert(document.getElementById("idpaneFiltro").offsetWidth+' '+document.getElementById("idpaneFiltro").offsetHeight);
var Tabla = dojo.byId("idConGridx");
dojo.style(Tabla, "height", (document.getElementById("idcontentAll").offsetHeight-document.getElementById("idpaneFiltro").offsetHeight-5)+'px');
}

function XmlToStore(xmldata){

	var store = ItemFileReadStore_1;

var myData = {identifier: "unique_id", items: []};
myData.identifier = "unique_id";

var i = 0;
var rowscount = xmldata.length;
//alert(rowscount);
while(i<rowscount){
myData.items[i] = {
unique_id:i, 
idsmsout: xmldata[i].getAttribute("idsmsout"), 
dateload: xmldata[i].getAttribute("dateload"),
idprovider: xmldata[i].getAttribute("idprovider"),
idsmstype: xmldata[i].getAttribute("idsmstype"),
idphone: xmldata[i].getAttribute("idphone"),
phone: Base64.decode(xmldata[i].getAttribute("phone")),
datetosend: xmldata[i].getAttribute("datetosend"),
message: Base64.decode(xmldata[i].getAttribute("message")),
dateprocess: xmldata[i].getAttribute("dateprocess"),
process: xmldata[i].getAttribute("process"),
priority: xmldata[i].getAttribute("priority"),

attempts: xmldata[i].getAttribute("attempts"),
idprovidersent: xmldata[i].getAttribute("idprovidersent"),
slices: xmldata[i].getAttribute("slices"),
slicessent: xmldata[i].getAttribute("slicessent"),
messageclass: xmldata[i].getAttribute("messageclass"),
report: xmldata[i].getAttribute("report"),
maxslices: xmldata[i].getAttribute("maxslices"),
enablemessageclass: xmldata[i].getAttribute("enablemessageclass"),
idport: xmldata[i].getAttribute("idport"),
flag1: xmldata[i].getAttribute("flag1"),
flag2: xmldata[i].getAttribute("flag2"),
flag3: xmldata[i].getAttribute("flag3"),
flag4: xmldata[i].getAttribute("flag4"),
flag5: xmldata[i].getAttribute("flag5"),
retryonfail: xmldata[i].getAttribute("retryonfail"),
maxtimelive: xmldata[i].getAttribute("maxtimelive"),
note: Base64.decode(xmldata[i].getAttribute("note"))
};
i++;
}

	// Set new data on data store (the store has jsId set, so there's
	// a global variable we can reference)
	store.clearOnClose = true;
	store.data = myData;
	store.close();

return store;
}




// Envia el formulario de PostgreSQL
function GetSMSOutTable(event){
    // Stop the submit event since we want to control form submission.
    dojo.stopEvent(event);
    // The parameters to pass to xhrPost, the form, how to handle it, and the callbacks.
    // Note that there isn't a url passed.  xhrPost will extract the url to call from the form's
    //'action' attribute.  You could also leave off the action attribute and set the url of the xhrPost object
    // either should work.
    var xhrArgs = {
      form: dojo.byId("idformFiltro"),
      handleAs: "text",
      load: function(data){

  var datar = dojox.xml.DomParser.parse(data);
//alert(datar);
var DataStore = XmlToStore(datar.byName('row'));
//alert(datar);
	// Get reference to our grid object. I set the id to "GridX" using
	// the Maqetta properties palette.
	var myGridX = dijit.byId("idsmsouttable");
	if (myGridX) {
		// Tell our grid to reset itself
		myGridX.store = null;
		myGridX.setStore(DataStore);
//myGridX.startup();
	}

///        dojo.byId("response").innerHTML = "Form posted.";
      },
      error: function(error){
        // We'll 404 in the demo, but that's okay.  We don't have a 'postIt' service on the
        // docs server.
	var myGridX = dijit.byId("idsmsouttable");
	if (myGridX) {
		// Tell our grid to reset itself
		myGridX.store = null;
	myGridX.setStore(null);
}
alert(error);
   //     dojo.byId("response").innerHTML = "Form posted.";
      }
    }
    // Call the asynchronous xhrPost
    var deferred = dojo.xhrPost(xhrArgs);
//  return false;
}
*/
