define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_accounts_list/_usaga_accounts_list.html',
'dojo/request', 'jspire/request/Xml', 
'jspire/form/FilteringSelect'
],function(declare,_Widget,_Templated,templateString, request, RXml, jsFS){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.List.queryExpr = '*${0}*';
t.List.searchDelay = 1000;
//alert(t.List.searchDelay);
jsFS.addXmlLoader(t.List, "fun_view_accounts_list_xml.usaga", "row", {}, "idaccount", "label", {name: 'System', id: 0});
t.List.Load();
},
validate: function(){
return this.List.validate();
},
_getValueAttr: function(){
return this.List.get('value');
},
_setValueAttr: function(_v){
this.List.set('value', _v);
},
reset: function(){
this.List.reset();
},
_setDisabledAttr: function(_d){
this.List.set('disabled', _d);
}




   
});
});
