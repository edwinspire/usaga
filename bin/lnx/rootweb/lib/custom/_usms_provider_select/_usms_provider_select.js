define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_provider_select/_usms_provider_select.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.Provider.on('Change', function(){
t.emit('Change', {});
});

jsFS.addXmlLoader(t.Provider, "provider_listidname_xml.usms", "row", {}, "idprovider", "name");
t.Provider.Load();
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
}


   
});
});
