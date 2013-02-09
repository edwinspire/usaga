	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
"dojox/xml/DomParser",
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
"dojox/grid/cells/dijit",
"dojox/data/XmlStore",
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/TooltipDialog",
"dijit/popup"
], function(ready, on, DomParser, Memory, FilteringSelect, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, CheckBox, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
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
LoadItemsSelectAccount: function(){
//var AccountSelectBox = dijit.byId('account.basic.accountselect');
  
var Fload = new jspire.dijit.FilteringSelect.FilteringSelectLoadFromXml(dijit.byId('account.basic.accountselect'), true, 'fun_view_idaccounts_names_xml.usaga', 'row', 'idaccount', 'name');
Fload.Load();
/*
var xhrArgs = {
    url: "getvaluesselectbox.usaga",
    handleAs: "text",
    load: function(dataX){
  var datar = dojox.xml.DomParser.parse(dataX);
var xmldata = datar.byName('row');
if(xmldata.length > 0){
var Items = [{}];
var len = xmldata.length;
var i = 0;
var idaccount = 0;

while(i<len){
idaccount = xmldata[i].getAttribute("idaccount");
Items[i] =    {name: jsspire.Base64.decode(xmldata[i].getAttribute("name")), id: idaccount};
i++;
}

    var stateStore = new Memory({data: Items});
AccountSelectBox.store = stateStore;
AccountSelectBox.startup();
}

    },
    error: function(errorx){
alert(errorx);
    }
  }
  var deferred = dojo.xhrGet(xhrArgs);
*/
return this;
},

LoadListIdContactName: function(){
var Objeto = this;
var store = new dojox.data.XmlStore({url: "usms_getcontactslistidcontactname_xml", sendQuery: true, rootItem: 'row'});

var request = store.fetch({onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};
myData.identifier = "unique_id";


if(numrows > 0){
var Items = [];

//var len = xmldata.length;
var i = 0;
while(i<numrows){
Items[i] =    {name: dataxml.getStringB64(i, 'name'), id: dataxml.getNumber(i, "idcontact")};
i++;
}
on.emit(Objeto.MasterDiv, "onListIdContactNameLoaded", {data: new Memory({data: Items})});
}

},
onError: function(e){
alert(e);
}
});
return Objeto;
}
}





// ACCOUNT BASIC ELEMENTS
var ABE = {
dijit:{
DialogDelete: dijit.byId('idDialogDeleteAccount'),
Partition: dijit.byId('account.basic.partition'), 
Enable: dijit.byId('account.basic.enable'),
Num: dijit.byId('account.basic.accountnum'),
Select: dijit.byId('account.basic.accountselect'),
Type: dijit.byId('account.basic.accountType'),
Note: dijit.byId('account.basic.note')
},
dojo: {
FormBasic: dojo.byId("os.account.form.basic"),
//FormLocation: dojo.byId("account.location.form"),
DeleteButton: dojo.byId('account.basic.deleteaccount')
},
ResetForms: function(){
this.dojo.FormBasic.reset();
//this.dojo.FormLocation.reset();
}
}

        dojo.connect(ABE.dojo.DeleteButton, 'onclick', function(){

if(GlobalObject.IdAccount > 0){
            dijit.popup.open({
                popup: ABE.dijit.DialogDelete,
                around: ABE.dojo.DeleteButton
            });
}
        });

        dojo.connect(dojo.byId('Accountdelcancel'), 'onclick', function(){
dijit.popup.close(ABE.dijit.DialogDelete);
});

        dojo.connect(dojo.byId('Accountdelok'), 'onclick', function(){
dijit.popup.close(ABE.dijit.DialogDelete);
ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
DeleteAccount();
});

dojo.connect(ABE.dijit.Select, 'onChange', function(e){
AccountSelected();
});

dojo.connect(dijit.byId('account.basic.newaccount'), 'onClick', function(e){
ABE.dijit.Select.set('invalidMessage', 'El nombre de Abonado es permitido');
GlobalObject.IdAccount = 0;
ABE.ResetForms();
AC.ResetAll();
});

dojo.connect(dijit.byId('account.basic.saveaccount'), 'onClick', function(e){
ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
SaveAccount();
});

/*
dojo.connect(dijit.byId('account.basic.deleteaccount'), 'onClick', function(e){
ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
DeleteAccount();
});
*/
dojo.connect(dijit.byId('account.contentpane.users'), 'onShow', function(e){
ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
LoadAccountUsersGridx();
});



