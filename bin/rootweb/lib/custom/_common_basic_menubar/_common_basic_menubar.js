define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_basic_menubar/_common_basic_menubar.html',
'dijit/ToolbarSeparator',
'_common_tooltipdialogconfirmation/_common_tooltipdialogconfirmation'
],function(declare,_Widget,_Templated,templateString, TBS, TTDC){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
enable: true,
postCreate: function(){

var t = this;
t.dialogdelete.dijitOwner(t.delete, 'Click').on('onok', function(){

if(t.enable){
t.emit('ondelete', {});
} 
});
t.new.on('Click', function(){
t.emit('onnew', {}); 
});
t.save.on('Click', function(){
t.emit('onsave', {}); 
});

//this.addButton('Borrar', 'dijitIconSave', true, false, false);

},
addButton: function(label_, iconClass_, confirm_, _message, separatorBefore, separatorAfter){
var t = this;
if(separatorBefore){
t.idtoolbar.addChild(new TBS());
}

var b = new dijit.form.Button({label: label_});
b.iconClass = iconClass_;
t.idtoolbar.addChild(b);

if(confirm_){
var c = new TTDC();
//TODO Esta linea aun esta por confirmar si no produce problema, antes funcionaba sin esta linea.
// Existe un problema, que el elemento no emite los Click como deberia hacerlo
t.DivMaster.addChild(c);

if(_message.length > 0){
c.innerHTML(_message);
}

c.dijitOwner(b, 'Click').on('onok', function(){
b.emit('onok', {});
});
}

if(separatorAfter){
t.idtoolbar.addChild(new TBS());
}

return b;
},
deleteButton: function(_button){
dojo.destroy(_button.domNode);
},
deleteButtonNew: function(){
this.deleteButton(this.new);
},
deleteButtonSave: function(){
this.deleteButton(this.save);
},
deleteButtonDelete: function(){
this.deleteButton(this.delete);
},
deleteAll: function(){
dojo.empty(this.idtoolbar.domNode);
}








   
});
});
