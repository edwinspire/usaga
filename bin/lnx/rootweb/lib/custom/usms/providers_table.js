define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./providers_table.html',
'dojo/request', 'jspire/request/Xml', 
  "dojox/io/xhrScriptPlugin",
  "dojo/data/ItemFileWriteStore",
  "gridx/Grid",
  "gridx/core/model/cache/Async",
  "dojox/data/CsvStore"
],function(declare,_Widget,_Templated,templateString,  request, RXml){

 return declare('usms.providers_table',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

dojo.parser.parse(this.domNode);

	dojo.connect(usms_providers_table_jsItemFileWriteStore_1, 'onSet', function(item, attribute, oldValue, newValue){
//alert('Edita '+ item.idnotiftempl);
//this._SaveItem(item);
});

		this.gridxprovider.setColumns([
			{field:"enable", name: "*", width: '20px', editable: 'true'},
			{field:"idprovider", name: "id", width: '20px'},
			{field:"cimi", name: "cimi", editable: 'true', width: '20px'},
			{field:"name", name: "Proveedor", editable: 'true', width: '200px'},
			{field:"note", name: "Nota" , editable: 'true'}
		]);
this.gridxprovider.startup();

this._Load();


},
_Load: function(){
var t = this;

            // Request the text file
            request.get("viewprovidertable_xml.usms", {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
var myData = {identifier: "unique_id", items: []};
var i = 0;
numrows = d.length;
if(numrows > 0){
while(i<numrows){
myData.items[i] = {
unique_id:i,
idprovider: d.getNumber(i, "idprovider"),
cimi: d.getStringFromB64(i, "cimi"),
enable: d.getBool(i, "enable"),
name: d.getStringFromB64(i, "name"),
note: d.getStringFromB64(i, "note"),
ts: d.getString(i, "ts")
};
i++;
}
}

myData.items[i] = {
unique_id:i,
idprovider: 0,
cimi: '',
enable: true,
name: '',
note: '',
ts: '1990-01-01'
};

usms_providers_table_jsItemFileWriteStore_1.clearOnClose = true;
	usms_providers_table_jsItemFileWriteStore_1.data = myData;
	usms_providers_table_jsItemFileWriteStore_1.close();

		t.gridxprovider.store = null;
		t.gridxprovider.setStore(usms_providers_table_jsItemFileWriteStore_1);


//t.gridxprovider.autoWidth = true;
//			t.gridxprovider.autoHeight = true;
	//		t.gridxprovider.resize();


//t.emit('onloadcontact', {idcontact: t._id, idaddress: t._idaddress});

                },
                function(error){
                    // Display the error returned
//t.Formulario.reset();
//t.emit('onloadcontact',  {idcontact: 0, idaddress: 0});
t.emit('onnotify', {msg: error});
                }
            );


}









  
});
});
