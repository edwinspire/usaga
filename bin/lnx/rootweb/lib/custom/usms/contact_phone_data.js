define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./contact_phone_data.html'
],function(declare,_Widget,_Templated,templateString){

 return declare('usms.contact_phone_data',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString   
});
});