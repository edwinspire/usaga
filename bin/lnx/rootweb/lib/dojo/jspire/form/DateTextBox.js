//>>built
define("jspire/form/DateTextBox",["dojo/_base/declare", "dojo/date/locale"],function(_1, _2){

var _x = {
// Obtiene de un dijit.form.DateTextBox la fecha de forma mas sencilla, el patron de fecha fabrica es yyyy-MM-dd
getDateFull: function(datetextbox, datePattern, selector){
return _2.format(datetextbox.get('value'), {datePattern: datePattern, selector: selector});
},
getDate: function(datetextbox){
return this.getDateFull(datetextbox, "yyyy-MM-dd", "date");
}
setDate: function(datetextbox, date){
this.DateTextBox.set('value', date_);
}


}

return _x;
});
