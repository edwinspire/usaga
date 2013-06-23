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
var t = this;
t.MsgClass.MClass.set('disabled', true);
t.EnableMsgClass.on('Change', function(){
t.MsgClass.MClass.set('disabled', !t.EnableMsgClass.checked)
});






},
validate: function(){
var t = this;
var v = false;

if(t.Formulario.validate() && t.Provider.validate() && t.SIM.validate() && t.SMSType.validate() && t.MsgClass.validate()){
v = true;
}
return v;
},
_getValuesAttr: function(){
var t = this;
t.validate();
return {idprovider: t.Provider.get('value'), idsim: t.SIM.get('value'), msgclass: t.MsgClass.get('value'), smstype: t.SMSType.get('value'), priority: t.Priority.get('value'), report: t.Report.get('checked'), enablemsgclass: t.EnableMsgClass.get('checked')}
},
reset: function(){
var t = this;
t.Formulario.reset();
t.Provider.reset();
t.SIM.reset();
t.MsgClass.reset();
t.SMSType.reset();
}









   
});
});
