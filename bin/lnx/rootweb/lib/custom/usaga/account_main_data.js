define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./account_main_data.html'
],function(declare,_Widget,_Templated,templateString){

 return declare('usaga.account_main_data',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
    // Get a DOM node reference for the root of our widget
 //   var domNode = this.domNode;
 var t = this;
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



t._LoadListAccounts();
/*
    // Run any parent postCreate processes - can be done at any point
    this.inherited(arguments);
 
    // Set our DOM node's background color to white -
    // smoothes out the mouseenter/leave event animations
    dojo.style(domNode, "backgroundColor", this.baseBackgroundColor);
    // Set up our mouseenter/leave events - using dijit._Widget's connect
    // means that our callback will execute with `this` set to our widget
    this.connect(domNode, "onmouseenter", function(e) {
        this._changeBackground(this.mouseBackgroundColor);
    });
    this.connect(domNode, "onmouseleave", function(e) {
        this._changeBackground(this.baseBackgroundColor);
    });
*/
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
return 0;
},
// Carga la lista accounts en el FilteringSelect
_LoadListAccounts: function(){
new jspire.dijit.FilteringSelect.FilteringSelectLoadFromXml(this.account_select, true, 'fun_view_idaccounts_names_xml.usaga', 'row', 'idaccount', 'name').Load();
},
// Carga el account seleccionado
_LoadAccountSelected: function(){
if(this.account_select.state != 'Error'){

var t = this;
var _idaccount = t.account_select.get('value');

if(_idaccount > 0){

var s = new dojox.data.XmlStore({url: "getaccount.usaga", sendQuery: true, rootItem: 'row'});
var request = s.fetch({query: { idaccount: _idaccount}, onComplete: function(itemsrow, r){

var dataxml = new jspireTableXmlStore(s, itemsrow);

numrows = itemsrow.length;

if(numrows > 0){
_idaccount = dataxml.getNumber(0, "idaccount");
t.partition.set('value', dataxml.getNumber(0, "partition"));
t.enable.set('checked', dataxml.getBool(0, "enable")); 
t.account.set('value', dataxml.getStringB64(0, "account")); 
t.account_select.set('value', _idaccount); 
t.idtype.setValue(dataxml.getString(0, "type")); 
t.note.set('value', dataxml.getStringB64(0, "note"));
t._idaddress = dataxml.getNumber(0, "idaddress"); 

}else{
t._idaddress = 0;
t.form_data.reset();
}
t.emit('onloadaccount', {idaccount: _idaccount, idaddress: t._idaddress}); 

},
onError: function(e){
alert(e);
}
});

}else{
t.form_data.reset();
}


}
},
// Guarda los datos en el servidor
_save: function(){
var t = this;
var datos = {};
datos.idaccount = t.account_select.get('value'); 
datos.idgroup = t.idgroup.get('idgroup');
datos.partition = t.partition.get('value');
datos.enable = t.enable.get('checked'); 
datos.account = t.account.get('value'); 
datos.name = t.account_select.get('displayedValue'); 
datos.type = t.idtype.get('value');
datos.note = t.note.get('value');

  // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
  var xhrArgs = {
    url: "saveaccount.usaga",
    content: datos,
    handleAs: "xml",
    load: function(dataX){

var xmld = new jspireTableXmlDoc(dataX, 'row');

if(xmld.length > 0){

alert(xmld.getStringB64(0, 'outpgmsg'));

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

}









  
});
});
