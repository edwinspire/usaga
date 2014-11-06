define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_menu_header/_usms_menu_header.html',
'dojo/request',
"jspire/request/Xml",
'_common_notification_area/_common_notification_area'
],function(declare,_Widget,_Templated,templateString, R, RXml){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_lastidnotify: 0,
postCreate: function(){
/*
if(typeof(Worker)!=="undefined")
{
  if(typeof(w)=="undefined")
    {
    w=new Worker('/lib/custom/_usms_menu_header/_usms_menu_header_worker_notifications.js');
    }
  w.onmessage = function (event) {
//    document.getElementById("result").innerHTML=event.data;
console.log('>>>>>>< '+event.data);
  };
}
else
{
document.getElementById("result").innerHTML="Sorry, your browser does not support Web Workers...";
}
*/
var t = this;

t.menu_system_loging.on('Click', function(){
window.open("usms.html", '_self');
});

t.menu_system_logout.on('Click', function(){
window.open("usms.html", '_self');
});

t.menu_system_status.on('Click', function(){
window.open("usms_status.html", '_self');
});

t.menu_config_postgresql.on('Click', function(){
window.open("usms_pg_conf.html", '_self');
});

t.menu_config_ports.on('Click', function(){
window.open("usms_ports_conf.html", '_self');
});

t.menu_config_location.on('Click', function(){
window.open("usms_locations.html", '_self');
});

t.menu_config_providers.on('Click', function(){
window.open("usms_providers.html", '_self');
});

t.menu_call_in.on('Click', function(){
window.open("usms_incomingcalls.html", '_self');
});

t.menu_sms_in.on('Click', function(){
window.open("usms_smsin.html", '_self');
});

t.menu_sms_out.on('Click', function(){
window.open("usms_smsout.html", '_self');
});

t.menu_contacts_edit.on('Click', function(){
window.open("usms_contacts.html", '_self');
});

t.menu_config_sim.on('Click', function(){
window.open("usms_sim_conf.html", '_self');
});


t.menu_sms_send.on('Click', function(){
window.open("usms_sendsms.html", '_self');
});

t.idmgroups.on('Click', function(){
window.open("usms_groups.html",'_self');
});

/*
t.menu_providers.on('Click', function(){
window.open("usms_providers.html", '_self');
});

t.menu_whitelist.on('Click', function(){
window.open("usms_whitelist.html", '_self');
});

t.menu_blacklist.on('Click', function(){
window.open("usms_blacklist.html", '_self');
});





t.menu_sms_sendm.on('Click', function(){
window.open("usms_sendm.html", '_self');
});



t.menu_about.on('Click', function(){
window.open("usms_acercade.html", '_self');
});
*/

// Recibe la señal del servidor indicando que hubo algun cambio y la tabla debe actualizarse
if(typeof(EventSource)!=="undefined")
  {

  var source=new EventSource("/event_table_changed.usms");

  source.onmessage=function(e){
	t._emit_event(JSON.parse(e.data));
   };

  }else  {
// Esto aplica para navegadores que no tienen soporte para EventSource
console.log("Sorry, your browser does not support server-sent events...");
//alert('No soporta EventSource');
setInterval(function(){
t._table_change();
}, 10000);
  }

/*
if(typeof(EventSource)!=="undefined")
  {
  var source=new EventSource("notification_lastid.usms");
  source.onmessage=function(event)
    {
console.log(Number(event.data));
t._get_notify();
    };
  }
else
  {
console.log("Sorry, your browser does not support server-sent events...");
  }
*/

},
_emit_event: function(obj){
console.log(obj);
var t = this;

for (key in obj) {
   // Hacer algo con la clave key
//console.log(key);
if(obj[key] == "true"){
console.log("onchanged"+key+"table");
t.emit("onchanged"+key+"table", {});
}
}
},
_get_notify:function(){
var t = this;
   R.post('notification_system.usms', {
            // Parse data from xml
		data: {lastidnotify: t._lastidnotify},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
//console.log('<<<<<>>>> ');
 dojo.forEach(d, function(item, i){
ix = d.getNumber(i, 'idnotify');
//console.log('>>> '+ix);
if(ix > t._lastidnotify){
t.notification.notify({message: d.getStringFromB64(i, 'body'), title: d.getStringFromB64(i, 'title'), img: d.getStringFromB64(i, 'img'), snd: d.getStringFromB64(i, 'snd'), timeout: d.getNumber(i, 'timeout'), urgency: d.getNumber(i, 'urgency'), closable: d.getBool(i, 'closable')});
t._lastidnotify = ix;
}
});

                },
                function(error){
                    // Display the error returned
t.notification.notify({message: error});
                }
            );
},
_table_change:function(){
var t = this;
   R.post('/event_table_changed_browser_does_not_support_server_sent.usms', {
            // Parse data
		data: t._tempts,
            handleAs: "text"
        }).then(
                function(response){
	t._compare_changes(response);
                },
                function(error){
                    // Display the error returned
t.notification.notify({message: error});
//setTimeout(t._get_notify(), 10000);
                }
            );
},
_compare_changes: function(_new){
var t = this;
var data = {};
var newts = JSON.parse(_new);
if(newts.events !== t._tempts.events){
data.events = true;
}else{
data.events = false;
}

if(newts.events_comments !== t._tempts.events_comments){
data.events_comments = true;
}else{
data.events_comments = false;
}

if(newts.eventtypes !== t._tempts.eventtypes){
data.eventtypes = true;
}else{
data.eventtypes = false;
}
t._tempts = newts;
t._emit_event(data);
}
 





   
});
});
