define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./contacts_data.html',
'dojo/request', 'jspire/request/Xml'
],function(declare,_Widget,_Templated,templateString, request, RXml){

 return declare('usms.contacts_data',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_id: 0,
_ts: "",
_idaddress: 0,
postCreate: function(){
var t = this;

t.id_new.on('Click', function(){
t.Formulario.reset();
});

t.id_save.on('Click', function(){
//t.Formulario.reset();
});

t.id_delete.on('Click', function(){
//t.Formulario.reset();
});


},
_setIdContactAttr: function(id){
this._id = id;
this._Load();
},
_getIdContactAttr: function(){
return this._id;
},
_Load: function(){
var t = this;
if(t._id > 0){
            // Request the text file
            request.get("getcontactbyid_xml.usms", {
            // Parse data from xml
	query: {idcontact: t._id},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;
if(numrows > 0){
var i = 0;
t.Enable.set('checked', d.getBool(i, "enable"));
t.FirstName.set('value', d.getStringFromB64(i, "firstname"));
t.LastName.set('value', d.getStringFromB64(i, "lastname"));

t.Title.set('value', d.getStringFromB64(i, "title"));
t.Birthday.set('value', d.getDate(i, "birthday"));
t.Gender.set('value', d.getNumber(i, "gender"));
t.IdentificationType.set('value', d.getNumber(i, "typeofid"));
t.Identification.set('value', d.getStringFromB64(i, "identification"));
t.Web.set('value', d.getStringFromB64(i, "web"));
t.email1.set('value', d.getStringFromB64(i, "email1"));
t.email2.set('value', d.getStringFromB64(i, "email2"));
t.Note.set('value', d.getStringFromB64(i, "note"));
t._ts = d.getStringFromB64(i, "ts");
t._idaddress = d.getNumber(i, "idaddress");
t._id = d.getNumber(i, "idcontact");

}else{
t._id = 0;
t._idaddress = 0;
t.Formulario.reset();
}

t.emit('onloadaccount', {idcontact: t._id, idaddress: t._idaddress});

                },
                function(error){
                    // Display the error returned
t.Formulario.reset();
t.emit('onloadaccount',  {idcontact: 0, idaddress: 0});
t.emit('onnotify', {msg: error});
                }
            );
}else{
t.Formulario.reset();
t.emit('onloadaccount',  {idcontact: 0, idaddress: 0});
}












}










   
});
});
