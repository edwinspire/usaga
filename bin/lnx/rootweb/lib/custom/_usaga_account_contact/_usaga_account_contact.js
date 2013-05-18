define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_account_contact/_usaga_account_contact.html',
'dojo/request',
'jspire/form/FilteringSelect',
'jspire/request/Xml'
],function(declare,_Widget,_Templated,templateString, R, jsFS, RXml){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.listcontactsnew.readOnly = true;
jsFS.addXmlLoader(t.listcontactsnew, 'getcontactslistidcontactname_xml.usms', 'row', {}, 'idcontact', 'name');
t.listcontactsnew.Load();
},
_idaccount: 0,
_idcontact: 0,      
Load: function(idaccount_, idcontact_){

var t = this;
t._idaccount = idaccount_;
t._idcontact = idcontact_;

if(t._idaccount > 0 && t._idcontact > 0){

   R.get('getaccountcontact.usaga', {
		query: {idaccount: t._idaccount, idcontact: t._idcontact},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;
if(numrows > 0){
t._idcontact = d.getNumber(0, "idcontact");
t.name.innerHTML = d.getStringFromB64(0, "lastname")+' '+d.getStringFromB64(0, "firstname");
t.enable.set('checked', d.getBool(0, "enable")); 
t.priority.set('value', d.getNumber(0, "prioritycontact")); 
t.appointment.set('value', d.getStringFromB64(0, "appointment")); 
t.note.set('value', d.getStringFromB64(0, "note"));

}else{
//t._resetall();
}
//t.emit('onloadaccount', {idaccount: t.Id, idaddress: t._idaddress}); 
//t.emit('notify_message', {message: t.account_select.get('displayedValue')+' cargado'}); 
                },
                function(error){
                    // Display the error returned
console.log(error);
t.emit('onloadaccount', {idaccount: 0, idaddress: 0}); 
t.emit('notify_message', {message: error}); 
                }
            );

}else{
t._resetall();
}



},

_delete: function(){
idccountdelete = this.Id;
if(idccountdelete > 0){
var datos = {};
datos.idaccount = this.Id*-1; 
this._actionsave(datos);
}
},

_save: function(){
var t = this;

var datos = {};
if(t.Id >= 0){
datos.idaccount = t.Id;
datos.idaddress = t._idaddress;  
datos.idgroup = t.idgroup.get('value');
datos.partition = t.partition.get('value');
datos.enable = t.enable.get('checked'); 
datos.account = t.account.get('value'); 
datos.name = t.account_select.get('displayedValue'); 
datos.type = t.idtype.get('value');
datos.note = t.note.get('value');
t._actionsave(datos);
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

t.account_select.Load();
var id = d.getInt(0, "outreturn");
if(id>0){
t.account_select.set('value', id);
}else{
t._resetall();
}
t._LoadAccountSelected();
}




                },
                function(error){
                    // Display the error returned
t._resetall();
t._LoadAccountSelected();
//console.log(errorx);
t.emit('notify_message', {message: errorx}); 
                }
            );


}










});
});
