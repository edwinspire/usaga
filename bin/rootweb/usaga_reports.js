/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready",
"dojo/dom-style",
"dojo/window",
"dojo/on",
"jspire/Gridx",
'dojo/request',
'jspire/request/Xml',
"jspire/form/DateTextBox",
'jspire/form/FilteringSelect',
	'gridx/modules/Focus',
	'gridx/modules/CellWidget',
	'gridx/modules/Edit',
	"gridx/modules/RowHeader",
	"gridx/modules/select/Row",
	"gridx/modules/IndirectSelect",
	"gridx/modules/extendedSelect/Row",
	"gridx/modules/VirtualVScroller",
"dijit/form/CheckBox",
"dijit/popup"
], function(ready, domStyle, dojoWindow, dojoOn, jsGridx, R, RXml, jsDateTextBox, jsFS) {
	ready(function() {
	
var FormFilter = dojo.byId("idFormFilter");
var AccountFilter = dijit.byId('idAccountFilter');
var AccountsInput = dojo.byId('idAccountsInput');
var InputStart = dojo.byId('idInputStart');
var InputEnd = dojo.byId('idInputEnd');
var Eventtypes = dojo.byId('idEventtypes');

var DateFilter = dijit.byId('idDateFilter');
DateFilter.hidden_button(true);
DateFilter.hidden_rows(true);

var EvenTypesFilter = dijit.byId('idEvenTypesFilter');
EvenTypesFilter.load();

//console.log(accountsInput);

dijit.byId('idLoad_Events').on('Click', function(){
console.log('Click -> Load');
});	
	
dijit.byId('idView_Report').on('Click', function(){
console.log(AccountFilter.get('itemselected'));
dt = DateFilter.get('value');
console.log(dt);
AccountsInput.value = objectToArray(AccountFilter.get('itemselected'), 'idaccount');
Eventtypes.value = objectToArray(EvenTypesFilter.get('itemselected'), 'ideventtype');
InputStart.value = dt.From;
InputEnd.value = dt.To;
FormFilter.submit();
});	
	
function objectToArray(o, key_){
var r = [];
dojo.forEach(o, function(entry, i){
//    alert(entry[key_]);
    r.push(entry[key_]);
    
  });
return r;
}	

	}
	);
}
);
