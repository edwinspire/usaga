define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_gridx_events/_usaga_gridx_events.html',
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
	_idaccounts: 0,
	_start: '1999-01-01',
	_end: null,
	_rows: 200,
	_lastid: 0,
	_ymd: 0,
	_function: -10,
	_busy: false,
	_bgColor: new Array(),
postCreate: function(){

var t = this;

	if (t.Gridx) {

//Esta fila habilita que aparezca la columna idaccount
	t.columns();
	t.Gridx.pagination.setPageSize(25);
// Captura el evento cuando se hace click en una fila
dojo.connect(t.Gridx, 'onRowClick', function(event){
var d = this.cell(event.rowId, 1, true).data();
//console.log(d);
t.Gridx.store.fetch({query: {unique_id: d}, onItem: function(item){
t.emit('oneventclick', item);
}});
});

t.clear();

}
/*
t._bgColor[0] = 'background: linear-gradient(to right, rgba(255,25,25,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[1] = 'background: linear-gradient(to right, rgba(255,64,13,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[2] = 'background: linear-gradient(to right, rgba(255,128,26,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[3] = 'background: linear-gradient(to right, rgba(255,191,38,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[4] = 'background: linear-gradient(to right, rgba(255,255,51,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[5] = 'background: linear-gradient(to right, rgba(191,230,38,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[6] = 'background: linear-gradient(to right, rgba(128,204,26,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[7] = 'background: linear-gradient(to right, rgba(64,179,13,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[8] = 'background: linear-gradient(to right, rgba(0,153,0,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[9] = 'background: linear-gradient(to right, rgba(64,179,64,1) 0%,rgba(125,185,232,0) 100%); ';
t._bgColor[100] = 'background: linear-gradient(to right, rgba(128,204,128,1) 0%,rgba(125,185,232,0) 100%); ';
*/
},
columns: function(_c){
var t = this;
var cols = [];
cols.push({field:"idevent", name: "id", width: '25px'});
if(_c && _c.dateload){
cols.push({field:"dateload", name: "dateload", width: '95px'});
}
cols.push({field:"datetimeevent", name: "Fecha", width: '95px', class: function(cell){
var b = "";
var fx = 0;
var p = false;

if(cell.data() === undefined){

}else{

f = new Date(cell.data());
fy = f.getUTCFullYear()*10000;
fm = f.getUTCMonth()*100;
fd = f.getUTCDate();

fx = t._ymd - (fy+fm+fd);
//console.log(n+''+(ny+nm+nd)+' >> '+(fy+fm+fd));

if(fd % 2 == 0) {
    p = true;
  }
}


if(fx > 0){
	
if(p){
b = 'levelbg2';
}else{
b = 'levelbg4';
}


}else if(fx == 0){
b = 'levelbg10';
}else{
	b = b+'';
}

return b;
}, decorator: function(v){
var r = v;
if(v){
r = v.toUTCString();
}
return r;
}});


if(_c && _c.idaccount){
cols.push({field:"idaccount", name: "idaccount", width: '50px'});
}
if(_c && _c.partition){
cols.push({field:"partition", name: "partition", width: '40px'});
}
if(_c && _c.enable){
cols.push({field:"enable", name: "enable", width: '40px', editable: true, editor: "dijit.form.CheckBox", editorArgs: jsGridx.EditorArgsToCellBooleanDisabled, alwaysEditing: true});
}

if(_c && _c.account){
cols.push({field:"account", name: "account", width: '50px'});
}

if(_c && _c.name){
cols.push({field:"name", name: "name"});
}



cols.push({field:"code", name: "code", width: '25px'});
cols.push({field:"zu", name: "zu", width: '15px'});
cols.push({field:"eventtype", name: "Tipo Evento", width: '80px'});
cols.push({field:"priority", name: "P",  width: '25px', class: function(cell){

var b;
try{
	b = 'levelbg'+cell.data();
}catch(error){
	b = '';
}
//console.log(b);
return b;

/*
var b;
try{
	b = t._bgColor[cell.data()-1];
}catch(error){
	b = '';
}
return 'text-align: center; '+b;*/
}});


cols.push({field:"description", name: "description"});
if(_c && _c.ideventtype){
cols.push({field:"ideventtype", name: "ideventtype", width: '40px'});
}

cols.push({field:"last_comment_time", name: "Ultimo Comentario", width: '10%', class: function(cell){
var b = '';
var time = cell.data();

if(time > 0){
time = Math.round(time/120);
}

console.log(cell.data()+' t '+time);

if(time>=0 && time < 2){
b = 'levelbg10';
}else if(time>=2 && time < 3){
b = 'levelbg9';
}else if(time>=3 && time < 4){
b = 'levelbg8';
}else if(time>=4 && time < 5){
b = 'levelbg7';
}else if(time>=5 && time < 6){
b = 'levelbg6';
}else if(time>=6 && time < 7){
b = 'levelbg5';
}else if(time>=7 && time < 8){
b = 'levelbg4';
}else if(time>=8 && time < 9){
b = 'levelbg3';
}else if(time>=9 && time < 10){
b = 'levelbg2';
}else if(time >= 10){
b = 'levelbg1';
}





/*
if(time>=0 && time < 480){
	b = t._bgColor[100];
}else if(time >= 480 && time <= 1440){
	b = t._bgColor[2];
}else if(time > 1440){
	b = t._bgColor[0];
}
*/
return b;}, decorator: function(v){
var r = 'Hace ';
if(v<0){
r = 'Nunca';
}else if(v>1440){
r = r+' '+Math.round(v/(60*24))+' dias';
}else if(v>60){
r = r+' '+Math.round(v/60)+' horas';
}else{
r = r+' '+v+' minutos';
}

return r;
}});


		this.Gridx.setColumns(cols);
this.Gridx.autoUpdate = true;
this.Gridx.startup();
//console.log('Columnas ok');
},
load: function (){

var t = this;

	if(!t._busy){
t._busy = true;
var end_ = null;

if(!t._end){
d_ = new Date();
end_ = d_.getFullYear()+'-'+(d_.getMonth()+1)+'-'+d_.getDate()+' 23:59';
}
var data_send = {idaccounts: t._idaccounts, start: t._start, end: end_, rows: t._rows, f: t._function};
//console.log('******* load events *******');
   R.get('fun_view_events_xml.usaga', {
            // Parse data from xml
	query: data_send,
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

n = new Date();
ny = n.getFullYear()*10000;
nm = n.getMonth()*100;
nd = n.getDate();

t._ymd = ny+nm+nd;

var myData = {identifier: "unique_id", items: []};

var i = 0;
var idx = 0;

while(i<numrows){

idx = d.getNumber(i, "idevent");
myData.items[i] = {
unique_id: idx,
idevent: idx, 
dateload: d.getString(i, "dateload"),
datetimeevent: d.getDate(i, "datetimeevent"),
idaccount: d.getNumber(i, "idaccount"),
partition: d.getNumber(i, "partition"),
enable: d.getBool(i, "enable"),
account: d.getStringFromB64(i, "account"),
name: d.getStringFromB64(i, "name"),
code: d.getStringFromB64(i, "code"),
zu: d.getNumber(i, "zu"),
priority: d.getNumber(i, "priority"),
description: d.getStringFromB64(i, "description"),
ideventtype: d.getNumber(i, "ideventtype"),
eventtype: d.getStringFromB64(i, "eventtype"),
last_comment_time: d.getInt(i, "last_comment_time")
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
}else{
console.log('<< Grid USAGA Events is Busy!>>');
}

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
t._busy = false;
},
clear: function(){
this._setData({identifier: "unique_id", items: []});
},
_setIdaccountsAttr: function(ids){
this.emit('onaccountschanged', {idaccounts: ids});
this._idaccounts = ids;
this.load();
},
_getIdaccountsAttr: function(){
return t._idaccounts;
},
_setStartAttr: function(s){
this._start = s;
},
_getStartAttr: function(){
return t._start;
},
_setEndAttr: function(s){
this._end = s;
},
_getEndAttr: function(){
return t._end;
},
_setRowsAttr: function(r){
this._rows = r;
},
_getRowsAttr: function(){
return t._rows;
},
_setFunctionAttr: function(f){
this._function = f;
},
_getFunctionAttr: function(){
return t._function;
},
_setPagesizeAttr: function(z){
this.Gridx.pagination.setPageSize(z);
},
_setColumnsAttr: function(_c){
this.columns(_c);
},
resize: function(){
return this.Gridx.resize();
},
parameters: function(_p){
var t = this;
t._idaccounts = _p.idaccounts;
t._start = _p.startDate;
t._end = _p.endDate;
t._rows = _p.rows;
t.load();
}






   
});
});
