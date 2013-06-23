define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_smsout_status/_usms_smsout_status.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
jsFS.addXmlLoader(t.Type, "enum_SMSOutStatus_xml.usms.usms", "item", {}, "value", "name");
t.Status.Load();
},
validate: function(){
return this.Status.validate();
},
_getValueAttr: function(){
return this.Status.get('value');
},
reset: function(){
this.Status.reset();
}




   
});
});
