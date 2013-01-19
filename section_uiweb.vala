//New file source
using GLib;
using Gee;
using edwinspire.uSMS;
//using edwinspire.GSM.MODEM;
using Xml;
using edwinspire.uHttp;

namespace edwinspire.OpenSAGA{

public class OpenSagaServer:GLib.Object{

private uHttpServer S = new uHttpServer ();

//private ArrayList<Device> Dispositivos = new ArrayList<Device>();
//private  HashSet<string> PuertosUnicos = new HashSet<string>();

public OpenSagaServer(){

print("Start OpenSAGA Version: 0.01\n");
print("Licence: LGPL\n");
print("Contact: edwinspire@gmail.com\n");

S.Port = 8081;

S.Index = "opensaga.html";
S.VirtualUrl["opensagagetaccount"] = "/opensagagetaccount";
S.VirtualUrl["opensagasaveaccount"] = "/opensagasaveaccount";
S.VirtualUrl["opensagagetvaluesselectbox"] = "/opensagagetvaluesselectbox"; 
S.VirtualUrl["opensagagetaccountusersgrid"] = "/opensagagetaccountusersgrid";
//S.VirtualUrl["usmsgetcontactsvaluesselectbox"] = "/usmsgetcontactsvaluesselectbox";  
S.VirtualUrl["opensagagetaccountuser"] = "/opensagagetaccountuser";
S.VirtualUrl["opensagasaveaccountuser"] = "/opensagasaveaccountuser";
S.VirtualUrl["opensagageteventsmonitor"] = "/opensagageteventsmonitor";       
S.VirtualUrl["opensagaaddaccountuser"] = "/opensagaaddaccountuser";
S.VirtualUrl["opensagagetaccountlocation"] = "/opensagagetaccountlocation";
S.VirtualUrl["opensagasaveaccountlocation"] = "/opensagasaveaccountlocation";
S.VirtualUrl["opensagagetaccountphonestriggerview"] = "/opensagagetaccountphonestriggerview";
S.VirtualUrl["opensagaaccountphonestriggerviewchanged"] = "/opensagaaccountphonestriggerviewchanged";
S.VirtualUrl["opensagagetaccountcontactsgrid"] = "/opensagagetaccountcontactsgrid";
S.VirtualUrl["opensagagetaccountphonesnotifgrid"] = "/opensagagetaccountphonesnotifgrid";
S.VirtualUrl["opensagagetaccountcontact"] = "/opensagagetaccountcontact";
S.VirtualUrl["opensagagetaccountphonesnotifeventtypegrid"] = "/opensagagetaccountphonesnotifeventtypegrid";
S.VirtualUrl["opensagagetaccountcontactstable"] = "/opensagagetaccountcontactstable";
S.VirtualUrl["opensagagetaccountnotificationstable"] = "/opensagagetaccountnotificationstable";
S.VirtualUrl["opensagagetviewnotificationtemplates"] = "/opensagagetviewnotificationtemplates";




foreach(var u in uSMSServer.VirtualUrls().entries){
S.VirtualUrl[u.key] = u.value;
}
 
S.RequestVirtualUrl.connect(RequestVirtualPageHandler);

}


public void RequestVirtualPageHandler(uHttpServer server, Request request, DataOutputStream dos){

    uHttp.Response response = new uHttp.Response();
//print("request.Path =>>>> %s\n", request.Path);
switch(request.Path){
case  "/opensagagetaccount":
response = ResponseGetAccount(request);
break;
case  "/opensagasaveaccount":
response = ResponseAccountSaveTable(request);
break;
case "/opensagagetvaluesselectbox":
response = ResponseAccountsNamesToSelectBox(request);
break;
case "/opensagagetaccountusersgrid":
response = ResponseAccountUsersToGridx(request);
break;
case "/opensagagetaccountuser":
response = ResponseGetUserAccount(request);
break;
case "/opensagasaveaccountuser":
response = ResponseAccountUsersTable(request);
break;
case "/opensagageteventsmonitor":
response = ResponseGetEventsMonitor(request);
break;
case "/opensagaaddaccountuser":
response = ResponseAccountUserAddTable(request);
break;
case "/opensagagetaccountlocation":
response = ResponseAccountGetLocation(request);
break;
case "/opensagasaveaccountlocation":
response = ResponseAccountLocationSaveTable(request);
break;

case "/opensagagetaccountphonestriggerview":
response = ResponseGetAccountPhonesTrigger(request);
break;

case "/opensagaaccountphonestriggerviewchanged":
response = ResponseAccountPhonesTriggerChangeTable(request);
break;

case "/opensagagetaccountcontactsgrid":
response = ResponseAccountContactsToGridx(request);
break;

case "/opensagagetaccountcontact":
response = ResponseGetAccountContact(request);
break;
case "/opensagagetaccountphonesnotifgrid":
response = ResponseAccountContactPhonesNotifToGridx(request);
break;

case "/opensagagetaccountphonesnotifeventtypegrid":
response = ResponseAccountContactPhonesNotifEventTypeToGridx(request);
break;
case "/opensagagetaccountcontactstable":
response = ResponseAccountContactsTable(request);
break;
case "/opensagagetaccountnotificationstable":
response = ResponseAccountNotificationsTable(request);
break;
case "/opensagagetviewnotificationtemplates":
response = ResponseViewNotificationTemplates(request);
break;
default:
response = uSMSServer.ResponseToVirtualRequest(request);
break;
}

    server.serve_response( response, dos );

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
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountPhonesTriggerAlarmTable Tabla = new AccountPhonesTriggerAlarmTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_phones_trigger_alarm_table_from_hashmap(request.Form).Xml().data;
//print("ResponseAccountSaveTable >>> \n%s\n", Tabla.fun_account_table_from_hashmap(request.Form).Xml());

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
  Retorno.Header.ContentType = "text/plain";
    Retorno.Header.Status = StatusCode.OK;

AccountTable Tabla = new AccountTable();
Tabla.GetParamCnx();

    Retorno.Data =  Tabla.fun_account_table_from_hashmap(request.Form).Xml().data;
//print("ResponseAccountSaveTable >>> \n%s\n", Tabla.fun_account_table_from_hashmap(request.Form).Xml());

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

OpenSagaProcessData Pro = new OpenSagaProcessData();

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
