//Funciones adicionales de cadenas
// Convierte una cadena en Booleano
String.prototype.to_boolean = function(){
var Return = false;
if(this == 'false' || this == 'FALSE'){
Return = false;
}else{
Return = Boolean(this);
}
return Return;
}

// Convierte un string en Date
String.prototype.to_date = function(){
// Se tuvo un problema al parsear las fechas ya que siempre devolvia un dia menos, con esto se soluciona
var f = new Date(this);
f.setDate(f.getDate()+1); 
console.log('String.prototype.to_date necesita revision')
return f;
}

String.prototype.to_number = function(){
return Number(this);
}

String.prototype.to_float = function(){
return parseFloat(this);
}

String.prototype.to_int = function(){
return parseInt(this);
}

String.prototype.to_b64 = function(){
return btoa(unescape(encodeURIComponent(this)));
}
//TODO: Solucionar el problema con saltos de linea
String.prototype.from_b64 = function(){
var r = '';
try
  {
r = decodeURIComponent(escape(atob(this.replace(/\s/g, ''))));
  }
catch(err)
  {
console.log(err);
  }
return r;
}



