define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_account_contacts_gridx/_usaga_account_contacts_gridx.html',
"dojo/request",
"jspire/request/Xml",
"jspire/Gridx",
'dijit/form/CheckBox',
'dojo/_base/array',
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
],function(declare,_Widget,_Templated,templateString, R, RXml, jsGridx, CBox, array){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
	_idaccount: 0,
	selected: [],
postCreate: function(){

var t = this;

	if (t.Gridx) {
//Esta fila habilita que aparezca la columna idaccount
	t.columns();
	t.Gridx.pagination.setPageSize(25);
// Captura el evento cuando se hace click en una fila
dojo.connect(t.Gridx, 'onRowClick', function(event){
var d = this.cell(event.rowId, 1, true).data();
t.Gridx.store.fetch({query: {unique_id: d}, onItem: function(item){
t.emit('rowclicked', item);
}});
});



dojo.connect(t.Gridx.select.row, 'onSelectionChange', function(_selected){
t.selected = [];
array.forEach(_selected, function(entry, i){
t.Gridx.store.fetch({query: {unique_id: entry}, onItem: function(item){
t.selected.push(item.idcontact[0]);
} 
});
  });
});

t.clear();

}

},
columns: function(_c){
	var t = this;
	var cols = [
			{field:"unique_id", name: "#", width: '20px'},
			{field:"enable_as_contact", name: "*", width: '20px', editor: CBox, editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true},
			{field:"priority", name: "priority", width: '20px'},
			{field:"name", name: "nombre", width: '150px'},
			{field:"appointment", name: "Designacion"}
		];
	this.Gridx.setColumns(cols);
	this.Gridx.autoUpdate = true;
	this.Gridx.startup();
//console.log('Columnas ok');
},
load: function (idaccount_){
var t = this;
t._idaccount = idaccount_;
t.selected = [];

   R.get('getaccountcontactsgrid.usaga', {
            // Parse data from xml
	query: {idaccount: t._idaccount},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id: i+1,
idcontact: d.getNumber(i, "idcontact"), 
idaccount: d.getNumber(i, "idaccount"), 
enable_as_contact: d.getBool(i, "enable"),
priority: d.getNumber(i, "prioritycontact"),    
name: d.getStringFromB64(i, "lastname")+' '+d.getStringFromB64(i, "firstname"),
appointment: d.getStringFromB64(i, "appointment")
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
ApplyNotifyToSelection: function(idaccount_, call_, sms_, msg_){
var t = this;
//console.log(t.selected);
if(t.selected.length>0){
   R.post('notifyeditselectedcontacts.usaga', {
		data: {idaccount: idaccount_, idcontacts: t.selected.toString(), call: call_, sms: sms_, msg: msg_},
            handleAs: "xml"
        }).then(
                function(response){

var d = new RXml.getFromXhr(response, 'row');

if(d.length > 0){
t.emit('notify_message', {message: d.getStringFromB64(0, 'outpgmsg')}); 
}

t.emit('oncontactnotifychanged', {}); 
                },
                function(error){
                    // Display the error returned
t.emit('notify_message', {message: error}); 
                }
            );

}else{
t.emit('notify_message', {message: 'No hay contactos seleccionados para aplicar los cambios'});
}

},
_setIdaccountAttr: function(id_){
//this.emit('onaccountchanged', {idaccounts: ids});
this.load(id_);
},
_getIdaccountsAttr: function(){
return t._idaccount;
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
