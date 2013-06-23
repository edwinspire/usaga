define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_smstype/_usms_smstype.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
jsFS.addXmlLoader(t.Type, "enum_SMSType_xml.usms", "item", {}, "value", "name");
t.Type.Load();
},
validate: function(){
return this.Type.validate();
},
_getValueAttr: function(){
return this.Type.get('value');
}





   
   
});
});
