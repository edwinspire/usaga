define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_account_gridx_filter/_usaga_account_gridx_filter.html',
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
'gridx/modules/IndirectSelect',
'gridx/modules/pagination/Pagination',
'gridx/modules/pagination/PaginationBar'
],function(declare,_Widget,_Templated,templateString, R, RXml, jsGridx, CBox){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
  url: 'fun_view_account_to_list_search_xml.usaga',
postCreate: function(){

var tw = this;

	if (tw.GridX) {
 // Optionally change column structure on the grid
		tw.GridX.setColumns([
			{field:"unique_id", name: "#", width: '25px'},
			{field:"enable", name: "*", width: '20px', editable: true, editor: CBox, editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true},
			{field:"name", name: "Nombre"},
			{field:"account", name: "Abonado"}
		]);
	tw.GridX.pagination.setPageSize(50);
jsGridx.addItemSelection(tw.GridX);
tw.GridX.startup();
}

// Captura el evento cuando se hace click en una fila
dojo.connect(tw.GridX, 'onRowClick', function(event){
var d = this.cell(event.rowId, 1, true).data();
tw.GridX.store.fetch({query: {unique_id: d}, onItem: function(item){
tw.emit('accountclick', {idaccount: tw.GridX.store.getValue(item, 'idaccount')});
}});
});

tw.load();
},
_getItemselectedAttr: function(){
return this.GridX.ItemSelected;
},
load: function(tsearch){
var t = this;
   R.get(t.url, {
            // Parse data from xml
	query: {text: tsearch},
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
idaccount: d.getNumber(i, "idaccount"),
enable: d.getBool(i, "enable"),
name: d.getStringFromB64(i, "name"),
account: d.getStringFromB64(i, "account")
};

i++;
}

}
t._setData(myData);
//t.GridX.startup();

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
t.GridX.resize();
},
Clear: function(){
this._setData({identifier: "unique_id", items: []});
},
resize: function(){
return this.GridX.resize();
}





   
});
});
