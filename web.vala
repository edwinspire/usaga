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
using edwinspire.uSMS;
//using edwinspire.GSM.MODEM;
//using Xml;
using edwinspire.uHttp;

namespace edwinspire.uSAGA{

public class uSagaServer:uSMSServer{

//private uSMSServer S = new uSMSServer ();

//private ArrayList<Device> Dispositivos = new ArrayList<Device>();
//private  HashSet<string> PuertosUnicos = new HashSet<string>();
/*
public uSagaServer(){

print("Start uSAGA Version: 0.02\n");
print("Licence: LGPL\n");
print("Hosted: https://github.com/edwinspire\n");
print("Contact: edwinspire@gmail.com\n");

//S.Port = 8081;

//S.Index = "usaga.html";
this.VirtualUrl["getaccount.usaga"] = "/getaccount.usaga";
this.VirtualUrl["saveaccount.usaga"] = "/saveaccount.usaga";
this.VirtualUrl["fun_view_idaccounts_names_xml.usaga"] = "/fun_view_idaccounts_names_xml.usaga"; 
this.VirtualUrl["fun_view_account_users_xml.usaga"] = "/fun_view_account_users_xml.usaga";
//S.VirtualUrl["usmsgetcontactsvaluesselectbox"] = "/usmsgetcontactsvaluesselectbox";  
this.VirtualUrl["fun_view_account_user_byidaccountidcontact_xml.usaga"] = "/fun_view_account_user_byidaccountidcontact_xml.usaga";
this.VirtualUrl["fun_account_users_table_xml_from_hashmap.usaga"] = "/fun_account_users_table_xml_from_hashmap.usaga";
this.VirtualUrl["usaga_geteventsmonitor.usaga"] = "/usaga_geteventsmonitor.usaga";       
//S.VirtualUrl["opensagaaddaccountuser"] = "/opensagaaddaccountuser";
//S.VirtualUrl["getaccountlocation.usaga"] = "/getaccountlocation.usaga";
//S.VirtualUrl["saveaccountlocation.usaga"] = "/saveaccountlocation.usaga";
this.VirtualUrl["getaccountphonestriggerview.usaga"] = "/getaccountphonestriggerview.usaga";
this.VirtualUrl["fun_account_phones_trigger_alarm_table_from_hashmap.usaga"] = "/fun_account_phones_trigger_alarm_table_from_hashmap.usaga";
this.VirtualUrl["getaccountcontactsgrid.usaga"] = "/getaccountcontactsgrid.usaga";
this.VirtualUrl["getaccountphonesnotifgrid.usaga"] = "/getaccountphonesnotifgrid.usaga";
this.VirtualUrl["getaccountcontact.usaga"] = "/getaccountcontact.usaga";
this.VirtualUrl["getaccountphonesnotifeventtypegrid.usaga"] = "/getaccountphonesnotifeventtypegrid.usaga";

//TODO: Eliminar esta pagina virtual, se la mantiene solo por compatibilidad con la version anterior.
this.VirtualUrl["getaccountcontactstable.usaga"] = "/getaccountcontactstable.usaga";

this.VirtualUrl["fun_account_contacts_table.usaga"] = "/fun_account_contacts_table.usaga";
this.VirtualUrl["getaccountnotificationstable.usaga"] = "/getaccountnotificationstable.usaga";
this.VirtualUrl["getviewnotificationtemplates.usaga"] = "/getviewnotificationtemplates.usaga";
this.VirtualUrl["notificationtemplatesedit.usaga"] = "/notificationtemplatesedit.usaga";

this.VirtualUrl["notifyeditselectedphones.usaga"] = "/notifyeditselectedphones.usaga";
this.VirtualUrl["geteventsaccount.usaga"] = "/geteventsaccount.usaga";
this.VirtualUrl["lastidevent.usaga"] = "/lastidevent.usaga";

this.VirtualUrl["notifyeditselectedcontacts.usaga"] = "/notifyeditselectedcontacts.usaga";
this.VirtualUrl["fun_account_address_edit_xml.usaga"] = "/fun_account_address_edit_xml.usaga";
this.VirtualUrl["fun_view_eventtypes_xml.usaga"] = "/fun_view_eventtypes_xml.usaga";

this.VirtualUrl["fun_eventtypes_edit_xml.usaga"] = "/fun_eventtypes_edit_xml.usaga";
this.VirtualUrl["fun_view_groups_xml.usaga"] = "/fun_view_groups_xml.usaga";
this.VirtualUrl["fun_groups_edit_xml_from_hashmap.usaga"] = "/fun_groups_edit_xml_from_hashmap.usaga";
this.VirtualUrl["fun_groups_remove_selected_xml.usaga"] = "/fun_groups_remove_selected_xml.usaga";
this.VirtualUrl["fun_view_idgroup_name_xml.usaga"] = "/fun_view_idgroup_name_xml.usaga";
this.VirtualUrl["fun_view_account_unregistered_contacts_xml.usaga"] = "/fun_view_account_unregistered_contacts_xml.usaga";
this.VirtualUrl["usaga_account_map.usaga"] = "/usaga_account_map.usaga";
this.VirtualUrl["fun_view_account_location_byid_xml.usaga"] = "/fun_view_account_location_byid_xml.usaga";
this.VirtualUrl["fun_view_account_unregistered_users_xml.usaga"] = "/fun_view_account_unregistered_users_xml.usaga";
//S.VirtualUrl["notifyeditselectedcontacts.usaga"] = "/notifyeditselectedcontacts.usaga";

 
//S.RequestVirtualUrl.connect(RequestVirtualPageHandler);

}
*/

public override bool connection_handler_virtual_usms(Request request, DataOutputStream dos){

    uHttp.Response response = new uHttp.Response();
//print("request.Path =>>>> %s\n", request.Path);
switch(request.Path){
case  "/getaccount.usaga":
response = ResponseGetAccount(request);
    this.serve_response( response, dos );
 break;
case  "/saveaccount.usaga":
response = ResponseAccountSaveTable(request);
    this.serve_response( response, dos );
 break;
case "/fun_view_idaccounts_names_xml.usaga":
response = ResponseAccountsNamesToSelectBox(request);
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
case "/usaga_geteventsmonitor.usaga":
response = ResponseGetEventsMonitor(request);
    this.serve_response( response, dos );
 break;
/*case "/opensagaaddaccountuser":
response = ResponseAccountUserAddTable(request);
    this.serve_response( response, dos );
 break;*/
case "/fun_view_account_unregistered_contacts_xml.usaga":
response = request_fun_view_account_unregistered_contacts_xml(request);
    this.serve_response( response, dos ); break;
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

case "/lastidevent.usaga":
response = ResponseEventsLastIdXml(request);
    this.serve_response( response, dos );
 break;
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

case "/fun_view_groups_xml.usaga":
response = response_fun_view_groups_xml(request);
    this.serve_response( response, dos );
 break;

case "/fun_groups_edit_xml_from_hashmap.usaga":
response = response_fun_groups_edit_xml_from_hashmap(request);
    this.serve_response( response, dos ); 
break;

case "/fun_groups_remove_selected_xml.usaga":
response = response_fun_groups_remove_selected_xml(request);
    this.serve_response( response, dos ); 
break;

case "/fun_view_idgroup_name_xml.usaga":
response = response_fun_view_idgroup_name_xml(request);
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

default:
      response.Header.Status = StatusCode.NOT_FOUND;
 response.Data = edwinspire.uHttp.Response.HtmErrorPage("uHTTP WebServer", "404 - Página no encontrada").data;
  response.Header.ContentType = "text/html";
this.serve_response( response, dos );
 break;
}

return false;
}

private uHttp.Response response_fun_view_idgroup_name_xml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

GroupsTable Tabla = new GroupsTable();
Tabla.GetParamCnx();

Retorno.Data = Tabla.fun_view_idgroup_name_xml(true).data;
return Retorno;
}

private uHttp.Response response_fun_groups_remove_selected_xml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

GroupsTable Tabla = new GroupsTable();
Tabla.GetParamCnx();

string idgroups = "0";

if(request.Form.has_key("idgroups")){
idgroups = request.Form["idgroups"];
}

Retorno.Data = Tabla.fun_groups_remove_selected_xml(idgroups).data;
return Retorno;
}

