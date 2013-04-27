define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./contacts_data.html'
],function(declare,_Widget,_Templated,templateString){

 return declare('usms.contacts_data',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString   
});
});