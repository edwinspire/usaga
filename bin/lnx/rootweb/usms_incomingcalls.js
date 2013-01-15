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
"dojox/data/XmlStore"
], function(ready, on, DomParser, Memory, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

/////////////////
///// BASIC /////
// Account basic elements

dojo.connect(dijit.byId('buttonsend'), 'onClick', function(e){

});

var GridCalls = dijit.byId('gridxcallin');

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
			{field:"idincall", name: "id", width: '20px'},
			{field:"datecall", name: "datecall", width: '20px'},
			{field:"idport", name: "idport", width: '20px'},
			{field:"idphone", name: "idphone"},
			{field:"callaction", name: "callaction"},
			{field:"phone", name: "phone"},
			{field:"idmodem", name: "idmodem"},
			{field:"flag1", name: "f1"},
			{field:"flag2", name: "f2"},
			{field:"flag3", name: "f3"},
			{field:"flag4", name: "f4"},
			{field:"flag5", name: "f5"},
			{field:"note", name: "note"}
		]);
GridCalls.startup();
}

function LoadGrid(){

}
////////////////// FUNCIONES CARGAN AL INICIO //////////////////////////
LoadGrid();


     });
});
