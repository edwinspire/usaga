require(["dojo/ready",  
"dojo/on",
"dojo/data/ItemFileWriteStore",
'jspire/usms/GridxSMSInBuilder',
'jspire/usms/GridxSMSOutBuilder',
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
], function(ready, on, ItemFileWriteStore, GridxSMSInBuilder, GridxSMSOutBuilder, Grid, Async, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller, request, RXml, jsGridx){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here
//dijit.byId('id_titlebar').set('label', 'CHIP SIM GSM');
//var NotifyArea = dijit.byId('id_notify_area');  
var AccordionSendToContacts = dijit.byId('idAccordionSendToContacts');

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

var smsD = FormSMSFree.get('values');
smsD.phone = IFWS1.getValue(item, 'unique_id');
smsD.idprovider = IFWS1.getValue(item, 'idprovider');
smsD.idsim = IFWS1.getValue(item, 'idsim');

PostSendSMS(smsD);

}});

}else{
MH.notification.notify({message: 'Revise que los datos del mensaje sean correctos antes de intentar nuevamente'});
}

});

var PostSendSMS = function(sms_){
request.post('/fun_outgoing_new_xml.usms', {
   handleAs: "xml",
data: sms_
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
MH.notification.notify({message: xmld.getStringFromB64(0, 'msg')});
}
//GridxPhonesF.Load();
}, function(error){
MH.notification.notify({message: error});
});
}


   var GridxPhonesF = jsGridx.addItemSelection('GridxPhonesFree');
//var GridxPhonesF = dijit.byId('GridxPhonesFree');

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

var num = GridxPhonesF.ItemSelected.length;

if(num>0){
i = 0;
while(i < num){
IFWS1.deleteItem(GridxPhonesF.ItemSelected[i]);
IFWS1.save();
i++;
}
		GridxPhonesF.store = null;
		GridxPhonesF.setStore(IFWS1);

}else{
MH.notification.notify({message: 'No hay remitentes seleccionados'});
}
}

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

  // var GridxListContact = jsGridx.addItemSelection('idGridxListContact');

var GridxListContact = dijit.byId('idGridxListContact');
GridxListContact.RowSelected = [];

dojo.connect(GridxListContact.select.row, 'onSelectionChange', function(selected){	
GridxListContact.RowSelected = [];
numsel = selected.length;
var i = 0;
while(i<numsel){
GridxListContact.store.fetch({query: {unique_id: selected[i]}, onItem: function(item){
GridxListContact.RowSelected[i] = {idphone: GridxListContact.store.getValue(item, 'idphone'), name: GridxListContact.store.getValue(item, 'name'), phone: GridxListContact.store.getValue(item, 'phone')}
} 
});
i++;
}
});



var TBoxSearchContactPhone = dijit.byId('idTBoxSearchContactPhone');
TBoxSearchContactPhone.on('search', function(e){
GridxListContact.Load();
});

if (GridxListContact) {

		// Optionally change column structure on the grid
		GridxListContact.setColumns([
			{field:"unique_id", name: "#", width: '30px'},
			{field:"name", name: "Nombre"},			
			{field:"phone", name: "Teléfono"}
		]);
GridxListContact.startup();
}


GridxListContact.Clear= function(){
GridxListContact.ItemSelected = [];
GridxListContact._setData({identifier: "unique_id", items: []});
}



GridxListContact._setData = function(data){
	IFWS2.clearOnClose = true;
	IFWS2.data = data;
	IFWS2.close();
		GridxListContact.store = null;
		GridxListContact.setStore(IFWS2);
}


dijit.byId('idBtnAddContactPhone').on('Click', function(){
if(GridxListContact.RowSelected.length>0){
var myData = {identifier: "unique_id", items: []};

var items = [];
// En este bloque tomamos los datos ya existentes en la lista de envio y formamos un nuevo array
IFWS_4.fetch({query:{} , onItem: function(item){
idphone = IFWS_4.getValue(item, 'idphone');
// Verificamos que el idphone exista
if(idphone){
items.push({idphone: idphone, name: IFWS_4.getValue(item, 'name'), phone: IFWS_4.getValue(item, 'phone')});
}
}

});


// Ahora agregamos a la lista de datos los nuevos seleccionados.
GridxListContact.RowSelected.forEach(function(r){
// Agregamos el registro r si aun no existe en items
if(!dojo.some(items, function(item){ return item == r; })){
items.push(r);
}
});


var itemsEnd = dojo.map(items, function(item, index){
item.unique_id = index+1;
    return item;
});

myData.items = itemsEnd;

GridxListToSend._setData(myData);
}else{
MH.notification.notify({message: 'No hay registros seleccionados'});
}

});


