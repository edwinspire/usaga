define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_menu_header/_usaga_menu_header.html',
'dojo/request',
"jspire/request/Xml",
'_common_notification_area/_common_notification_area'
],function(declare,_Widget,_Templated,templateString, R, RXml){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
	_lastidnotify: 0,
	_tempts: {},
postCreate: function(){

var t = this;

t.idmlogin.on('Click', function(){
window.open("usaga_login.html", '_self');
});

t.idmlogout.on('Click', function(){
window.open("/", '_self');
});

t.idmeventmonitor.on('Click', function(){
window.open('usaga_eventmonitor.html','_self');
});


t.idmeventmanager.on('Click', function(){
window.open("usaga_event_manager.html", '_self');
});

t.idmeventmanagermobil.on('Click', function(){
window.open("m_usaga_event_manager.html", '_self');
});

t.idmeventreport.on('Click', function(){
window.open("usaga_reports.html", '_self');
});

t.idmeventmonitor2.on('Click', function(){
window.open("usaga_eventmonitor.html", '_self');
});


t.idmaccountedit.on('Click', function(){
window.open("usaga_account.html",'_self');
});

t.idmaccountmante.on('Click', function(){
window.open("usaga_maintenance.html",'_self');
});

t.idmadm.on('Click', function(){
alert('En construccion');
});

t.idmgroups.on('Click', function(){
window.open("usms_groups.html",'_self');
});

t.idmformatnotify.on('Click', function(){
window.open("usaga_FormatNotif.html",'_self');
});

t.idmpanelmodel.on('Click', function(){
window.open("usaga_panelmodel.html",'_self');
});

t.idmeventtypes.on('Click', function(){
window.open("usaga_eventtypes.html",'_self');
});

t.idmkeywords.on('Click', function(){
window.open("usaga_keywords.html",'_self');
});

t.idmusms.on('Click', function(){
window.open('usms.html','_blank');
});

t.idmaboutusaga.on('Click', function(){
alert('En construccion');
});

t.idmtutousaga.on('Click', function(){
alert('En construccion');
});

//t.on("onchangednotification_areatable", function(){
//t._get_notify();
//});

// Recibe la señal del servidor indicando que hubo algun cambio y la tabla debe actualizarse
if(typeof(EventSource) !== "undefined")
  {

  var source=new EventSource("/event_table_changed.usms");

  source.onmessage=function(e){
	t._emit_event(JSON.parse(e.data));
   };

  }else{
// Esto aplica para navegadores que no tienen soporte para EventSource
console.log("Sorry, your browser does not support server-sent events...");
//alert('No soporta EventSource');
setInterval(function(){
t._table_change();
}, 10000);
  }


},
_emit_event: function(obj){
//console.log("EventSource = "+typeof(EventSource));
var t = this;
//console.log(obj);
for (key in obj) {
   // Hacer algo con la clave key
//console.log(key);
if(obj[key] == "true" || obj[key] == true){
console.log("onchanged"+key+"table");

if('notification_area' == key){
t._get_notify();
}

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
//console.log('** _table_change ** '+response);
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

var newts;

try{
newts = JSON.parse(_new);
}
catch(e){
console.log(e);
newts = {};
}

//console.log(newts);

for (key in newts) {
//console.log(newts[key]+' ====> '+t._tempts[key]);
if(newts[key] !== t._tempts[key]){
data[key] = true;
}else{
data[key] = false;
}
}

t._tempts = newts;
t._emit_event(data);
}
 


   
});
});
