define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_basic_button_action_confirm/_common_basic_button_action_confirm.html',
'_common_tooltipdialogconfirmation/_common_tooltipdialogconfirmation'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
postCreate: function(){
var t = this;
t.dialogdelete.dijitOwner(t.Button, 'Click').on('onok', function(){
t.emit('onclick', {});
});
}





   
});
});
