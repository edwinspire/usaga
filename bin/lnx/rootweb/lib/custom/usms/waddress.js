define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./waddress.html',
"dojo/request", "jspire/request/Xml"
],function(declare,_Widget,_Templated,templateString, request, RXml){

 return declare('usms.waddress',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
reset: function(){
this.resetForm();
this.idaddress = 0;
},   
resetForm: function(){
this.idform.reset();
},
idaddress: 0,
ts: '1990-01-01',
idlocation: '0',
_setIdAddressAttr: function(id) {
        // Using our avatarNode attach point, set its value
this.idaddress = id;
return this;
},
_getIdAddressAttr: function() {
        // Using our avatarNode attach point, get its value
return this.idaddress;
},
_settsAttr: function(ts) {
        // Using our avatarNode attach point, set its value
this.ts = ts;
return this;
},
_gettsAttr: function() {
        // Using our avatarNode attach point, get its value
return this.ts;
},
_setMainstreetAttr: function(ms) {
        // Using our avatarNode attach point, set its value
this.idps.set('value', ms);
return this;
},
_getMainstreetAttr: function() {
        // Using our avatarNode attach point, get its value
return this.idps.get('value');
},
_setSecundarystreetAttr: function(ss) {
        // Using our avatarNode attach point, set its value
this.idss.set('value', ss);
return this;
},
_getSecundarystreetAttr: function() {
        // Using our avatarNode attach point, get its value
return this.idss.get('value');
},
_setOtherAttr: function(o) {
        // Using our avatarNode attach point, set its value
this.ido.set('value', o);
return this;
},
_getOtherAttr: function() {
        // Using our avatarNode attach point, get its value
return this.ido.get('value');
},
_setNoteAttr: function(n) {
        // Using our avatarNode attach point, set its value
this.idn.set('value', n);
return this;
},
_getNoteAttr: function() {
        // Using our avatarNode attach point, get its value
return this.idn.get('value');
},
_setGeoxAttr: function(x) {
        // Using our avatarNode attach point, set its value
this.idgeox.set('value', x);
return this;
},
_getGeoxAttr: function() {
        // Using our avatarNode attach point, get its value
return this.idgeox.get('value');
},
_setGeoyAttr: function(y) {
        // Using our avatarNode attach point, set its value
this.idgeoy.set('value', y);
this.emit('onok', {value: y});
return this;
},
_getGeoyAttr: function() {
        // Using our avatarNode attach point, get its value
return this.idgeoy.get('value');
},
postCreate: function(){
this.reset();
    // Get a DOM node reference for the root of our widget
 //   var domNode = this.domNode;
 

/*
    // Run any parent postCreate processes - can be done at any point
    this.inherited(arguments);
 
    // Set our DOM node's background color to white -
    // smoothes out the mouseenter/leave event animations
    dojo.style(domNode, "backgroundColor", this.baseBackgroundColor);
    // Set up our mouseenter/leave events - using dijit._Widget's connect
    // means that our callback will execute with `this` set to our widget
    this.connect(domNode, "onmouseenter", function(e) {
        this._changeBackground(this.mouseBackgroundColor);
    });
    this.connect(domNode, "onmouseleave", function(e) {
        this._changeBackground(this.baseBackgroundColor);
    });
*/
},
values: function(){
var t = this;
return {
idaddress: t.idaddress,
geox: t.idgeox.get('value'),
geoy: t.idgeoy.get('value'),
f1: t.idf1.get('value'),
f2: t.idf2.get('value'),
f3: t.idf3.get('value'),
f4: t.idf4.get('value'),
f5: t.idf5.get('value'),
f6: t.idf6.get('value'),
f7: t.idf7.get('value'),
f8: t.idf8.get('value'),
f9: t.idf9.get('value'),
f10: t.idf10.get('value'),
ts: t.ts,
idlocation: t.idlocation
};
},
load: function(id){
var t = this;
t.idaddress = id;
            // Request the text file
            request.get("get_address_byid.usms", {
            // Parse data from xml
	query: {idaddress: t.idaddress},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;
var myData = {identifier: "unique_id", items: []};

if(numrows > 0){
i = 0;
t.idaddress = d.getNumber(i, 'idaddress');
//t.idgeox.set('value',  d.getFloat(i, 'geox'));
//t.idgeoyset('value', d.getFloat(i, 'geoy'));
t.idf1.set('value', d.getStringFromB64(i, 'field1'));
t.idf2.set('value', d.getStringFromB64(i, 'field2'));
t.idf3.set('value',d.getStringFromB64(i, 'field3'));
t.idf4.set('value',d.getStringFromB64(i, 'field4'));
t.idf5.set('value',d.getStringFromB64(i, 'field5'));
t.idf6.set('value', d.getStringFromB64(i, 'field6'));
t.idf7.set('value', d.getStringFromB64(i, 'field7'));
t.idf8.set('value', d.getStringFromB64(i, 'field8'));
t.idf9.set('value', d.getStringFromB64(i, 'field9'));
t.idf10.set('value', d.getStringFromB64(i, 'field10'));
t.ts = d.getString(i, 'ts');
t.idlocation = d.getString(i, 'idlocation');
}else{
t.reset();
}
t.emit('onloaddata', t.values());
                },
                function(error){
                    // Display the error returned
t.reset();
t.emit('onloaddata', t.values());
alert(error);
                }
            );

}




});
});
