define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_provider_select/_usms_provider_select.html',
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

jsFS.addXmlLoader(t.Provider, "provider_listidname_xml.usms", "row", {}, "idprovider", "name");
t.Provider.Load();

// Agregamos esta funcion de esta forma para evitar un mal funcionamiento cuando el filteringselect es una celda de un Gridx.
// Una vez cargados los datos se setea y se conecta el evento Change.
t.Provider.postLoad = function(){

t.set('value', t._tempValue);

t.Provider.on('Change', function(e){
t.emit('Change', {});
});
}

},
validate: function(){
return this.Provider.validate();
},
_getValueAttr: function(){
return this.Provider.get('value');
},
reset: function(){
this.Provider.reset();
},
_setValueAttr: function(v){
this.Provider.set('value', String(v));
this._tempValue = v;
},
displayedValue: function(){
return this.Provider.get('displayedValue');
}


   
});
});
