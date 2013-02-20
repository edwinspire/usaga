	/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */

require(["dojo/ready",  
"dojo/on",
"dojo/data/ItemFileWriteStore",
"dojo/request",
	"gridx/Grid",
	"gridx/core/model/cache/Async",
'gridx/modules/Focus',
'gridx/modules/CellWidget',
'gridx/modules/Edit',
"gridx/modules/VirtualVScroller",
"jspire/request/Xml",
"gridx/modules/RowHeader",
"gridx/modules/select/Row",
"gridx/modules/IndirectSelect",
"gridx/modules/extendedSelect/Row",
"dijit/form/TextBox"
], function(ready, on, ItemFileWriteStore, request, Grid, Async, Focus, CellWidget, Edit, VirtualVScroller, RXml){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

var ObjectBase = function(){
this.id= 0,
this.to_delete= [],
this.label= '',
this.title= 'Selección: ',
this.setHeaderLabel= function(country){
this.label.innerHTML = this.title+'['+country+']';
}
}

var Country = new ObjectBase();
Country.title = 'País: ';
Country.label = dojo.byId('labcountry');


        var dcountrydialognew = dijit.byId('countrydialognew');
dcountrydialognew.setowner('newcountry', 'onclick').innerHTML('<form id="countryform">  <table border="0" style="border-collapse: collapse; table-layout: auto; width: 100%; height: 100%;">    <colgroup>      <col></col>      <col></col>    </colgroup>    <tbody>      <tr>       <td>          <label style="margin-right: 3px;">            Nombre:</label>        </td>        <td>         <input type="text" data-dojo-type="dijit.form.TextBox" id="countryname" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="País"></input>       </td>      </tr>      <tr>        <td>          <label style="margin-right: 3px;">            Código:</label>        </td>        <td>         <input type="text" data-dojo-type="dijit.form.TextBox" id="countrycode" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="Código de país"></input>       </td>      </tr>    </tbody>  </table></form>').on('onok', function(){

SaveCountry({idcountry:0, name: dijit.byId('countryname').get('value'), code: dijit.byId('countrycode').get('value')});

dojo.byId('countryform').reset();
});


// Carga los datos al hacer click
dijit.byId('loadcountry').on('Click', function(){
LoadGridCountry();
});

// Elimina los registros seleccionados
        var dcountrydialogdel = dijit.byId('countrydialogdel');
dcountrydialogdel.setowner('delcountry', 'onclick').on('onok', function(){
DeleteCountry();
});


var egridcountry = dijit.byId('gridcountry');
if(egridcountry){
		egridcountry.setColumns([
			{field:"unique_id", name: "#", width: '20px'},
			{field:"name", name: "Nombre", editable: true},
     			{field:"code", name: "Código", editable: true}
		]);
egridcountry.startup();
}


dojo.connect(egridcountry, 'onRowClick', function(event){
d = this.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
StoreCountry.fetch({query: {unique_id: d}, onItem: function(item){
Country.id = StoreCountry.getValue(item, 'idcountry');
Country.setHeaderLabel(StoreCountry.getValue(item, 'name'));
}
});

LoadGridState(); 

});

// Guarda los cambios
dojo.connect(StoreCountry, 'onSet', function(item, attribute, oldValue, newValue){
SaveCountry(item);
});

// Obtiene los ids de los registros que se van a eliminar y los guarda en una matriz
dojo.connect(egridcountry.select.row, 'onSelectionChange', function(selected){
Country.to_delete = [];
numsel = selected.length;
i = 0;

while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
StoreCountry.fetch({query: {unique_id: selected[i]}, onItem: function(item){
Country.to_delete[i] = StoreCountry.getValue(item, 'idcountry');
} 
});
i++;
}
//console.log('Borrar: '+Country.to_delete.toString());
});

// Carga los datos
function LoadGridCountry(){
Country.id = 0;
Country.to_delete = [];
Country.setHeaderLabel('---');
LoadGridState();
            // Request the text file
            request.get("fun_view_country_xml.usms", {
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var myData = {identifier: "unique_id", items: []};

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i+1,
idcountry: d.getNumber(i, "idcountry"),
name: d.getStringFromB64(i, "name"),
code: d.getStringFromB64(i, "code"),
ts: d.getString(i, "ts")
};
i++;
}
StoreCountry.clearOnClose = true;
	StoreCountry.data = myData;
	StoreCountry.close();

		egridcountry.store = null;
		egridcountry.setStore(StoreCountry);
                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );

}

