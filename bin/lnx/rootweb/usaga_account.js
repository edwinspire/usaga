	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
'dojo/store/Memory',
  "dijit/form/FilteringSelect", 
"dojo/Evented",
"dojo/data/ItemFileReadStore",
"dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
  "dijit/form/CheckBox",
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
  "dijit/form/NumberTextBox",
"gridx/modules/VirtualVScroller",
"jspire/request/Xml",
"dojo/request",
"jspire/Gridx",
"jspire/form/DateTextBox",
"dojox/grid/cells/dijit",
"dojox/data/XmlStore",
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/TooltipDialog",
"dijit/popup"
], function(ready, on, Memory, FilteringSelect, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, CheckBox, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller, RXml, request, jsGridx, jsDateTextBox){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

/////////////////
///// BASIC /////
// Account basic elements


var GlobalObject = {
DisabledContentPanes: function(disabled){

dijit.byId('ContentPaneTiempos').attr('disabled',  disabled);
dijit.byId('ContentPaneContactos').attr('disabled',  disabled);
dijit.byId('account.contentpane.users').attr('disabled',  disabled);
dijit.byId('ContentPaneNotifyGroup').attr('disabled',  disabled);
dijit.byId('ContentPaneEventos').attr('disabled',  disabled);
dijit.byId('ContentPaneDataInstall').attr('disabled',  disabled);
dijit.byId('ContentPaneMantenimiento').attr('disabled',  disabled);
dijit.byId('ContentPaneLocaliz').attr('disabled',  disabled);
},
IdAccount: 0,
MasterDiv: dojo.byId('usaga.account.divmaster'),

LoadListIdContactsNames: function(){
var Objeto = this;

var store = new dojox.data.XmlStore({url: "usms_getcontactslistidcontactname_xml", sendQuery: true, rootItem: 'row'});

var request = store.fetch({onComplete: function(itemsrow, r){

var dataxml = new RXml.getFromXmlStore(store, itemsrow);

numrows = itemsrow.length;

//var myData = {identifier: "unique_id", items: []};

if(numrows > 0){
var Items = [];

//var len = xmldata.length;
var i = 0;
while(i<numrows){
Items[i] =    {name: dataxml.getStringFromB64(i, 'name'), id: dataxml.getNumber(i, "idcontact")};
i++;
}
//on.emit(Objeto.MasterDiv, "onListIdContactNameLoaded", {data: new Memory({data: Items})});
var d = new Memory({data: Items});

//----var userSelectBox = dijit.byId('usaga.account.users.form.idcontact');
var userSelectBox = dijit.byId('usaga.account.users.form.idcontact');
userSelectBox.store = null;
userSelectBox.store = d;
userSelectBox.startup();
userSelectBox.readOnly = true;

AC.dijit.Select.store = null;
AC.dijit.Select.store = d;
AC.dijit.Select.startup();
AC.dijit.Select.readOnly = true;

}

},
onError: function(e){
alert(e);
}
});

return Objeto;
}
}








dojo.connect(dijit.byId('account.contentpane.users'), 'onShow', function(e){
//ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
LoadAccountUsersGridx();
});



///////////////////////////
///// ACCOUNT ADDRESS /////
var AA = {
AddressW : dijit.byId('usaga_account_address'),
Delete: function(){
this.AddressW.delete();
},
Load: function(){
this.AddressW.load(this.AddressW.idaddress);
},
Save: function(){
// Objeto Widget Address
this.AddressW.save();
}
} 

AA.AddressW.save = function(){
var t = this;
var dat = t.values();
dat.idaccount = Account_Main_Data.idaccount();
            // Request the text file
            request.post("fun_account_address_edit_xml.usaga", {
            // Parse data from xml
	data: dat,
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

if(d.length > 0){
t.idaddress = d.getInt(0, 'outreturn');
t.load(t.idaddress);
alert(d.getStringFromB64(0, 'outpgmsg'));
}else{
t.reset();
}

                },
                function(error){
                    // Display the error returned
t.reset();
//t.emit('onloaddata', t.values());
alert(error);
                }
            );

}


dojo.connect(dojo.byId('accountwlocationaddress_save'), 'onclick', function(){
AA.Save();
});

dojo.connect(dojo.byId('accountwlocationaddress_delete'), 'onclick', function(){
AA.Delete();
});




////////////////////
///// USUARIOS /////
var myAccountUsersGridX = dijit.byId("usaga.account.users.gridx");

dojo.connect(dijit.byId("usaga.account.user.button.new"), 'onClick', function(){
			dojo.byId("usaga.account.users.form").reset();
dijit.byId("usaga.account.users.form.idcontact").readOnly = false;

PTElements.GxPTClear();

});

dojo.connect(dijit.byId("usaga.account.user.button.save"), 'onClick', SaveFormAccountUser);
dojo.connect(dijit.byId("usaga.account.user.button.del"), 'onClick', DeleteFormAccountUser);
dojo.connect(dijit.byId("usaga.account.user.button.contactdata"), 'onClick', function(){
alert('No implementado');
});




	if (myAccountUsersGridX) {
// Captura el evento cuando se hace click en una fila
dojo.connect(myAccountUsersGridX, 'onRowClick', function(event){
LoadFormAccountUser(this.cell(event.rowId, 1, true).data());
});
		// Optionally change column structure on the grid
		myAccountUsersGridX.setColumns([
			{field:"idcontact", name: "idcontact", width: '0px'},
			{field:"enable_as_user", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true, disabled: true},
			{field:"numuser", name: "#", width: '20px', editable: true, editor: "dijit.form.NumberTextBox"},
			{field:"name", name: "nombre"},
			{field:"appointment", name: "Designacion", width: '100px', editable: true}
		]);
myAccountUsersGridX.startup();
}


function DeleteFormAccountUser(){
SaveFormAccountUser(true);
}

function SaveFormAccountUser(deleteuser){

var formdata = { idaccount: Account_Main_Data.idaccount()};
formdata.idcontact = dijit.byId('usaga.account.users.form.idcontact').get('value');

if(deleteuser == true){
formdata.idcontact = formdata.idcontact*-1;
}

formdata.enable = dijit.byId('usaga.account.users.form.enable').get('checked');
formdata.appointment = dijit.byId('usaga.account.users.form.appointment').get('value');
formdata.keyword = dijit.byId('usaga.account.users.form.keyword').get('value');
formdata.pwd = dijit.byId('usaga.account.users.form.pwd').get('value');
formdata.note = dijit.byId('usaga.account.users.form.note').get('value');
formdata.numuser = dijit.byId('usaga.account.users.form.numuser').get('value');

if(Account_Main_Data.idaccount() > 0){

request.post('fun_account_users_table_xml_from_hashmap.usaga', {
   handleAs: "xml",
data: formdata
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

alert(xmld.getStringFromB64(0, 'outpgmsg'));

var idcontactuser = xmld.getNumber(0, 'outreturn');
LoadAccountUsersGridx();
if(idcontactuser == formdata.idcontact){
LoadFormAccountUser(idcontactuser);
}else{
	dojo.byId("usaga.account.users.form").reset();
}

}, function(error){
alert(error);
});

}else{
			dojo.byId("usaga.account.users.form").reset();
}
dijit.byId("usaga.account.users.form.idcontact").readOnly = true;
}

function LoadFormAccountUser(iniidcontact){

var inidaccount = Account_Main_Data.idaccount();

if(inidaccount > 0){

request.get('fun_view_account_user_byidaccountidcontact_xml.usaga', {
   handleAs: "xml",
query:  {idaccount: inidaccount, idcontact: iniidcontact}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){

dijit.byId('usaga.account.users.form.idcontact').set('value', xmld.getString(0, 'idcontact')); 
dijit.byId('usaga.account.users.form.enable').set("checked", xmld.getBool(0, 'enable'));
dijit.byId('usaga.account.users.form.numuser').set("value", xmld.getNumber(0, 'numuser'));
dijit.byId('usaga.account.users.form.appointment').set('value', xmld.getStringFromB64(0, 'appointment'));
dijit.byId('usaga.account.users.form.keyword').set('value', xmld.getStringFromB64(0, 'keyword'));
dijit.byId('usaga.account.users.form.pwd').set('value', xmld.getStringFromB64(0, 'pwd'));
dijit.byId('usaga.account.users.form.note').set('value', xmld.getStringFromB64(0, 'note'));

}else{
iniidcontact = 0;
}

LoadAccountPhonesTriggerGridx(iniidcontact);

}, function(error){
LoadAccountPhonesTriggerGridx(iniidcontact);
alert(error);
});

}else{
			dojo.byId("usaga.account.users.form").reset();
LoadAccountPhonesTriggerGridx(0);
}
}

