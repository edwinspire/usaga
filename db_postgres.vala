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



public class EventTypesTable:PostgreSQLConnection{


public string  fun_eventtypes_edit_xml_from_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true){

int ideventtype = 0;
int priority = 0;
string label = "";
bool accountdefault = false;
bool groupdefault = false;
string note = "";
string ts = "1990-01-01";

if(data.has_key("ideventtype")){
ideventtype = int.parse(data["ideventtype"]);
}

if(data.has_key("priority")){
priority = int.parse(data["priority"]);
}

if(data.has_key("label")){
label = data["label"];
}

if(data.has_key("accountdefault")){
accountdefault = bool.parse(data["accountdefault"]);
}

if(data.has_key("groupdefault")){
groupdefault = bool.parse(data["groupdefault"]);
}

if(data.has_key("note")){
note = data["note"];
}

if(data.has_key("ts")){
ts = data["ts"];
}
return fun_eventtypes_edit_xml(ideventtype, priority, label, accountdefault, groupdefault, note, ts, fieldtextasbase64);
}

//usaga.fun_eventtypes_edit_xml(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, innote text, ints timestamp without time zone, fieldtextasbase64 boolean)



public string  fun_eventtypes_edit_xml(int ideventtype, int priority, string label, bool accountdefault, bool groupdefault, string note, string ts, bool fieldtextasbase64 = true){

string Retorno = "<table></table>";

string[] ValuesArray = {ideventtype.to_string(), priority.to_string(), label, accountdefault.to_string(), groupdefault.to_string(), note, ts,  fieldtextasbase64.to_string()};

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM  usaga.fun_eventtypes_edit_xml($1::integer, $2::integer, $3::text, $4::boolean, $5::boolean, $6::text, $7::timestamp without time zone, $8::boolean) AS return;",  ValuesArray);

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

public string fun_view_eventtypes_xml(bool fieldtextasbase64 = true){
string RetornoX = "<table></table>";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {fieldtextasbase64.to_string()};

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_eventtypes_xml($1::boolean) AS return;", valuesin);

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
//GLib.print("fun_events_lastid_xml >>> \n%s\n", RetornoX);
return RetornoX;
}

}

public class EventTable:PostgreSQLConnection{

public EventTable(){

}



public string fun_events_lastid_xml(){
string RetornoX = "<table></table>";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {};

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_events_lastid_xml() AS return", valuesin);

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
//GLib.print("fun_events_lastid_xml >>> \n%s\n", RetornoX);
return RetornoX;
}


public string byIdAccount_xml(int idaccount, string start, string end,  bool fieldtextasbase64 = true){
string RetornoX = "<table></table>";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), start, end, fieldtextasbase64.to_string()};

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_events_xml($1::integer, $2::timestamp without time zone, $3::timestamp without time zone, $4::boolean) AS return", valuesin);

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

