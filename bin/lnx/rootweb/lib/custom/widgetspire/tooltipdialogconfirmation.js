define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./tooltipdialogconfirmation.html',
"dijit/TooltipDialog",
"dijit/popup"
],function(declare,_Widget,_Templated,templateString){

 return declare('widgetspire.tooltipdialogconfirmation',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
owner: '',
postCreate: function(){
    // Get a DOM node reference for the root of our widget
//var domNode = this.domNode;

    // Run any parent postCreate processes - can be done at any point
//    this.inherited(arguments);
 
    // Set up our mouseenter/leave events - using dijit._Widget's connect
    // means that our callback will execute with `this` set to our widget
    this.connect(this.byes, "onClick", function(e) {
//alert('Prsiona ok');
this.emit('onok', {});
this.close();
    });
    this.connect(this.bno, "onClick", function(e) {
//alert('Prsiona no');
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
setowner: function(owner_, onevent){
var o = this;
o.owner = dojo.byId(owner_);
        dojo.connect(dojo.byId(owner_), onevent, function(){
o.open();
});
return o;
}








 
});
});
