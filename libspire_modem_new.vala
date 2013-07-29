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
using Gee;

namespace edwinspire{

namespace Ports{


[Description(nick = "DTMF", blurb = "Tono DTMF permitidos")]
	public enum DTMF{
[Description(nick = "0", blurb = "DTMF 0")]
		Zero,
[Description(nick = "1", blurb = "DTMF 1")]
		One,
[Description(nick = "2", blurb = "DTMF 2")]
		Two,
[Description(nick = "3", blurb = "DTMF 3")]
		Three,
[Description(nick = "4", blurb = "DTMF 4")]
		Four,
[Description(nick = "5", blurb = "DTMF 5")]
		Five,
[Description(nick = "6", blurb = "DTMF 6")]
		Six,
[Description(nick = "7", blurb = "DTMF 7")]
		Seven,
[Description(nick = "8", blurb = "DTMF 8")]
		Eigth,
[Description(nick = "9", blurb = "DTMF 9")]
		Nine,
[Description(nick = "*", blurb = "DTMF *")]
		Asterisc,
[Description(nick = "#", blurb = "DTMF #")]
Sharp,
[Description(nick = "A", blurb = "DTMF A")]
A,
[Description(nick = "B", blurb = "DTMF B")]
B,
[Description(nick = "C", blurb = "DTMF C")]
C,
[Description(nick = "D", blurb = "DTMF D")]
D
	}


public enum ResponseCode{
OK = 0,
CONNECT = 1,
RING = 2,
NOCARRIER = 3, 
ERROR = 4,
NODIALTONE = 5,
BUSY = 6,
NOANSWER = 7,
[Description(nick = "ERROR CMS", blurb = "Responde con ERROR modem GSM")]
ERROR_CMS = 98,
[Description(nick = "ERROR CME", blurb = "Responde con ERROR CME")]
ERROR_CME = 99,
UNKNOW = 100,
}

public enum CME{
PhoneFailure = 0,
NoConnectionToPhone = 1,
PhoneAdaptorLinkReserved = 2,
OperationNotAllowed = 3,
OperationNotSupported = 4,
PH_SIM_PIN_Required = 5,
PH_FSIM_PIN_Rrequired = 6,
PH_FSIM_PUK_Required = 7,
SIM_NotInserted = 10,
SIM_PIN_Required = 11,
SIM_PUK_Required = 12,
SIM_Failure = 13,
SIM_Busy = 14,
SIM_Wrong = 15,
IncorrectPassword = 16,
SIM_PIN2_Required = 17,
SIM_PUK2_Rrequired = 18,
MemoryFull = 20,
InvalidIndex = 21,
NotFound = 22,
MemoryFailure = 23,
TextStringTooLong = 24,
InvalidCharactersInTextString = 25,
DialStringTooLong = 26,
InvalidCharactersInDialString = 27,
NoNetworkService = 30,
NetworkTimeout = 31,
EmergencyCallsOnly = 32,
NetworkPersonalizationPIN_Required = 40,
NetworkPersonalization_PUK_Required = 41,
NetworkSubsetPersonalization_PIN_Required = 42, 
NetworkSubsetPersonalization_PUK_Required = 43,
ServiceProviderPersonalization_PIN_Required = 44,
ServiceProviderPersonalization_PUK_Required = 45,
CorporatePersonalization_PIN_Required = 46,
CorporatePersonalization_PUK_Required = 47,
Unknown = 100,
None = 1000
}

