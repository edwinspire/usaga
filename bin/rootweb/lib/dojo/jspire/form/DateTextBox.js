//>>built
define("jspire/form/DateTextBox",["dojo/_base/declare", "dojo/date/locale"],function(_1, _2){

var _x = {
// Agrega la funcion _getDate a un dijit.form.DateTextBox  para obtener la fecha de forma mas sencilla, el patron de fecha fabrica es yyyy-MM-dd
addGetDateFunctionArgs: function(datetextbox, datePattern, selector){
datetextbox._datePattern = datePattern;
datetextbox._selector = selector;
datetextbox._getDate = function(){
//console.log('FromTB = '+datetextbox.get('value'));
return _2.format(datetextbox.get('value'), {datePattern: datetextbox._datePattern, selector: datetextbox._selector});
},
datetextbox._toISOString = function(){
return datetextbox.get('value').toISOString();
},
datetextbox.toISOString = function(){
var patt1=/[0-9|-]+/i;
return datetextbox._toISOString().match(patt1);
}
return datetextbox;
},
addGetDateFunction: function(datetextbox){
return this.addGetDateFunctionArgs(datetextbox, "yyyy-MM-dd", "date");
},


addSetDateFunction: function(datetextbox){
datetextbox._setDate = function(date_){
datetextbox.set('value', date_);
return datetextbox;
}

}


}

return _x;
});
