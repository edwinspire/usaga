define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_sms_form/_usms_sms_form.html',
'jspire/form/DateTextBox'
],function(declare,_Widget,_Templated,templateString, DTBox){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

var t = this;

DTBox.addGetDateFunction(t.date);
var d = new Date();
t.date.set('value', d);
t.time.set('value', d);
},
validate: function(){
var v = false;
var t = this;

if(t.Formulario.validate() && t.advanced.validate()){
v = true;
}

return v;
},
_getValuesAttr: function(){
var t = this;
var dat = t.advanced.get('values');
dat.date = t.date._getDate()+''+t.time.value.toString().replace(/.*1970\s(\S+).*/,'T$1');
dat.message = t.message.get('value');
return dat;
}













  
});
});