	/// <summary>
	/// Respuesta obtenida del Modem
	/// </summary>
public class Response:GLib.Object{
public CME CMEError = CME.None;
public CMS CMSError = CMS.None;
		/// <summary>
		/// Respuesta al comando enviado
		/// true si la respuesta al comando es OK, false en caso contrario
		/// </summary>
public ResponseCode Return = ResponseCode.UNKNOW;
public string Raw = "";
		/// <summary>
		/// Lineas recibidas como respuesta al comando AT
		/// </summary>
		public ArrayList<string> Lines  = new ArrayList<string>();
		/// <summary>
		/// Constructor
		/// </summary>
		/// <param name="Return">
		/// true si todo salio bien, false en caso contrario
		/// </param>
		/// <param name="Lines">
		/// Lineas devueltas por el modem como respuesta a un comando AT
		/// </param>
public Response.with_args(ResponseCode Return, ArrayList<string> Lines, string raw, CME cmeError = CME.None, CMS cmsError = CMS.None){
			this.Return = Return;
			this.Lines = Lines;
this.Raw = raw;
this.CMEError = cmeError;
this.CMSError = cmsError;
		}

public Response(){
}

public string ToString(){
var Cadena = new StringBuilder();
foreach(var l in this.Lines){
Cadena.append_printf("%s\n", l);
}
Cadena.append_printf("Modem %s Response:\n", Return.to_string());
return Cadena.str;
}

	}


//Description 
//These are the error codes for +CMS ERROR. 
public enum CMS{
//0-127 
//GSM 04.11 Annex E-2 values 
//128-255 
//GSM 03.40 section 9.2.3.22 values 
 
Phonefailure  = 300,
SMSServiceOfPhoneReserved = 301,
OperationNotAllowed = 302,
OperationNotSupported = 303,
InvalidPDUModeParameter = 304,
InvalidTextModeParameter = 305,
SIMNotInserted = 310,
SIMPINNecessary = 311, 
PH_SIMPINNecessary = 312, 
SIMFailure = 313,
SIMBusy =  314,
SIMWrong = 315,
MemoryFailure = 320,
InvalidMemoryIndex = 321, 
MemoryFull = 322,
SMSCAddressUnknown = 330,
NoNetworkService = 331, 
NetworkTimeout = 332,
UnknownError = 500, 
ManufacturerSpecific = 512, 
None = 1000
}

public struct LastCallReceived{

public string Number;
public DateTime Date;
public bool Read;

public LastCallReceived(){
this.Number = "";
this.Date = new DateTime.now_local ();
this.Read = false;
}

}


[Description(nick = "Modem", blurb = "Clase para manejar Modems")]
public class Modem : SerialPort{

private string[] expregOK = {"OK\r\n"};
private string[] expregERROR = {"ERROR\r\n"};

// Message service error
private string[] expregERROR_CMS = {
"""\+CMS ERROR: (?<Error>[0-9|a-z|AZ|\w| ]+)""",
"\\+CMS ERROR: (?<Error>[0-9]+)"
};


private string[] expregERROR_CMEE = {
"""\+CME ERROR: (?<Error>[0-9|a-z|AZ|\w| ]+)""",
"\\+CME ERROR: (?<Error>[0-9]+)"
};

private string[] expregCLIP = {
"\\+CLIP: \"(?<CLIP>[0-9|+]+)\""
};

public LastCallReceived LastCall = LastCallReceived();

//--Señales--//
[Description(nick = "CallID", blurb = "Señal emitida cuando se detecta el CallId de una llamada entrante")]
public signal void CallID(string Number);
[Description(nick = "Ringing", blurb = "Señal emitida cuando el modem esta timbrando")]
public signal void Ringing();

private Timer Temporizador = new Timer();


public Modem(){

}

/*
[Description(nick = "TestTimeOutMin", blurb = "Auto Detecta en TimeOut minimo del modem")]
public uint TestTimeOutMin(){
uint oldTimeOut = this.TimeOut;
this.DiscardBuffer();
int trys = 0;
while(trys<100){
this.TimeOut = 1000-(trys*10);

if(!this.SendSimpleCommand("AT\r")){
//print("TimeOut Minimo = %s ms\n", this.TimeOut.to_string());
break;
}

trys++;
}
this.TimeOut = oldTimeOut;
return (1000-(trys*10))+50;
}
*/


[Description(nick = "AutoBaudRate", blurb = "Intenta detectar el Baudrate mas adecuado para el modem")]
public uint AutoBaudRate() {
uint oldbaudrate = this.BaudRate;
uint Retorno = this.BaudRate;
bool oldOpen = this.IsOpen;
bool detectado = false;

//int[] baudios = {460800, 230400, 115200, 38400, 19200, 9600, 4800, 2400, 1800, 1200, 600, 300, 200, 100};
uint[] baudios = {100, 200, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200, 38400, 115200, 230400, 460800};
this.Close();

foreach(var v in baudios){
this.BaudRate = v;
this.Open();
print("Test Baudrate: %s\n", v.to_string());
this.DiscardBuffer();
if(this.AT()){
print("Baudrate a %s = OK\n", v.to_string());
Retorno = v;
detectado = true;
break;
}
this.Close();
}
 
if(!detectado){
this.BaudRate = oldbaudrate;
}

if(oldOpen){
this.Open();
}else{
this.Close();
}

return Retorno;
}


[Description(nick = "Receive", blurb = "Respuesta del modem")]
public Response Receive(double waitforresponse_ms = 0, bool preventDetectFalseResponse = false) {

var RespuestaEnBruto = new StringBuilder();

if(waitforresponse_ms<100){
waitforresponse_ms = waitforresponse_ms+(this.BaudRateTomseg()*750);
}

ArrayList<string> ModemReadLines = new ArrayList<string>();
var Respuesta = ResponseCode.UNKNOW;

if(this.IsOpen && this.Enable){

Temporizador.start();

string? linea = "";
bool identificado = false;

		while(Respuesta == ResponseCode.UNKNOW){
identificado = false;
//print("timeout readline %s => %s\n", waitforresponse_ms.to_string(), (Temporizador.elapsed()*1000).to_string());
if(Temporizador.elapsed()*1000>waitforresponse_ms){
warning("[Receive] Timeout response modem, limit %s ms\n", waitforresponse_ms.to_string());
break;
}

linea = this.ReadLineWithoutStrip();

if(linea!=null){
identificado = false;

// Detecta si la linea es OK
	foreach(string Expresion in expregOK){

		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.OK;
RespuestaEnBruto.append(linea);
		identificado = true;			
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}

if(!identificado){
// Detecta si la linea es ERROR
	foreach(string Expresion in expregERROR){
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.ERROR;
RespuestaEnBruto.append(linea);
		identificado = true;
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}

if(!identificado){
// Detecta si la linea es ERROR_CMS
// TODO // Implementar deteccion de descripcion de este error y anexarlo a la respuesta
	foreach(string Expresion in expregERROR_CMS){
//print("Linea %s\n", linea);
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.ERROR_CMS;
RespuestaEnBruto.append(linea);
		identificado = true;
//print("%s\n", linea);
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}

if(!identificado){
// Detecta si la linea es ERROR_CME
// TODO // Implementar deteccion de descripcion de este error y anexarlo a la respuesta
	foreach(string Expresion in expregERROR_CMEE){
//print("Linea %s\n", linea);
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.ERROR_CME;
RespuestaEnBruto.append(linea);
		identificado = true;
//print("%s\n", linea);
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}

if(!identificado){
	foreach(string Expresion in expregCLIP){
		try{
Regex RegExp = new Regex(Expresion);
MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){

string NumberPhone = match.fetch_named("CLIP");
this.LastCall.Number = NumberPhone;
this.LastCall.Date = new DateTime.now_local();
this.LastCall.Read = false;
		CallID(NumberPhone);
		identificado = true;
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}


if(!identificado){
	ModemReadLines.add(Strip(linea));
RespuestaEnBruto.append(linea);
}

// TODO: Verificar si esto es necesario
if(Respuesta != ResponseCode.UNKNOW){
// Se hace un doble chequeo para verificar que no hay mas bits por leer, esto previene que se detecte falsamente
// un ERROR u OK cuando en Modo texto se lee un sms que contenga esas parabras.
if(preventDetectFalseResponse){
//print("Doble checqueo %s\n", preventDetectFalseResponse.to_string());
if(this.BytesToReadInternal()){
	ModemReadLines.add(Strip(linea));
RespuestaEnBruto.append(linea);
Respuesta = ResponseCode.UNKNOW;
}
}

}
}

				}

}		

Temporizador.stop();

	Response Respuest =  new Response.with_args(Respuesta,  ModemReadLines, RespuestaEnBruto.str);

			return Respuest;
		}



/*
[Description(nick = "Receive", blurb = "Respuesta del modem")]
public Response Receive(double waitforresponse_ms = 0, bool preventDetectFalseResponse = false) {
//print("Receive\n");
//Temporizador.reset();
//uint oldTimeOut = this.TimeOut;
if(waitforresponse_ms<100){
waitforresponse_ms = (waitforresponse_ms+1)+(this.BaudRateTouseg());
}
//print("waitforresponse_ms %s\n", waitforresponse_ms.to_string());
ArrayList<string> ModemReadLines = new ArrayList<string>();
var Respuesta = ResponseCode.UNKNOW;

if(this.IsOpen && this.Enable){

Temporizador.start();

//int iline = 0;
string? linea = "";
bool identificado = false;

		while(Respuesta == ResponseCode.UNKNOW){
identificado = false;
//print("timeout readline %s => %s\n", waitforresponse_ms.to_string(), (Temporizador.elapsed()*1000).to_string());
if(Temporizador.elapsed()*1000>waitforresponse_ms){
//warning("Timeout (%s) wait for response modem\n", waitforresponse_ms.to_string());
break;
}

linea = this.ReadLine();

if(linea!=null){
identificado = false;

// Detecta si la linea es OK
	foreach(string Expresion in expregOK){
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.OK;
		identificado = true;			
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}

if(!identificado){
// Detecta si la linea es ERROR
	foreach(string Expresion in expregERROR){
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.ERROR;
		identificado = true;
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}

if(!identificado){
// Detecta si la linea es ERROR_CMS
// TODO // Implementar deteccion de descripcion de este error y anexarlo a la respuesta
	foreach(string Expresion in expregERROR_CMS){
//print("Linea %s\n", linea);
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.ERROR_CMS;
		identificado = true;
//print("%s\n", linea);
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}

if(!identificado){
// Detecta si la linea es ERROR_CME
// TODO // Implementar deteccion de descripcion de este error y anexarlo a la respuesta
	foreach(string Expresion in expregERROR_CMEE){
//print("Linea %s\n", linea);
		try{
Regex RegExp = new Regex(Expresion);

MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){
Respuesta = ResponseCode.ERROR_CME;
		identificado = true;
//print("%s\n", linea);
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}

if(!identificado){
	foreach(string Expresion in expregCLIP){
		try{
Regex RegExp = new Regex(Expresion);
//print("%s\n", linea);
MatchInfo match;
if(RegExp.match(linea, RegexMatchFlags.ANCHORED, out match)){

string NumberPhone = match.fetch_named("CLIP");
		CallID(NumberPhone);
		identificado = true;
//print("CLIP >>>>>>>>>>>>>>>>>>>>>> %s\n", NumberPhone);
break;
}
			}catch (RegexError err) {
                warning (err.message);
		}
		}
}


if(!identificado){
	ModemReadLines.add(linea);
}

if(Respuesta != ResponseCode.UNKNOW){
// Se hace un doble chequeo para verificar que no hay mas bits por leer, esto previene que se detecte falsamente
// un ERROR u OK cuando en Modo texto se lee un sms que contenga esas parabras.
if(preventDetectFalseResponse){
//print("Doble checqueo %s\n", preventDetectFalseResponse.to_string());
if(this.BytesToReadInternal()){
	ModemReadLines.add(linea);
Respuesta = ResponseCode.UNKNOW;
}
}

}
}

				}

}		

Temporizador.stop();

	Response Respuest =  new Response.with_args(Respuesta,  ModemReadLines);

			return Respuest;
		}

*/


/// <summary>
/// Envia un comando AT al modem
/// </summary>
/// <param name="ComandoAT">
/// A <see cref="System.String"/>
/// Comando AT
/// </param>
/// <returns>
/// A <see cref="System.Boolean"/>
/// Devuelve true si se ha logrado enviar el comando al modem, caso contrario devuelve false
/// </returns>
public bool Send(string ComandoAT) {
			bool Retorno = false;


			this.DiscardBuffer();
			long Escrito = Write(ComandoAT);
if(Escrito>0){
	Retorno = true;
}else{
//throw new SerialError.IO_EXCEPTION("El Puerto no esta abierto");
stderr.printf("No se pudo escribir en el puerto %s\n", this.Port);
}

			return Retorno;
		}

		/// <summary>
		/// Envia un comando AT del cual se espera
		/// obtener como respuesta un OK o ERROR
		/// </summary>
		/// <param name="ATCommand">
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// A <see cref="System.Boolean"/>
		/// Respuesta al comando AT (true = OK / false = ERROR)
		/// </returns>
public bool SendSimpleCommand(string ATCommand, double waitforresponse_ms = 0) {
	bool Retorno= false;
				this.DiscardBuffer();
long Escrito = this.Write(ATCommand);
if(Escrito>0){
if(Receive(waitforresponse_ms).Return == ResponseCode.OK){
Retorno = true;
}
}else{
stderr.printf("No se pudo escribir en el puerto %s\n", this.Port);
if(LogModem){
LogCommandAT(ATCommand+": No se pudo escribir en el puerto\n");
}
}


return 	Retorno;
}

[Description(nick = "Dial Command", blurb = "Marca en numero pasado como parametro")]
public bool DialCommand(string number){
return this.ATD(number);
}


[Description(nick = "ATD", blurb = "Marca en numero pasado como parametro")]
public bool ATD(string  Number){

bool Retorno = false;

 StringBuilder ComandoAT = new StringBuilder("ATD");
 	ComandoAT.append(Number);
 	ComandoAT.append("\r");
			if(this.IsOpen){
				this.DiscardBuffer();
				//this.DiscardOutBuffer();
this.Write(ComandoAT.str);
				Retorno = true;
			}
return Retorno;
}

[Description(nick = "Set To Default Configuration", blurb = "Vuelve el modem a sus valores iniciales")]
public bool SetToDefaultConfiguration(){
return this.ATZ();
}



[Description(nick = "ATZ", blurb = "Reset modem. Vuelve el modem a sus valores iniciales")]
	public bool ATZ(){
			 return this.SendSimpleCommand("ATZ\r");
	}

	public bool ATE(bool enable){
string comando = "ATE0\r";
if(enable){
comando = "ATE1\r";
}
 return this.SendSimpleCommand(comando);
	}

//TODO// Probar que funcione
	public bool ATV(bool enable){
string comando = "ATV0\r";
if(enable){
comando = "ATV1\r";
}
 return this.SendSimpleCommand(comando);
	}

public bool VerboseMode(bool enable){
return ATV(enable);
}

public bool Echo(bool enable){
return ATE(enable);
}


	public bool ATS_Set(int register, int value){
		return this.SendSimpleCommand("ATS"+register.to_string()+"="+value.to_string()+"\r");
	}


public bool AutomaticAnswerControl_Set(int rings){
return ATS_Set(0, rings);
}

public int AutomaticAnswerControl(){
return ATS(0);
}

public int ATS0(){
return AutomaticAnswerControl();
}

public bool ATS0_Set(int rings){
return AutomaticAnswerControl_Set(rings);
}


public bool EscapeSequenseCharacter_Set(int character = 43){
return ATS_Set(2, character);
}

public int EscapeSequenseCharacter(){
return ATS(2);
}

public int ATS2(){
return EscapeSequenseCharacter();
}

public bool ATS2_Set(int character = 43){
return EscapeSequenseCharacter_Set(character);
}

public bool CommandLineTerminationCharacter_Set(int character = 13){
return ATS_Set(3, character);
}

public int CommandLineTerminationCharacter(){
return ATS(3);
}

public int ATS3(){
return CommandLineTerminationCharacter();
}

public bool ATS3_Set(int character = 13){
return CommandLineTerminationCharacter_Set(character);
}

public bool ResponseFormattingCharacter_Set(int character = 10){
return ATS_Set(4, character);
}

public int ResponseFormattingCharacter(){
return ATS(4);
}

public int ATS4(){
return ResponseFormattingCharacter();
}

public bool ATS4_Set(int character = 10){
return ResponseFormattingCharacter_Set(character);
}


public bool CommandLineEditingCharacter_Set(int character = 8){
return ATS_Set(5, character);
}

public int CommandLineEditingCharacter(){
return ATS(5);
}

public int ATS5(){
return CommandLineEditingCharacter();
}

public bool ATS5_Set(int character = 8){
return CommandLineEditingCharacter_Set(character);
}


public bool ATS7_Set(int timeout = 50){
return ATS_Set(7, timeout);
}

public bool CompletionConnectionTimeOut_Set(int timeout = 50){
return ATS7_Set(timeout);
}

public int ATS7(){
return ATS(7);
}

public int CompletionConnectionTimeOut(){
return ATS7();
}


public bool ATS10_Set(int delay = 2){
return ATS_Set(10, delay);
}

public bool AutomaticDisconnectDelayControl_Set(int delay = 2){
return ATS10_Set(delay);
}

public int ATS10(){
return ATS(10);
}

public int AutomaticDisconnectDelayControl(){
return ATS10();
}



//TODO// Probar qe funcione
public int ATS(int register){

int Retorno = 0;
			this.DiscardBuffer();

this.Send("ATS"+register.to_string()+"?\r");

Response Respuesta = this.Receive();

			if(Respuesta.Return == ResponseCode.OK){
						try{
Regex RegExp = new Regex("(?<Value>[0-9]+)");
	foreach(string Linea in Respuesta.Lines){

MatchInfo match;
if(RegExp.match(Linea, RegexMatchFlags.ANCHORED, out match)){
Retorno = int.parse(match.fetch_named("Value"));
break;
}
			}

			}
				catch (RegexError err) {
                warning (err.message);
		}
		
	}

return Retorno;
		}


	public bool AT(){
			 return this.SendSimpleCommand("AT\r");
	}



	public bool EscapeSequense(){
			 return this.SendSimpleCommand("+++\r");
	}

[Description(nick = "Accept Call", blurb = "Acepta una llamada entrante")]
public bool AcceptCall(){
return this.ATA();
}


[Description(nick = "ATA", blurb = "Acepta una llamada entrante")]
	public bool ATA(){
		return this.SendSimpleCommand("ATA\r");
	}




}




}


}