private uHttp.Response response_fun_groups_edit_xml_from_hashmap(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

GroupsTable Tabla = new GroupsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_groups_edit_xml_from_hashmap(request.Form).data;
return Retorno;
}

private uHttp.Response response_fun_view_groups_xml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

GroupsTable Tabla = new GroupsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_view_groups_xml().data;
return Retorno;
}

private static uHttp.Response ResponseEventTypesEditXml(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

EventTypesTable Tabla = new EventTypesTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_eventtypes_edit_xml_from_hashmap(request.Form, true).data;

return Retorno;
}

private static uHttp.Response ResponseViewEventTypesXml(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

EventTypesTable Tabla = new EventTypesTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_eventtypes_xml(true).data;

return Retorno;
}


private static uHttp.Response response_fun_account_address_edit_xml_from_hashmap(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_address_edit_xml_from_hashmap(request.Form, true).data;

return Retorno;
}


private uHttp.Response ResponseAccountNotificationAppliedToSelectedContacts(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountNotificationsTable Tabla = new AccountNotificationsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_account_notify_applied_to_selected_contacts_xml_hashmap(request.Form).data;
return Retorno;
}

private uHttp.Response ResponseEventsLastIdXml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

EventTable Tabla = new EventTable();
Tabla.GetParamCnx();