function LoadAccountUsersGridx(){

dojo.byId("usaga.account.users.form").reset();

var inidaccount = Account_Main_Data.idaccount();

var myData = {identifier: "unique_id", items: []};
	var myGridX = dijit.byId("usaga.account.users.gridx");

if(inidaccount > 0){

request.get('fun_view_account_users_xml.usaga', {
   handleAs: "xml",
query:  {idaccount: inidaccount}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){

var i = 0;
var rowscount = xmld.length;
while(i<rowscount){

myData.items[i] = {
unique_id:i,
//s: false, 
idcontact: xmld.getNumber(i, 'idcontact'), 
enable_as_user: xmld.getBool(i, 'enable_as_user'),
numuser: xmld.getNumber(i, 'numuser'),
name: xmld.getStringFromB64(i, 'lastname')+' '+xmld.getStringFromB64(i, 'firstname'),
appointment: xmld.getStringFromB64(i, 'appointment'),
};

i++;
}


}

	// Set new data on data store (the store has jsId set, so there's
	// a global variable we can reference)
	var store = usaga_account_users_ItemFileWriteStoreUsers;
	store.clearOnClose = true;
	store.data = myData;
	store.close();

		// Tell our grid to reset itself
		myGridX.store = null;
		myGridX.setStore(store);

}, function(error){
alert(error);
});

}else{
			dijit.byId("usaga.account.users.gridx").store = null;
}
}


