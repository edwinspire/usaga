require(["dojo/ready",
'dojo/request',
"jspire/request/Xml"], function(ready, R, RXml){
     ready(function(){

 dijit.byId('id_titlebar').set('label', 'Acceso a base de datos PostgreSQL');

dojo.connect(dojo.byId('btn_pg_get'), 'onclick', function(){
loadFormPostgreSQLCnx();
} );

dojo.connect(dojo.byId('btn_pg_save'), 'onclick', function(){
sendFormPostgreSQLCnx();
} );

function sendFormPostgreSQLCnx(){

var data_ = {host: dijit.byId('host').get('value'), 
port: dijit.byId('port').get('value'), 
user: dijit.byId('user').get('value'), 
pwd: dijit.byId('pwd').get('value'), 
db: dijit.byId('db').get('value'), 
ssl: dijit.byId('ssl').get('checked'),  
note: dijit.byId('note').get('value')};

   R.post('postpostgresconf', {
	data: data_,
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'postgres');

loadFormPostgreSQLCnx();
                },
                function(error){
                    // Display the error returned
console.log(errorx);
loadFormPostgreSQLCnx();
                }
            );

}


// Carga el formulario de PostgreSQL
function loadFormPostgreSQLCnx(){

   R.get('getpostgresconf', {
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
}

                },
                function(error){
                    // Display the error returned
console.log(errorx);
                }
            );

}


     });
});

// Envia el formulario de PostgreSQL
function sendFormPostgreSQLCnx(){
  var formpg = dojo.byId("FormPostgreSQLCnx");
//postpostgresconf//
  dojo.connect(formpg, "onsubmit", function(event){
    // Stop the submit event since we want to control form submission.
    dojo.stopEvent(event);

    // The parameters to pass to xhrPost, the form, how to handle it, and the callbacks.
    // Note that there isn't a url passed.  xhrPost will extract the url to call from the form's
    //'action' attribute.  You could also leave off the action attribute and set the url of the xhrPost object
    // either should work.
    var xhrArgs = {
      form: formpg,
      handleAs: "text",
      load: function(data){
alert("Enviado");
///        dojo.byId("response").innerHTML = "Form posted.";
      },
      error: function(error){
        // We'll 404 in the demo, but that's okay.  We don't have a 'postIt' service on the
        // docs server.
alert(error);
   //     dojo.byId("response").innerHTML = "Form posted.";
      }
    }
    // Call the asynchronous xhrPost
    var deferred = dojo.xhrPost(xhrArgs);
  });
}




