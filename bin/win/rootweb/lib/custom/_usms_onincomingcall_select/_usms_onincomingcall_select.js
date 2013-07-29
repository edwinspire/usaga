define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_onincomingcall_select/_usms_onincomingcall_select.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect',
  'dijit/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS, _1){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_tempValue: 0,
postCreate: function(){
var t = this;

jsFS.addXmlLoader(t.IncomingAction, "enum_OnIncomingCall_xml.usms", "item", {}, "value", "name");
t.IncomingAction.Load();

// Agregamos esta funcion de esta forma para evitar un mal funcionamiento cuando el filteringselect es una celda de un Gridx.
// Una vez cargados los datos se setea y se conecta el evento Change.
t.IncomingAction.postLoad = function(){
t.set('value', t._tempValue);
t.IncomingAction.on('Change', function(e){
t.emit('Change', {});
});
}

},
validate: function(){
return this.IncomingAction.validate();
},
_getValueAttr: function(){
return this.IncomingAction.get('value');
},
reset: function(){
this.IncomingAction.reset();
},
_setValueAttr: function(v){
this.IncomingAction.set('value', String(v));
this._tempValue = v;
},
displayedValue: function(){
return this.IncomingAction.get('displayedValue');
}


   
});
});