// Guarda los datos
function SaveCountry(item){

request.post('fun_location_country_edit_xml_from_hashmap.usms', {
   handleAs: "xml",
data: item,
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridCountry();
}, function(error){
LoadGridCountry();
alert(error);
});

}

// Guarda los datos
function DeleteCountry(){

request.post('fun_location_country_remove_selected_xml.usms', {
   handleAs: "xml",
data: {ids: Country.to_delete.toString()},
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridCountry();
}, function(error){
LoadGridCountry();
alert(error);
});

}






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var State = new ObjectBase();
State.title = 'Estado / Provincia: ';
State.label = dojo.byId('labstate');


        var dstatedialognew = dijit.byId('statedialognew');
dstatedialognew.setowner('newstate', 'onclick').innerHTML('<form id="stateform">  <table border="0" style="border-collapse: collapse; table-layout: auto; width: 100%; height: 100%;">    <colgroup>      <col></col>      <col></col>    </colgroup>    <tbody>      <tr>        <td>          <label style="margin-right: 3px;">            Nombre:</label>        </td>        <td>         <input type="text" data-dojo-type="dijit.form.TextBox" id="statename" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="Estado / Provincia"></input>       </td>      </tr>      <tr>        <td>          <label style="margin-right: 3px;">            Código:</label>        </td>        <td>         <input type="text" data-dojo-type="dijit.form.TextBox" id="statecode" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="Código de área"></input>       </td>      </tr>    </tbody>  </table></form>').on('onok', function(){
if(Country.id > 0){
SaveState({idcountry: Country.id, name: dijit.byId('statename').get('value'), code: dijit.byId('statecode').get('value')});
}else{
alert('No hay un país seleccionado');
}
dojo.byId('stateform').reset();
});

// Elimina los registros seleccionados
        var dstatedialogdel = dijit.byId('statedialogdel');
dstatedialogdel.setowner('delstate', 'onclick').on('onok', function(){
DeleteState();
});


var egridstate = dijit.byId('gridstate');
if(egridstate){
		egridstate.setColumns([
			{field:"unique_id", name: "#", width: '20px'},
			{field:"name", name: "Nombre", editable: true},
     			{field:"code", name: "Código", editable: true}
		]);
egridstate.startup();
}


// 
dojo.connect(egridstate, 'onRowClick', function(event){
d = this.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
StoreState.fetch({query: {unique_id: d}, onItem: function(item){
State.id = StoreState.getValue(item, 'idstate');
State.setHeaderLabel(StoreState.getValue(item, 'name'));
} 
});
LoadGridCity();
});

// Guarda los cambios
dojo.connect(StoreState, 'onSet', function(item, attribute, oldValue, newValue){
SaveState(item);
});


// Obtiene los ids de los registros que se van a eliminar y los guarda en una matriz
dojo.connect(egridstate.select.row, 'onSelectionChange', function(selected){
State.to_delete = [];
numsel = selected.length;
i = 0;

while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
StoreState.fetch({query: {unique_id: selected[i]}, onItem: function(item){
State.to_delete[i] = StoreState.getValue(item, 'idcountry');
} 
});
i++;
}
//console.log('Borrar: '+Country.to_delete.toString());
});

// Carga los datos
function LoadGridState(){
State.id = 0;
State.to_delete = [];
State.setHeaderLabel('---');
LoadGridCity();
var myData = {identifier: "unique_id", items: []};

if(Country.id > 0){
            // Request the text file
            request.get("fun_view_state_by_idcountry_xml.usms", {
	query: {idcountry: Country.id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i+1,
idcountry: d.getNumber(i, "idcountry"),
idstate: d.getNumber(i, "idstate"),
name: d.getStringFromB64(i, "name"),
code: d.getStringFromB64(i, "code"),
ts: d.getString(i, "ts")
};
i++;
}
StoreState.clearOnClose = true;
	StoreState.data = myData;
	StoreState.close();

		egridstate.store = null;
		egridstate.setStore(StoreState);
                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );
}else{
StoreState.clearOnClose = true;
	StoreState.data = myData;
	StoreState.close();

		egridstate.store = null;
		egridstate.setStore(StoreState);
}
}

