// 
//  main.vala
//  
//  Author:
//       Edwin De La Cruz <edwinspire@gmail.com>
//  
//  Copyright (c) 2011 edwinspire
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
using edwinspire.pgSQL;
using edwinspire.uSMS;
using Postgres;

namespace edwinspire.uSAGA{

public struct EventViewdb{

public int IdEvent;
public string DateLoad;
public int IdAccount;
public int Partition;
public bool Enable;
public string Account;
public string Name;
//public int TypeAccount;
public string Code;
public int ZU;
public int Priority;
public string Description;
public int IdEvenType;
public string EventType;
public string Date;
public int Process1;
public string DateProcess1;
public int Process2;
public string DateProcess2;
public int Process3;
public string DateProcess3;
public int Process4;
public string DateProcess4;
public int Process5;
public string DateProcess5; 

public EventViewdb(){
this.IdEvent = 0;
this.DateLoad = "";
this.IdAccount = 0;
this.Partition = 0;
this.Description = "";
this.Enable = false;
this.Account = "";
this.Name = "";
this.IdEvenType = 0;
this.Code = "";
this.ZU = 0;
this.Priority = 0;
this.IdEvenType = 0;
this.EventType = "";
this.Date = "";
this.Process1 = 0;
this.DateProcess1  = "";
this.Process2 = 0;
this.DateProcess2 = "";
this.Process3 = 0;
this.DateProcess3 = "";
this.Process4 = 0;
this.DateProcess4  = "";
this.Process5 = 0;
this.DateProcess5 = ""; 

}

}


/*
public struct EVENTdb {

public int ID, IdAccount, ZU, IdPhone, Priority;
		public bool Enable;
		public DateTime Date, Load;
		public string Code, Descrip, Note;
		public EventType EventTypeA, EventTypeM;
public SysProcess Process;
		public Tramit Tramit;
public EVENTdb(int ID, int IdAccount, int ZU, int IdPhone, int Priority, bool Enable, DateTime Date, DateTime Load, string Code, string Descrip, string Note, EventType EventTypeA, EventType EventTypeM, SysProcess Process, Tramit Tramit){
		
this.ID = ID;
this.IdAccount = IdAccount;	
			this.ZU = ZU;	
			this.IdPhone = IdPhone;	
			this.Priority = Priority;	
			this.Enable = Enable;	
			this.Date = Date;	
			this.Load = Load;	
			this.Code = Code;	
			this.Descrip = Descrip;	
			this.Note = Note;	
this.EventTypeA = EventTypeA;
			this.EventTypeM = EventTypeM;
			this.Process = Process;
			this.Tramit = Tramit;
			
		}
	}
*/




//usaga.fun_account_insert_update(IN inidaccount integer, IN inpartition integer, IN inenable boolean, IN inaccount text, IN inname text, IN intype integer, IN innote text, OUT outidaccount integer, OUT outpgmsg text)

public struct AccountUserdb{

public int IdAccount; 
public int IdContact; 
public int NumUser;
public string Appointment;
public bool Enable;
public string KeyWord;
public string Password;
public string Note;

public AccountUserdb(){
this.IdAccount = 0;
this.IdContact = 0;
this.NumUser = 0;
this.Enable = false;
this.KeyWord = "";
this.Password = "";
this.Note = "";
this.Appointment = "";
}

}
 

public struct Accountdb {

public int Id;
public int  IdGroup;
public int Partition;
public int IdPhone;
		public bool Enable;
		public AccountType Type;
		public string Account;
public string Name;
public string Note;

	//	public ComunicationFormat Format;
		//public DateTime InstallDate;
		//	public Addressdb Address;

public Accountdb(){
this.Id = 0;
this.IdGroup = 0;
this.Partition = 0;
		this.Enable = false;
			this.Account = "";
			this.Name = "";
			this.Type = AccountType.Unknown;
this.Note = "";

}

public Accountdb.with_args(int ID, bool Enable, int IDGroup, string Account, string Name, int Partition, AccountType Type, string Note){
		
this.Id = ID;
//this.Address = Address;
this.IdGroup = IDGroup;
this.Partition = Partition;
//this.IdPanelModel = IdPanelModel;
//this.IdPhone = IdPhone;
			this.Enable = Enable;
			this.Account = Account;
			this.Name = Name;
			this.Type = Type;
//			this.InstallerCode = InstallerCode;
//			this.InstallDate = InstallDate;
//this.Format = Format;
this.Note = Note;
				
		}
	}





public class EventView:PostgreSQLConnection{

public EventView(){

}


public string LastXml(int rows = 100, bool fieldtextasbase64 = true){
string RetornoX = "<table></table>";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {rows.to_string(), fieldtextasbase64.to_string()};

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_view_last_events_xml($1::integer, $2::boolean) AS return", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].Value;
}

}else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
return RetornoX;
}

}



