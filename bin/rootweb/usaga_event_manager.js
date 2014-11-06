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
], function(ready, domStyle, dojoWindow, dojoOn, jsGridx, R, RXml, jsDateTextBox, jsFS) {
	ready(function() {
		var _Grid = dijit.byId('idGridEventos');
		var _EventView = dijit.byId('idEventView');
		var _Comments = dijit.byId('idComments');
		var _AddComment = dijit.byId('idAddComentario');
		var AccComments = dijit.byId('idAccordionComments');
		var MH = dijit.byId("idMH");
		var idEventClicked = 0;
		MH.on("onchangedeventstable", function() {
			//console.log('********** onchangedeventstable');
			_Grid.load();
		}
		);
		MH.on("onchangedevents_commentstable", function() {
			//console.log('********** oneventcommentstablechanged');
			_Grid.load();
			/*
if(idEventClicked>0){
_EventView.load(idEventClicked);
}
*/
		}
		);
		dijit.byId('idNewEvent').on('Click', function() {
			_EventView.New_();
		}
		);
		dijit.byId('idSaveEvent').on('Click', function() {
			_EventView.save();
		}
		);
		dijit.byId('idCancelEvent').on('Click', function() {
			_EventView.reset();
		}
		);
		dijit.byId('idTitle').set('label', 'Administrador de eventos');
		_Grid.set('function', 2);
		_Grid.set('idaccounts', [-2]);
		_Grid.set('pagesize', 50);
		_Grid.columns( {
			enable: true, account: true, name: true
		}
		);
		_Grid.on('oneventclick', function(e) {
			idEventClicked = e.idevent;
			_EventView.load(idEventClicked);
		}
		);
		_EventView.on('onloadevent', function(e) {
			_Comments.load(e.idevent);
			_AddComment.set('idevent', e.idevent);
		}
		);
		_AddComment.on('onsavecomment', function(e) {
			_Comments.load(e.idevent);
			AccComments.selectChild(dijit.byId("idAccCommPView"));
		}
		);
	}
	);
}
);
