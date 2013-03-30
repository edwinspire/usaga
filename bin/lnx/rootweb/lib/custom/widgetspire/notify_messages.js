define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./notify_messages.html',
"dojo/dom-construct",
"dojo/dom-style"
],function(declare,_Widget,_Templated,templateString, domConstruct, domStyle){

 return declare('widgetspire.notify_messages',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

},
setText: function(t){
 var node = domConstruct.create("div");
domStyle.set(node, {
      backgroundColor: "white",
      border: "1px solid black",
      margin: "0.5em",
      textAlign: "right"
    });


node.innerHTML = t;

  domConstruct.place(node, this.container);

setTimeout(function(){
dojo.destroy(node);
}, 10000);

//   <div id="notify" style="border: 1px solid black; border-radius: 6px; -moz-border-radius: 6px;">fjffjfjjf</div>
}   








});
});
