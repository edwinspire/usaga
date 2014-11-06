/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']
require(["dojo/ready",  
"dojo/on",
'dojo/request', 
'jspire/request/Xml',
'jspire/usms/GridxSMSInBuilder',
"dojo/data/ItemFileReadStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojox/grid/cells/dijit"
], function(ready, on, request, RXml, SMSInBuilder, ItemFileReadStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller) {
	ready(function() {
		// logic that requires that Dojo is fully initialized should go here
		var myGridX = SMSInBuilder.Build(dijit.byId("idgridxtable"), ItemFileReadStore_1);
		var MH = dijit.byId('idMH');
		myGridX.on('onnotify', function(m) {
			MH.notification.notify( {
				message: m.msg
			}
			);
		}
		);
		var FromToSelect = dijit.byId('idFromToSelect');
		FromToSelect.on('onget', function(e) {
			myGridX.Load(e.From, e.To, e.Rows);
		}
		);
		dijit.byId('idTitleBar').set('label', 'Mensajes recibidos');
	}
	);
}
);
