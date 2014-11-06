define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_gridx_eventtypes/_usaga_gridx_eventtypes.html',
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
	_editable: false,
postCreate: function(){

var t = this;

	if (t.Gridx) {

jsGridx.addItemSelection(t.Gridx);
dojo.connect(t.Gridx.store, 'onSet', function(item, attribute, oldValue, newValue){
t._save(item);
});

	t.columns();
	t.Gridx.pagination.setPageSize(25);
t.clear();
}
},
columns: function(_c){
var t = this;
var cols = [];

cols.push({field:"unique_id", name: "#", width: '20px'});

if(_c && _c.ideventtype){
cols.push({field:"ideventtype", name: "id", width: '20px'});
}

cols.push({field:"label", name: "Etiqueta", editable: t._editable});

if(_c && _c.name){
cols.push({field:"name", name: "enum"});
}

if(_c && _c.priority){
cols.push({field:"priority", name: "Prioridad", editable: t._editable});
}

if(_c && _c.manual){
if(t._editable){
cols.push({field:"manual", name: "manual" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'});
}else{
cols.push({field:"manual", name: "manual" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: 'true'});
}
}

if(_c && _c.treatment){
if(t._editable){
cols.push({field:"treatment", name: "Tratamiento" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'});
}else{
cols.push({field:"treatment", name: "Tratamiento" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: 'true'});
}
}

if(_c && _c.enable_datetime){
if(t._editable){
cols.push({field:"enable_datetime", name: "Fecha Manual" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'});
}else{
cols.push({field:"enable_datetime", name: "Fecha Manual" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: 'true'});
}
}


if(_c && _c.na_timeout){
cols.push({field:"na_timeout", name: "Tiempo", editable: t._editable});
}

if(_c && _c.na_closable){
if(t._editable){
cols.push({field:"na_closable", name: "closable" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'});
}else{
cols.push({field:"na_closable", name: "closable" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: 'true'});
}
}

if(_c && _c.na_img){
cols.push({field:"na_img", name: "Imagen", editable: t._editable});
}

if(_c && _c.na_snd){
cols.push({field:"na_snd", name: "Sonido", editable: t._editable});
}

if(_c && _c.accountdefault){
if(t._editable){
cols.push({field:"accountdefault", name: "accountdefault" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'});
}else{
cols.push({field:"accountdefault", name: "accountdefault" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: 'true'});
}
}

if(_c && _c.groupdefault){
if(t._editable){
cols.push({field:"groupdefault", name: "groupdefault" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBoolean, alwaysEditing: 'true'});
}else{
cols.push({field:"groupdefault", name: "groupdefault" ,  editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: 'true'});
}
}

if(_c && _c.note){
cols.push({field:"note", name: "nota" , editable: t._editable});
}

		t.Gridx.setColumns(cols);
//t.Gridx.autoUpdate = true;
t.Gridx.startup();
},
_save: function(item){
var t = this;
console.log(item)
   R.post('fun_eventtypes_edit_xml.usaga', {
		data: {ideventtype: item.ideventtype, label: item.label, priority: item.priority, note: item.note, accountdefault: item.accountdefault, groupdefault: item.groupdefault, manual: item.manual, treatment: item.treatment, enable_datetime: item.enable_datetime, na_timeout: item.na_timeout, na_closable: item.na_closable, na_snd: item.na_snd, na_img: item.na_img},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){

var d = new RXml.getFromXhr(response, 'row');

if(d.length > 0){

console.log(d.getStringFromB64(0, 'outpgmsg'));
t.emit('notify_message', {message: d.getStringFromB64(0, 'outpgmsg')}); 

id = d.getInt(0, "outreturn");
if(id>0){
t.load(id);
}else{
t._resetall();
}

}

                },
                function(error){
                    // Display the error returned
t._resetall();
t.load();
//console.log(errorx);
t.emit('notify_message', {message: errorx}); 
                }
            );


},
_getItemselectedAttr: function(){
return this.Gridx.ItemSelected;
},
load: function (){

var t = this;

   R.get('fun_view_eventtypes_xml.usaga', {
            // Parse data from xml
	query: {},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){
myData.items[i] = {
unique_id: i,
ideventtype: d.getNumber(i, "ideventtype"),
name: d.getStringFromB64(i, "name"),
label: d.getStringFromB64(i, "label"),
priority: d.getNumber(i, "priority"),
accountdefault: d.getBool(i, "accountdefault"),
groupdefault: d.getBool(i, "groupdefault"),
manual: d.getBool(i, "manual"),
enable_datetime: d.getBool(i, "enable_datetime"),
na_timeout: d.getNumber(i, "na_timeout"),
na_closable: d.getBool(i, "na_closable"),
na_img: d.getStringFromB64(i, "na_img"),
na_snd: d.getStringFromB64(i, "na_snd"),
treatment: d.getBool(i, "treatment"),
note: d.getStringFromB64(i, "note")
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
_setEditableAttr: function(edit){
this._editable = edit;
},
_getEditableAttr: function(){
return t._editable;
},
resize: function(){
return this.Gridx.resize();
}

   
});
});