///////////////////////////////////////
///////////// PHONES TRIGGER //////////
// Phones Trigger Elements
var PTElements = {
dojo: {
GxPT: dojo.byId("usaga.account.phonestrigger.gridx")
},
dijit: {
GxPT: dijit.byId("usaga.account.phonestrigger.gridx")
},
GxPTClear: function(){

	usaga_account_users_ItemFileWriteStoreTriggerAlarm.clearOnClose = true;
	usaga_account_users_ItemFileWriteStoreTriggerAlarm.data =  {identifier: "unique_id", items: []};
	usaga_account_users_ItemFileWriteStoreTriggerAlarm.close();

		// Tell our grid to reset itself
		this.dijit.GxPT.store = null;
		this.dijit.GxPT.setStore(usaga_account_users_ItemFileWriteStoreTriggerAlarm);

} 

}


// Creamos esta funcion paralela para cargar la lista de proveedores en los select que van dentro de la grid, como la carga es asincrona fue necesario crear la estructura de la gridx una vez esten listos los datos para los selects.
PTElements.dijit.GxPT.setColumnsNew = function(){
            // Request the text file
   request.get('usms_provider_listidname_xml', {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
var Items = [];
numfields = d.length;
var i = 0;
while(i<numfields){
Items[i] =    {value: d.getStringFromB64(i, 'name'), id: d.getString(i, 'idprovider')};
i++;
}

fieldStore = new Memory({data: Items});

		PTElements.dijit.GxPT.setColumns([
			{field:"idcontact", name: "idcontact", width: '0px'},
			{field:"idphone", name: "idphone", width: '0px'},
			{field:"enable", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true},
			{field:"type", name: "type", width: '20px'},
			{field:"idprovider", name: "provider", editable: true, alwaysEditing: true,
					editor: 'dijit.form.Select',
					editorArgs: {
						props: 'store: fieldStore, labelAttr: "value", disabled: "true"'}},
			{field:"phone", name: "Teléfono", width: '150px'},
//			{field:"address", name: "Dirección", width: '150px'},
			{field:"fromsms", name: "sms", width: '20px', editable: true, editor: "dijit.form.CheckBox", 
			editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true},

			{field:"fromcall", name: "call", width: '20px', editable: true, editor: "dijit.form.CheckBox", 
		editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true,
			},
			{field:"note", name: "Nota", width: '100px', editable: true}
		]);
PTElements.dijit.GxPT.startup();


                },
                function(error){
alert(error);
                }
            );

}




PTElements.dijit.GxPT.setColumnsNew();


	dojo.connect(usaga_account_users_ItemFileWriteStoreTriggerAlarm, 'onSet', function(item, attribute, oldValue, newValue){
AjaxSaveChangesPhonesTriggerGridx(item);
});




function AjaxSaveChangesPhonesTriggerGridx(item){

if(item.idaccount > 0 && item.idcontact > 0 && PTElements.dijit.GxPT){

request.post('fun_account_phones_trigger_alarm_table_from_hashmap.usaga', {
   handleAs: "xml",
data: {idaccount: item.idaccount, idphone: item.idphone, enable: item.enable, fromsms: item.fromsms, fromcall: item.fromcall, note: item.note}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

alert(xmld.getStringFromB64(0, 'outpgmsg'));

var idcontactuser = xmld.getNumber(0, 'outreturn');
LoadAccountUsersGridx();
if(idcontactuser == formdata.idcontact){
LoadFormAccountUser(idcontactuser);
}else{
	dojo.byId("usaga.account.users.form").reset();
}

}, function(error){
alert(error);
});

}else{
LoadAccountPhonesTriggerGridx(0);
}

}


