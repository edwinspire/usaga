define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_location_address/_usms_location_address.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.titleaddress.set('label', 'Dirección');
t.titlelocation.set('label', 'Localización');
t.address.on('onloaddata', function(l){
t.location.set('location', l.idlocation);
});


t.location.set('location', 0);
},
_setIdaddressAttr: function(id){
this.address.set('idaddress', id);
}   
});
});
