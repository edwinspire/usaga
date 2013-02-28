define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./wlocation.html',
'jspire/form/FilteringSelect',
'dojo/store/Memory',
'dojo/dom-style'
],function(declare,_Widget,_Templated,templateString, jsFS, M, Style){

 return declare('usms.wlocation',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_setLabels: function(l){
var r = 0;
var t = this;
t.labL1.innerHTML = l.L1;
if(r<l.L1.length){
r = l.L1.length;
}

t.labL2.innerHTML = l.L2;
if(r<l.L2.length){
r = l.L2.length;
}

t.labL3.innerHTML = l.L3;
if(r<l.L3.length){
r = l.L3.length;
}

t.labL4.innerHTML = l.L4;
if(r<l.L4.length){
r = l.L4.length;
}

t.labL5.innerHTML = l.L5;
if(r<l.L5.length){
r = l.L5.length;
}

t.labL6.innerHTML = l.L6;
if(r<l.L6.length){
r = l.L6.length;
}
t._setWidth((r*2));
},
_setWidth: function(w){
labs = [];
labs[0] = this.labL1;
labs[1] = this.labL2;
labs[2] = this.labL3;
labs[3] = this.labL4;
labs[4] = this.labL5;
labs[5] = this.labL6;

i = 0;
while(i<6){
//Style.set(labs[i], "margin-right", w+'px');
i++;
}

},
postCreate: function(){

var t = this;
t._setLabels({L1: 'Nivel 1: ', L2: 'Nivel 2:', L3: 'Nivel 3:', L4: 'Nivel 4:', L5: 'Nivel 5:', L6: 'Nivel 6:'});

jsFS.addXmlLoader(t.fsL1, 'fun_view_location_level_xml.usms', 'row', {level: 1}, 'idl1', 'name');
jsFS.addXmlLoader(t.fsL2, 'fun_view_location_level_xml.usms', 'row', {}, 'idl2', 'name');
jsFS.addXmlLoader(t.fsL3, 'fun_view_location_level_xml.usms', 'row', {}, 'idl3', 'name');
jsFS.addXmlLoader(t.fsL4, 'fun_view_location_level_xml.usms', 'row', {}, 'idl4', 'name');
jsFS.addXmlLoader(t.fsL5, 'fun_view_location_level_xml.usms', 'row', {}, 'idl5', 'name');
jsFS.addXmlLoader(t.fsL6, 'fun_view_location_level_xml.usms', 'row', {}, 'idl6', 'name');

t.fsL1.on('Change', function(e){

t._resetfs(t.fsL2);
t._resetfs(t.fsL3);
t._resetfs(t.fsL4);
t._resetfs(t.fsL5);
t._resetfs(t.fsL6);

t.fsL2._Query = {level: 2, idfk: this.get('value')};
t.fsL2.Load();
});

t.fsL2.on('Change', function(e){

t._resetfs(t.fsL3);
t._resetfs(t.fsL4);
t._resetfs(t.fsL5);
t._resetfs(t.fsL6);

t.fsL3._Query = {level: 3, idfk: this.get('value')};
t.fsL3.Load();
});

t.fsL3.on('Change', function(e){

t._resetfs(t.fsL4);
t._resetfs(t.fsL5);
t._resetfs(t.fsL6);

t.fsL4._Query = {level: 4, idfk: this.get('value')};
t.fsL4.Load();
});

t.fsL4.on('Change', function(e){
t._resetfs(t.fsL5);
t._resetfs(t.fsL6);
t.fsL5._Query = {level: 5, idfk: this.get('value')};
t.fsL5.Load();
});

t.fsL5.on('Change', function(e){
t._resetfs(t.fsL6);
t.fsL6._Query = {level: 6,  idfk: this.get('value')};
t.fsL6.Load();
});

this.LoadL1();


    // Get a DOM node reference for the root of our widget
 //   var domNode = this.domNode;
//dojo.parser.parse(this.domNode);
//dojo.require('dojo.store.Memory');

},
_resetfs: function(fs){
Items = [];
Items[0] =  {name: 'Ninguno', id: 0};
fs.store = null;
fs.store = new M({data: Items});
fs.startup();
fs.reset();
},
LoadL1: function(){
this.fsL1.Load();
},
getLocation: function(){
var r = '000000';

var _a = this.fsL1.get('value');
var _b = this.fsL2.get('value');
var _c = this.fsL3.get('value');
var _d = this.fsL4.get('value');
var _e = this.fsL5.get('value');
var _f = this.fsL6.get('value');
r = '1'+_a+_b+_c+_d+_e+_f;

return r;
}








  
});
});
