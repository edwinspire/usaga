define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_textbox_search/_common_textbox_search.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
timeout: 800,
postCreate: function(){
var t = this;
var myTimeoutSearch; 
t.TextBox.on('Change', function(){
clearTimeout(myTimeoutSearch);
myTimeoutSearch=setTimeout(function(){
t.emit('search', {value: t.TextBox.get('value')});
},t.timeout);
});
},
_getTimeoutAttr: function(){
return this.timeout;
},
_setTimeoutAttr: function(to){
if(to<250){
to = 250;
}
this.timeout = to;
},
_setValueAttr: function(v){
this.TextBox.set('value', String(v));
},
_getValueAttr: function(){
return this.TextBox.get('value');
},
reset: function(){
this.TextBox.reset();
}




   
});
});
