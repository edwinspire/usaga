define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_add_event_comment/_usaga_add_event_comment.html',
'dojo/request',
'jspire/request/Xml',
"dojo/request/iframe",
"dojo/query",
'dojo/dom-construct',
'dojo/dom-style',
'dijit/Editor',
'dijit/form/Form'
],function(declare,_Widget,_Templated,templateString, R, RXml, iframe, query, domConstruct, domStyle){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
	_Idevent: 0,
	seconds: 0,
	_nidevent: '',
	_ncomment: '',
	_nseconds: '',
	_nidadmin: '',
	_nstatus: '',
	_nfiles: '',
	_mobile: false,
postCreate: function(){

	var t = this;
try{
t._nidevent = domConstruct.create('input', {type: 'hidden', name: 'idevent'}, t.Files.domNode);
t._nidadmin = domConstruct.create('input', {type: 'hidden', name: 'idadmin'}, t.Files.domNode);
t._nseconds = domConstruct.create('input', {type: 'hidden', name: 'seconds'}, t.Files.domNode);
t._ncomment = domConstruct.create('input', {type: 'hidden', name: 'comment'}, t.Files.domNode);
t._nstatus = domConstruct.create('input', {type: 'hidden', name: 'status'}, t.Files.domNode);
domConstruct.place('<label style="margin-right: 3px;">Adjuntos:</label>', t.Files.domNode);
t._nfiles = domConstruct.place('<input type="file" class="dijitButton"  name="attach_usms" value="" multiple></input>', t.Files.domNode);
}
catch(e){
console.log(e);
}


t._configMobile();
/*
  query("#"+t.Files.get("id")+" input").forEach(function(node, index, arr){

console.log(node.name);

switch(node.name){

case 'idevent':
	t._nidevent = node;
break;
case 'comment':
	t._ncomment = node;
break;
case 'seconds':
	t._nseconds = node;
break;
case 'idadmin':
	t._nidadmin = node;
break;
case 'status':
	t._nstatus = node;
break;
case 'attach_usms':
	t._nfiles = node;
break;
}


  });
*/

	t._disableButtons(true);

	t.Save.on('click', function(){
		t._save_with_files(0);
	});


	t.SaveEnd.on('click', function(){
		t._save_with_files(1);
	});


	t.Start.on('click', function(){
		if(t._Idevent>0){
		t._disableButtons(false);
		t.seconds = 0;
		}
	});

	t.CancelComment.on('click', function(){
		t._disableButtons(true);
		t.seconds = 0;
	});

var timecomment = setInterval(function(){
if(!t.Save.get('disabled')){
t.seconds++;
t.Start.set('label', 'Iniciado ('+t.seconds+' seg)');
}else{
t.Start.set('label', 'Iniciar');
}
},1000);


},
_save_with_files: function(_status){
var t = this;
	t._nidevent.value = t._Idevent;
	t._nseconds.value = t.seconds;
if(t._mobile){
	t._ncomment.value = t.OnlyMobileComment.get('value');
}else{
	t._ncomment.value = t.Editorx.get('value').trim();
}


	t._nidadmin.value = 0;
	t._nstatus.value = _status;

    console.log('Enviando archivos.....');

    iframe("/php/fun_event_comment_insert-xml.php",{	
      form: t.Files.get('id'),
//	data: {edwin: 'hola'},
      handleAs: "xml"
    }).then(function(response){
var d = new RXml.getFromXhr(response, 'row');

if(d.length > 0){
console.log(d.getStringFromB64(0, 'outpgmsg'));

idc = d.getInt(0, "outreturn");

if(idc>0){
t._disableButtons(true);
t.emit('onsavecomment', {idevent: t._Idevent, idcomment: idc}); 
}
}

    });

},
_disableButtons: function(_d){
var t = this;
		t.Save.set('disabled', _d);
		t.SaveEnd.set('disabled', _d);
		t.Editorx.set('disabled', _d);
		t.CancelComment.set('disabled', _d);
		t.OnlyMobileComment.set('disabled', _d);
		t.Editorx.set('value', '');
		t._nfiles.value = '';
		t.Files.reset();
},
   _setIdeventAttr: function(_id){
this.reset();
this._Idevent = _id;
},
_setMobileAttr: function(_m){
this._mobile = _m;
this._configMobile();
},
_configMobile: function(){
var t = this;
if(t._mobile){
//domStyle.set('');
console.log('Version mobil');
domStyle.set(t.Editorx.domNode, 'display', 'none');
domStyle.set(t.OnlyMobileComment.domNode, 'display', 'block');
}else{
domStyle.set(t.Editorx.domNode, 'display', 'block');
domStyle.set(t.OnlyMobileComment.domNode, 'display', 'none');
}
},
reset: function(){
var t = this;
t._disableButtons(true);
t._Idevent = 0;
}




});
});







