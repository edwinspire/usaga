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
		function HtmlDialogNotifications(msg, idform, idcall, idsms, idtext) {
			return '<form id="'+idform+'" style="width: 250px;">   <label style="font-weight: bold;">'+msg+'</label>   <table border="0" style="border-collapse: collapse; table-layout: fixed; width: 100%; height: auto;">     <colgroup>       <col></col>       <col></col>     </colgroup>     <tbody>       <tr>         <td style="width: 75px;">           Llamar:</td>         <td>           <input type="checkbox" data-dojo-type="dijit/form/CheckBox" id="'+idcall+'" intermediateChanges="false" iconClass="dijitNoIcon"></input></td>       </tr>       <tr>         <td>           Enviar SMS:</td>         <td>           <input type="checkbox" data-dojo-type="dijit/form/CheckBox" id="'+idsms+'" intermediateChanges="false" iconClass="dijitNoIcon"></input></td>       </tr>       <tr>         <td>           Texto SMS:</td>         <td>           <textarea type="text" data-dojo-type="dijit/form/Textarea" id="'+idtext+'" intermediateChanges="false" rows="3" trim="false" uppercase="false" lowercase="false" propercase="false"></textarea></td>       </tr>     </tbody>   </table>   </form>';
		}
		var MH = dijit.byId('id_usaga_menu_header');
		dijit.byId('id_account_titlebar').set('label', 'Abonados');
		dijit.byId('id_contact_linked_titlebar').set('label', 'Detalle del contacto vinculado');
		var MenuGeneral = dijit.byId('id_menu_general');
		var TitleContentPaneMain = dijit.byId('idTitleContentPaneMain');
		var Account = dijit.byId('id_account_basic_data');
		var ContactWidget = dijit.byId('idContactWidget');
		var GridxA = dijit.byId('id_account_contacts_gridx');
		var ContactW = dijit.byId('id_account_contact_widgetx');
		var ContactMB = dijit.byId('id_account_contact_phonenotify_menubar');
		dijit.byId('id_account_contact_titlebar_grid').set('label', 'Contactos a Notificar');
		var GridxB = dijit.byId('id_account_contact_phonenotify_gridx');
		dijit.byId('id_account_user_gridx_titlebar').set('label', 'Usuarios');
		var GridxC = dijit.byId('id_account_user_gridx');
		var UserW = dijit.byId('id_account_user_widget');
		var UserMB = dijit.byId('id_account_user_menubar');
		var GridxD = dijit.byId('id_account_ctrl_alarma_gridx');
		var _Grid = dijit.byId('idGridEventos');
		var _EventView = dijit.byId('idEventView');
		var _Comments = dijit.byId('idComments');
		var _AddComment = dijit.byId('idAddComentario');
		var AccComments = dijit.byId('idAccordionComments');
		_Grid.set('function', 0);
		/*
MH.on("onchangedeventstable", function(){
_Grid.load();
});
*/
		dijit.byId('idNewEvent').on('Click', function() {
			_EventView.new(Account.get('idaccount'));
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
		_Grid.on('oneventclick', function(e) {
			_EventView.load(e.idevent);
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
		var AccountSearch = dijit.byId('idAccountSearch');
		AccountSearch.GridData.on('accountclick', function(e) {
			Account.load(e.idaccount);
		}
		);
		MH.on('onchangedaccounttable', function() {
			AccountSearch.load();
		}
		)
		var BoderContainerMaster = dijit.byId('id_bodercontainer_master');
		setTimeout(function() {
			BoderContainerMaster.startup();
			dojo.setStyle(BoderContainerMaster.domNode, 'height','100%');
			dojo.setStyle(BoderContainerMaster.domNode, 'width','100%');
			BoderContainerMaster.resize();
		}
		, 1000);
		var BodyApp = dojo.byId('myapp');
		BodyApp.adjustElements = function() {
			h = dojoWindow.getBox().h - domStyle.get(MH.domNode, 'height') - domStyle.get('id_account_titlebar', 'height');
			domStyle.set('id_usaga_account', 'height', h+'px');
			//console.log('window on resize to: '+h);
			dijit.byId('id_tagcontainer').resize();
		}
		dojoOn(window, "resize", function() {
			BodyApp.adjustElements();
		}
		)
		Account.on('notify_message', function(n) {
			MH.notification.notify( {
				message: n.message
			}
			);
		}
		);
		Account.on('onloadaccount', function(x) {
			if(x.idaccount > 0) {
				Account.DisabledContentPanes(false);
			} else {
				Account.DisabledContentPanes(true);
			}
			TitleContentPaneMain.set('title', x.name);
			ContactWidget.set('idcontact', x.idcontact);
			ContactWidget.resize();
			GridxA.load(x.idaccount);
			ContactW.Load(x.idaccount, 0);
			UserW.Load(x.idaccount, 0);
			console.log(x.idaccount);
			_Grid.set('idaccounts', [x.idaccount]);
		}
		);
		_Grid.on('onchangedaccounttable', function(i) {
			_EventView.reset();
			_EventView.new([i.idaccounts]);
		}
		);
		Account.on('oncontactselected', function(e) {
			ContactWidget.set('idcontact', e.idcontact);
		}
		);
		Account.DisabledContentPanes= function(disabled) {
			dijit.byId('ContentPaneTiempos').attr('disabled',  true);
			//dijit.byId('ContentPaneLocaliz').attr('disabled',  disabled);
			//dijit.byId('ContentPaneDatas').attr('disabled',  disabled);
			dijit.byId('ContentPaneContactos').attr('disabled',  disabled);
			dijit.byId('ContentPaneUsers').attr('disabled',  disabled);
			dijit.byId('ContentPaneEventos').attr('disabled',  disabled);
		}
		MenuGeneral.on('onnew', function() {
			Account.DisabledContentPanes(true);
			Account.new();
			ContactWidget.new();
			_EventView.reset();
			_Grid.clear();
			_Grid.set('idaccounts', []);
		}
		);
		MenuGeneral.on('onsave', function() {
			if(ContactWidget.get('idcontact')>0) {
				console.log('El contacto ya esta creado, simplemente guardamos');
				ContactWidget.save();
				Account.save();
			} else {
				console.log('El contacto no ha sido creado, lo creamos.');
				ContactWidget.save();
			}
		}
		);
		ContactWidget.on('contactmodified', function(e) {
			//Crea un contacto y lo setea 
			Account.set('idcontact', e.idcontact);
			setTimeout(function() {
				console.log('Creamos el abonado con el contacto id '+e.idcontact);
				Account.save();
			}
			, 1550);
		}
		);
		MenuGeneral.on('ondelete', function() {
			Account.delete();
		}
		);
		// ### SECCION CONTACTOS ###
		ContactW.on('notify_message', function(m) {
			MH.notification.notify( {
				message: m.message
			}
			);
		}
		);
		ContactW.on('onloadcontact', function(e) {
			GridxB.Load(e.idcontact);
			GridxC.Load(e.idcontact);
		}
		);
		ContactW.on('onsave', function(e) {
			GridxA.load(e.idaccount);
		}
		);
		ContactMB.on('onnew', function() {
			ContactW.New(Account.Id);
		}
		);
		ContactMB.on('onsave', function() {
			ContactW.save();
		}
		);
		ContactMB.on('ondelete', function() {
			ContactW.delete();
		}
		);
		var DialogContactNotifyContactsApplySelected = dijit.byId('id_contact_NotifyContactPhonesdialog');
		DialogContactNotifyContactsApplySelected.byes.set('label', 'Aplicar');
		DialogContactNotifyContactsApplySelected.bno.set('label', 'Cancelar');
		DialogContactNotifyContactsApplySelected.innerHTML(HtmlDialogNotifications('Los cambios se aplicarán a todos los números telefónicos de los contactos que haya seleccionado. Esta acción REEMPLAZARÁ los datos existentes', 'GridxAForm', 'GridxACall', 'GridxASMS', 'GridxAMsgText'));
		DialogContactNotifyContactsApplySelected.dijitOwner(dijit.byId('id_account_contact_notifygridx_popup'), 'Click').on('onok', function() {
			GridxA.ApplyNotifyToSelection(Account.Id, dijit.byId('GridxACall').get('checked'), dijit.byId('GridxASMS').get('checked'), dijit.byId('GridxAMsgText').get('value'));
		}
		);
		GridxA.on('rowclicked', function(item) {
			//console.log(item.idaccount+' >> '+item.idcontact);
			ContactW.Load(item.idaccount, item.idcontact);
		}
		);
		/*
	if (GridxA) {
GridxA.ApplyNotifyToSelection = function(){
if(GridxA.selected.length>0){
   R.post('notifyeditselectedcontacts.usaga', {
		data: {idaccount: Account.Id, idcontacts: GridxA.selected.toString(), call: dijit.byId('GridxACall').get('checked'), sms: dijit.byId('GridxASMS').get('checked'), msg: dijit.byId('GridxAMsgText').get('value')},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
if(d.length > 0){
GridxA.emit('notify_message', {message: d.getStringFromB64(0, 'outpgmsg')}); 
}
GridxA.Load();
ContactW.Load(Account.Id, 0);
                },
                function(error){
                    // Display the error returned
GridxA.emit('notify_message', {message: error}); 
                }
            );
}else{
GridxA.emit('notify_message', {message: 'No hay contactos seleccionados para aplicar los cambios'});
}
}
dojo.connect(GridxA.select.row, 'onSelectionChange', function(selected){
GridxA.selected = [];
var numsel = selected.length;
i = 0;
while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda, agregamos el idphone al array
GridxA.store.fetch({query: {unique_id: selected[i]}, onItem: function(item){
GridxA.selected[i] = GridxA.store.getValue(item, 'idcontact');
} 
});
i++;
}
});
GridxA.on('notify_message', function(m){
MH.notification.notify({message: m.message});
});
// Captura el evento cuando se hace click en una fila
dojo.connect(GridxA, 'onRowClick', function(evt){
var t = GridxA;
d = t.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
t.store.fetch({query: {unique_id: d}, onItem: function(item){
ContactW.Load(t.store.getValue(item, 'idaccount'), t.store.getValue(item, 'idcontact'));
}
});
});
		GridxA.setColumns([
			{field:"unique_id", name: "#", width: '20px'},
			{field:"enable_as_contact", name: "*", width: '20px', editor: "dijit/form/CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true},
			{field:"priority", name: "priority", width: '20px'},
			{field:"name", name: "nombre", width: '150px'},
			{field:"appointment", name: "Designacion"}
		]);
GridxA.startup();
}
*/
		/*
GridxA.Clear= function(){
GridxA.selected = [];
GridxA._setData({identifier: "unique_id", items: []});
}
GridxA._setData = function(data){
	id_account_contact_store.clearOnClose = true;
	id_account_contact_store.data = data;
	id_account_contact_store.close();
		GridxA.store = null;
		GridxA.setStore(id_account_contact_store);
}
*/
		/*
GridxA.Load = function(){
GridxA.resize();
GridxA.selected = [];
if(Account.Id > 0){
   R.get('getaccountcontactsgrid.usaga', {
		query: {idaccount: Account.Id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;
var myData = {identifier: "unique_id", items: []};
if(numrows > 0){
var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id: i+1,
idcontact: d.getNumber(i, "idcontact"), 
idaccount: d.getNumber(i, "idaccount"), 
enable_as_contact: d.getBool(i, "enable_as_contact"),
priority: d.getNumber(i, "prioritycontact"),    
name: d.getStringFromB64(i, "lastname")+' '+d.getStringFromB64(i, "firstname"),
appointment: d.getStringFromB64(i, "appointment")
};
i++;
}
}
GridxA._setData(myData);
                },
                function(error){
                    // Display the error returned
console.log(error);
t.emit('notify_message', {message: error}); 
                }
            );
}else{
GridxA.Clear();
}
return GridxA;
}
*/
		// ### SECCION TELEFONOS DE CONTACTOS ###
		// Abre el dialogo
		var DialogContactNotifyPhoneApplySelected = dijit.byId('id_contact_NotifyContactdialog');
		DialogContactNotifyPhoneApplySelected.byes.set('label', 'Aplicar');
		DialogContactNotifyPhoneApplySelected.bno.set('label', 'Cancelar');
		DialogContactNotifyPhoneApplySelected.innerHTML(HtmlDialogNotifications('Los cambios se aplicarán a todos los números telefónicos que haya seleccionado. Esta acción REEMPLAZARÁ los datos existentes', 'GridxBForm', 'GridxBCall', 'GridxBSMS', 'GridxBMsgText'));
		DialogContactNotifyPhoneApplySelected.dijitOwner(dijit.byId('id_account_contact_phonenotify_notifycations_popup'), 'Click').on('onok', function() {
			GridxB.ApplyNotifyToSelection();
		}
		);
		if (GridxB) {
			GridxB.ApplyNotifyToSelection = function() {
				if(GridxB.selected.length>0) {
					R.post('notifyeditselectedphones.usaga', {
						data: {
							idaccount: Account.Id, idphones: GridxB.selected.toString(), call: dijit.byId('GridxBCall').get('checked'), sms: dijit.byId('GridxBSMS').get('checked'), msg: dijit.byId('GridxBMsgText').get('value')
						}
						,
						            handleAs: "xml"
					}
					).then(
					                function(response) {
						var d = new RXml.getFromXhr(response, 'row');
						if(d.length > 0) {
							GridxB.emit('notify_message', {
								message: d.getStringFromB64(0, 'outpgmsg')
							}
							);
						}
						GridxB.Load(ContactW.get('idcontact'));
					}
					,
					                function(error) {
						// Display the error returned
						GridxB.emit('notify_message', {
							message: error
						}
						);
					}
					);
				} else {
					MH.notification.notify( {
						message: 'No hay teléfonos seleccionados para aplicar los cambios'
					}
					);
				}
			}
			dojo.connect(GridxB.select.row, 'onSelectionChange', function(selected) {
				GridxB.selected = [];
				var numsel = selected.length;
				i = 0;
				while(i<numsel) {
					// Aqui buscamos los datos desde el store y no desde la celda, agregamos el idphone al array
					GridxB.store.fetch( {
						query: {
							unique_id: selected[i]
						}
						, onItem: function(item) {
							GridxB.selected[i] = GridxB.store.getValue(item, 'idphone');
						}
					}
					);
					i++;
				}
			}
			);
			GridxB.on('notify_message', function(m) {
				MH.notification.notify( {
					message: m.message
				}
				);
			}
			);
			GridxB.setColumns([ {
				field:"unique_id", name: "#", width: '20px'
			}
			,
			//			{field:"idnotifaccount", name: "id", width: '0px'},
			{
				field:"idphone", name: "idp", width: '0px'
			}
			, {
				field:"phone", name: "Teléfono", width: '100px'
			}
			, {
				field:"idprovider", name: "idprovider"
			}
			, {
				field:"priority", name: "Prioridad", width: '30px', editable: true
			}
			, {
				field:"call", name: "call", width: '20px', editable: true, editor: "dijit/form/CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true
			}
			, {
				field:"sms", name: "sms", width: '20px', editable: true, editor: "dijit/form/CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true
			}
			, {
				field:"smstext", name: "smstext", width: '150px', editable: true
			}
			, {
				field:"note", name: "Nota", editable: true
			}
			]);
			GridxB.startup();
			GridxB._setData = function(data) {
				ItemFileWriteStore_B.clearOnClose = true;
				ItemFileWriteStore_B.data = data;
				ItemFileWriteStore_B.close();
				GridxB.store = null;
				GridxB.setStore(ItemFileWriteStore_B);
			}
			GridxB.Clear= function() {
				GridxB.selected = [];
				GridxB._setData( {
					identifier: "unique_id", items: []
				}
				);
			}
			GridxB.Load = function(idcontact) {
				GridxB.selected = [];
				if(Account.Id > 0 && idcontact > 0) {
					R.get('getaccountphonesnotifgrid.usaga', {
						query: {
							idaccount: Account.Id, idcontact: idcontact
						}
						,
						            // Parse data from xml
						handleAs: "xml"
					}
					).then(
					                function(response) {
						var d = new RXml.getFromXhr(response, 'row');
						numrows = d.length;
						var myData = {
							identifier: "unique_id", items: []
						}
						;
						if(numrows > 0) {
							var i = 0;
							while(i<numrows) {
								myData.items[i] = {
									unique_id:i+1,
									idcontact: idcontact,
									idnotifaccount: d.getNumber(i, "idnotifaccount"),
									idphone: d.getNumber(i, "idphone"),
									idprovider: d.getNumber(i, "idprovider"),
									phone: d.getStringFromB64(i, "phone"),
									idaccount: d.getNumber(i, "idaccount"),
									priority: d.getNumber(i, "priority"),    
									call: d.getBool(i, "call"),
									sms: d.getBool(i, "sms"),
									smstext: d.getStringFromB64(i, "smstext"),
									note: d.getStringFromB64(i, "note")
								}
								;
								i++;
							}
						}
						GridxB._setData(myData);
					}
					,
					                function(error) {
						// Display the error returned
						console.log(error);
						GridxB.emit('notify_message', {
							message: error
						}
						);
					}
					);
				} else {
					GridxB.Clear();
				}
				return GridxB;
			}
			GridxB.SaveItem = function(itemStore) {
				var t = GridxB;
				R.post('getaccountnotificationstable.usaga', {
					data: {
						idnotifaccount: 0, idaccount:Account.Id, idphone: itemStore.idphone, priority: itemStore.priority, sms: itemStore.sms, call: itemStore.call, smstext: itemStore.smstext, note: itemStore.note
					}
					,
					            // Parse data from xml
					handleAs: "xml"
				}
				).then(
				                function(response) {
					var d = new RXml.getFromXhr(response, 'row');
					if(d.length > 0) {
						t.emit('notify_message', {
							message: d.getStringFromB64(0, 'outpgmsg')
						}
						);
					}
					t.Load(itemStore.idcontact);
				}
				,
				                function(error) {
					// Display the error returned
					t.emit('notify_message', {
						message: error
					}
					);
					t.Load(itemStore.idcontact);
				}
				);
			}
			dojo.connect(ItemFileWriteStore_B, 'onSet', function(item, attribute, oldValue, newValue) {
				GridxB.SaveItem(item);
			}
			);
		}
		//# SECCION USUARIOS #//
		if (GridxC) {
			// Captura el evento cuando se hace click en una fila
			dojo.connect(GridxC, 'onRowClick', function(event) {
				var t = GridxC;
				d = t.cell(event.rowId, 1, true).data();
				// Aqui buscamos los datos desde el store y no desde la celda.
				t.store.fetch( {
					query: {
						unique_id: d
					}
					, onItem: function(item) {
						UserW.Load(t.store.getValue(item, 'idaccount'), t.store.getValue(item, 'idcontact'));
					}
				}
				);
			}
			);
			// Optionally change column structure on the grid
			GridxC.setColumns([
			//			{field:"idcontact", name: "idcontact", width: '0px'}, 
			{
				field:"unique_id", name: "#", width: '20px'
			}
			, {
				field:"enable_as_user", name: "*", width: '20px', editor: "dijit/form/CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true
			}
			, {
				field:"numuser", name: "NU", width: '20px', editor: "dijit/form/NumberTextBox"
			}
			, {
				field:"name", name: "nombre"
			}
			, {
				field:"appointment", name: "Designacion", width: '100px'
			}
			]);
			GridxC.startup();
		}
		GridxC.Clear = function() {
			GridxC._setData( {
				identifier: "unique_id", items: []
			}
			);
		}
		GridxC._setData = function(data) {
			// Set new data on data store (the store has jsId set, so there's
			// a global variable we can reference)
			var store = ItemFileWriteStore_3;
			store.clearOnClose = true;
			store.data = data;
			store.close();
			// Tell our grid to reset itself
			GridxC.store = null;
			GridxC.setStore(store);
		}
		GridxC.Load = function() {
			var G = GridxC;
			if(Account.Id > 0) {
				R.get('fun_view_account_users_xml.usaga', {
					handleAs: "xml",
					query: {
						idaccount: Account.Id
					}
				}
				).then(function(response) {
					var xmld = new RXml.getFromXhr(response, 'row');
					var myData = {
						identifier: "unique_id", items: []
					}
					;
					if(xmld.length > 0) {
						var i = 0;
						var rowscount = xmld.length;
						while(i<rowscount) {
							myData.items[i] = {
								unique_id:i+1,
								idaccount: xmld.getNumber(i, "idaccount"), 
								idcontact: xmld.getNumber(i, 'idcontact'), 
								enable_as_user: xmld.getBool(i, 'enable_as_user'),
								numuser: xmld.getNumber(i, 'numuser'),
								name: xmld.getStringFromB64(i, 'lastname')+' '+xmld.getStringFromB64(i, 'firstname'),
								appointment: xmld.getStringFromB64(i, 'appointment'),
							}
							;
							i++;
						}
					}
					GridxC._setData(myData);
				}
				, function(error) {
					NotifyMSG.notify( {
						message: error
					}
					);
				}
				);
			} else {
				GridxC.Clear();
			}
		}
		UserW.on('notify_message', function(m) {
			MH.notification.notify( {
				message: m.message
			}
			);
		}
		);
		UserW.on('onloaduser', function(e) {
			GridxD.Load(e.idaccount, e.idcontact);
		}
		);
		UserW.on('onsave', function() {
			GridxC.Load();
		}
		);
		UserMB.on('onnew', function() {
			UserW.New(Account.Id);
		}
		);
		UserMB.on('onsave', function() {
			UserW.save();
		}
		);
		UserMB.on('ondelete', function() {
			UserW.delete();
		}
		);
		//# SECCION CTRL ALARMA #//
		GridxD.Clear = function() {
			GridxD._setData( {
				identifier: "unique_id", items: []
			}
			);
		}
		GridxD._setData = function(data) {
			var store = ItemFileWriteStore_4;
			store.clearOnClose = true;
			store.data = data;
			store.close();
			// Tell our grid to reset itself
			GridxD.store = null;
			GridxD.setStore(store);
		}
		// Setea las columnas de la tabla
		GridxD.setColumns([
		//			{field:"unique_id", name: "#", width: '20px'}, 
		{
			field:"enable", name: "*", width: '20px', editable: true, editor: "dijit/form/CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true
		}
		,
		//			{field:"type", name: "type", width: '20px'} 
		{
			field:"phone", name: "Teléfono", width: '150px'
		}
		, {
			field:"fromsms", name: "sms", width: '20px', editable: true, editor: "dijit/form/CheckBox", 
						editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true
		}
		, {
			field:"fromcall", name: "call", width: '20px', editable: true, editor: "dijit/form/CheckBox", 
					editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true,
		}
		, {
			field:"note", name: "Nota", width: '100px', editable: true
		}
		]);
		GridxD.startup();
		GridxD.Clear();
		dojo.connect(ItemFileWriteStore_4, 'onSet', function(item, attribute, oldValue, newValue) {
			GridxD.SaveItem(item);
		}
		);
		GridxD.SaveItem = function(item) {
			if(item.idaccount > 0 && item.idcontact > 0 && GridxD) {
				R.post('fun_account_phones_trigger_alarm_table_from_hashmap.usaga', {
					handleAs: "xml",
					data: {
						idaccount: item.idaccount, idphone: item.idphone, enable: item.enable, fromsms: item.fromsms, fromcall: item.fromcall, note: item.note
					}
				}
				).then(function(response) {
					var xmld = new RXml.getFromXhr(response, 'row');
					NotifyMSG.notify( {
						message: xmld.getStringFromB64(0, 'outpgmsg')
					}
					);
					var idcontactuser = xmld.getNumber(0, 'outreturn');
					GridxD.Load(Account.Id, idcontactuser);
				}
				, function(error) {
					NotifyMSG.notify( {
						message: error
					}
					);
				}
				);
			} else {
				GridxD,Clear();
			}
		}
		GridxD.Load = function(idaccount_, idcontact_) {
			var G = GridxD;
			if(idaccount_ > 0 && idcontact_ > 0) {
				R.get('getaccountphonestriggerview.usaga', {
					handleAs: "xml",
					query: {
						idaccount: idaccount_, idcontact: idcontact_
					}
				}
				).then(function(response) {
					var dataxml = new RXml.getFromXhr(response, 'row');
					var myData = {
						identifier: "unique_id", items: []
					}
					;
					if(dataxml.length > 0) {
						var i = 0;
						var rowscount = dataxml.length;
						while(i<rowscount) {
							myData.items[i] = {
								unique_id:i+1,
								idaccount: dataxml.getNumber(i, "idaccount"),
								idcontact: dataxml.getNumber(i, "idcontact"),  
								idphone: dataxml.getNumber(i, "idphone"), 
								enable: dataxml.getBool(i, "trigger_alarm"),
								idprovider: dataxml.getNumber(i, "idprovider"),
								type: dataxml.getNumber(i, "type"),
								phone: dataxml.getStringFromB64(i, "phone"),
								fromsms: dataxml.getBool(i, "fromsms"),    
								fromcall: dataxml.getBool(i, "fromcall"),    
								note: dataxml.getStringFromB64(i, "note")
							}
							;
							i++;
						}
					}
					GridxD._setData(myData);
				}
				, function(error) {
					NotifyMSG.notify( {
						message: error
					}
					);
				}
				);
			} else {
				GridxD.Clear();
			}
		}
		//# FUNCIONES QUE SE EJECUTAN CUANDO SE HA CARGADO LA PAGINA #//
		MH.notification.notify( {
			message: 'uSAGA - Abonados'
		}
		);
		//Se ajusta al tamaño de la pantalla actual
		BodyApp.adjustElements();
		Account.DisabledContentPanes(true);
	}
	);
}
);
