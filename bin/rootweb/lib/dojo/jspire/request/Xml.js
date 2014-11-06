//>>built
define("jspire/request/Xml",["dojo/_base/declare", "jspire/String"],function(){

return {

getFromXhr: function (xmldoc, getElementsByTagName){
this.xml = xmldoc,
this.ElementsByTagName = getElementsByTagName,
this.rows = this.xml.getElementsByTagName(this.ElementsByTagName),
this.length = this.rows.length,
this.getValue = function(i, field){
var r = '';
/*if(this.xml){
// Esto lo hacemos asi para evitar problemas cuando los datos no existen, si ese es el caso devuelve una cadena vacia en lugar de null
var _a = this.rows[i].getElementsByTagName(field);
if(_a){
var _b = _a.item(0);
if(_b){
var _c = _b.firstChild;
if(_c){
r = _c.data;
}else{
console.log('No existe firstChild del item(0) del TagName '+field+' en el elemento '+1);
}
}else{
console.log('No existe el item(0) del TagName '+field+' en el elemento '+1);
}
}else{
console.log('No existe el TagName '+field+' en el elemento '+1);
}
}else{
console.log('getFromXhr(xmldoc, getElementsByTagName): xmldoc No está definido');
}*/


try{
r = this.rows[i].getElementsByTagName(field).item(0).firstChild.data;
}
catch(e){
r = '';
//console.log(e);
}

/*
if(this.xml){


// Esto lo hacemos asi para evitar problemas cuando los datos no existen, si ese es el caso devuelve una cadena vacia en lugar de null
var _a = this.rows[i].getElementsByTagName(field);
if(_a){
if(_a.item(0)){
if(_a.item(0).firstChild){
r = _a.item(0).firstChild.data;
}else{
console.log('No existe firstChild del item(0) del TagName '+field+' en el elemento '+1);
}
}else{
console.log('No existe el item(0) del TagName '+field+' en el elemento '+1);
}
}else{
console.log('No existe el TagName '+field+' en el elemento '+1);
}
}else{
console.log('getFromXhr(xmldoc, getElementsByTagName): xmldoc No está definido');
}
*/
return r;
},
this.getBool = function(i, field){
return this.getString(i, field).to_boolean();
},
this.getNumber = function(i, field){
return Number(this.getValue(i, field));
},
this.getInt = function(i, field){
return parseInt(this.getValue(i, field));
},
this.getFloat = function(i, field){
return parseFloat(this.getValue(i, field));
},
this.getString = function(i, field){
return String(this.getValue(i, field));
},
this.getDate = function(i, field){
var x = Date.parse(this.getString(i, field));
return new Date(x);
},
this.getStringFromB64 = function(i, field){
return this.getString(i, field).from_b64();
}
},

getFromXmlStore: function (xmlstore, xmlitems){
this.store = xmlstore,
this.items = xmlitems,
this.lengthItems = this.items.length,
this.getValue = function(i, field){
return this.store.getValue(this.items[i], field);
},
this.getBool = function(i, field){
return this.getString(i, field).to_boolean();
},
this.getNumber = function(i, field){
return Number(this.getValue(i, field));
},
this.getInt = function(i, field){
return parseInt(this.getValue(i, field));
},
this.getFloat = function(i, field){
return parseFloat(this.getValue(i, field));
},
this.getString = function(i, field){
return String(this.getValue(i, field));
},
this.getDate = function(i, field){
var x = Date.parse(this.getString(i, field));
console.log(this.getString(i, field)+' >> '+x)
return new Date(x);
},
this.getStringFromB64 = function(i, field){
return this.getString(i, field).from_b64();
}
}


}
});
