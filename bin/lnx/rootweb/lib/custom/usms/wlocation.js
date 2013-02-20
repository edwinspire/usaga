define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./wlocation.html',
'jspire/form/FilteringSelect',
'dojo/store/Memory'
],function(declare,_Widget,_Templated,templateString, jsFS, M){

 return declare('usms.wlocation',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString ,
postCreate: function(){

var t = this;

jsFS.addXmlLoader(t.fsidcountry, 'fun_view_country_xml.usms', 'row', {}, 'idcountry', 'name');
jsFS.addXmlLoader(t.fsidstate, 'fun_view_state_by_idcountry_xml.usms', 'row', {}, 'idstate', 'name');
jsFS.addXmlLoader(t.fsidcity, 'fun_view_city_by_idstate_xml.usms', 'row', {}, 'idcity', 'name');
jsFS.addXmlLoader(t.fsidsector, 'fun_view_sector_by_idcity_xml.usms', 'row', {}, 'idsector', 'name');
jsFS.addXmlLoader(t.fsidsubsector, 'fun_view_subsector_by_idsector_xml.usms', 'row', {}, 'idsubsector', 'name');

t.fsidcountry.on('Change', function(e){

t._resetfs(t.fsidstate);
t._resetfs(t.fsidcity);
t._resetfs(t.fsidsector);
t._resetfs(t.fsidsubsector);

t.fsidstate._Query = {idcountry: this.get('value')};
t.fsidstate.Load();
});

t.fsidstate.on('Change', function(e){

t._resetfs(t.fsidcity);
t._resetfs(t.fsidsector);
t._resetfs(t.fsidsubsector);

t.fsidcity._Query = {idstate: this.get('value')};
t.fsidcity.Load();
});

t.fsidcity.on('Change', function(e){

t._resetfs(t.fsidsector);
t._resetfs(t.fsidsubsector);

t.fsidsector._Query = {idcity: this.get('value')};
t.fsidsector.Load();
});

t.fsidsector.on('Change', function(e){
t._resetfs(t.fsidsubsector);
t.fsidsubsector._Query = {idsector: this.get('value')};
t.fsidsubsector.Load();
});



this.LoadCountry();


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
LoadCountry: function(){
this.fsidcountry.Load();
},
getLocation: function(){
var r = '000000';

var _a = this.fsidcountry.get('value');
var _b = this.fsidstate.get('value');
var _c = this.fsidcity.get('value');
var _d = this.fsidsector.get('value');
var _e = this.fsidsubsector.get('value');
r = '1'+_a+_b+_c+_d+_e;

return r;
}








  
});
});
