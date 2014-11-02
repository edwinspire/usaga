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
using edwinspire.uHttp;
using edwinspire.uSMS;
namespace edwinspire.uSAGA {
	public class uSagaServer:uSMSServer {
		private PeriodicFunction PF = new PeriodicFunction();
		public override bool connection_handler_virtual_usms(Request request, DataOutputStream dos) {
			uHttp.Response response = new uHttp.Response();
			//print("request.Path =>>>> %s\n", request.Path);
			switch(request.Path) {
				case  "/getaccount.usaga":
								response = ResponseGetAccount(request);
				this.serve_response( response, dos );
				break;
				case  "/saveaccount.usaga":
								response = ResponseAccountSaveTable(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_accounts_list_xml.usaga":
								response = response_fun_view_accounts_list_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_account_users_xml.usaga":
								response = request_fun_view_account_users_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_account_user_byidaccountidcontact_xml.usaga":
								response = request_fun_view_account_user_byidaccountidcontact_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_account_users_table_xml_from_hashmap.usaga":
								response = fun_account_users_table_xml_from_hashmap(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_events_xml.usaga":
								response = ResponseGetEventsMonitor(request);
				this.serve_response( response, dos );
				break;
				/*case "/opensagaaddaccountuser":
response = ResponseAccountUserAddTable(request);
    this.serve_response( response, dos );
 break;*/
				case "/fun_view_account_unregistered_contacts_xml.usaga":
								response = request_fun_view_account_unregistered_contacts_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_account_unregistered_users_xml.usaga":
								response = request_fun_view_account_unregistered_users_xml(request);
				this.serve_response( response, dos );
				break;
				/*
case "/saveaccountlocation.usaga":
response = ResponseAccountLocationSaveTable(request);
    this.serve_response( response, dos );
 break;
*/
				case "/getaccountphonestriggerview.usaga":
								response = ResponseGetAccountPhonesTrigger(request);
				this.serve_response( response, dos );
				break;
				case "/fun_account_phones_trigger_alarm_table_from_hashmap.usaga":
								response = request_fun_account_phones_trigger_alarm_table_from_hashmap(request);
				this.serve_response( response, dos );
				break;
				case "/getaccountcontactsgrid.usaga":
								response = ResponseAccountContactsToGridx(request);
				this.serve_response( response, dos );
				break;
				case "/getaccountcontact.usaga":
								response = ResponseGetAccountContact(request);
				this.serve_response( response, dos );
				break;
				case "/getaccountphonesnotifgrid.usaga":
								response = ResponseAccountContactPhonesNotifToGridx(request);
				this.serve_response( response, dos );
				break;
				case "/getaccountphonesnotifeventtypegrid.usaga":
								response = ResponseAccountContactPhonesNotifEventTypeToGridx(request);
				this.serve_response( response, dos );
				break;
				case "/fun_account_contacts_table.usaga":
								response = ResponseAccountContactsTable(request);
				this.serve_response( response, dos );
				break;
				case "/getaccountcontactstable.usaga":
								response = ResponseAccountContactsTable(request);
				this.serve_response( response, dos );
				break;
				case "/getaccountnotificationstable.usaga":
								response = ResponseAccountNotificationsTable(request);
				this.serve_response( response, dos );
				break;
				case "/getviewnotificationtemplates.usaga":
								response = ResponseViewNotificationTemplates(request);
				this.serve_response( response, dos );
				break;
				case "/notificationtemplatesedit.usaga":
								response = ResponseNotificationTemplatesEdit(request);
				this.serve_response( response, dos );
				break;
				case "/notifyeditselectedphones.usaga":
								response = ResponseAccountNotificationApplySelected(request);
				this.serve_response( response, dos );
				break;
				case "/geteventsaccount.usaga":
								response = ResponseAccountEvents(request);
				this.serve_response( response, dos );
				break;
				//case "/events_and_comments_table_changed.usaga":
				//response_events_and_comments_table_changed(request, dos);
				// break;
				case "/notifyeditselectedcontacts.usaga":
								response = ResponseAccountNotificationAppliedToSelectedContacts(request);
				this.serve_response( response, dos );
				break;
				case "/fun_account_address_edit_xml.usaga":
								response = response_fun_account_address_edit_xml_from_hashmap(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_eventtypes_xml.usaga":
								response = ResponseViewEventTypesXml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_eventtypes_edit_xml.usaga":
								response = ResponseEventTypesEditXml(request);
				this.serve_response( response, dos );
				break;
				case "/usaga_account_map.usaga":
								response = response_usaga_account_map(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_account_location_byid_xml.usaga":
								response = response_fun_view_account_location_byid_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_account_contacts_address_xml.usaga":
								response = response_fun_view_account_contacts_address_xml(request);
				this.serve_response( response, dos );
				break;
				//case "/notifications.usaga":
				//response = response_usaga_notifications(request);
				//  this.serve_response( response, dos ); 
				//break;
				case "/fun_view_account_to_list_search_xml.usaga":
								response = response_fun_view_account_to_list_search_xml(request);
				this.serve_response( response, dos );
				break;
				case "/enum_EventStatus_xml.usaga":
								response = response_enum_EventStatus_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_eventtypes_xml.usaga":
								response = response_fun_eventtypes_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_events_getbyid_xml.usaga":
								response = response_fun_events_getbyid_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_event_comment_insert_xml.usaga":
								response = response_fun_event_comment_insert_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_events_comments_xml.usaga":
								response = response_fun_view_events_comments_xml(request);
				this.serve_response( response, dos );
				break;
				case "/fun_event_insert_manual_xml.usaga":
								response = response_fun_event_insert_manual_xml(request);
				this.serve_response( response, dos );
				break;
				case "/m_usaga_event_view.usaga":
								response = response_m_usaga_event_view(request);
				this.serve_response( response, dos );
				break;
				case "/fun_view_accounts_events_reports_xml.usaga":
				response = response_fun_view_accounts_events_reports_xml(request);
				this.serve_response( response, dos );
				break;
				case "/usaga_report_events_print.usaga":
				response = response_usaga_report_events_print(request);
				this.serve_response( response, dos );
				break;				
				default:
								      response.Status = StatusCode.NOT_FOUND;
				response.Data = edwinspire.uHttp.Response.HtmErrorPage("uHTTP WebServer", "404 - Página no encontrada").data;
				response.Header["Content-Type"] = "text/html";
				this.serve_response( response, dos );
				break;
			}
			return false;
		}
		
		/**
		* Returns the HTML page with the necessary variasbles to build a web site reports
		*/
		private uHttp.Response response_usaga_report_events_print(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/html";
			Retorno.Status = StatusCode.OK;
			EventTable Tabla = new EventTable();
			Tabla.GetParamCnx();
    		string ids = "{0,0,0,0}";
	//	stderr.printf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><< ");
//			stderr.printf(request.Form.size.to_string());

    	 ids = Tabla.fun_view_accounts_events_only_idevents(request.Form.post_request.internal_hashmap);
			
				//	stderr.printf("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><< "+ids);

            
        Retorno.Data = this.ReadServerFile("usaga_report_events_print.html").replace("data-usaga-idevents=\"{}\"", "data-usaga-idevents=\""+ids+"\"").data;
			return Retorno;
		}		
		
		private static uHttp.Response response_fun_view_accounts_events_reports_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			EventTable Tabla = new EventTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_accounts_events_reports_xml(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}		
				
		private uHttp.Response response_m_usaga_event_view(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/html";
			Retorno.Status = StatusCode.OK;
			int idevent = 0;
			if(request.Form.get_request.has_key("idevent")) {
				idevent = int.parse(request.Form.get_request.get_value("idevent"));
			}
			Retorno.Data = this.ReadServerFile("_m_usaga_event_view.html").replace("data-usaga-idevent=\"0\"", "data-usaga-idevent=\""+idevent.to_string()+"\"").data;
			return Retorno;
		}
		private static uHttp.Response response_fun_event_insert_manual_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			EventTable Tabla = new EventTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_event_insert_manual_xml(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}
		private static uHttp.Response response_fun_view_events_comments_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idevent = 0;
			if(request.Form.get_request.has_key("idevent")) {
				idevent = int.parse(request.Form.get_request.get_value("idevent"));
			}
			EventCommentTable Tabla = new EventCommentTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_events_comments_xml(idevent, true).data;
			return Retorno;
		}
		
		private uHttp.Response response_fun_event_comment_insert_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idevent = 0;
			int idadmin = 0;
			int seconds  = 0;
			int status  = 0;
			string comment = "";
			bool fieldtextasbase64 = true;
			int[] idattachs = {};
			warranty("No esta implementado\n");
			/*
			TODO: Reimplementar esta seccion
			int[] idattachs = this.attach_files(request.MultiPartForm.Parts, false);
			if(request.MultiPartForm.is_multipart_form_data) {
				foreach(var p in request.MultiPartForm.Parts) {
					switch(p.get_content_disposition_param("name")) {
						case "idevent":
														idevent = int.parse(p.get_data_as_string_valid_unichars());
						break;
						case "idadmin":
														idadmin = int.parse(p.get_data_as_string_valid_unichars());
						break;
						case "seconds":
														seconds = int.parse(p.get_data_as_string_valid_unichars());
						break;
						case "status":
														status = int.parse(p.get_data_as_string_valid_unichars());
						break;
						case "comment":
														comment = p.get_data_as_string_valid_unichars();
						break;
						case "fieldtextasbase64":
														fieldtextasbase64 = bool.parse(p.get_data_as_string_valid_unichars());
						break;
					}
				}
			}*/
			EventCommentTable Tabla = new EventCommentTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_event_comment_insert_xml(idevent, idadmin, seconds, status, comment, idattachs, fieldtextasbase64).data;
			return Retorno;
		}
		private static uHttp.Response response_fun_events_getbyid_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idevent = 0;
			if(request.Form.get_request.has_key("idevent")) {
				idevent = int.parse(request.Form.get_request.get_value("idevent"));
			}
			EventTable Tabla = new EventTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_events_getbyid_xml(idevent, true).data;
			return Retorno;
		}
		private static uHttp.Response response_fun_eventtypes_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int manual = 0;
			if(request.Form.get_request.has_key("manual")) {
				manual = int.parse(request.Form.get_request.get_value("manual"));
			}
			EventTypesTable Tabla = new EventTypesTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_eventtypes_xml(manual, true).data;
			return Retorno;
		}
		private uHttp.Response response_enum_EventStatus_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			Retorno.Data = uHttpServer.EnumToXml(typeof(EventStatus), true).data;
			return Retorno;
		}
		private uHttp.Response response_fun_view_account_to_list_search_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			string text = "";
			if(request.Form.get_request.has_key("text")) {
				text = request.Form.get_request.get_value("text");
			}
			Retorno.Data =  Tabla.NameAndId_Search_Xml(text, true).data;
			return Retorno;
		}
		/*
private uHttp.Response response_usaga_notifications(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header["Content-Type"] = "text/event-stream";
  Retorno.Header["Cache-Control"] = "no-cache";
    Retorno.Status = StatusCode.OK;
var d = new DateTime.now_local();
Retorno.Data = ("data: server time "+d.to_string()+"\n\n").data;
print(("data: server time "+d.to_string())+"\n\n");
return Retorno;
}
*/
		private static uHttp.Response ResponseEventTypesEditXml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			EventTypesTable Tabla = new EventTypesTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_eventtypes_edit_xml_from_hashmap(request.Form.post_request.internal_hashmap, true).data;
			return Retorno;
		}
		private static uHttp.Response ResponseViewEventTypesXml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			EventTypesTable Tabla = new EventTypesTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_eventtypes_xml(true).data;
			return Retorno;
		}
		private static uHttp.Response response_fun_account_address_edit_xml_from_hashmap(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_account_address_edit_xml_from_hashmap(request.Form.post_request.internal_hashmap, true).data;
			return Retorno;
		}
		private uHttp.Response ResponseAccountNotificationAppliedToSelectedContacts(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountNotificationsTable Tabla = new AccountNotificationsTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_account_notify_applied_to_selected_contacts_xml_hashmap(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}
		/*
private uHttp.Response ResponseEventsLastIdXml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header["Content-Type"] = "text/xml";
    Retorno.Status = StatusCode.OK;
EventTable Tabla = new EventTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_events_lastid_xml().data;
return Retorno;
}
*/
		/*
private void response_event_lastid(Request request, DataOutputStream dos){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header["Content-Type"] = "text/event-stream";
  Retorno.Header["Cache-Control"] = "no-cache";
    Retorno.Status = StatusCode.OK;
this.serve_response( Retorno, dos );
EventTable Tabla = new EventTable();
Tabla.GetParamCnx();
int newid = Tabla.lastid();
int lastid = 0;
int idaccount = 0;
if(request.Form.get_request.has_key("idaccount")){
idaccount = int.parse(request.Form.get_request.get_value("idaccount"]); 
}
int i = 0;
while(i<150){
if(lastid < newid){
this.writeData(("data: "+newid.to_string()+"\n\n").data, dos);
lastid = newid;
}else{
newid = Tabla.lastid(idaccount);
}
Thread.usleep(1000*1500);
i++;
}
}
*/
		/*
private void response_events_and_comments_table_changed(Request request, DataOutputStream dos){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header["Content-Type"] = "text/event-stream";
  Retorno.Header["Cache-Control"] = "no-cache";
    Retorno.Status = StatusCode.OK;
this.serve_response( Retorno, dos );
EventTable Eventos = new EventTable();
Eventos.GetParamCnx();
EventCommentTable Comment = new EventCommentTable();
Comment.GetParamCnx();
string Eold_ts = "2001-01-01";
string Cold_ts = "2001-01-01";
bool changed = false;
int i = 0;
while(i<150){
if(Eventos.is_changed(Eold_ts)){
changed = true;
Eold_ts = Eventos.last_ts();
}
if(Comment.is_changed(Cold_ts)){
changed = true;
Cold_ts = Comment.last_ts();
}
if(changed){
this.writeData(("data: 1\n\n").data, dos);
changed = false;
}
Thread.usleep(1000*1500);
i++;
}
}
*/
		private uHttp.Response ResponseAccountEvents(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			EventTable Tabla = new EventTable();
			Tabla.GetParamCnx();
			int idaccount = 0;
			string start = "1990-01-01";
			string end = "2100-01-01";
			if(request.Form.get_request.has_key("idaccount")) {
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			if(request.Form.get_request.has_key("fstart")) {
				start = request.Form.get_request.get_value("fstart");
			}
			if(request.Form.get_request.has_key("fend")) {
				end = request.Form.get_request.get_value("fend");
			}
			Retorno.Data = Tabla.byIdAccount_xml(idaccount, start, end, true).data;
			return Retorno;
		}
		private uHttp.Response ResponseAccountNotificationApplySelected(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountNotificationsTable Tabla = new AccountNotificationsTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_account_notifications_applyselected_xml_from_hasmap(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}
		private uHttp.Response ResponseNotificationTemplatesEdit(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int id = 0;
			string message = "";
			string description = "";
			string ts = "1990-01-01";
			if(request.Form.post_request.has_key("idnotiftempl")) {
				id = int.parse(request.Form.post_request.get_value("idnotiftempl"));
			}
			if(request.Form.post_request.has_key("message")) {
				message = request.Form.post_request.get_value("message");
			}
			if(request.Form.post_request.has_key("description")) {
				description = request.Form.post_request.get_value("description");
			}
			if(request.Form.post_request.has_key("ts")) {
				ts = request.Form.post_request.get_value("ts");
			}
			NotificationTemplates Tabla = new NotificationTemplates();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_notification_templates_edit_xml(id, description, message, ts, true).data;
			//print(Tabla.UserAndIdContact_Xml(id));
			return Retorno;
		}
		private uHttp.Response response_fun_view_account_contacts_address_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountContactsTable Tabla = new AccountContactsTable();
			Tabla.GetParamCnx();
			int id = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				id = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			Retorno.Data = Tabla.fun_view_account_contacts_address_xml(id).data;
			return Retorno;
		}
		private uHttp.Response ResponseViewNotificationTemplates(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			NotificationTemplates Tabla = new NotificationTemplates();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_view_notification_templates_xml().data;
			return Retorno;
		}
		private uHttp.Response ResponseAccountNotificationsTable(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountNotificationsTable Tabla = new AccountNotificationsTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_account_notifications_table_xml_from_hashmap(request.Form.post_request.internal_hashmap).data;
			//GLib.print(Tabla.fun_account_notifications_table_xml_from_hashmap(request.Form.post_request.internal_hashmap));
			return Retorno;
		}
		private uHttp.Response ResponseAccountContactsTable(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountContactsTable Tabla = new AccountContactsTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_account_contacts_table_from_hasmap(request.Form.post_request.internal_hashmap).data;
			//print(Tabla.fun_account_contacts_table_from_hasmap(request.Form.post_request.internal_hashmap));
			return Retorno;
		}
		private uHttp.Response ResponseAccountContactPhonesNotifEventTypeToGridx(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idaccount = 0;
			int idphone = 0;
			if(request.Form.get_request.has_key("idaccount") && request.Form.get_request.has_key("idphone")) {
				idphone = int.parse(request.Form.get_request.get_value("idphone"));
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountNotificationsEventtypeTable Tabla = new AccountNotificationsEventtypeTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.byIdAccountIdPhone(idaccount, idphone, true).data;
			//GLib.print(Tabla.byIdAccountIdPhone(idaccount, idphone, true));
			return Retorno;
		}
		private uHttp.Response ResponseAccountContactPhonesNotifToGridx(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idcontact = 0;
			int idaccount = 0;
			if(request.Form.get_request.has_key("idaccount") && request.Form.get_request.has_key("idcontact")) {
				idcontact = int.parse(request.Form.get_request.get_value("idcontact"));
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountNotificationsTable Tabla = new AccountNotificationsTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.byIdContact(idaccount, idcontact).data;
			//GLib.print(Tabla.byIdContact(idaccount, idcontact, true));
			return Retorno;
		}
		// Recibe los datos y los actualiza en la base de datos.
		private uHttp.Response ResponseGetAccountContact(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idcontact = 0;
			int idaccount = 0;
			if(request.Form.get_request.has_key("idaccount") && request.Form.get_request.has_key("idcontact")) {
				idcontact = int.parse(request.Form.get_request.get_value("idcontact"));
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountContactsTable Tabla = new AccountContactsTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.byIdXml(idaccount, idcontact).data;
			return Retorno;
		}
		private uHttp.Response ResponseAccountContactsToGridx(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int id = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				id = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_account_contacts_xml(id).data;
			//print(Tabla.UserAndIdContact_Xml(id));
			return Retorno;
		}
		private uHttp.Response request_fun_account_phones_trigger_alarm_table_from_hashmap(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_account_phones_trigger_alarm_table_from_hashmap(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}
		// Recibe los datos y los actualiza en la base de datos.
		private uHttp.Response ResponseGetEventsMonitor(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			//var Temporizador = new Timer();
			//Temporizador.start();
			EventTable Tabla = new EventTable();
			Tabla.GetParamCnx();
			//stderr.printf("********************* Responde A %f\n", Temporizador.elapsed());
			Retorno.Data =  Tabla.fun_view_events_xml_from_hashmap(request.Query).data;
			//stderr.printf("********************* Responde B %f\n", Temporizador.elapsed());
			//Temporizador.stop();
			return Retorno;
		}
		// Recibe los datos y los actualiza en la base de datos.
		private uHttp.Response ResponseAccountSaveTable(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_account_table_xml_from_hashmap(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}
		private uHttp.Response fun_account_users_table_xml_from_hashmap(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_account_users_table_xml_from_hashmap(request.Form.post_request.internal_hashmap).data;
			return Retorno;
		}
		private uHttp.Response ResponseGetAccountPhonesTrigger(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.AccountPhonesTriggerAlarmViewdbXml_from_hashmap(request.Query).data;
			return Retorno;
		}
		private uHttp.Response response_fun_view_accounts_list_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_accounts_list_xml().data;
			//print(Tabla.NameAndId_All_Xml());
			return Retorno;
		}
		private uHttp.Response request_fun_view_account_users_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int id = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				id = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_account_users_xml(id).data;
			//print(Tabla.UserAndIdContact_Xml(id));
			return Retorno;
		}
		// Recibe los datos y los actualiza en la base de datos.
		private uHttp.Response ResponseGetAccount(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			//print("ResponseGetAccount\n");
			int id = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				id = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_view_account_byid_xml(id).data;
			return Retorno;
		}
		private uHttp.Response response_usaga_account_map(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/html";
			Retorno.Status = StatusCode.OK;
			int idaccount = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			var retornoHtml = uHttpServer.ReadFile(this.PathLocalFile("usaga_account_map.html")).replace("data-usaga-idaccount=\"0\"", "data-usaga-idaccount=\""+idaccount.to_string()+"\"");
			Retorno.Data = retornoHtml.data;
			return Retorno;
		}
		private uHttp.Response response_fun_view_account_location_byid_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int id = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				id = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_account_location_byid_xml(id).data;
			return Retorno;
		}
		private uHttp.Response request_fun_view_account_unregistered_contacts_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idaccount = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_account_unregistered_contacts_xml(idaccount).data;
			//print(Tabla.UserAndIdContact_Xml(id));
			return Retorno;
		}
		private uHttp.Response request_fun_view_account_unregistered_users_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			int idaccount = 0;
			if(request.Form.get_request.has_key("idaccount")) {
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data =  Tabla.fun_view_account_unregistered_users_xml(idaccount).data;
			//print(Tabla.UserAndIdContact_Xml(id));
			return Retorno;
		}
		// Recibe los datos y los actualiza en la base de datos.
		private uHttp.Response request_fun_view_account_user_byidaccountidcontact_xml(Request request) {
			uHttp.Response Retorno = new uHttp.Response();
			Retorno.Header["Content-Type"] = "text/xml";
			Retorno.Status = StatusCode.OK;
			//print("ResponseGetAccount\n");
			int idcontact = 0;
			int idaccount = 0;
			if(request.Form.get_request.has_key("idaccount") && request.Form.get_request.has_key("idcontact")) {
				idcontact = int.parse(request.Form.get_request.get_value("idcontact"));
				idaccount = int.parse(request.Form.get_request.get_value("idaccount"));
			}
			AccountTable Tabla = new AccountTable();
			Tabla.GetParamCnx();
			Retorno.Data = Tabla.fun_view_account_user_byidaccountidcontact_xml(idaccount, idcontact).data;
			return Retorno;
		}
		/*
private void thread_periodic_process(){
  if (!Thread.supported()) {
        stderr.printf("Cannot run without threads.\n");
    }else{
try{
Thread.create<void>(this.periodic_process, false);
}
catch(ThreadError e){
print(e.message);
}
}
}
*/
		private void periodic_process() {
			// Se ejecuta esta funcion en cada hear beat
			PF.GetParamCnx();
			PF.functions();
		}
		/*
public void periodic_process(){
PeriodicFunction PF = new PeriodicFunction();
while(true){
if(this.periodic_function_time < 1){
this.periodic_function_time = 1;
}
// Se ejecuta esta funcion en cada hear beat
PF.GetParamCnx();
PF.functions();
Thread.usleep(1000000*this.periodic_function_time);
}
}
*/
		// Inicia y corre el servidor asincronicamente
		public void runuSAGA() {
			this.heartbeatseconds = 10;
			this.heartbeat.connect(this.periodic_process);
			this.runuSMS();
		}
	}
}
