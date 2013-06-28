require(["dojo/ready",  
"dojo/on",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"dojo/request",
"jspire/request/Xml",
"jspire/Gridx",
"dojox/grid/cells/dijit",
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/TooltipDialog",
"dijit/popup",
"dijit/form/CheckBox",
"dijit/form/Select"
], function(ready, on, ItemFileWriteStore, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller, request, RXml, jsGridx){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here
//dijit.byId('id_titlebar').set('label', 'CHIP SIM GSM');
//var NotifyArea = dijit.byId('id_notify_area');  
var MH = dijit.byId('idMH');
var FormSMSFree = dijit.byId('idFormSMSFree');
FormSMSFree.advanced.Provider.Provider.set('disabled', true);
FormSMSFree.advanced.SIM.SIM.set('disabled', true);


        var DialogFreeAddPhone = dijit.byId('idDialogFreeAddPhone');
DialogFreeAddPhone.innerHTML(' <div style="height: auto; width: 250px;"><span style="margin: 3px; display: inline-block;"><label style="margin-right: 10px;">Tel&eacute;fono:</label><input type="text" data-dojo-type="dijit/form/ValidationTextBox" regExp="[\+|0-9]+" id="idSMSFreeFieldPhone" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="Phone" title="Ingrese el n&amp;uacute;mero telef&amp;oacute;nico"></input></span><span style="margin: 3px; display: inline-block;"> <label>   Proveedor:</label> <div data-dojo-type="_usms_provider_select/_usms_provider_select" id="idSMSFreeFieldProvider" title="Proveedor de telefon&amp;iacute;a" style="display: inline;"></div></span><span style="margin: 3px; display: inline-block;"><label style="margin-right: 30px;">  SIM:</label><div data-dojo-type="_usms_sim_select/_usms_sim_select" id="idSMSFreeFieldSIM" title="CHIP - SIM GSM para usar en el env&amp;iacute;o" style="display: inline;"></div></span></div>');


DialogFreeAddPhone.dijitOwner(dijit.byId('idFreeAddSender'), 'Click').on('onok', function(){
//IFWS1.clearOnClose = true;
IFWS1.newItem({unique_id: dijit.byId('idSMSFreeFieldPhone').get('value'), idprovider: dijit.byId('idSMSFreeFieldProvider').get('value'), provider: dijit.byId('idSMSFreeFieldProvider').displayedValue(), sim: dijit.byId('idSMSFreeFieldSIM').displayedValue(), idsim: dijit.byId('idSMSFreeFieldSIM').get('value')});
IFWS1.save();
dijit.byId('idSMSFreeFieldPhone').set('value', '');
dijit.byId('idSMSFreeFieldProvider').reset();
dijit.byId('idSMSFreeFieldSIM').reset();
});


var DialogFreeSendReset = dijit.byId('idDialogFreeSendReset');
DialogFreeSendReset.innerHTML('<div style="height: auto; width: 200px;">Esta acción borrará todos los remitentes que haya ingresado y los datos del mensaje. Desea hacerlo?</div>');
DialogFreeSendReset.dijitOwner(dijit.byId('idFreeSMSReset'), 'Click').on('onok', function(){
FormSMSFree.reset();
GridxPhonesF.Clear();
});


        var DialogFreeSend = dijit.byId('idDialogFreeSend');
DialogFreeSend.innerHTML('<div style="height: auto; width: 200px;">Está seguro de querer enviar los mensajes de texto a los remitentes ingresados?</div>');
DialogFreeSend.dijitOwner(dijit.byId('idFreeSendSMS'), 'Click').on('onok', function(){


if(FormSMSFree.validate()){
IFWS1.fetch({query:{} , onItem: function(item){
///alert(IFWS1.getValue(item, 'unique_id'));

var smsD = FormSMSFree.get('values');
smsD.phone = IFWS1.getValue(item, 'unique_id');
smsD.idprovider = IFWS1.getValue(item, 'idprovider');
smsD.idsim = IFWS1.getValue(item, 'idsim');

request.post('/fun_outgoing_new_xml.usms', {
   handleAs: "xml",
data: smsD
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
MH.notification.notify({message: xmld.getStringFromB64(0, 'msg')});
}
//GridxPhonesF.Load();
}, function(error){
MH.notification.notify({message: error});
});



}});

}else{
MH.notification.notify({message: 'Revise que los datos del mensaje sean correctos antes de intentar nuevamente'});
}

});


var GridxPhonesF = dijit.byId('GridxPhonesFree');
GridxPhonesF.RowSelection = [];

// Capturamos el evento onSelectionChange de la gridx 
dojo.connect(GridxPhonesF.select.row, 'onSelectionChange', function(selected){
GridxPhonesF.RowSelection = [];
numsel = selected.length;
var i = 0;
while(i<numsel){
GridxPhonesF.store.fetch({query: {unique_id: selected[i]}, onItem: function(item){
GridxPhonesF.RowSelection[i] = GridxPhonesF.store.getValue(item, 'unique_id');
} 
});
i++;
}
});

var DialogFreeRemovePhone = dijit.byId('idDialogFreeRemovePhone');
DialogFreeRemovePhone.innerHTML('<div style="height: auto; width: 150px;">Desea eliminar los remitentes seleccionados?</div>');
DialogFreeRemovePhone.dijitOwner(dijit.byId('idFreeRemoveSender'), 'Click').on('onok', function(){
GridxPhonesF.Delete();
});


	if (GridxPhonesF) {

		// Optionally change column structure on the grid
		GridxPhonesF.setColumns([
			{field:"unique_id", name: "Teléfono"},
			{field:"provider", name: "Proveedor"},			
			{field:"sim", name: "SIM"}
		]);
GridxPhonesF.startup();
}


GridxPhonesF.Clear= function(){
GridxPhonesF.selected = [];
GridxPhonesF._setData({identifier: "unique_id", items: []});
}



GridxPhonesF._setData = function(data){
	IFWS1.clearOnClose = true;
	IFWS1.data = data;
	IFWS1.close();
		GridxPhonesF.store = null;
		GridxPhonesF.setStore(IFWS1);
}



GridxPhonesF.Delete = function(){

var num = GridxPhonesF.RowSelection.length;

if(num>0){
i = 0;
while(i < num){
GridxPhonesF.store.fetch({query: {unique_id: GridxPhonesF.RowSelection[i]}, onItem: function(item){
IFWS1.deleteItem(item);
IFWS1.save();
} 
});

i++;
}
}else{
MH.notification.notify({message: 'No hay remitentes seleccionados'});
}
}

////////////////////////////////////////////////////////////////////////////////////////
var GridxListContact = dijit.byId('idGridxListContact');	


if (GridxListContact) {

		// Optionally change column structure on the grid
		GridxListContact.setColumns([
			{field:"unique_id", name: "#"},
			{field:"name", name: "Nombre"},			
			{field:"phone", name: "Teléfono"}
		]);
GridxListContact.startup();
}


GridxListContact.Clear= function(){
GridxListContact.selected = [];
GridxListContact._setData({identifier: "unique_id", items: []});
}



GridxListContact._setData = function(data){
	IFWS2.clearOnClose = true;
	IFWS2.data = data;
	IFWS2.close();
		GridxListContact.store = null;
		GridxListContact.setStore(IFWS2);
}



GridxListContact.Delete = function(){

var num = GridxListContact.RowSelection.length;

if(num>0){
i = 0;
while(i < num){
GridxListContact.store.fetch({query: {unique_id: GridxListContact.RowSelection[i]}, onItem: function(item){
IFWS2.deleteItem(item);
IFWS2.save();
} 
});

i++;
}
}else{
MH.notification.notify({message: 'No hay remitentes seleccionados'});
}
}

GridxListContact.Load = function(){
//NotifyArea.notify({message: 'Cargando datos. Por favor espere...'});
GridxListContact.RowSelection = [];

            // Request the text file
            request.post("fun_view_contacts_phones_with_search_xml.usms", {
		data: {},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i+1,
name: d.getStringFromB64(i, "name"),
phone: d.getStringFromB64(i, "phone")
};
i++;
}

GridxListContact._setData(myData);

                },
                function(error){
                    // Display the error returned
//NotifyArea.notify({message: error});
GridxListContact.Clear();
                }
            );

}


