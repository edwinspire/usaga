//
//
//  Author:
//       Edwin De La Cruz <admin@edwinspire.com>
//
//  Copyright (c) 2011 edwinspire
//  Web Site http://edwinspire.com
//
//  Quito - Ecuador
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.


using GLib;

	/// <summary>
	/// Importacion de funciones externas de manejos de puerto serial Multiplataforma.
	/// Modificar serial.c segun el sistema operativo que este usando
	/// </summary>
extern int Open_Port(string Puerto);
extern int Set_Configure_Port(int fd, uint BaudRate, uint Bits, uint Parity, uint BitsStop);
extern long Write_Port(int fd, string buf, int SizeData);
//extern long Getc_Port(int fd, void* Data);
extern char Getc(int fd);
extern int Kbhit_Port(int fd);
extern int Close_Port(int fd);
extern int Set_Hands_Haking(int fd, int FlowControl);
//extern int Set_BaudRate(int fd, uint BaudRate);
extern int IO_Blocking(int fd, int Modo);
extern int Clean_Buffer(int fd);
extern int Setup_Buffer(int fd,  ulong InQueue, ulong OutQueue);
extern int Set_Time(int fd, uint Time);



namespace edwinspire{

namespace Ports{


[Description(nick = "HandShaking", blurb = "Especifica el protocolo de control utilizado para establecer la comunicacion con el puerto serie")]
public enum HandShaking{
[Description(nick = "NONE", blurb = "No se utiliza ningun control para el protocol de enlace")]
NONE,
[Description(nick = "RTS-CTS", blurb = "Controles por hardware, Solicitud de encio (RTS) y Listo para enviar (CTS)")]
RTS_CTS,
[Description(nick = "XOnXOff", blurb = "Protocolo de control de software XON/XOFF")]
XOnXOff,
[Description(nick = "DTR-DSR", blurb = "Utiliza tanto RTS CTS como XON/XOFF")]
DTR_DSR
}
	
[Description(nick = "Parity", blurb = "Especifica el bit de paridad")]
public enum Parity {
[Description(nick = "NONE", blurb = "No se produce una comprobación de paridad")]
NONE, 
[Description(nick = "ODD", blurb = "Establece el bit de paridad de forma que el recuento de bits establecidos sea un número impar")]
ODD, 
[Description(nick = "EVEN", blurb = "Establece el bit de paridad de forma que el recuento de bits establecidos sea un número par")]
EVEN, 
[Description(nick = "MARK", blurb = "Establece el conjunto de bits de paridad en 1")]
MARK, 
[Description(nick = "SPACE", blurb = "Establece el conjunto de bits de paridad en 0")]
SPACE
}


[Description(nick = "StopBits", blurb = "Especifica el número de bits de parada utilizado")]
public enum StopBits {
[Description(nick = "NONE", blurb = "No se utiliza ningún bit de parada")]
NONE, 
[Description(nick = "ONE", blurb = "Se utiliza un bit de parada")]
ONE, 
[Description(nick = "TWO", blurb = "Se utilizan dos bits de parada")]
TWO
}


[Description(nick = "Data Status", blurb = "Estado del modem")]
public enum DataStatus{
[Description(nick = "None", blurb = "Modem no eta realizando ninguna accion")]
None, 
[Description(nick = "Sending", blurb = "Enviando datos al modem")]
Sending, 
[Description(nick = "Receiving", blurb = "Recibiendo datos del modem")]
Receiving
}


public class Configure:GLib.Object{

public string Port{set; get; default = "/dev/ttyS0";}

public uint BaudRate{get; set; default = 9600;}
public Parity Parityp{get; set; default = Ports.Parity.NONE;}
public StopBits StopBitsp{get; set; default = Ports.StopBits.ONE;}
public uint DataBits{get; set; default = 8;}
public HandShaking HandShake{get; set; default = Ports.HandShaking.NONE;}
//public uint TimeOut{set; get; default = 250;}
public bool Enable{set; get; default = true;}

public ulong BufferIn{set; get; default = 8192;}
public ulong BufferOut{set; get; default = 8192;}

public Configure(){

}

}




public class SerialPort:Configure{

public signal void Status(DataStatus Status);

private int Gestor = -1;
private bool Bloqueante = false;
// Variables para uso interno
private Timer TemporizadorInternoReadChar = new Timer();
private Timer TemporizadorInternoReadLine = new Timer();
private StringBuilder LineaModem = new StringBuilder();
//private StringBuilder LineaModemCR = new StringBuilder();
public bool LogModem = false;


public SerialPort.with_args(string Port_ = "/dev/ttyS0", uint Baudrate = 2400, uint DataBits = 8, Parity Parity_ = Parity.NONE, StopBits StopBits_ = StopBits.ONE, HandShaking HS_ = HandShaking.NONE){
connectSignals();
 Port = Port_;
 this.BaudRate = Baudrate;
 this.Parityp =  Parity_;
 this.StopBitsp = StopBits_;
  this.DataBits = DataBits;
  this.HandShake = HS_;
}

private void connectSignals(){
// Realizamos la accion cuando el Baudrate cambia
this.notify["BaudRate"].connect((objeto, parametros)=>{
Set_Port();
});

this.notify["Parity"].connect((objeto, parametros)=>{
Set_Port();
});

this.notify["StopBits"].connect((objeto, parametros)=>{
Set_Port();
});


this.notify["DataBits"].connect((objeto, parametros)=>{
Set_Port();
});

this.notify["HandShake"].connect((objeto, parametros)=>{
	set_handshaking();
});

this.notify["BufferIn"].connect((objeto, parametros)=>{
Setup_Buffer_(this.BufferIn, this.BufferOut);
});

this.notify["BufferOut"].connect((objeto, parametros)=>{
Setup_Buffer_(this.BufferIn, this.BufferOut);
});



}

public SerialPort(){
connectSignals();
Port = "/dev/ttyS0";
Enable = true;
}

private bool Set_Port(){
bool Retorno = false;
if(this.IsEnableAndOpen()){
if(Set_Configure_Port(Gestor, this.BaudRate, this.DataBits, this.Parityp, this.StopBitsp) == 0){
Retorno = true;
}else{
Retorno = false;
}
}
//print("Set port %s\n", Retorno.to_string());
return Retorno;
}

private bool Set(){
bool Retorno = false;
if(Enable && Set_Port()){
if(set_handshaking()){
	Retorno = IO_Blocking_();
}
}

return Retorno;
}

private bool Setup_Buffer_(ulong BufferIn, ulong BufferOut){
bool Retorno = false;
if(this.IsEnableAndOpen() && Setup_Buffer(Gestor, BufferIn, BufferOut)==0){
Retorno = true;
}
return Retorno;
}



private bool set_handshaking(){
bool Retorno = false;
if(this.IsEnableAndOpen()){
if(Set_Hands_Haking(Gestor, this.HandShake) == 0){
Retorno = true;
}
}
return Retorno;
}

public bool DiscardBuffer(){
bool Retorno = false;
if(this.IsEnableAndOpen() && Clean_Buffer(Gestor) == 0){
Retorno = true;
}
return Retorno;
}

//TODO//
public string[] Get_PortName(){
string[] Retorno = new string[0];
return Retorno;
}

public bool Blocking{
set{
	Bloqueante = value;
IO_Blocking_();
}
get{
	return Bloqueante;
}
}

private bool IO_Blocking_(){
bool Retorno = false;
int Valor = -1;
if(Bloqueante){
Valor = 0;
}

if(this.IsEnableAndOpen() && IO_Blocking(Gestor, Valor) == 0){
Retorno = true;
}

return Retorno;
}

public bool Time(uint Time_){
bool Retorno = false;
if(this.IsEnableAndOpen() && Set_Time(Gestor, Time_) == 0){
Retorno = true;
}
return Retorno;
}




//Bits por leer
public int BytesToRead{
get{
	return Kbhit_Port(Gestor);
}

}


public bool Open() {
var Cadena = new StringBuilder();

if(LogModem){
Cadena.append_printf("Puerto: %s\n", this.Port);
Cadena.append_printf("Abre con configuracion: %s\n", this.Port);

Cadena.append_printf("BaudRate: %s\n", this.BaudRate.to_string());
Cadena.append_printf("Parityp: %s\n", this.Parityp.to_string());
Cadena.append_printf("StopBitsp: %s\n", this.StopBitsp.to_string());
Cadena.append_printf("DataBits: %s\n", this.DataBits.to_string());
Cadena.append_printf("HandShake: %s\n", this.HandShake.to_string());
LogCommandAT(Cadena.str);
}

	//TODO//Crear un TimeOut para Open
		Gestor = Open_Port(Port);
		//stdout.printf ("Gestor id = %s\n", Gestor.to_string());
		if(Enable && IsOpen){
Set();
}else{

	//throw new SerialError.IO_EXCEPTION("Puerto no pudo ser abierto");
	stderr.printf("El puerto %s no pudo ser abierto\n", this.Port);
if(LogModem){
Cadena.truncate(0);
Cadena.append_printf("Puerto: %s no pudo ser abierto\n", this.Port);
LogCommandAT(Cadena.str);
}

}
return this.IsOpen;
}


public long Write(string Data_){
long Retorno = 0;
var Cadena = new StringBuilder();

if(LogModem){
Cadena.append_printf(">> %s\n", Data_);
LogCommandAT(Cadena.str);
}

if(this.IsEnableAndOpen()){
if(Data_.length>0){
//ulong pausaEntreBits = (ulong)this.BaudRateTouseg();
//print("pausaEntreBits %s\n", pausaEntreBits.to_string());
StringBuilder DatoC = new StringBuilder();
int i = 0;
this.Status(DataStatus.Sending);
while(i<Data_.length){
DatoC.truncate(0);
DatoC.append_unichar(Data_[i]);
this.PausaEntreBytes();
if(Write_Port(Gestor, DatoC.str, 1) == 1){
Retorno++;
}else{
warning("No se pudo escribir (%s)\n", DatoC.str);
}

i++;
}
}
}

this.Status(DataStatus.None);
return Retorno;
}


internal bool IsEnableAndOpen() {
bool Retorno = false;

if(Enable){
if(IsOpen){
Retorno = true;
}else{
	stderr.printf("(IsEnableAndOpen) El Puerto %s no esta abierto\n", this.Port);
}
}else{
	stderr.printf("(IsEnableAndOpen) El Puerto %s no esta habilitado\n", this.Port);
}

return Retorno;
}

public char ReadChar() {
//print("Readchar()\n");
//unichar Uni_ = 0;
char Datax = 0;
//stdout.printf ("char0 %c\n", Datax);
//Espera un tiempo hasa que lleguen los datos, caso contrario sale y genera una exepcion
if(this.IsEnableAndOpen()){
//stdout.printf ("char1 %c\n", Datax);
if(this.BytesToReadInternal()){
//stdout.printf ("char2 %c\n", Datax);
//PausaEntreBytes();
this.Status(DataStatus.Receiving);
 Datax = Getc(Gestor);

}
}

this.Status(DataStatus.None);
stdout.printf ("%c", Datax);
return Datax;
}



internal void PausaEntreBytes(){
	Thread.usleep((ulong)this.BaudRateTouseg());
}


// Consulta al modem si hay bits para leer, si se exede el timeout de espera se genera una exepcion.
internal bool BytesToReadInternal(){
bool Retorno = false;

if(this.IsEnableAndOpen() && this.BytesToRead<1){

int intentos = 0;
//var TimeOut = 100; // 100ms
Retorno = true;
//Timer Temporizador = new Timer();
TemporizadorInternoReadChar.start();
while(!(this.BytesToRead>0) && intentos<5){
	PausaEntreBytes();
	PausaEntreBytes();

/*
if((TemporizadorInternoReadChar.elapsed()*1000)>TimeOut){
//warning("Exedio %s ms para leer\n", TimeOut.to_string());
	Retorno = false;
break;
}
*/
intentos++;
}

}else{
	Retorno = true;
}
TemporizadorInternoReadChar.stop();

return Retorno;
}


public static void LogCommandAT (string text = "") {
    try {
        // an output file in the current working directory
        var file = File.new_for_path ("modem.log");
/*
        // delete if file already exists
        if (file.query_exists ()) {
            file.delete ();
        }
*/
        // creating a file and a DataOutputStream to the file
        /*
            Use BufferedOutputStream to increase write speed:
            var dos = new DataOutputStream (new BufferedOutputStream.sized (file.create (FileCreateFlags.REPLACE_DESTINATION), 65536));
        */
        var dos = new DataOutputStream (file.append_to (FileCreateFlags.NONE));

        // writing a short string to the stream
   //     dos.put_string ("this is the first line\n");
        
     //   string text = "this is the second line\n";
        // For long string writes, a loop should be used, because sometimes not all data can be written in one run
        // 'written' is used to check how much of the string has already been written
        uint8[] data = text.data;
        long written = 0;
        while (written < data.length) { 
            // sum of the bytes of 'text' that already have been written to the stream
            written += dos.write (data[written:data.length]);
        }
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
        // return 1;
    }

  //  return 0;
}

public double BaudRateTouseg(){
var Retorno = ((1/(double)this.BaudRate)*1000000);
return Retorno;
}

public double BaudRateTomseg(){
var Retorno = ((1/(double)this.BaudRate)*1000);
return Retorno;
}

public string? ReadLine(double timeout_ms_for_line = 0){
return Strip(ReadLine(timeout_ms_for_line));
}

// Lee una linea desde el modem, como fin de linea se determina \r\n
public string? ReadLineWithoutStrip(double timeout_ms_for_line = 0){

bool AnyCharValid = false;
LineaModem.truncate(0);
//LineaModemCR.truncate(0);

if(this.IsEnableAndOpen()){
//Timer Temporizador = new Timer();
TemporizadorInternoReadLine.start();

if(timeout_ms_for_line<1){
timeout_ms_for_line = (this.BaudRateTomseg()+1)*200;
}

char C = 0;
bool EncontradoFinDeLinea = false;
//var maxtimewaitforendline = (ulong)this.BaudRateTouseg();

while(!EncontradoFinDeLinea){

	if((TemporizadorInternoReadLine.elapsed()*1000)>timeout_ms_for_line){
warning("[ReadLineWithoutStrip] Timeout to End Line, limit %s ms\n", timeout_ms_for_line.to_string());
//	Thread.usleep(5000);
		EncontradoFinDeLinea = true;
break;
}


if(LineaModem.str.has_suffix("\r\n")){
EncontradoFinDeLinea = true;
}else{
C = ReadChar();
//print("%c", C);
if(C>0){
AnyCharValid=true;
LineaModem.append_c(C);
}

}

}

}
TemporizadorInternoReadLine.stop();
//stdout.printf ("%s\n", LineaModem.str);
string ? Retorno = null;
if(AnyCharValid){
Retorno = LineaModem.str;
}
if(LogModem){
var Cadena = new StringBuilder();
//Cadena.truncate(0);
Cadena.append_printf("<< %s\n", Retorno);
LogCommandAT(Cadena.str);
}
LineaModem.truncate(0);
//print("%s\n", Retorno);
return Retorno;
}

public static string Strip(string String){
return String.strip();
}


/*
public string? ReadLine(double timeout_ms_for_line = 0){
//print("ReadLine\n");
//TemporizadorInternoReadLine.reset();
//this.DiscardBuffer();

bool AnyCharValid = false;
LineaModem.truncate(0);
LineaModemCR.truncate(0);

if(this.IsEnableAndOpen()){
//Timer Temporizador = new Timer();
TemporizadorInternoReadLine.start();

if(timeout_ms_for_line<1){
timeout_ms_for_line = this.BaudRateTouseg()+1000;
}

//timeout_ms_for_line = timeout_ms_for_line+thi

char C = 0;
bool EncontradoFinDeLinea = false;
//var maxtimewaitforendline = (ulong)this.BaudRateTouseg();

while(!EncontradoFinDeLinea){
//print("Leyendo puerto loop %s => %s\n", (TemporizadorInternoReadLine.elapsed()).to_string(), timeout_ms_for_line.to_string());

	if((TemporizadorInternoReadLine.elapsed()*1000)>timeout_ms_for_line){
	//TODO// Generar exepcion de timeout esperando fin de linea
	Thread.usleep(5000);
//		warning("<TimeOut Fin de linea> %s mseg a Baudrate: %s\n", timeout_ms_for_line.to_string(), this.BaudRate.to_string());
		EncontradoFinDeLinea = true;
break;
}


if("\r\n" in LineaModemCR.str){
EncontradoFinDeLinea = true;

}else{
C = ReadChar();
//print("%c", C);
if(C == 10 || C == 13){
LineaModemCR.append_c(C);
}else if(C > 0){
AnyCharValid = true;
LineaModem.append_c(C);
LineaModemCR.truncate();
}

}

}

}
TemporizadorInternoReadLine.stop();
//stdout.printf ("%s\n", LineaModem.str);
string ? Retorno = null;
if(AnyCharValid){
Retorno = LineaModem.str.strip();
}
if(LogModem){
var Cadena = new StringBuilder();
//Cadena.truncate(0);
Cadena.append_printf("<< %s\n", Retorno);
LogCommandAT(Cadena.str);
}
//print("%s\n", Retorno);
return Retorno;
}
*/
public bool Close() {
bool Retorno = false;
if(IsOpen){
if(Close_Port(Gestor) == 0){
Retorno = true;
Thread.usleep(100000);
}else if(Close_Port(Gestor) == 0){
Retorno = true;
Thread.usleep(100000);
}else if(Close_Port(Gestor) == 0){
Retorno = true;
Thread.usleep(100000);
}
Gestor = -1;
}
	return Retorno;
}

public bool IsOpen{
get{
	bool Retorno = false;
	if(Gestor>0){
Retorno = true;
	}
	return Retorno;
}

}



}


}


}




