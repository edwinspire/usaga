define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_events_comments/_usaga_events_comments.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.startup();
t.DataGrid.startup();
t.DataGrid.on('oneventclick', function(e){
t.Comments.load(e.idevent);
});


dojo.setStyle(t.BC.domNode, 'height','100%');
dojo.setStyle(t.BC.domNode, 'width','100%');
t.BC.resize();
},
resize: function(){
this.DataGrid.resize();
this.BC.resize();
},
parameters: function(_p){
this.DataGrid.parameters(_p);
this.Comments.load(0);
}




  
});
});