public struct AccountPhonesTriggerAlarmViewdb{

public int IdAccount;
public int IdContact;
public int IdPhone;
public bool PhoneEnable;
public int Type;
public int IdProvider;
public string Phone;
public string Address;
public bool TriggerEnable;
public bool SMS;
public bool Call;
public string Note;

public AccountPhonesTriggerAlarmViewdb(){
this.IdAccount = 0;
this.IdContact = 0;
this.IdPhone = 0;
this.PhoneEnable = false;
this.Type = 0;
this.IdProvider = 0;
this.Phone = "";
this.Address = "";
this.TriggerEnable = false;
this.SMS = false;
this.Call = false;
this.Note = "";
}


}



public class AccountPhonesTriggerAlarmTable:PostgreSQLConnection{

public static XmlRow AccountPhonesTriggerAlarmViewdbNodeXml(AccountPhonesTriggerAlarmViewdb row){

XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idaccount", row.IdAccount);
Fila.addFieldInt("idcontact", row.IdContact);
Fila.addFieldInt("idphone", row.IdPhone);
Fila.addFieldBool("phone_enable", row.PhoneEnable);
Fila.addFieldInt("type", row.Type);
Fila.addFieldInt("idprovider", row.IdProvider);
Fila.addFieldString("phone", row.Phone, true);
Fila.addFieldString("address", row.Address, true);
Fila.addFieldBool("trigger_alarm", row.TriggerEnable);
Fila.addFieldBool("fromsms", row.SMS);
Fila.addFieldBool("fromcall", row.Call);
Fila.addFieldString("note", row.Note, true);

return Fila;
}


public SQLFunReturn fun_account_phones_trigger_alarm_table_from_hashmap(HashMap<string, string> form){
int inidaccount = 0;
int inidphone = 0;
bool inenable = false;
bool infromsms = false;
bool infromcall = false;
string innote = "";

if(form.has_key("idphone")){
inidphone = int.parse(form["idphone"]);
}
if(form.has_key("idaccount")){
inidaccount = int.parse(form["idaccount"]);
}
if(form.has_key("enable")){
inenable = bool.parse(form["enable"]);
}
if(form.has_key("fromsms")){
infromsms = bool.parse(form["fromsms"]);
}
if(form.has_key("fromcall")){
infromcall = bool.parse(form["fromcall"]);
}
if(form.has_key("note")){
innote = form["note"];
}

return fun_account_phones_trigger_alarm_table(inidaccount, inidphone, inenable, infromsms, infromcall, innote);
}

//fun_account_phones_trigger_alarm_table(IN inidaccount integer, IN inidphone integer, IN inenable boolean, IN infromsms boolean, IN infromcall boolean, IN innote text, OUT outreturn integer, OUT outpgmsg text)
public SQLFunReturn fun_account_phones_trigger_alarm_table(int inidaccount, int inidphone, bool inenable, bool infromsms, bool infromcall, string innote){

SQLFunReturn Retorno = new SQLFunReturn();
//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
string[] ValuesArray = {inidaccount.to_string(), inidphone.to_string(), inenable.to_string(), infromsms.to_string(), infromcall.to_string(), innote};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_account_phones_trigger_alarm_table($1::integer, $2::integer, $3::boolean, $4::boolean, $5::boolean, $6::text);""",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno.Return = filas["outreturn"].as_int();
Retorno.Msg = filas["outpgmsg"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("Llega hasta aqui 5 \n");
return Retorno;
}

public string AccountPhonesTriggerAlarmViewdbXml_from_hashmap(HashMap<string, string> form){

int idaccount = 0;
int idcontact = 0;

if(form.has_key("idcontact")){
idcontact = int.parse(form["idcontact"]);
}
if(form.has_key("idaccount")){
idaccount = int.parse(form["idaccount"]);
}
return AccountPhonesTriggerAlarmViewdbXml(idaccount, idcontact);
}


public string AccountPhonesTriggerAlarmViewdbXml(int idaccount, int idcontact){
var Rows = XmlDatas.Node("trigger");
foreach(var r in AccountPhonesTriggerAlarmView(idaccount, idcontact)){
Rows->add_child(AccountPhonesTriggerAlarmViewdbNodeXml(r).Row());
}
return XmlDatas.XmlDocToString(Rows);
}

public AccountPhonesTriggerAlarmViewdb[] AccountPhonesTriggerAlarmView(int idaccount, int idcontact){

string[] valuesin = {idaccount.to_string(), idcontact.to_string()};
AccountPhonesTriggerAlarmViewdb[] RetornoX = new AccountPhonesTriggerAlarmViewdb[0];

if(idaccount > 0 && idcontact > 0){

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_account_users_trigger_phones_contacts($1::integer, $2::integer)", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

var Registros = this.Result_FieldName(ref Resultado);

RetornoX = new AccountPhonesTriggerAlarmViewdb[Registros.length];
int i = 0;
foreach(var reg in Registros){
AccountPhonesTriggerAlarmViewdb Registro = AccountPhonesTriggerAlarmViewdb();
Registro.IdAccount = reg["idaccount"].as_int();
Registro.IdContact = reg["idcontact"].as_int();
Registro.IdPhone = reg["idphone"].as_int();
Registro.PhoneEnable = reg["phone_enable"].as_bool();
Registro.Type = reg["type"].as_int();
Registro.IdProvider = reg["idprovider"].as_int();
Registro.Phone = reg["phone"].Value;
Registro.Address = reg["address"].Value;
Registro.TriggerEnable = reg["trigger_alarm"].as_bool();
Registro.SMS = reg["fromsms"].as_bool();
Registro.Call = reg["fromcall"].as_bool();
Registro.Note = reg["note"].Value;

RetornoX[i] = Registro;

i++;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

}

return RetornoX;
}



}

public struct AccountContactRow{
public int IdAccount;
public int IdContact;
public int Priority;
public bool Enable;
public string Appointment;
public string Note;
public string TimeStamp;

public AccountContactRow(){
this.IdAccount = 0;
this.IdContact = 0;
this.Priority = 0;
this.Enable = false;
this.Appointment = "";
this.Note = "";
this.TimeStamp = "";
}

}



public class AccountContactsTable:PostgreSQLConnection{

public string fun_account_contacts_table_from_hasmap(HashMap<string, string> Data, bool fieldtextasbase64 = true){

int idaccount = 0;
int idcontact = 0;
bool enable = false;
int priority = 10;
string  appointment = "";
string note = "";

if(Data.has_key("idaccount")){
idaccount = int.parse(Data["idaccount"]);
}
if(Data.has_key("idcontact")){
idcontact = int.parse(Data["idcontact"]);
}
if(Data.has_key("enable_as_contact")){
enable = bool.parse(Data["enable_as_contact"]);
}
if(Data.has_key("priority")){
priority = int.parse(Data["priority"]);
}
if(Data.has_key("appointment")){
appointment = Data["appointment"];
}
if(Data.has_key("note")){
note = Data["note"];
}

return this.fun_account_contacts_table(idaccount, idcontact, enable, priority, appointment, note, fieldtextasbase64);
}

public string fun_account_contacts_table(int idaccount, int idcontact, bool enable, int priority, string  appointment, string note, bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), idcontact.to_string(), priority.to_string(), enable.to_string(), appointment, note, fieldtextasbase64.to_string()};

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_account_contacts_table_xml($1::integer, $2::integer, $3::integer, $4::boolean, $5::text, $6::text, $7::boolean) AS return", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].Value;
}

}else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

return RetornoX;
}

public string byIdXml(int idaccount, int idcontact, bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()};

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_account_contacts_byid($1::integer, $2::integer, $3::boolean) AS return""", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

return RetornoX;
}

}



