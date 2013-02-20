define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./account_main_data.html',
'dojo/request',
"jspire/form/FilteringSelect",
"jspire/request/Xml"
],function(declare,_Widget,_Templated,templateString, R, jsFS, RXml){

 return declare('usaga.account_main_data',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
    // Get a DOM node reference for the root of our widget
 //   var domNode = this.domNode;

 var t = this;

jsFS.addXmlLoader(t.account_select, 'fun_view_idaccounts_names_xml.usaga', 'row', {}, 'idaccount', 'name');
jsFS.addXmlLoader(t.idgroup, 'fun_view_idgroup_name_xml.usaga', 'row', {}, 'idgroup', 'name');

// Generamos un id aleatorio porque el tooltipdialogconfirmation solo funciona pasando como parametro el id del elemento
id_button_delete = 'account_main_data'+Math.random()+'id_button_delete';
 
t.button_delete.set("id", id_button_delete);

dojo.connect(t.account_select, 'onChange', function(e){
t._LoadAccountSelected();
});


dojo.connect(t.button_new, 'onClick', function(e){
t.account_select.set('invalidMessage', 'El nombre de Abonado es permitido');
t._resetall();
t.emit('onloadaccount', {idaccount: 0, idaddress: 0}); 
});

dojo.connect(t.button_save, 'onClick', function(e){
t.account_select.set('invalidMessage', 'Debe seleccionar un abonado de la lista');
t._save();
});

t.dialogconfirmdeleteaccount.setowner(t.button_delete.get("id"), 'onclick').on('onok', function(){
t._delete();
});


t.account_select.Load();
t.idgroup.Load();

},
_resetall: function(){
this.form_data.reset();
this._idaddress = 0;
},
_idaddress: 0,
idaddress: function(){
return _idaddress;
},
idaccount: function(){
return this.account_select.get('value');
},
// Carga el account seleccionado
_LoadAccountSelected: function(){
if(this.account_select.state != 'Error'){

var t = this;
var _idaccount = t.account_select.get('value');

if(_idaccount > 0){

   R.get('getaccount.usaga', {
		query: {idaccount: _idaccount},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

if(numrows > 0){
_idaccount = d.getNumber(0, "idaccount");
t.partition.set('value', d.getNumber(0, "partition"));
t.enable.set('checked', d.getBool(0, "enable")); 

// Esto es para verificar que sea un numero valido ya que los valores nulos no son enviados desde postgres
_idgroup = d.getNumber(0, "idgroup");
if(isNaN(_idgroup) || _idgroup < 1){
t.idgroup.reset();
}else{
t.idgroup.set('value', _idgroup);
}

t.account.set('value', d.getStringFromB64(0, "account")); 
t.account_select.set('value', _idaccount); 
t.idtype.setValue(d.getString(0, "type")); 
t.note.set('value', d.getStringFromB64(0, "note"));
t._idaddress = d.getNumber(0, "idaddress"); 

}else{
t._idaddress = 0;
t.form_data.reset();
}
t.emit('onloadaccount', {idaccount: _idaccount, idaddress: t._idaddress}); 




                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );

}else{
t.form_data.reset();
}


}
},

_delete: function(){
idccountdelete = this.account_select.get('value');
if(idccountdelete > 0){
var datos = {};
datos.idaccount = idccountdelete*-1; 
t._actionsave(datos);
}
},

_save: function(){

var t = this;
var datos = {};
idaccountsave = t.account_select.get('value');
if(idaccountsave >= 0){
datos.idaccount = t.account_select.get('value'); 
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

alert(d.getStringFromB64(0, 'outpgmsg'));

t._LoadListAccounts();
var id = d.getNumber(0, "outreturn");

if(id>=0){
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
alert(errorx);
                }
            );

/*
  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "saveaccount.usaga",
    content: data,
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspireTableXmlDoc(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringFromB64(0, 'outpgmsg'));

t._LoadListAccounts();
var id = xmld.getNumber(0, "outreturn");

if(id>=0){
t.account_select.set('value', id);
}else{
t._resetall();
}
t._LoadAccountSelected();
}

    },
    error: function(errorx){
t._resetall();
t._LoadAccountSelected();
alert(errorx);
    }
  }
  // Call the asynchronous xhrGet
  var deferred = dojo.xhrPost(xhrArgs);
*/
},

  
});
});
