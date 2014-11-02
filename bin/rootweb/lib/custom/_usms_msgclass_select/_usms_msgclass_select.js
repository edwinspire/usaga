define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_msgclass_select/_usms_msgclass_select.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
jsFS.addXmlLoader(t.MClass, "enum_DCS_MESSAGE_CLASS_xml.usms", "item", {}, "value", "name");
t.MClass.Load();
},
validate: function(){
return this.MClass.validate();
},
_getValueAttr: function(){
return this.MClass.get('value');
},
reset: function(){
this.MClass.reset();
}





   
});
});
