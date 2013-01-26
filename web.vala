//New file source
using GLib;
using Gee;
using edwinspire.uSMS;
//using edwinspire.GSM.MODEM;
using Xml;
using edwinspire.uHttp;

namespace edwinspire.uSAGA{

public class uSagaServer:GLib.Object{

private uHttpServer S = new uHttpServer ();

//private ArrayList<Device> Dispositivos = new ArrayList<Device>();
//private  HashSet<string> PuertosUnicos = new HashSet<string>();

public uSagaServer(){

print("Start uSAGA Version: 0.02\n");
print("Licence: LGPL\n");
print("Contact: edwinspire@gmail.com\n");

S.Port = 8081;

S.Index = "usaga.html";
S.VirtualUrl["getaccount.usaga"] = "/getaccount.usaga";
S.VirtualUrl["saveaccount.usaga"] = "/saveaccount.usaga";
S.VirtualUrl["getvaluesselectbox.usaga"] = "/getvaluesselectbox.usaga"; 
S.VirtualUrl["getaccountusersgrid.usaga"] = "/getaccountusersgrid.usaga";
//S.VirtualUrl["usmsgetcontactsvaluesselectbox"] = "/usmsgetcontactsvaluesselectbox";  
S.VirtualUrl["getaccountuser.usaga"] = "/getaccountuser.usaga";
S.VirtualUrl["saveaccountuser.usaga"] = "/saveaccountuser.usaga";
S.VirtualUrl["usaga_geteventsmonitor.usaga"] = "/usaga_geteventsmonitor.usaga";       
S.VirtualUrl["opensagaaddaccountuser"] = "/opensagaaddaccountuser";
S.VirtualUrl["getaccountlocation.usaga"] = "/getaccountlocation.usaga";
S.VirtualUrl["saveaccountlocation.usaga"] = "/saveaccountlocation.usaga";
S.VirtualUrl["getaccountphonestriggerview.usaga"] = "/getaccountphonestriggerview.usaga";
S.VirtualUrl["accountphonestriggerviewchanged.usaga"] = "/accountphonestriggerviewchanged.usaga";
S.VirtualUrl["getaccountcontactsgrid.usaga"] = "/getaccountcontactsgrid.usaga";
S.VirtualUrl["getaccountphonesnotifgrid.usaga"] = "/getaccountphonesnotifgrid.usaga";
S.VirtualUrl["getaccountcontact.usaga"] = "/getaccountcontact.usaga";
S.VirtualUrl["getaccountphonesnotifeventtypegrid.usaga"] = "/getaccountphonesnotifeventtypegrid.usaga";
S.VirtualUrl["getaccountcontactstable.usaga"] = "/getaccountcontactstable.usaga";
S.VirtualUrl["getaccountnotificationstable.usaga"] = "/getaccountnotificationstable.usaga";
S.VirtualUrl["usagagetviewnotificationtemplates"] = "/usagagetviewnotificationtemplates";
S.VirtualUrl["usaganotificationtemplatesedit"] = "/usaganotificationtemplatesedit";



foreach(var u in uSMSServer.VirtualUrls().entries){
S.VirtualUrl[u.key] = u.value;
}
 
S.RequestVirtualUrl.connect(RequestVirtualPageHandler);

}


public void RequestVirtualPageHandler(uHttpServer server, Request request, DataOutputStream dos){

    uHttp.Response response = new uHttp.Response();
//print("request.Path =>>>> %s\n", request.Path);
switch(request.Path){
case  "/getaccount.usaga":
response = ResponseGetAccount(request);
break;
case  "/saveaccount.usaga":
response = ResponseAccountSaveTable(request);
break;
case "/getvaluesselectbox.usaga":
response = ResponseAccountsNamesToSelectBox(request);
break;
case "/getaccountusersgrid.usaga":
response = ResponseAccountUsersToGridx(request);
break;
case "/getaccountuser.usaga":
response = ResponseGetUserAccount(request);
break;
case "/saveaccountuser.usaga":
response = ResponseAccountUsersTable(request);
break;
case "/usaga_geteventsmonitor.usaga":
response = ResponseGetEventsMonitor(request);
break;
case "/opensagaaddaccountuser":
response = ResponseAccountUserAddTable(request);
break;
case "/getaccountlocation.usaga":
response = ResponseAccountGetLocation(request);
break;
case "/saveaccountlocation.usaga":
response = ResponseAccountLocationSaveTable(request);
break;

case "/getaccountphonestriggerview.usaga":
response = ResponseGetAccountPhonesTrigger(request);
break;

case "/accountphonestriggerviewchanged.usaga":
response = ResponseAccountPhonesTriggerChangeTable(request);
break;

case "/getaccountcontactsgrid.usaga":
response = ResponseAccountContactsToGridx(request);
break;

case "/getaccountcontact.usaga":
response = ResponseGetAccountContact(request);
break;
case "/getaccountphonesnotifgrid.usaga":
response = ResponseAccountContactPhonesNotifToGridx(request);
break;

case "/getaccountphonesnotifeventtypegrid.usaga":
response = ResponseAccountContactPhonesNotifEventTypeToGridx(request);
break;
case "/getaccountcontactstable.usaga":
response = ResponseAccountContactsTable(request);
break;
case "/getaccountnotificationstable.usaga":
response = ResponseAccountNotificationsTable(request);
break;
case "/usagagetviewnotificationtemplates":
response = ResponseViewNotificationTemplates(request);
break;
case "/usaganotificationtemplatesedit":
response = ResponseNotificationTemplatesEdit(request);
break;

default:
response = uSMSServer.ResponseToVirtualRequest(request);
break;
}

    server.serve_response( response, dos );

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


private uHttp.Response ResponseViewNotificationTemplates(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

NotificationTemplates Tabla = new NotificationTemplates();
Tabla.GetParamCnx();
Retorno.Data = Tabla.fun_view_notification_templates_xml().data;
//GLib.print(Tabla.fun_account_notifications_table_xml_from_hashmap(request.Form));
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
print(Tabla.fun_account_contacts_table_from_hasmap(request.Form));
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
GLib.print(Tabla.byIdContact(idaccount, idcontact, true));
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



private uHttp.Response ResponseAccountPhonesTriggerChangeTable(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_phones_trigger_alarm_table_from_hashmap(request.Form).Xml().data;
return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseAccountLocationSaveTable(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountLocationTable Tabla = new AccountLocationTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_location_table_from_hashmap(request.Form).Xml().data;
//print("ResponseAccountSaveTable >>> \n%s\n", Tabla.fun_account_table_from_hashmap(request.Form).Xml());

return Retorno;
}

private uHttp.Response ResponseAccountGetLocation(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

int id = 0;
if(request.Form.has_key("idaccount")){
id = int.parse(request.Form["idaccount"]);
}

AccountLocationTable Tabla = new AccountLocationTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.LocationbyIdAccountXml(id).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseGetEventsMonitor(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/xml";
    Retorno.Header.Status = StatusCode.OK;

EventView Tabla = new EventView();
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


private uHttp.Response ResponseAccountUsersTable(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_users_table_from_hashmap(request.Form).Xml().data;

return Retorno;
}


private uHttp.Response ResponseGetAccountPhonesTrigger(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.AccountPhonesTriggerAlarmViewdbXml_from_hashmap(request.Form).data;

return Retorno;
}

private uHttp.Response ResponseAccountsNamesToSelectBox(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.NameAndId_All_Xml().data;
//print(Tabla.NameAndId_All_Xml());

return Retorno;
}

private uHttp.Response ResponseAccountUsersToGridx(Request request){

uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

int id = 0;
if(request.Form.has_key("idaccount")){
id = int.parse(request.Form["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.AccountUsersViewXml(id).data;
//print(Tabla.UserAndIdContact_Xml(id));
return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseGetAccount(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;
//print("ResponseGetAccount\n");
int id = 0;

if(request.Form.has_key("idaccount")){
id = int.parse(request.Form["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

Retorno.Data = Tabla.byIdXml(id).data;

//print("ResponseGetAccount id = %s\n%s\n", id.to_string(), Tabla.byIdXml(id));

return Retorno;
}

// Recibe los datos y los actualiza en la base de datos.
private uHttp.Response ResponseGetUserAccount(Request request){
uHttp.Response Retorno = new uHttp.Response();
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;
//print("ResponseGetAccount\n");
int idcontact = 0;
int idaccount = 0;

if(request.Form.has_key("idaccount") && request.Form.has_key("idcontact")){
idcontact = int.parse(request.Form["idcontact"]);
idaccount = int.parse(request.Form["idaccount"]);
}

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

Retorno.Data = Tabla.UserbyIdContactXml(idaccount, idcontact).data;

return Retorno;
}

// Inicia y corre el servidor asincronicamente
public void Run(){
S.RequestPrintOnConsole = true;

uSagaProcessData Pro = new uSagaProcessData();

try{
Thread.create<void>(Pro.Run, false);
}
catch(ThreadError e){
print(e.message);
}


//this.ResetAndLoadDevices();
print("Connect: http://localhost:%s\n", S.Port.to_string());
    S.run();
}



}



}
