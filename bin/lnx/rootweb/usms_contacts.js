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
"dojox/data/XmlStore"
], function(ready, on, DomParser, Memory, FilteringSelect, Evented, ItemFileReadStore, ItemFileWriteStore, Grid, Async, CheckBox, Focus, CellWidget, Edit, NumberTextBox, VirtualVScroller){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

/////////////////
///// BASIC /////
// Account basic elements

dojo.connect(dijit.byId('usms.contact.new'), 'onClick', function(e){
GlobalObject.IdContact = 0;
FormContact.dojo.Form.reset();
//TODO Limpiar el resto de datos
});

dojo.connect(dijit.byId('usms.contact.save'), 'onClick', function(e){
FormContact.SaveForm();
});

dojo.connect(dijit.byId('usms.contact.del'), 'onClick', function(e){
GlobalObject.IdContact = GlobalObject.IdContact*-1;
FormContact.SaveForm();
});


var GlobalObject = {
IdContact: 0,
GridStore: usms_contacts_ItemFileReadStore,
dijit: {
Grid: dijit.byId("usms.contacts.gridx")
},

LoadContactSelected: function(){

if(GlobalObject.IdContact > 0){
var store = new dojox.data.XmlStore({url: "usms_getcontactbyid_xml", sendQuery: true, rootItem: 'row'});

var request = store.fetch({query: {idcontact: GlobalObject.IdContact}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;
if(numrows > 0){
var i = 0;

FormContact.dijit.Enable.set('value', dataxml.getBool(i, "enable"));
FormContact.dijit.Firstname.set('value', dataxml.getStringB64(i, "firstname"));
FormContact.dijit.Lastname.set('value', dataxml.getStringB64(i, "lastname"));
FormContact.dijit.Title.set('value', dataxml.getNumber(i, "title"));
FormContact.dijit.Birthday.set('value', new Date(dataxml.getString(i, "birthday")));
FormContact.dijit.Gender.set('value', dataxml.getNumber(i, "gender"));
FormContact.dijit.IdentificationType.set('value', dataxml.getNumber(i, "typeofid"));
FormContact.dijit.Identification.set('value', dataxml.getStringB64(i, "identification"));
FormContact.dijit.Web.set('value', dataxml.getStringB64(i, "web"));
FormContact.dijit.email1.set('value', dataxml.getStringB64(i, "email1"));
FormContact.dijit.email2.set('value', dataxml.getStringB64(i, "email2"));
FormContact.dijit.Note.set('value', dataxml.getStringB64(i, "note"));
FormContact.ts = dataxml.getStringB64(i, "ts");
}else{
FormContact.dojo.Form.reset();
}
},
onError: function(e){
alert(e);
}
});
}
},

LoadGrid: function(){

var store = new dojox.data.XmlStore({url: "usms_getcontactslistidcontactname_xml", sendQuery: true, rootItem: 'row'});

var request = store.fetch({onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(store, itemsrow);

numrows = itemsrow.length;

var myData = {identifier: "unique_id", items: []};
myData.identifier = "unique_id";

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id:i,
idcontact: dataxml.getNumber(i, "idcontact"),
enable: dataxml.getBool(i, "enable"),
name: dataxml.getStringB64(i, "name"),
};
i++;
}

GlobalObject.GridStore.clearOnClose = true;
	GlobalObject.GridStore.data = myData;
	GlobalObject.GridStore.close();

		GlobalObject.dijit.Grid.store = null;
		GlobalObject.dijit.Grid.setStore(GlobalObject.GridStore);

},
onError: function(e){
alert(e);
}
});
}
}


	if (GlobalObject.dijit.Grid) {
// Captura el evento cuando se hace click en una fila
dojo.connect(GlobalObject.dijit.Grid, 'onRowClick', function(event){
GlobalObject.IdContact = this.cell(event.rowId, 1, true).data();
GlobalObject.LoadContactSelected();
});
		// Optionally change column structure on the grid
		GlobalObject.dijit.Grid.setColumns([
			{field:"idcontact", name: "id", width: '0px'},
			{field:"enable", name: "*", width: '20px'},
			{field:"name", name: "Nombre"},
		]);
GlobalObject.dijit.Grid.startup();
GlobalObject.LoadGrid();
}

var FormContact = {
ts: '',
dojo: {
Form: dojo.byId('usms.contact.form')
},
dijit: {
Enable: dijit.byId('usms.contact.enable'),
Firstname: dijit.byId('usms.contact.firstname'),
Lastname: dijit.byId('usms.contact.lastname'),
Title: dijit.byId('usms.contact.title'),
Birthday: dijit.byId('usms.contact.birthday'),
Gender: dijit.byId('usms.contact.gender'),
IdentificationType: dijit.byId('usms.contact.typeidentification'),
Identification: dijit.byId('usms.contact.identification'),
Web: dijit.byId('usms.contact.web'),
email1: dijit.byId('usms.contact.email1'),
email2: dijit.byId('usms.contact.email2'),
Note: dijit.byId('usms.contact.note')
},
SaveForm: function(){

var Objeto = this;

  var xhrArgs = {
    url: "usms_contactstablefun_xml",
 content: {idcontact:GlobalObject.IdContact, enable: FormContact.dijit.Enable.get('value'), title: FormContact.dijit.Title.get('value'), firstname: FormContact.dijit.Firstname.get('value'), lastname: FormContact.dijit.Lastname.get('value'), birthday: dojo.date.locale.format(FormContact.dijit.Birthday.get('value'), {datePattern: "yyyy-MM-dd", selector: "date"}), gender: FormContact.dijit.Gender.get('value'), typeofid: FormContact.dijit.IdentificationType.get('value'), identification: FormContact.dijit.Identification.get('value'), web: FormContact.dijit.Web.get('value'), email1: FormContact.dijit.email1.get('value'), email2: FormContact.dijit.email2.get('value'), note: FormContact.dijit.Note.get('value'), ts: FormContact.ts},
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

Objeto.LoadGrid();
    },

    error: function(error)
{
Objeto.LoadGrid();
alert(error);
    }
  }

  var deferred = dojo.xhrPost(xhrArgs);

return Objeto;
}
}

////////////////// FUNCIONES CARGAN AL INICIO //////////////////////////
//dijit.byId('account.location.geox').constraints = {pattern: '###.################'};
//dijit.byId('account.location.geoy').constraints = {pattern: '###.################'};



     });
});
