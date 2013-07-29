define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_menu_header/_usms_menu_header.html',
'dojo/request',
"jspire/request/Xml",
//'_usms_menu_header/_usms_menu_header_worker_notifications',
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





//setTimeout(t._get_notify(), 5000);

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
console.log('<<<<<>>>> ');
 dojo.forEach(d, function(item, i){
ix = d.getNumber(i, 'id');
console.log('>>> '+ix);
if(ix > t._lastidnotify){
t.notification.notify({message: d.getStringFromB64(i, 'body')});
t._lastidnotify = ix;
}
});

//setTimeout(t._get_notify(), 10000);

                },
                function(error){
                    // Display the error returned
t.notification.notify({message: error});
//setTimeout(t._get_notify(), 10000);
                }
            );
}





   
});
});