// Guarda los datos
function SaveState(item){

request.post('fun_location_state_edit_xml_from_hashmap.usms', {
   handleAs: "xml",
data: item
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridState();
}, function(error){
LoadGridState();
alert(error);
});

}


// Elimina los datos seleccionados
function DeleteState(){

request.post('fun_location_state_remove_selected_xml.usms', {
   handleAs: "xml",
data: {ids: State.to_delete.toString()},
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridState();
}, function(error){
LoadGridState();
alert(error);
});

}



///////////////////////////////////////////////////////////////////////////////////////

var City = new ObjectBase();
City.title = 'Ciudad: ';
City.label = dojo.byId('labcity');


        var dcitydialognew = dijit.byId('citydialognew');
dcitydialognew.setowner('newcity', 'onclick').innerHTML('<form id="cityform">  <table border="0" style="border-collapse: collapse; table-layout: auto; width: 100%; height: 100%;">    <colgroup>      <col></col>      <col></col>    </colgroup>    <tbody>      <tr>        <td>          <label style="margin-right: 3px;">            Nombre:</label>        </td>        <td>         <input type="text" data-dojo-type="dijit.form.TextBox" id="cityname" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="Ciudad"></input>       </td>      </tr>      <tr>        <td>          <label style="margin-right: 3px;">            Código:</label>        </td>        <td>         <input type="text" data-dojo-type="dijit.form.TextBox" id="citycode" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false" placeHolder="Código de área"></input>       </td>      </tr>    </tbody>  </table></form>').on('onok', function(){
if(State.id > 0){
SaveCity({idstate: State.id, name: dijit.byId('cityname').get('value'), code: dijit.byId('citycode').get('value')});
}else{
alert('No hay un estado seleccionado');
}

dojo.byId('cityform').reset();
});

var egridcity = dijit.byId('gridcity');
if(egridcity){
		egridcity.setColumns([
			{field:"unique_id", name: "#", width: '15px'},
			{field:"name", name: "Nombre", editable: true},
     			{field:"code", name: "Código", editable: true}
		]);
egridcity.startup();
}

// Elimina los registros seleccionados
        var dcitydialogdel = dijit.byId('citydialogdel');
dcitydialogdel.setowner('delcity', 'onclick').on('onok', function(){
DeleteCity();
});

// 
dojo.connect(egridcity, 'onRowClick', function(event){
d = this.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
StoreCity.fetch({query: {unique_id: d}, onItem: function(item){
City.id = StoreCity.getValue(item, 'idcity');
City.setHeaderLabel(StoreCity.getValue(item, 'name'));
} 
});
LoadGridSector();
});

// Guarda los cambios
dojo.connect(StoreCity, 'onSet', function(item, attribute, oldValue, newValue){
SaveCity(item);
});


// Obtiene los ids de los registros que se van a eliminar y los guarda en una matriz
dojo.connect(egridcity.select.row, 'onSelectionChange', function(selected){
City.to_delete = [];
numsel = selected.length;
i = 0;

while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
StoreCity.fetch({query: {unique_id: selected[i]}, onItem: function(item){
City.to_delete[i] = StoreCity.getValue(item, 'idcity');
} 
});
i++;
}
//console.log('Borrar: '+Country.to_delete.toString());
});

// Carga los datos
function LoadGridCity(){
City.id = 0;
City.to_delete = [];
City.setHeaderLabel('---');
LoadGridSector();
var myData = {identifier: "unique_id", items: []};

if(State.id > 0){
            // Request the text file
            request.get("fun_view_city_by_idstate_xml.usms", {
	query: {idstate: State.id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i+1,
idcity: d.getNumber(i, "idcity"),
idstate: d.getNumber(i, "idstate"),
name: d.getStringFromB64(i, "name"),
code: d.getStringFromB64(i, "code"),
ts: d.getString(i, "ts")
};
i++;
}
StoreCity.clearOnClose = true;
	StoreCity.data = myData;
	StoreCity.close();

		egridcity.store = null;
		egridcity.setStore(StoreCity);
                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );
}else{
StoreCity.clearOnClose = true;
	StoreCity.data = myData;
	StoreCity.close();

		egridcity.store = null;
		egridcity.setStore(StoreCity);
}
}

// Guarda los datos
function SaveCity(item){

request.post('fun_location_city_edit_xml_from_hashmap.usms', {
   handleAs: "xml",
data: item,
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridCity();
}, function(error){
LoadGridCity();
alert(error);
});

}


