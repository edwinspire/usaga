//>>built
define("jspire/usms/GridxSMSOutBuilder",["dojo/_base/declare", "dojo/date/locale", 'dojo/request', 
'jspire/request/Xml'],function(_1, _2, request, RXml){

var _x = {
// Construye una tabla smsin
// g = dijit gridx
// s = ItemFileReadStore / ItemFileWriteStore
Build: function(g, s){

	if (g) {

		g.setColumns([

			{field:"idsmsout", name: "id", width:"30px"},
			{field:"idowner", name: "idowner", width:"30px"},
			{field:"dateload", name: "dateload", width:"80px"},
			{field:"idsmstype", name: "idsmstype", width:"20px"},
			{field:"enable", name: "enable-phone", width:"20px"},
			{field:"datetosend", name: "datetosend", width:"80px"},
			{field:"idphone", name: "idphone", width:"50px"},
			{field:"phone", name: "phone", width:"80px"},
			{field:"idprovider", name: "idprovider", width:"50px"},
			{field:"message", name: "message", width: "200px"},
			//{field:"process", name: "process", width:"80px", editor: "_usms_smsout_process/_usms_smsout_process", editable: true, alwaysEditing: true},
			{field:"priority", name: "priority", width:"30px"},
			{field:"report", name: "report", width:"30px"},
			{field:"enablemessageclass", name: "enablemessageclass", width:"30px"},
			{field:"messageclass", name: "messageclass", width:"30px"},
			{field:"status", name: "status"},
			{field:"note", name: "note"}

		]);

g.startup();
}

g.Load= function(from, to, rows){
            // Request the text file
            request.get("view_smsin_datefilter.usms", {
	query: {fstart: from, fend: to, nrows: rows},
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
unique_id:i+1,
idsmsout: d.getNumber(i, "idsmsout"),
idowner: d.getNumber(i, "idowner"),  
enable: d.getBool(i, "enable"),
dateload: d.getString(i, "dateload"),
idprovider: d.getNumber(i, "idprovider"),
idsmstype: d.getNumber(i, "idsmstype"),
idphone: d.getNumber(i, "idphone"),
phone: d.getStringFromB64(i, "phone"),
datetosend: d.getString(i, "datetosend"),
message: d.getStringFromB64(i, "message"),
status: d.getNumber(i, "status"),
priority: d.getNumber(i, "priority"),
report: d.getBool(i, "report"),
messageclass: d.getNumber(i, "messageclass"),
enablemessageclass: d.getBool(i, "enablemessageclass"),
note: d.getStringFromB64(i, "note")
};
i++;
}
}
	s.clearOnClose = true;
	s.data = myData;
	s.close();

		g.store = null;
		g.setStore(s);

                },
                function(error){
                    // Display the error returned
g.emit('onnotify', {msg: error});
                }
            );


}

return g;
}


}

return _x;
});
