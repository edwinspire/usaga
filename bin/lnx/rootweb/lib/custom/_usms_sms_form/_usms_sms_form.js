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

t.message.on('Change', function(){
//alert(this.get('value'));
l = this.get('value').length;
t.Chars.innerHTML = l;
t.LengMsg.innerHTML = Math.ceil(l/160);
});

DTBox.addGetDateFunction(t.date);
t.reset();

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
},
reset: function(){
var t = this;
t.Formulario.reset();
t.advanced.reset();
var d = new Date();
t.date.set('value', d);
t.time.set('value', d);
}














  
});
});