function LoadAccountPhonesTriggerGridx(inidcontact){

			PTElements.GxPTClear();
var inidaccount = Account_Main_Data.idaccount();

if(inidaccount > 0 && inidcontact > 0){

var store = new dojox.data.XmlStore({url: "getaccountphonestriggerview.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: inidaccount, idcontact: inidcontact}, onComplete: function(itemsrow, r){

var dataxml = new RXml.getFromXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i,
idaccount: dataxml.getNumber(i, "idaccount"), 
idphone: dataxml.getNumber(i, "idphone"), 
idcontact: dataxml.getNumber(i, "idcontact"), 
enable: dataxml.getBool(i, "trigger_alarm"),
idprovider: dataxml.getNumber(i, "idprovider"),
type: dataxml.getNumber(i, "type"),
phone: dataxml.getStringFromB64(i, "phone"),
phone: dataxml.getStringFromB64(i, "phone"),
fromsms: dataxml.getBool(i, "fromsms"),    
fromcall: dataxml.getBool(i, "fromcall"),    
note: dataxml.getStringFromB64(i, "note"),
};
i++;
}

	// Set new data on data store (the store has jsId set, so there's
	usaga_account_users_ItemFileWriteStoreTriggerAlarm.clearOnClose = true;
	usaga_account_users_ItemFileWriteStoreTriggerAlarm.data = myData;
	usaga_account_users_ItemFileWriteStoreTriggerAlarm.close();

		// Tell our grid to reset itself
		PTElements.dijit.GxPT.store = null;
		PTElements.dijit.GxPT.setStore(usaga_account_users_ItemFileWriteStoreTriggerAlarm);

},
onError: function(e){
alert(e);
}
});

}

}



/////////////////////////
/////// CONTACTOS ///////
// Account Contacts

dojo.connect(dijit.byId('usaga.account.contacts.new'), 'onClick', function(){
//alert('Nuevo');
AC.ResetOnSelectContact();
AC.dijit.Select.readOnly = false;
});
dojo.connect(dijit.byId('usaga.account.contacts.save'), 'onClick', function(){
//alert('save');
AC.SaveForm(false);
});
dojo.connect(dijit.byId('usaga.account.contacts.del'), 'onClick', function(){
//alert('del');
AC.SaveForm(true);
});
dojo.connect(dijit.byId('usaga.account.contacts.contactdata'), 'onClick', function(){
alert('contactdata en construccion');
});

// ACCOUNT CONTACTS
var AC = {
GxCStore: usaga_account_contactsStore,
GxNPStore: usaga_account_contact_notifphonesStore,
GxNETStore: usaga_account_contact_notifeventtypeStore,
GxNPSelectedRows: [],
GxNPSelectedContacts: [],
dijit: {
// Gridx Contacts
GxC: dijit.byId('usaga.account.contacts.gridx'),
Select: dijit.byId('usaga.account.contacts.id'),
Enable: dijit.byId('usaga.account.contacts.enable'),
Priority: dijit.byId('usaga.account.contacts.priority'),
Appointment: dijit.byId('usaga.account.contacts.appointment'),
Note: dijit.byId('usaga.account.contacts.note'),
TS: dijit.byId('usaga.account.contacts.ts'),
GxNP: dijit.byId('usaga.account.contacts.notifphonesgridx'),
GxNET: dijit.byId('usaga.account.contacts.notifeventtypegridx'),
},
dojo:{
Form: dojo.byId('usaga.account.contacts.form')
},
ResetAll: function(){
this.GxCClear();
this.ResetOnSelectContact();
},
GxCClear: function(){
	this.GxCStore.clearOnClose = true;
	this.GxCStore.data = {identifier: "unique_id", items: []};
	this.GxCStore.close();
this.dijit.GxC.store = null;
this.dijit.GxC.setStore(this.GxCStore);

},
GxNPClear: function(){
	this.GxNPStore.clearOnClose = true;
	this.GxNPStore.data = {identifier: "unique_id", items: []};
	this.GxNPStore.close();
this.dijit.GxNP.store = null;
this.dijit.GxNP.setStore(this.GxNPStore);
},
GxNETClear: function(){

	this.GxNETStore.clearOnClose = true;
	this.GxNETStore.data = {identifier: "unique_id", items: []};
	this.GxNETStore.close();

		this.dijit.GxNET.store = null;
		this.dijit.GxNET.setStore(this.GxNETStore);

},
ResetOnSelectContact: function(){
this.dijit.Select.readOnly = true;
this.dojo.Form.reset();
this.GxNPClear();
this.GxNETClear();
},
LoadContactsGrid: function(){
this.ResetOnSelectContact();
var _idaccount = Account_Main_Data.idaccount(); 
if(_idaccount > 0){

var store = new dojox.data.XmlStore({url: "getaccountcontactsgrid.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: _idaccount}, onComplete: function(itemsrow, r){

var dataxml = new RXml.getFromXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i,
idcontact: dataxml.getNumber(i, "idcontact"), 
enable_as_contact: dataxml.getBool(i, "enable_as_contact"),
priority: dataxml.getNumber(i, "prioritycontact"),    
name: dataxml.getStringFromB64(i, "lastname")+' '+dataxml.getStringFromB64(i, "firstname"),
appointment: dataxml.getStringFromB64(i, "appointment"),
};

i++;
}

	AC.GxCStore.clearOnClose = true;
	AC.GxCStore.data = myData;
	AC.GxCStore.close();

		AC.dijit.GxC.store = null;
		AC.dijit.GxC.setStore(AC.GxCStore);
},
onError: function(e){
alert(e);
}
});

}else{
AC.GxCClear();
}


