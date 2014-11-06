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
'jspire/request/Xml',
"jspire/form/DateTextBox",
'jspire/form/FilteringSelect',
'dojo/_base/array',
'_usaga_event_report/_usaga_event_report',
'_usaga_event_comments/_usaga_event_comments',
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
	"gridx/modules/RowHeader",
	"gridx/modules/select/Row",
	"gridx/modules/IndirectSelect",
	"gridx/modules/extendedSelect/Row",
	"gridx/modules/VirtualVScroller",
"dijit/form/CheckBox",
"dijit/popup"
], function(ready, domStyle, dojoWindow, dojoOn, jsGridx, R, RXml, jsDateTextBox, jsFS, array, EventReport) {
	ready(function() {

dijit.byId('idTitle').set('label', 'REPORTE DE EVENTOS');	
var DivMain = dojo.byId('idDivMain');
var DivC = dijit.byId('idDivC');
var idevents = DivMain.getAttribute('data-usaga-idevents');
//console.log(idevents);
var es = idevents.replace('{', '').replace('}', '').split(',');
//console.log(es);


array.forEach(es, function(event, i){
e = new EventReport();
DivC.addChild(e);
e.load(event);
})









	}
	);
}
);
