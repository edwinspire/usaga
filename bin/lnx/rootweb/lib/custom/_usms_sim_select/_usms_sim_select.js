define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_sim_select/_usms_sim_select.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
jsFS.addXmlLoader(t.SIM, "fun_view_sim_idname_xml.usms", "row", {}, "idsim", "phone");
t.SIM.Load();
},
validate: function(){
return this.SIM.validate();
},
_getValueAttr: function(){
return this.SIM.get('value');
},
reset: function(){
this.SIM.reset();
}








   
});
});