public class AccountNotificationsEventtypeTable:PostgreSQLConnection{

public string byIdAccountIdPhone(int idaccount, int idphone, bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), idphone.to_string(), fieldtextasbase64.to_string()};

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_view_account_contact_notif_eventtypes_xml($1::integer, $2::integer, $3::boolean) AS return", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

return RetornoX;
}


}

public class NotificationTemplates:PostgreSQLConnection{

// usaga.fun_notification_templates_edit_xml(inidnotiftempl integer, indescription text, inmessage text, ts timestamp without time zone, fieldtextasbase64 boolean)
public string fun_notification_templates_edit_xml(int idnotiftempl, string description, string message, string ts, bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {idnotiftempl.to_string(), description, message, ts, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_notification_templates_edit_xml($1::integer, $2::text, $3::text, $4::timestamp without time zone, $5::boolean) as return;",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

return Retorno;
}

//usaga.fun_view_notification_templates_xml
public string fun_view_notification_templates_xml(bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {fieldtextasbase64.to_string()};

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_view_notification_templates_xml($1::boolean) AS return""", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
//GLib.print(RetornoX);
return RetornoX;
}


}

public class AccountNotificationsTable:PostgreSQLConnection{

public string byIdContact(int idaccount, int idcontact, bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()};

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_view_account_notif_phones_xml($1::integer, $2::integer, $3::boolean) AS return""", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
//GLib.print(RetornoX);
return RetornoX;
}

public string fun_account_notifications_table_xml_from_hashmap(HashMap<string, string> form, bool fieldtextasbase64 = true){

int idnotifaccount = 0;
int idaccount = 0;
int idphone = 0;
int priority = 10;
bool call = false;
bool sms = false;
string smstext = "";
string note =  "";
string ts = "1990-1-1 00:00"; 

if(form.has_key("idnotifaccount")){
idnotifaccount = int.parse(form["idnotifaccount"]);
}

if(form.has_key("idaccount")){
idaccount = int.parse(form["idaccount"]);
}
if(form.has_key("idphone")){
idphone = int.parse(form["idphone"]);
}
if(form.has_key("priority")){
priority = int.parse(form["priority"]);
}
if(form.has_key("call")){
call = bool.parse(form["call"]);
}
if(form.has_key("sms")){
sms = bool.parse(form["sms"]);
}
if(form.has_key("smstext")){
smstext = form["smstext"];
}
if(form.has_key("note")){
note = form["note"];
}
if(form.has_key("ts")){
ts = form["ts"];
}

return fun_account_notifications_table_xml(idnotifaccount, idaccount, idphone, priority, call, sms, smstext, note, ts, fieldtextasbase64);
}

// usaga.fun_account_notifications_table(IN inidnotifaccount integer, IN inidaccount integer, IN inidphone integer, IN prioinrity integer, IN incall boolean, IN insms boolean, IN insmstext text, IN innote text, IN ints timestamp without time zone, OUT outreturn integer, OUT outpgmsg text)
public string fun_account_notifications_table_xml(int idnotifaccount, int idaccount, int idphone, int priority, bool call, bool sms, string smstext, string note, string ts, bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {idnotifaccount.to_string(), idaccount.to_string(), idphone.to_string(), priority.to_string(), call.to_string(),  sms.to_string(), smstext, note, ts, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_account_notifications_table_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::boolean, $6::boolean, $7::text, $8::text, $9::timestamp without time zone, $10::boolean) AS return;",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
return Retorno;
}

}




public struct AccountUsersViewdb{

public int IdContact;
public bool EnableContact;
public string FirstName;
public string LastName;
public int IdAccount;
public int PriorityContact;
public bool EnableAsContact;
public string Appointment;
public bool EnableAsUser;
public int NumUser;
public string Pwd;
public string KeyWord;

public AccountUsersViewdb(){
this.IdContact = 0;
this.EnableContact = false;
this.FirstName = "";
this.LastName = "";
this.IdAccount = 0;
this.PriorityContact = 0;
this.EnableAsContact = false;
this.Appointment = "";
this.EnableAsUser = false;
this.NumUser = 0;
this.Pwd = "";
this.KeyWord = "";
}


}


public struct AccountContactViewdb{

public int IdContact;
public bool EnableContact;
public string FirstName;
public string LastName;
public int IdAccount;
public int PriorityContact;
public bool EnableAsContact;
public string Appointment;

public AccountContactViewdb(){
this.IdContact = 0;
this.EnableContact = false;
this.FirstName = "";
this.LastName = "";
this.IdAccount = 0;
this.PriorityContact = 0;
this.EnableAsContact = false;
this.Appointment = "";
}


}



public class AccountTable:PostgreSQLConnection{

public static XmlRow AccountUserViewNodeXml(AccountUsersViewdb user){

XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idcontact", user.IdContact);
Fila.addFieldBool("enable", user.EnableContact);
Fila.addFieldString("firstname", user.FirstName, true);
Fila.addFieldString("lastname", user.LastName, true);
Fila.addFieldInt("idaccount", user.IdAccount);
Fila.addFieldInt("prioritycontact", user.PriorityContact);
Fila.addFieldBool("enable_as_contact", user.EnableAsContact);
Fila.addFieldString("appointment", user.Appointment, true);
Fila.addFieldBool("enable_as_user", user.EnableAsUser);
Fila.addFieldInt("numuser", user.NumUser);
Fila.addFieldString("pwd", user.Pwd, true);
Fila.addFieldString("keyword", user.KeyWord, true);

return Fila;
}

public static XmlRow AccountContactViewNodeXml(AccountContactViewdb user){

XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idcontact", user.IdContact);
Fila.addFieldBool("enable", user.EnableContact);
Fila.addFieldString("firstname", user.FirstName, true);
Fila.addFieldString("lastname", user.LastName, true);
Fila.addFieldInt("idaccount", user.IdAccount);
Fila.addFieldInt("prioritycontact", user.PriorityContact);
Fila.addFieldBool("enable_as_contact", user.EnableAsContact);
Fila.addFieldString("appointment", user.Appointment, true);

return Fila;
}

public static XmlRow AccountNodeXml(Accountdb account){

XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idaccount", account.Id);
Fila.addFieldInt("idgroup", account.IdGroup);
Fila.addFieldInt("partition", account.Partition);
Fila.addFieldBool("enable", account.Enable);
Fila.addFieldString("account", account.Account, true);
Fila.addFieldString("name", account.Name, true);
Fila.addFieldInt("type", (int)account.Type);
Fila.addFieldString("note", account.Note, true);

return Fila;
}




public string NameAndId_All_Xml(){

var Rows = XmlDatas.Node("accounts");

foreach(var r in NameAndId_All().entries){
XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idaccount", r.key);
Fila.addFieldString("name", r.value, true);
Rows->add_child(Fila.Row());
}
return XmlDatas.XmlDocToString(Rows);
}

public HashMap<int, string> NameAndId_All(){

string[] valuesin = {"name"};
HashMap<int, string> RetornoX = new HashMap<int, string>();
RetornoX[0] = "Ninguno seleccionado";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT idaccount, name FROM usaga.account ORDER BY $1::text;", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX[reg["idaccount"].as_int()] = reg["name"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

return RetornoX;
}


public string fun_account_notifications_table_xml(int idnotifaccount, int idaccount, int idphone, int priority, bool call, bool sms, string smstext, string note, string ts, bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {idnotifaccount.to_string(), idaccount.to_string(), idphone.to_string(), priority.to_string(), call.to_string(),  sms.to_string(), smstext, note, ts, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_account_notifications_table_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::boolean, $6::boolean, $7::text, $8::text, $9::timestamp without time zone, $10::boolean) AS return;",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
return Retorno;
}

public string  fun_view_account_contacts_xml(int idaccount, bool fieldtextasbase64 = true){

string Retorno = "<table></table>";

string[] ValuesArray = {idaccount.to_string(), fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM  usaga.fun_view_account_contacts_xml($1::integer, $2::boolean) AS return;",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
return Retorno;
}

public string AccountUsersViewXml(int idaccount){
var Rows = XmlDatas.Node("users");
foreach(var r in AccountUsersView(idaccount)){
Rows->add_child(AccountUserViewNodeXml(r).Row());
}
return XmlDatas.XmlDocToString(Rows);
}


public AccountUsersViewdb[] AccountUsersView(int idaccount){

string[] valuesin = {idaccount.to_string()};
AccountUsersViewdb[] RetornoX = new AccountUsersViewdb[0];

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.view_account_users WHERE idaccount = $1 ORDER BY numuser, lastname, firstname", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

//var Etiqueta = new StringBuilder();

var Registros = this.Result_FieldName(ref Resultado);

RetornoX = new AccountUsersViewdb[Registros.length];
int i = 0;
foreach(var reg in Registros){
AccountUsersViewdb Registro = AccountUsersViewdb();
Registro.IdContact = reg["idcontact"].as_int();
Registro.EnableContact = reg["enable"].as_bool();
Registro.FirstName = reg["firstname"].Value;
Registro.LastName = reg["lastname"].Value;
Registro.IdAccount = reg["idaccount"].as_int();
Registro.PriorityContact = reg["prioritycontact"].as_int();
Registro.EnableAsContact = reg["enable_as_contact"].as_bool();
Registro.Appointment = reg["appointment"].Value;
Registro.EnableAsUser = reg["enable_as_user"].as_bool();
Registro.NumUser = reg["numuser"].as_int();
Registro.Pwd = reg["pwd"].Value;
Registro.KeyWord = reg["keyword"].Value;

RetornoX[i] = Registro;

i++;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

return RetornoX;
}

public string byIdXml(int idaccount){
return XmlDatas.XmlDocToString(AccountNodeXml(this.byId(idaccount)).Row());
}

public Accountdb byId(int idaccount){

string[] valuesin = {idaccount.to_string()};
Accountdb Retorno = Accountdb();
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.account WHERE idaccount = $1;""", valuesin.length, null, valuesin, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var reg in this.Result_FieldName(ref Resultado)){

Retorno.Id = reg["idaccount"].as_int();
Retorno.IdGroup = reg["idgroup"].as_int();
Retorno.Partition = reg["partition"].as_int();
Retorno.Enable =  reg["enable"].as_bool();
Retorno.Account = reg["account"].Value;
Retorno.Name = reg["name"].Value;
Retorno.Type = (AccountType)reg["type"].as_int();
Retorno.Note = reg["note"].Value;
//GLib.print("<<<<<<<<<<<<<<<<<<< %s   [%s]\n", Retorno.Enable.to_string(), reg["enable"].Value);
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}

return Retorno;
}


public string fun_account_table_xml_from_hashmap(HashMap<string, string> Data, bool fieldtextasbase64 = true){

Accountdb Cuenta = Accountdb();

if(Data.has_key("idaccount")){
Cuenta.Id = int.parse(Data["idaccount"]);
}

if(Data.has_key("enable")){
Cuenta.Enable = bool.parse(Data["enable"]);
}

if(Data.has_key("account")){
Cuenta.Account = Data["account"];
}
if(Data.has_key("name")){
Cuenta.Name = Data["name"];
}
if(Data.has_key("idgroup")){
Cuenta.IdGroup = int.parse(Data["idgroup"]);
}
if(Data.has_key("partition")){
Cuenta.Partition = int.parse(Data["partition"]);
}
if(Data.has_key("type")){
Cuenta.Type = (AccountType)int.parse(Data["type"]);
}
if(Data.has_key("note")){
Cuenta.Note = Data["note"];
}
//GLib.print("Llega hasta aqui 1 \n");
return fun_account_table_xml(Cuenta.Id, Cuenta.Enable, Cuenta.Account, Cuenta.Name, Cuenta.IdGroup, Cuenta.Partition, Cuenta.Type, Cuenta.Note, fieldtextasbase64);
}

// usaga.fun_account_table(IN inidaccount integer, IN inenable boolean, IN inaccount text, IN inname text, IN inidgroup integer, IN inpartition integer, IN intype integer, IN innote text, OUT outidaccount integer, OUT outpgmsg text)
public string fun_account_table_xml(int inidaccount, bool inenable, string inaccount, string inname, int inidgroup, int inpartition, AccountType intype, string innote, bool fieldtextasbase64 = true){

string Retorno = "";
//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
string[] ValuesArray = {inidaccount.to_string(), inenable.to_string(), inaccount, inname, inidgroup.to_string(), inpartition.to_string(), ((int)intype).to_string(), innote, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("SELECT * FROM usaga.fun_account_table_xml($1::integer, $2::boolean, $3::text, $4::text, $5::integer, $6::integer, $7::integer, $8::text, $9::boolean) as return;",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("%s\n", Retorno);
return Retorno;
}


public SQLFunReturn fun_account_users_add_from_hashmap(HashMap<string, string> Data){

int inidaccount = 0;
int inidcontact = 0;
if(Data.has_key("idaccount")){
inidaccount = int.parse(Data["idaccount"]);
}
if(Data.has_key("idcontact")){
inidcontact = int.parse(Data["idcontact"]);
}

return fun_account_users_add(inidaccount, inidcontact);
}

public SQLFunReturn fun_account_users_add(int inidaccount, int inidcontact){

SQLFunReturn Retorno = new SQLFunReturn();
//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
string[] ValuesArray = {inidaccount.to_string(), inidcontact.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_account_users_add($1::integer, $2::integer);""",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno.Return = filas["outreturn"].as_int();
Retorno.Msg = filas["outpgmsg"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("Llega hasta aqui 5 \n");
return Retorno;
}

//usaga.fun_account_users_table(IN inidaccount integer, IN inidcontact integer, IN inappointment text, IN inenable boolean, IN innumuser integer, IN inkeyword text, IN inpwd text, IN innote text, OUT outreturn integer, OUT outmsg text)
 public SQLFunReturn fun_account_users_table(int inidaccount, int inidcontact, string inappointment, bool inenable, int innumuser, string inkeyword, string inpwd, string  innote = ""){

SQLFunReturn Retorno = new SQLFunReturn();
string[] ValuesArray = {inidaccount.to_string(), inidcontact.to_string(), inappointment, inenable.to_string(), innumuser.to_string(),  inkeyword, inpwd, innote};
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_account_users_table($1::integer, $2::integer, $3::text, $4::boolean, $5::integer, $6::text, $7::text, $8::text);""",  ValuesArray.length, null, ValuesArray, null, null, 0);
    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno.Return = filas["outreturn"].as_int();
Retorno.Msg = filas["outpgmsg"].Value;

//GLib.print("OUT %s => %i\n", filas["outreturn"].Value, filas["outreturn"].as_int());
}
} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("Llega hasta aqui 5 \n");
return Retorno;
}
 


public SQLFunReturn fun_account_users_table_from_hashmap(HashMap<string, string> Data){

AccountUserdb Registro = AccountUserdb();

if(Data.has_key("idaccount")){
Registro.IdAccount = int.parse(Data["idaccount"]);
}
if(Data.has_key("idcontact")){
Registro.IdContact = int.parse(Data["idcontact"]);
}
if(Data.has_key("numuser")){
Registro.NumUser = int.parse(Data["numuser"]);
}
if(Data.has_key("enable")){
Registro.Enable = bool.parse(Data["enable"]);
//GLib.print("Cuenta Habilitada >>>> %s\n \n", Registro.Enable.to_string());
}

if(Data.has_key("keyword")){
Registro.KeyWord = Data["keyword"];
}
if(Data.has_key("pwd")){
Registro.Password = Data["pwd"];
}

if(Data.has_key("appointment")){
Registro.Appointment = Data["appointment"];
}

if(Data.has_key("note")){
Registro.Note = Data["note"];
}
//GLib.print("Llega hasta aqui 1 \n");
return fun_account_users_table(Registro.IdAccount, Registro.IdContact, Registro.Appointment, Registro.Enable, Registro.NumUser, Registro.KeyWord, Registro.Password, Registro.Note);
}




public static XmlRow AccountUserNodeXml(AccountUserdb user){

XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idaccount", user.IdAccount);
Fila.addFieldInt("idcontact", user.IdContact);
Fila.addFieldString("appointment", user.Appointment, true);
Fila.addFieldBool("enable", user.Enable);
Fila.addFieldString("keyword", user.KeyWord, true);
Fila.addFieldString("pwd", user.Password, true);
Fila.addFieldInt("numuser", user.NumUser);
Fila.addFieldString("note", user.Note, true);

return Fila;
}

public string UserbyIdContactXml(int idaccount, int idcontact){
return XmlDatas.XmlDocToString(AccountUserNodeXml(this.UserbyIdContact(idaccount, idcontact)).Row());
}


public AccountUserdb UserbyIdContact(int idaccount, int idcontact){
AccountUserdb Retorno = AccountUserdb();
string[] ValuesArray = {idaccount.to_string(), idcontact.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.account_users WHERE idaccount=$1::integer  AND idcontact=$2::integer LIMIT 1""",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
Retorno.IdAccount = filas["idaccount"].as_int();
Retorno.IdContact = filas["idcontact"].as_int();
Retorno.Enable = filas["enable_as_user"].as_bool();
Retorno.KeyWord = filas["keyword"].Value;
Retorno.Appointment = filas["appointment"].Value;
Retorno.Password = filas["pwd"].Value;
Retorno.NumUser = filas["numuser"].as_int();
Retorno.Note = filas["note_user"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
return Retorno;
}


}





public struct AccountLocationdb{

public int IdAccount;
public double GeoX;
public double GeoY;
public string Address;
public string IdAddress;
public string Note;

public AccountLocationdb(){
this.IdAccount = 0;
this.GeoX = 0;
this.GeoY = 0;
this.Address ="";
this.IdAddress = "";
this.Note = "";
}

}

public class AccountLocationTable:PostgreSQLConnection{


public static XmlRow AccountLocationNodeXml(AccountLocationdb location){

XmlRow Fila = new XmlRow();
Fila.Name = "row";
Fila.addFieldInt("idaccount", location.IdAccount);
Fila.addFieldDouble("geox", location.GeoX);
Fila.addFieldDouble("geoy", location.GeoY);
Fila.addFieldString("address", location.Address, true);
Fila.addFieldString("idaddress", location.IdAddress, false);
Fila.addFieldString("note", location.Note, true);

return Fila;
}


public SQLFunReturn fun_account_location_table_from_hashmap(HashMap<string, string> Data){

AccountLocationdb Registro = AccountLocationdb();

if(Data.has_key("idaccount")){
Registro.IdAccount = int.parse(Data["idaccount"]);
}
if(Data.has_key("geox")){
Registro.GeoX = double.parse(Data["geox"]);
}
if(Data.has_key("geoy")){
Registro.GeoY = double.parse(Data["geoy"]);
}
if(Data.has_key("address")){
Registro.Address = Data["address"];
}
if(Data.has_key("inidaddress")){
Registro.IdAddress = Data["inidaddress"];
}
if(Data.has_key("note")){
Registro.Note = Data["note"];
}

return fun_account_location_table(Registro.IdAccount, Registro.GeoX, Registro.GeoY, Registro.Address, Registro.IdAddress, Registro.Note);
}



//usaga.fun_account_location_table(IN inidaccount integer, IN ingeox real, IN ingeoy real, IN inaddress text, IN inidaddress text, IN innote text, OUT outreturn integer, OUT outpgmsg text)
 public SQLFunReturn fun_account_location_table(int inidaccount, double ingeox, double ingeoy, string inaddress, string inidaddress, string  innote = ""){

SQLFunReturn Retorno = new SQLFunReturn();
//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
string[] ValuesArray = {inidaccount.to_string(), ingeox.to_string(), ingeoy.to_string(), inaddress, inidaddress, innote};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.fun_account_location_table($1::integer, $2::real, $3::real, $4::text, $5::text, $6::text);""",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno.Return = filas["outreturn"].as_int();
Retorno.Msg = filas["outpgmsg"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("Llega hasta aqui 5 \n");
return Retorno;
}


public string LocationbyIdAccountXml(int idaccount){
return XmlDatas.XmlDocToString(AccountLocationNodeXml(this.LocationbyIdAccount(idaccount)).Row());
}

public AccountLocationdb LocationbyIdAccount(int idaccount){
AccountLocationdb Retorno = AccountLocationdb();
Retorno.IdAccount = idaccount;
if(idaccount > 0){
//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
string[] ValuesArray = {idaccount.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
var Resultado = Conexion.exec_params ("""SELECT * FROM usaga.account_location WHERE idaccount=$1::integer LIMIT 1""",  ValuesArray.length, null, ValuesArray, null, null, 0);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
//GLib.print("Llega hasta aqui 4 \n");
foreach(var filas in this.Result_FieldName(ref Resultado)){
Retorno.IdAccount = filas["idaccount"].as_int();
Retorno.GeoX = filas["geox"].as_double();
Retorno.GeoY = filas["geoy"].as_double();
Retorno.Address = filas["address"].Value;
Retorno.IdAddress = filas["idaddress"].Value;
Retorno.Note = filas["note"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
}
return Retorno;
}

}





}









