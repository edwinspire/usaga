define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_dtmf_select/_usms_dtmf_select.html',
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

jsFS.addXmlLoader(t.Selector, "enum_DTMF_xml.usms", "item", {}, "value", "name");
t.Selector.Load();

// Agregamos esta funcion de esta forma para evitar un mal funcionamiento cuando el filteringselect es una celda de un Gridx.
// Una vez cargados los datos se setea y se conecta el evento Change.
t.Selector.postLoad = function(){

t.set('value', t._tempValue);

t.Selector.on('Change', function(e){
t.emit('Change', {});
});
}

},
validate: function(){
return this.Selector.validate();
},
_getValueAttr: function(){
return this.Selector.get('value');
},
reset: function(){
this.Selector.reset();
},
_setValueAttr: function(v){
this.Selector.set('value', String(v));
this._tempValue = v;
},
displayedValue: function(){
return this.Selector.get('displayedValue');
}


   
});
});
