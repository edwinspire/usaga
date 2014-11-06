define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_eventtype/_usaga_eventtype.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
jsFS.addXmlLoader(t.Type, "fun_eventtypes_xml.usaga", "row", {manual: 0}, "ideventtype", "label");
t.Type.Load();
},
validate: function(){
return this.Type.validate();
},
_getValueAttr: function(){
return this.Type.get('value');
},
_setValueAttr: function(_id){
this.Type.set('value', _id);
},
reset: function(){
this.Type.reset();
},
_setDisabledAttr: function(_d){
this.Type.set('disabled', _d);
}






   
   
});
});