Retorno.Data = Tabla.fun_events_lastid_xml().data;
return Retorno;
}

private uHttp.Response ResponseAccountEvents(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

EventTable Tabla = new EventTable();
Tabla.GetParamCnx();

int idaccount = 0;
string start = "1990-01-01";
string end = "2100-01-01";

if(request.Query.has_key("idaccount")){
idaccount = int.parse(request.Query["idaccount"]); 
}

if(request.Query.has_key("fstart")){
start = request.Query["fstart"]; 
}

if(request.Query.has_key("fend")){
end = request.Query["fend"]; 
}



Retorno.Data = Tabla.byIdAccount_xml(idaccount, start, end, true).data;
return Retorno;
}

private uHttp.Response ResponseAccountNotificationApplySelected(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountNotificationsTable Tabla = new AccountNotificationsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_account_notifications_applyselected_xml_from_hasmap(request.Form).data;
return Retorno;
}


private uHttp.Response ResponseNotificationTemplatesEdit(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

int id = 0;
string message = "";
string description = "";
string ts = "1990-01-01";

if(request.Form.has_key("idnotiftempl")){
id = int.parse(request.Form["idnotiftempl"]);
}

if(request.Form.has_key("message")){
message = request.Form["message"];
}


if(request.Form.has_key("description")){
description = request.Form["description"];
}

if(request.Form.has_key("ts")){
ts = request.Form["ts"];
}

NotificationTemplates Tabla = new NotificationTemplates();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_notification_templates_edit_xml(id, description, message, ts, true).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}

private uHttp.Response response_fun_view_account_contacts_address_xml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountContactsTable Tabla = new AccountContactsTable();
Tabla.GetParamCnx();
int id = 0;

if(request.Query.has_key("idaccount")){
id = int.parse(request.Query["idaccount"]);
}

Retorno.Data = Tabla.fun_view_account_contacts_address_xml(id).data;
return Retorno;
}

private uHttp.Response ResponseViewNotificationTemplates(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

NotificationTemplates Tabla = new NotificationTemplates();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_view_notification_templates_xml().data;
return Retorno;
}

private uHttp.Response ResponseAccountNotificationsTable(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountNotificationsTable Tabla = new AccountNotificationsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_account_notifications_table_xml_from_hashmap(request.Form).data;
//GLib.print(Tabla.fun_account_notifications_table_xml_from_hashmap(request.Form));
return Retorno;
}

private uHttp.Response ResponseAccountContactsTable(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountContactsTable Tabla = new AccountContactsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_account_contacts_table_from_hasmap(request.Form).data;
//print(Tabla.fun_account_contacts_table_from_hasmap(request.Form));
return Retorno;
}

private uHttp.Response ResponseAccountContactPhonesNotifEventTypeToGridx(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;
int idaccount = 0;
int idphone = 0;
if(request.Query.has_key("idaccount") && request.Query.has_key("idphone")){
idphone = int.parse(request.Query["idphone"]);
idaccount = int.parse(request.Query["idaccount"]);
}
AccountNotificationsEventtypeTable Tabla = new AccountNotificationsEventtypeTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.byIdAccountIdPhone(idaccount, idphone, true).data;
//GLib.print(Tabla.byIdAccountIdPhone(idaccount, idphone, true));
return Retorno;
}

private uHttp.Response ResponseAccountContactPhonesNotifToGridx(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;
int idcontact = 0;
int idaccount = 0;
if(request.Query.has_key("idaccount") && request.Query.has_key("idcontact")){
idcontact = int.parse(request.Query["idcontact"]);
idaccount = int.parse(request.Query["idaccount"]);
}
AccountNotificationsTable Tabla = new AccountNotificationsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.byIdContact(idaccount, idcontact).data;
//GLib.print(Tabla.byIdContact(idaccount, idcontact, true));
return Retorno;
}


// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseGetAccountContact(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;
int idcontact = 0;
int idaccount = 0;
if(request.Query.has_key("idaccount") && request.Query.has_key("idcontact")){
idcontact = int.parse(request.Query["idcontact"]);
idaccount = int.parse(request.Query["idaccount"]);
}
AccountContactsTable Tabla = new AccountContactsTable();
Tabla.GetParamCnx();
Retorno.Data = Tabla.byIdXml(idaccount, idcontact).data;
return Retorno;
}

private uHttp.Response ResponseAccountContactsToGridx(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

int id = 0;
if(request.Query.has_key("idaccount")){
id = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_account_contacts_xml(id).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}



private uHttp.Response request_fun_account_phones_trigger_alarm_table_from_hashmap(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_phones_trigger_alarm_table_from_hashmap(request.Form).data;
return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseGetEventsMonitor(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

EventTable Tabla = new EventTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.LastXml().data;
//print("ResponseGetEventsMonitor >>> \n%s\n", Tabla.Last_Xml());

return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseAccountSaveTable(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_table_xml_from_hashmap(request.Form).data;

return Retorno;
}





/*
private uHttp.Response ResponseAccountUserAddTable(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_users_add_from_hashmap(request.Form).Xml().data;
//print("ResponseAccountSaveTable >>> \n%s\n", Tabla.fun_account_table_from_hashmap(request.Form).Xml());

return Retorno;
}
*/


private uHttp.Response fun_account_users_table_xml_from_hashmap(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_users_table_xml_from_hashmap(request.Form).data;

return Retorno;
}


private uHttp.Response ResponseGetAccountPhonesTrigger(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.AccountPhonesTriggerAlarmViewdbXml_from_hashmap(request.Query).data;

return Retorno;
}

private uHttp.Response ResponseAccountsNamesToSelectBox(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_idaccounts_names_xml().data;
//print(Tabla.NameAndId_All_Xml());

return Retorno;
}

private uHttp.Response request_fun_view_account_users_xml(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

int id = 0;
if(request.Query.has_key("idaccount")){
id = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_account_users_xml(id).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseGetAccount(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;
//print("ResponseGetAccount\n");
int id = 0;

if(request.Query.has_key("idaccount")){
id = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

Retorno.Data = Tabla.fun_view_account_byid_xml(id).data;

return Retorno;
}

private uHttp.Response response_usaga_account_map(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/html";
    Retorno.Header.Status = StatusCode.OK;

int idaccount = 0;

if(request.Query.has_key("idaccount")){
idaccount = int.parse(request.Query["idaccount"]); 
}

var retornoHtml = uHttpServer.ReadFile(this.PathLocalFile("usaga_account_map.html")).replace("data-usaga-idaccount=\"0\"", "data-usaga-idaccount=\""+idaccount.to_string()+"\"");

Retorno.Data = retornoHtml.data;
return Retorno;
}

private uHttp.Response response_fun_view_account_location_byid_xml(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

int id = 0;
if(request.Query.has_key("idaccount")){
id = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_account_location_byid_xml(id).data;
return Retorno;
}

private uHttp.Response request_fun_view_account_unregistered_contacts_xml(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

int idaccount = 0;
if(request.Query.has_key("idaccount")){
idaccount = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_account_unregistered_contacts_xml(idaccount).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}

private uHttp.Response request_fun_view_account_unregistered_users_xml(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

int idaccount = 0;
if(request.Query.has_key("idaccount")){
idaccount = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_view_account_unregistered_users_xml(idaccount).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response request_fun_view_account_user_byidaccountidcontact_xml(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;
//print("ResponseGetAccount\n");
int idcontact = 0;
int idaccount = 0;

if(request.Query.has_key("idaccount") && request.Query.has_key("idcontact")){
idcontact = int.parse(request.Query["idcontact"]);
idaccount = int.parse(request.Query["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

Retorno.Data = Tabla.fun_view_account_user_byidaccountidcontact_xml(idaccount, idcontact).data;

return Retorno;
}

// Inicia y corre el servidor asincronicamente
public void runuSAGA(){

uSagaProcessData Pro = new uSagaProcessData();
Pro.GetParamCnx();
print("uSAGA Software - idowner: %i\n", Pro.fun_get_idowner_usaga());

try{
Thread.create<void>(Pro.Run, false);
}
catch(ThreadError e){
print(e.message);
}

    this.runuSMS();
}



}



}
