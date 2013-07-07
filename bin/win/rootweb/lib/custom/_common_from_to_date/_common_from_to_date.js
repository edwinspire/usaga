define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_from_to_date/_common_from_to_date.html',
'jspire/form/DateTextBox'
],function(declare,_Widget,_Templated,templateString, jsDTb){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;

jsDTb.addGetDateFunction(t.FFrom);
jsDTb.addGetDateFunction(t.FTo);

t.reset();

t.ButtonGet.on('Click', function(){
t.emit('onget', {From: t.get('from'), To: t.get('to'), Rows: t.get('rows')});
});

},
_getFromAttr: function(){
//return this.FFrom._getDate()+''+this.HFrom.value.toString().replace(/.*1970\s(\S+).*/,'T$1');
return this.FFrom._getDate()+'T'+this.HFrom.value.toLocaleTimeString();
},
_getToAttr: function(){
return this.FTo._getDate()+'T'+this.HTo.value.toLocaleTimeString();
},
_getRowsAttr: function(){
return this.Rows.get('value');
},
reset: function(){
var t = this;
var x = new Date('2000-01-01 00:00');
t.FFrom.set('value', x);
t.HFrom.set('value', x);

var d = new Date();
t.FTo.set('value', d);
t.HTo.set('value', d);

t.Rows.set('value', 100);
}









   
});
});
