	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
'dojo/request', 
'jspire/request/Xml',
'jspire/form/DateTextBox',
"dojo/data/ItemFileReadStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojox/grid/cells/dijit"
], function(ready, on, request, RXml, jsDTb, ItemFileReadStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

dojo.connect(dojo.byId('send'), 'onclick', function(){
myGridX.Load();
});

jsDTb.addGetDateFunction(dijit.byId('fstart'));
jsDTb.addGetDateFunction(dijit.byId('fend'));




	var myGridX = dijit.byId("idgridxtable");
	if (myGridX) {


		// Optionally change column structure on the grid
		myGridX.setColumns([

			{field:"idsmsout", name: "id"},
			{field:"dateload", name: "dateload", width: "5%"},
			{field:"idprovider", name: "idprovider"},
			{field:"idsmstype", name: "idsmstype"},
			{field:"idphone", name: "idphone"},
			{field:"phone", name: "phone"},
			{field:"datetosend", name: "datetosend", width: "5%"},
			{field:"message", name: "message", width: "15%"},
			{field:"dateprocess", name: "dateprocess", width: "5%"},
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
			{field:"note", name: "note", width: "10%"}

		]);

myGridX.startup();


}

myGridX.Load= function(){
            // Request the text file
            request.get("view_smsout_datefilter.usms", {
	query: {fstart: dijit.byId('fstart')._getDate(), fend: dijit.byId('fend')._getDate(), nrows: dijit.byId('nrows').get('value')},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
var myData = {identifier: "unique_id", items: []};
var i = 0;
numrows = d.length;
if(numrows > 0){
while(i<numrows){
myData.items[i] = {
unique_id:i+1,
idsmsout: d.getNumber(i, "idsmsout"), 
dateload: d.getString(i, "dateload"),
idprovider: d.getNumber(i, "idprovider"),
idsmstype: d.getNumber(i, "idsmstype"),
idphone: d.getNumber(i, "idphone"),
phone: d.getStringFromB64(i, "phone"),
datetosend: d.getString(i, "datetosend"),
message: d.getStringFromB64(i, "message"),
dateprocess: d.getString(i, "dateprocess"),
process: d.getNumber(i, "process"),
priority: d.getNumber(i, "priority"),
attempts: d.getNumber(i, "attempts"),
idprovidersent: d.getNumber(i, "idprovidersent"),
slices: d.getNumber(i, "slices"),
slicessent: d.getNumber(i, "slicessent"),
messageclass: d.getNumber(i, "messageclass"),
report: d.getBool(i, "report"),
maxslices: d.getNumber(i, "maxslices"),
enablemessageclass: d.getBool(i, "enablemessageclass"),
idport: d.getNumber(i, "idport"),
flag1: d.getNumber(i, "flag1"),
flag2: d.getNumber(i, "flag2"),
flag3: d.getNumber(i, "flag3"),
flag4: d.getNumber(i, "flag4"),
flag5: d.getNumber(i, "flag5"),
retryonfail: d.getNumber(i, "retryonfail"),
maxtimelive: d.getNumber(i, "maxtimelive"),
note: d.getStringFromB64(i, "note")
};
i++;
}
}
	ItemFileReadStore_1.clearOnClose = true;
	ItemFileReadStore_1.data = myData;
	ItemFileReadStore_1.close();

		myGridX.store = null;
		myGridX.setStore(ItemFileReadStore_1);

//myGridX.emit('onnotify', {msg: 'Se han cargado los datos'});

                },
                function(error){
                    // Display the error returned
myGridX.emit('onnotify', {msg: error});
                }
            );


}










     });
});


