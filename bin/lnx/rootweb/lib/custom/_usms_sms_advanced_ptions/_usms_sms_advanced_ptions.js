define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_sms_advanced_ptions/_usms_sms_advanced_ptions.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString   
});
});