function DeleteAccount(){
if(GlobalObject.IdAccount>0){
GlobalObject.IdAccount = GlobalObject.IdAccount*-1; //.set('value', id.get('value')*-1);
SaveAccount();
}else{
ABE.ResetForms();
}
}

function SaveAccount(){
var formulario = dojo.byId("os.account.form.basic");
var datos = {};
//datos.idaccount = dijit.byId('account.basic.id').get('value'); 
datos.idaccount = GlobalObject.IdAccount; 
//datos.idgroup = ThisObject.get('idgroup');
datos.partition = dijit.byId('account.basic.partition').get('value');
datos.enable = dijit.byId('account.basic.enable').get('checked'); 
datos.account = dijit.byId('account.basic.accountnum').get('value'); 
datos.name = dijit.byId('account.basic.accountselect').get('displayedValue'); 
datos.type = dijit.byId('account.basic.accountType').get('value');
datos.note = dijit.byId('account.basic.note').get('value');

  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "saveaccount.usaga",
    content: datos,
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspireTableXmlDoc(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringB64(0, 'outpgmsg'));

GlobalObject.LoadItemsSelectAccount();
var id = xmld.getNumber(0, "outreturn");

if(id>=0){
// Seteamos primero el id para que al ejecutar SaveAccountLocation no haya problema cuando se crea una cuenta nueva
GlobalObject.IdAccount = id;
AjaxLoadAccount();
SaveAccountLocation();
}

}

    },
    error: function(errorx){
alert(errorx);
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);

}


function AjaxLoadAccount(){
var formulario = dojo.byId("os.account.form.basic");
if(GlobalObject.IdAccount>0){
GlobalObject.DisabledContentPanes(false);

var store = new dojox.data.XmlStore({url: "getaccount.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: { idaccount: GlobalObject.IdAccount}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

if(numrows > 0){

GlobalObject.IdAccount = dataxml.getNumber(0, "idaccount")
ABE.dijit.Partition.set('value', dataxml.getNumber(0, "partition"));
ABE.dijit.Enable.set('checked', dataxml.getBool(0, "enable")); 
ABE.dijit.Num.set('value', dataxml.getStringB64(0, "account")); 
ABE.dijit.Select.set('value', dataxml.getNumber(0, "idaccount")); 
ABE.dijit.Type.setValue(dataxml.getString(0, "type")); 
ABE.dijit.Note.set('value', dataxml.getStringB64(0, "note"));
AA.AddressW.set('idaddress', dataxml.getNumber(0, "idaddress"));  
}else{
formulario.reset();
}

AA.Load();
LoadAccountPhonesTriggerGridx(0);

},
onError: function(e){
alert(e);
}
});

}else{
formulario.reset();
}

}


function AccountSelected(){
// Cargamos la cuenta solo si el registro existe
//var selector = dijit.byId('account.basic.accountselect');
if(ABE.dijit.Select.state != 'Error'){
GlobalObject.IdAccount = ABE.dijit.Select.get('value');
AjaxLoadAccount();
AC.LoadContactsGrid();
}
}



///////////////////////////
///// ACCOUNT ADDRESS /////
var AA = {
AddressW : dijit.byId('usaga_account_address'),
Delete: function(){
this.AddressW.idaddress = this.AddressW.idaddress*-1;
if(this.AddressW.idaddress > 0){
this.Save();
}
},
Load: function(){

var ObjectoW = this.AddressW;

if(ObjectoW.idaddress > 0){

var store = new dojox.data.XmlStore({url: 'get_address_byid.usms', sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaddress: ObjectoW.idaddress}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

if(numrows > 0){
i = 0;
ObjectoW.set('idaddress', dataxml.getNumber(i, 'idaddress'));
ObjectoW.set('geox', dataxml.getFloat(i, 'geox'));
ObjectoW.set('geoy', dataxml.getFloat(i, 'geoy'));
ObjectoW.set('mainstreet', dataxml.getStringB64(i, 'main_street'));
ObjectoW.set('secundarystreet', dataxml.getStringB64(i, 'secundary_street'));
ObjectoW.set('other', dataxml.getStringB64(i, 'other'));
ObjectoW.set('note', dataxml.getStringB64(i, 'note'));
ObjectoW.set('ts', dataxml.getString(i, 'ts'));
ObjectoW.set('idlocation', dataxml.getString(i, 'idlocation'));
}else{
ObjectoW.reset();
}

},
onError: function(e){
ObjectoW.reset();
alert(e);
}
});

}else{
ObjectoW.reset();
}

},
Save: function(){
// Objeto Widget Address
var OWA = this.AddressW;
var Este = this;

  var xhrArgs = {
    url: "fun_address_edit.usaga",
 content: {idaddress: OWA.get('idaddress'), idlocation: OWA.get('idlocation'), geox: OWA.get('geox'), geoy: OWA.get('geoy'), main_street: OWA.get('mainstreet'), secundary_street: OWA.get('secundarystreet'), other: OWA.get('other'), note: OWA.get('note'), ts: OWA.get('ts'), idaccount: GlobalObject.IdAccount},
    handleAs: "xml",
    load: function(datass){

var xmld = new jspireTableXmlDoc(datass, 'row');

if(xmld.length > 0){
OWA.idaddress = xmld.getInt(0, 'outreturn');
alert(xmld.getStringB64(0, 'outpgmsg'));
}else{
OWA.reset();
}
ABE.idaddress = OWA.idaddress;
Este.Load();
    },

    error: function(error)
{
OWA.reset();
alert(error);
    }
  }

  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}
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


