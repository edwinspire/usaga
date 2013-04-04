define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./usaga_header_menu.html'
],function(declare,_Widget,_Templated,templateString){

 return declare('usaga.usaga_header_menu',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

var t = this;


t.idmlogin.on('Click', function(){
window.open("usaga_login.html");
});

t.idmlogout.on('Click', function(){
window.open("usaga_logout.html", '_self');
});

t.idmeventmonitor.on('Click', function(){
window.open('usaga_eventmonitor.html','_self');
});

t.idmaccountedit.on('Click', function(){
window.open("usaga_account.html");
});

t.idmaccountmante.on('Click', function(){
window.open("usaga_maintenance.html");
});

t.idmadm.on('Click', function(){
alert('En construccion');
});

t.idmgroups.on('Click', function(){
window.open("usaga_groups.html");
});

t.idmformatnotify.on('Click', function(){
window.open("usaga_FormatNotif.html");
});

t.idmpanelmodel.on('Click', function(){
window.open("usaga_panelmodel.html");
});

t.idmeventtypes.on('Click', function(){
window.open("usaga_eventtypes.html");
});

t.idmkeywords.on('Click', function(){
window.open("usaga_keywords.html");
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

}   







});
});
