require(["dojo/ready",
'dojo/request',
"jspire/request/Xml"], function(ready, R, RXml){
     ready(function(){

 dijit.byId('id_titlebar').set('label', 'Acceso a base de datos PostgreSQL');

dojo.connect(dojo.byId('btn_pg_get'), 'onclick', function(){
Load();
} );

dojo.connect(dojo.byId('btn_pg_save'), 'onclick', function(){
Save();
} );



function Save(){

var data_ = {host: dijit.byId('host').get('value'), 
port: dijit.byId('port').get('value'), 
user: dijit.byId('user').get('value'), 
pwd: dijit.byId('pwd').get('value'), 
db: dijit.byId('db').get('value'), 
ssl: dijit.byId('ssl').get('checked'),  
note: dijit.byId('note').get('value')};

R.post('savepostgresql.usms', {
   handleAs: "xml",
data: data_
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
//NotifyArea.notify({message: xmld.getStringFromB64(0, 'outpgmsg')});
}
Load();
}, function(error){
//NotifyArea.notify({message: error});
});

}


// Carga el formulario de PostgreSQL
function Load(){

   R.get('getpostgresql.usms', {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'postgres');

if(d.length > 0){
   dijit.byId('pwd').set('value', d.getStringFromB64(0, 'pwd'));
   dijit.byId('user').set('value', d.getStringFromB64(0, "user"));
   dijit.byId('host').set('value', d.getStringFromB64(0, "host"));  
   dijit.byId('port').set('value', d.getNumber(0, "port"));  

   dijit.byId('ssl').set('checked', d.getBool(0, "ssl"));

   dijit.byId('db').set('value', d.getStringFromB64(0, "db"));  
   dijit.byId('note').set('value', d.getStringFromB64(0, "note"));
}else{
//NotifyArea.notify({message: error});
}

                },
                function(error){
                    // Display the error returned
//NotifyArea.notify({message: error});
                }
            );

}


     });
});




