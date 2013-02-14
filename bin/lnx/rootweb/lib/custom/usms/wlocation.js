define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!./wlocation.html'
],function(declare,_Widget,_Templated,templateString){

 return declare('usms.wlocation',[ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString ,
postCreate: function(){
    // Get a DOM node reference for the root of our widget
 //   var domNode = this.domNode;
 

/*
    // Run any parent postCreate processes - can be done at any point
    this.inherited(arguments);
 
    // Set our DOM node's background color to white -
    // smoothes out the mouseenter/leave event animations
    dojo.style(domNode, "backgroundColor", this.baseBackgroundColor);
    // Set up our mouseenter/leave events - using dijit._Widget's connect
    // means that our callback will execute with `this` set to our widget
    this.connect(domNode, "onmouseenter", function(e) {
        this._changeBackground(this.mouseBackgroundColor);
    });
    this.connect(domNode, "onmouseleave", function(e) {
        this._changeBackground(this.baseBackgroundColor);
    });
*/
}


  
});
});
