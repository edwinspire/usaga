//New file source
using GLib;
using Gee;
using edwinspire.uSMS;
using edwinspire.pgSQL;
using Xml;
using edwinspire.uHttp;
using edwinspire.uSMS;
using Postgres;

namespace edwinspire.uSAGA{

public class uSagaProcessData:PostgresuSMS{

public uSagaProcessData(){

}


// opensaga.fun_eventtype_default
public void fun_eventtype_default(){

int Retorno = -1;

string[] valuessms = new string[2];

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

    EnumClass enum_class = (EnumClass) typeof(EventType).class_ref ();
foreach(var item in enum_class.values){
//string nick = item.value_nick;
//GLib.print("ComboBox.FromEnum = %s\n", nick);

valuessms[0] = item.value.to_string();
valuessms[1] = item.value_nick;


var Resultado = this.exec_params_minimal (ref Conexion, """SELECT usaga.fun_eventtype_default($1::integer, $2::text);""",  valuessms);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var filas in this.Result_FieldName(ref Resultado)){
Retorno = filas["fun_eventtype_default"].as_int();
//GLib.print("%s = %s\n", valuessms[0], valuessms[1]);
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
}


//return Retorno;
}

public void Run(){
this.GetParamCnx();
this.fun_eventtype_default();

int i = 0;
while(true){
this.GetParamCnx();
//Thread.usleep(1000*1000);
//ReceiveFromCallIn();
Thread.usleep(1000*1000);
ReceiveFromSMSIn();
Thread.usleep(1000*1000);
GenAutoTestReport();
Thread.usleep(1000*1000);

if(i==0){
HearBeat();
}else if(i>200){
i=-1;
}
//GLib.print(i.to_string());
i++;
}

}

private void HearBeat(){
GLib.print("\n[uSAGA]: Receptor procesando ");

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){
//GLib.print("Conectado\n");
var Resultado = Conexion.exec("""SELECT * FROM usaga.hearbeat();""");

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("OpenSAGA: \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["calls"]);
//GLib.print("Llamadas procesadas: %s\n", filas["calls"].Value);
GLib.print("%s >> ok\n", filas["hearbeat"].Value);
/*
foreach(var tu in filas.entries){
GLib.print("%s => %s\n", tu.key, tu.value);
}
*/
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
}

/*
private void ReceiveFromCallIn(){
GLib.print("\n[uSAGA]: Procesando llamadas entrantes\n");
// Lee las llamadas recibidas desde la tabla incomingcall, verifica si pertenece a algun usuario del sistema de alarma e ingresa el evento
//int Retorno = -1;
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){
//GLib.print("Conectado\n");
var Resultado = Conexion.exec("""SELECT * FROM usaga.fun_receiver_from_incomingcalls();""");

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("OpenSAGA: \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["calls"]);
GLib.print("Llamadas procesadas: %s\n", filas["calls"].Value);
GLib.print("Eventos generados: %s\n", filas["eventsgenerated"].Value);

}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
}
*/

private void ReceiveFromSMSIn(){
// Lee los mensajes recibidos desde la tabla smsin, verifica si pertenece a algun usuario del sistema de alarma, obtiene el tipo de alarma e ingresa el evento
GLib.print("\n[uSAGA]: Procesando SMSs entrantes\n");
// Lee las llamadas recibidas desde la tabla incomingcall, verifica si pertenece a algun usuario del sistema de alarma e ingresa el evento
//int Retorno = -1;
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){
//GLib.print("Conectado\n");
var Resultado = Conexion.exec("""SELECT * FROM usaga.fun_receiver_from_incomingsmss();""");

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("OpenSAGA: \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["calls"]);
GLib.print("Mensajes procesados: %s\n", filas["outsmss"].Value);
GLib.print("Eventos generados: %s\n", filas["outeventsgenerated"].Value);
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
}

private void GenAutoTestReport(){
// Genera un sms de reporte semanal a cada usuario del sistema de alarma.
GLib.print("\n[uSAGA]: Generando reportes de prueba automaticos\n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){
//GLib.print("Conectado\n");
var Resultado = Conexion.exec("""SELECT * FROM usaga.fun_generate_test_report();""");

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("OpenSAGA: \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["calls"]);
//GLib.print("Mensajes procesados: %s\n", filas["outsmss"].Value);
GLib.print("Eventos generados: %s\n", filas["outeventsgenerated"].Value);
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
}




}


}