public string LastXml(int rows = 100, bool fieldtextasbase64 = true){
string RetornoX = "<table></table>";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {rows.to_string(), fieldtextasbase64.to_string()};

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_last_events_xml($1::integer, $2::boolean) AS return", valuesin);

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

public class GroupsTable:PostgreSQLConnection{


public string fun_groups_remove_selected_xml(string idgroups, bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {"{"+idgroups+"}", fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_groups_remove_selected_xml($1::integer[], $2::boolean) AS return;",  ValuesArray);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
foreach(var filas in this.Result_FieldName(ref Resultado)){
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
return Retorno;
}

public string fun_view_idgroup_name_xml(bool fieldtextasbase64 = true){

string[] valuesin = {fieldtextasbase64.to_string()};
string RetornoX = "<table></table>";


var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_idgroup_name_xml($1::boolean) as return;", valuesin);

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

//GLib.print("%s\n", RetornoX);
return RetornoX;
}

public string fun_view_groups_xml(bool fieldtextasbase64 = true){

string[] valuesin = {fieldtextasbase64.to_string()};
string RetornoX = "<table></table>";


var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_groups_xml($1::boolean) as return;", valuesin);

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

//GLib.print("%s\n", RetornoX);
return RetornoX;
}


public string fun_groups_edit_xml_from_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true){

int idgroup = 0;
bool enable = false;
string name = "";
string note = "";
string ts = "1990-01-01";

if(data.has_key("idgroup")){
idgroup = int.parse(data["idgroup"]);
}

if(data.has_key("enable")){
enable = bool.parse(data["enable"]);
}

if(data.has_key("name")){
name = data["name"];
}

if(data.has_key("note")){
note = data["note"];
}

if(data.has_key("ts")){
ts = data["ts"];
}

return fun_groups_edit_xml(idgroup, enable, name, note, ts, fieldtextasbase64);
}

//usaga.fun_groups_edit_xml(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean)
public string fun_groups_edit_xml(int idgroup, bool enable, string name, string note, string ts, bool fieldtextasbase64 = true){

string[] valuesin = {idgroup.to_string(), enable.to_string(), name, note, ts, fieldtextasbase64.to_string()};
string RetornoX = "<table></table>";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_groups_edit_xml($1::integer, $2::boolean, $3::text, $4::text, $5::timestamp without time zone, $6::boolean) as return;", valuesin);

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

public string fun_account_phones_trigger_alarm_table_from_hashmap(HashMap<string, string> form, bool fieldtextasbase64 = true){
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

return fun_account_phones_trigger_alarm_table(inidaccount, inidphone, inenable, infromsms, infromcall, innote, fieldtextasbase64);
}

//fun_account_phones_trigger_alarm_table(IN inidaccount integer, IN inidphone integer, IN inenable boolean, IN infromsms boolean, IN infromcall boolean, IN innote text, OUT outreturn integer, OUT outpgmsg text)
public string fun_account_phones_trigger_alarm_table(int inidaccount, int inidphone, bool inenable, bool infromsms, bool infromcall, string innote, bool fieldtextasbase64 = true){

string Retorno = "<table></table>";
string[] ValuesArray = {inidaccount.to_string(), inidphone.to_string(), inenable.to_string(), infromsms.to_string(), infromcall.to_string(), innote, fieldtextasbase64.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_phones_trigger_alarm_table_xml($1::integer, $2::integer, $3::boolean, $4::boolean, $5::boolean, $6::text, $7::boolean) as return;",  ValuesArray);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
foreach(var reg in this.Result_FieldName(ref Resultado)){
Retorno = reg["return"].Value;
}
} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("Llega hasta aqui 5 \n");
return Retorno;
}

public string AccountPhonesTriggerAlarmViewdbXml_from_hashmap(HashMap<string, string> form, bool fieldtextasbase64 = true){

int idaccount = 0;
int idcontact = 0;

if(form.has_key("idcontact")){
idcontact = int.parse(form["idcontact"]);
}
if(form.has_key("idaccount")){
idaccount = int.parse(form["idaccount"]);
}
return fun_view_account_users_trigger_phones_contacts_xml(idaccount, idcontact, fieldtextasbase64);
}


public string fun_view_account_users_trigger_phones_contacts_xml(int idaccount, int idcontact, bool fieldtextasbase64 = true){

string[] valuesin = {idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()};
string RetornoX = "<table></table>";

if(idaccount > 0 && idcontact > 0){

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_users_trigger_phones_contacts_xml($1::integer, $2::integer, $3::boolean) as return;", valuesin);

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

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_contacts_table_xml($1::integer, $2::integer, $3::integer, $4::boolean, $5::text, $6::text, $7::boolean) AS return", valuesin);

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

var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_account_contacts_byid($1::integer, $2::integer, $3::boolean) AS return""", valuesin);

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

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_contact_notif_eventtypes_xml($1::integer, $2::integer, $3::boolean) AS return", valuesin);

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

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_notification_templates_edit_xml($1::integer, $2::text, $3::text, $4::timestamp without time zone, $5::boolean) as return;",  ValuesArray);

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

var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_view_notification_templates_xml($1::boolean) AS return""", valuesin);

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

var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_view_account_notif_phones_xml($1::integer, $2::integer, $3::boolean) AS return""", valuesin);

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

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_notifications_table_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::boolean, $6::boolean, $7::text, $8::text, $9::timestamp without time zone, $10::boolean) AS return;",  ValuesArray);

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

public string fun_account_notifications_applyselected_xml_from_hasmap(HashMap<string, string> data, bool fieldtextasbase64 = true){

int idaccount = 0;
string arrayidphones = "";
bool call = false;
bool sms = false;
string msg = "";

if(data.has_key("idaccount")){
idaccount = int.parse(data["idaccount"]);
}

if(data.has_key("idphones")){
arrayidphones = data["idphones"];
}

if(data.has_key("call")){
call = bool.parse(data["call"]);
}

if(data.has_key("sms")){
sms = bool.parse(data["sms"]);
}

if(data.has_key("msg")){
msg = data["msg"];
}

return fun_account_notifications_applyselected_xml(idaccount, arrayidphones, call, sms, msg, fieldtextasbase64);
}

public string fun_account_notify_applied_to_selected_contacts_xml_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true){

int idaccount = 0;
string arrayidcontacts = "";
bool call = false;
bool sms = false;
string msg = "";

if(data.has_key("idaccount")){
idaccount = int.parse(data["idaccount"]);
}

if(data.has_key("idcontacts")){
arrayidcontacts = data["idcontacts"];
}

if(data.has_key("call")){
call = bool.parse(data["call"]);
}

if(data.has_key("sms")){
sms = bool.parse(data["sms"]);
}

if(data.has_key("msg")){
msg = data["msg"];
}
return fun_account_notify_applied_to_selected_contacts_xml(idaccount, arrayidcontacts, call, sms, msg, fieldtextasbase64);
}

public string fun_account_notify_applied_to_selected_contacts_xml(int idaccount, string arrayidcontacts, bool call, bool sms, string msg, bool fieldtextasbase64 = true){

string Retorno = "";

if(arrayidcontacts.length > 0){

string[] ValuesArray = {idaccount.to_string(), "{"+arrayidcontacts+"}", call.to_string(), sms.to_string(), msg, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_notify_applied_to_selected_contacts_xml($1::integer, $2::integer[], $3::boolean, $4::boolean, $5::text, $6::boolean) AS return;",  ValuesArray);

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

}else{
if(fieldtextasbase64){
Retorno = "<table><row>  <outreturn>0</outreturn>"+Base64.encode("No ha seleccionado ningún contacto para aplicar los cambios.".data)+"<outpgmsg></outpgmsg></row></table>";
}else{
Retorno = "<table><row>  <outreturn>0</outreturn>No ha seleccionado ningún contacto para aplicar los cambios.<outpgmsg></outpgmsg></row></table>";
}
}

return Retorno;
}

public string fun_account_notifications_applyselected_xml(int idaccount, string arrayidphones, bool call, bool sms, string msg, bool fieldtextasbase64 = true){

string Retorno = "";

if(arrayidphones.length > 0){

string[] ValuesArray = {idaccount.to_string(), "{"+arrayidphones+"}", call.to_string(), sms.to_string(), msg, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_notifications_applyselected_xml($1::integer, $2::integer[], $3::boolean, $4::boolean, $5::text, $6::boolean) AS return;",  ValuesArray);

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

}else{

if(fieldtextasbase64){
Retorno = "<table><row>  <outreturn>0</outreturn>"+Base64.encode("No ha seleccionado ningún teléfono para aplicar los cambios.".data)+"<outpgmsg></outpgmsg></row></table>";
}else{
Retorno = "<table><row>  <outreturn>0</outreturn>No ha seleccionado ningún teléfono para aplicar los cambios.<outpgmsg></outpgmsg></row></table>";
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

public string  fun_account_address_edit_xml_from_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true){ 

int idaccount = 0;

if(data.has_key("idaccount")){
idaccount = int.parse(data["idaccount"]);
}
AddressRowData RowData = AddressTable.rowdata_from_hashmap(data);

return fun_account_address_edit_xml(idaccount, RowData.idlocation, RowData.geox, RowData.geoy, RowData.f1, RowData.f2, RowData.f3, RowData.f4, RowData.f5, RowData.f6, RowData.f7, RowData.f8, RowData.f9, RowData.f10, RowData.ts, fieldtextasbase64);
}

public string  fun_account_address_edit_xml(int idcontact, int inidlocation, double ingeox, double ingeoy, string f1, string f2, string f3, string f4, string f5, string f6, string f7, string f8, string f9, string f10, string ints, bool fieldtextasbase64 = true){
string RetornoX = "";
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {idcontact.to_string(), inidlocation.to_string(), ingeox.to_string(), ingeoy.to_string(), f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, ints, fieldtextasbase64.to_string()};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM  usaga.fun_account_address_edit_xml($1::integer, $2::integer, $3::double precision, $4::double precision, $5::text, $6::text,  $7::text, $8::text, $9::text, $10::text, $11::text, $12::text, $13::text, $14::text, $15::timestamp without time zone, $16::boolean) AS return;", valuesin);
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

public string fun_view_idaccounts_names_xml(bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion,  "SELECT * FROM usaga.fun_view_idaccounts_names_xml($1::boolean) AS return;",  ValuesArray);

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


public string fun_view_account_location_byid_xml(int idaccount, bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {idaccount.to_string(), fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion,  "SELECT * FROM usaga.fun_view_account_location_byid_xml($1::integer, $2::boolean) AS return;",  ValuesArray);

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


public string fun_account_notifications_table_xml(int idnotifaccount, int idaccount, int idphone, int priority, bool call, bool sms, string smstext, string note, string ts, bool fieldtextasbase64 = true){

string Retorno = "";

string[] ValuesArray = {idnotifaccount.to_string(), idaccount.to_string(), idphone.to_string(), priority.to_string(), call.to_string(),  sms.to_string(), smstext, note, ts, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion,  "SELECT * FROM usaga.fun_account_notifications_table_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::boolean, $6::boolean, $7::text, $8::text, $9::timestamp without time zone, $10::boolean) AS return;",  ValuesArray);

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

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM  usaga.fun_view_account_contacts_xml($1::integer, $2::boolean) AS return;",  ValuesArray);

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

public string fun_view_account_users_xml(int inidaccount, bool fieldtextasbase64 = true){

string Retorno = "";
string[] ValuesArray = {inidaccount.to_string(), fieldtextasbase64.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_users_xml($1::integer, $2::boolean) as return;",  ValuesArray);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var filas in this.Result_FieldName(ref Resultado)){
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
//GLib.print("%s\n", Retorno);
return Retorno;
}


public string fun_view_account_byid_xml(int inidaccount, bool fieldtextasbase64 = true){

string Retorno = "";
string[] ValuesArray = {inidaccount.to_string(), fieldtextasbase64.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_byid_xml($1::integer, $2::boolean) as return;",  ValuesArray);

    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var filas in this.Result_FieldName(ref Resultado)){
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}
//GLib.print("%s\n", Retorno);
return Retorno;
}



public string fun_account_table_xml_from_hashmap(HashMap<string, string> Data, bool fieldtextasbase64 = true){

int Id = 0;
bool Enable = false;
string Account = "";
string Name = "";
int IdGroup = 0;
int Partition = 0;
int Type = 0;
int IdAddress = 0;
string Note = "";

if(Data.has_key("idaccount")){
Id = int.parse(Data["idaccount"]);
}

if(Data.has_key("idaddress")){
IdAddress = int.parse(Data["idaddress"]);
}


if(Data.has_key("enable")){
Enable = bool.parse(Data["enable"]);
}

if(Data.has_key("account")){
Account = Data["account"];
}
if(Data.has_key("name")){
Name = Data["name"];
}
if(Data.has_key("idgroup")){
IdGroup = int.parse(Data["idgroup"]);
}
if(Data.has_key("partition")){
Partition = int.parse(Data["partition"]);
}
if(Data.has_key("type")){
Type = int.parse(Data["type"]);
}
if(Data.has_key("note")){
Note = Data["note"];
}

//GLib.print("Llega hasta aqui 1 \n");
return fun_account_table_xml(Id, Enable, Account, Name, IdGroup, Partition, Type, IdAddress, Note, fieldtextasbase64);
}

// usaga.fun_account_table(IN inidaccount integer, IN inenable boolean, IN inaccount text, IN inname text, IN inidgroup integer, IN inpartition integer, IN intype integer, IN innote text, OUT outidaccount integer, OUT outpgmsg text)
public string fun_account_table_xml(int inidaccount, bool inenable, string inaccount, string inname, int inidgroup, int inpartition, int intype, int inidaddress, string innote, bool fieldtextasbase64 = true){

string Retorno = "";
//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
string[] ValuesArray = {inidaccount.to_string(), inenable.to_string(), inaccount, inname, inidgroup.to_string(), inpartition.to_string(), intype.to_string(), inidaddress.to_string(), innote, fieldtextasbase64.to_string()};
//GLib.print("Llega hasta aqui 3 \n");
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_table_xml($1::integer, $2::boolean, $3::text, $4::text, $5::integer, $6::integer, $7::integer, $8::integer, $9::text, $10::boolean) as return;",  ValuesArray);

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

var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_account_users_add($1::integer, $2::integer);""",  ValuesArray);

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
 public string fun_account_users_table_xml(int inidaccount, int inidcontact, string inappointment, bool inenable, int innumuser, string inkeyword, string inpwd, string  innote = "", bool fieldtextasbase64 = true){

string Retorno = "<table></table>";
string[] ValuesArray = {inidaccount.to_string(), inidcontact.to_string(), inappointment, inenable.to_string(), innumuser.to_string(),  inkeyword, inpwd, innote, fieldtextasbase64.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_users_table_xml($1::integer, $2::integer, $3::text, $4::boolean, $5::integer, $6::text, $7::text, $8::text, $9::boolean) as return;",  ValuesArray);
    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {

foreach(var filas in this.Result_FieldName(ref Resultado)){
//Retorno = int.parse(filas["fun_smsout_insert"]);
Retorno = filas["return"].Value;
}

} else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }

}

//GLib.print("Llega hasta aqui 5 \n");
return Retorno;
}
 


public string fun_account_users_table_xml_from_hashmap(HashMap<string, string> Data, bool fieldtextasbase64 = true){

int IdAccount = 0;
int IdContact = 0;
string Appointment = "";
bool Enable = false;
int NumUser = 0;
string KeyWord = "";
string Password = "";
string Note = "";

if(Data.has_key("idaccount")){
IdAccount = int.parse(Data["idaccount"]);
}
if(Data.has_key("idcontact")){
IdContact = int.parse(Data["idcontact"]);
}
if(Data.has_key("numuser")){
NumUser = int.parse(Data["numuser"]);
}
if(Data.has_key("enable")){
Enable = bool.parse(Data["enable"]);
}

if(Data.has_key("keyword")){
KeyWord = Data["keyword"];
}
if(Data.has_key("pwd")){
Password = Data["pwd"];
}

if(Data.has_key("appointment")){
Appointment = Data["appointment"];
}

if(Data.has_key("note")){
Note = Data["note"];
}
return fun_account_users_table_xml(IdAccount, IdContact, Appointment, Enable, NumUser, KeyWord, Password, Note, fieldtextasbase64);
}

public string fun_view_account_user_byidaccountidcontact_xml(int idaccount, int idcontact, bool fieldtextasbase64 = true){
string Retorno = "<table></table>";
string[] ValuesArray = {idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()};
var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_user_byidaccountidcontact_xml($1::integer, $2::integer, $3::boolean) AS return;",  ValuesArray);

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


public string fun_view_account_unregistered_contacts_xml(int idaccount, bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), fieldtextasbase64.to_string()};

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_unregistered_contacts_xml($1::integer, $2::boolean) AS return;", valuesin);

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


public string fun_view_account_unregistered_users_xml(int idaccount, bool fieldtextasbase64 = true){

string RetornoX = "";

var  Conexion = Postgres.connect_db (this.ConnString());

if(Conexion.get_status () == ConnectionStatus.OK){

string[] valuesin = {idaccount.to_string(), fieldtextasbase64.to_string()};

var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_unregistered_users_xml($1::integer, $2::boolean) AS return;", valuesin);

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





}






