require(["dojo/ready",
'dojo/request',
"jspire/request/Xml"], function(ready, R, RXml){
     ready(function(){

var PostgreSQLForm = dijit.byId('postgres_form_widget');

dojo.connect(dojo.byId('btn_pg_get'), 'onclick', function(){
PostgreSQLForm.Load();
} );

dojo.connect(dojo.byId('btn_pg_save'), 'onclick', function(){
PostgreSQLForm.Save();
} );





     });
});