on(GlobalObject.MasterDiv, 'onListIdContactNameLoaded', function(d){

var userSelectBox = dijit.byId('usaga.account.users.form.idcontact');
userSelectBox.store = null;
userSelectBox.store = d.data;
userSelectBox.startup();
userSelectBox.readOnly = true;
});

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
			{field:"enable_as_user", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jspireEditorArgsToGridxCellBooleanDisabled, alwaysEditing: true, disabled: true},
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

var formdata = { idaccount: GlobalObject.IdAccount};
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

if(GlobalObject.IdAccount > 0){

  var xhrArgs = {
    url: "saveaccountuser.usaga",
 content: formdata,
    handleAs: "text",
    load: function(datass){

  var datar = dojox.xml.DomParser.parse(datass);

var xmldata = datar.byName('SQLFunReturn');
var idcontactuser = xmldata[0].getAttribute("return");

LoadAccountUsersGridx();
alert(jsspire. Base64.decode(xmldata[0].getAttribute("msg")));
if(idcontactuser == formdata.idcontact){
LoadFormAccountUser(idcontactuser);
}else{
//alert(jsspire. Base64.decode(xmldata[0].getAttribute("msg")));
			dojo.byId("usaga.account.users.form").reset();
}

 
    },
    error: function(error){
//      targetNode.innerHTML = "An unexpected error occurred: " + error;
alert(error);
			dojo.byId("usaga.account.users.form").reset();

    }
  }

  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}else{
			dojo.byId("usaga.account.users.form").reset();
}
dijit.byId("usaga.account.users.form.idcontact").readOnly = true;
}

function LoadFormAccountUser(iniidcontact){

var inidaccount = GlobalObject.IdAccount;

if(inidaccount > 0){

  var xhrArgs = {
    url: "getaccountuser.usaga",
 content: { idaccount: inidaccount, idcontact: iniidcontact},
    handleAs: "text",
    load: function(datass){

  var datar = dojox.xml.DomParser.parse(datass);
var xmldata = datar.byName('row');

dijit.byId('usaga.account.users.form.idcontact').set('value', String(xmldata[0].getAttribute("idcontact"))); 
dijit.byId('usaga.account.users.form.enable').set("checked", StringToBool(xmldata[0].getAttribute("enable")));
dijit.byId('usaga.account.users.form.numuser').set("value", xmldata[0].getAttribute("numuser"));
dijit.byId('usaga.account.users.form.appointment').set('value', jsspire.Base64.decode(xmldata[0].getAttribute("appointment")));
dijit.byId('usaga.account.users.form.keyword').set('value', jsspire.Base64.decode(xmldata[0].getAttribute("keyword")));
dijit.byId('usaga.account.users.form.pwd').set('value', jsspire.Base64.decode(xmldata[0].getAttribute("pwd")));
dijit.byId('usaga.account.users.form.note').set('value', jsspire.Base64.decode(xmldata[0].getAttribute("note")));

    },
    error: function(error){
//      targetNode.innerHTML = "An unexpected error occurred: " + error;
alert(error);

    }
  }

  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);

LoadAccountPhonesTriggerGridx(iniidcontact);

}else{
			dojo.byId("usaga.account.users.form").reset();
LoadAccountPhonesTriggerGridx(0);
}
}

