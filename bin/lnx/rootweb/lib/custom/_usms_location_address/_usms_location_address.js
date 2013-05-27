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

t.address.on('onsavedata', function(e){
t.emit('onsave', e);
});

t.address.on('notify_message', function(m){
t.emit('notify_message', m)
});
t.location.on('notify_message', function(m){
t.emit('notify_message', m)
});

t.location.set('location', 0);
t.tab.startup();
//t.tab.layout();
},
_setIdaddressAttr: function(id){
this.address.set('idaddress', id);
},
save: function(){
this.address.idlocation = this.location.get('location');
this.address.save();
},
delete: function(){
this.address.delete();
}



   
});
});
