define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_contact_phones_gridx/_usms_contact_phones_gridx.html',
"dojo/request",
"jspire/request/Xml",
"jspire/Gridx",
'dijit/form/CheckBox',
'dojo/data/ItemFileReadStore',
'gridx/Grid',
'gridx/core/model/cache/Async',
'gridx/modules/Focus',
'gridx/modules/VirtualVScroller', 
'gridx/modules/Edit', 
'gridx/modules/CellWidget', 
'gridx/modules/RowHeader', 
'gridx/modules/select/Row', 
'gridx/modules/extendedSelect/Row', 
'gridx/modules/IndirectSelect'
],function(declare,_Widget,_Templated,templateString, R, RXml, jsGridx, CBox){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

var tw = this;


	if (tw.GridX) {
// Captura el evento cuando se hace click en una fila
dojo.connect(tw.GridX, 'onRowClick', function(event){
var t = tw.GridX;
var d = this.cell(event.rowId, 1, true).data();
t.store.fetch({query: {unique_id: d}, onItem: function(item){
tw.emit('phoneclick', {idphone: tw.GridX.store.getValue(item, 'idphone')});
}});


});
		// Optionally change column structure on the grid
		tw.GridX.setColumns([
			//{field:"idcontact", name: "idc", width: '0px'},
			{field:"unique_id", name: "#", width: '25px'},
			{field:"enable", name: "*", width: '20px', editable: true, editor: CBox, editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true},
			{field:"phone", name: "Teléfono"},
		]);
tw.GridX.startup();
}


},
Load: function(_idcontact){
var t = this;
   R.get('simplifiedviewofphonesbyidcontact_xml.usms', {
	query: {idcontact: _idcontact},
            handleAs: "xml"
        }).then(
                function(response){

var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

var myData = {identifier: "unique_id", items: []};

if(numrows > 0){
var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id: i+1,
idcontact: d.getNumber(i, "idcontact"),
idphone: d.getNumber(i, "idphone"),
enable: d.getBool(i, "enable"),
phone: d.getStringFromB64(i, "phone")
};

i++;
}

}

t._setData(myData);

                },
                function(error){
                    // Display the error returned
console.log(error);
t.emit('notify_message', {message: error}); 
                }
            );
},
_setData: function(data){
var t = this;
var st = t.GridX.store;
st.clearOnClose = true;
	st.data = data;
	st.close();
		t.GridX.store = null;
		t.GridX.setStore(st);
//tw.GridX.startup();
tw.GridX.resize();
},
Clear: function(){
this._setData({identifier: "unique_id", items: []});
},
resize: function(){
return this.GridX.resize();
}








   
});
});
