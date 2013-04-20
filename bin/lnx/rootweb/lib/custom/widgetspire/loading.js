define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./loading.html',
'dojo/dom-style',
'dojo/_base/fx'
],function(declare,_Widget,_Templated,templateString, domStyle, fx){

 return declare('widgetspire.loading',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){

},

HideShow: function(idNode){
var t = this;
//idNode es el id del nodo que esta bajo elste widget y que será mostrado
domStyle.set(idNode, "display", "block");
domStyle.set(idNode, "width", "100%");
domStyle.set(idNode, "height", "100%");
  fx.fadeOut({node: t.domNode}).play();
}

   
});
});