return this;
},
SaveForm: function(deleteReg){

var Objeto = this;
if(AC.dijit.Select.get('value') > 0 && Account_Main_Data.idaccount() > 0){
idcontact = AC.dijit.Select.get('value');
if(deleteReg){
idcontact = idcontact*-1;
}

  var xhrArgs = {
    url: "getaccountcontactstable.usaga",
 content: {idaccount:Account_Main_Data.idaccount(), idcontact: idcontact, enable_as_contact: AC.dijit.Enable.get('checked'), priority: AC.dijit.Priority.get('value'), appointment: AC.dijit.Appointment.get('value'), note: AC.dijit.Note.get('value'), ts: AC.dijit.TS.get('value')},
    handleAs: "xml",
    load: function(datass){

//var xmldata = datass.getElementsByTagName("row");
var xmld = new RXml.getFromXhr(datass, 'row');

if(xmld.length > 0){
var outreturn = xmld.getInt(0, 'outreturn');
if(outreturn == Objeto.dijit.Select.get('value')){

alert(xmld.getStringFromB64(0, 'outpgmsg'));
Objeto.LoadFormContact(outreturn);

}else{
Objeto.ResetOnSelectContact();
}

}else{
Objeto.ResetOnSelectContact();
}
Objeto.LoadContactsGrid();
    },

    error: function(error)
{
Objeto.LoadContactsGrid();
alert(error);
    }
  }

  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);

}
return Objeto;
},
LoadPhonesNotifEvenTypes: function(idphone){

if(idphone > 0){

var store = new dojox.data.XmlStore({url: "getaccountphonesnotifeventtypegrid.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount:Account_Main_Data.idaccount(), idphone: idphone}, onComplete: function(itemsrow, r){

var dataxml = new RXml.getFromXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};
myData.identifier = "unique_id";

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i,
idnotifaccount: dataxml.getNumber(i, "idnotifaccount"),
ideventtype: dataxml.getNumber(i, "ideventtype"),
enable: dataxml.getBool(i, "enable"),
label: dataxml.getStringFromB64(i, "label"),
ts: dataxml.getValue(i, "ts"),
};
i++;
}

AC.GxNETStore.clearOnClose = true;
	AC.GxNETStore.data = myData;
	AC.GxNETStore.close();

		AC.dijit.GxNET.store = null;
		AC.dijit.GxNET.setStore(AC.GxNETStore);

},
onError: function(e){
alert(e);
}
});

}else{
AC.GxCClear();
}
return this;
},
LoadPhones: function(idcontact){

this.GxNPSelectedRows = [];
this.GxNPSelectedContacts = [];

if(idcontact > 0){

var store = new dojox.data.XmlStore({url: "getaccountphonesnotifgrid.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount:Account_Main_Data.idaccount(), idcontact: idcontact}, onComplete: function(itemsrow, r){

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};


var dataxml = new RXml.getFromXmlStore(store, itemsrow);
var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i+1,
idcontact: idcontact,
idnotifaccount: dataxml.getNumber(i, "idnotifaccount"),
idphone: dataxml.getNumber(i, "idphone"),
idprovider: dataxml.getNumber(i, "idprovider"),
phone: dataxml.getStringFromB64(i, "phone"),
idaccount: dataxml.getNumber(i, "idaccount"),
priority: dataxml.getNumber(i, "priority"),    
call: dataxml.getBool(i, "call"),
sms: dataxml.getBool(i, "sms"),
smstext: dataxml.getStringFromB64(i, "smstext"),
note: dataxml.getStringFromB64(i, "note")
};

i++;
}

AC.GxNPStore.clearOnClose = true;
	AC.GxNPStore.data = myData;
	AC.GxNPStore.close();

		AC.dijit.GxNP.store = null;
		AC.dijit.GxNP.setStore(AC.GxNPStore);

},
onError: function(e){
AC.GxNPClear();
alert(e);
}
});

}else{
AC.GxNPClear();
}
return this;
},