function LoadAccountUsersGridx(){

dojo.byId("usaga.account.users.form").reset();

var inidaccount = GlobalObject.IdAccount;

if(inidaccount > 0){

  var xhrArgs = {
    url: "getaccountusersgrid.usaga",
 content: {idaccount: inidaccount},
    handleAs: "text",
    load: function(datass){

  var datar = dojox.xml.DomParser.parse(datass);
	// Get reference to our grid object. I set the id to "GridX" using
	// the Maqetta properties palette.
	var myGridX = dijit.byId("usaga.account.users.gridx");
	if (myGridX) {

var xmldata = datar.byName('row');

var myData = {identifier: "unique_id", items: []};
myData.identifier = "unique_id";

var i = 0;
var rowscount = xmldata.length;
while(i<rowscount){

myData.items[i] = {
unique_id:i,
//s: false, 
idcontact: xmldata[i].getAttribute("idcontact"), 
enable_as_user: xmldata[i].getAttribute("enable_as_user"),
numuser: xmldata[i].getAttribute("numuser"),
//priority: xmldata[i].getAttribute("prioritycontact"),    
name: jsspire.Base64.decode(xmldata[i].getAttribute("lastname"))+' '+jsspire.Base64.decode(xmldata[i].getAttribute("firstname")),
appointment: jsspire.Base64.decode(xmldata[i].getAttribute("appointment")),
};

i++;
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
	}

 
    },
    error: function(error){
//      targetNode.innerHTML = "An unexpected error occurred: " + error;
alert(error);

    }
  }

  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
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

function primaryFormatter(inDatum) {
        if (inDatum == "true")
        {
          return true;
        }
        else
        {
          return false; 
        }
};



// Est parte de codigo carga la lista de proveedores y los carga en un select 
fieldStore = new Memory();
fieldStorex = new jspireMemoryIdValueFromXmlStore(true, 'usms_provider_listidname_xml', 'row', 'idprovider', 'name').Load();

// Se usa este interval para asegurarse de que los datos estan listos para cargarlos al store
interstore = setInterval(function(){
if(fieldStorex.isLoaded){
fieldStore = fieldStorex.Memory();
clearInterval(interstore);
}
}, 2000);


	function getDate(d){
		res = Boolean(d);
alert('from '+res);
		return res;
	}



	if (PTElements.dijit.GxPT) {

		// Optionally change column structure on the grid
		PTElements.dijit.GxPT.setColumns([
			{field:"idcontact", name: "idcontact", width: '0px'},
			{field:"idphone", name: "idphone", width: '0px'},
			{field:"enable", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jspireEditorArgsToGridxCellBoolean, alwaysEditing: true},
			{field:"type", name: "type", width: '20px'},
			{field:"idprovider", name: "provider", editable: true, alwaysEditing: true,
					editor: 'dijit.form.Select',
					editorArgs: {
						props: 'store: fieldStore, labelAttr: "value", disabled: "true"'}},
			{field:"phone", name: "Teléfono", width: '150px'},
//			{field:"address", name: "Dirección", width: '150px'},
			{field:"fromsms", name: "sms", width: '20px', editable: true, editor: "dijit.form.CheckBox", 
			editorArgs: jspireEditorArgsToGridxCellBoolean, alwaysEditing: true},

			{field:"fromcall", name: "call", width: '20px', editable: true, editor: "dijit.form.CheckBox", 
		editorArgs: jspireEditorArgsToGridxCellBoolean, alwaysEditing: true,
			},
			{field:"note", name: "Nota", width: '100px', editable: true}
		]);
PTElements.dijit.GxPT.startup();
}

	dojo.connect(usaga_account_users_ItemFileWriteStoreTriggerAlarm, 'onSet', function(item, attribute, oldValue, newValue){
AjaxSaveChangesPhonesTriggerGridx(item);
});




function AjaxSaveChangesPhonesTriggerGridx(item){

if(item.idaccount > 0 && item.idcontact > 0 && PTElements.dijit.GxPT){

  var xhrArgs = {
    url: "/accountphonestriggerviewchanged.usaga",
 content: {idaccount: item.idaccount, idphone: item.idphone, enable: item.enable, fromsms: item.fromsms, fromcall: item.fromcall, note: item.note},
    handleAs: "text",
    load: function(datass){

  var datar = dojox.xml.DomParser.parse(datass);

var xmldata = datar.byName('SQLFunReturn');

if(xmldata.length > 0){
var id = xmldata[0].getAttribute("return");
alert(jsspire.Base64.decode(xmldata[0].getAttribute("msg")));
}
LoadAccountPhonesTriggerGridx(item.idcontact);

    },
    error: function(error){
LoadAccountPhonesTriggerGridx(item.idcontact);
alert(error);
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
}else{
LoadAccountPhonesTriggerGridx(0);
}

}

function LoadAccountPhonesTriggerGridx(inidcontact){

			PTElements.GxPTClear();
var inidaccount = GlobalObject.IdAccount;

if(inidaccount > 0 && inidcontact > 0){

var store = new dojox.data.XmlStore({url: "getaccountphonestriggerview.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: inidaccount, idcontact: inidcontact}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i,
//s: false, 
idaccount: dataxml.getNumber(i, "idaccount"), 
idphone: dataxml.getNumber(i, "idphone"), 
idcontact: dataxml.getNumber(i, "idcontact"), 
enable: dataxml.getBool(i, "trigger_alarm"),
idprovider: dataxml.getNumber(i, "idprovider"),
type: dataxml.getNumber(i, "type"),
phone: dataxml.getStringB64(i, "phone"),
//address: jsspire.Base64.decode(xmldata[i].getAttribute("address")),
phone: dataxml.getStringB64(i, "phone"),
fromsms: dataxml.getBool(i, "fromsms"),    
fromcall: dataxml.getBool(i, "fromcall"),    
note: dataxml.getStringB64(i, "note"),
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
if(GlobalObject.IdAccount > 0){

var store = new dojox.data.XmlStore({url: "getaccountcontactsgrid.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: GlobalObject.IdAccount}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i,
idcontact: dataxml.getNumber(i, "idcontact"), 
enable_as_contact: dataxml.getBool(i, "enable_as_contact"),
priority: dataxml.getNumber(i, "prioritycontact"),    
name: dataxml.getStringB64(i, "lastname")+' '+dataxml.getStringB64(i, "firstname"),
appointment: dataxml.getStringB64(i, "appointment"),
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
if(AC.dijit.Select.get('value') > 0 && GlobalObject.IdAccount > 0){
idcontact = AC.dijit.Select.get('value');
if(deleteReg){
idcontact = idcontact*-1;
}

  var xhrArgs = {
    url: "getaccountcontactstable.usaga",
 content: {idaccount:GlobalObject.IdAccount, idcontact: idcontact, enable_as_contact: AC.dijit.Enable.get('checked'), priority: AC.dijit.Priority.get('value'), appointment: AC.dijit.Appointment.get('value'), note: AC.dijit.Note.get('value'), ts: AC.dijit.TS.get('value')},
    handleAs: "xml",
    load: function(datass){

//var xmldata = datass.getElementsByTagName("row");
var xmld = new jspireTableXmlDoc(datass, 'row');

if(xmld.length > 0){
var outreturn = xmld.getInt(0, 'outreturn');
if(outreturn == Objeto.dijit.Select.get('value')){

alert(xmld.getStringB64(0, 'outpgmsg'));
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

var request = store.fetch({query: {idaccount:GlobalObject.IdAccount, idphone: idphone}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

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
label: dataxml.getStringB64(i, "label"),
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

var request = store.fetch({query: {idaccount:GlobalObject.IdAccount, idcontact: idcontact}, onComplete: function(itemsrow, r){

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};


var dataxml = new jspireTableXmlStore(store, itemsrow);
var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i+1,
idcontact: idcontact,
idnotifaccount: dataxml.getNumber(i, "idnotifaccount"),
idphone: dataxml.getNumber(i, "idphone"),
idprovider: dataxml.getNumber(i, "idprovider"),
phone: dataxml.getStringB64(i, "phone"),
idaccount: dataxml.getNumber(i, "idaccount"),
priority: dataxml.getNumber(i, "priority"),    
call: dataxml.getBool(i, "call"),
sms: dataxml.getBool(i, "sms"),
smstext: dataxml.getStringB64(i, "smstext"),
address: dataxml.getStringB64(i, "address"),
note: dataxml.getStringB64(i, "note")
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
    content: {idaccount: GlobalObject.IdAccount, idcontacts: AC.GxNPSelectedContacts.toString(), call: dijit.byId('usaga.contactnotif.call.all').get('checked'), sms: dijit.byId('usaga.contactnotif.sms.all').get('checked'), msg: dijit.byId('usaga.contactnotif.msg.all').get('value')},
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspireTableXmlDoc(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringB64(0, 'outpgmsg'));

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
    content: {idaccount: GlobalObject.IdAccount, idphones: AC.GxNPSelectedRows.toString(), call: dijit.byId('usaga.notiftelf.call.all').get('checked'), sms: dijit.byId('usaga.notiftelf.sms.all').get('checked'), msg: dijit.byId('usaga.notiftelf.msg.all').get('value')},
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspireTableXmlDoc(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringB64(0, 'outpgmsg'));

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
if(GlobalObject.IdAccount > 0){

var store = new dojox.data.XmlStore({url: "getaccountcontact.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: GlobalObject.IdAccount, idcontact: iniidcontact}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

if(itemsrow.length>0){
Objeto.dijit.Select.set('value', dataxml.getNumber(0, "idcontact")); 
Objeto.dijit.Enable.set("checked", dataxml.getBool(0, "enable_as_contact"));
Objeto.dijit.Priority.set("value", dataxml.getNumber(0, "prioritycontact"));
Objeto.dijit.Appointment.set('value', dataxml.getStringB64(0, "appointment"));
Objeto.dijit.Note.set('value', dataxml.getStringB64(0, "note"));
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


on(GlobalObject.MasterDiv, 'onListIdContactNameLoaded', function(d){
//alert(AC.dijit.Select);
AC.dijit.Select.store = null;
AC.dijit.Select.store = d.data;
AC.dijit.Select.startup();
AC.dijit.Select.readOnly = true;
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
			{field:"enable_as_contact", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jspireEditorArgsToGridxCellBooleanDisabled, alwaysEditing: true},
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
			{field:"call", name: "call", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jspireEditorArgsToGridxCellBoolean, alwaysEditing: true},
			{field:"sms", name: "sms", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jspireEditorArgsToGridxCellBoolean, alwaysEditing: true},
			{field:"smstext", name: "smstext", width: '150px', editable: true},
			{field:"address", name: "Dirección", editable: false},
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

if(GlobalObject.IdAccount > 0 && itemStore.idcontact > 0){

  var xhrArgs = {
    url: "getaccountnotificationstable.usaga",
 content: {idnotifaccount: 0, idaccount:GlobalObject.IdAccount, idphone: itemStore.idphone, priority: itemStore.priority, sms: itemStore.sms, call: itemStore.call, smstext: itemStore.smstext, note: itemStore.note },
    handleAs: "xml",
    load: function(datass){

var xmld = new jspireTableXmlDoc(datass, 'row');

if(xmld.length > 0){

if(xmld.getInt(0, 'outreturn') > 0){
//alert('pasa');
alert(xmld.getStringB64(0, 'outpgmsg'));
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
if(GlobalObject.IdAccount > 0){

var start = new jspireGetDateFromDijitDateTextBox(dijit.byId('usaga.account.event.fstart'));
var end = new jspireGetDateFromDijitDateTextBox(dijit.byId('usaga.account.event.fend'));

var store = new dojox.data.XmlStore({url: "geteventsaccount.usaga", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idaccount: GlobalObject.IdAccount, fstar: start.getDate(), fend: end.getDate()}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

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
account: dataxml.getStringB64(i, "account"),
name: dataxml.getStringB64(i, "name"),
code: dataxml.getStringB64(i, "code"),
zu: dataxml.getNumber(i, "zu"),
priority: dataxml.getNumber(i, "priority"),
description: dataxml.getStringB64(i, "description"),
ideventtype: dataxml.getNumber(i, "ideventtype"),
eventtype: dataxml.getStringB64(i, "eventtype")
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







	dojo.connect(usaga_account_contact_notifphonesStore, 'onSet', function(item, attribute, oldValue, newValue){
//alert('Edita '+ item.idcontact);
ANP.Save(item);
});	

////////////////// FUNCIONES CARGAN AL INICIO //////////////////////////
//GlobalObject.DisabledContentPanes(true);
GlobalObject.DisabledContentPanes(true);

setInterval(function(){
if(GlobalObject.IdAccount>0){
GlobalObject.DisabledContentPanes(false);
}else{
GlobalObject.DisabledContentPanes(true);
}
}, 5000);

//dijit.byId('account.location.geox').constraints = {pattern: '###.################'};
//dijit.byId('account.location.geoy').constraints = {pattern: '###.################'};

GlobalObject.LoadItemsSelectAccount().LoadListIdContactName();
//GlobalObject.LoadListIdContactName();
ABE.dijit.Select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
AC.dijit.Select.set('invalidMessage', 'Seleccione de la lista');
//dijit.byId('usaga_account_address').idps.set('value', 'Es la direccion');


     });
});
