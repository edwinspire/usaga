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

dojo.connect(dojo.byId('usaga_menuitem_maintenance'), 'onclick', function(){
window.open("usaga_maintenance.html");
});



dojo.connect(dojo.byId('usaga_menuitem_admins'), 'onclick', function(){
alert('En construccion');
});

dojo.connect(dojo.byId('usaga_menuitem_groups'), 'onclick', function(){
window.open("usaga_groups.html");
});

dojo.connect(dojo.byId('usaga_menuitem_formatNotif'), 'onclick', function(){
window.open("usaga_FormatNotif.html");
});

dojo.connect(dojo.byId('usaga_menuitem_modelpanel'), 'onclick', function(){
window.open("usaga_panelmodel.html");
});

dojo.connect(dojo.byId('usaga_menuitem_eventTypes'), 'onclick', function(){
window.open("usaga_eventtypes.html");
});

dojo.connect(dojo.byId('usaga_menuitem_keywords'), 'onclick', function(){
window.open("usaga_keywords.html");
});

dojo.connect(dojo.byId('usaga_menuitem_usms'), 'onclick', function(){
window.open('usms.html','_blank');
});

dojo.connect(dojo.byId('usaga_menuitem_aboutusaga'), 'onclick', function(){
alert('En construccion');
});

dojo.connect(dojo.byId('usaga_menuitem_tutouSAGA'), 'onclick', function(){
alert('En construccion');
});

dojo.connect(dojo.byId('usaga_menuitem_tutouSMS'), 'onclick', function(){
alert('En construccion');
});





}   







});
});
