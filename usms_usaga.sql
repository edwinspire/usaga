--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.7
-- Dumped by pg_dump version 9.1.7
-- Started on 2013-01-26 02:54:16 ECT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2583 (class 1262 OID 16384)
-- Dependencies: 2582
-- Name: usms; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE usms IS 'Base de datos de uSMS.';


--
-- TOC entry 7 (class 2615 OID 16964)
-- Name: opensaga; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA opensaga;


--
-- TOC entry 2584 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA opensaga; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA opensaga IS 'Esquema de detos de OpenSAGA';


--
-- TOC entry 227 (class 3079 OID 11644)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2587 (class 0 OID 0)
-- Dependencies: 227
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 247 (class 1255 OID 27005)
-- Dependencies: 787 7
-- Name: fun_account_contacts_byid(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_contacts_byid(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResultado FOR SELECT idaccount, idcontact, enable, encode(firstname::bytea, 'base64') as firstname, encode(lastname::bytea, 'base64') as lastname, prioritycontact, enable_as_contact, encode(appointment::bytea, 'base64') as appointment, encode(note::bytea, 'base64') as note, ts  FROM opensaga.view_account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;

ELSE

OPEN CursorResultado FOR SELECT * FROM opensaga.view_account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;

END IF;

RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 286 (class 1255 OID 26932)
-- Dependencies: 7 787
-- Name: fun_account_contacts_table(integer, integer, integer, boolean, text, text, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN


IF EXISTS(SELECT * FROM opensaga.account WHERE idaccount = inidaccount) AND EXISTS(SELECT * FROM contacts WHERE idcontact = abs(inidcontact)) THEN

IF inidcontact > 0 THEN

IF EXISTS(SELECT * FROM opensaga.account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact) THEN
-- Actualizamos
UPDATE opensaga.account_contacts SET prioritycontact = inpriority, enable = inenable, appointment = inappointment, note = innote WHERE idaccount = inidaccount AND idcontact = inidcontact;

IF FOUND THEN
outpgmsg := 'Registro actualizado';
outreturn := inidcontact; 
ELSE
outpgmsg := 'El registro no pudo ser actualizado';
outreturn := -2; 
END IF;

ELSE
-- Creamos nuevo
INSERT INTO opensaga.account_contacts (idcontact, idaccount, enable, prioritycontact, appointment, note) VALUES (inidcontact, inidaccount, inenable, inpriority, inappointment, innote) RETURNING idcontact INTO outreturn;
outpgmsg := 'Nuevo contacto registrado';
END IF;

ELSE
-- Eliminamos el registro
DELETE FROM opensaga.account_contacts WHERE idaccount = inidaccount AND idcontact = abs(inidcontact);
outreturn := abs(inidcontact);
outpgmsg := 'idcontact '||inidcontact::text||' de idaccount '||inidaccount::text||' ha sido eliminado';
END IF;

ELSE
outreturn := -1;
outpgmsg := 'idaccount '||inidaccount::text||' o idcontact '||inidcontact::text||' no existen';
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;

$$;


--
-- TOC entry 2588 (class 0 OID 0)
-- Dependencies: 286
-- Name: FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) IS 'Agrega, edita y elimina contactos de una cuenta.';


--
-- TOC entry 289 (class 1255 OID 26948)
-- Dependencies: 7 787
-- Name: fun_account_contacts_table_xml(integer, integer, integer, boolean, text, text, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_contacts_table_xml(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM opensaga.fun_account_contacts_table(inidaccount, inidcontact, inpriority, inenable, inappointment, innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 273 (class 1255 OID 25923)
-- Dependencies: 7 787
-- Name: fun_account_event_notifications_sms(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_event_notifications_sms() RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE

CursorEvents CURSOR FOR SELECT * FROM opensaga.events WHERE process1=0 ORDER BY priority, datetimeevent;
EventROWDATA   opensaga.events%ROWTYPE;

CursorNotifactions refcursor;
NotificationROWDATA   opensaga.account_notifications%ROWTYPE;

TextSMS TEXT DEFAULT 'Alarma!';
InternalidphoneToAlarmaFromCall INTEGER DEFAULT 0;
InternalidincallToAlarmaFromCall INTEGER DEFAULT 0;

BEGIN
-- Obtenemos todos los eventos que no hay sido procesados automaticamente

    OPEN CursorEvents;
    loop
    
        FETCH CursorEvents INTO EventROWDATA;
        EXIT WHEN NOT FOUND;
       
-- El el evento es tipo 72 (Generado por llamada telefonica) Enviamos las notificaciones a todas las persona configuradas         
-- TODO: Debe enviarse a las personas que tiene asignado ese tipo de evento

    OPEN CursorNotifactions FOR SELECT * FROM opensaga.account_notifications WHERE idaccount = EventROWDATA.idaccount;
    loop

        FETCH CursorNotifactions INTO NotificationROWDATA;
        EXIT WHEN NOT FOUND;

-- Definimos el texto del mensaje
IF length(NotificationROWDATA.smstext) > 0 THEN
-- Su vecino “Juan Perez Gallardo” domiciliado en “Agustinas 131” tiene una emergencia.
TextSMS := opensaga.fun_notification_gen_message(EventROWDATA.idaccount::INTEGER, EventROWDATA.idevent::INTEGER, EventROWDATA.ideventtype::INTEGER, NotificationROWDATA.smstext::TEXT);
ELSE
TextSMS := EventROWDATA.description;
END IF;

      
PERFORM fun_smsout_insert_sendnow(0, 10, NotificationROWDATA.idphone::INTEGER, 1, ''::text, TextSMS, false, 1, 'Notificacion generada automaticamente');

    end loop;
    CLOSE CursorNotifactions;

-- Tipo de evento 72 es alarma por llamada telefonica, debemos enviar una notificacion al propietario de la linea informando la recepcion de la alarma
IF EventROWDATA.ideventtype = 72 THEN

SELECT idincall INTO InternalidincallToAlarmaFromCall FROM opensaga.events_generated_by_calls WHERE idevent = EventROWDATA.idevent;

IF InternalidincallToAlarmaFromCall>0 THEN

SELECT idphone INTO InternalidphoneToAlarmaFromCall FROM incomingcalls WHERE idincall = InternalidincallToAlarmaFromCall;
IF InternalidphoneToAlarmaFromCall > 0 THEN
PERFORM fun_smsout_insert_sendnow(0, 10, InternalidphoneToAlarmaFromCall, 10, ''::text, 'OpenSAGA ha recibido su señal', true, 0, 'SMS generado automaticamente');
END IF;
END IF;

END IF;

-- Actualizamos el proceso del evento a 1
UPDATE opensaga.events  SET process1 = 1, dateprocess1 = now() WHERE idevent = EventROWDATA.idevent;

    end loop;
    CLOSE CursorEvents;


RETURN TRUE;
END;$$;


--
-- TOC entry 2589 (class 0 OID 0)
-- Dependencies: 273
-- Name: FUNCTION fun_account_event_notifications_sms(); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_event_notifications_sms() IS 'Genere notificaciones (sms) segun se haya programado para cada cliente.';


--
-- TOC entry 276 (class 1255 OID 26359)
-- Dependencies: 787 7
-- Name: fun_account_insert_update(integer, integer, boolean, text, text, integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;
ValidData boolean DEFAULT false;
IdAccountSearchByName INTEGER DEFAULT -1;
IdAccountSearchByNumber INTEGER DEFAULT -1;

BEGIN

-- Primero validamos los datos antes de procegir
IdAccountSearchByName := opensaga.fun_account_search_name(inname);
IdAccountSearchByNumber := opensaga.fun_account_search_number(inaccount);

IF EXISTS(SELECT account FROM opensaga.account WHERE idaccount = inidaccount) THEN
-- El registro se debe actualizar
-- Verificamos que el name sea valido
IF IdAccountSearchByName = inidaccount OR IdAccountSearchByName = 0 THEN
-- El nombre de la cuenta corresponde a la misma cuenta o no pertenece a otra cuenta, se lo puede usar

-- Verificamos que el account sea valido
IF IdAccountSearchByNumber = inidaccount OR IdAccountSearchByNumber = 0 THEN
-- El account de la cuenta corresponde a la misma cuenta o no pertenece a otra cuenta, se lo puede usar
UPDATE opensaga.account SET partition = inpartition, enable = inenable, account = inaccount, name = inname, type = intype, note = innote, tabletimestamp = now() WHERE idaccount = inidaccount RETURNING idaccount INTO Retorno;
ELSE
-- El account de la cuenta no se puede cambiar porque ya existe
Retorno := -2;
END IF;


ELSE
-- El nombre de la cuenta no se puede cambiar porque ya existe
Retorno := -1;
END IF;

ELSE
-- Verificamos datos para el nuevo registro
IF IdAccountSearchByNumber = 0 AND IdAccountSearchByName = 0 THEN
-- creamos la cuenta
INSERT INTO opensaga.account (partition, enable, account, name, type, dateload, note) VALUES (inpartition, inenable, inaccount, inname, intype, now(), innote) RETURNING idaccount INTO Retorno;
ELSE
-- account o name ya existen
Retorno := -3;
END IF;


END IF;

RETURN;
END;$$;


--
-- TOC entry 2590 (class 0 OID 0)
-- Dependencies: 276
-- Name: FUNCTION fun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) IS 'Funcion inserta o actualiza registros de la tabla accounts. Realiza verificacion de datos antes de realizar la operacion.
Si inid es mayor que 1 actualiza el registro, caso contrario cre uno nuevo
Devuelve:
el id de la cuenta
0  No se ha realizado ninguna accion
-1 El nombre de la cuenta ya existe
-2 El numero de la cuenta ya existe
-3 Imposible crear nueva cuenta, account o name ya estan siendo usados';


--
-- TOC entry 280 (class 1255 OID 26854)
-- Dependencies: 7 787
-- Name: fun_account_location_table(integer, real, real, text, text, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_location_table(inidaccount integer, ingeox real, ingeoy real, inaddress text, inidaddress text, innote text, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outpgmsg := '';
outreturn := 0;

-- Verificamos que el numero de cuenta sea mayos que 0
IF abs(inidaccount) > 0 THEN

IF EXISTS(SELECT * FROM opensaga.account_location WHERE idaccount = abs(inidaccount)) THEN

IF inidaccount > 0 THEN
-- Actualiza los datos
UPDATE opensaga.account_location SET geox = ingeox, geoy = ingeoy, address = inaddress, idaddress = inidaddress, note = innote WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Localizacion de idaccount '||inidaccount::text||' actualizada';
ELSE
-- Borra los datos (No elimina el registro)
UPDATE opensaga.account_location SET geox = 0, geoy = 0, address = '', idaddress = '', note = '' WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Borrardos datos de localización idaccount '||inidaccount::text;
END IF;

ELSE
-- Inserta
INSERT INTO opensaga.account_location (idaccount, geox, geoy, address, idaddress, note) VALUES (inidaccount, ingeox, ingeoy, inaddress, inidaddress, innote) RETURNING idaccount INTO outreturn;
outpgmsg := 'Localizacion de idaccount '||inidaccount::text||' creada';
END IF;

ELSE
outpgmsg := 'El idaccount '||inidaccount::text||' no es valido.';
outreturn := -1;
END IF;

RETURN;
END;$$;


--
-- TOC entry 268 (class 1255 OID 26946)
-- Dependencies: 787 7
-- Name: fun_account_notifications_table(integer, integer, integer, integer, boolean, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_notifications_table(inidnotifaccount integer, inidaccount integer, inidphone integer, inpriority integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

internalidnotifaccount INTEGER DEFAULT 0;

BEGIN

outreturn := 0;
outpgmsg := 'Ninguna accion realizada';

SELECT idnotifaccount INTO internalidnotifaccount FROM opensaga.account_notifications WHERE idaccount = inidaccount AND idphone = inidphone LIMIT 1;

IF internalidnotifaccount > 0 THEN
-- Actualizamos
UPDATE opensaga.account_notifications SET priority = inpriority, call = incall, sms = insms, smstext = insmstext, note = innote WHERE idnotifaccount = internalidnotifaccount;
outreturn := internalidnotifaccount;
outpgmsg := 'Registro actualizado';
ELSE
-- Insertamos
INSERT INTO opensaga.account_notifications (idaccount, idphone, priority, call, sms, smstext, note) VALUES (inidaccount, inidphone, inpriority, incall, insms, insmstext, innote) RETURNING idnotifaccount INTO outreturn;
outpgmsg := 'Registro insertado';
END IF;


IF fieldtextasbase64 THEN

outpgmsg := encode(outpgmsg::bytea, 'base64');

END IF;


RETURN;
END;$$;


--
-- TOC entry 287 (class 1255 OID 26944)
-- Dependencies: 7 787
-- Name: fun_account_notifications_table_xml(integer, integer, integer, integer, boolean, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_notifications_table_xml(inidnotifaccount integer, inidaccount integer, inidphone integer, prioinrity integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM opensaga.fun_account_notifications_table(inidnotifaccount, inidaccount, inidphone, prioinrity, incall, insms, insmstext, innote, ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 283 (class 1255 OID 26870)
-- Dependencies: 787 7
-- Name: fun_account_phones_trigger_alarm_isuser(integer, integer); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno BOOLEAN DEFAULT FALSE;
InIdContact INTEGER DEFAULT 0;
BEGIN

-- Obtenemos el IdContact a quien pertenece ese idphone
SELECT idcontact INTO InIdContact FROM phones WHERE idphone = inidphone; 
IF EXISTS(SELECT * FROM opensaga.account_users WHERE idaccount = inidaccount AND idcontact = InIdContact) THEN
-- El telefono pertenece a un usuario del sistema
Retorno := TRUE;
ELSE
-- Eliminamos ese registro si existe
IF EXISTS(SELECT * FROM opensaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone) THEN
DELETE FROM opensaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone;
END IF;
Retorno := FALSE;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2591 (class 0 OID 0)
-- Dependencies: 283
-- Name: FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) IS 'Chequea que el idphone pasado como parametro pertenesca a un usuario de la cuenta, caso contrario lo elimina.
Devuelve true si es usuario y false si no lo es.';


--
-- TOC entry 284 (class 1255 OID 26420)
-- Dependencies: 787 7
-- Name: fun_account_phones_trigger_alarm_table(integer, integer, boolean, boolean, boolean, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN

-- TODO: Aqui hacer un chequeo de todos los registros


IF opensaga.fun_account_phones_trigger_alarm_isuser(inidaccount, inidphone)  THEN
-- idphone pertenece a un usuario del sistema, proseguir.

IF EXISTS(SELECT * FROM opensaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone) THEN

IF inenable OR infromsms OR infromcall OR length(innote) > 0 THEN
-- Actualizamos el registro
UPDATE opensaga.account_phones_trigger_alarm SET enable = inenable, fromsms = infromsms, fromcall = infromcall, note = innote WHERE idaccount = inidaccount AND idphone = inidphone RETURNING idphone INTO outreturn;
outpgmsg := 'Registro actualizado';
ELSE
-- Todos los valores son falsos eliminamos el registro
DELETE FROM opensaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone;
outpgmsg := 'Registro limpiado';
END IF;

ELSE
-- Crear Registro si hay datos que crear
IF inenable OR infromsms OR infromcall OR length(innote) > 0 THEN
INSERT INTO opensaga.account_phones_trigger_alarm (idaccount, idphone, enable, fromsms, fromcall, note) VALUES (inidaccount, inidphone, inenable, infromsms, infromcall, innote) RETURNING idphone INTO outreturn;
outpgmsg := 'Registro insertado';
ELSE
outreturn := -1;
outpgmsg := 'No hay datos que ingresar';
END IF;

END IF;


END IF;

RETURN;
END;$$;


--
-- TOC entry 2592 (class 0 OID 0)
-- Dependencies: 284
-- Name: FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text) IS 'Agregar / elimina los numeros autorizados a disparar la alarma. Solo numeros de usuarios del sistema son permitidos';


--
-- TOC entry 240 (class 1255 OID 17933)
-- Dependencies: 7 787
-- Name: fun_account_search_name(text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_search_name(innameaccount text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT -1;

BEGIN

SELECT idaccount INTO Retorno FROM opensaga.account WHERE name = innameaccount;

IF Retorno<1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2593 (class 0 OID 0)
-- Dependencies: 240
-- Name: FUNCTION fun_account_search_name(innameaccount text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_search_name(innameaccount text) IS 'Devuelve el idaccount de la cuenta que tiene el nombre pasado como parametro, si no hay cuentas con ese nombre devuelve 0, devuelve -1 en caso de falla';


--
-- TOC entry 241 (class 1255 OID 17934)
-- Dependencies: 787 7
-- Name: fun_account_search_number(text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_search_number(innumberaccount text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT -1;

BEGIN

SELECT idaccount INTO Retorno FROM opensaga.account WHERE account = innumberaccount;

IF Retorno<1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2594 (class 0 OID 0)
-- Dependencies: 241
-- Name: FUNCTION fun_account_search_number(innumberaccount text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_search_number(innumberaccount text) IS 'Busca el idaccount basado en el numero pasado como parametro';


--
-- TOC entry 248 (class 1255 OID 27009)
-- Dependencies: 7 787
-- Name: fun_account_table(integer, boolean, text, text, integer, integer, integer, text, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

IdAccountSearchByName INTEGER DEFAULT 0;
IdAccountSearchByNumber INTEGER DEFAULT 0;
initialaccount TEXT DEFAULT '0000';
i INTEGER DEFAULT 0;

BEGIN

outreturn := 0;
outpgmsg := 'Ninguna operacion realizada';
initialaccount := inaccount;

-- Primero validamos los datos antes de procegir
-- Buscamos un idaccount con el nombre pasado como parametro
IdAccountSearchByName := opensaga.fun_account_search_name(inname);

CASE
    WHEN inidaccount = 0 THEN

-- Chequeamo que el numero de la cuenta no se repita, si lo hace buscamos el siguiente numero disponible
WHILE opensaga.fun_account_search_number(inaccount) > 0 LOOP
    inaccount := initialaccount||'('||i::text||')';
i := i+1;
END LOOP;

IF IdAccountSearchByName < 1 THEN
        -- Nuevo registro
INSERT INTO opensaga.account (partition, enable, account, name, type, dateload, note, idgroup) VALUES (inpartition, inenable, inaccount, inname, intype, now(), innote, inidgroup) RETURNING idaccount INTO outreturn;       
outpgmsg := 'Nueva cuenta almacenda. idaccount = '||outreturn::TEXT;
--INSERT INTO opensaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent) VALUES (now(), inidaccount, 'SYS', 100, outpgmsg, 79, now());

ELSE
outpgmsg := 'El nombre ['|| inname::text ||'] y esta siendo utilizado por otra cuenta. Utilice otro nombre';
outreturn := -1;
END IF;


    WHEN inidaccount > 0 THEN

IF IdAccountSearchByName < 1 OR IdAccountSearchByName = inidaccount THEN
        -- Actualia registro
UPDATE opensaga.account SET partition = inpartition, enable = inenable, account = inaccount, name = inname, type = intype, note = innote, idgroup = inidgroup WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Actualizada la cuenta idaccount = '||outreturn::TEXT;
--INSERT INTO opensaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent) VALUES (now(), inidaccount, 'SYS', 100, outpgmsg, 78, now());

ELSE
outpgmsg := 'El nombre ['|| inname::text ||'] y esta siendo utilizado por otra cuenta. Utilice otro nombre';
outreturn := -1;
END IF;

        WHEN inidaccount < 0 THEN
        -- Eliminamos el registro si existe
IF EXISTS(SELECT account FROM opensaga.account WHERE idaccount = abs(inidaccount)) THEN
DELETE FROM  opensaga.account WHERE idaccount = abs(inidaccount);
outpgmsg := 'Registro idaccount '|| abs(inidaccount) ||' eliminado.';
outreturn := abs(inidaccount);
END IF;

END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

EXCEPTION
WHEN UNIQUE_VIOLATION THEN
outpgmsg := encode(SQLERRM::bytea, 'base64');



RETURN;
END;$$;


--
-- TOC entry 301 (class 1255 OID 27008)
-- Dependencies: 787 7
-- Name: fun_account_table_xml(integer, boolean, text, text, integer, integer, integer, text, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_table_xml(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM opensaga.fun_account_table(inidaccount , inenable , inaccount , inname, inidgroup ,  inpartition , intype , innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 275 (class 1255 OID 26412)
-- Dependencies: 7 787
-- Name: fun_account_users_table(integer, integer, text, boolean, integer, text, text, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_users_table(inidaccount integer, inidcontact integer, inappointment text, inenable boolean, innumuser integer, inkeyword text, inpwd text, innote text, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outreturn := 0;
outpgmsg := '';

IF EXISTS(SELECT idaccount FROM opensaga.account WHERE idaccount = inidaccount) AND EXISTS(SELECT idcontact FROM contacts WHERE idcontact = abs(inidcontact)) THEN

CASE
	WHEN EXISTS(SELECT idaccount FROM opensaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount) AND inidcontact > 0 THEN
	-- El registro ya existe, actualizarlo
	UPDATE opensaga.account_users SET appointment = inappointment, enable_as_user = inenable, keyword = inkeyword, pwd = inpwd, numuser = innumuser, note_user = innote  WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount;
outreturn := abs(inidcontact);
outpgmsg := 'Usuario actualizado';

	WHEN NOT EXISTS(SELECT idaccount FROM opensaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount) AND inidcontact > 0 THEN
	-- El registro no existe, crearlo
INSERT INTO opensaga.account_users (idaccount, idcontact, appointment, enable_as_user, keyword, pwd, numuser, note_user) VALUES (inidaccount, inidcontact, inappointment, inenable, inkeyword, inpwd, innumuser, innote);
outreturn := abs(inidcontact);
outpgmsg := 'Usuario insertado';

	WHEN inidcontact < 0 THEN
	-- Eliminamos el registro
	DELETE  FROM opensaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount;
outreturn := abs(inidcontact);
outpgmsg := 'Usuario eliminado';
-- Tambien lo eliminamos de la tabla trigger alarm
DELETE FROM opensaga.account_phones_trigger_alarm WHERE idphone IN (SELECT idphone FROM view_contacts_phones WHERE idcontact = abs(inidcontact)) AND idaccount = inidaccount;
outpgmsg := 'Usuario eliminado y eliminada la autorizacion para dispara alarmas';
	END CASE;


ELSE
-- 
outpgmsg := 'idaccount '||inidaccount::text||' o idcontact '||inidcontact::text||' no existen';
outreturn := -1;
END IF;



RETURN;
END;



$$;


--
-- TOC entry 282 (class 1255 OID 26867)
-- Dependencies: 7 787
-- Name: fun_account_users_trigger_phones_contacts(integer, integer); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_users_trigger_phones_contacts(inidaccount integer, inidcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT trigger_alarm boolean, OUT fromsms boolean, OUT fromcall boolean, OUT note text) RETURNS SETOF record
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorViewContactsPhonesAddress CURSOR FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
ROWDATAViewContact   public.view_contacts_phones%ROWTYPE;
ROWDATAPhoneTrigger   opensaga.account_phones_trigger_alarm%ROWTYPE;
BEGIN


OPEN CursorViewContactsPhonesAddress;
    loop    

        FETCH CursorViewContactsPhonesAddress INTO ROWDATAViewContact;
        EXIT WHEN NOT FOUND;

IF EXISTS(SELECT opensaga.account_phones_trigger_alarm.enable FROM opensaga.account_phones_trigger_alarm WHERE opensaga.account_phones_trigger_alarm.idaccount = inidaccount AND opensaga.account_phones_trigger_alarm.idphone = ROWDATAViewContact.idphone LIMIT 1) THEN
SELECT * INTO ROWDATAPhoneTrigger FROM opensaga.account_phones_trigger_alarm WHERE opensaga.account_phones_trigger_alarm.idaccount = inidaccount AND opensaga.account_phones_trigger_alarm.idphone = ROWDATAViewContact.idphone LIMIT 1;
RETURN QUERY SELECT inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAViewContact.address::text, ROWDATAPhoneTrigger.enable::boolean, ROWDATAPhoneTrigger.fromsms::boolean, ROWDATAPhoneTrigger.fromcall::boolean, ROWDATAPhoneTrigger.note::text;
ELSE
RETURN QUERY SELECT inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAViewContact.address::text, 'false'::boolean, 'false'::boolean, 'false'::boolean, ''::text;
END IF;

--UPDATE smsout SET process = 5, idport = FirstCurrentIdPort, dateprocess = now()  WHERE idsmsout = SMSOUTROWDATA.idsmsout;

    end loop;
    CLOSE CursorViewContactsPhonesAddress;





--idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT trigger_alarm boolean, OUT fromsms boolean, OUT fromcall boolean, OUT note text)
 --RETURN QUERY SELECT '1'::integer, '2'::integer, '3'::integer, 'false'::boolean, '0'::integer, '0'::integer, 'phones'::text, 'direccion'::text, 'false'::boolean, 'false'::boolean, 'false'::boolean, 'nota'::text;
 
END
$$;


--
-- TOC entry 271 (class 1255 OID 25922)
-- Dependencies: 787 7
-- Name: fun_auto_process_events(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_auto_process_events() RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
PERFORM opensaga.fun_account_event_notifications_sms();

RETURN TRUE;
END;$$;


--
-- TOC entry 2595 (class 0 OID 0)
-- Dependencies: 271
-- Name: FUNCTION fun_auto_process_events(); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_auto_process_events() IS 'Procesa los eventos:
Envia notificaciones basados en los eventos y configuraciones del sistema';


--
-- TOC entry 246 (class 1255 OID 17544)
-- Dependencies: 7 787
-- Name: fun_eventtype_default(integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_eventtype_default(inid integer, inname text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno INTEGER DEFAULT 0;

BEGIN

IF EXISTS(SELECT name FROM opensaga.eventtypes WHERE ideventtype=inid)  THEN
-- El registro existe, se lo puede actualizar
UPDATE opensaga.eventtypes SET name = inname WHERE ideventtype = inid RETURNING ideventtype INTO Retorno;
ELSE
-- El registro no existe, lo insertamos
INSERT INTO opensaga.eventtypes (ideventtype, name, label) VALUES (inid, inname, inname) RETURNING ideventtype INTO Retorno;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 246
-- Name: FUNCTION fun_eventtype_default(inid integer, inname text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_eventtype_default(inid integer, inname text) IS 'Funcion usada internamente por opesaga para reflejar los EventType usados por el sistema.';


--
-- TOC entry 278 (class 1255 OID 26416)
-- Dependencies: 787 7
-- Name: fun_generate_test_report(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN


RETURN;
END;$$;


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 278
-- Name: FUNCTION fun_generate_test_report(OUT outeventsgenerated integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) IS 'Genera los eventos de reporte de prueba enviados a los clientes.';


--
-- TOC entry 272 (class 1255 OID 26131)
-- Dependencies: 787 7
-- Name: fun_get_priority_from_ideventtype(integer); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_get_priority_from_ideventtype(inideventtype integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;

BEGIN
SELECT priority INTO Retorno FROM opensaga.eventtypes WHERE ideventtype = inideventtype;
IF Retorno IS NULL OR Retorno < 0 THEN
Retorno := 10;
END IF;
RETURN Retorno;
END;$$;


--
-- TOC entry 2598 (class 0 OID 0)
-- Dependencies: 272
-- Name: FUNCTION fun_get_priority_from_ideventtype(inideventtype integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_get_priority_from_ideventtype(inideventtype integer) IS 'Devuelve la prioridad segun el ideventtype';


--
-- TOC entry 274 (class 1255 OID 26215)
-- Dependencies: 7 787
-- Name: fun_notification_gen_message(integer, integer, integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
InternalIdNotifTemplate INTEGER DEFAULT 0;
Internalidphone INTEGER DEFAULT 0;
ContactROWDATA   view_contacts_phones%ROWTYPE;
EventsROWDATA   opensaga.view_events%ROWTYPE;


BEGIN


Retorno := trim(insmstext);

-- Verificamos si el insmstext empieza con &NTxxx donde xxx es el idnotiftemplat y obiemente tiene 6 caracteres
IF length(Retorno) = 6 AND substr(Retorno, 1, 3) =  '&NT' THEN
InternalIdNotifTemplate := to_number(substr(Retorno, 4, 3), '999999');

SELECT message INTO Retorno FROM opensaga.notification_templates WHERE idnotiftempl = InternalIdNotifTemplate;

IF length(Retorno) > 0 OR Retorno IS NOT NULL THEN

-- USUARIO: Hacemos los reemplazos de los datos de usuario si es una evento generado por una llamada telefonica por un usuario
-- TODO: En la tabla eventos hay que ver una forma de registrar el idcontact asociado al usernum para por ejemplo en 
-- desarmados saber que contacto fue que desarmo el sistema.
IF inideventtype = 72 AND (position('&U01' in Retorno) > 0 OR position('&U02' in Retorno)>0 )  THEN
--Retorno:= trim(insmstext);

-- Obtenemos los datos
SELECT * INTO ContactROWDATA FROM view_contacts_phones WHERE idphone = (SELECT idphone FROM incomingcalls WHERE idincall = (SELECT idincall FROM  opensaga.events_generated_by_calls WHERE idevent = inidevent));

IF ContactROWDATA IS NOT NULL THEN
IF position('&U01' in Retorno) > 0 THEN
-- Hacemos el reemplazo
Retorno := replace(Retorno, '&U01', ContactROWDATA.lastname|| ' ' ||ContactROWDATA.firstname);
END IF;

IF position('&U02' in Retorno) > 0 THEN
-- Hacemos el reemplazo
Retorno := replace(Retorno, '&U02', ContactROWDATA.phone);
END IF;

IF position('&U03' in Retorno) > 0 THEN
-- Hacemos el reemplazo
Retorno := replace(Retorno, '&U03', 'NO IMPLEMENTADO');
END IF;

IF position('&U04' in Retorno) > 0 THEN
-- Hacemos el reemplazo
Retorno := replace(Retorno, '&U04', ContactROWDATA.address);
END IF;

IF position('&U05' in Retorno) > 0 THEN
-- Hacemos el reemplazo
Retorno := replace(Retorno, '&U05', 'NO IMPLEMENTADO');
END IF;


END IF;




END IF;

-- EVENTO: Hacemos el reemplazo por la descripcion del evento
IF position('&E01' in Retorno) > 0 OR position('&E02' in Retorno) > 0 OR position('&E03' in Retorno) > 0 OR position('&E04' in Retorno) > 0 THEN
SELECT * INTO EventsROWDATA FROM view_events WHERE idevent = inidevent;

IF position('&E01' in Retorno) > 0 THEN
Retorno := replace(Retorno, '&E01', EventsROWDATA.description);
END IF;

IF position('&E02' in Retorno) > 0 THEN
Retorno := replace(Retorno, '&E02', EventsROWDATA.eventtype);
END IF;


END IF;

ELSE
-- No se encontro ese idnotiftempl
Retorno := insmstext;
END IF;

END IF;



RETURN Retorno;
END;$$;


--
-- TOC entry 2599 (class 0 OID 0)
-- Dependencies: 274
-- Name: FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text) IS 'Genera el texto del mensaje que se enviara como notificcion';


--
-- TOC entry 303 (class 1255 OID 27016)
-- Dependencies: 787 7
-- Name: fun_notification_templates_edit(integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_notification_templates_edit(inidnotiftempl integer, indescription text, inmessage text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN

CASE

WHEN inidnotiftempl > 0 AND EXISTS(SELECT * FROM opensaga.notification_templates WHERE idnotiftempl = inidnotiftempl) THEN
-- Actualizamos opensaga.notification_templates
UPDATE opensaga.notification_templates SET description = indescription, message = inmessage WHERE idnotiftempl = inidnotiftempl RETURNING idnotiftempl INTO outreturn;
outpgmsg := 'Registro id '||outreturn::text||' fue actualizado';

WHEN inidnotiftempl < 0 THEN
-- Eliminamos el registro
DELETE FROM opensaga.notification_templates WHERE idnotiftempl = abs(inidnotiftempl);
outpgmsg := 'Registro id '||abs(inidnotiftempl)::text||' fue eliminado';

WHEN inidnotiftempl = 0 THEN
-- Insertamos un nuevo registro
INSERT INTO opensaga.notification_templates (description, message) VALUES (indescription, inmessage) RETURNING idnotiftempl INTO outreturn;
outpgmsg := 'Registro id '||outreturn::text||' fue creado';
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;
RETURN;
END;$$;


--
-- TOC entry 304 (class 1255 OID 27019)
-- Dependencies: 787 7
-- Name: fun_notification_templates_edit_xml(integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_notification_templates_edit_xml(inidnotiftempl integer, indescription text, inmessage text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM opensaga.fun_notification_templates_edit(inidnotiftempl , indescription , inmessage , ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;
$$;


--
-- TOC entry 270 (class 1255 OID 25921)
-- Dependencies: 7 787
-- Name: fun_receiver_from_incomingcalls(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_receiver_from_incomingcalls(OUT calls integer, OUT eventsgenerated integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

--Retorno INTEGER DEFAULT 0;
vcursor CURSOR FOR SELECT * FROM public.view_callin WHERE flag1=0 AND idphone > 0;
VROWDATA   public.view_callin%ROWTYPE;
IdAccountInternal INTEGER DEFAULT 0;

Internalfirstname TEXT DEFAULT '';
Internallastname TEXT DEFAULT '';
Internalphone TEXT DEFAULT '';
Internalidcontact INTEGER DEFAULT 0;

InternalAlarmPriority INTEGER DEFAULT 1;

BEGIN
calls := 0;
eventsgenerated := 0;

-- Buscamos las llamadas sin idphone y lo marcamos como sin propietario, para ignorarlos a futuro.
UPDATE incomingcalls SET flag1 = 3 WHERE idphone < 1;

-- Obtenemos todas las llamadas que no han sido procesadas.
    OPEN vcursor;
    loop
    
        FETCH vcursor INTO VROWDATA;
        EXIT WHEN NOT FOUND;
                
--LISTEN mymessage;
--PERFORM pg_notify('mymessage', VROWDATA.idcontact::text);   
calls := calls+1;
-- Obtenemos el IdAccount de la cuenta a la que pertenece ese idphone
-- TODO: hacer una verificacion pra que solo usuarios del sistema puedan activar la alarma
SELECT idaccount INTO IdAccountInternal FROM opensaga.view_account_phones_trigger_alarm WHERE idphone = VROWDATA.idphone AND enable = true AND trigger_enable = true AND fromcall = true LIMIT 1;

IF IdAccountInternal > 0 THEN 

-- Obtenemos la prioridad de la alarma segun su tipo
  InternalAlarmPriority := opensaga.fun_get_priority_from_ideventtype(72);

-- Obtenemos los datos del contacto
SELECT idcontact, firstname, lastname, phone INTO Internalidcontact, Internalfirstname, Internallastname, Internalphone  FROM view_contacts_phones WHERE idphone = VROWDATA.idphone;

--PERFORM pg_notify('mymessage', 'Existe'); 
-- Marcamos la llamada como procesada
UPDATE public.incomingcalls SET flag1 = 1 WHERE idincall = VROWDATA.idincall;

BEGIN
-- Ingresamos el evento.
eventsgenerated := eventsgenerated+1;

INSERT INTO opensaga.events_generated_by_calls (idaccount, code, zu, priority, description, ideventtype, idincall, datetimeevent) VALUES (IdAccountInternal, 'A-CALL', Internalidcontact, InternalAlarmPriority, 'ALARMA! ' || Internallastname || ' ' || Internalfirstname || ' [' || Internalphone::text || ']', 72, VROWDATA.idincall, VROWDATA.datecall); 
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
            eventsgenerated := eventsgenerated-1;
END;

        
ELSE
-- La llamada no pertenece a ningun abonado
UPDATE public.incomingcalls SET flag1 = 2 WHERE idincall = VROWDATA.idincall;
      
END IF;
        
    end loop;
    CLOSE vcursor;

-- Procesamos los eventos generados
PERFORM opensaga.fun_auto_process_events();

RETURN;
END;$$;


--
-- TOC entry 2600 (class 0 OID 0)
-- Dependencies: 270
-- Name: FUNCTION fun_receiver_from_incomingcalls(OUT calls integer, OUT eventsgenerated integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_receiver_from_incomingcalls(OUT calls integer, OUT eventsgenerated integer) IS 'Funcion procesa las llamadas recibidas en la tabla inomngcalls, genera el evento.
process:
0 No procesdo
1 Procesado, evento de una cuenta
2 Procesado, numero no registrado en alguna cuenta.
3 Procesado, numero no tiene propietario
';


--
-- TOC entry 277 (class 1255 OID 26415)
-- Dependencies: 787 7
-- Name: fun_receiver_from_incomingsmss(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_receiver_from_incomingsmss(OUT outsmss integer, OUT outeventsgenerated integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN


RETURN;
END;$$;


--
-- TOC entry 285 (class 1255 OID 26920)
-- Dependencies: 7 787
-- Name: fun_view_account_contact_notif_eventtypes(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$DECLARE

CursorEventtypes refcursor; 

ROWDATAEventType   opensaga.eventtypes%ROWTYPE;
ROWDATANET   opensaga.account_notifications_eventtype%ROWTYPE;

InternalIdNotifAccount INTEGER DEFAULT 0;


BEGIN

SELECT opensaga.account_notifications.idnotifaccount INTO InternalIdNotifAccount FROM opensaga.account_notifications WHERE idphone = inidphone AND idaccount = inidaccount LIMIT 1;

IF InternalIdNotifAccount > 0 THEN

OPEN CursorEventtypes FOR SELECT * FROM opensaga.eventtypes ORDER BY label;
    loop    

        FETCH CursorEventtypes INTO ROWDATAEventType;
        EXIT WHEN NOT FOUND;

IF EXISTS(SELECT opensaga.account_notifications_eventtype.idnotifphoneeventtype FROM opensaga.account_notifications_eventtype WHERE opensaga.account_notifications_eventtype.idnotifaccount = InternalIdNotifAccount AND opensaga.account_notifications_eventtype.ideventtype = ROWDATAEventType.ideventtype LIMIT 1) THEN
SELECT * INTO ROWDATANET FROM opensaga.account_notifications_eventtype WHERE opensaga.account_notifications_eventtype.idnotifaccount = InternalIdNotifAccount AND opensaga.account_notifications_eventtype.ideventtype = ROWDATAEventType.ideventtype LIMIT 1;
IF fieldtextasbase64 THEN
RETURN QUERY SELECT InternalIdNotifAccount::integer, ROWDATAEventType.ideventtype::integer, 'true'::boolean, encode(ROWDATAEventType.label::bytea, 'base64'), ROWDATANET.ts::timestamp without time zone;
ELSE
RETURN QUERY SELECT InternalIdNotifAccount::integer, ROWDATAEventType.ideventtype::integer, 'true'::boolean, ROWDATAEventType.label::text, ROWDATANET.ts::timestamp without time zone;
END IF;

ELSE

IF fieldtextasbase64 THEN
RETURN QUERY SELECT InternalIdNotifAccount::integer, ROWDATAEventType.ideventtype::integer, 'false'::boolean, encode(ROWDATAEventType.label::bytea, 'base64'), '1900-01-01 00:00'::timestamp without time zone;
ELSE
RETURN QUERY SELECT InternalIdNotifAccount::integer, ROWDATAEventType.ideventtype::integer, 'false'::boolean, ROWDATAEventType.label::text, '1900-01-01 00:00'::timestamp without time zone;
END IF;



END IF;

    end loop;
    CLOSE CursorEventtypes;

END IF;

END
$$;


--
-- TOC entry 2601 (class 0 OID 0)
-- Dependencies: 285
-- Name: FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) IS 'Vista de los tipos de eventos habilitados para un determinado idaccountnotif';


--
-- TOC entry 260 (class 1255 OID 26939)
-- Dependencies: 7 787
-- Name: fun_view_account_contact_notif_eventtypes_xml(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_account_contact_notif_eventtypes_xml(inidaccount integer, inidphone integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM opensaga.fun_view_account_contact_notif_eventtypes(inidaccount, inidphone, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 299 (class 1255 OID 26994)
-- Dependencies: 7 787
-- Name: fun_view_account_contacts_xml(integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_account_contacts_xml(inidaccount integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idaccount, idcontact, enable, encode(firstname::bytea, 'base64') AS firstname, encode(lastname::bytea, 'base64') AS lastname, prioritycontact, enable_as_contact, encode(appointment::bytea, 'base64') as appointment, ts FROM opensaga.view_account_contacts WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM opensaga.view_account_contacts WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 252 (class 1255 OID 26915)
-- Dependencies: 787 7
-- Name: fun_view_account_notif_phones(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_account_notif_phones(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean, OUT idnotifcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT priority integer, OUT call boolean, OUT sms boolean, OUT smstext text, OUT note text, OUT ts timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

--CursorViewContactsPhonesAddress CURSOR FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
CursorViewContactsPhonesAddress refcursor; 

ROWDATAViewContact   public.view_contacts_phones%ROWTYPE;
ROWDATAAccNotif   opensaga.account_notifications%ROWTYPE;

BEGIN

IF EXISTS(SELECT phones.idphone FROM phones WHERE phones.idcontact = inidcontact) THEN

OPEN CursorViewContactsPhonesAddress FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
    loop    

        FETCH CursorViewContactsPhonesAddress INTO ROWDATAViewContact;
        EXIT WHEN NOT FOUND;
--fieldtextasbase64
IF EXISTS(SELECT opensaga.account_notifications.idnotifaccount FROM opensaga.account_notifications WHERE opensaga.account_notifications.idaccount = inidaccount AND opensaga.account_notifications.idphone = ROWDATAViewContact.idphone LIMIT 1) THEN
SELECT * INTO ROWDATAAccNotif FROM opensaga.account_notifications WHERE opensaga.account_notifications.idaccount = inidaccount AND opensaga.account_notifications.idphone = ROWDATAViewContact.idphone LIMIT 1;

IF fieldtextasbase64 THEN
RETURN QUERY SELECT ROWDATAAccNotif.idnotifaccount::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, encode(ROWDATAViewContact.phone::bytea, 'base64'), encode(ROWDATAViewContact.address::bytea, 'base64'), ROWDATAAccNotif.priority::integer, ROWDATAAccNotif.call::boolean, ROWDATAAccNotif.sms::boolean, encode(ROWDATAAccNotif.smstext::bytea, 'base64'), encode(ROWDATAAccNotif.note::bytea, 'base64'), ROWDATAAccNotif.ts::timestamp without time zone;
ELSE
RETURN QUERY SELECT ROWDATAAccNotif.idnotifaccount::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAViewContact.address::text, ROWDATAAccNotif.priority::integer, ROWDATAAccNotif.call::boolean, ROWDATAAccNotif.sms::boolean, ROWDATAAccNotif.smstext::text, ROWDATAAccNotif.note::text, ROWDATAAccNotif.ts::timestamp without time zone;
END IF;

ELSE

IF fieldtextasbase64 THEN
RETURN QUERY SELECT '0'::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, encode(ROWDATAViewContact.phone::bytea, 'base64'), encode(ROWDATAViewContact.address::bytea, 'base64'), '0'::integer, 'false'::boolean, 'false'::boolean, ''::text, ''::text, '1990-01-01 00:00'::timestamp without time zone;
ELSE
RETURN QUERY SELECT '0'::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAViewContact.address::text, '0'::integer, 'false'::boolean, 'false'::boolean, ''::text, ''::text, '1990-01-01 00:00'::timestamp without time zone;
END IF;



END IF;

    end loop;
    CLOSE CursorViewContactsPhonesAddress;

END IF;

END
$$;


--
-- TOC entry 261 (class 1255 OID 26938)
-- Dependencies: 7 787
-- Name: fun_view_account_notif_phones_xml(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_account_notif_phones_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM opensaga.fun_view_account_notif_phones(inidaccount, inidcontact, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 300 (class 1255 OID 26986)
-- Dependencies: 787 7
-- Name: fun_view_last_events_xml(integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idevent, dateload, CASE WHEN idaccount IS NULL THEN '0' ELSE idaccount END AS idaccount, CASE WHEN partition IS NULL THEN '0' ELSE partition END AS partition, CASE WHEN enable IS NULL THEN 'false' ELSE enable END AS enable, CASE WHEN account IS NULL THEN encode('System'::bytea, 'base64') ELSE account END AS account, CASE WHEN name IS NULL THEN encode('openSAGA'::bytea, 'base64') ELSE name END AS name, CASE WHEN type IS NULL THEN '0' ELSE type END AS type, encode(code::bytea, 'base64') as code, zu, priority, encode(description::bytea, 'base64') as description, ideventtype, datetimeevent, encode(eventtype::bytea, 'base64') AS eventtype, process1, process2, process3, process4, process5, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5 FROM opensaga.view_events ORDER BY idevent DESC LIMIT rows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idevent, dateload, CASE WHEN idaccount IS NULL THEN '0' ELSE idaccount END AS idaccount, CASE WHEN partition IS NULL THEN '0' ELSE partition END AS partition, CASE WHEN enable IS NULL THEN 'false' ELSE enable END AS enable, CASE WHEN account IS NULL THEN 'System' ELSE account END AS account, CASE WHEN name IS NULL THEN 'openSAGA' ELSE name END AS name, CASE WHEN type IS NULL THEN '0' ELSE type END AS type, code, zu, priority, description, ideventtype, eventtype, datetimeevent, process1, process2, process3, process4, process5, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5 FROM opensaga.view_events ORDER BY idevent DESC LIMIT rows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 2602 (class 0 OID 0)
-- Dependencies: 300
-- Name: FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) IS 'Muestra los ultimos eventos registrados en formato xml';


--
-- TOC entry 298 (class 1255 OID 26984)
-- Dependencies: 7 787
-- Name: fun_view_notification_templates_xml(boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_view_notification_templates_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idnotiftempl, encode(description::bytea, 'base64') AS description, encode(message::bytea, 'base64') AS message, ts FROM opensaga.notification_templates;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM opensaga.notification_templates;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 269 (class 1255 OID 26417)
-- Dependencies: 7 787
-- Name: hearbeat(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION hearbeat() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$BEGIN

INSERT INTO opensaga.events (code, priority, description, ideventtype) VALUES ('SYS', 100, 'Hear Beat Receiver', 83);

RETURN now();
END;$$;


--
-- TOC entry 2603 (class 0 OID 0)
-- Dependencies: 269
-- Name: FUNCTION hearbeat(); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION hearbeat() IS 'Genera un evento de funcionmiento de la receptora';


SET search_path = public, pg_catalog;

--
-- TOC entry 279 (class 1255 OID 26815)
-- Dependencies: 787 5
-- Name: ctrl_ts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ctrl_ts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.ts = now(); 
   RETURN NEW;
END;
$$;


--
-- TOC entry 290 (class 1255 OID 26962)
-- Dependencies: 5 787
-- Name: fun_contact_search_by_name(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_contact_search_by_name(infirstname text, inlastname text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT -1;

BEGIN

SELECT idcontact INTO Retorno FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) LIMIT 1;

IF Retorno<1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2604 (class 0 OID 0)
-- Dependencies: 290
-- Name: FUNCTION fun_contact_search_by_name(infirstname text, inlastname text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_contact_search_by_name(infirstname text, inlastname text) IS 'Obtiene el idcontact segun el firstname y lastname pasado como parametro.
Si no lo encuentra devuelve 0.';


--
-- TOC entry 242 (class 1255 OID 26967)
-- Dependencies: 5 787
-- Name: fun_contacts_table(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_contacts_table(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

internalIdContact INTEGER DEFAULT 0;

BEGIN

-- Obtenemos el idcontact segun el nombre ingresado
internalIdContact := fun_contact_search_by_name(infirstname, inlastname);

CASE
-- Actualizamos cuando inidcontact es mayor que 0 y ademas ese id existe
	WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN

IF internalIdContact = inidcontact OR internalIdContact < 1 THEN
UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';
ELSE
outreturn := inidcontact;
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';
END IF;

-- Insertamos un nuevo registro
	WHEN inidcontact = 0 THEN
IF internalIdContact < 1 THEN
INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note, idaddress) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote, inidaddress) RETURNING idcontact INTO outreturn;
outpgmsg := 'idcontact '||outreturn::text||' creado.';
ELSE
outreturn := -1;
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';
END IF;

	WHEN inidcontact < 0 THEN

DELETE FROM contacts WHERE idcontact = abs(inidcontact);
outreturn := abs(inidcontact);
outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

	END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


--
-- TOC entry 291 (class 1255 OID 26966)
-- Dependencies: 787 5
-- Name: fun_contacts_table_xml(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_contacts_table_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress text, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN
--fun_contacts_table_xml(IN inidcontact integer, IN inenable boolean, IN intitle text, IN infirstname text, IN inlastname text, IN ingender integer, IN inbirthday date, IN intypeofid integer, IN inidentification text, IN inweb text, IN inemail1 text, IN inemail2 text, IN inidaddress text, IN note text)

OPEN CursorResultado FOR SELECT * FROM fun_contacts_table(inidcontact, inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, inidaddress, innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 250 (class 1255 OID 16818)
-- Dependencies: 787 5
-- Name: fun_correntportproviders_get_idprovider(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_correntportproviders_get_idprovider(inidport integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;

BEGIN

SELECT idprovider INTO Retorno FROM currentportsproviders WHERE idport = inidport;

IF Retorno < 1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2605 (class 0 OID 0)
-- Dependencies: 250
-- Name: FUNCTION fun_correntportproviders_get_idprovider(inidport integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_correntportproviders_get_idprovider(inidport integer) IS 'Obtiene el idprovider desde la tabla currentportsproviders segun el idport pasado como parametro.';


--
-- TOC entry 262 (class 1255 OID 16714)
-- Dependencies: 787 5
-- Name: fun_currentportsproviders_insertupdate(integer, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
internalidprovider integer DEFAULT 0;
Retorno integer DEFAULT 0;
internalidmodem integer DEFAULT 0;

BEGIN

-- Usando el incimi tratamos de obtener el idprovider de la tabla provider
SELECT idprovider INTO internalidprovider FROM provider WHERE cimi = incimi;

-- Usando el inimei tratamos de obtener el idmodem de la tabla modem
SELECT idmodem INTO internalidmodem FROM modem WHERE imei = inimei;

IF internalidmodem IS NULL OR internalidmodem < 1 THEN
internalidmodem := 0;
END IF;

IF internalidprovider IS NULL THEN
-- El cimi no existe, lo creamos en la tabla providers
INSERT INTO provider (enable, cimi, name, note) VALUES (false, incimi, 'Undefined', 'No exitia previamente este cimi asi que fue creado automaticamente por usmsd') RETURNING idprovider INTO internalidprovider;
END IF;

IF EXISTS(SELECT idprovider FROM currentportsproviders WHERE idport = inidport) THEN
UPDATE currentportsproviders SET idmodem = internalidmodem, port = inport, cimi = incimi, imei = inimei, idprovider = internalidprovider, lastupdate = now() WHERE idport = inidport RETURNING idport INTO Retorno;
ELSE
-- No existe el registro, creamos uno nuevo
INSERT INTO currentportsproviders (idport, port, cimi, imei, idprovider, lastupdate, idmodem) VALUES (inidport, inport, incimi, inimei, internalidprovider, now(), internalidmodem) RETURNING idport INTO Retorno;
END IF;


-- Eliminamos todos los registros que tienen el campo lastupdate con mas de 2 minutos en relacion a la fecha actual
 DELETE FROM currentportsproviders WHERE (now()- lastupdate) > '0:02:00';
RETURN Retorno;
END;$$;


--
-- TOC entry 2606 (class 0 OID 0)
-- Dependencies: 262
-- Name: FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text) IS 'Funcion que inserta o actualiza los datos de la tabla currentportsproviders con datos enviados desde el puerto serial.';


--
-- TOC entry 264 (class 1255 OID 25899)
-- Dependencies: 787 5
-- Name: fun_idphone_from_phone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_idphone_from_phone(inphone text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno INTEGER DEFAULT 0;

BEGIN

IF char_length(inphone) > 0 THEN
-- Obtenemos el phone 
SELECT idphone INTO Retorno FROM phones WHERE phone = inphone;
IF Retorno IS NULL THEN
Retorno := 0;
END IF;
END IF;


RETURN Retorno;
END;$$;


--
-- TOC entry 2607 (class 0 OID 0)
-- Dependencies: 264
-- Name: FUNCTION fun_idphone_from_phone(inphone text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_idphone_from_phone(inphone text) IS 'Obtenemos el idphone segun el phone pasado como parametro';


--
-- TOC entry 243 (class 1255 OID 16846)
-- Dependencies: 5 787
-- Name: fun_incomingcalls_insert(timestamp without time zone, integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;
inidphone INTEGER DEFAULT 0;
-- TODO: Hay que agregar el campo idmodem
BEGIN
-- Buscamos si ya existe una llamada desde ese mismo numero anteriormente para ignorarlo.
-- La idea es registrar una llamada y no registrar cada ring
SELECT idincall INTO Retorno FROM incomingcalls WHERE ('now()' - datecall) < '00:00:20' AND phone = inphone;

IF Retorno < 1 OR Retorno IS NULL THEN

---SELECT fun_idphone_from_phone('1234'); 
inidphone := fun_idphone_from_phone(inphone);
INSERT INTO incomingcalls (datecall, idport, idphone, callaction, phone, note) VALUES (indatecall, inidport, inidphone, incalaction, inphone, innote) RETURNING idincall INTO Retorno;

IF Retorno < 1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2608 (class 0 OID 0)
-- Dependencies: 243
-- Name: FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text) IS 'Registra las llamadas entrantes provenientes de los modems';


--
-- TOC entry 251 (class 1255 OID 16847)
-- Dependencies: 787 5
-- Name: fun_incomingcalls_insert_online(integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN 
RETURN fun_incomingcalls_insert('now()', inidport, incallaction, inphone, innote); 
END;$$;


--
-- TOC entry 2609 (class 0 OID 0)
-- Dependencies: 251
-- Name: FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) IS 'Funcion para insertar la fecha en modo online, registra la llamada con la fecha actual.';


--
-- TOC entry 254 (class 1255 OID 17669)
-- Dependencies: 5 787
-- Name: fun_modem_insert(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;
BEGIN

-- Verificamos que no exista ese imei
IF NOT EXISTS(SELECT idmodem FROM modem WHERE imei = inimei) THEN
INSERT INTO modem (imei, manufacturer, model, revision, note) VALUES (inimei, inmanufacturer, inmodel, inrevision, innote) RETURNING idmodem INTO Retorno;
END IF;


RETURN Retorno;
END;$$;


--
-- TOC entry 2610 (class 0 OID 0)
-- Dependencies: 254
-- Name: FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text) IS 'Inserta los datos de un modem';


--
-- TOC entry 263 (class 1255 OID 25896)
-- Dependencies: 787 5
-- Name: fun_phone_from_idphone(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_phone_from_idphone(inidphone integer) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';

BEGIN

IF inidphone>0 THEN
-- Obtenemos el phone 
SELECT phone INTO Retorno FROM phones WHERE idphone = inidphone;
IF Retorno IS NULL THEN
Retorno := '';
END IF;
END IF;


RETURN Retorno;
END;$$;


--
-- TOC entry 2611 (class 0 OID 0)
-- Dependencies: 263
-- Name: FUNCTION fun_phone_from_idphone(inidphone integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_phone_from_idphone(inidphone integer) IS 'Obtiene el numero telefonico desde la tabla phones segun el idphone';


--
-- TOC entry 265 (class 1255 OID 25900)
-- Dependencies: 5 787
-- Name: fun_phone_idphone_check(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_phone_idphone_check(inidphone integer, inphone text, OUT outidphone integer, OUT outphone text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE
retorno INTEGER DEFAULT -1; 

BEGIN

-- Verificamos que los datos sea validos 
IF char_length(inphone) > 0 OR  inidphone > 0 THEN

IF inidphone>0 THEN
-- Si se pasa el idphone como parametro se obtiene el phone desde la tabla phones segun ese id
outidphone := inidphone;
outphone := fun_phone_from_idphone(outidphone);

ELSE
-- Si inidphone <= 0 tratamos de obtenerlo usando el inphone
outphone := inphone;
outidphone := fun_idphone_from_phone(outphone);
END IF;

ELSE
-- Valores vacios
outphone := 0;
outidphone := '';

END IF;

RETURN;
END;$$;


--
-- TOC entry 294 (class 1255 OID 26980)
-- Dependencies: 5 787
-- Name: fun_phone_search_by_number(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_phone_search_by_number(inphone text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT -1;

BEGIN

SELECT idphone INTO Retorno FROM phones WHERE upper(trim(phone)) = upper(trim(inphone)) LIMIT 1;

IF Retorno<1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


--
-- TOC entry 2612 (class 0 OID 0)
-- Dependencies: 294
-- Name: FUNCTION fun_phone_search_by_number(inphone text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_phone_search_by_number(inphone text) IS 'Busca el id segun el numero telefonico';


--
-- TOC entry 295 (class 1255 OID 26979)
-- Dependencies: 5 787
-- Name: fun_phones_table(integer, integer, boolean, text, integer, integer, real, real, text, text, text, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_phones_table(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, ingeox real, ingeoy real, inphone_ext text, inidaddress text, inaddress text, inubiphone integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

InternalIdPhone INTEGER DEFAULT 0;

BEGIN

IF length(inphone) > 0 THEN

IF EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact)  THEN
--
InternalIdPhone := fun_phone_search_by_number(inphone);

CASE

	WHEN inidphone = 0 THEN
	
	IF InternalIdPhone < 1 THEN
	INSERT INTO phones (idcontact, enable, phone, typephone, idprovider, note, geox, geoy, idaddress, phone_ext, ubiphone, address) VALUES (inidcontact, inenable, inphone, intypephone, inidprovider, innote, ingeox, ingeoy, inidaddress, inphone_ext, inubiphone, inaddress) RETURNING idphone INTO outreturn;
	outpgmsg := 'Nuevo telefono ingresado';
	ELSE
	outpgmsg := 'El numero telefonico ingresado ya existe, debe ingresar uno diferente';
	outreturn := -1;
	END IF;

	WHEN inidphone > 0 AND EXISTS(SELECT * FROM phones WHERE idphone = inidphone) THEN
	
	IF InternalIdPhone < 1 OR InternalIdPhone = inidphone THEN
	UPDATE phones SET idcontact = inidcontact, enable = inenable, phone = inphone, typephone = intypephone, idprovider = inidprovider, note = innote, geox = ingeox, geoy = ingeoy, idaddress = inidaddress, phone_ext = inphone_ext, ubiphone = inubiphone, address = inaddress WHERE idphone = inidphone RETURNING  idphone INTO outreturn;
	outpgmsg := 'Telefono actualizado';
	ELSE
	outpgmsg := 'El numero telefonico ingresado ya existe, debe ingresar uno diferente';
	outreturn := -2;
	END IF;

	WHEN inidphone < 0 THEN
	DELETE FROM phones WHERE idphone = abs(inidphone);
	outpgmsg := 'Telefono eliminado';
	outreturn := 0;
END CASE;

ELSE
outreturn := -1;
outpgmsg := 'El contacto no existe';
END IF;

ELSE
outreturn := -1;
outpgmsg := 'El numero no puede estar vacio';
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


--
-- TOC entry 245 (class 1255 OID 26978)
-- Dependencies: 787 5
-- Name: fun_phones_table_xml(integer, integer, boolean, text, integer, integer, real, real, text, text, text, integer, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_phones_table_xml(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, ingeox real, ingeoy real, inphone_ext text, inidaddress text, inaddress text, inubiphone integer, innote text, ts timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN

OPEN CursorResultado FOR SELECT * FROM fun_phones_table(inidphone, inidcontact, inenable, inphone, intypephone, inidprovider, ingeox, ingeoy, inphone_ext, inidaddress, inaddress, inubiphone, innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 259 (class 1255 OID 17670)
-- Dependencies: 787 5
-- Name: fun_portmodem_update(integer, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
internalidprovider integer DEFAULT 0;
Retorno integer DEFAULT 0;

BEGIN
-- Inserta los datos del modem si no existe
PERFORM fun_modem_insert(inimei, inmanufacturer, inmodel, inrevision, '');
-- Mantiene actualizada la tabla currentportsproviders 
PERFORM fun_currentportsproviders_insertupdate(inidport, inport, incimi, inimei); 
RETURN TRUE;
END;$$;


--
-- TOC entry 2613 (class 0 OID 0)
-- Dependencies: 259
-- Name: FUNCTION fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text) IS 'Actualiza los registros del puerto y del modem que esta usando la base de datos.';


--
-- TOC entry 253 (class 1255 OID 27023)
-- Dependencies: 5 787
-- Name: fun_provider_edit(integer, boolean, text, text, text, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_provider_edit(inidprovider integer, inenable boolean, incimi text, inname text, innote text, ints timestamp without time zone, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$BEGIN

CASE

WHEN inidnotiftempl > 0 AND EXISTS(SELECT * FROM opensaga.notification_templates WHERE idnotiftempl = inidnotiftempl) THEN
-- Actualizamos opensaga.notification_templates
UPDATE opensaga.notification_templates SET description = indescription, message = inmessage WHERE idnotiftempl = inidnotiftempl RETURNING idnotiftempl INTO outreturn;
outpgmsg := 'Registro id '||outreturn::text||' fue actualizado';

WHEN inidnotiftempl < 0 THEN
-- Eliminamos el registro
DELETE FROM opensaga.notification_templates WHERE idnotiftempl = abs(inidnotiftempl);
outpgmsg := 'Registro id '||abs(inidnotiftempl)::text||' fue eliminado';

WHEN inidnotiftempl = 0 THEN
-- Insertamos un nuevo registro
INSERT INTO opensaga.notification_templates (description, message) VALUES (indescription, inmessage) RETURNING idnotiftempl INTO outreturn;
outpgmsg := 'Registro id '||outreturn::text||' fue creado';
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;
RETURN;
END;$$;


--
-- TOC entry 297 (class 1255 OID 26982)
-- Dependencies: 787 5
-- Name: fun_providers_idname_xml(boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN
IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idprovider, enable, encode(name::bytea, 'base64') AS name FROM provider;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idcontact, enable, name FROM provider;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 2614 (class 0 OID 0)
-- Dependencies: 297
-- Name: FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean) IS 'Devuelve la lista de proveedores unicamente los campos id y name';


--
-- TOC entry 249 (class 1255 OID 16828)
-- Dependencies: 5 787
-- Name: fun_smsin_insert(integer, integer, timestamp without time zone, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno INTEGER DEFAULT 0;
inidprovider INTEGER DEFAULT 0;
inidphone INTEGER DEFAULT 0;

BEGIN

-- Buscamos el idprovider segun el inidport ingresado
inidprovider := fun_correntportproviders_get_idprovider(inidport);
-- Buscamos el idphone segun el numero telefonico ingresado
inidphone := fun_idphone_from_phone(inphone);

INSERT INTO smsin (idport, idprovider, idphone, datesms, status, phone, message) VALUES (inidport, inidprovider, inidphone, indatesms, instatus, inphone, inmsj) RETURNING idsmsin INTO Retorno;

IF Retorno < 1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;

END;$$;


--
-- TOC entry 2615 (class 0 OID 0)
-- Dependencies: 249
-- Name: FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text) IS 'Funcion para almacenar sms entrantes en la tabla smsin';


--
-- TOC entry 266 (class 1255 OID 16800)
-- Dependencies: 787 5
-- Name: fun_smsout_insert(integer, integer, integer, integer, text, timestamp without time zone, text, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsout_insert(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, indatetosend timestamp without time zone, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
retorno INTEGER DEFAULT 0; 
internalPhone TEXT DEFAULT '';
internalidPhone INTEGER DEFAULT 0;

BEGIN

SELECT outidphone, outphone INTO internalidPhone, internalPhone FROM fun_phone_idphone_check(inidphone, inphone);

IF char_length(internalPhone) < 1 AND internalidPhone < 1 THEN
-- No hay valores validos, no es posible insertar
retorno := -1;

ELSE

-- Tratamos de obtener el idprovider si no se lo ha proveido
IF inidprovider < 1 THEN
SELECT idprovider INTO inidprovider FROM phones WHERE idphone = internalidPhone;
-- Pone el idprovider a 0, lo que hace que el sistema intente con cada proveedor hasta lograr enviar el sms.
IF inidprovider IS NULL THEN inidprovider := 0;  END IF;
END IF;

INSERT INTO smsout (idprovider, idsmstype, priority, idphone, phone, datetosend, message, note) VALUES (inidprovider, inidsmstype, inpriority, internalidPhone, internalPhone, indatetosend, inmessage, innote) RETURNING idsmsout INTO retorno;

-- Verificamos que el numero no exista en la lista negra, si existe seteamos process como destino no permitodo
IF EXISTS(SELECT idbl FROM blacklist WHERE idprovider = inidprovider AND idphone = internalidPhone) THEN
UPDATE smsout SET dateprocess = now(), process = 4 WHERE idsmsout = retorno;
END IF;

-- TODO 
-- Si es necesario implementar uso de lista blanca

END IF;


RETURN retorno;
END;$$;


--
-- TOC entry 2616 (class 0 OID 0)
-- Dependencies: 266
-- Name: FUNCTION fun_smsout_insert(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, indatetosend timestamp without time zone, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsout_insert(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, indatetosend timestamp without time zone, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) IS 'Ingresa un sms en la tabla smsout haciendo chequeos previos.
Devuelve:
-1 Si no se ha ingresado inphone e idphone <1';


--
-- TOC entry 258 (class 1255 OID 17668)
-- Dependencies: 787 5
-- Name: fun_smsout_insert_sendnow(integer, integer, integer, integer, text, text, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
retorno INTEGER DEFAULT -1; 

BEGIN
retorno := fun_smsout_insert(inidprovider, inidsmstype, inidphone, inpriority, inphone, 'now()', inmessage, inenablemsgclass, inmsgclass, innote);
RETURN retorno;
END;$$;


--
-- TOC entry 2617 (class 0 OID 0)
-- Dependencies: 258
-- Name: FUNCTION fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) IS 'Ingresa un sms en la tabla smsout haciendo chequeos previos.';


--
-- TOC entry 255 (class 1255 OID 17665)
-- Dependencies: 5 787
-- Name: fun_smsout_preparenewsmsautoprovider(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsout_preparenewsmsautoprovider() RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE

CursorNewSMSAutoprovider CURSOR FOR SELECT * FROM public.smsout WHERE datetosend<=now() AND idprovider = 0 AND process = 0;
SMSOUTROWDATA   public.smsout%ROWTYPE;
FirstCurrentIdPort INTEGER DEFAULT 0; 

BEGIN

SELECT idport INTO FirstCurrentIdPort FROM  currentportsproviders ORDER BY idport LIMIT 1;

-- Obtenemos todos los smsout que tienen autoproveedor y debes ser ya enviados, los marcamos como autoprovider y con el primer puerto registrado actualmente
    OPEN CursorNewSMSAutoprovider;
    loop    

        FETCH CursorNewSMSAutoprovider INTO SMSOUTROWDATA;
        EXIT WHEN NOT FOUND;
UPDATE smsout SET process = 5, idport = FirstCurrentIdPort, dateprocess = now()  WHERE idsmsout = SMSOUTROWDATA.idsmsout;
    end loop;
    CLOSE CursorNewSMSAutoprovider;

RETURN TRUE;
END;$$;


--
-- TOC entry 2618 (class 0 OID 0)
-- Dependencies: 255
-- Name: FUNCTION fun_smsout_preparenewsmsautoprovider(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsout_preparenewsmsautoprovider() IS 'Prepara para enviar los smsout nuevos que han sido marcados como autoproveedor';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 173 (class 1259 OID 16579)
-- Dependencies: 2210 2211 2212 2213 2214 2215 2216 2217 2218 2219 2220 2221 2222 2223 2224 2225 2226 2227 2228 2229 2230 2231 2232 2233 2234 2235 2236 2237 5 1720 1720
-- Name: smsout; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE smsout (
    idsmsout bigint NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    idprovider integer DEFAULT 0 NOT NULL,
    idsmstype integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    datetosend timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess timestamp without time zone DEFAULT now() NOT NULL,
    process integer DEFAULT 0 NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL,
    priority integer DEFAULT 5,
    attempts integer DEFAULT 0,
    idprovidersent integer DEFAULT 0,
    slices integer DEFAULT 0,
    slicessent integer DEFAULT 0,
    messageclass integer DEFAULT 1 NOT NULL,
    report boolean DEFAULT false,
    maxslices integer DEFAULT 1 NOT NULL,
    enablemessageclass boolean DEFAULT false NOT NULL,
    idport integer DEFAULT 0 NOT NULL,
    flag1 integer DEFAULT 0 NOT NULL,
    flag2 integer DEFAULT 0 NOT NULL,
    flag3 integer DEFAULT 0 NOT NULL,
    flag4 integer DEFAULT 0 NOT NULL,
    flag5 integer DEFAULT 0 NOT NULL,
    retryonfail integer DEFAULT 0 NOT NULL,
    maxtimelive integer DEFAULT 2 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    message text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL
);


--
-- TOC entry 2619 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE smsout; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE smsout IS 'Tabla de mensajes salientes';


--
-- TOC entry 2620 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.idsmstype; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsout.idsmstype IS 'Estado del envio del sms';


--
-- TOC entry 2621 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.idphone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsout.idphone IS 'Se es identificado el numero con un idphone se escribe este campo';


--
-- TOC entry 2622 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsout.phone IS 'Numero telefonico';


--
-- TOC entry 2623 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.datetosend; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsout.datetosend IS 'Fecha programada de envio';


--
-- TOC entry 2624 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsout.priority IS 'Prioridad de envio del sms. 5 es el valor de fabrica. 0 es la maxima prioridad.';


--
-- TOC entry 267 (class 1255 OID 16715)
-- Dependencies: 787 5 649
-- Name: fun_smsout_to_send(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsout_to_send(inidport integer DEFAULT 0) RETURNS smsout
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno smsout%ROWTYPE;
idlockedsmsout INTEGER DEFAULT 0;
inidprovider INTEGER DEFAULT 0;
internalPhone TEXT DEFAULT '';
internalidPhone INTEGER DEFAULT 0;

SMSOutOpciones smsoutoptions%ROWTYPE;

BEGIN

-- Marcamos como expirados los sms que han sobrepasado su tiempo de vida
PERFORM fun_smsout_update_expired();

-- Preparamos los smsout marcados como autoproveedor
PERFORM fun_smsout_preparenewsmsautoprovider();

-- Selecionamos los datos desde smsoutoptions
SELECT * INTO SMSOutOpciones FROM fun_smsoutoptions_current();

--LISTEN mymessage;
--PERFORM pg_notify('mymessage', inidport::text);

-- Seleccionamos el inidprovider para el inidport pasado como parametro, si existe devolvera un valor > 0
SELECT idprovider INTO inidprovider FROM currentportsproviders WHERE idport = inidport;

-- SECCION selecciona un sms para enviar segun el Proveedor que corresponde a este puerto y setea los valores de smsoutoptions registradas en este momento
IF inidprovider > 0 THEN
UPDATE smsout SET maxtimelive = SMSOutOpciones.maxtimelive, retryonfail = SMSOutOpciones.retryonfail, report = SMSOutOpciones.report, dateprocess = now(), maxslices = SMSOutOpciones.maxslices, process=1, idport = inidport WHERE idsmsout = (SELECT idsmsout FROM smsout WHERE datetosend <= now() AND ((idprovider = inidprovider AND process IN(0, 10) ) OR (idprovider = 0 AND process = 5 AND idport = inidport) ) ORDER BY datetosend, priority LIMIT 1) RETURNING idsmsout INTO idlockedsmsout;

IF idlockedsmsout > 0 THEN
-- Verificamos idphone y phone
SELECT idphone, phone INTO internalidPhone, internalPhone FROM smsout WHERE idsmsout = idlockedsmsout;

SELECT outidphone, outphone INTO internalidPhone, internalPhone FROM fun_phone_idphone_check(internalidPhone, internalPhone);
-- TODO: chequear adicionalmente que solo haya numeros, + como caracteres
IF char_length(internalPhone) > 0 THEN
UPDATE smsout SET idphone=internalidPhone, phone = internalPhone WHERE idsmsout = idlockedsmsout RETURNING idsmsout INTO idlockedsmsout;

ELSE
-- El phone es invalido
UPDATE smsout SET idphone=internalidPhone, phone = internalPhone, process = 11 WHERE idsmsout = idlockedsmsout;
idlockedsmsout := 0;
END IF;

END IF;


END IF;


-- Obtenemos el ultimo registro para enviar con este proveedor
SELECT * INTO Retorno FROM smsout WHERE idsmsout = idlockedsmsout;

RETURN Retorno;
END;$$;


--
-- TOC entry 2625 (class 0 OID 0)
-- Dependencies: 267
-- Name: FUNCTION fun_smsout_to_send(inidport integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsout_to_send(inidport integer) IS 'Selecciona un sms de smsout para enviarlo.
-- process: 0 nada, 1 blockeado, 2 enviado, 3 falla, 4 destino no permitido, 5 autoprovider, 6 enviado incompleto, 7 expirado tiempo de vida, 8 falla todos los intentos por enviar por todos los puertos, 9 fallan todos los intentos de envio, 10 Espera por reintento de envio, 11 Phone no valido';


--
-- TOC entry 257 (class 1255 OID 17664)
-- Dependencies: 5 787
-- Name: fun_smsout_update_expired(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsout_update_expired() RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
-- Ponemos como expirados todos los sms que hayan sobrepasado el tiempo de vida
UPDATE smsout SET process = 7, dateprocess = now() WHERE process != 7 AND process IN(0, 1, 5, 10) AND (SELECT EXTRACT (MINUTE FROM (now() - dateprocess))) > maxtimelive;
RETURN TRUE;
END;$$;


--
-- TOC entry 2626 (class 0 OID 0)
-- Dependencies: 257
-- Name: FUNCTION fun_smsout_update_expired(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsout_update_expired() IS 'Pone como expirados los mensajes que han sobrepasado su tiempo de vida';


--
-- TOC entry 239 (class 1255 OID 16799)
-- Dependencies: 787 5
-- Name: fun_smsout_updatestatus(integer, integer, integer, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsout_updatestatus(inidsmsout integer, inprocess integer, inidport integer, inslices integer, inslicessent integer, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno integer DEFAULT -1;
--inidprovidernext integer DEFAULT 0;
inidprovider integer DEFAULT 0;
InternalAttempts INTEGER DEFAULT 0;
InternalIdPort INTEGER DEFAULT 0;

BEGIN

InternalIdPort := inidport;
-- Obtenemos el idprovider para el idport actual
inidprovider := fun_correntportproviders_get_idprovider(InternalIdPort);

IF EXISTS(SELECT idprovider FROM smsout WHERE idsmsout = inidsmsout AND idprovider = 0) THEN
-- SECCION SMS es con auto proveedor

IF inprocess = 3 THEN
-- El envio ha fallado 
-- Buscamos el siguiente proveedor habilitado desde la tabla currentportsproviders
SELECT idport INTO  InternalIdPort FROM currentportsproviders WHERE idport > (SELECT idport FROM smsout WHERE idsmsout = inidsmsout) ORDER BY idport;

IF InternalIdPort IS NULL OR InternalIdPort < 1 THEN
-- No hay mas puertos para intentar
InternalIdPort := inidport;
inprocess := 8;
inidprovider := 0;
InternalAttempts :=1;
ELSE
-- Se intentara con el siguiente puerto encontrado
inprocess := 5;
inidprovider := 0;
END IF;

END IF;

-- Actualizamos este sms que autoproveedor
-- UPDATE smsout SET slices = inslices, slicessent = inslicessent, dateprocess = now(), attempts = InternalAttempts, process = inprocess, idprovidersent = inidprovider, idport = inidport WHERE idsmsout = inidsmsout RETURNING idsmsout INTO Retorno;


ELSE
-- SECCION SMS no es con autoproveedor

InternalAttempts :=1;

IF inprocess = 3 THEN

-- Actualiza el mensaje verificando si ya exede el numero de intentos y si 
IF EXISTS(SELECT idprovider FROM smsout WHERE retryonfail > (attempts+1) AND idsmsout = inidsmsout) THEN
-- En espera para volver a intentar el envio
inprocess := 10;
ELSE
-- Se Exede ya el numero de intentos
inprocess := 9;
END IF;

END IF;

END IF;


UPDATE smsout SET slices = inslices, slicessent = inslicessent, dateprocess = now(), attempts = attempts+InternalAttempts, process = inprocess, idprovidersent = inidprovider, idport = inidport WHERE idsmsout = inidsmsout RETURNING idsmsout INTO Retorno;

RETURN Retorno;
END;$$;


--
-- TOC entry 2627 (class 0 OID 0)
-- Dependencies: 239
-- Name: FUNCTION fun_smsout_updatestatus(inidsmsout integer, inprocess integer, inidport integer, inslices integer, inslicessent integer, innote text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsout_updatestatus(inidsmsout integer, inprocess integer, inidport integer, inslices integer, inslicessent integer, innote text) IS 'Actualiza el estado de envio del sms.';


--
-- TOC entry 180 (class 1259 OID 16745)
-- Dependencies: 2250 2251 2252 2253 2254 5
-- Name: smsoutoptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE smsoutoptions (
    idsmsoutopt bigint NOT NULL,
    enable boolean,
    name text,
    report boolean DEFAULT false NOT NULL,
    retryonfail integer DEFAULT 0 NOT NULL,
    maxslices integer DEFAULT 1,
    maxtimelive integer DEFAULT 5 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2628 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE smsoutoptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE smsoutoptions IS 'Opciones globales adicionales para envio de mensajes de texto.';


--
-- TOC entry 2629 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.enable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsoutoptions.enable IS 'usms toma el ultimo registro habilitado para su funcionamiento ignorando los anteriores';


--
-- TOC entry 2630 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsoutoptions.name IS 'Nombre opcional';


--
-- TOC entry 2631 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.report; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsoutoptions.report IS 'Solicita reporte de recibido para cada sms';


--
-- TOC entry 2632 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.retryonfail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsoutoptions.retryonfail IS '0 = No intenta reenviar el sms en caso de falla.
> 0 Numero de reintentos en caso de falla.';


--
-- TOC entry 2633 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.maxslices; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN smsoutoptions.maxslices IS 'Numero maximo de sms que se enviara cuando el texto del mensaje es largo.
De fabrica envia un solo mensaje de 160 caracteres.
Si 0 o 1 de fabrica.';


--
-- TOC entry 256 (class 1255 OID 17663)
-- Dependencies: 5 664 787
-- Name: fun_smsoutoptions_current(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_smsoutoptions_current() RETURNS smsoutoptions
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno smsoutoptions%ROWTYPE;

BEGIN

-- Si no existe un registro habilitado, creamos uno con valores de fabrica
IF NOT EXISTS(SELECT idsmsoutopt FROM smsoutoptions WHERE enable=true) THEN
INSERT INTO smsoutoptions (name, enable) VALUES ('Automatic', true);
END IF;

-- Selecionamos el ultimo registro habilitado desde smsoutoptions
SELECT * INTO Retorno FROM smsoutoptions WHERE enable = true ORDER BY idsmsoutopt DESC LIMIT 1;

IF Retorno.retryonfail =0 OR Retorno.retryonfail IS NULL THEN
Retorno.retryonfail := 1;
UPDATE smsoutoptions SET retryonfail = Retorno.retryonfail WHERE idsmsoutopt = Retorno.idsmsoutopt;
END IF;

IF Retorno.report IS NULL THEN
Retorno.report := false;
UPDATE smsoutoptions SET report = Retorno.report WHERE idsmsoutopt = Retorno.idsmsoutopt;
END IF;

IF Retorno.maxslices=0 OR Retorno.maxslices IS NULL THEN
Retorno.maxslices := 1;
UPDATE smsoutoptions SET maxslices = Retorno.maxslices WHERE idsmsoutopt = Retorno.idsmsoutopt;
END IF;

IF Retorno.maxtimelive<5 OR Retorno.maxtimelive IS NULL THEN
Retorno.maxtimelive := 5; -- Maximo 5 minutos de vida despues de l ultima modificacion del proceso
UPDATE smsoutoptions SET maxtimelive = Retorno.maxtimelive WHERE idsmsoutopt = Retorno.idsmsoutopt;
END IF;


RETURN Retorno;

END;$$;


--
-- TOC entry 2634 (class 0 OID 0)
-- Dependencies: 256
-- Name: FUNCTION fun_smsoutoptions_current(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_smsoutoptions_current() IS 'Obtiene los valores de smsoutoptions actualmente usadas.';


--
-- TOC entry 293 (class 1255 OID 26959)
-- Dependencies: 5 787
-- Name: fun_view_contacts_byidcontact_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, enable, encode(title::bytea, 'base64') AS title, encode(firstname::bytea, 'base64') AS firstname, encode(lastname::bytea, 'base64') AS lastname, gender, birthday, typeofid, encode(identification::bytea, 'base64') AS identification, encode(web::bytea, 'base64') as web, encode(email1::bytea, 'base64') as email1, encode(email2::bytea, 'base64') as email2, encode(note::bytea, 'base64') AS note, idaddress, ts   FROM contacts WHERE idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM contacts  WHERE idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 2635 (class 0 OID 0)
-- Dependencies: 293
-- Name: FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean) IS 'Devuelve un contacto segun el parametro idcontact en formato xml.';


--
-- TOC entry 288 (class 1255 OID 26958)
-- Dependencies: 5 787
-- Name: fun_view_contacts_to_list_xml(boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, enable, encode((lastname ||' '||firstname)::bytea, 'base64') AS name FROM contacts;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idcontact, enable, (lastname ||' '||firstname) AS name FROM contacts;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 2636 (class 0 OID 0)
-- Dependencies: 288
-- Name: FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean) IS 'Lista de contactos con datos basicos, para ser usado en un combobox o lista simplificada.';


--
-- TOC entry 296 (class 1255 OID 26983)
-- Dependencies: 5 787
-- Name: fun_view_incomingcalls_xml(timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idincall, datecall, idport, idphone, callaction, encode(phone::bytea, 'base64') AS phone, flag1, flag2, flag3, flag4, flag5, idmodem, encode(note::bytea, 'base64') AS note, ts FROM incomingcalls WHERE datecall BETWEEN datestart AND dateend ORDER BY datecall DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM incomingcalls WHERE datecall BETWEEN datestart AND dateend ORDER BY datecall DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 2637 (class 0 OID 0)
-- Dependencies: 296
-- Name: FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) IS 'Obtiene la tabla entre las fechas seleccionadas en formato xml';


--
-- TOC entry 244 (class 1255 OID 26960)
-- Dependencies: 5 787
-- Name: fun_view_phones_byid_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_phones_byid_xml(inidphone integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idphone, idcontact, enable, encode(phone::bytea, 'base64') as phone, typephone, idprovider, encode(note::bytea, 'base64') as note, geox, geoy, idaddress, encode(phone_ext::bytea, 'base64') as phone_ext, ubiphone, encode(address::bytea, 'base64') as address, ts FROM phones WHERE idphone = inidphone;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM phones WHERE idphone = inidphone;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 292 (class 1255 OID 26976)
-- Dependencies: 787 5
-- Name: fun_view_phones_byidcontact_simplified_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_phones_byidcontact_simplified_xml(inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idphone, idcontact, enable, encode(phone::bytea, 'base64') as phone, idprovider FROM phones WHERE idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idphone, idcontact, enable, phone, idprovider FROM phones WHERE idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 302 (class 1255 OID 27021)
-- Dependencies: 5 787
-- Name: fun_view_provider_table_xml(boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_provider_table_xml(fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idprovider, enable, encode(cimi::bytea, 'base64') AS cimi, encode(name::bytea, 'base64') AS name, encode(note::bytea, 'base64') AS note, ts FROM provider;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM provider;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';
END;$$;


--
-- TOC entry 2638 (class 0 OID 0)
-- Dependencies: 302
-- Name: FUNCTION fun_view_provider_table_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fun_view_provider_table_xml(fieldtextasbase64 boolean) IS 'Devuelve la tabla en formato xml';


--
-- TOC entry 305 (class 1255 OID 27038)
-- Dependencies: 787 5
-- Name: fun_view_smsin_table_filter_xml(timestamp without time zone, timestamp without time zone, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_smsin_table_filter_xml(datestart timestamp without time zone, dateend timestamp without time zone, maxrows integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idsmsin, dateload, idprovider, idphone, encode(phone::bytea, 'base64') AS phone, datesms, encode(message::bytea, 'base64') AS message, idport, status, flag1, flag2, flag3, flag4, flag5, encode(note::bytea, 'base64') AS note, ts FROM smsin WHERE dateload BETWEEN datestart AND dateend ORDER BY dateload DESC LIMIT maxrows;
SELECT * FROM cursor_to_xml(CursorResult, maxrows+1, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM smsin WHERE dateload BETWEEN datestart AND dateend ORDER BY dateload DESC LIMIT maxrows;
SELECT * FROM cursor_to_xml(CursorResult, maxrows+1, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


--
-- TOC entry 281 (class 1255 OID 27026)
-- Dependencies: 787 5
-- Name: fun_view_smsout_table_filter_xml(timestamp without time zone, timestamp without time zone, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fun_view_smsout_table_filter_xml(datestart timestamp without time zone, dateend timestamp without time zone, maxrows integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idsmsout, dateload, idprovider, idsmstype, idphone, encode(phone::bytea, 'base64') AS phone, datetosend, encode(message::bytea, 'base64') AS message, dateprocess, process, priority, attempts, idprovidersent, slices, slicessent, messageclass, report, maxslices, enablemessageclass, idport, flag1, flag2, flag3, flag4, flag5, retryonfail, maxtimelive, encode(note::bytea, 'base64') AS note, ts FROM smsout WHERE datetosend BETWEEN datestart AND dateend ORDER BY datetosend DESC LIMIT maxrows;
SELECT * FROM cursor_to_xml(CursorResult, maxrows+1, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM smsout WHERE datetosend BETWEEN datestart AND dateend ORDER BY datetosend DESC LIMIT maxrows;
SELECT * FROM cursor_to_xml(CursorResult, maxrows+1, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 184 (class 1259 OID 16976)
-- Dependencies: 2268 2269 2270 2271 2272 2273 2274 2275 2276 7 1720
-- Name: account; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account (
    idaccount bigint NOT NULL,
    partition integer DEFAULT 0 NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    account text DEFAULT '0000'::text NOT NULL,
    name text DEFAULT 'Undefined'::text NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    idgroup integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 2639 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE account; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account IS 'Cuenta de usuario';


--
-- TOC entry 2640 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN account.account; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account.account IS 'Numero de cuenta en 4 digitos';


--
-- TOC entry 203 (class 1259 OID 17772)
-- Dependencies: 2376 2377 2378 2379 2380 2381 2382 7 1718
-- Name: account_contacts; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_contacts (
    idaccount integer DEFAULT 0 NOT NULL,
    idcontact integer DEFAULT 0 NOT NULL,
    prioritycontact integer DEFAULT 5 NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    appointment text DEFAULT ''::text NOT NULL,
    note text COLLATE pg_catalog."C.UTF-8" DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2641 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE account_contacts; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_contacts IS 'Usuarios del sistema, tiene acceso al sistema ';


--
-- TOC entry 2642 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN account_contacts.prioritycontact; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_contacts.prioritycontact IS 'Priordad de comunicar novedad a este contacto';


--
-- TOC entry 183 (class 1259 OID 16974)
-- Dependencies: 184 7
-- Name: account_idaccount_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE account_idaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2643 (class 0 OID 0)
-- Dependencies: 183
-- Name: account_idaccount_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_idaccount_seq OWNED BY account.idaccount;


--
-- TOC entry 185 (class 1259 OID 17049)
-- Dependencies: 2277 2278 2279 2280 2281 2282 2283 2284 2285 7
-- Name: account_installationdata; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_installationdata (
    idinstallationdata integer DEFAULT 0 NOT NULL,
    idaccount integer DEFAULT 0 NOT NULL,
    installationdate timestamp without time zone DEFAULT now() NOT NULL,
    installercode text DEFAULT '1234'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    idpanelmodel integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    idcommunicationformat integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2644 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE account_installationdata; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_installationdata IS 'Datos basico acerca de la instalacion del sistema de alarma';


--
-- TOC entry 2645 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN account_installationdata.idaccount; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_installationdata.idaccount IS 'idaccount a la que pertenecen estos datos';


--
-- TOC entry 2646 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN account_installationdata.installercode; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_installationdata.installercode IS 'Codigo de instalador del panel de control';


--
-- TOC entry 189 (class 1259 OID 17143)
-- Dependencies: 2293 2294 2295 2296 2297 2298 2299 7 1720
-- Name: account_location; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_location (
    idlocation bigint NOT NULL,
    idaccount integer DEFAULT 0 NOT NULL,
    geox real DEFAULT 0 NOT NULL,
    geoy real DEFAULT 0 NOT NULL,
    address text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'none'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    idaddress text DEFAULT 'XXXXX'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2647 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE account_location; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_location IS 'Localizacion de la cuenta';


--
-- TOC entry 2648 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN account_location.geox; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_location.geox IS 'Ubicacion georeferenciada';


--
-- TOC entry 2649 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN account_location.address; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_location.address IS 'Detalle de la direccion, puntos de referencia, etc.';


--
-- TOC entry 188 (class 1259 OID 17141)
-- Dependencies: 189 7
-- Name: account_location_idlocation_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE account_location_idlocation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2650 (class 0 OID 0)
-- Dependencies: 188
-- Name: account_location_idlocation_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_location_idlocation_seq OWNED BY account_location.idlocation;


--
-- TOC entry 191 (class 1259 OID 17176)
-- Dependencies: 2301 2302 2303 2304 2305 2306 2307 2308 7 1720 1720
-- Name: account_notifications; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_notifications (
    idnotifaccount bigint NOT NULL,
    idaccount integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 5 NOT NULL,
    call boolean DEFAULT false NOT NULL,
    sms boolean DEFAULT false NOT NULL,
    smstext text COLLATE pg_catalog."es_EC.utf8" DEFAULT ' '::text NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2651 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE account_notifications; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_notifications IS 'Contactos a donde se enviara las notificaciones en caso de alarma';


--
-- TOC entry 193 (class 1259 OID 17261)
-- Dependencies: 2310 2311 2312 7
-- Name: account_notifications_eventtype; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_notifications_eventtype (
    idnotifphoneeventtype bigint NOT NULL,
    idnotifaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2652 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE account_notifications_eventtype; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_notifications_eventtype IS 'Tipos de eventos para cada notificacion.
TODO: Verificar llaves unicas';


--
-- TOC entry 192 (class 1259 OID 17259)
-- Dependencies: 193 7
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2653 (class 0 OID 0)
-- Dependencies: 192
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq OWNED BY account_notifications_eventtype.idnotifphoneeventtype;


--
-- TOC entry 224 (class 1259 OID 26445)
-- Dependencies: 2432 2433 2434 7
-- Name: account_notifications_group; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_notifications_group (
    idaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2654 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE account_notifications_group; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_notifications_group IS 'Tipos de eventos que se enviaran a los grupos';


--
-- TOC entry 190 (class 1259 OID 17174)
-- Dependencies: 7 191
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE account_notifications_idnotifaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2655 (class 0 OID 0)
-- Dependencies: 190
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_notifications_idnotifaccount_seq OWNED BY account_notifications.idnotifaccount;


--
-- TOC entry 205 (class 1259 OID 18107)
-- Dependencies: 2395 2396 2397 2398 2399 2400 2401 7 1720
-- Name: account_phones_trigger_alarm; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_phones_trigger_alarm (
    idaccount integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    enable boolean DEFAULT false NOT NULL,
    fromsms boolean DEFAULT true NOT NULL,
    fromcall boolean DEFAULT true NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 204 (class 1259 OID 18087)
-- Dependencies: 2389 2390 2391 2392 2393 1720 1720 1718 7 203
-- Name: account_users; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_users (
    enable_as_user boolean DEFAULT true NOT NULL,
    keyword text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'undefined'::text NOT NULL,
    pwd text COLLATE pg_catalog."es_EC.utf8" DEFAULT '1234'::text NOT NULL,
    numuser integer DEFAULT 0 NOT NULL,
    note_user text DEFAULT ' '::text NOT NULL
)
INHERITS (account_contacts);


--
-- TOC entry 2656 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN account_users.numuser; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_users.numuser IS 'Numero de usuario';


--
-- TOC entry 195 (class 1259 OID 17289)
-- Dependencies: 2313 2314 2315 2316 2317 2318 2319 2320 2322 2323 2324 2325 2326 2327 2328 2329 2330 2331 2332 2333 1720 7
-- Name: events; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE events (
    idevent bigint NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    idaccount integer DEFAULT 0 NOT NULL,
    code text DEFAULT '0000'::text NOT NULL,
    zu integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 5 NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    datetimeevent timestamp without time zone DEFAULT now() NOT NULL,
    process1 integer DEFAULT 0 NOT NULL,
    process2 integer DEFAULT 0 NOT NULL,
    process3 integer DEFAULT 0 NOT NULL,
    process4 integer DEFAULT 0 NOT NULL,
    process5 integer DEFAULT 0 NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ' '::text NOT NULL,
    dateprocess1 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess2 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess3 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess4 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess5 timestamp without time zone DEFAULT now() NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2657 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE events; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE events IS 'Eventos del sistema
TODO: Ver la posibilidad de crear llave unica usando todos los campos';


--
-- TOC entry 2658 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN events.dateload; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN events.dateload IS 'Fecha de ingreso del evento';


--
-- TOC entry 202 (class 1259 OID 17714)
-- Dependencies: 2373 195 1720 7
-- Name: events_generated_by_calls; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE events_generated_by_calls (
    idincall integer DEFAULT 0 NOT NULL
)
INHERITS (events);


--
-- TOC entry 2659 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE events_generated_by_calls; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE events_generated_by_calls IS 'Tabla de eventos generados por llamadas telefonicas.
No permite eventos con misma hora, mismo idphone, etc, no permite eventos repetidos.';


--
-- TOC entry 194 (class 1259 OID 17287)
-- Dependencies: 195 7
-- Name: events_idevent_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE events_idevent_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2660 (class 0 OID 0)
-- Dependencies: 194
-- Name: events_idevent_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE events_idevent_seq OWNED BY events.idevent;


--
-- TOC entry 196 (class 1259 OID 17352)
-- Dependencies: 2334 2335 2336 2337 2338 2339 2340 2341 7
-- Name: eventtypes; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE eventtypes (
    ideventtype integer DEFAULT 0 NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    accountdefault boolean DEFAULT false NOT NULL,
    label text DEFAULT 'Undefined'::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    groupdefault boolean DEFAULT false NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2661 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE eventtypes; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE eventtypes IS 'Tipos de eventos. Enumeracion interna desde OpenSAGA, usar unicamente los que no estan reservados.';


--
-- TOC entry 2662 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN eventtypes.name; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN eventtypes.name IS 'Nombre del evento';


--
-- TOC entry 222 (class 1259 OID 26381)
-- Dependencies: 2428 2429 2430 2431 1720 1720 7
-- Name: groups; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    idgroup bigint NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'group'::text NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 26379)
-- Dependencies: 222 7
-- Name: groups_idgroup_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE groups_idgroup_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2663 (class 0 OID 0)
-- Dependencies: 221
-- Name: groups_idgroup_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE groups_idgroup_seq OWNED BY groups.idgroup;


--
-- TOC entry 198 (class 1259 OID 17389)
-- Dependencies: 2343 2344 2345 2346 2347 7 1720
-- Name: keywords; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE keywords (
    idkeyword bigint NOT NULL,
    enable boolean DEFAULT false NOT NULL,
    keyword text DEFAULT 'alarm'::text NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2664 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE keywords; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE keywords IS 'Lista de palabras claves a reconocer en los sms';


--
-- TOC entry 197 (class 1259 OID 17387)
-- Dependencies: 198 7
-- Name: keywords_idkeyword_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE keywords_idkeyword_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2665 (class 0 OID 0)
-- Dependencies: 197
-- Name: keywords_idkeyword_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE keywords_idkeyword_seq OWNED BY keywords.idkeyword;


--
-- TOC entry 214 (class 1259 OID 26202)
-- Dependencies: 2416 2417 2418 1718 1718 7
-- Name: notification_templates; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE notification_templates (
    idnotiftempl bigint NOT NULL,
    description text COLLATE pg_catalog."C.UTF-8" DEFAULT 'description'::text NOT NULL,
    message text COLLATE pg_catalog."C.UTF-8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2666 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE notification_templates; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE notification_templates IS 'Plantilla de notificaciones, usa valores predeterminados para las notificaciones.

DATOS DE ABONADO
&A01: Grupo
&A02: Subgrupo
&A03: Nombre abonado
&A04: Numero del abonado
&A05: Direccion abonado
&A06: Coordenadas abonado

DATOS DE USUARIO
&U01: Nombre completo
&U02: Numero de telefono (que generó la alarma)
&U03: Tipo de telefono
&U04: Direccion del telefono
&U05: Coordenadas del telefono

DATOS DEL EVENTO
&E01: Descripcion del evento






';


--
-- TOC entry 213 (class 1259 OID 26200)
-- Dependencies: 7 214
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE notification_templates_idnotiftempl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2667 (class 0 OID 0)
-- Dependencies: 213
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE notification_templates_idnotiftempl_seq OWNED BY notification_templates.idnotiftempl;


--
-- TOC entry 187 (class 1259 OID 17108)
-- Dependencies: 2287 2288 2289 2290 2291 7
-- Name: panelmodel; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE panelmodel (
    idpanelmodel bigint NOT NULL,
    name text DEFAULT 'Undefined'::text,
    model text DEFAULT 'Undefined'::text NOT NULL,
    version text DEFAULT 'v-0.0'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2668 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE panelmodel; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE panelmodel IS 'Modelos de paneles de control de alarma';


--
-- TOC entry 186 (class 1259 OID 17106)
-- Dependencies: 7 187
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE panelmodel_idpanelmodel_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2669 (class 0 OID 0)
-- Dependencies: 186
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE panelmodel_idpanelmodel_seq OWNED BY panelmodel.idpanelmodel;


SET search_path = public, pg_catalog;

--
-- TOC entry 165 (class 1259 OID 16387)
-- Dependencies: 2159 2160 2161 2162 2163 2164 2165 2166 2167 2168 2169 2170 2171 2172 5
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    idcontact integer NOT NULL,
    enable boolean DEFAULT true,
    firstname text DEFAULT 'nombre'::text NOT NULL,
    lastname text DEFAULT ' '::text NOT NULL,
    gender integer DEFAULT 0 NOT NULL,
    birthday date DEFAULT '1900-01-01'::date NOT NULL,
    typeofid integer DEFAULT 0 NOT NULL,
    identification text DEFAULT ''::text NOT NULL,
    web text DEFAULT ''::text NOT NULL,
    email1 text DEFAULT ''::text NOT NULL,
    email2 text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    idaddress text DEFAULT 'X'::text,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    title text DEFAULT 'Sr@'::text NOT NULL
);


--
-- TOC entry 2670 (class 0 OID 0)
-- Dependencies: 165
-- Name: TABLE contacts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE contacts IS 'Datos basicos de contactos';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 225 (class 1259 OID 26909)
-- Dependencies: 2156 7 1718
-- Name: view_account_contacts; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_account_contacts AS
    SELECT DISTINCT ON (tabla.idaccount, tabla.idcontact) tabla.idaccount, tabla.idcontact, tabla.enable, tabla.firstname, tabla.lastname, tabla.prioritycontact, tabla.enable_as_contact, tabla.appointment, tabla.ts, tabla.note FROM (SELECT account_contacts.idaccount, contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment, account_contacts.ts, account_contacts.note FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact) ORDER BY account_contacts.ts DESC) tabla ORDER BY tabla.idaccount, tabla.idcontact, tabla.ts DESC;


SET search_path = public, pg_catalog;

--
-- TOC entry 167 (class 1259 OID 16423)
-- Dependencies: 2174 2175 2176 2177 2178 2179 2180 2181 2182 2183 2184 2185 2186 5 1720
-- Name: phones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phones (
    idphone integer NOT NULL,
    idcontact integer DEFAULT 0 NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    typephone integer DEFAULT 0 NOT NULL,
    idprovider integer DEFAULT 0 NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    geox real DEFAULT 0 NOT NULL,
    geoy real DEFAULT 0 NOT NULL,
    idaddress text DEFAULT 'XXXXX'::text NOT NULL,
    phone_ext text DEFAULT ' '::text NOT NULL,
    ubiphone integer DEFAULT 0 NOT NULL,
    address text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'unknown'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2671 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE phones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE phones IS 'Numeros telefonicos de contactos.';


--
-- TOC entry 2672 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN phones.typephone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN phones.typephone IS '0: No especificado
1: Fijo
2: Movil';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 223 (class 1259 OID 26425)
-- Dependencies: 2155 1720 7
-- Name: view_account_phones_trigger_alarm; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_account_phones_trigger_alarm AS
    SELECT account.idaccount, account.enable, account.account, account.name, account.type, account_phones_trigger_alarm.idphone, (SELECT phones.phone FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS phone, (SELECT phones.idprovider FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS idprovider, (SELECT phones.address FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS address, account_phones_trigger_alarm.enable AS trigger_enable, account_phones_trigger_alarm.fromcall, account_phones_trigger_alarm.fromsms FROM account, account_phones_trigger_alarm WHERE (account.idaccount = account_phones_trigger_alarm.idaccount);


--
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 223
-- Name: VIEW view_account_phones_trigger_alarm; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON VIEW view_account_phones_trigger_alarm IS 'TODO: Cambiar la vista usando left join para mejorar desempeño';


--
-- TOC entry 206 (class 1259 OID 26127)
-- Dependencies: 2152 1720 7 1720
-- Name: view_account_users; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_account_users AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_users.idaccount, account_users.prioritycontact, account_users.enable AS enable_as_contact, account_users.appointment, account_users.enable_as_user, account_users.numuser, account_users.pwd, account_users.keyword FROM account_users, public.contacts WHERE (contacts.idcontact = account_users.idcontact);


--
-- TOC entry 220 (class 1259 OID 26345)
-- Dependencies: 2154 7
-- Name: view_events; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_events AS
    SELECT events.idevent, events.dateload, events.idaccount, account.partition, account.enable, account.account, account.name, account.type, events.code, events.zu, events.priority, events.description, events.ideventtype, (SELECT eventtypes.label FROM eventtypes WHERE (eventtypes.ideventtype = events.ideventtype)) AS eventtype, events.datetimeevent, events.process1, events.process2, events.process3, events.process4, events.process5, events.dateprocess1, events.dateprocess2, events.dateprocess4, events.dateprocess3, events.dateprocess5 FROM (events LEFT JOIN account ON ((events.idaccount = account.idaccount)));


SET search_path = public, pg_catalog;

--
-- TOC entry 212 (class 1259 OID 26177)
-- Dependencies: 2412 2413 2414 5 1720
-- Name: address_city; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address_city (
    idcity bigint NOT NULL,
    idstate integer DEFAULT 0 NOT NULL,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'city'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 208 (class 1259 OID 26134)
-- Dependencies: 2403 2404 2405 5
-- Name: address_country; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address_country (
    idcountry bigint NOT NULL,
    name text DEFAULT 'country'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE address_country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE address_country IS 'Paices del mundo';


--
-- TOC entry 216 (class 1259 OID 26237)
-- Dependencies: 2420 2421 2422 5 1718
-- Name: address_sector; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address_sector (
    idsector bigint NOT NULL,
    idcity integer DEFAULT 0 NOT NULL,
    name text COLLATE pg_catalog."C.UTF-8" DEFAULT 'sector'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 215 (class 1259 OID 26235)
-- Dependencies: 5 216
-- Name: address_sector_idsector_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE address_sector_idsector_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 215
-- Name: address_sector_idsector_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE address_sector_idsector_seq OWNED BY address_sector.idsector;


--
-- TOC entry 210 (class 1259 OID 26156)
-- Dependencies: 2407 2408 2409 2410 5
-- Name: address_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address_states (
    idstate bigint NOT NULL,
    idcountry integer DEFAULT 0 NOT NULL,
    name text DEFAULT 'state'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE address_states; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE address_states IS 'Estados o provincias';


--
-- TOC entry 218 (class 1259 OID 26257)
-- Dependencies: 2424 2425 2426 5 1720
-- Name: address_subsector; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address_subsector (
    idsubsector bigint NOT NULL,
    idsector integer DEFAULT 0 NOT NULL,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'subsector'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 26255)
-- Dependencies: 5 218
-- Name: address_subsector_idsubsector_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE address_subsector_idsubsector_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 217
-- Name: address_subsector_idsubsector_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE address_subsector_idsubsector_seq OWNED BY address_subsector.idsubsector;


--
-- TOC entry 177 (class 1259 OID 16622)
-- Dependencies: 2243 2244 2245 5 1720
-- Name: blacklist; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE blacklist (
    idbl integer NOT NULL,
    idprovider integer DEFAULT 0,
    idphone integer DEFAULT 0,
    note text COLLATE pg_catalog."es_EC.utf8",
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE blacklist; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE blacklist IS 'Lista de numeros a los que no se enviaran sms.';


--
-- TOC entry 176 (class 1259 OID 16620)
-- Dependencies: 5 177
-- Name: blacklist_idbl_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE blacklist_idbl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 176
-- Name: blacklist_idbl_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE blacklist_idbl_seq OWNED BY blacklist.idbl;


--
-- TOC entry 211 (class 1259 OID 26175)
-- Dependencies: 212 5
-- Name: city_idcity_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE city_idcity_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 211
-- Name: city_idcity_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE city_idcity_seq OWNED BY address_city.idcity;


--
-- TOC entry 164 (class 1259 OID 16385)
-- Dependencies: 165 5
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 164
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.idcontact;


--
-- TOC entry 207 (class 1259 OID 26132)
-- Dependencies: 208 5
-- Name: country_idcountry_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE country_idcountry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 207
-- Name: country_idcountry_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE country_idcountry_seq OWNED BY address_country.idcountry;


--
-- TOC entry 178 (class 1259 OID 16696)
-- Dependencies: 2246 2247 2248 5
-- Name: currentportsproviders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE currentportsproviders (
    idport integer DEFAULT 0 NOT NULL,
    port text,
    cimi text,
    imei text,
    idprovider integer,
    lastupdate timestamp without time zone DEFAULT now(),
    idmodem integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE currentportsproviders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE currentportsproviders IS 'Tabla de relacion entre puertos y proveedor que estan usando actualmente';


--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.idport; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN currentportsproviders.idport IS 'IdPort, dato proveniente de la tabla serialport de usmsd.sqlite';


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.port; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN currentportsproviders.port IS 'Dato proveniente de la tabla serialport de usmsd.sqlite';


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.cimi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN currentportsproviders.cimi IS 'Dato proveniente del modem';


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.imei; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN currentportsproviders.imei IS 'Dato proveniente del modem';


--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.idprovider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN currentportsproviders.idprovider IS 'Dato proveniente de la tabla provider usndo como referencia el campo cimi para obtenerlo.';


--
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.lastupdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN currentportsproviders.lastupdate IS 'Fecha de la ultima actualizacion. Si este campo exede de 2 minuto en relacion a la fecha actual deberia eliminarse.';


--
-- TOC entry 182 (class 1259 OID 16833)
-- Dependencies: 2256 2257 2258 2259 2260 2261 2262 2263 2264 2265 2266 5
-- Name: incomingcalls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE incomingcalls (
    idincall bigint NOT NULL,
    datecall timestamp without time zone DEFAULT now() NOT NULL,
    idport integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    callaction integer DEFAULT 0 NOT NULL,
    phone text NOT NULL,
    note text,
    flag1 integer DEFAULT 0 NOT NULL,
    flag2 integer DEFAULT 0 NOT NULL,
    flag3 integer DEFAULT 0 NOT NULL,
    flag4 integer DEFAULT 0 NOT NULL,
    flag5 integer DEFAULT 0 NOT NULL,
    idmodem integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE incomingcalls; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE incomingcalls IS 'Registro de llamadas entrantes';


--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN incomingcalls.datecall; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN incomingcalls.datecall IS 'Fecha de recepcion de la llamada.';


--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN incomingcalls.idport; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN incomingcalls.idport IS 'Idport por el cual se recibio la llamada.';


--
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN incomingcalls.callaction; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN incomingcalls.callaction IS 'Accion tomada ante esa llamada: ignorada, rechazada, contestada';


--
-- TOC entry 181 (class 1259 OID 16831)
-- Dependencies: 5 182
-- Name: incomingcalls_idincall_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE incomingcalls_idincall_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 181
-- Name: incomingcalls_idincall_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE incomingcalls_idincall_seq OWNED BY incomingcalls.idincall;


--
-- TOC entry 201 (class 1259 OID 17582)
-- Dependencies: 2349 2350 2351 2352 2353 1720 1720 5 1720
-- Name: modem; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE modem (
    idmodem bigint NOT NULL,
    imei text DEFAULT '01234'::text NOT NULL,
    manufacturer text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'Could not be obtained'::text NOT NULL,
    model text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'Could not be obtained'::text NOT NULL,
    revision text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'Could not be obtained'::text NOT NULL,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE modem; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE modem IS 'Modems que han sido automaticamente registrados por el sistema';


--
-- TOC entry 200 (class 1259 OID 17580)
-- Dependencies: 201 5
-- Name: modem_idmodem_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE modem_idmodem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 200
-- Name: modem_idmodem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE modem_idmodem_seq OWNED BY modem.idmodem;


--
-- TOC entry 166 (class 1259 OID 16421)
-- Dependencies: 5 167
-- Name: phones_idphone_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phones_idphone_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 166
-- Name: phones_idphone_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phones_idphone_seq OWNED BY phones.idphone;


--
-- TOC entry 169 (class 1259 OID 16452)
-- Dependencies: 2188 2189 2190 2191 2192 5
-- Name: provider; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE provider (
    idprovider integer NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    cimi text DEFAULT ''::text NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE provider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE provider IS 'Proveedores de telefonia';


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN provider.cimi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN provider.cimi IS 'Obtiene desde el modem con el comando AT+CIMI, numero de identificacion inico de cada proveedor';


--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN provider.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN provider.name IS 'Nombre del proveedor';


--
-- TOC entry 168 (class 1259 OID 16450)
-- Dependencies: 169 5
-- Name: provider_idprovider_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE provider_idprovider_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 168
-- Name: provider_idprovider_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE provider_idprovider_seq OWNED BY provider.idprovider;


--
-- TOC entry 171 (class 1259 OID 16522)
-- Dependencies: 2194 2195 2196 2197 2198 2199 2200 2201 2202 2203 2204 2205 2206 2207 2208 1720 1720 5
-- Name: smsin; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE smsin (
    idsmsin bigint NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    idprovider integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    datesms timestamp without time zone DEFAULT '1990-01-01 00:00:00'::timestamp without time zone NOT NULL,
    message text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL,
    idport integer DEFAULT 0,
    status integer DEFAULT 0 NOT NULL,
    flag1 integer DEFAULT 0 NOT NULL,
    flag2 integer DEFAULT 0 NOT NULL,
    flag3 integer DEFAULT 0 NOT NULL,
    flag4 integer DEFAULT 0 NOT NULL,
    flag5 integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE smsin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE smsin IS 'Tabla de sms entrantes';


--
-- TOC entry 170 (class 1259 OID 16520)
-- Dependencies: 171 5
-- Name: smsin_idsmsin_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE smsin_idsmsin_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 170
-- Name: smsin_idsmsin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE smsin_idsmsin_seq OWNED BY smsin.idsmsin;


--
-- TOC entry 172 (class 1259 OID 16577)
-- Dependencies: 5 173
-- Name: smsout_idsmsout_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE smsout_idsmsout_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 172
-- Name: smsout_idsmsout_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE smsout_idsmsout_seq OWNED BY smsout.idsmsout;


--
-- TOC entry 179 (class 1259 OID 16743)
-- Dependencies: 5 180
-- Name: smsoutoptions_idsmsoutopt_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE smsoutoptions_idsmsoutopt_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 179
-- Name: smsoutoptions_idsmsoutopt_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE smsoutoptions_idsmsoutopt_seq OWNED BY smsoutoptions.idsmsoutopt;


--
-- TOC entry 209 (class 1259 OID 26154)
-- Dependencies: 5 210
-- Name: states_idstate_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_idstate_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 209
-- Name: states_idstate_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_idstate_seq OWNED BY address_states.idstate;


--
-- TOC entry 219 (class 1259 OID 26275)
-- Dependencies: 2153 1720 5 1720 1718
-- Name: view_address; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_address AS
    SELECT countryx.idcountry, countryx.name AS country, countryx.code AS country_code, statesx.idstate, statesx.name AS state, statesx.code AS state_code, cityx.idcity, cityx.name AS city, sectorx.idsector, sectorx.name AS sector, subsectorx.idsubsector, subsectorx.name AS subsector, ((((COALESCE((countryx.idcountry)::text, 'X'::text) || COALESCE((statesx.idstate)::text, 'X'::text)) || COALESCE((cityx.idcity)::text, 'X'::text)) || COALESCE((sectorx.idsector)::text, 'X'::text)) || COALESCE((subsectorx.idsubsector)::text, 'X'::text)) AS idaddress FROM ((((address_country countryx LEFT JOIN address_states statesx ON ((countryx.idcountry = statesx.idcountry))) LEFT JOIN address_city cityx ON ((statesx.idstate = cityx.idstate))) LEFT JOIN address_sector sectorx ON ((cityx.idcity = sectorx.idcity))) LEFT JOIN address_subsector subsectorx ON ((sectorx.idsector = subsectorx.idsector)));


--
-- TOC entry 199 (class 1259 OID 17522)
-- Dependencies: 2151 5
-- Name: view_callin; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_callin AS
    SELECT incomingcalls.idincall, incomingcalls.datecall, incomingcalls.idport, incomingcalls.callaction, incomingcalls.idphone, incomingcalls.phone, incomingcalls.flag1, phones.idcontact, phones.enable, phones.phone AS phone_phone, phones.typephone AS type, phones.idprovider, phones.geox, phones.geoy FROM incomingcalls, phones WHERE (incomingcalls.idphone = phones.idphone);


--
-- TOC entry 226 (class 1259 OID 27010)
-- Dependencies: 2157 5 1720
-- Name: view_contacts_phones; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_contacts_phones AS
    SELECT contacts.idcontact, contacts.enable AS contact_enable, contacts.title, contacts.firstname, contacts.lastname, contacts.gender, contacts.birthday, contacts.typeofid, contacts.identification, contacts.web, contacts.email1, contacts.email2, phones.idphone, phones.enable AS phone_enable, phones.typephone AS type, phones.idprovider, phones.ubiphone, phones.phone, phones.phone_ext, phones.idaddress, phones.address, phones.geox, phones.geoy, phones.note FROM (contacts LEFT JOIN phones ON ((contacts.idcontact = phones.idcontact)));


--
-- TOC entry 175 (class 1259 OID 16599)
-- Dependencies: 2239 2240 2241 5 1720
-- Name: whitelist; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE whitelist (
    idwl integer NOT NULL,
    idprovider integer DEFAULT 0,
    idphone integer DEFAULT 0,
    note text COLLATE pg_catalog."es_EC.utf8",
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE whitelist; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE whitelist IS 'Lista de numeros para envio de sms sin restriccion';


--
-- TOC entry 174 (class 1259 OID 16597)
-- Dependencies: 5 175
-- Name: whitelist_idwl_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE whitelist_idwl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 174
-- Name: whitelist_idwl_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE whitelist_idwl_seq OWNED BY whitelist.idwl;


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2267 (class 2604 OID 16979)
-- Dependencies: 184 183 184
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account ALTER COLUMN idaccount SET DEFAULT nextval('account_idaccount_seq'::regclass);


--
-- TOC entry 2292 (class 2604 OID 17146)
-- Dependencies: 188 189 189
-- Name: idlocation; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_location ALTER COLUMN idlocation SET DEFAULT nextval('account_location_idlocation_seq'::regclass);


--
-- TOC entry 2300 (class 2604 OID 17179)
-- Dependencies: 191 190 191
-- Name: idnotifaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications ALTER COLUMN idnotifaccount SET DEFAULT nextval('account_notifications_idnotifaccount_seq'::regclass);


--
-- TOC entry 2309 (class 2604 OID 17264)
-- Dependencies: 193 192 193
-- Name: idnotifphoneeventtype; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications_eventtype ALTER COLUMN idnotifphoneeventtype SET DEFAULT nextval('account_notifications_eventtype_idnotifphoneeventtype_seq'::regclass);


--
-- TOC entry 2383 (class 2604 OID 18090)
-- Dependencies: 204 204
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2384 (class 2604 OID 18091)
-- Dependencies: 204 204
-- Name: idcontact; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN idcontact SET DEFAULT 0;


--
-- TOC entry 2385 (class 2604 OID 18092)
-- Dependencies: 204 204
-- Name: prioritycontact; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN prioritycontact SET DEFAULT 5;


--
-- TOC entry 2386 (class 2604 OID 18093)
-- Dependencies: 204 204
-- Name: enable; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN enable SET DEFAULT true;


--
-- TOC entry 2387 (class 2604 OID 18094)
-- Dependencies: 204 204
-- Name: appointment; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN appointment SET DEFAULT ''::text;


--
-- TOC entry 2388 (class 2604 OID 18095)
-- Dependencies: 204 204
-- Name: note; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN note SET DEFAULT ''::text;


--
-- TOC entry 2394 (class 2604 OID 26457)
-- Dependencies: 204 204
-- Name: ts; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2321 (class 2604 OID 17292)
-- Dependencies: 195 194 195
-- Name: idevent; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2365 (class 2604 OID 17717)
-- Dependencies: 202 194 202
-- Name: idevent; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2366 (class 2604 OID 17718)
-- Dependencies: 202 202
-- Name: dateload; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateload SET DEFAULT now();


--
-- TOC entry 2367 (class 2604 OID 17719)
-- Dependencies: 202 202
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2368 (class 2604 OID 17720)
-- Dependencies: 202 202
-- Name: code; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN code SET DEFAULT '0000'::text;


--
-- TOC entry 2369 (class 2604 OID 17721)
-- Dependencies: 202 202
-- Name: zu; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN zu SET DEFAULT 0;


--
-- TOC entry 2370 (class 2604 OID 17722)
-- Dependencies: 202 202
-- Name: priority; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN priority SET DEFAULT 5;


--
-- TOC entry 2371 (class 2604 OID 17723)
-- Dependencies: 202 202
-- Name: description; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN description SET DEFAULT ''::text;


--
-- TOC entry 2372 (class 2604 OID 17724)
-- Dependencies: 202 202
-- Name: ideventtype; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ideventtype SET DEFAULT 0;


--
-- TOC entry 2374 (class 2604 OID 18022)
-- Dependencies: 202 202
-- Name: datetimeevent; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN datetimeevent SET DEFAULT now();


--
-- TOC entry 2354 (class 2604 OID 25925)
-- Dependencies: 202 202
-- Name: process1; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process1 SET DEFAULT 0;


--
-- TOC entry 2355 (class 2604 OID 25942)
-- Dependencies: 202 202
-- Name: process2; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process2 SET DEFAULT 0;


--
-- TOC entry 2356 (class 2604 OID 25959)
-- Dependencies: 202 202
-- Name: process3; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process3 SET DEFAULT 0;


--
-- TOC entry 2357 (class 2604 OID 25976)
-- Dependencies: 202 202
-- Name: process4; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process4 SET DEFAULT 0;


--
-- TOC entry 2358 (class 2604 OID 25993)
-- Dependencies: 202 202
-- Name: process5; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process5 SET DEFAULT 0;


--
-- TOC entry 2359 (class 2604 OID 26010)
-- Dependencies: 202 202
-- Name: note; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN note SET DEFAULT ' '::text;


--
-- TOC entry 2360 (class 2604 OID 26033)
-- Dependencies: 202 202
-- Name: dateprocess1; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess1 SET DEFAULT now();


--
-- TOC entry 2361 (class 2604 OID 26050)
-- Dependencies: 202 202
-- Name: dateprocess2; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess2 SET DEFAULT now();


--
-- TOC entry 2362 (class 2604 OID 26067)
-- Dependencies: 202 202
-- Name: dateprocess3; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess3 SET DEFAULT now();


--
-- TOC entry 2363 (class 2604 OID 26084)
-- Dependencies: 202 202
-- Name: dateprocess4; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess4 SET DEFAULT now();


--
-- TOC entry 2364 (class 2604 OID 26101)
-- Dependencies: 202 202
-- Name: dateprocess5; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess5 SET DEFAULT now();


--
-- TOC entry 2375 (class 2604 OID 26572)
-- Dependencies: 202 202
-- Name: ts; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2427 (class 2604 OID 26384)
-- Dependencies: 221 222 222
-- Name: idgroup; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN idgroup SET DEFAULT nextval('groups_idgroup_seq'::regclass);


--
-- TOC entry 2342 (class 2604 OID 17392)
-- Dependencies: 198 197 198
-- Name: idkeyword; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY keywords ALTER COLUMN idkeyword SET DEFAULT nextval('keywords_idkeyword_seq'::regclass);


--
-- TOC entry 2415 (class 2604 OID 26205)
-- Dependencies: 213 214 214
-- Name: idnotiftempl; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY notification_templates ALTER COLUMN idnotiftempl SET DEFAULT nextval('notification_templates_idnotiftempl_seq'::regclass);


--
-- TOC entry 2286 (class 2604 OID 17111)
-- Dependencies: 187 186 187
-- Name: idpanelmodel; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY panelmodel ALTER COLUMN idpanelmodel SET DEFAULT nextval('panelmodel_idpanelmodel_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2411 (class 2604 OID 26180)
-- Dependencies: 211 212 212
-- Name: idcity; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_city ALTER COLUMN idcity SET DEFAULT nextval('city_idcity_seq'::regclass);


--
-- TOC entry 2402 (class 2604 OID 26137)
-- Dependencies: 208 207 208
-- Name: idcountry; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_country ALTER COLUMN idcountry SET DEFAULT nextval('country_idcountry_seq'::regclass);


--
-- TOC entry 2419 (class 2604 OID 26240)
-- Dependencies: 215 216 216
-- Name: idsector; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_sector ALTER COLUMN idsector SET DEFAULT nextval('address_sector_idsector_seq'::regclass);


--
-- TOC entry 2406 (class 2604 OID 26159)
-- Dependencies: 209 210 210
-- Name: idstate; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_states ALTER COLUMN idstate SET DEFAULT nextval('states_idstate_seq'::regclass);


--
-- TOC entry 2423 (class 2604 OID 26260)
-- Dependencies: 217 218 218
-- Name: idsubsector; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_subsector ALTER COLUMN idsubsector SET DEFAULT nextval('address_subsector_idsubsector_seq'::regclass);


--
-- TOC entry 2242 (class 2604 OID 16625)
-- Dependencies: 177 176 177
-- Name: idbl; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY blacklist ALTER COLUMN idbl SET DEFAULT nextval('blacklist_idbl_seq'::regclass);


--
-- TOC entry 2158 (class 2604 OID 16390)
-- Dependencies: 164 165 165
-- Name: idcontact; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN idcontact SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- TOC entry 2255 (class 2604 OID 16836)
-- Dependencies: 182 181 182
-- Name: idincall; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY incomingcalls ALTER COLUMN idincall SET DEFAULT nextval('incomingcalls_idincall_seq'::regclass);


--
-- TOC entry 2348 (class 2604 OID 17585)
-- Dependencies: 200 201 201
-- Name: idmodem; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY modem ALTER COLUMN idmodem SET DEFAULT nextval('modem_idmodem_seq'::regclass);


--
-- TOC entry 2173 (class 2604 OID 16426)
-- Dependencies: 167 166 167
-- Name: idphone; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phones ALTER COLUMN idphone SET DEFAULT nextval('phones_idphone_seq'::regclass);


--
-- TOC entry 2187 (class 2604 OID 16455)
-- Dependencies: 169 168 169
-- Name: idprovider; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY provider ALTER COLUMN idprovider SET DEFAULT nextval('provider_idprovider_seq'::regclass);


--
-- TOC entry 2193 (class 2604 OID 16525)
-- Dependencies: 171 170 171
-- Name: idsmsin; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY smsin ALTER COLUMN idsmsin SET DEFAULT nextval('smsin_idsmsin_seq'::regclass);


--
-- TOC entry 2209 (class 2604 OID 16582)
-- Dependencies: 172 173 173
-- Name: idsmsout; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY smsout ALTER COLUMN idsmsout SET DEFAULT nextval('smsout_idsmsout_seq'::regclass);


--
-- TOC entry 2249 (class 2604 OID 16748)
-- Dependencies: 179 180 180
-- Name: idsmsoutopt; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY smsoutoptions ALTER COLUMN idsmsoutopt SET DEFAULT nextval('smsoutoptions_idsmsoutopt_seq'::regclass);


--
-- TOC entry 2238 (class 2604 OID 16602)
-- Dependencies: 175 174 175
-- Name: idwl; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY whitelist ALTER COLUMN idwl SET DEFAULT nextval('whitelist_idwl_seq'::regclass);


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2492 (class 2606 OID 18076)
-- Dependencies: 203 203 203 2579
-- Name: pk_account_contacts; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT pk_account_contacts PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2524 (class 2606 OID 26454)
-- Dependencies: 224 224 224 2579
-- Name: pk_account_notif_group; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications_group
    ADD CONSTRAINT pk_account_notif_group PRIMARY KEY (idaccount, ideventtype);


--
-- TOC entry 2496 (class 2606 OID 18120)
-- Dependencies: 205 205 205 2579
-- Name: pk_account_triggers_phones; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT pk_account_triggers_phones PRIMARY KEY (idaccount, idphone);


--
-- TOC entry 2494 (class 2606 OID 26886)
-- Dependencies: 204 204 204 2579
-- Name: pk_account_users; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT pk_account_users PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2456 (class 2606 OID 16987)
-- Dependencies: 184 184 2579
-- Name: pk_idaccount; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT pk_idaccount PRIMARY KEY (idaccount);


--
-- TOC entry 2478 (class 2606 OID 17295)
-- Dependencies: 195 195 2579
-- Name: pk_idevent; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT pk_idevent PRIMARY KEY (idevent);


--
-- TOC entry 2488 (class 2606 OID 17730)
-- Dependencies: 202 202 2579
-- Name: pk_idevent_from_call; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT pk_idevent_from_call PRIMARY KEY (idevent);


--
-- TOC entry 2480 (class 2606 OID 17362)
-- Dependencies: 196 196 2579
-- Name: pk_ideventtype; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eventtypes
    ADD CONSTRAINT pk_ideventtype PRIMARY KEY (ideventtype);


--
-- TOC entry 2520 (class 2606 OID 26392)
-- Dependencies: 222 222 2579
-- Name: pk_idgroup; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT pk_idgroup PRIMARY KEY (idgroup);


--
-- TOC entry 2462 (class 2606 OID 17061)
-- Dependencies: 185 185 2579
-- Name: pk_idinstallationdata; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT pk_idinstallationdata PRIMARY KEY (idinstallationdata);


--
-- TOC entry 2482 (class 2606 OID 17399)
-- Dependencies: 198 198 2579
-- Name: pk_idkeyword; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT pk_idkeyword PRIMARY KEY (idkeyword);


--
-- TOC entry 2468 (class 2606 OID 17156)
-- Dependencies: 189 189 2579
-- Name: pk_idlocation; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT pk_idlocation PRIMARY KEY (idlocation);


--
-- TOC entry 2472 (class 2606 OID 17182)
-- Dependencies: 191 191 2579
-- Name: pk_idnotifaccount; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT pk_idnotifaccount PRIMARY KEY (idnotifaccount);


--
-- TOC entry 2476 (class 2606 OID 17266)
-- Dependencies: 193 193 2579
-- Name: pk_idnotifphoneeventtype; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT pk_idnotifphoneeventtype PRIMARY KEY (idnotifphoneeventtype);


--
-- TOC entry 2510 (class 2606 OID 26212)
-- Dependencies: 214 214 2579
-- Name: pk_idnotiftempl; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_templates
    ADD CONSTRAINT pk_idnotiftempl PRIMARY KEY (idnotiftempl);


--
-- TOC entry 2466 (class 2606 OID 17119)
-- Dependencies: 187 187 2579
-- Name: pk_idpanelmodel; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY panelmodel
    ADD CONSTRAINT pk_idpanelmodel PRIMARY KEY (idpanelmodel);


--
-- TOC entry 2474 (class 2606 OID 17988)
-- Dependencies: 191 191 191 2579
-- Name: uni_acc_notyf_idacc_idphone; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT uni_acc_notyf_idacc_idphone UNIQUE (idaccount, idphone);


--
-- TOC entry 2458 (class 2606 OID 26363)
-- Dependencies: 184 184 2579
-- Name: uni_account_account; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_account UNIQUE (account);


--
-- TOC entry 2460 (class 2606 OID 17949)
-- Dependencies: 184 184 2579
-- Name: uni_account_name; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_name UNIQUE (name);


--
-- TOC entry 2490 (class 2606 OID 18043)
-- Dependencies: 202 202 202 202 202 2579
-- Name: uni_event_from_calls; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT uni_event_from_calls UNIQUE (idaccount, ideventtype, datetimeevent, idincall);


--
-- TOC entry 2464 (class 2606 OID 17073)
-- Dependencies: 185 185 2579
-- Name: uni_idaccount; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT uni_idaccount UNIQUE (idaccount);


--
-- TOC entry 2470 (class 2606 OID 17173)
-- Dependencies: 189 189 2579
-- Name: uni_idaccount_alocation; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT uni_idaccount_alocation UNIQUE (idaccount);


--
-- TOC entry 2522 (class 2606 OID 26394)
-- Dependencies: 222 222 2579
-- Name: uni_name_groups; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT uni_name_groups UNIQUE (name);


SET search_path = public, pg_catalog;

--
-- TOC entry 2438 (class 2606 OID 16428)
-- Dependencies: 167 167 2579
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT id PRIMARY KEY (idphone);


--
-- TOC entry 2436 (class 2606 OID 16400)
-- Dependencies: 165 165 2579
-- Name: idcontact; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT idcontact PRIMARY KEY (idcontact);


--
-- TOC entry 2506 (class 2606 OID 26187)
-- Dependencies: 212 212 2579
-- Name: pk_city; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_city
    ADD CONSTRAINT pk_city PRIMARY KEY (idcity);


--
-- TOC entry 2448 (class 2606 OID 16632)
-- Dependencies: 177 177 2579
-- Name: pk_idbl; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT pk_idbl PRIMARY KEY (idbl);


--
-- TOC entry 2498 (class 2606 OID 26142)
-- Dependencies: 208 208 2579
-- Name: pk_idcountry; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_country
    ADD CONSTRAINT pk_idcountry PRIMARY KEY (idcountry);


--
-- TOC entry 2450 (class 2606 OID 16704)
-- Dependencies: 178 178 2579
-- Name: pk_idcpp; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY currentportsproviders
    ADD CONSTRAINT pk_idcpp PRIMARY KEY (idport);


--
-- TOC entry 2454 (class 2606 OID 16845)
-- Dependencies: 182 182 2579
-- Name: pk_idincall; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incomingcalls
    ADD CONSTRAINT pk_idincall PRIMARY KEY (idincall);


--
-- TOC entry 2484 (class 2606 OID 17587)
-- Dependencies: 201 201 2579
-- Name: pk_idmodem; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modem
    ADD CONSTRAINT pk_idmodem PRIMARY KEY (idmodem);


--
-- TOC entry 2440 (class 2606 OID 16464)
-- Dependencies: 169 169 2579
-- Name: pk_idprovider; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY provider
    ADD CONSTRAINT pk_idprovider PRIMARY KEY (idprovider);


--
-- TOC entry 2512 (class 2606 OID 26247)
-- Dependencies: 216 216 2579
-- Name: pk_idsector; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_sector
    ADD CONSTRAINT pk_idsector PRIMARY KEY (idsector);


--
-- TOC entry 2442 (class 2606 OID 16528)
-- Dependencies: 171 171 2579
-- Name: pk_idsmsin; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY smsin
    ADD CONSTRAINT pk_idsmsin PRIMARY KEY (idsmsin);


--
-- TOC entry 2452 (class 2606 OID 16756)
-- Dependencies: 180 180 2579
-- Name: pk_idsmsoutopt; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY smsoutoptions
    ADD CONSTRAINT pk_idsmsoutopt PRIMARY KEY (idsmsoutopt);


--
-- TOC entry 2502 (class 2606 OID 26167)
-- Dependencies: 210 210 2579
-- Name: pk_idstate; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_states
    ADD CONSTRAINT pk_idstate PRIMARY KEY (idstate);


--
-- TOC entry 2516 (class 2606 OID 26267)
-- Dependencies: 218 218 2579
-- Name: pk_idsubsector; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_subsector
    ADD CONSTRAINT pk_idsubsector PRIMARY KEY (idsubsector);


--
-- TOC entry 2446 (class 2606 OID 16609)
-- Dependencies: 175 175 2579
-- Name: pk_idwl; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT pk_idwl PRIMARY KEY (idwl);


--
-- TOC entry 2444 (class 2606 OID 16596)
-- Dependencies: 173 173 2579
-- Name: pk_smsout; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY smsout
    ADD CONSTRAINT pk_smsout PRIMARY KEY (idsmsout);


--
-- TOC entry 2514 (class 2606 OID 26249)
-- Dependencies: 216 216 216 2579
-- Name: uni_idcity_name_sector; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_sector
    ADD CONSTRAINT uni_idcity_name_sector UNIQUE (idcity, name);


--
-- TOC entry 2518 (class 2606 OID 26269)
-- Dependencies: 218 218 218 2579
-- Name: uni_idsector_name_subsector; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_subsector
    ADD CONSTRAINT uni_idsector_name_subsector UNIQUE (idsector, name);


--
-- TOC entry 2508 (class 2606 OID 26229)
-- Dependencies: 212 212 212 2579
-- Name: uni_idstate_name_city; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_city
    ADD CONSTRAINT uni_idstate_name_city UNIQUE (idstate, name);


--
-- TOC entry 2504 (class 2606 OID 26222)
-- Dependencies: 210 210 210 2579
-- Name: uni_idstate_name_states; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_states
    ADD CONSTRAINT uni_idstate_name_states UNIQUE (idcountry, name);


--
-- TOC entry 2486 (class 2606 OID 17624)
-- Dependencies: 201 201 2579
-- Name: uni_imei_modem; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modem
    ADD CONSTRAINT uni_imei_modem UNIQUE (imei);


--
-- TOC entry 2500 (class 2606 OID 26153)
-- Dependencies: 208 208 2579
-- Name: uni_namecountry; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_country
    ADD CONSTRAINT uni_namecountry UNIQUE (name);


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2557 (class 2620 OID 26838)
-- Dependencies: 279 184 2579
-- Name: ts_account; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account BEFORE UPDATE ON account FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2567 (class 2620 OID 26839)
-- Dependencies: 279 203 2579
-- Name: ts_account_contacts; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_contacts BEFORE UPDATE ON account_contacts FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2558 (class 2620 OID 26840)
-- Dependencies: 279 185 2579
-- Name: ts_account_installationdata; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_installationdata BEFORE UPDATE ON account_installationdata FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2560 (class 2620 OID 26841)
-- Dependencies: 279 189 2579
-- Name: ts_account_location; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_location BEFORE UPDATE ON account_location FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2561 (class 2620 OID 26842)
-- Dependencies: 279 191 2579
-- Name: ts_account_notifications; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_notifications BEFORE UPDATE ON account_notifications FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2562 (class 2620 OID 26843)
-- Dependencies: 279 193 2579
-- Name: ts_account_notifications_eventtype; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_notifications_eventtype BEFORE UPDATE ON account_notifications_eventtype FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2577 (class 2620 OID 26844)
-- Dependencies: 279 224 2579
-- Name: ts_account_notifications_group; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_notifications_group BEFORE UPDATE ON account_notifications_group FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2569 (class 2620 OID 26845)
-- Dependencies: 279 205 2579
-- Name: ts_account_phones_trigger_alarm; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_phones_trigger_alarm BEFORE UPDATE ON account_phones_trigger_alarm FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2568 (class 2620 OID 26846)
-- Dependencies: 279 204 2579
-- Name: ts_account_users; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_users BEFORE UPDATE ON account_users FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2563 (class 2620 OID 26847)
-- Dependencies: 279 195 2579
-- Name: ts_events; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_events BEFORE UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2564 (class 2620 OID 26848)
-- Dependencies: 279 196 2579
-- Name: ts_eventtypes; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_eventtypes BEFORE UPDATE ON eventtypes FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2576 (class 2620 OID 26849)
-- Dependencies: 222 279 2579
-- Name: ts_groups; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_groups BEFORE UPDATE ON groups FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2565 (class 2620 OID 26850)
-- Dependencies: 279 198 2579
-- Name: ts_keywords; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_keywords BEFORE UPDATE ON keywords FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2573 (class 2620 OID 26851)
-- Dependencies: 279 214 2579
-- Name: ts_notification_templates; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_notification_templates BEFORE UPDATE ON notification_templates FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2559 (class 2620 OID 26852)
-- Dependencies: 187 279 2579
-- Name: ts_panelmodel; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_panelmodel BEFORE UPDATE ON panelmodel FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


SET search_path = public, pg_catalog;

--
-- TOC entry 2572 (class 2620 OID 26822)
-- Dependencies: 279 212 2579
-- Name: ts_address_city; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_address_city BEFORE UPDATE ON address_city FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2570 (class 2620 OID 26824)
-- Dependencies: 279 208 2579
-- Name: ts_address_country; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_address_country BEFORE UPDATE ON address_country FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2574 (class 2620 OID 26825)
-- Dependencies: 216 279 2579
-- Name: ts_address_sector; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_address_sector BEFORE UPDATE ON address_sector FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2571 (class 2620 OID 26827)
-- Dependencies: 210 279 2579
-- Name: ts_address_states; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_address_states BEFORE UPDATE ON address_states FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2575 (class 2620 OID 26826)
-- Dependencies: 279 218 2579
-- Name: ts_address_subsector; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_address_subsector BEFORE UPDATE ON address_subsector FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2554 (class 2620 OID 26828)
-- Dependencies: 177 279 2579
-- Name: ts_blacklist; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_blacklist BEFORE UPDATE ON blacklist FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2547 (class 2620 OID 26829)
-- Dependencies: 279 165 2579
-- Name: ts_contacts; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_contacts BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2556 (class 2620 OID 26830)
-- Dependencies: 279 182 2579
-- Name: ts_incomingcalls; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_incomingcalls BEFORE UPDATE ON incomingcalls FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2566 (class 2620 OID 26831)
-- Dependencies: 201 279 2579
-- Name: ts_modem; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_modem BEFORE UPDATE ON modem FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2549 (class 2620 OID 26816)
-- Dependencies: 167 279 2579
-- Name: ts_phone; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_phone BEFORE UPDATE ON phones FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2548 (class 2620 OID 26832)
-- Dependencies: 279 167 2579
-- Name: ts_phones; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_phones BEFORE UPDATE ON phones FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2550 (class 2620 OID 26833)
-- Dependencies: 279 169 2579
-- Name: ts_provider; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_provider BEFORE UPDATE ON provider FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2551 (class 2620 OID 26834)
-- Dependencies: 171 279 2579
-- Name: ts_smsin; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_smsin BEFORE UPDATE ON smsin FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2552 (class 2620 OID 26835)
-- Dependencies: 279 173 2579
-- Name: ts_smsout; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_smsout BEFORE UPDATE ON smsout FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2555 (class 2620 OID 26836)
-- Dependencies: 279 180 2579
-- Name: ts_smsoutoptions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_smsoutoptions BEFORE UPDATE ON smsoutoptions FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2553 (class 2620 OID 26837)
-- Dependencies: 279 175 2579
-- Name: ts_whitelist; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_whitelist BEFORE UPDATE ON whitelist FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2541 (class 2606 OID 26561)
-- Dependencies: 184 2455 205 2579
-- Name: fk_accnt_trigg_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2542 (class 2606 OID 26566)
-- Dependencies: 2437 205 167 2579
-- Name: fk_accnt_trigg_idphone; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idphone FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2539 (class 2606 OID 26887)
-- Dependencies: 184 2455 204 2579
-- Name: fk_account_users_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2540 (class 2606 OID 26892)
-- Dependencies: 2435 204 165 2579
-- Name: fk_account_users_idcontact; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idcontact FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2530 (class 2606 OID 26491)
-- Dependencies: 185 2455 184 2579
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2532 (class 2606 OID 26510)
-- Dependencies: 184 189 2455 2579
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2537 (class 2606 OID 26921)
-- Dependencies: 2455 184 203 2579
-- Name: fk_idaccount_contacts; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idaccount_contacts FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2533 (class 2606 OID 26871)
-- Dependencies: 184 2455 191 2579
-- Name: fk_idaccount_notif; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idaccount_notif FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2538 (class 2606 OID 26926)
-- Dependencies: 2435 203 165 2579
-- Name: fk_idcontact_contacts; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idcontact_contacts FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2536 (class 2606 OID 26614)
-- Dependencies: 198 196 2479 2579
-- Name: fk_ideventtype_kw; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT fk_ideventtype_kw FOREIGN KEY (ideventtype) REFERENCES eventtypes(ideventtype) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2535 (class 2606 OID 26540)
-- Dependencies: 193 2471 191 2579
-- Name: fk_idnotifaccount_eetype; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT fk_idnotifaccount_eetype FOREIGN KEY (idnotifaccount) REFERENCES account_notifications(idnotifaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2531 (class 2606 OID 26496)
-- Dependencies: 187 185 2465 2579
-- Name: fk_idpanelmodel; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idpanelmodel FOREIGN KEY (idpanelmodel) REFERENCES panelmodel(idpanelmodel) ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- TOC entry 2534 (class 2606 OID 26876)
-- Dependencies: 191 2437 167 2579
-- Name: fk_idphone_notif; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idphone_notif FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- TOC entry 2545 (class 2606 OID 26667)
-- Dependencies: 216 212 2505 2579
-- Name: fk_idcity_sector; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_sector
    ADD CONSTRAINT fk_idcity_sector FOREIGN KEY (idcity) REFERENCES address_city(idcity) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2525 (class 2606 OID 26817)
-- Dependencies: 2435 167 165 2579
-- Name: fk_idcontact; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT fk_idcontact FOREIGN KEY (idcontact) REFERENCES contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2543 (class 2606 OID 26681)
-- Dependencies: 210 208 2497 2579
-- Name: fk_idcountry_states; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_states
    ADD CONSTRAINT fk_idcountry_states FOREIGN KEY (idcountry) REFERENCES address_country(idcountry) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2528 (class 2606 OID 26709)
-- Dependencies: 2437 177 167 2579
-- Name: fk_idphone; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT fk_idphone FOREIGN KEY (idphone) REFERENCES phones(idphone);


--
-- TOC entry 2526 (class 2606 OID 26805)
-- Dependencies: 167 175 2437 2579
-- Name: fk_idphone; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT fk_idphone FOREIGN KEY (idphone) REFERENCES phones(idphone);


--
-- TOC entry 2529 (class 2606 OID 26714)
-- Dependencies: 177 2439 169 2579
-- Name: fk_idprovider; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT fk_idprovider FOREIGN KEY (idprovider) REFERENCES provider(idprovider) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2527 (class 2606 OID 26810)
-- Dependencies: 2439 169 175 2579
-- Name: fk_idprovider; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT fk_idprovider FOREIGN KEY (idprovider) REFERENCES provider(idprovider) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2546 (class 2606 OID 26696)
-- Dependencies: 218 216 2511 2579
-- Name: fk_idsector; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_subsector
    ADD CONSTRAINT fk_idsector FOREIGN KEY (idsector) REFERENCES address_sector(idsector) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2544 (class 2606 OID 26644)
-- Dependencies: 210 212 2501 2579
-- Name: fk_idstate_city; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_city
    ADD CONSTRAINT fk_idstate_city FOREIGN KEY (idstate) REFERENCES address_states(idstate) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2586 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-01-26 02:54:18 ECT

--
-- PostgreSQL database dump complete
--

