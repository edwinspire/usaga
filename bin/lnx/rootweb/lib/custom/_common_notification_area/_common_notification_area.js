define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_notification_area/_common_notification_area.html',
"dojo/dom-construct",
"dojo/dom-style"
],function(declare,_Widget,_Templated,templateString, domConstruct, domStyle){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

},
setText: function(t){
 var node = domConstruct.create("span");
node.innerHTML = '<div data-dojo-attach-point="notify_" style="opacity:0.75; filter:alpha(opacity=75);  margin: 3px; border: 1px solid #FF8635; border-radius: 6px; -moz-border-radius: 6px; width: 206px; background-color: transparent; background-image: -webkit-gradient(linear, left top, left bottom, from(white), to(#f3b71f)); background-image: -o-linear-gradient(white, #f3b71f); background-image: -ms-linear-gradient(white, #f3b71f); background-image: -moz-linear-gradient(white, #f3b71f); background-image: -webkit-linear-gradient(white, #f3b71f); background-image: linear-gradient(white, #f3b71f); text-align: center; height: auto;">     <label style="color: #553204;">'+t+'</label>   </div>';

  domConstruct.place(node, this.container);

setTimeout(function(){
dojo.destroy(node);
}, 15000);

//   <div id="notify" style="border: 1px solid black; border-radius: 6px; -moz-border-radius: 6px;">fjffjfjjf</div>
}   







   
});
});
