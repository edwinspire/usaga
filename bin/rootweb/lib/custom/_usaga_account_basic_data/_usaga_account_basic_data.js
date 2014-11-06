define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_account_basic_data/_usaga_account_basic_data.html',
'dojo/request',
'jspire/form/FilteringSelect',
'jspire/request/Xml',
'_common_tooltipdialogconfirmation/_common_tooltipdialogconfirmation'
],function(declare,_Widget,_Templated,templateString, R, jsFS, RXml){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
Id: 0,
//_idcontactLast: '0',
changed: false,
new: function(){
var t = this;
t.Id = 0;
t.form_data.reset();
t.changed = false;
//t.name.set('invalidMessage', 'El nombre de Abonado es permitido');
t.emit('onloadaccount', {idaccount: t.Id, idcontact: 0}); 
t.emit('notify_message', {message: 'Crear nuevo abonado'}); 
},
postCreate: function(){

var t = this;

t.partition.on('Change', function(){
t.changed = true;
});
t.enable.on('Change', function(){
t.changed = true;
});
//t.idgroup.on('Change', function(){
//t.changed = true;
//});
t.account.on('Change', function(){
t.changed = true;
});
t.name.on('Change', function(){
t.changed = true;
});
t.idtype.on('Change', function(){
t.changed = true;
});
t.idcontact.on('Change', function(){
t.changed = true;
t.emit('oncontactselected', {idcontact: t.idcontact.get('value')});
});
t.note.on('Change', function(){
t.changed = true;
});

jsFS.addXmlLoader(t.idcontact, "/getcontactslistidcontactname_xml.usms", "row", {}, "idcontact", "name", {name: 'Ninguno', id: '0'});
//jsFS.addXmlLoader(t.idgroup, 'fun_view_groups_xml.usaga', 'row', {}, 'idgroup', 'name');

/*
t.idcontact.on('onloaddata', function(){
setTimeout(t.DialogLinkContact.close, 2000);
})
*/
t.idcontact.Load();
//t.idgroup.Load();


/*
t.DialogLinkContact.innerHTML('<div style="width: 150px;"><div>Esta acción vincula el contacto seleccionado a este abonado. Si ya hay otro contacto vinculado actualmente esto lo reemplazará</div><div>Está seguro que desea continuar?</div></div>').dijitOwner(t.idcontact, 'Change').on('onok', function(e){
t.changed = true;
t._idcontactLast = t.idcontact.get('value');
});

t.DialogLinkContact.on('onno', function(e){
// Al volver a cambiar de valor se vuelve a disparar el evento Change, por lo que hay que volver a cerrar el dialogo.
//t.idcontact.domNode.removeEventListener('Click', this);
t.idcontact.set('value', t._idcontactLast);
});
*/

},
disableFields: function(_disabled){
var t = this;
t.partition.set('disabled', _disabled);
t.enable.set('disabled', _disabled);
//t.idgroup.set('disabled', _disabled);
t.account.set('disabled', _disabled);
t.name.set('disabled', _disabled); 
t.idtype.set('disabled', _disabled);
t.idcontact.set('disabled', _disabled);
t.note.set('disabled', _disabled);
},
_resetall: function(){
this.form_data.reset();
this.idcontact.reset();
this.Id = 0;
this.changed = false;
t.disableFields(false);
},
_getIdcontactAttr: function(){
return this.idcontact.get('value');
},
_setIdcontactAttr: function(id_){
var t = this;
// Seteamos el nuevo idcontact (si fue modificado) y enviamos los datos para guardarlos.
if(id_ != t.idcontact.get('value')){
t.idcontact.Load();
setTimeout(function(){
t.idcontact.set('value', id_);
t.changed = true;
}, 1500);
}
},
idaccount: function(){
return this.Id;
},
_getIdaccountAttr: function(){
return this.Id;
},
// Carga el account seleccionado
load: function(_id){
var t = this;
t.Id = _id;
t.changed = false;

if(t.Id > 0){
t.disableFields(true);
   R.get('getaccount.usaga', {
		query: {idaccount: t.Id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

if(numrows > 0){
t.Id = d.getNumber(0, "idaccount");
t.partition.set('value', d.getNumber(0, "partition"));
t.enable.set('checked', d.getBool(0, "enable")); 

/*
// Esto es para verificar que sea un numero valido ya que los valores nulos no son enviados desde postgres
_idgroup = d.getNumber(0, "idgroup");
if(isNaN(_idgroup) || _idgroup < 1){
t.idgroup.reset();
}else{
t.idgroup.set('value', _idgroup);
}
*/

t.account.set('value', d.getStringFromB64(0, "account")); 
t.name.set('value', d.getStringFromB64(0, "name")); 
t.idtype.setValue(d.getString(0, "type")); 
t.note.set('value', d.getStringFromB64(0, "note"));
t.idcontact.set('value', d.getString(0, "idcontact")); 
//t._idcontactLast = t.idcontact.get('value');

}else{
t._resetall();
}
console.log('IdACcount '+t.Id+' loaded');
setTimeout(function(){
t.changed = false;
t.disableFields(false);
}, 1500);


t.emit('onloadaccount', {idaccount: t.Id, idcontact: t.idcontact.get('value'), name: t.name.get('value')}); 
//t.emit('notify_message', {message: t.name.get('displayedValue')+' cargado'}); 
                },
                function(error){
                    // Display the error returned
console.log(error);
t.changed = false;
t.emit('onloadaccount', {idaccount: 0, idcontact: 0}); 
t.emit('notify_message', {message: error}); 
                }
            );

}else{
t._resetall();
}



},

delete: function(){
idccountdelete = this.Id;
if(idccountdelete > 0){
var datos = {};
datos.idaccount = this.Id*-1; 
this._actionsave(datos);
}
},

save: function(){
var t = this;
if(t.changed){
console.log('function save _usaga_account_basic_data: ID '+t.Id);
var datos = {};
if(t.Id >= 0){
t.disableFields(true);
datos.idaccount = t.Id;
datos.idcontact = t.idcontact.get('value');  
//datos.idgroup = t.idgroup.get('value');
datos.partition = t.partition.get('value');
datos.enable = t.enable.get('checked'); 
datos.account = t.account.get('value'); 
datos.name = t.name.get('value'); 
datos.type = t.idtype.get('value');
datos.note = t.note.get('value');
t._actionsave(datos);
}
}
},
// Guarda los datos en el servidor
_actionsave: function(_data){
var t = this;

   R.post('saveaccount.usaga', {
		data: _data,
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){

var d = new RXml.getFromXhr(response, 'row');

if(d.length > 0){

console.log(d.getStringFromB64(0, 'outpgmsg'));
t.emit('notify_message', {message: d.getStringFromB64(0, 'outpgmsg')}); 

id = d.getInt(0, "outreturn");
if(id>0){
t.load(id);
}else{
t._resetall();
}

}

                },
                function(error){
                    // Display the error returned
t._resetall();
t.load();
//console.log(errorx);
t.emit('notify_message', {message: errorx}); 
                }
            );


}







   
});
});