// Aplica los cambios a los telefonos de los contactos selecionados seleccionados
NotifyEditToContactsSelected: function(){
if(AC.GxNPSelectedContacts.length>0){
var Objeto = this;
  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "notifyeditselectedcontacts.usaga",
    content: {idaccount: Account_Main_Data.idaccount(), idcontacts: AC.GxNPSelectedContacts.toString(), call: dijit.byId('usaga.contactnotif.call.all').get('checked'), sms: dijit.byId('usaga.contactnotif.sms.all').get('checked'), msg: dijit.byId('usaga.contactnotif.msg.all').get('value')},
    handleAs: "xml",
    load: function(dataX){

var xmld = new RXml.getFromXhr(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringFromB64(0, 'outpgmsg'));

}
AC.LoadContactsGrid();
    },
    error: function(errorx){
alert(errorx);
//Objeto.LoadPhones(0);
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}
},

// Aplica los cambios a los registros seleccionados
NotifyEditSelected: function(){
if(AC.GxNPSelectedRows.length>0){
var Objeto = this;
  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "notifyeditselectedphones.usaga",
    content: {idaccount: Account_Main_Data.idaccount(), idphones: AC.GxNPSelectedRows.toString(), call: dijit.byId('usaga.notiftelf.call.all').get('checked'), sms: dijit.byId('usaga.notiftelf.sms.all').get('checked'), msg: dijit.byId('usaga.notiftelf.msg.all').get('value')},
    handleAs: "xml",
    load: function(dataX){

var xmld = new RXml.getFromXhr(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringFromB64(0, 'outpgmsg'));

}

Objeto.LoadPhones(AC.dijit.Select.get('value'));

    },
    error: function(errorx){
alert(errorx);
Objeto.LoadPhones(0);
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}
},


LoadFormContact: function(iniidcontact){

var Objeto = this;
if(Account_Main_Data.idaccount() > 0){

var store = new dojox.data.XmlStore({url: "getaccountcontact.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: Account_Main_Data.idaccount(), idcontact: iniidcontact}, onComplete: function(itemsrow, r){

var dataxml = new RXml.getFromXmlStore(store, itemsrow);

if(itemsrow.length>0){
Objeto.dijit.Select.set('value', dataxml.getNumber(0, "idcontact")); 
Objeto.dijit.Enable.set("checked", dataxml.getBool(0, "enable_as_contact"));
Objeto.dijit.Priority.set("value", dataxml.getNumber(0, "prioritycontact"));
Objeto.dijit.Appointment.set('value', dataxml.getStringFromB64(0, "appointment"));
Objeto.dijit.Note.set('value', dataxml.getStringFromB64(0, "note"));
Objeto.dijit.TS.set('value', dataxml.getString(0, "ts"));
}else{
Objeto.ResetOnSelectContact();
iniidcontact = 0;
}

Objeto.LoadPhones(iniidcontact);

},
onError: function(e){
alert(e);
}
});

}else{
Objeto.ResetOnSelectContact();
}

return Objeto;
} 


}


dojo.connect(dojo.byId('usaga.contactnotif.applytoall'), 'onclick', function(){

            dijit.popup.open({
                popup: dijit.byId('usaga.contactnotif.dialogMessageAll'),
                around: dojo.byId('usaga.contactnotif.applytoall')
            });

});

dojo.connect(dojo.byId('usaga.contactnotif.dialogMessageAll_ok'), 'onclick', function(){
   dijit.popup.close(dijit.byId('usaga.contactnotif.dialogMessageAll'));
AC.NotifyEditToContactsSelected();
});

dojo.connect(dojo.byId('usaga.contactnotif.dialogMessageAll_cancel'), 'onclick', function(){
   dijit.popup.close(dijit.byId('usaga.contactnotif.dialogMessageAll'));
});

//////////////////////////////////////////////////////////////////////////////
dojo.connect(dojo.byId('usaga.telfnotif.applytoall'), 'onclick', function(){

            dijit.popup.open({
                popup: dijit.byId('usaga.telfnotif.dialogMessageAll'),
                around: dojo.byId('usaga.telfnotif.applytoall')
            });

});