// Elimina los datos seleccionados
function DeleteCity(){

request.post('fun_location_city_remove_selected_xml.usms', {
   handleAs: "xml",
data: {ids: City.to_delete.toString()},
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridCity();
}, function(error){
LoadGridCity();
alert(error);
});

}




////////////////////////////////////////////////////////////////////////

var Sector = new ObjectBase();
Sector.title = 'Sector: ';
Sector.label = dojo.byId('labsector');

        var dsectordialognew = dijit.byId('sectordialognew');
dsectordialognew.setowner('newsector', 'onclick').innerHTML('<form id="sectorform"> <div>  <label style="margin-right: 3px;">    Nombre:</label>  <input type="text" data-dojo-type="dijit.form.TextBox" id="sectorname" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false"  placeHolder="Sector"></input>  <input style="display:none" type="text" data-dojo-type="dijit.form.TextBox"></input></div> </form>').on('onok', function(){
if(City.id > 0){
SaveSector({idcity: City.id, name: dijit.byId('sectorname').get('value')});
}else{
alert('No hay una ciudad seleccionada');
}

dojo.byId('sectorform').reset();
});
       

var egridsector = dijit.byId('gridsector');
if(egridsector){
		egridsector.setColumns([
			{field:"unique_id", name: "#", width: '15px'},
			{field:"name", name: "Nombre", editable: true}
		]);
egridsector.startup();
}

// Elimina los registros seleccionados
        var dsectordialogdel = dijit.byId('sectordialogdel');
dsectordialogdel.setowner('delsector', 'onclick').on('onok', function(){
DeleteSector();
});

// 
dojo.connect(egridsector, 'onRowClick', function(event){
d = this.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
StoreSector.fetch({query: {unique_id: d}, onItem: function(item){
Sector.id = StoreSector.getValue(item, 'idsector');
Sector.setHeaderLabel(StoreSector.getValue(item, 'name'));
} 
});
LoadGridSubSector();
});

// Guarda los cambios
dojo.connect(StoreSector, 'onSet', function(item, attribute, oldValue, newValue){
SaveSector(item);
});


// Obtiene los ids de los registros que se van a eliminar y los guarda en una matriz
dojo.connect(egridsector.select.row, 'onSelectionChange', function(selected){
Sector.to_delete = [];
numsel = selected.length;
i = 0;

while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
StoreSector.fetch({query: {unique_id: selected[i]}, onItem: function(item){
Sector.to_delete[i] = StoreSector.getValue(item, 'idsector');
} 
});
i++;
}
//console.log('Borrar: '+Country.to_delete.toString());
});

// Carga los datos
function LoadGridSector(){
Sector.id = 0;
Sector.to_delete = [];
Sector.setHeaderLabel('---');
LoadGridSubSector();
var myData = {identifier: "unique_id", items: []};

if(City.id > 0){
            // Request the text file
            request.get("fun_view_sector_by_idcity_xml.usms", {
	query: {idcity: City.id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i+1,
idcity: d.getNumber(i, "idcity"),
idsector: d.getNumber(i, "idsector"),
name: d.getStringFromB64(i, "name"),
ts: d.getString(i, "ts")
};
i++;
}
StoreSector.clearOnClose = true;
	StoreSector.data = myData;
	StoreSector.close();

		egridsector.store = null;
		egridsector.setStore(StoreSector);
                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );
}else{
StoreSector.clearOnClose = true;
	StoreSector.data = myData;
	StoreSector.close();

		egridsector.store = null;
		egridsector.setStore(StoreSector);
}
}

// Guarda los datos
function SaveSector(item){

request.post('fun_location_sector_edit_xml_from_hashmap.usms', {
   handleAs: "xml",
data: item,
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridSector();
}, function(error){
LoadGridSector();
alert(error);
});

}


// Elimina los datos seleccionados
function DeleteSector(){

request.post('fun_location_sector_remove_selected_xml.usms', {
   handleAs: "xml",
data: {ids: Sector.to_delete.toString()},
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridSector();
}, function(error){
LoadGridSector();
alert(error);
});

}



//////////////////////////////////////////////////////////////////////////


var SubSector = new ObjectBase();
SubSector.title = 'SubSector: ';
SubSector.label = dojo.byId('labsubsector');


        var dsubsectordialognew = dijit.byId('subsectordialognew');
