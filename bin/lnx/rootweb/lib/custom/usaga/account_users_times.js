define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./account_users_times.html'
],function(declare,_Widget,_Templated,templateString){

 return declare('usaga.account_users_times',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString   
});
});