define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_contact_data/_usms_contact_data.html',
'dojo/request', 
'jspire/request/Xml', 
'jspire/form/DateTextBox',
'dojo/dom-style'
],function(declare,_Widget,_Templated,templateString, request, RXml, DTBox, domStyle){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
changed: false,
_id: 0,
_ts: "",
_idaddress: 0,
reset: function(){
t = this;
t._id = 0;
t._ts = "1990-01-01";
t._idaddress = 0;
t.Formulario.reset();
t.changed = false;
},
postCreate: function(){
var t = this;

DTBox.addGetDateFunction(t.Birthday);

t.Enablex.on('change', function(){
t.changed = true;
});
t.FirstName.on('change', function(){
t.changed = true;
});
t.LastName.on('change', function(){
t.changed = true;
});
t.Title.on('change', function(){
t.changed = true;
});
t.Birthday.on('change', function(){
t.changed = true;
});
t.Gender.on('change', function(){
t.changed = true;
});
t.IdentificationType.on('change', function(){
t.changed = true;
});
t.Identification.on('change', function(){
t.changed = true;
});
t.Web.on('change', function(){
t.changed = true;
});
t.email1.on('change', function(){
t.changed = true;
});
t.email2.on('change', function(){
t.changed = true;
});
t.Note.on('change', function(){
t.changed = true;
});
t.disableFields(true);
//domStyle.set(t.domNode, 'width', '300px');

},
disableFields: function(_disabled){
t = this;
t.Enablex.set("disabled", _disabled);
t.FirstName.set("disabled", _disabled);
t.LastName.set("disabled", _disabled);
t.Title.set("disabled", _disabled);
t.Birthday.set("disabled", _disabled);
t.Gender.set("disabled", _disabled);
t.IdentificationType.set("disabled", _disabled);
t.Identification.set("disabled", _disabled);
t.Web.set("disabled", _disabled);
t.email1.set("disabled", _disabled);
t.email2.set("disabled", _disabled);
t.Note.set("disabled", _disabled);
},
new: function(){
t = this;
t._id = 0;
t._load();
},
_setIdcontactAttr: function(id){
this._id = id;
this._load();
},
_getIdcontactAttr: function(){
return this._id;
},
_setIdaddressAttr: function(id){
this._idaddress = id;
this.changed = true;
// Al setear el idaddress debemos guardar ese seteo
this.save();
},
_getIdaddressAttr: function(){
return this._idaddress;
},
_load: function(){
var t = this;
t.changed = false;
t.disableFields(true);
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
t.Enablex.set('checked', d.getBool(i, "enable"));
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
t._ts = d.getString(i, "ts");
t._idaddress = d.getNumber(i, "idaddress");
t._id = d.getNumber(i, "idcontact");

}else{
t._id = 0;
t._idaddress = 0;
t.Formulario.reset();
}


setTimeout(function(){
t.changed = false;
t.disableFields(false);
}, 2000);
t.emit('onloadcontact', {idcontact: t._id, idaddress: t._idaddress, name: t.LastName.get('value')+' '+t.FirstName.get('value')});

                },
                function(error){
                    // Display the error returned
t.Formulario.reset();
t.emit('onloadcontact',  {idcontact: 0, idaddress: 0, name: ''});
t.emit('onnotify', {message: error});
                }
            );
}else{
t.Formulario.reset();
t.Identification.set("value", new Date().toString().to_b64());
t.disableFields(false);
t.emit('onloadcontact',  {idcontact: 0, idaddress: 0, name: ''});
}
t.changed = false;
},

values: function(){
var t = this;
return {
idcontact: t._id, 
enable: t.Enablex.get('checked'), 
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
ts: t._ts,
idaddress: t._idaddress
}
},

save: function(){

var t = this;
if(t.changed){
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
t.emit('onnotify', {message: xmld.getStringFromB64(0, 'outpgmsg')});
}else{
t._id = 0;
}
t.emit('onsavecontact', {idcontact: t._id});
t._load();

                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {message: error});
t._id = 0;
t._load();
                }
            );

}else{
t.emit('onnotify', {message: 'Los datos no han sido completados correctamente'});
}
}

//return Objeto;
},
delete: function(){
// Internamente postgres elimina automaticamente es idaddress
var t = this;

if(t._id > 0){
            // Request the text file
            request.post("contacts_table_edit.usms", {
            // Parse data from xml
	data: {idcontact: t._id*-1},
            handleAs: "xml"
        }).then(
                function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
if(0 == Math.abs(xmld.getInt(0, 'outreturn'))){
// Fue borrado correctamente
t.emit('ondeletecontact', {idcontact: t._id, idaddress: t._idaddress});
t.reset();
}
t.emit('onnotify', {message: xmld.getStringFromB64(0, 'outpgmsg')});
}else{
t.reset();
}

t._load();

                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {message: error});
t._id = 0;
t._load();
                }
            );

}else{
t.emit('onnotify', {message: 'No ha seleccionado un contacto para eliminar'});
}

//return Objeto;
}


   
});
});
