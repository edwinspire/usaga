define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usms_gridx_groups/_usms_gridx_groups.html',
"dojo/request",
"jspire/request/Xml",
"jspire/Gridx",
'dijit/form/CheckBox',
'dojo/data/ItemFileWriteStore',
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
	_function: -10,
	_rows: 25,
	_idcontact: 0,
	_url_load: 'fun_view_groups_xml.usms',
//	_columntypes: new Array(),
postCreate: function(){

var t = this;

	if (t.Gridx) {

jsGridx.addRowSelection(t.Gridx, 'idgroup');

	dojo.connect(t.Gridx.store, 'onSet', function(item, attribute, oldValue, newValue){
switch(t._function){
	case 1:
t.save_contact_group(item);
	break;
	default:
t.save(item);
	break;
}
});

//Esta fila habilita que aparezca la columna idaccount
	t.columns();
	t.Gridx.pagination.setPageSize(25);

/*
// Captura el evento cuando se hace click en una fila
dojo.connect(t.Gridx, 'onRowClick', function(event){
var d = this.cell(event.rowId, 1, true).data();
//console.log(d);
t.Gridx.store.fetch({query: {unique_id: d}, onItem: function(item){
t.emit('ongroupclick', item);
}});
});
*/
t.clear();

}

//t.load();

},
columns: function(){
var t = this;
var cols = [];

var columntypes = new Array();
columntypes[0] = {field:"unique_id", name: "#", width: '20px'};
columntypes[1] = {field:"belong", name: "Pertenece", width: '50px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true};
columntypes[3] = {field:"enable", name: "*", width: '20px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: true};
columntypes[2] = {field:"enable", name: "*", width: '20px', editable: false, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true};
columntypes[4] = {field:"name", name: "Nombre", editable: false};
columntypes[5] = {field:"name", name: "Nombre", editable: true};
columntypes[6] = {field:"note", name: "Nota" , editable: false};
columntypes[7] = {field:"note", name: "Nota" , editable: true};

switch(t._function)
{
case 1:
// Columnas para grupos por idcontact
cols.push(columntypes[0]);
cols.push(columntypes[1]);
cols.push(columntypes[2]);
cols.push(columntypes[4]);
cols.push(columntypes[6]);
  t._url_load = 'fun_view_contacts_groups_xml.usms';
  break;
//case 2:
//  execute code block 2
//  break;
default:
  t._url_load = 'fun_view_groups_xml.usms';
cols.push(columntypes[0]);
cols.push(columntypes[3]);
cols.push(columntypes[5]);
cols.push(columntypes[7]);
}

		t.Gridx.setColumns(cols);
t.Gridx.autoUpdate = true;
t.Gridx.startup();
//console.log('Columnas ok');
},
delete: function(){
var t = this;
if(t._function == 0){
R.post('fun_groups_remove_selected_xml.usms', {
   handleAs: "xml",
data: {idgroups: t.Gridx.RowSelected.toString()}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
console.log({message: xmld.getStringFromB64(0, 'outpgmsg')});
//MH.notification.notify({message: xmld.getStringFromB64(0, 'outpgmsg')});
}
//LoadGrid();
}, function(error){
//MH.notification.notify({message: error});
});
}
},
save: function(item){

R.post('fun_groups_edit_xml_from_hashmap.usms', {
   handleAs: "xml",
data: {idgroup: item.idgroup,  enable: item.enable, name: item.name, note: item.note}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
console.log(xmld.getStringFromB64(0, 'outpgmsg'));
//MH.notification.notify({message: xmld.getStringFromB64(0, 'outpgmsg')});
}
}, function(error){
//MH.notification.notify({message: error});
});

},
save_contact_group: function(item){

R.post('fun_contact_change_groups_xml.usms', {
   handleAs: "xml",
data: {idgroup: item.idgroup,  belong: item.belong, idcontact: item.idcontact}
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
console.log(xmld.getStringFromB64(0, 'outpgmsg'));
//MH.notification.notify({message: xmld.getStringFromB64(0, 'outpgmsg')});
}
t.load();
}, function(error){
//MH.notification.notify({message: error});
});

},
load: function (){

var t = this;

   R.post(t._url_load, {
            // Parse data from xml
	data:  {idcontact: t._idcontact},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i+1,
idgroup: d.getNumber(i, "idgroup"),
idcontact: d.getNumber(i, "idcontact"),
name: d.getStringFromB64(i, "name"),
note: d.getStringFromB64(i, "note"),
enable: d.getBool(i, "enable"),
belong: d.getBool(i, "belong")
//ts: d.getString(i, "ts")
};
i++;
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
var st = t.Gridx.store;
st.clearOnClose = true;
	st.data = data;
	st.close();
		t.Gridx.store = null;
		t.Gridx.setStore(st);
t.Gridx.resize();
},
clear: function(){
this._setData({identifier: "unique_id", items: []});
},
_setRowsAttr: function(r){
this._rows = r;
},
_getRowsAttr: function(){
return t._rows;
},
_setFunctionAttr: function(f){
this._function = f;
this.columns();
},
_getFunctionAttr: function(){
return t._function;
},
_setIdcontactAttr: function(id){
this._idcontact = id;
this.load();
},
_getIdcontactAttr: function(){
return t._idcontact;
},
_setPagesizeAttr: function(z){
this.Gridx.pagination.setPageSize(z);
},
_setColumnsAttr: function(_c){
this.columns(_c);
},
resize: function(){
return this.Gridx.resize();
}


   
});
});