dojo.connect(dojo.byId('usaga.telfnotif.dialogMessageAll_ok'), 'onclick', function(){
   dijit.popup.close(dijit.byId('usaga.telfnotif.dialogMessageAll'));
AC.NotifyEditSelected();
});

dojo.connect(dojo.byId('usaga.telfnotif.dialogMessageAll_cancel'), 'onclick', function(){
   dijit.popup.close(dijit.byId('usaga.telfnotif.dialogMessageAll'));
});


	if (AC.dijit.GxC) {
// Captura el evento cuando se hace click en una fila
dojo.connect(AC.dijit.GxC, 'onRowClick', function(event){
AC.ResetOnSelectContact();
var id = this.cell(event.rowId, 1, true).data();
AC.LoadFormContact(id);
});
		AC.dijit.GxC.setColumns([
			{field:"idcontact", name: "idcontact", width: '0%'},
			{field:"enable_as_contact", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true},
			{field:"priority", name: "priority", width: '20px'},
			{field:"name", name: "nombre", width: '150px'},
			{field:"appointment", name: "Designacion"}
		]);
AC.dijit.GxC.startup();
}

	if (AC.dijit.GxNP) {

AC.dijit.GxNP.setColumns([
			{field:"unique_id", name: "#", width: '20px'},
			{field:"idnotifaccount", name: "id", width: '0px'},
			{field:"idphone", name: "idp", width: '0px'},
			{field:"phone", name: "Teléfono", width: '100px'},
			{field:"idprovider", name: "idprovider"},
	                {field:"priority", name: "Prioridad", width: '30px', editable: true},
			{field:"call", name: "call", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true},
			{field:"sms", name: "sms", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true},
			{field:"smstext", name: "smstext", width: '150px', editable: true},
	                {field:"note", name: "Nota", editable: true}
		]);
AC.dijit.GxNP.startup();

// Captura el evento cuando se hace click en una fila
dojo.connect(AC.dijit.GxNP, 'onRowClick', function(event){
//var id = this.cell(event.rowId, 2, true).data();
//alert(id);
AC.LoadPhonesNotifEvenTypes(this.cell(event.rowId, 3, true).data());
});

		
}


dojo.connect(AC.dijit.GxNP.select.row, 'onSelectionChange', function(selected){
AC.GxNPSelectedRows = [];
//alert(selected);
numsel = selected.length;
i = 0;
while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
AC.GxNPStore.fetch({query: {unique_id: selected[i]}, onItem: function(item){
//console.log('id phone ', AC.GxNPStore.getValue(item, 'idphone')  );
AC.GxNPSelectedRows[i] = AC.GxNPStore.getValue(item, 'idphone');
} 
});
i++;
}
});

dojo.connect(AC.dijit.GxC.select.row, 'onSelectionChange', function(selected){
AC.GxNPSelectedContacts = [];
//alert(selected);
numsel = selected.length;
i = 0;
while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
AC.GxCStore.fetch({query: {unique_id: selected[i]}, onItem: function(item){
//console.log('id phone ', AC.GxNPStore.getValue(item, 'idphone')  );
alert(i);
AC.GxNPSelectedContacts[i] = AC.GxCStore.getValue(item, 'idcontact');
} 
});
i++;
}
});




	if (AC.dijit.GxNET) {

		AC.dijit.GxNET.setColumns([
			{field:"enable", name: "*", width: '20px'},
			{field:"ideventtype", name: "IdEventType", width: '0px'},
			{field:"label", name: "Evento"},
		]);
AC.dijit.GxNET.startup();
}


///////////////////////////////////////////////////
//// TELEFONOS PARA NOTIFICACIONES DE EVENTOS /////
var ANP = {
Save: function(itemStore){

var Objeto = this;

if(Account_Main_Data.idaccount() > 0 && itemStore.idcontact > 0){

  var xhrArgs = {
    url: "getaccountnotificationstable.usaga",
 content: {idnotifaccount: 0, idaccount:Account_Main_Data.idaccount(), idphone: itemStore.idphone, priority: itemStore.priority, sms: itemStore.sms, call: itemStore.call, smstext: itemStore.smstext, note: itemStore.note },
    handleAs: "xml",
    load: function(datass){

var xmld = new RXml.getFromXhr(datass, 'row');

if(xmld.length > 0){

if(xmld.getInt(0, 'outreturn') > 0){
//alert('pasa');
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}else{
//Objeto.ResetOnSelectContact();
}

}
//Objeto.LoadContactsGrid();
AC.LoadPhones(itemStore.idcontact);
    },

    error: function(error)
{
AC.LoadPhones(itemStore.idcontact);
alert(error);
    }
  }
	
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);

//LoadAccountPhonesTriggerGridx(iniidcontact);

}else{
	AC.GxCClear();
}
return Objeto;
}

}



