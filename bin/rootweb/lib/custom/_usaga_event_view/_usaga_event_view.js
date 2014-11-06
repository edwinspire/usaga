define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_event_view/_usaga_event_view.html',
'dojo/request',
'jspire/request/Xml',
'dojo/dom-class',
'_common_datetime/_common_datetime'
],function(declare,_Widget,_Templated,templateString, R, RXml, domClass){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_IdEvent: 0,
postCreate: function(){
var t = this;
t.set('disabledfields', true);
},
load: function(_id){
var t = this;
t._IdEvent = _id;
if(t._IdEvent > 0){

t.set('disabledfields', true);

   R.get('fun_events_getbyid_xml.usaga', {
		query: {idevent: t._IdEvent},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

if(numrows > 0){
t._IdEvent = d.getNumber(0, "idevent");
t.ID.innerHTML = '# '+t._IdEvent;
t.Account.set('value', d.getString(0, "idaccount")); 
t.Fecha.set('value', d.getString(0, "datetimeevent"));
t.Code.set('value', d.getStringFromB64(0, "code")); 
t.ZU.set('value', d.getInt(0, "zu")); 
t.Priority.set('value', d.getInt(0, "priority"));
t.Description.set('value', d.getStringFromB64(0, "description")); 
t.ET.set('value', d.getString(0, "ideventtype")); 

domClass.remove(t.Wcontainer);
domClass.add(t.Wcontainer, "levelb"+t.Priority.get('value'));
//alert(t.Account.get('displayedValue'));
}else{
t.reset();
}
//console.log(t.Account.get('displayedValue'));
t.emit('onloadevent', {idevent: t._IdEvent}); 

                },
                function(error){
                    // Display the error returned
console.log(error);
t.reset();
t.emit('onloadevent', {idevent: t._IdEvent}); 
t.emit('notify_message', {message: error}); 
                }
            );

}else{
t.reset();
t.emit('onloadevent', {idevent: t._IdEvent}); 
}
},
New_: function(_idaccount){
var t = this;
t.reset();
t.Fecha.now();
t.set('disabledfields', false);
if(_idaccount>0){
t.Account.set('value', _idaccount); 
t.Account.set('disabled', true);
}
},
save: function(){
var t = this;

if(t.Account.get('value')>0 && t._IdEvent<1){

var _data = {idaccount: t.Account.get('value'), date: t.Fecha.get('value'), code: t.Code.get('value'), zu: t.ZU.get('value'), priority: t.Priority.get('value'), description: t.Description.get('value'), ideventtype: t.ET.get('value')};

   R.post('fun_event_insert_manual_xml.usaga', {
		data: _data,
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){

var d = new RXml.getFromXhr(response, 'row');

if(d.length > 0){

console.log(d.getStringFromB64(0, 'outpgmsg'));
t.emit('notify_message', {message: d.getStringFromB64(0, 'outpgmsg')}); 

id = d.getInt(0, "outreturn");
if(id>0){
t.load(id);
}else{
t._resetall();
}

}

                },
                function(error){
                    // Display the error returned
t.reset();
t.load();
//console.log(errorx);
t.emit('notify_message', {message: errorx}); 
                }
            );

}else{
console.log('No se puede guardar un evento ya creado, Imposible editar! >> '+t._IdEvent);
}


},
reset: function(){
var t = this;
t._IdEvent = 0;
t.ID.innerHTML = '# '+t._IdEvent;
t.Account.reset();
t.Fecha.reset();
t.Code.reset();
t.ZU.reset();
t.Priority.reset();
t.Description.reset();
t.ET.reset(); 
//t.set('disabledfields', false);
domClass.remove(t.Wcontainer);
t.emit('onloadevent', {idevent: t._IdEvent}); 
},
_setDisabledfieldsAttr: function(_d){
var t = this;
t.Fecha.set('disabled', _d);
t.Account.set('disabled', _d);
t.ET.set('disabled', _d);
t.Code.set('disabled', _d);
t.ZU.set('disabled', _d);
t.Priority.set('disabled', _d);
t.Description.set('disabled', _d);
}


   
});
});