dsubsectordialognew.setowner('newsub', 'onclick').innerHTML('<form id="subsectorform">  <div>  <label style="margin-right: 3px;">    Nombre:</label>  <input type="text" data-dojo-type="dijit.form.TextBox" id="subsectorname" intermediateChanges="false" trim="false" uppercase="false" lowercase="false" propercase="false" selectOnClick="false"  placeHolder="Subsector"></input>  <input style="display:none" type="text" data-dojo-type="dijit.form.TextBox"></input></div></form>').on('onok', function(){
if(Sector.id > 0){
SaveSubSector({idsector: Sector.id, name: dijit.byId('subsectorname').get('value')});
}else{
alert('No hay ningun sector cargado');
}
dojo.byId('subsectorform').reset();
});
        
var egridsub = dijit.byId('gridsub');
if(egridsub){
		egridsub.setColumns([
			{field:"unique_id", name: "#", width: '20px'},
			{field:"name", name: "Nombre", editable: true}
		]);
egridsub.startup();
}



// Elimina los registros seleccionados
        var dsubdialogdel = dijit.byId('subdialogdel');
dsubdialogdel.setowner('delsub', 'onclick').on('onok', function(){
DeleteSubSector();
});


/*
// 
dojo.connect(egridsub, 'onRowClick', function(event){
d = this.cell(event.rowId, 1, true).data();
// Aqui buscamos los datos desde el store y no desde la celda.
StoreSubSector.fetch({query: {unique_id: d}, onItem: function(item){
Sector.id = StoreSector.getValue(item, 'idsector');
//console.log(Country.id);
} 
});

});
*/

// Guarda los cambios
dojo.connect(StoreSubSector, 'onSet', function(item, attribute, oldValue, newValue){
SaveSubSector(item);
});


// Obtiene los ids de los registros que se van a eliminar y los guarda en una matriz
dojo.connect(egridsub.select.row, 'onSelectionChange', function(selected){
SubSector.to_delete = [];
numsel = selected.length;
i = 0;

while(i<numsel){
// Aqui buscamos los datos desde el store y no desde la celda.
StoreSubSector.fetch({query: {unique_id: selected[i]}, onItem: function(item){
SubSector.to_delete[i] = StoreSubSector.getValue(item, 'idsubsector');
} 
});
i++;
}
//console.log('Borrar: '+Country.to_delete.toString());
});

// Carga los datos
function LoadGridSubSector(){
SubSector.id = 0;
SubSector.to_delete = [];

var myData = {identifier: "unique_id", items: []};

if(Sector.id > 0){
            // Request the text file
            request.get("fun_view_subsector_by_idsector_xml.usms", {
	query: {idsector: Sector.id},
            // Parse data from xml
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');

numrows = d.length;

var i = 0;
while(i<numrows){

myData.items[i] = {
unique_id:i+1,
idsubsector: d.getNumber(i, "idsubsector"),
idsector: d.getNumber(i, "idsector"),
name: d.getStringFromB64(i, "name"),
ts: d.getString(i, "ts")
};
i++;
}
StoreSubSector.clearOnClose = true;
	StoreSubSector.data = myData;
	StoreSubSector.close();

		egridsub.store = null;
		egridsub.setStore(StoreSubSector);
                },
                function(error){
                    // Display the error returned
alert(error);
                }
            );
}else{
StoreSubSector.clearOnClose = true;
	StoreSubSector.data = myData;
	StoreSubSector.close();

		egridsub.store = null;
		egridsub.setStore(StoreSubSector);
}
}

// Guarda los datos
function SaveSubSector(item){

request.post('fun_location_subsector_edit_xml_from_hashmap.usms', {
   handleAs: "xml",
data: item,
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridSubSector();
}, function(error){
LoadGridSubSector();
alert(error);
});

}


// Elimina los datos seleccionados
function DeleteSubSector(){

request.post('fun_location_subsector_remove_selected_xml.usms', {
   handleAs: "xml",
data: {ids: SubSector.to_delete.toString()},
}).then(function(response){

var xmld = new RXml.getFromXhr(response, 'row');

if(xmld.length > 0){
alert(xmld.getStringFromB64(0, 'outpgmsg'));
}
LoadGridSubSector();
}, function(error){
LoadGridSubSector();
alert(error);
});

}









     });
});