///////////////////////////////////////////////////
// MUESTRA LOS EVENTOS DE LA CUENTA EN UNA TABLA //

jsDateTextBox.addGetDateFunction(dijit.byId('usaga.account.event.fstart'));
jsDateTextBox.addGetDateFunction(dijit.byId('usaga.account.event.fend'));

dojo.connect(dojo.byId('usaga.account.event.send'), 'onclick', function(){
LoadGridEventsAccount();
});


	var GridEventsAccount = dijit.byId("usaga.account.event.grid");
	if (GridEventsAccount) {


		// Optionally change column structure on the grid
		GridEventsAccount.setColumns([

			{field:"id", name: "id", width: '20px'},
			{field:"dateload", name: "dateload", width: '80px'},
			{field:"idaccount", name: "idaccount", width: '75px'},
			{field:"partition", name: "partition", width: '60px'},
			{field:"enable", name: "enable", width: '60px'},
			{field:"account", name: "account", width: '100px'},
			{field:"name", name: "name", width: '100px'},
			{field:"code", name: "code"},
			{field:"zu", name: "zu"},
			{field:"priority", name: "priority"},
			{field:"description", name: "description"},
			{field:"ideventtype", name: "ideventtype"},
			{field:"eventtype", name: "eventtype"}
		]);
GridEventsAccount.startup();
}

function LoadGridEventsAccount(){
if(Account_Main_Data.idaccount() > 0){

var store = new dojox.data.XmlStore({url: "geteventsaccount.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: Account_Main_Data.idaccount(), fstar: dijit.byId('usaga.account.event.fstart')._getDate(), fend: dijit.byId('usaga.account.event.fend')._getDate()}, onComplete: function(itemsrow, r){

var dataxml = new RXml.getFromXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i,
id: dataxml.getNumber(i, "idevent"), 
dateload: dataxml.getDate(i, "dateload"),
idaccount: dataxml.getNumber(i, "idaccount"),
partition: dataxml.getNumber(i, "partition"),
enable: dataxml.getBool(i, "enable"),
account: dataxml.getStringFromB64(i, "account"),
name: dataxml.getStringFromB64(i, "name"),
code: dataxml.getStringFromB64(i, "code"),
zu: dataxml.getNumber(i, "zu"),
priority: dataxml.getNumber(i, "priority"),
description: dataxml.getStringFromB64(i, "description"),
ideventtype: dataxml.getNumber(i, "ideventtype"),
eventtype: dataxml.getStringFromB64(i, "eventtype")
};
i++;
}

usaga_account_event_store.clearOnClose = true;
	usaga_account_event_store.data = myData;
	usaga_account_event_store.close();

		GridEventsAccount.store = null;
		GridEventsAccount.setStore(usaga_account_event_store);
//GridCalls.startup();
//alert('ok');
},
onError: function(e){
alert(e);
}
});
}
}


var Account_Main_Data = dijit.byId('account_main');

	Account_Main_Data.on('onloadaccount', function(d){

if(d.idaccount > 0){
GlobalObject.DisabledContentPanes(false);
}else{
GlobalObject.DisabledContentPanes(true);
}

// Carga la lista de contactos (de usms) para ponerlos el los FilteringSelect de contactos y usuarios de usaga
GlobalObject.LoadListIdContactsNames();

// Carga los datos de direcciones
AA.AddressW.idaddress = d.idaddress;
AA.Load();

// Carga los datos de contactos
AC.LoadContactsGrid();



});	


	dojo.connect(usaga_account_contact_notifphonesStore, 'onSet', function(item, attribute, oldValue, newValue){
//alert('Edita '+ item.idcontact);
ANP.Save(item);
});	

////////////////// FUNCIONES CARGAN AL INICIO //////////////////////////
//GlobalObject.DisabledContentPanes(true);
GlobalObject.DisabledContentPanes(true);

setInterval(function(){
if(Account_Main_Data.idaccount()>0){
GlobalObject.DisabledContentPanes(false);
}else{
GlobalObject.DisabledContentPanes(true);
}
}, 5000);

//dijit.byId('account.location.geox').constraints = {pattern: '###.################'};
//dijit.byId('account.location.geoy').constraints = {pattern: '###.################'};

//GlobalObject.LoadFilteringSelectAccount().LoadListIdContactName();
//GlobalObject.LoadListIdContactName();
//ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
AC.dijit.Select.set('invalidMessage', 'Seleccione de la lista');
//dijit.byId('usaga_account_address').idps.set('value', 'Es la direccion');


     });
});
