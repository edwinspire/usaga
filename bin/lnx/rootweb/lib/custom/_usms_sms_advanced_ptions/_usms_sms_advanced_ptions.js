define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_sms_advanced_ptions/_usms_sms_advanced_ptions.html',
"_usms_provider_select/_usms_provider_select"
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){


},
validate: function(){
var t = this;
var v = false;
console.log(t.Formulario.validate());
console.log(t.Provider.validate());

if(t.Formulario.validate() && t.Provider.validate()){
v = true;
}
return v;
},
_getValuesAttr: function(){
var t = this;
//t.validate();
return {idprovider: t.Provider.get('value')}
}









   
});
});
