/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']
require(["dojo/ready",  
"dojo/on"
], function(ready, on) {
	ready(function() {
		// logic that requires that Dojo is fully initialized should go here
		dijit.byId('id_titlebar_master').set('label', 'Edición de Contáctos - Teléfono');
		//////////////////
		///// BASIC /////
		// Account basic elements
		var ContactSearch = dijit.byId("ContactSearch");
		ContactSearch.TitleBar.set('label', 'Lista de contactos');
		ContactSearch.on('contactclick', function(e) {
			Contact.set("idcontact", e.idcontact);
		}
		);
		var MH = dijit.byId('idMH');
		var Contact = dijit.byId('WContact');
		Contact.on('onnotify', function(e) {
			MH.notification.notify(e);
		}
		);
		Contact.on('contactmodified', function(e) {
			ContactSearch.GridData.Load();
		}
		);
		Contact.on('ondeletecontact', function(e) {
			ContactSearch.GridData.Load();
		}
		);
		var MBC = dijit.byId('MenubarContacts');
		MBC.on('ondelete', function() {
			Contact.delete();
		}
		);
		MBC.on('onnew', function() {
			Contact.new();
		}
		);
		MBC.on('onsave', function() {
			Contact.save();
		}
		);
	}
	);
}
);
