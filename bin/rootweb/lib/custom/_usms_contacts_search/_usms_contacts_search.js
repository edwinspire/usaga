define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_contacts_search/_usms_contacts_search.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.TSearch.on('search', function(e){
t.GridData.Load(e.value)
});
setTimeout(t.GridData.Load(t.TSearch.get('value')), 2000);
},
resize: function(){
return this.GridData.resize();
}





   
});
});
