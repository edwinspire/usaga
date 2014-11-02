//>>built
define("jspire/usms/GridxSMSInBuilder",["dojo/_base/declare", "dojo/date/locale", 'dojo/request', 
'jspire/request/Xml'],function(_1, _2, request, RXml){

var _x = {
// Construye una tabla smsin
// g = dijit gridx
// s = ItemFileReadStore / ItemFileWriteStore
Build: function(g, s){

	if (g) {


		// Optionally change column structure on the grid
		g.setColumns([

			{field:"idsmsin", name: "id"},
			{field:"dateload", name: "dateload", width: "5%"},
			{field:"idprovider", name: "idprovider"},
			{field:"idphone", name: "idphone"},
			{field:"phone", name: "phone"},
			{field:"datesms", name: "datesms", width: "5%"},
			{field:"message", name: "message", width: "15%"},
			{field:"idport", name: "idport"},
			{field:"status", name: "status"},
			{field:"flag1", name: "flag1"},
			{field:"flag2", name: "flag2"},
			{field:"flag3", name: "flag3"},
			{field:"flag4", name: "flag4"},
			{field:"flag5", name: "flag5"},
			{field:"note", name: "note", width: "10%"}
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
idsmsin: d.getNumber(i, "idsmsin"), 
dateload: d.getString(i, "dateload"),
idprovider: d.getNumber(i, "idprovider"),
idphone: d.getNumber(i, "idphone"),
phone: d.getStringFromB64(i, "phone"),
datesms: d.getString(i, "datesms"),
message: d.getStringFromB64(i, "message"),
idport: d.getNumber(i, "idport"),
status: d.getNumber(i, "status"),
flag1: d.getNumber(i, "flag1"),
flag2: d.getNumber(i, "flag2"),
flag3: d.getNumber(i, "flag3"),
flag4: d.getNumber(i, "flag4"),
flag5: d.getNumber(i, "flag5"),
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
