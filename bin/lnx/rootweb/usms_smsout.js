	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
'dojo/store/Memory',
"dojo/Evented",
"dojo/data/ItemFileReadStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojox/grid/cells/dijit",
"dojox/data/XmlStore"
], function(ready, on, Memory, Evented, ItemFileReadStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

dojo.connect(dojo.byId('send'), 'onclick', function(){
LoadGrid();
});


var ObjectTable = {
RowSeleted: 0 
} 


	var myGridX = dijit.byId("idgridxtable");
	if (myGridX) {


		// Optionally change column structure on the grid
		myGridX.setColumns([

			{field:"idsmsout", name: "id"},
			{field:"dateload", name: "dateload"},
			{field:"idprovider", name: "idprovider"},
			{field:"idsmstype", name: "idsmstype"},
			{field:"idphone", name: "idphone"},
			{field:"phone", name: "phone"},
			{field:"datetosend", name: "datetosend"},
			{field:"message", name: "message"},
			{field:"dateprocess", name: "dateprocess"},
			{field:"process", name: "process"},
			{field:"priority", name: "priority"},
			{field:"attempts", name: "attempts"},
			{field:"idprovidersent", name: "idprovidersent"},
			{field:"slices", name: "slices"},
			{field:"slicessent", name: "slicessent"},
			{field:"messageclass", name: "messageclass"},
			{field:"report", name: "report"},
			{field:"maxslices", name: "maxslices"},
			{field:"enablemessageclass", name: "enablemessageclass"},
			{field:"idport", name: "idport"},
			{field:"flag1", name: "flag1"},
			{field:"flag2", name: "flag2"},
			{field:"flag3", name: "flag3"},
			{field:"flag4", name: "flag4"},
			{field:"flag5", name: "flag5"},
			{field:"retryonfail", name: "retryonfail"},
			{field:"maxtimelive", name: "maxtimelive"},
			{field:"note", name: "note"}
		]);

myGridX.startup();


}


function LoadGrid(){

var store = new dojox.data.XmlStore({url: "usms_smsoutviewtablefilter", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {fstart: getdate('fstart'), fend: getdate('fend'), nrows: dijit.byId('nrows').get('value')}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i, 
idsmsout: dataxml.getNumber(i, "idsmsout"), 
dateload: dataxml.getDate(i, "dateload"),
idprovider: dataxml.getNumber(i, "idprovider"),
idsmstype: dataxml.getNumber(i, "idsmstype"),
idphone: dataxml.getNumber(i, "idphone"),
phone: dataxml.getStringB64(i, "phone"),
datetosend: dataxml.getDate(i, "datetosend"),
message: dataxml.getStringB64(i, "message"),
dateprocess: dataxml.getDate(i, "dateprocess"),
process: dataxml.getNumber(i, "process"),
priority: dataxml.getNumber(i, "priority"),
attempts: dataxml.getNumber(i, "attempts"),
idprovidersent: dataxml.getNumber(i, "idprovidersent"),
slices: dataxml.getNumber(i, "slices"),
slicessent: dataxml.getNumber(i, "slicessent"),
messageclass: dataxml.getNumber(i, "messageclass"),
report: dataxml.getBool(i, "report"),
maxslices: dataxml.getNumber(i, "maxslices"),
enablemessageclass: dataxml.getBool(i, "enablemessageclass"),
idport: dataxml.getNumber(i, "idport"),
flag1: dataxml.getNumber(i, "flag1"),
flag2: dataxml.getNumber(i, "flag2"),
flag3: dataxml.getNumber(i, "flag3"),
flag4: dataxml.getNumber(i, "flag4"),
flag5: dataxml.getNumber(i, "flag5"),
retryonfail: dataxml.getNumber(i, "retryonfail"),
maxtimelive: dataxml.getNumber(i, "maxtimelive"),
note: dataxml.getStringB64(i, "note")
};
i++;
}

	// Set new data on data store (the store has jsId set, so there's
	// a global variable we can reference)
	ItemFileReadStore_1.clearOnClose = true;
	ItemFileReadStore_1.data = myData;
	ItemFileReadStore_1.close();

		myGridX.store = null;
		myGridX.setStore(ItemFileReadStore_1);
},
onError: function(e){
alert(e);
}
});

}

// Se hace este timeout porque la pagina demora en crearse y al cargar no muestra nada.
//setTimeout(LoadGrid, 5000);



function getdate(iddijit){
return dojo.date.locale.format(dijit.byId(iddijit).get('value'), {datePattern: "yyyy-MM-dd", selector: "date"});
}









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
