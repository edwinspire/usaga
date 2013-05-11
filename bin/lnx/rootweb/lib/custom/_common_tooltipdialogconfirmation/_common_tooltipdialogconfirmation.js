define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_tooltipdialogconfirmation/_common_tooltipdialogconfirmation.html',
"dijit/TooltipDialog",
"dijit/popup"
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
owner: '',
innerHTML: function(content){
this.contentdiv.innerHTML = content;
// Aplicamos un parser para que los id de los elementos puedan ser accesibles.
dojo.parser.parse(this.domNode);
return this;
},
postCreate: function(){
    // Get a DOM node reference for the root of our widget
//var domNode = this.domNode;

    // Run any parent postCreate processes - can be done at any point
//    this.inherited(arguments);

// Inserta un texto de fabrica
this.innerHTML('<div style="width: 100px;"><label>Est&aacute; seguro que desea realizar esta acci&oacute;n?</label></div>');
 
    this.connect(this.byes, "onClick", function(e) {
this.emit('onok', {});
this.close();
    });
    this.connect(this.bno, "onClick", function(e) {
this.emit('onno', {});
this.close();
    });

},
close: function(){
dijit.popup.close(this.tooltipdialog);
return this;
},
open: function(){
            dijit.popup.open({
                popup: this.tooltipdialog,
                around: this.owner
            });
return this;
},
// El owner_ es el id del componente que va a utilizar el dialogo
setowner: function(idowner_, onevent){
var o = this;
// Solo funciona con dojo.byId, no funciona con dijit
o.owner = dojo.byId(idowner_);
        dojo.connect(o.owner, onevent, function(){
o.open();
});
return o;
}








    
});
});
