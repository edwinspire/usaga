/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready"], function(ready) {
	ready(function() {
		// logic that requires that Dojo is fully initialized should go here
		var _Grid = dijit.byId('id_grid_events');
		var MH = dijit.byId("idMH");
		dijit.byId('id_titulo').set('label', 'Administrador de eventos - Movil');
		MH.on("onchangedeventstable", function() {
			//console.log('********** onchangedeventstable');
			_Grid.load();
		}
		);
		MH.on("onchangedevents_commentstable", function() {
			//console.log('********** oneventcommentstablechanged');
			//_Grid.load();
		}
		);
		_Grid.set('function', 2);
		_Grid.set('idaccounts', [-2]);
		_Grid.set('pagesize', 25);
		_Grid.columns( {
			enable: true, account: true, name: true
		}
		);
		_Grid.on('oneventclick', function(e) {
			//_EventView.load(e.idevent);
			window.open("m_usaga_event_view.usaga"+"?idevent="+e.idevent, '_self');
		}
		);
	}
	);
}
);
