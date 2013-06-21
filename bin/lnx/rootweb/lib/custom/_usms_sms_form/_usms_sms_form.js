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

},
_getValuesAttr: function(){
var t = this;
datetime = t.date._getDate()+''+t.time.value.toString().replace(/.*1970\s(\S+).*/,'T$1');
return {date: datetime, message: t.message.get('value')}
}













  
});
});
