/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready"], function(ready) {
	ready(function() {
		// logic that requires that Dojo is fully initialized should go here
		dijit.byId('idTB1').set('label', 'Evento de abonado');
		dijit.byId('idTB2').set('label', 'Comentarios');
		var idevent = dojo.byId('idEventView').getAttribute('data-usaga-idevent');
		var _EventView = dijit.byId('idEventView');
		var _Comments = dijit.byId('idComments');
		var _AddComment = dijit.byId('idAddComment');
		var _TP = dijit.byId('idTP');
		var MH = dijit.byId("idMH");
		_AddComment.set('mobile', true);
		_EventView.on('onloadevent', function(e) {
			_Comments.load(e.idevent);
			_AddComment.set('idevent', e.idevent);
		}
		);
		_AddComment.on('onsavecomment', function(e) {
			_Comments.load(e.idevent);
			_TP.set('open', false);
		}
		);
		/*
MH.on('onchangedevents_commentstable', function(){
_EventView.load(idevent);
});
*/
		_EventView.load(idevent);
		dijit.byId('idMB1').on('Click', function() {
			_EventView.New_();
			//_EventView.reset();
			idevent = 0;
		}
		);
		dijit.byId('idMB2').on('Click', function() {
			_EventView.save();
		}
		);
		dijit.byId('idMB3').on('Click', function() {
			window.open("m_usaga_event_manager.html", '_self');
		}
		);
	}
	);
}
);
