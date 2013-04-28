define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./contacts_data.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/DateTextBox'
],function(declare,_Widget,_Templated,templateString, request, RXml, DTBox){

 return declare('usms.contacts_data',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_id: 0,
_ts: "",
_idaddress: 0,
postCreate: function(){
var t = this;

DTBox.addGetDateFunction(t.Birthday);

t.DialogDelete.setowner(t.id_delete, 'onclick').on('onok', function(){
/*
if(GlobalObject.IdContact>0){
GlobalObject.IdContact = GlobalObject.IdContact*-1;
FormContact.SaveForm();
}
*/
});

t.id_new.on('Click', function(){
t._id = 0;
t._Load();
});

t.id_save.on('Click', function(){
t._Save();
});

t.id_delete.on('Click', function(){
//t.Formulario.reset();
});


},
_setIdContactAttr: function(id){
this._id = id;
this._Load();
},
_getIdContactAttr: function(){
return this._id;
},
_Load: function(){
var t = this;
if(t._id > 0){
            // Request the text file
            request.get("getcontactbyid_xml.usms", {
            // Parse data from xml
	query: {idcontact: t._id},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;
if(numrows > 0){
var i = 0;
t.Enable.set('checked', d.getBool(i, "enable"));
t.FirstName.set('value', d.getStringFromB64(i, "firstname"));
t.LastName.set('value', d.getStringFromB64(i, "lastname"));

t.Title.set('value', d.getStringFromB64(i, "title"));
t.Birthday.set('value', d.getDate(i, "birthday"));
t.Gender.set('value', d.getNumber(i, "gender"));
t.IdentificationType.set('value', d.getNumber(i, "typeofid"));
t.Identification.set('value', d.getStringFromB64(i, "identification"));
t.Web.set('value', d.getStringFromB64(i, "web"));
t.email1.set('value', d.getStringFromB64(i, "email1"));
t.email2.set('value', d.getStringFromB64(i, "email2"));
t.Note.set('value', d.getStringFromB64(i, "note"));
t._ts = d.getStringFromB64(i, "ts");
t._idaddress = d.getNumber(i, "idaddress");
t._id = d.getNumber(i, "idcontact");

}else{
t._id = 0;
t._idaddress = 0;
t.Formulario.reset();
}

t.emit('onloadcontact', {idcontact: t._id, idaddress: t._idaddress});

                },
                function(error){
                    // Display the error returned
t.Formulario.reset();
t.emit('onloadcontact',  {idcontact: 0, idaddress: 0});
t.emit('onnotify', {msg: error});
                }
            );
}else{
t.Formulario.reset();
t.emit('onloadcontact',  {idcontact: 0, idaddress: 0});
}

},

values: function(){
var t = this;
return {
idcontact: t._id, 
enable: t.Enable.get('checked'), 
title: t.Title.get('value'), 
firstname: t.FirstName.get('value'), 
lastname: t.LastName.get('value'), 
birthday: t.Birthday._getDate(),
gender: t.Gender.get('value'), 
typeofid: t.IdentificationType.get('value'), 
identification: t.Identification.get('value'), 
web: t.Web.get('value'), 
email1: t.email1.get('value'), 
email2: t.email2.get('value'), 
note: t.Note.get('value'), 
ts: t._ts}
},

_Save: function(){

var t = this;

if(t.Formulario.validate()){

            // Request the text file
            request.post("contacts_table_edit.usms", {
            // Parse data from xml
	data: t.values(),
            handleAs: "xml"
        }).then(
                function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){

t._id = xmld.getInt(0, 'outreturn');
t.emit('onnotify', {msg: xmld.getStringFromB64(0, 'outpgmsg')});
}else{
t._id = 0;
}
t.emit('onsave', {idcontact: t._id});
t._Load();

                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {msg: error});
t._id = 0;
t._Load();
                }
            );

}else{
t.emit('onnotify', {msg: 'Los datos no han sido completados correctamente'});
}

//return Objeto;
}










   
});
});
