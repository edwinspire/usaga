define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_contact/_usms_contact.html',
"dojo/dom-style"
],function(declare,_Widget,_Templated,templateString, domStyle){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
new: function(){
var t = this;
t.Tab.selectChild(t.ContentPaneContactData);
t.ContactData.new();
t.PhoneData.new();
t.disableFields(true);
},
disableFields: function(_disabled){
var t = this;
t.ContentPaneDireccion.set('disabled', _disabled);
t.ContentPaneTelf.set('disabled', _disabled);
},
save: function(){
t = this;
t.ContactData.save();
t._savePhoneData();
if(t.ContactData.get('idcontact')>0){
t.LocationContact.save();
}
},
delete: function(){
t = this;
t.ContactData.delete();
t.PhoneData.Delete();
t.LocationContact.delete();
},
_savePhoneData: function(){
var t = this;
t.PhoneData.Save();
if(t.PhoneData.get('idphone')>0){
t.LocationTelf.save();
}
},
postCreate: function(){
var t = this;
t.Tab.startup();
t.ContactGroup.set('function', 1);
t.disableFields(true);
t.ContentPaneTelf.on('show', function(){
t.BorderContainerPhones.resize();
t.GridContactPhones.GridX.resize();
console.log('Ajusta Tamaño de la tabla de telefonos');
});


// Menu PhoneData
t.menubarphone.on('ondelete', function(){
t.PhoneData.Delete();
t.LocationTelf.delete();
});

t.menubarphone.on('onnew', function(){
t.PhoneData.new();
});

t.menubarphone.on('onsave', function(){
t._savePhoneData();
});



t.ContactData.on('onloadcontact', function(data){
t.disableFields(false);
t.LocationContact.set('idaddress', data.idaddress);
t.GridContactPhones.Load(data.idcontact);
t.PhoneData.Load(data.idcontact, 0);
t.ContactGroup.set('idcontact', data.idcontact);
if(data.name.length>0){
t.ContentPaneContactData.set('title', '[ '+data.name+' ]');
}else{
t.ContentPaneContactData.set('title', 'Datos: [---]');
}
});


t.ContactData.on('onnotify', function(e){
t.emit('onnotify', e);
});

t.ContactData.on('onsavecontact', function(data){
//t.GridListContact.Load(data.idcontact);
t.emit('contactmodified', {idcontact: data.idcontact});
});

t.ContactData.on('ondeletecontact', function(data){
t.emit('ondeletecontact',  {idcontact: data.idcontact, idaddress: data.idaddress});
});


t.LocationContact.on('onnotify', function(e){
t.emit('onnotify', e);
});
t.LocationContact.on('onsave', function(e){
if(e.idaddress != t.ContactData.get('idaddress')){
t.ContactData.set('idaddress', e.idaddress);
}
});

t.GridContactPhones.on('phoneclick', function(e){
t.PhoneData.Load(t.ContactData.get("idcontact"), e.idphone);
t.TabPhones.resize();
});

t.PhoneData.on('onnotify', function(e){
t.emit('onnotify', e);
});
t.PhoneData.on('onloadphone', function(data){
t.LocationTelf.set('idaddress', data.idaddress);
});
t.PhoneData.on('onsavephone', function(data){
t.GridContactPhones.Load(data.idcontact);
});

t.PhoneData.on('ondeletecontact', function(data){
t.GridContactPhones.Load();
});

t.LocationTelf.on('onnotify', function(e){
t.emit('onnotify', e);
});
t.LocationTelf.on('onsave', function(e){
if(e.idaddress != t.PhoneData.get('idaddress')){
t.PhoneData.set('idaddress', e.idaddress);
}
});


t.resize();

},
resize: function(){
//this.Tab.startup();
this.Tab.resize();
this.TabPhones.resize();
},
_setIdcontactAttr: function(id_){
this.ContactData.set('idcontact', id_);
this.resize();
},
_getIdcontactAttr: function(){
return this.ContactData.get('idcontact');
}





   
});
});
