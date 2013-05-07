define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./postgres_form.html',
'dojo/request', 'jspire/request/Xml',
  'dijit/form/Form'
],function(declare,_Widget,_Templated,templateString,  request, RXml){

 return declare('usms.postgres_form',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

},
Save: function(){
var t = this;

if(t.Formulario.validate()){

var data_ = {host: t.Host.get('value'), 
port: t.Port.get('value'), 
user: t.User.get('value'), 
pwd: t.Password.get('value'), 
db: t.DataBase.get('value'), 
ssl: t.SSL.get('checked'),  
note: t.Note.get('value')};

   request.post('postpostgresconf', {
	data: data_,
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var xmld = new RXml.getFromXhr(response, 'postgres');

if(xmld.length > 0){

//t._id = xmld.getInt(0, 'outreturn');
//t.emit('onnotify', {msg: xmld.getStringFromB64(0, 'outpgmsg')});
}else{
//t.reset();
}
//t.emit('onsavephone', {idcontact: t._id});

t.Load();
                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {msg: error});
t.Load();
                }
            );

}else{
t.emit('onnotify', {msg: 'Los datos no son válidos, reviselos antes de guardarlos.'});
}

},

// Carga el formulario de PostgreSQL
Load: function (){
var t = this;
   request.get('getpostgresconf', {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'postgres');

if(d.length > 0){
   t.Password.set('value', d.getStringFromB64(0, 'pwd'));
   t.User.set('value', d.getStringFromB64(0, "user"));
   t.Host.set('value', d.getStringFromB64(0, "host"));  
   t.Port.set('value', d.getNumber(0, "port"));  

   t.SSL.set('checked', d.getBool(0, "ssl"));

   t.DataBase.set('value', d.getStringFromB64(0, "db"));  
   t.Note.set('value', d.getStringFromB64(0, "note"));
}else{
t.emit('onnotify', {msg: 'No se obtuvieron datos'});
}

                },
                function(error){
                    // Display the error returned
t.emit('onnotify', {msg: error});
                }
            );

}







   
});
});
