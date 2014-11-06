define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_account_search/_usaga_account_search.html'
],function(declare,_Widget,_Templated, templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

var t = this;
t.TitleBar.set('label', 'Lista de cuentas');

t.TSearch.on('search', function(e){
t.GridData.load(e.value)
});

},
_getItemselectedAttr: function(){
return this.GridData.get('itemselected');
},
load: function(){
var t = this;
t.GridData.load(t.TSearch.get('value'));
},
resize: function(){
return this.GridData.resize();
}






   
});
});
