define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_smstype/_usms_smstype.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString   
});
});