/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready", 
'jspire/Gridx',
'jspire/request/Xml',
"dojo/data/ItemFileReadStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
 "dojox/data/XmlStore",
   "dijit/form/CheckBox",
'gridx/modules/VirtualVScroller',
 'gridx/modules/Edit',
 'gridx/modules/CellWidget'], function(ready, jsGridx, RXml) {
	ready(function() {
		// logic that requires that Dojo is fully initialized should go here
		var MH = dijit.byId('idMH');
		var myGridX = dijit.byId("GridEvents");
		myGridX.set('idaccount', -2);
		myGridX.set('rows', 200);
		myGridX.set('function', 1);
		myGridX.set('columns', {
			name: true
		}
		);
		MH.on("onchangedeventstable", function() {
			myGridX.load();
		}
		);
		MH.on("onchangedevents_commentstable", function() {
			myGridX.load();
		}
		);
	}
	);
}
);
