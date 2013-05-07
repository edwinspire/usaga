	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

// modules:['gridx/modules/Focus', 'gridx/modules/Edit', 'gridx/modules/CellWidget', 'gridx/modules/VirtualVScroller']

require(["dojo/ready",  
"dojo/on",
'dojo/request', 
'jspire/request/Xml',
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit'
], function(ready, on, request, RXml){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

var NotifyMSG = dijit.byId('notify');

var gridxprovider = dijit.byId('gridxprovider');

gridxprovider.on('onnotify', function(m){
NotifyMSG.setText(m.msg);
});

	if (gridxprovider) {

		// Optionally change column structure on the grid
		gridxprovider.setColumns([
			{field:"enable", name: "*", width: '20px', editable: 'true'},
			{field:"idprovider", name: "id", width: '20px'},
			{field:"cimi", name: "cimi", editable: 'true'},
			{field:"name", name: "Proveedor", editable: 'true'},
			{field:"note", name: "Nota" , editable: 'true'}
		]);
gridxprovider.startup();
}

dijit.byId('getdata').on('Click', function(){
gridxprovider._Load();
});


	dojo.connect(ItemFileWriteStore_1, 'onSet', function(item, attribute, oldValue, newValue){
//alert('Edita '+ item.idnotiftempl);
gridxprovider._Save(item);
});


gridxprovider._Load= function(){

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

ItemFileWriteStore_1.clearOnClose = true;
	ItemFileWriteStore_1.data = myData;
	ItemFileWriteStore_1.close();

		gridxprovider.store = null;
		gridxprovider.setStore(ItemFileWriteStore_1);

gridxprovider.emit('onnotify', {msg: 'Se han cargado los datos'});

                },
                function(error){
                    // Display the error returned
gridxprovider.emit('onnotify', {msg: error});
                }
            );


}

gridxprovider._Save= function(item){

            // Request the text file
            request.post("providereditxml.usms", {
            // Parse data from xml
	data: item,
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
var myData = {identifier: "unique_id", items: []};
var i = 0;
numrows = d.length;
if(numrows > 0){

gridxprovider.emit('onnotify', {msg: d.getStringFromB64(0, "outpgmsg")});

}

gridxprovider._Load();
                },
                function(error){
                    // Display the error returned
gridxprovider.emit('onnotify', {msg: error});
                }
            );


}

// Se hace este timeout porque la pagina demora en crearse y al cargar no muestra nada.
setTimeout(gridxprovider._Load, 2000);


     });
});
