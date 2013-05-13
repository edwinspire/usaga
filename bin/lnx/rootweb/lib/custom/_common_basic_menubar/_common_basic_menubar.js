define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_basic_menubar/_common_basic_menubar.html',
'_common_tooltipdialogconfirmation/_common_tooltipdialogconfirmation',
'dijit/ToolbarSeparator'
],function(declare,_Widget,_Templated,templateString){

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

},
addButton: function(label_, iconClass_, separatorBefore, separatorAfter){

if(separatorBefore){
this.idtoolbar.addChild(new ToolbarSeparator());
}

var b = new dijit.form.Button({label: label_});
b.iconClass = iconClass_;
this.idtoolbar.addChild(b);

if(separatorAfter){
this.idtoolbar.addChild(new ToolbarSeparator());
}

return b;
}






   
});
});
