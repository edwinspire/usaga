define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_tooltipdialogconfirmation/_common_tooltipdialogconfirmation.html',
"dojo/dom-construct",
"dijit/TooltipDialog",
"dijit/popup"
],function(declare,_Widget,_Templated,templateString, domConstruct){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
isOpen: false,
owner: '',
innerHTML: function(content){
this.contentdiv.innerHTML = content;
// Aplicamos un parser para que los id de los elementos puedan ser accesibles.
dojo.parser.parse(this.domNode);
this.startup();
return this;
},
addNodeContent: function(n){
domConstruct.place(n, this.contentdiv);
dojo.parser.parse(this.domNode);
this.startup();
},
postCreate: function(){
    // Get a DOM node reference for the root of our widget
//var domNode = this.domNode;
var t = this;
// Inserta un texto de fabrica
t.innerHTML('<div style="width: 100px;"><label>Est&aacute; seguro que desea realizar esta acci&oacute;n?</label></div>');

t.byes.on('Click', function(e){
t.emit('onok', e);
console.log('onok');
t.close();
});

t.bno.on('Click', function(e){
t.emit('onno', e);
t.close();
});


},
close: function(){
dijit.popup.close(this.tooltipdialog);
this.isOpen = false;
return this;
},
open: function(){
var t = this;
            dijit.popup.open({
                popup: t.tooltipdialog,
                around: t.owner.domNode
            });
t.isOpen = true;
return t;
},
// El owner_ es el id del componente que va a utilizar el dialogo
dojoOwner: function(idowner_, onevent){
var o = this;
// Solo funciona con dojo.byId, no funciona con dijit
o.owner = idowner_;
        dojo.connect(o.owner, onevent, function(){
o.open();
});
return o;
},
// El owner_ es el dijit del componente que va a utilizar el dialogo
dijitOwner: function(dijit_, onevent){
var o = this;
// Solo funciona con dijit.byId, no funciona con dojo
o.owner = dijit_;
dijit_.on(onevent, function(){
o.open();
});

return o;
}








    
});
});