GridxListContact.Load = function(){
GridxListContact.RowSelected = [];

            // Request the text file
            request.post("fun_view_contacts_phones_with_search_xml.usms", {
		data: {contact_phone_search: TBoxSearchContactPhone.get('value'), exclude_idphones: GridxListToSend.idphones().toString()},
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
idphone: d.getNumber(i, "idphone"),
phone: d.getStringFromB64(i, "phone")
};
i++;
}

GridxListContact._setData(myData);

                },
                function(error){
                    // Display the error returned
MH.notification.notify({message: error});
GridxListContact.Clear();
                }
            );

}

var SMSFormContact = dijit.byId('idSMSFormContact');
//SMSFormContact.advanced.Provider.Provider.set('disabled', true);
//SMSFormContact.advanced.SIM.SIM.set('disabled', true);


dijit.byId('idDialogContactSend').innerHTML('<div style="height: auto; width: 200px;">Desea enviar el mensaje de texto a los contactos listados?</div>').dijitOwner(dijit.byId('idBtnSendSMSContact'), 'Click').on('onok', function(){

if(SMSFormContact.validate()){
IFWS_4.fetch({query:{} , onItem: function(item){

var s = SMSFormContact.get('values');
s.idphone = IFWS_4.getValue(item, 'idphone');

PostSendSMS(s);

}});

}else{
MH.notification.notify({message: 'Revise que los datos del mensaje sean correctos antes de intentar nuevamente'});
}

});

dijit.byId('idDialogContactSendReset').innerHTML('<div style="height: auto; width: 200px;">Desea realmente eliminar los contactos seleccionados?</div>').dijitOwner(dijit.byId('idResetListContacts'), 'Click').on('onok', function(){
GridxListToSend._setData({identifier: "unique_id", items: []});
GridxListContact.Load();
});

// Elimina los telefonos de contactos seleccionados de la lista de envio
dijit.byId('idDialogDeletContactToSend').innerHTML('<div style="height: auto; width: 200px;">Está seguro de eliminar los contactos seleccionados?</div>').dijitOwner(dijit.byId('idBtnDeleteContact'), 'Click').on('onok', function(){

var items_ = [];
var i = 1;
IFWS_4.fetch({query:{} , onItem: function(item){

if(!dojo.some(GridxListToSend.RowSelected, function(reg){ return reg == IFWS_4.getValue(item, 'unique_id'); })){
item.unique_id = i;
items_.push(item);
i++;
}

}});

GridxListToSend._setData({identifier: "unique_id", items: items_});
GridxListContact.Load();
});




   var GridxListToSend = dijit.byId('idGridxListToSend');

if (GridxListToSend) {

		// Optionally change column structure on the grid
		GridxListToSend.setColumns([
			{field:"unique_id", name: "#", width: '30px'},
			{field:"name", name: "Nombre"},			
			{field:"phone", name: "Teléfono"}
		]);
GridxListToSend.startup();
}

GridxListToSend.RowSelected = [];

dojo.connect(GridxListToSend.select.row, 'onSelectionChange', function(selected){	
GridxListToSend.RowSelected = selected;
});

GridxListToSend._setData = function(data){
	IFWS_4.clearOnClose = true;
	IFWS_4.data = data;
	IFWS_4.close();
		GridxListToSend.store = null;
		GridxListToSend.setStore(IFWS_4);

AccordionSendToContacts.selectChild('idContentPaneSMSToSendContact', true);
GridxListContact.ItemSelected = [];
GridxListContact.Load();
}

GridxListToSend.idphones = function(){
var idphonesList = [];
IFWS_4.fetch({query:{} , onItem: function(item){
idphone = IFWS_4.getValue(item, 'idphone');
if(idphone){
idphonesList.push(idphone);
}
}

});
return idphonesList;
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

var GridxSMSIn = GridxSMSInBuilder.Build(dijit.byId("idGridxSMSIn"), IFWSSMSIn);

var FromToSelect = dijit.byId('idFromToSMSIn');
FromToSelect.on('onget', function(e){
GridxSMSIn.Load(e.From, e.To, e.Rows);
});


var GridxSMSOut = GridxSMSOutBuilder.Build(dijit.byId("idGridxSMSOut"), IFWS5);

var FromToSMSOut = dijit.byId('idFromToSMSOut');
FromToSMSOut.on('onget', function(e){
GridxSMSOut.Load(e.From, e.To, e.Rows);
});


GridxListContact.Load();



     });
});
