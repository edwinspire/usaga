//>>built
define("jspire/Gridx",["dojo/_base/declare", "jspire/String"],function(_1){

return {

// Requiere los modulos 'gridx/modules/RowHeader', 'gridx/modules/select/Row', 'gridx/modules/extendedSelect/Row', 'gridx/modules/IndirectSelect'
// Tambien debe tener un campo unique_id visible para usarlo como referencia
addRowSelection: function(idgridx, namefiel){

var gridx = dijit.byId(idgridx);
gridx.RowSelected = [];

dojo.connect(gridx.select.row, 'onSelectionChange', function(selected){	
console.log('onSelectionChange');
gridx.RowSelected = [];
numsel = selected.length;
var i = 0;
while(i<numsel){
//console.log(selected[i]);
gridx.store.fetch({query: {unique_id: selected[i]}, onItem: function(item){
gridx.RowSelected[i] = gridx.store.getValue(item, namefiel);
console.log(gridx.RowSelected);
} 
});
i++;
}
});

return gridx;
},


// Requiere los modulos 'gridx/modules/RowHeader', 'gridx/modules/select/Row', 'gridx/modules/extendedSelect/Row', 'gridx/modules/IndirectSelect'
// Tambien debe tener un campo unique_id visible para usarlo como referencia
addItemSelection: function(idgridx){

var gridx = dijit.byId(idgridx);
gridx.ItemSelected = [];

dojo.connect(gridx.select.row, 'onSelectionChange', function(selected){	
console.log(selected);
gridx.ItemSelected = [];
numsel = selected.length;
var i = 0;
while(i<numsel){
gridx.store.fetch({query: {unique_id: selected[i]}, onItem: function(item){
gridx.ItemSelected[i] = item;
console.log(item);
} 
});
i++;
}
});

return gridx;
},

// EditorArgs para una columna booleana de gridx editable, la columna debe usar como editor un checkbox y estar como alwaysEditing: true para que muestre el checkbox
EditorArgsToCellBoolean: {
props: 'value: true',
				fromEditor: function (d){
d1 = d+'';
		return d1.to_boolean();
	},
toEditor: function(storeData, gridData){
r = gridData+'';
return r.to_boolean();

				}
			},

// EditorArgs para una columna booleana de gridx editable, la columna debe usar como editor un checkbox y estar como alwaysEditing: true para que muestre el checkbox, pero no es editable
EditorArgsToCellBooleanDisabled: {
props: 'value: true, disabled: "true"',
				fromEditor: function (d){
d1 = d+'';
		return d1.to_boolean();
	},
toEditor: function(storeData, gridData){
r = gridData+'';
return r.to_boolean();
				}
			}

};
});