/*

GridxPhonesF.Load = function(){
//NotifyArea.notify({message: 'Cargando datos. Por favor espere...'});
GridxPhonesF.RowSelection = [];

            // Request the text file
            request.get("fun_view_sim_xml.usms", {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i+1,
idsim: d.getNumber(i, "idsim"),
idprovider: d.getNumber(i, "idprovider"),
enable: d.getBool(i, "enable"),
phone: d.getStringFromB64(i, "phone"),
smsout_request_reports: d.getBool(i, "smsout_request_reports"),
smsout_retryonfail: d.getNumber(i, "smsout_retryonfail"),
smsout_max_length: d.getNumber(i, "smsout_max_length"),
smsout_max_lifetime: d.getNumber(i, "smsout_max_lifetime"),
smsout_enabled_other_providers: d.getBool(i, "smsout_enabled_other_providers"),
idmodem: d.getString(i, "idmodem"),
on_incommingcall: d.getNumber(i, "on_incommingcall"),
note: d.getStringFromB64(i, "note"),
ts: d.getString(i, "ts"),
};
i++;
}

GridxPhonesF._setData(myData);

                },
                function(error){
                    // Display the error returned
NotifyArea.notify({message: error});
GridxPhonesF.Clear();
                }
            );

}

// Guarda los datos
GridxPhonesF.SaveItem = function(item){

request.post('fun_sim_table_edit_xml.usms', {
   handleAs: "xml",
data: item
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');
//alert(xmld.getStringFromB64(0, 'message'));
if(xmld.length > 0){
NotifyArea.notify({message: xmld.getStringFromB64(0, 'outpgmsg')});
}
GridxPhonesF.Load();
}, function(error){
NotifyArea.notify({message: error});
});

}


        var myDialogNew = dijit.byId('idDialogNew');
myDialogNew.byes.set('label', 'Cerrar');
myDialogNew.bno.set('label', 'Cancelar');
myDialogNew.innerHTML('<div style="width: 200px;"><div>No puede crear manualmente un registro.</div><div>Estos registros se crean automáticamente al leer un contacto de la lista de contactos de la tajeta SIM cuyo nombre es "usms" y como número consta el número telefónico de esa SIM.</div></div>');
myDialogNew.dijitOwner(dijit.byId('new'), 'Click');


//--
        dojo.connect(dojo.byId('getdata'), 'onclick', function(){
GridxPhonesF.Load();
});

//--
        var DialogFreeAddPhone = dijit.byId('iddialogdelete');
DialogFreeAddPhone.dijitOwner(dijit.byId('delete'), 'Click').on('onok', function(){

if(GridxPhonesF.RowSelection.length > 0){
GridxPhonesF.Delete();
}else{
NotifyArea.notify({message: 'No hay registros seleccionados'});
}
});


	dojo.connect(IFWS1, 'onSet', function(item, attribute, oldValue, newValue){
GridxPhonesF.SaveItem(item);
});








*/

GridxListContact.Load();



     });
});
