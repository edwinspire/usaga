define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_contact_phone_data/_usms_contact_phone_data.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
changed: false,
_id: 0,
_idcontact: 0,
_ts: "",
_idaddress: 0,
reset: function(){
t = this;
t.changed = false;
t._id = 0;
//t._idcontact = 0;
t._ts = "1990-01-01";
t._idaddress = 0;
t.Formulario.reset();
},
_setIdaddressAttr: function(id){
var t = this;
t._idaddress = id;
t.changed = true;
t.Save();
},
_getIdaddressAttr: function(){
return this._idaddress;
},
_getIdphoneAttr: function(){
return this._id;
},
postCreate: function(){
var t = this;
t.disableFields(true);

t.Enable.on('change', function(){
t.changed = true;
});
t.Phone.on('change', function(){
t.changed = true;
});
t.PhoneExt.on('change', function(){
t.changed = true;
});
t.TypePhone.on('change', function(){
t.changed = true;
});
t.UbiPhone.on('change', function(){
t.changed = true;
});
t.Provider.on('change', function(){
t.changed = true;
});
t.Note.on('change', function(){
t.changed = true;
});
/*
t.menubar.on('ondelete', function(){
t.Delete();
});


t.menubar.on('onnew', function(){
var i = t._idcontact*1;
t.reset();
t._Load();
t._idcontact = i;
t.disableFields(false);
});

t.menubar.on('onsave', function(){
t.Save();
});
*/
jsFS.addXmlLoader(t.Provider, "provider_listidname_xml.usms", "row", {}, "idprovider", "name");
t.Provider.Load();

},
new: function(){
var i = t._idcontact*1;
t = this;
t.reset();
t._Load();
t._idcontact = i;
t.disableFields(false);
},
Load: function(idcontact_, idphone_){
this.reset();
this._idcontact = idcontact_;
this._id = idphone_;
this._Load();
},
disableFields: function(_disabled){
t = this;
t.Enable.set("disabled", _disabled);
t.Phone.set("disabled", _disabled);
t.PhoneExt.set("disabled", _disabled);
t.TypePhone.set("disabled", _disabled);
t.UbiPhone.set("disabled", _disabled);
t.Provider.set("disabled", _disabled);
t.Note.set("disabled", _disabled);
},
_Load: function(){
var t = this;
t.disableFields(true);
t.changed = false;
if(t._id > 0){
            // Request the text file
            request.get("getphonebyid_xml.usms", {
            // Parse data from xml
	query: {idcontact: t._idcontact, idphone: t._id},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;
if(numrows > 0){
var i = 0;
t.Enable.set('checked', d.getBool(i, "enable"));
t.Phone.set('value', d.getStringFromB64(i, "phone"));
t.PhoneExt.set('value', d.getStringFromB64(i, "phone_ext"));

t.TypePhone.set('value', d.getNumber(i, "typephone"));
t.UbiPhone.set('value', d.getNumber(i, "ubiphone"));
t.Provider.set('value', d.getString(i, "idprovider"));
t.Note.set('value', d.getStringFromB64(i, "note"));
t._ts = d.getString(i, "ts");
t._idaddress = d.getNumber(i, "idaddress");
t._idcontact = d.getNumber(i, "idcontact");
t._id = d.getNumber(i, "idphone");
}else{
t.reset();
}
setTimeout(function(){
t.changed = false;
t.disableFields(false);
}, 2000);
t.emit('onloadphone', {idcontact: t._idcontact, idphone: t._id, idaddress: t._idaddress});

                },
                function(error){
                    // Display the error returned
t.reset();
t.emit('onloadphone',  {idcontact: t._idcontact, idaddress: 0, idphone: 0});
t.emit('onnotify', {message: error});
                }
            );
}else{
t.reset();
t.disableFields(false);
t.emit('onloadphone',  {idcontact: t._idcontact, idaddress: 0, idphone: 0});
}

},

values: function(){
var t = this;
return {
idcontact: t._idcontact, 
idphone: t._id,
enable: t.Enable.get('checked'), 
phone: t.Phone.get('value'), 
phone_ext: t.PhoneExt.get('value'), 
typephone: t.TypePhone.get('value'), 
ubiphone: t.UbiPhone.get('value'), 
idprovider: t.Provider.get('value'), 
note: t.Note.get('value'), 
ts: t._ts,
idaddress: t._idaddress
}
},

Save: function(){

var t = this;
if(t.changed){

if(t.Formulario.validate()){
            // Request the text file
            request.post("phonetable_xml.usms", {
            // Parse data from xml
	data: t.values(),
            handleAs: "xml"
        }).then(
                function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){

t._id = xmld.getInt(0, 'outreturn');
t.emit('onnotify', {message: xmld.getStringFromB64(0, 'outpgmessage')});
}else{
t.reset();
}
t.emit('onsavephone', {idcontact: t._idcontact});
t._Load();

                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {message: error});
t.reset();
t._Load();
                }
            );

}else{
t.emit('onnotify', {message: 'Los datos no han sido completados correctamente'});
}
}

//return Objeto;
},
Delete: function(){
// Internamente postgres elimina automaticamente es idaddress
var t = this;

if(t._id > 0){
            // Request the text file
            request.post("phonetable_xml.usms", {
            // Parse data from xml
	data: {idphone: t._id*-1},
            handleAs: "xml"
        }).then(
                function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
if(0 == Math.abs(xmld.getInt(0, 'outreturn'))){
// Fue borrado correctamente
t.emit('ondeletephone', {idcontact: t._idcontact, idaddress: t._idaddress});
t.reset();
}
t.emit('onnotify', {message: xmld.getStringFromB64(0, 'outpgmessage')});
}else{
t.reset();
}

t._Load();

                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {message: error});
t.reset();
t._Load();
                }
            );

}else{
t.emit('onnotify', {message: 'No ha seleccionado un contacto para eliminar'});
}

//return Objeto;
}





   
});
});
