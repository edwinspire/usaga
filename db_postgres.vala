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
using edwinspire.uHttp;
namespace edwinspire.uSAGA {
	public struct EventViewdb {
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
		public EventViewdb() {
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
	public struct AccountUserdb {
		public int IdAccount;
		public int IdContact;
		public int NumUser;
		public string Appointment;
		public bool Enable;
		public string KeyWord;
		public string Password;
		public string Note;
		public AccountUserdb() {
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
		public Accountdb() {
			this.Id = 0;
			this.IdGroup = 0;
			this.Partition = 0;
			this.Enable = false;
			this.Account = "";
			this.Name = "";
			this.Type = AccountType.Unknown;
			this.Note = "";
		}
		public Accountdb.with_args(int ID, bool Enable, int IDGroup, string Account, string Name, int Partition, AccountType Type, string Note) {
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
	public class EventTypesTable:PostgreSQLConnection {
		public void fun_eventtype_default() {
			int Retorno = -1;
			string[] valuessms = new string[2];
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				EnumClass enum_class = (EnumClass) typeof(EventType).class_ref ();
				foreach(var item in enum_class.values) {
					valuessms[0] = item.value.to_string();
					valuessms[1] = item.value_nick;
					var Resultado = this.exec_params_minimal (ref Conexion, """SELECT usaga.fun_eventtype_default($1::integer, $2::text);""",  valuessms);
					if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
						foreach(var filas in this.Result_FieldName(ref Resultado)) {
							Retorno = filas["fun_eventtype_default"].as_int();
						}
					} else {
						stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
					}
				}
			}
		}
		/*
public bool is_changed(){
bool RetornoX = false;
var new_ts = this.old_ts;
var new_rows = this.old_rows;
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts, (SELECT COUNT(*) FROM usaga.eventtypes) AS rows FROM usaga.eventtypes ORDER BY ts DESC LIMIT 1;", valuesin);
    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
foreach(var reg in this.Result_FieldName(ref Resultado)){
new_ts = reg["ts"].Value;
new_rows = reg["rows"].as_int();
}
}else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }
}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
if(this.old_rows != new_rows || this.old_ts != new_ts){
RetornoX = true;
this.old_rows = new_rows;
this.old_ts = new_ts;
}
return RetornoX;
}
*/
		/*
public string last_ts(){
string RetornoX = "2000-01-01 00:00";
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts AS return FROM usaga.eventtypes ORDER BY ts DESC LIMIT 1;", valuesin);
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
*/
		public string  fun_eventtypes_edit_xml_from_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true) {
			int ideventtype = 0;
			int priority = 0;
			string label = "";
			bool accountdefault = false;
			bool groupdefault = false;
			bool manual = false;
			bool treatment = false;
			bool enable_datetime = false;
			string note = "";
			string ts = "1990-01-01";
			int na_timeout = 10;
			bool na_closable = false;
			string na_img = "";
			string na_snd = "";
			if(data.has_key("ideventtype")) {
				ideventtype = int.parse(data["ideventtype"]);
			}
			if(data.has_key("priority")) {
				priority = int.parse(data["priority"]);
			}
			if(data.has_key("na_closable")) {
				na_closable = bool.parse(data["na_closable"]);
			}
			if(data.has_key("accountdefault")) {
				accountdefault = bool.parse(data["accountdefault"]);
			}
			if(data.has_key("na_img")) {
				na_img = data["na_img"];
			}
			if(data.has_key("na_snd")) {
				na_snd = data["na_snd"];
			}
			if(data.has_key("na_timeout")) {
				na_timeout = int.parse(data["na_timeout"]);
			}
			if(data.has_key("label")) {
				label = data["label"];
			}
			if(data.has_key("accountdefault")) {
				accountdefault = bool.parse(data["accountdefault"]);
			}
			if(data.has_key("groupdefault")) {
				groupdefault = bool.parse(data["groupdefault"]);
			}
			if(data.has_key("manual")) {
				manual = bool.parse(data["manual"]);
			}
			if(data.has_key("treatment")) {
				treatment = bool.parse(data["treatment"]);
			}
			if(data.has_key("enable_datetime")) {
				enable_datetime = bool.parse(data["enable_datetime"]);
			}
			if(data.has_key("note")) {
				note = data["note"];
			}
			if(data.has_key("ts")) {
				ts = data["ts"];
			}
			return fun_eventtypes_edit_xml(ideventtype, priority, label, accountdefault, groupdefault, manual, treatment, enable_datetime, na_timeout, na_closable, na_img, na_snd,  note, ts, fieldtextasbase64);
		}
		//usaga.fun_eventtypes_edit_xml(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, innote text, ints timestamp without time zone, fieldtextasbase64 boolean)
		//CREATE OR REPLACE FUNCTION usaga.fun_eventtypes_edit_xml(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, inmanual boolean, intreatment boolean, inenable_datetime boolean, inna_timeout integer, inna_closable boolean, inna_img text, inna_snd text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean)
		public string  fun_eventtypes_edit_xml(int ideventtype, int priority, string label, bool accountdefault, bool groupdefault, bool manual, bool treatment, bool enable_datetime,  int na_timeout, bool na_closable, string na_img, string na_snd, string note, string ts, bool fieldtextasbase64 = true) {
			string Retorno = "<table></table>";
			string[] ValuesArray = {
				ideventtype.to_string(), priority.to_string(), label, accountdefault.to_string(), groupdefault.to_string(), manual.to_string(), treatment.to_string(), enable_datetime.to_string(), na_timeout.to_string(), na_closable.to_string(), na_img, na_snd, note, ts,  fieldtextasbase64.to_string()
			}
			;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM  usaga.fun_eventtypes_edit_xml($1::integer, $2::integer, $3::text, $4::boolean, $5::boolean, $6::boolean, $7::boolean, $8::boolean, $9::integer, $10::boolean, $11::text, $12::text, $13::text, $14::timestamp without time zone, $15::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					//GLib.print("Llega hasta aqui 4 \n");
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string fun_view_eventtypes_xml(bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_eventtypes_xml($1::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("fun_events_lastid_xml >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		// 
		public string fun_eventtypes_xml(int manual = 0, bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					manual.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_eventtypes_xml($1::integer, $2::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("fun_events_lastid_xml >>> \n%s\n", RetornoX);
			return RetornoX;
		}
	}
	public class EventCommentTable:PostgreSQLConnection {
		public EventCommentTable() {
		}
		/*
public bool is_changed(){
bool RetornoX = false;
var new_ts = this.old_ts;
var new_rows = this.old_rows;
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts, (SELECT COUNT(*) FROM usaga.events_comments) AS rows FROM usaga.events_comments ORDER BY ts DESC LIMIT 1;", valuesin);
    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
foreach(var reg in this.Result_FieldName(ref Resultado)){
new_ts = reg["ts"].Value;
new_rows = reg["rows"].as_int();
}
}else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }
}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
if(this.old_rows != new_rows || this.old_ts != new_ts){
RetornoX = true;
this.old_rows = new_rows;
this.old_ts = new_ts;
}
return RetornoX;
}
*/
		/*
public string last_ts(){
string RetornoX = "2000-01-01 00:00";
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts AS return FROM usaga.events_comments ORDER BY ts DESC LIMIT 1;", valuesin);
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
*/
		public string fun_event_comment_insert_xml(int idevent, int idadmin, int seconds, int status, string comment, int[] idattachs, bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				StringBuilder s = new StringBuilder("{ ");
				foreach(var x in idattachs) {
					s.append_printf("%i,", x);
				}
				s.truncate(s.len-1);
				s.append("}");
				//GLib.print(s.str);
				string[] valuesin = {
					idevent.to_string(), idadmin.to_string(), seconds.to_string(), status.to_string(), comment, s.str, fieldtextasbase64.to_string()
				}
				;
				//GLib.print(comment);
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_event_comment_insert_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::text, $6::integer[], $7::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("Hasta aqui ok\n");
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		
		public string fun_view_events_comments_xml(int idevent, bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idevent.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_events_comments_xml($1::integer, $2::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("Hasta aqui ok\n");
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
	}
	
	
	public class EventTable:PostgreSQLConnection {
		public EventTable() {
		}
		
		public string fun_view_accounts_events_reports_xml(HashMap<string, string> data, bool fieldtextasbase64 = true) {
		
		string idaccounts = "";
		string ideventtypes = "";
		string start = "";
		string end = "";
		
		if(data.has_key("idaccounts")) {
				idaccounts = data["idaccounts"];
			}
			if(data.has_key("ideventtypes")) {
				ideventtypes = data["ideventtypes"];
			}
			if(data.has_key("start")) {
				start = data["start"];
			}
			if(data.has_key("end")) {
				end = data["end"];
			}
			if(data.has_key("b64")) {
				fieldtextasbase64 = bool.parse(data["b64"]);
			}
		
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccounts, ideventtypes, start, end, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_accounts_events_reports_xml($1::integer[], $2::integer[], $3::timestamp without time zone, $4::timestamp without time zone, $5::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		
		
		// TODO Posiblemente esta funcion no se vaya a usar
		public string fun_view_accounts_events_only_idevents_xml(HashMap<string, string> data, bool fieldtextasbase64 = true) {
		
		string idaccounts = "";
		string ideventtypes = "";
		string start = "";
		string end = "";
		
		if(data.has_key("idaccounts")) {
				idaccounts = data["idaccounts"];
			}
			if(data.has_key("ideventtypes")) {
				ideventtypes = data["ideventtypes"];
			}
			if(data.has_key("start")) {
				start = data["start"];
			}
			if(data.has_key("end")) {
				end = data["end"];
			}
			if(data.has_key("b64")) {
				fieldtextasbase64 = bool.parse(data["b64"]);
			}		
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					"{"+idaccounts+"}", "{"+ideventtypes+"}", start, end, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_accounts_events_only_idevents_xml($1::integer[], $2::integer[], $3::timestamp without time zone, $4::timestamp without time zone, $5::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}	
		
		/**
		* This method gets an array with all idevents obtained according to the filters passed as parameter
		*/
		public string fun_view_accounts_events_only_idevents(HashMap<string, string> data, bool fieldtextasbase64 = true) {
		
		string idaccounts = "";
		string ideventtypes = "";
		string start = "";
		string end = "";
		
		    if(data.has_key("idaccounts")) {
				idaccounts = data["idaccounts"];
			}
			if(data.has_key("ideventtypes")) {
				ideventtypes = data["ideventtypes"];
			}
			if(data.has_key("start")) {
				start = data["start"];
			}
			if(data.has_key("end")) {
				end = data["end"];
			}
			if(data.has_key("b64")) {
				fieldtextasbase64 = bool.parse(data["b64"]);
			}	
			
			string RetornoX = "{0,0}";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {"{"+idaccounts+"}", "{"+ideventtypes+"}", start, end};
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_accounts_events_only_idevents($1::integer[], $2::integer[], $3::timestamp without time zone, $4::timestamp without time zone) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}		
		
		
		
			
		/*
public bool is_changed(){
bool RetornoX = false;
var new_ts = this.old_ts;
var new_rows = this.old_rows;
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts, (SELECT COUNT(*) FROM usaga.events) AS rows FROM usaga.events ORDER BY ts DESC LIMIT 1;", valuesin);
    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
foreach(var reg in this.Result_FieldName(ref Resultado)){
new_ts = reg["ts"].Value;
new_rows = reg["rows"].as_int();
}
}else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }
}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
if(this.old_rows != new_rows || this.old_ts != new_ts){
RetornoX = true;
this.old_rows = new_rows;
this.old_ts = new_ts;
}
return RetornoX;
}
*/
		/*
public string last_ts(){
string RetornoX = "2000-01-01 00:00";
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts AS return FROM usaga.events ORDER BY ts DESC LIMIT 1;", valuesin);
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
*/
		public string fun_event_insert_manual_xml(HashMap<string, string> data) {
			string RetornoX = "<table></table>";
			int idaccount = 0;
			string code = "00";
			int zu = 0;
			int priority = 100;
			string description  = "";
			int ideventtype = 0;
			bool fieldtextasbase64 = true;
			string date = "2000-01-01 00:00";
			string note = "";
			if(data.has_key("idaccount")) {
				idaccount = int.parse(data["idaccount"]);
			}
			if(data.has_key("code")) {
				code = data["code"];
			}
			if(data.has_key("zu")) {
				zu = int.parse(data["zu"]);
			}
			if(data.has_key("priority")) {
				priority = int.parse(data["priority"]);
			}
			if(data.has_key("description")) {
				description = data["description"];
			}
			if(data.has_key("ideventtype")) {
				ideventtype = int.parse(data["ideventtype"]);
			}
			if(data.has_key("date")) {
				date = data["date"];
			}
			if(data.has_key("fieldtextasbase64")) {
				fieldtextasbase64 = bool.parse(data["fieldtextasbase64"]);
			}
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), code, zu.to_string(), priority.to_string(), description, ideventtype.to_string(), date, note, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_event_insert_manual_xml($1::integer, $2::text, $3::integer, $4::integer, $5::text, $6::integer, $7::timestamp without time zone, $8::text, $9::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		public string fun_view_events_xml_from_hashmap(HashMap<string, string> data) {
			//int idaccount = 0;
			string start = "2000-01-01 00:00";
			string end  = new GLib.DateTime.now_local().to_string();
			int rows = 100;
			int function = 0;
			bool fieldtextasbase64 = true;
			string idaccounts = "";
			int prioritymin = 1;
			int prioritymax = 100;
			string status = "";
			string ideventtypes = "";
			if(data.has_key("idaccounts")) {
				idaccounts = data["idaccounts"];
			}
			if(data.has_key("start")) {
				start = data["start"];
			}
			if(data.has_key("end")) {
				end = data["end"];
			}
			if(data.has_key("f")) {
				function = int.parse(data["f"]);
			}
			if(data.has_key("prioritymin")) {
				prioritymin = int.parse(data["prioritymin"]);
			}
			if(data.has_key("prioritymax")) {
				prioritymax = int.parse(data["prioritymax"]);
			}
			if(data.has_key("status")) {
				status = data["status"];
			}
			if(data.has_key("ideventtypes")) {
				ideventtypes = data["ideventtypes"];
			}
			if(data.has_key("rows")) {
				rows = int.parse(data["rows"]);
			}
			if(data.has_key("fieldtextasbase64")) {
				fieldtextasbase64 = bool.parse(data["fieldtextasbase64"]);
			}
			return fun_view_events_xml(idaccounts, start, end, function, rows, ideventtypes, status, prioritymin, prioritymax,  fieldtextasbase64);
		}
		public string fun_view_events_xml(string idaccounts, string datestart, string dateend, int function, int rows, string ideventtypes, string status, int prioritymin, int prioritymax,  bool fieldtextasbase64) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					"{"+idaccounts+"}", datestart, dateend, function.to_string(), rows.to_string(), "{"+ideventtypes+"}", "{"+status+"}", prioritymin.to_string(),  prioritymax.to_string(),  fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_events_xml($1::integer[], $2::timestamp without time zone, $3::timestamp without time zone, $4::integer, $5::integer, $6::integer[], $7::integer[], $8::integer, $9::integer,  $10::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("fun_view_events_xml >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		/*
public string fun_view_events_xml(int idaccount, string start, string end, int function = 0, int rows = 100, bool fieldtextasbase64 = true){
string RetornoX = "<table></table>";
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {idaccount.to_string(), start, end, function.to_string(), rows.to_string(), fieldtextasbase64.to_string()};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_events_xml($1::integer, $2::timestamp without time zone, $3::timestamp without time zone, $4::integer, $5::integer, $6::boolean) AS return", valuesin);
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
*/
		public string fun_events_lastid_xml() {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_events_lastid_xml() AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("fun_events_lastid_xml >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		public int lastid(int idaccount = 0) {
			int RetornoX = 0;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string query = "SELECT idevent FROM usaga.events WHERE idaccount = $1::integer ORDER BY idevent DESC LIMIT 1;";
				if(idaccount<=0) {
					query = "SELECT idevent FROM usaga.events WHERE idaccount > $1::integer ORDER BY idevent DESC LIMIT 1;";
				}
				var Resultado = this.exec_params_minimal (ref Conexion, query, {
					idaccount.to_string()
				}
				);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["idevent"].as_int();
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
		public string byIdAccount_xml(int idaccount, string start, string end,  bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), start, end, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_events_xml($1::integer, $2::timestamp without time zone, $3::timestamp without time zone, $4::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		public string fun_events_getbyid_xml(int idevent, bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idevent.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_events_getbyid_xml($1::integer, $2::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
		public string LastXml(int rows = 100, bool fieldtextasbase64 = true) {
			string RetornoX = "<table></table>";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					rows.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_last_events_xml($1::integer, $2::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print("ResponseGetEventsMonitor >>> \n%s\n", RetornoX);
			return RetornoX;
		}
	}
	public struct AccountPhonesTriggerAlarmViewdb {
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
		public AccountPhonesTriggerAlarmViewdb() {
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
	public class AccountPhonesTriggerAlarmTable:PostgreSQLConnection {
		public string fun_account_phones_trigger_alarm_table_from_hashmap(HashMap<string, string> form, bool fieldtextasbase64 = true) {
			int inidaccount = 0;
			int inidphone = 0;
			bool inenable = false;
			bool infromsms = false;
			bool infromcall = false;
			string innote = "";
			if(form.has_key("idphone")) {
				inidphone = int.parse(form["idphone"]);
			}
			if(form.has_key("idaccount")) {
				inidaccount = int.parse(form["idaccount"]);
			}
			if(form.has_key("enable")) {
				inenable = bool.parse(form["enable"]);
			}
			if(form.has_key("fromsms")) {
				infromsms = bool.parse(form["fromsms"]);
			}
			if(form.has_key("fromcall")) {
				infromcall = bool.parse(form["fromcall"]);
			}
			if(form.has_key("note")) {
				innote = form["note"];
			}
			return fun_account_phones_trigger_alarm_table(inidaccount, inidphone, inenable, infromsms, infromcall, innote, fieldtextasbase64);
		}
		//fun_account_phones_trigger_alarm_table(IN inidaccount integer, IN inidphone integer, IN inenable boolean, IN infromsms boolean, IN infromcall boolean, IN innote text, OUT outreturn integer, OUT outpgmsg text)
		public string fun_account_phones_trigger_alarm_table(int inidaccount, int inidphone, bool inenable, bool infromsms, bool infromcall, string innote, bool fieldtextasbase64 = true) {
			string Retorno = "<table></table>";
			string[] ValuesArray = {
				inidaccount.to_string(), inidphone.to_string(), inenable.to_string(), infromsms.to_string(), infromcall.to_string(), innote, fieldtextasbase64.to_string()
			}
			;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_phones_trigger_alarm_table_xml($1::integer, $2::integer, $3::boolean, $4::boolean, $5::boolean, $6::text, $7::boolean) as return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						Retorno = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			//GLib.print("Llega hasta aqui 5 \n");
			return Retorno;
		}
		public string AccountPhonesTriggerAlarmViewdbXml_from_hashmap(HashMap<string, string> form, bool fieldtextasbase64 = true) {
			int idaccount = 0;
			int idcontact = 0;
			if(form.has_key("idcontact")) {
				idcontact = int.parse(form["idcontact"]);
			}
			if(form.has_key("idaccount")) {
				idaccount = int.parse(form["idaccount"]);
			}
			return fun_view_account_users_trigger_phones_contacts_xml(idaccount, idcontact, fieldtextasbase64);
		}
		public string fun_view_account_users_trigger_phones_contacts_xml(int idaccount, int idcontact, bool fieldtextasbase64 = true) {
			string[] valuesin = {
				idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()
			}
			;
			string RetornoX = "<table></table>";
			if(idaccount > 0 && idcontact > 0) {
				var  Conexion = Postgres.connect_db (this.ConnString());
				if(Conexion.get_status () == ConnectionStatus.OK) {
					var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_users_trigger_phones_contacts_xml($1::integer, $2::integer, $3::boolean) as return;", valuesin);
					if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
						foreach(var reg in this.Result_FieldName(ref Resultado)) {
							RetornoX = reg["return"].Value;
						}
					} else {
						stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
					}
				} else {
					stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
				}
			}
			return RetornoX;
		}
	}
	public struct AccountContactRow {
		public int IdAccount;
		public int IdContact;
		public int Priority;
		public bool Enable;
		public string Appointment;
		public string Note;
		public string TimeStamp;
		public AccountContactRow() {
			this.IdAccount = 0;
			this.IdContact = 0;
			this.Priority = 0;
			this.Enable = false;
			this.Appointment = "";
			this.Note = "";
			this.TimeStamp = "";
		}
	}
	public class AccountContactsTable:PostgreSQLConnection {
		public string fun_account_contacts_table_from_hasmap(HashMap<string, string> Data, bool fieldtextasbase64 = true) {
			int idaccount = 0;
			int idcontact = 0;
			bool enable = false;
			int priority = 10;
			string  appointment = "";
			string note = "";
			if(Data.has_key("idaccount")) {
				idaccount = int.parse(Data["idaccount"]);
			}
			if(Data.has_key("idcontact")) {
				idcontact = int.parse(Data["idcontact"]);
			}
			if(Data.has_key("enable_as_contact")) {
				enable = bool.parse(Data["enable_as_contact"]);
			}
			if(Data.has_key("priority")) {
				priority = int.parse(Data["priority"]);
			}
			if(Data.has_key("appointment")) {
				appointment = Data["appointment"];
			}
			if(Data.has_key("note")) {
				note = Data["note"];
			}
			return this.fun_account_contacts_table(idaccount, idcontact, enable, priority, appointment, note, fieldtextasbase64);
		}
		public string fun_account_contacts_table(int idaccount, int idcontact, bool enable, int priority, string  appointment, string note, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), idcontact.to_string(), priority.to_string(), enable.to_string(), appointment, note, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_contacts_table_xml($1::integer, $2::integer, $3::integer, $4::boolean, $5::text, $6::text, $7::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
		public string byIdXml(int idaccount, int idcontact, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_account_contacts_byid($1::integer, $2::integer, $3::boolean) AS return""", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
		public string fun_view_account_contacts_address_xml(int idaccount, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_view_account_contacts_address_xml($1::integer,  $2::boolean) AS return""", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
	}
	public class AccountNotificationsEventtypeTable:PostgreSQLConnection {
		public string byIdAccountIdPhone(int idaccount, int idphone, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), idphone.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_contact_notif_eventtypes_xml($1::integer, $2::integer, $3::boolean) AS return", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
	}
	public class NotificationTemplates:PostgreSQLConnection {
		// usaga.fun_notification_templates_edit_xml(inidnotiftempl integer, indescription text, inmessage text, ts timestamp without time zone, fieldtextasbase64 boolean)
		public string fun_notification_templates_edit_xml(int idnotiftempl, string description, string message, string ts, bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				idnotiftempl.to_string(), description, message, ts, fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_notification_templates_edit_xml($1::integer, $2::text, $3::text, $4::timestamp without time zone, $5::boolean) as return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		//usaga.fun_view_notification_templates_xml
		public string fun_view_notification_templates_xml(bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_view_notification_templates_xml($1::boolean) AS return""", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print(RetornoX);
			return RetornoX;
		}
	}
	public class AccountNotificationsTable:PostgreSQLConnection {
		public string byIdContact(int idaccount, int idcontact, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, """SELECT * FROM usaga.fun_view_account_notif_phones_xml($1::integer, $2::integer, $3::boolean) AS return""", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			//GLib.print(RetornoX);
			return RetornoX;
		}
		public string fun_account_notifications_table_xml_from_hashmap(HashMap<string, string> form, bool fieldtextasbase64 = true) {
			int idnotifaccount = 0;
			int idaccount = 0;
			int idphone = 0;
			int priority = 10;
			bool call = false;
			bool sms = false;
			string smstext = "";
			string note =  "";
			string ts = "1990-1-1 00:00";
			if(form.has_key("idnotifaccount")) {
				idnotifaccount = int.parse(form["idnotifaccount"]);
			}
			if(form.has_key("idaccount")) {
				idaccount = int.parse(form["idaccount"]);
			}
			if(form.has_key("idphone")) {
				idphone = int.parse(form["idphone"]);
			}
			if(form.has_key("priority")) {
				priority = int.parse(form["priority"]);
			}
			if(form.has_key("call")) {
				call = bool.parse(form["call"]);
			}
			if(form.has_key("sms")) {
				sms = bool.parse(form["sms"]);
			}
			if(form.has_key("smstext")) {
				smstext = form["smstext"];
			}
			if(form.has_key("note")) {
				note = form["note"];
			}
			if(form.has_key("ts")) {
				ts = form["ts"];
			}
			return fun_account_notifications_table_xml(idnotifaccount, idaccount, idphone, priority, call, sms, smstext, note, ts, fieldtextasbase64);
		}
		// usaga.fun_account_notifications_table(IN inidnotifaccount integer, IN inidaccount integer, IN inidphone integer, IN prioinrity integer, IN incall boolean, IN insms boolean, IN insmstext text, IN innote text, IN ints timestamp without time zone, OUT outreturn integer, OUT outpgmsg text)
		public string fun_account_notifications_table_xml(int idnotifaccount, int idaccount, int idphone, int priority, bool call, bool sms, string smstext, string note, string ts, bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				idnotifaccount.to_string(), idaccount.to_string(), idphone.to_string(), priority.to_string(), call.to_string(),  sms.to_string(), smstext, note, ts, fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_notifications_table_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::boolean, $6::boolean, $7::text, $8::text, $9::timestamp without time zone, $10::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					//GLib.print("Llega hasta aqui 4 \n");
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string fun_account_notifications_applyselected_xml_from_hasmap(HashMap<string, string> data, bool fieldtextasbase64 = true) {
			int idaccount = 0;
			string arrayidphones = "";
			bool call = false;
			bool sms = false;
			string msg = "";
			if(data.has_key("idaccount")) {
				idaccount = int.parse(data["idaccount"]);
			}
			if(data.has_key("idphones")) {
				arrayidphones = data["idphones"];
			}
			if(data.has_key("call")) {
				call = bool.parse(data["call"]);
			}
			if(data.has_key("sms")) {
				sms = bool.parse(data["sms"]);
			}
			if(data.has_key("msg")) {
				msg = data["msg"];
			}
			return fun_account_notifications_applyselected_xml(idaccount, arrayidphones, call, sms, msg, fieldtextasbase64);
		}
		public string fun_account_notify_applied_to_selected_contacts_xml_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true) {
			int idaccount = 0;
			string arrayidcontacts = "";
			bool call = false;
			bool sms = false;
			string msg = "";
			if(data.has_key("idaccount")) {
				idaccount = int.parse(data["idaccount"]);
			}
			if(data.has_key("idcontacts")) {
				arrayidcontacts = data["idcontacts"];
			}
			if(data.has_key("call")) {
				call = bool.parse(data["call"]);
			}
			if(data.has_key("sms")) {
				sms = bool.parse(data["sms"]);
			}
			if(data.has_key("msg")) {
				msg = data["msg"];
			}
			return fun_account_notify_applied_to_selected_contacts_xml(idaccount, arrayidcontacts, call, sms, msg, fieldtextasbase64);
		}
		public string fun_account_notify_applied_to_selected_contacts_xml(int idaccount, string arrayidcontacts, bool call, bool sms, string msg, bool fieldtextasbase64 = true) {
			string Retorno = "";
			if(arrayidcontacts.length > 0) {
				string[] ValuesArray = {
					idaccount.to_string(), "{"+arrayidcontacts+"}", call.to_string(), sms.to_string(), msg, fieldtextasbase64.to_string()
				}
				;
				//GLib.print("Llega hasta aqui 3 \n");
				var  Conexion = Postgres.connect_db (this.ConnString());
				if(Conexion.get_status () == ConnectionStatus.OK) {
					var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_notify_applied_to_selected_contacts_xml($1::integer, $2::integer[], $3::boolean, $4::boolean, $5::text, $6::boolean) AS return;",  ValuesArray);
					if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
						//GLib.print("Llega hasta aqui 4 \n");
						foreach(var filas in this.Result_FieldName(ref Resultado)) {
							//Retorno = int.parse(filas["fun_smsout_insert"]);
							Retorno = filas["return"].Value;
						}
					} else {
						stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
					}
				}
			} else {
				if(fieldtextasbase64) {
					Retorno = "<table><row>  <outreturn>0</outreturn>"+Base64.encode("No ha seleccionado ningún contacto para aplicar los cambios.".data)+"<outpgmsg></outpgmsg></row></table>";
				} else {
					Retorno = "<table><row>  <outreturn>0</outreturn>No ha seleccionado ningún contacto para aplicar los cambios.<outpgmsg></outpgmsg></row></table>";
				}
			}
			return Retorno;
		}
		public string fun_account_notifications_applyselected_xml(int idaccount, string arrayidphones, bool call, bool sms, string msg, bool fieldtextasbase64 = true) {
			string Retorno = "";
			if(arrayidphones.length > 0) {
				string[] ValuesArray = {
					idaccount.to_string(), "{"+arrayidphones+"}", call.to_string(), sms.to_string(), msg, fieldtextasbase64.to_string()
				}
				;
				//GLib.print("Llega hasta aqui 3 \n");
				var  Conexion = Postgres.connect_db (this.ConnString());
				if(Conexion.get_status () == ConnectionStatus.OK) {
					var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_notifications_applyselected_xml($1::integer, $2::integer[], $3::boolean, $4::boolean, $5::text, $6::boolean) AS return;",  ValuesArray);
					if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
						//GLib.print("Llega hasta aqui 4 \n");
						foreach(var filas in this.Result_FieldName(ref Resultado)) {
							//Retorno = int.parse(filas["fun_smsout_insert"]);
							Retorno = filas["return"].Value;
						}
					} else {
						stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
					}
				}
			} else {
				if(fieldtextasbase64) {
					Retorno = "<table><row>  <outreturn>0</outreturn>"+Base64.encode("No ha seleccionado ningún teléfono para aplicar los cambios.".data)+"<outpgmsg></outpgmsg></row></table>";
				} else {
					Retorno = "<table><row>  <outreturn>0</outreturn>No ha seleccionado ningún teléfono para aplicar los cambios.<outpgmsg></outpgmsg></row></table>";
				}
			}
			return Retorno;
		}
	}
	public struct AccountUsersViewdb {
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
		public AccountUsersViewdb() {
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
	public struct AccountContactViewdb {
		public int IdContact;
		public bool EnableContact;
		public string FirstName;
		public string LastName;
		public int IdAccount;
		public int PriorityContact;
		public bool EnableAsContact;
		public string Appointment;
		public AccountContactViewdb() {
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
	public class PeriodicFunction:PostgreSQLConnection {
		private uint HearBeatTimes = 0;
		private uint EventypesTimes = 0;
		// Se dispara cuando arranca el servidor y cada 30 minutos, tomando en cuenta que el metodo es llamado cada 10 segundos
		private void fun_eventtype_default() {
			if(this.EventypesTimes == 0) {
				EventTypesTable ETT1 = new EventTypesTable();
				ETT1.ParamCnx = this.ParamCnx;
				//ETT1.GetParamCnx(this.Config);
				ETT1.fun_eventtype_default();
				this.EventypesTimes++;
			} else if(this.EventypesTimes>180) {
				EventTypesTable ETT2 = new EventTypesTable();
				ETT2.ParamCnx = this.ParamCnx;
				//ETT2.GetParamCnx(this.Config);
				ETT2.fun_eventtype_default();
				this.EventypesTimes = 1;
			} else {
				this.EventypesTimes++;
			}
		}
		// Se dispara cada 10 minutos, tomando en cuenta que el metodo es llamado cada 10 segundos
		private void HearBeat() {
			if(this.HearBeatTimes>60) {
				//GLib.print("\n[uSAGA]: Receptor procesando ");
				var  Conexion = Postgres.connect_db (this.ConnString());
				if(Conexion.get_status () == ConnectionStatus.OK) {
					var Resultado = Conexion.exec("""SELECT * FROM usaga.hearbeat();""");
					if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
						foreach(var filas in this.Result_FieldName(ref Resultado)) {
							GLib.print("HearBeat: %s\n", filas["hearbeat"].Value);
						}
					} else {
						stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
					}
				}
				this.HearBeatTimes = 0;
			} else {
				this.HearBeatTimes++;
			}
		}
		// Se dispara en cada hearbeat (cada 10 segundos)
		private void fun_periodic_functions() {
			GLib.print("\n[uSAGA]: Periodic Functions");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = Conexion.exec("""SELECT * FROM usaga.fun_periodic_functions() as return;""");
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						GLib.print(": %s\n", filas["return"].Value);
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
		}
		public void functions() {
			this.fun_periodic_functions();
			this.HearBeat();
			this.fun_eventtype_default();
		}
	}
	public class AccountTable:PostgreSQLConnection {
		/*
public bool is_changed(string old_ts){
bool RetornoX = false;
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {old_ts};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_table_is_changed($1::timestamp without time zone) AS return;", valuesin);
    if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
foreach(var reg in this.Result_FieldName(ref Resultado)){
RetornoX = reg["return"].as_bool();
}
}else{
	        stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
    }
}else{
	        stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
}
return RetornoX;
}
public string last_ts(){
string RetornoX = "2000-01-01 00:00";
var  Conexion = Postgres.connect_db (this.ConnString());
if(Conexion.get_status () == ConnectionStatus.OK){
string[] valuesin = {};
var Resultado = this.exec_params_minimal (ref Conexion, "SELECT ts AS return FROM usaga.account ORDER BY ts DESC LIMIT 1;", valuesin);
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
*/
		public string NameAndId_Search_Xml(string text, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					text, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_to_list_search_xml($1::text, $2::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
		public string  fun_account_address_edit_xml_from_hashmap(HashMap<string, string> data, bool fieldtextasbase64 = true) {
			int idaccount = 0;
			if(data.has_key("idaccount")) {
				idaccount = int.parse(data["idaccount"]);
			}
			AddressRowData RowData = AddressTable.rowdata_from_hashmap(data);
			return fun_account_address_edit_xml(idaccount, RowData.idlocation, RowData.geox, RowData.geoy, RowData.f1, RowData.f2, RowData.f3, RowData.f4, RowData.f5, RowData.f6, RowData.f7, RowData.f8, RowData.f9, RowData.f10, RowData.ts, fieldtextasbase64);
		}
		public string  fun_account_address_edit_xml(int idcontact, int inidlocation, double ingeox, double ingeoy, string f1, string f2, string f3, string f4, string f5, string f6, string f7, string f8, string f9, string f10, string ints, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idcontact.to_string(), inidlocation.to_string(), ingeox.to_string(), ingeoy.to_string(), f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, ints, fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM  usaga.fun_account_address_edit_xml($1::integer, $2::integer, $3::double precision, $4::double precision, $5::text, $6::text,  $7::text, $8::text, $9::text, $10::text, $11::text, $12::text, $13::text, $14::text, $15::timestamp without time zone, $16::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
		public string fun_view_accounts_list_xml(bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion,  "SELECT * FROM usaga.fun_view_accounts_list_xml($1::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					//GLib.print("Llega hasta aqui 4 \n");
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string fun_view_account_location_byid_xml(int idaccount, bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				idaccount.to_string(), fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion,  "SELECT * FROM usaga.fun_view_account_location_byid_xml($1::integer, $2::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					//GLib.print("Llega hasta aqui 4 \n");
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string fun_account_notifications_table_xml(int idnotifaccount, int idaccount, int idphone, int priority, bool call, bool sms, string smstext, string note, string ts, bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				idnotifaccount.to_string(), idaccount.to_string(), idphone.to_string(), priority.to_string(), call.to_string(),  sms.to_string(), smstext, note, ts, fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion,  "SELECT * FROM usaga.fun_account_notifications_table_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::boolean, $6::boolean, $7::text, $8::text, $9::timestamp without time zone, $10::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					//GLib.print("Llega hasta aqui 4 \n");
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string  fun_view_account_contacts_xml(int idaccount, bool fieldtextasbase64 = true) {
			string Retorno = "<table></table>";
			string[] ValuesArray = {
				idaccount.to_string(), fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM  usaga.fun_view_account_contacts_xml($1::integer, $2::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					//GLib.print("Llega hasta aqui 4 \n");
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string fun_view_account_users_xml(int inidaccount, bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				inidaccount.to_string(), fieldtextasbase64.to_string()
			}
			;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_users_xml($1::integer, $2::boolean) as return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			//GLib.print("%s\n", Retorno);
			return Retorno;
		}
		public string fun_view_account_byid_xml(int inidaccount, bool fieldtextasbase64 = true) {
			string Retorno = "";
			string[] ValuesArray = {
				inidaccount.to_string(), fieldtextasbase64.to_string()
			}
			;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_byid_xml($1::integer, $2::boolean) as return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			//GLib.print("%s\n", Retorno);
			return Retorno;
		}
		public string fun_account_table_xml_from_hashmap(HashMap<string, string> Data, bool fieldtextasbase64 = true) {
			int Id = 0;
			bool Enable = false;
			string Account = "";
			string Name = "";
			int IdGroup = 0;
			int Partition = 0;
			int Type = 0;
			int IdContact = 0;
			string Note = "";
			if(Data.has_key("idaccount")) {
				Id = int.parse(Data["idaccount"]);
			}
			if(Data.has_key("idcontact")) {
				IdContact = int.parse(Data["idcontact"]);
			}
			if(Data.has_key("enable")) {
				Enable = bool.parse(Data["enable"]);
			}
			if(Data.has_key("account")) {
				Account = Data["account"];
			}
			if(Data.has_key("name")) {
				Name = Data["name"];
			}
			if(Data.has_key("idgroup")) {
				IdGroup = int.parse(Data["idgroup"]);
			}
			if(Data.has_key("partition")) {
				Partition = int.parse(Data["partition"]);
			}
			if(Data.has_key("type")) {
				Type = int.parse(Data["type"]);
			}
			if(Data.has_key("note")) {
				Note = Data["note"];
			}
			//GLib.print("Llega hasta aqui 1 \n");
			return fun_account_table_xml(Id, Enable, Account, Name, IdGroup, Partition, Type, IdContact, Note, fieldtextasbase64);
		}
		// usaga.fun_account_table(IN inidaccount integer, IN inenable boolean, IN inaccount text, IN inname text, IN inidgroup integer, IN inpartition integer, IN intype integer, IN innote text, OUT outidaccount integer, OUT outpgmsg text)
		public string fun_account_table_xml(int inidaccount, bool inenable, string inaccount, string inname, int inidgroup, int inpartition, int intype, int inidcontact, string innote, bool fieldtextasbase64 = true) {
			string Retorno = "";
			//GLib.print("Llega hasta aqui %s => %s\n", inname, innote);
			string[] ValuesArray = {
				inidaccount.to_string(), inenable.to_string(), inaccount, inname, inidgroup.to_string(), inpartition.to_string(), intype.to_string(), inidcontact.to_string(), innote, fieldtextasbase64.to_string()
			}
			;
			//GLib.print("Llega hasta aqui 3 \n");
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_table_xml($1::integer, $2::boolean, $3::text, $4::text, $5::integer, $6::integer, $7::integer, $8::integer, $9::text, $10::boolean) as return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		/*
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
*/
		//usaga.fun_account_users_table(IN inidaccount integer, IN inidcontact integer, IN inappointment text, IN inenable boolean, IN innumuser integer, IN inkeyword text, IN inpwd text, IN innote text, OUT outreturn integer, OUT outmsg text)
		public string fun_account_users_table_xml(int inidaccount, int inidcontact, string inappointment, bool inenable, int innumuser, string inkeyword, string inpwd, string  innote = "", bool fieldtextasbase64 = true) {
			string Retorno = "<table></table>";
			string[] ValuesArray = {
				inidaccount.to_string(), inidcontact.to_string(), inappointment, inenable.to_string(), innumuser.to_string(),  inkeyword, inpwd, innote, fieldtextasbase64.to_string()
			}
			;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_account_users_table_xml($1::integer, $2::integer, $3::text, $4::boolean, $5::integer, $6::text, $7::text, $8::text, $9::boolean) as return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			//GLib.print("Llega hasta aqui 5 \n");
			return Retorno;
		}
		public string fun_account_users_table_xml_from_hashmap(HashMap<string, string> Data, bool fieldtextasbase64 = true) {
			int IdAccount = 0;
			int IdContact = 0;
			string Appointment = "";
			bool Enable = false;
			int NumUser = 0;
			string KeyWord = "";
			string Password = "";
			string Note = "";
			if(Data.has_key("idaccount")) {
				IdAccount = int.parse(Data["idaccount"]);
			}
			if(Data.has_key("idcontact")) {
				IdContact = int.parse(Data["idcontact"]);
			}
			if(Data.has_key("numuser")) {
				NumUser = int.parse(Data["numuser"]);
			}
			if(Data.has_key("enable")) {
				Enable = bool.parse(Data["enable"]);
			}
			if(Data.has_key("keyword")) {
				KeyWord = Data["keyword"];
			}
			if(Data.has_key("pwd")) {
				Password = Data["pwd"];
			}
			if(Data.has_key("appointment")) {
				Appointment = Data["appointment"];
			}
			if(Data.has_key("note")) {
				Note = Data["note"];
			}
			return fun_account_users_table_xml(IdAccount, IdContact, Appointment, Enable, NumUser, KeyWord, Password, Note, fieldtextasbase64);
		}
		public string fun_view_account_user_byidaccountidcontact_xml(int idaccount, int idcontact, bool fieldtextasbase64 = true) {
			string Retorno = "<table></table>";
			string[] ValuesArray = {
				idaccount.to_string(), idcontact.to_string(), fieldtextasbase64.to_string()
			}
			;
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_user_byidaccountidcontact_xml($1::integer, $2::integer, $3::boolean) AS return;",  ValuesArray);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var filas in this.Result_FieldName(ref Resultado)) {
						//Retorno = int.parse(filas["fun_smsout_insert"]);
						Retorno = filas["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			}
			return Retorno;
		}
		public string fun_view_account_unregistered_contacts_xml(int idaccount, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_unregistered_contacts_xml($1::integer, $2::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
		public string fun_view_account_unregistered_users_xml(int idaccount, bool fieldtextasbase64 = true) {
			string RetornoX = "";
			var  Conexion = Postgres.connect_db (this.ConnString());
			if(Conexion.get_status () == ConnectionStatus.OK) {
				string[] valuesin = {
					idaccount.to_string(), fieldtextasbase64.to_string()
				}
				;
				var Resultado = this.exec_params_minimal (ref Conexion, "SELECT * FROM usaga.fun_view_account_unregistered_users_xml($1::integer, $2::boolean) AS return;", valuesin);
				if (Resultado.get_status () == ExecStatus.TUPLES_OK) {
					foreach(var reg in this.Result_FieldName(ref Resultado)) {
						RetornoX = reg["return"].Value;
					}
				} else {
					stderr.printf ("FETCH ALL failed: %s", Conexion.get_error_message ());
				}
			} else {
				stderr.printf ("Conexion failed: %s", Conexion.get_error_message ());
			}
			return RetornoX;
		}
	}
}
