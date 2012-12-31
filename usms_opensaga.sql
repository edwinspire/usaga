--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.7
-- Dumped by pg_dump version 9.1.7
-- Started on 2012-12-31 08:09:24 ECT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 7 (class 2615 OID 16964)
-- Name: opensaga; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA opensaga;


--
-- TOC entry 2373 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA opensaga; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA opensaga IS 'Esquema de detos de OpenSAGA';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 297 (class 1255 OID 26932)
-- Dependencies: 7 778
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
-- TOC entry 2374 (class 0 OID 0)
-- Dependencies: 297
-- Name: FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) IS 'Agrega, edita y elimina contactos de una cuenta.';


--
-- TOC entry 299 (class 1255 OID 26948)
-- Dependencies: 7 778
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
-- TOC entry 275 (class 1255 OID 25923)
-- Dependencies: 7 778
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
-- TOC entry 2375 (class 0 OID 0)
-- Dependencies: 275
-- Name: FUNCTION fun_account_event_notifications_sms(); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_event_notifications_sms() IS 'Genere notificaciones (sms) segun se haya programado para cada cliente.';


--
-- TOC entry 278 (class 1255 OID 26359)
-- Dependencies: 7 778
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
-- TOC entry 2376 (class 0 OID 0)
-- Dependencies: 278
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
-- TOC entry 286 (class 1255 OID 26854)
-- Dependencies: 7 778
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
-- TOC entry 269 (class 1255 OID 26946)
-- Dependencies: 7 778
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
-- TOC entry 298 (class 1255 OID 26944)
-- Dependencies: 7 778
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
-- TOC entry 289 (class 1255 OID 26870)
-- Dependencies: 7 778
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
-- TOC entry 2377 (class 0 OID 0)
-- Dependencies: 289
-- Name: FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) IS 'Chequea que el idphone pasado como parametro pertenesca a un usuario de la cuenta, caso contrario lo elimina.
Devuelve true si es usuario y false si no lo es.';


--
-- TOC entry 291 (class 1255 OID 26420)
-- Dependencies: 7 778
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
-- TOC entry 2378 (class 0 OID 0)
-- Dependencies: 291
-- Name: FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text) IS 'Agregar / elimina los numeros autorizados a disparar la alarma. Solo numeros de usuarios del sistema son permitidos';


--
-- TOC entry 245 (class 1255 OID 17933)
-- Dependencies: 7 778
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
-- TOC entry 2379 (class 0 OID 0)
-- Dependencies: 245
-- Name: FUNCTION fun_account_search_name(innameaccount text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_search_name(innameaccount text) IS 'Devuelve el idaccount de la cuenta que tiene el nombre pasado como parametro, si no hay cuentas con ese nombre devuelve 0, devuelve -1 en caso de falla';


--
-- TOC entry 246 (class 1255 OID 17934)
-- Dependencies: 778 7
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
-- TOC entry 2380 (class 0 OID 0)
-- Dependencies: 246
-- Name: FUNCTION fun_account_search_number(innumberaccount text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_search_number(innumberaccount text) IS 'Busca el idaccount basado en el numero pasado como parametro';


--
-- TOC entry 270 (class 1255 OID 26378)
-- Dependencies: 778 7
-- Name: fun_account_table(integer, boolean, text, text, integer, integer, integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outreturn integer, OUT outpgmsg text) RETURNS record
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

IF IdAccountSearchByName <= 0 OR inidaccount = 0 THEN

CASE
    WHEN inidaccount = 0 THEN

-- Chequeamo que el numero de la cuenta no se repita, si lo hace buscamos el siguiente numero disponible
WHILE opensaga.fun_account_search_number(inaccount) > 0 LOOP
    inaccount := initialaccount||'('||i::text||')';
i := i+1;
END LOOP;

        -- Nuevo registro
INSERT INTO opensaga.account (partition, enable, account, name, type, dateload, note, idgroup) VALUES (inpartition, inenable, inaccount, inname, intype, now(), innote, inidgroup) RETURNING idaccount INTO outreturn;       
outpgmsg := 'Nueva cuenta almacenda. idaccount = '||outreturn::TEXT;
INSERT INTO opensaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent) VALUES (now(), inidaccount, 'SYS', 100, outpgmsg, 79, now());
    WHEN inidaccount > 0 THEN
        -- Actualia registro
UPDATE opensaga.account SET partition = inpartition, enable = inenable, account = inaccount, name = inname, type = intype, note = innote, idgroup = inidgroup WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Actualizada la cuenta idaccount = '||outreturn::TEXT;
INSERT INTO opensaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent) VALUES (now(), inidaccount, 'SYS', 100, outpgmsg, 78, now());
        WHEN inidaccount < 0 THEN
        -- Eliminamos el registro si existe
IF EXISTS(SELECT account FROM opensaga.account WHERE idaccount = abs(inidaccount)) THEN
DELETE FROM  opensaga.account WHERE idaccount = abs(inidaccount);
outpgmsg := 'Registro idaccount '|| abs(inidaccount) ||' eliminado.';
outreturn := abs(inidaccount);
END IF;
END CASE;

ELSE
outpgmsg := 'El nombre ['|| inname::text ||'] y esta siendo utilizado por otra cuenta.';
outreturn := -1;
END IF;

EXCEPTION
WHEN UNIQUE_VIOLATION THEN
outpgmsg := SQLERRM;

RETURN;
END;$$;


--
-- TOC entry 2381 (class 0 OID 0)
-- Dependencies: 270
-- Name: FUNCTION fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outreturn integer, OUT outpgmsg text) IS 'Crea, actualiza, elimina registros de la tabla account.
0: algo falla
> 0: idaccount';


--
-- TOC entry 277 (class 1255 OID 26412)
-- Dependencies: 7 778
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
-- TOC entry 288 (class 1255 OID 26867)
-- Dependencies: 778 7
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
-- TOC entry 273 (class 1255 OID 25922)
-- Dependencies: 7 778
-- Name: fun_auto_process_events(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_auto_process_events() RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
PERFORM opensaga.fun_account_event_notifications_sms();

RETURN TRUE;
END;$$;


--
-- TOC entry 2382 (class 0 OID 0)
-- Dependencies: 273
-- Name: FUNCTION fun_auto_process_events(); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_auto_process_events() IS 'Procesa los eventos:
Envia notificaciones basados en los eventos y configuraciones del sistema';


--
-- TOC entry 248 (class 1255 OID 17544)
-- Dependencies: 7 778
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
-- TOC entry 2383 (class 0 OID 0)
-- Dependencies: 248
-- Name: FUNCTION fun_eventtype_default(inid integer, inname text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_eventtype_default(inid integer, inname text) IS 'Funcion usada internamente por opesaga para reflejar los EventType usados por el sistema.';


--
-- TOC entry 284 (class 1255 OID 26416)
-- Dependencies: 778 7
-- Name: fun_generate_test_report(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN


RETURN;
END;$$;


--
-- TOC entry 2384 (class 0 OID 0)
-- Dependencies: 284
-- Name: FUNCTION fun_generate_test_report(OUT outeventsgenerated integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) IS 'Genera los eventos de reporte de prueba enviados a los clientes.';


--
-- TOC entry 274 (class 1255 OID 26131)
-- Dependencies: 778 7
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
-- TOC entry 2385 (class 0 OID 0)
-- Dependencies: 274
-- Name: FUNCTION fun_get_priority_from_ideventtype(inideventtype integer); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_get_priority_from_ideventtype(inideventtype integer) IS 'Devuelve la prioridad segun el ideventtype';


--
-- TOC entry 276 (class 1255 OID 26215)
-- Dependencies: 778 7
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
-- TOC entry 2386 (class 0 OID 0)
-- Dependencies: 276
-- Name: FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text) IS 'Genera el texto del mensaje que se enviara como notificcion';


--
-- TOC entry 272 (class 1255 OID 25921)
-- Dependencies: 778 7
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
-- TOC entry 2387 (class 0 OID 0)
-- Dependencies: 272
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
-- TOC entry 283 (class 1255 OID 26415)
-- Dependencies: 778 7
-- Name: fun_receiver_from_incomingsmss(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION fun_receiver_from_incomingsmss(OUT outsmss integer, OUT outeventsgenerated integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN


RETURN;
END;$$;


--
-- TOC entry 293 (class 1255 OID 26920)
-- Dependencies: 7 778
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
-- TOC entry 2388 (class 0 OID 0)
-- Dependencies: 293
-- Name: FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) IS 'Vista de los tipos de eventos habilitados para un determinado idaccountnotif';


--
-- TOC entry 261 (class 1255 OID 26939)
-- Dependencies: 7 778
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
-- TOC entry 253 (class 1255 OID 26915)
-- Dependencies: 7 778
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
-- TOC entry 262 (class 1255 OID 26938)
-- Dependencies: 7 778
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
-- TOC entry 271 (class 1255 OID 26417)
-- Dependencies: 7 778
-- Name: hearbeat(); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION hearbeat() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$BEGIN

INSERT INTO opensaga.events (code, priority, description, ideventtype) VALUES ('SYS', 100, 'Hear Beat Receiver', 83);

RETURN now();
END;$$;


--
-- TOC entry 2389 (class 0 OID 0)
-- Dependencies: 271
-- Name: FUNCTION hearbeat(); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION hearbeat() IS 'Genera un evento de funcionmiento de la receptora';


--
-- TOC entry 294 (class 1255 OID 26931)
-- Dependencies: 778 7
-- Name: xxxfun_account_contacts_table(integer, integer, integer, boolean, text, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN


IF EXISTS(SELECT * FROM opensaga.account WHERE idaccount = inidaccount) AND EXISTS(SELECT * FROM contacts WHERE idcontact = abs(inidcontact)) THEN

IF inidcontact > 0 THEN

IF EXISTS(SELECT * FROM opensaga.account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact) THEN
-- Actualizamos
UPDATE opensaga.account_contacts SET priority = inpriority, enable = inenable, appointment = inappointmente, note = innote WHERE idaccount = inidaccount AND idcontact = inidcontact RETURNING idcontact INTO outreturn;
outpgmsg := 'Registro actualizado';
ELSE
-- Creamos nuevo
INSERT INTO opensaga.account_contacts (idcontact, idaccount, enable, priority, appointment, note) VALUES (inidcontact, inidaccount, inenable, inpriority, inappointment, innote) RETURNING idcontact INTO outreturn;
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

RETURN;
END;

$$;


--
-- TOC entry 2390 (class 0 OID 0)
-- Dependencies: 294
-- Name: FUNCTION xxxfun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION xxxfun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, OUT outreturn integer, OUT outpgmsg text) IS 'Agrega, edita, elimina contactos de una cuenta';


--
-- TOC entry 260 (class 1255 OID 17943)
-- Dependencies: 7 778
-- Name: xxxfun_account_insert_update(integer, integer, boolean, text, text, integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text) RETURNS integer
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

RETURN Retorno;
END;$$;


--
-- TOC entry 2391 (class 0 OID 0)
-- Dependencies: 260
-- Name: FUNCTION xxxfun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION xxxfun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text) IS 'Funcion inserta o actualiza registros de la tabla accounts. Realiza verificacion de datos antes de realizar la operacion.
Si inid es mayor que 1 actualiza el registro, caso contrario cre uno nuevo
Devuelve:
el id de la cuenta
0  No se ha realizado ninguna accion
-1 El nombre de la cuenta ya existe
-2 El numero de la cuenta ya existe
-3 Imposible crear nueva cuenta, account o name ya estan siendo usados
';


--
-- TOC entry 290 (class 1255 OID 26913)
-- Dependencies: 778 7
-- Name: xxxfun_account_notif_phones(integer, integer); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_notif_phones(inidaccount integer, inidphone integer, OUT idnotifcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT priority integer, OUT call boolean, OUT sms boolean, OUT smstext text, OUT note text, OUT ts timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

--CursorViewContactsPhonesAddress CURSOR FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
CursorViewContactsPhonesAddress refcursor; 

ROWDATAViewContact   public.view_contacts_phones%ROWTYPE;
ROWDATAAccNotif   opensaga.account_notifications%ROWTYPE;

inidcontact INTEGER DEFAULT 0;

BEGIN

SELECT phones.idcontact INTO inidcontact FROM phones WHERE phones.idphone = inidphone LIMIT 1;

OPEN CursorViewContactsPhonesAddress FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
    loop    

        FETCH CursorViewContactsPhonesAddress INTO ROWDATAViewContact;
        EXIT WHEN NOT FOUND;

IF EXISTS(SELECT opensaga.account_notifications.idnotifaccount FROM opensaga.account_notifications WHERE opensaga.account_notifications.idaccount = inidaccount AND opensaga.account_notifications.idphone = ROWDATAViewContact.idphone LIMIT 1) THEN
SELECT * INTO ROWDATAAccNotif FROM opensaga.account_notifications WHERE opensaga.account_notifications.idaccount = inidaccount AND opensaga.account_notifications.idphone = ROWDATAViewContact.idphone LIMIT 1;
RETURN QUERY SELECT ROWDATAAccNotif.idnotifaccount::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAViewContact.address::text, ROWDATAAccNotif.priority::integer, ROWDATAAccNotif.call::boolean, ROWDATAAccNotif.sms::boolean, ROWDATAAccNotif.smstext::text, ROWDATAAccNotif.note::text, ROWDATAAccNotif.ts::timestamp without time zone;
ELSE
RETURN QUERY SELECT 0::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAViewContact.address::text, '0'::integer, 'false'::boolean, 'false'::boolean, ''::text, ''::text, '1990-01-01 00:00'::timestamp without time zone;
END IF;

--UPDATE smsout SET process = 5, idport = FirstCurrentIdPort, dateprocess = now()  WHERE idsmsout = SMSOUTROWDATA.idsmsout;

    end loop;
    CLOSE CursorViewContactsPhonesAddress;

END
$$;


--
-- TOC entry 279 (class 1255 OID 26355)
-- Dependencies: 778 7
-- Name: xxxfun_account_table(integer, boolean, text, text, integer, integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inpartition integer, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outidaccount := 0;
outpgmsg := 'Ninguna operacion realizada';

CASE
    WHEN inidaccount = 0 THEN
        -- Nuevo registro
INSERT INTO opensaga.account (partition, enable, account, name, type, dateload, note) VALUES (inpartition, inenable, inaccount, inname, intype, now(), innote) RETURNING idaccount INTO outidaccount;       
outpgmsg := 'Nueva cuenta almacenda. idaccount = '||outidaccount::TEXT;
    WHEN inidaccount > 0 THEN
        -- Actualia registro
UPDATE opensaga.account SET partition = inpartition, enable = inenable, account = inaccount, name = inname, type = intype, note = innote, tabletimestamp = now() WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outidaccount;
outpgmsg := 'Actualizada la cuenta idaccount = '||outidaccount::TEXT;
        WHEN inidaccount < 0 THEN
        -- Eliminamos el registro si existe
IF EXISTS(SELECT account FROM opensaga.account WHERE idaccount = abs(inidaccount)) THEN
DELETE FROM  opensaga.account WHERE idaccount = abs(inidaccount);
outpgmsg := 'Registro idaccount '|| abs(inidaccount) ||' eliminado.';
outidaccount := abs(inidaccount);
END IF;
END CASE;


EXCEPTION
WHEN UNIQUE_VIOLATION THEN
outpgmsg := SQLERRM;

RETURN;
END;$$;


--
-- TOC entry 2392 (class 0 OID 0)
-- Dependencies: 279
-- Name: FUNCTION xxxfun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inpartition integer, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION xxxfun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inpartition integer, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) IS 'Crea, actualiza, elimina registros de la tabla account.
0: Ningun proceso realizado
> 0: idaccount';


--
-- TOC entry 280 (class 1255 OID 26374)
-- Dependencies: 778 7
-- Name: xxxfun_account_table(integer, boolean, text, text, integer, integer, integer, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outidaccount := 0;
outpgmsg := 'Ninguna operacion realizada';

CASE
    WHEN inidaccount = 0 THEN
        -- Nuevo registro
INSERT INTO opensaga.account (partition, enable, account, name, type, dateload, note, idgroup) VALUES (inpartition, inenable, inaccount, inname, intype, now(), innote, inidgroup) RETURNING idaccount INTO outidaccount;       
outpgmsg := 'Nueva cuenta almacenda. idaccount = '||outidaccount::TEXT;
    WHEN inidaccount > 0 THEN
        -- Actualia registro
UPDATE opensaga.account SET partition = inpartition, enable = inenable, account = inaccount, name = inname, type = intype, note = innote, idgroup = inidgroup, tabletimestamp = now() WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outidaccount;
outpgmsg := 'Actualizada la cuenta idaccount = '||outidaccount::TEXT;
        WHEN inidaccount < 0 THEN
        -- Eliminamos el registro si existe
IF EXISTS(SELECT account FROM opensaga.account WHERE idaccount = abs(inidaccount)) THEN
DELETE FROM  opensaga.account WHERE idaccount = abs(inidaccount);
outpgmsg := 'Registro idaccount '|| abs(inidaccount) ||' eliminado.';
outidaccount := abs(inidaccount);
END IF;
END CASE;


EXCEPTION
WHEN UNIQUE_VIOLATION THEN
outpgmsg := SQLERRM;

RETURN;
END;$$;


--
-- TOC entry 2393 (class 0 OID 0)
-- Dependencies: 280
-- Name: FUNCTION xxxfun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION xxxfun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) IS 'Crea, actualiza, elimina registros de la tabla account.
0: algo falla
> 0: idaccount';


--
-- TOC entry 282 (class 1255 OID 26413)
-- Dependencies: 778 7
-- Name: xxxfun_account_users_add(integer, integer); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_users_add(inidaccount integer, inidcontact integer, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
BEGIN
outreturn := 0;
outpgmsg := '';
IF NOT EXISTS(SELECT * FROM opensaga.account_users WHERE idaccount = inidaccount AND idcontact = inidcontact) AND EXISTS(SELECT * FROM opensaga.account WHERE idaccount = inidaccount)  AND EXISTS(SELECT * FROM contacts  WHERE idcontact = inidcontact) THEN
-- eL REGISTRO NO EXISTE E ID ACCOUNT E idcontact existen
INSERT INTO opensaga.account_users (idaccount, idcontact) VALUES (inidaccount, inidcontact);
outreturn := 1;
outpgmsg := 'Nuevo usuario insertado';
ELSE
outreturn := 0;
outpgmsg := 'El usuario no pudo ser registrado, posiblemente el usuario ya existe o idaccount o idcontact no existen';
END IF;

RETURN;
END;$$;


--
-- TOC entry 2394 (class 0 OID 0)
-- Dependencies: 282
-- Name: FUNCTION xxxfun_account_users_add(inidaccount integer, inidcontact integer, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION xxxfun_account_users_add(inidaccount integer, inidcontact integer, OUT outreturn integer, OUT outpgmsg text) IS 'Agrega un nuevo usuario a la cuenta';


--
-- TOC entry 281 (class 1255 OID 26410)
-- Dependencies: 778 7
-- Name: xxxfun_account_users_table(integer, integer, text, boolean, integer, text, text, text); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_account_users_table(inidaccount integer, inidcontact integer, inappointment text, inenable boolean, innumuser integer, inkeyword text, inpwd text, innote text, OUT outreturn integer, OUT outmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outreturn := 0;
outmsg := '';

IF EXISTS(SELECT idaccount FROM opensaga.account WHERE idaccount = inidaccount) AND EXISTS(SELECT idcontact FROM contacts WHERE idcontact = inidcontact) THEN

CASE
	WHEN EXISTS(SELECT idaccount FROM opensaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount) THEN
	-- El registro ya existe, actualizarlo
	UPDATE opensaga.account_users SET appointment = inappointment, enable_as_user = inenable, keyword = inkeyword, pwd = inpwd, numuser = innumuser, note_user = innote  WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount;
outreturn := abs(inidcontact);
outmsg := 'Registro actualizado';

	WHEN NOT EXISTS(SELECT idaccount FROM opensaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount) THEN
	-- El registro no existe, crearlo
INSERT INTO opensaga.account_users (idaccount, idcontact, appointment, enable_as_user, keyword, pwd, numuser, note_user) VALUES (inidaccount, inidcontact, inappointment, inenable, inkeyword, inpwd, innumuser, innote);
outreturn := abs(inidcontact);
outmsg := 'Registro insertado';

	WHEN inidcontact < 0 THEN
	-- Eliminamos el registro
	DELETE  FROM opensaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount;
outreturn := abs(inidcontact);
outmsg := 'Registro eliminado';
	END CASE;



ELSE
-- 
outmsg := 'idaccount '||inidaccount::text||' no existe';
outreturn := -1;
END IF;



RETURN;
END;



$$;


--
-- TOC entry 292 (class 1255 OID 26919)
-- Dependencies: 778 7
-- Name: xxxfun_view_account_contact_notif_eventtypes(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxfun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$DECLARE

CursorEventtypes refcursor; 

ROWDATAEventType   opensaga.eventtypes%ROWTYPE;
ROWDATANET   opensaga.account_notifications_eventtype%ROWTYPE;

InternalIdNotifAccount INTEGER DEFAULT 0;


BEGIN

SELECT opensaga.account_notifications.idnotifaccount INTO InternalIdNotifAccount FROM opensaga.account_notifications WHERE idphone = inidphone AND idaccount = inidaccount LIMIT 1;

OPEN CursorEventtypes FOR SELECT opensaga.eventtypes.ideventtype, opensaga.eventtypes.label FROM opensaga.eventtypes ORDER BY label;
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
RETURN QUERY SELECT '0'::integer, ROWDATAEventType.ideventtype::integer, 'false'::boolean, encode(ROWDATAEventType.label::bytea, 'base64'), '1900-01-01 00:00'::timestamp without time zone;
ELSE
RETURN QUERY SELECT '0'::integer, ROWDATAEventType.ideventtype::integer, 'false'::boolean, ROWDATAEventType.label::text, '1900-01-01 00:00'::timestamp without time zone;
END IF;



END IF;

    end loop;
    CLOSE CursorEventtypes;

END
$$;


--
-- TOC entry 2395 (class 0 OID 0)
-- Dependencies: 292
-- Name: FUNCTION xxxfun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text); Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON FUNCTION xxxfun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text) IS 'Vista de los tipos de eventos habilitados para un determinado idaccountnotif';


--
-- TOC entry 252 (class 1255 OID 26914)
-- Dependencies: 778 7
-- Name: xxxxxfun_account_notif_phones(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: -
--

CREATE FUNCTION xxxxxfun_account_notif_phones(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT priority integer, OUT call boolean, OUT sms boolean, OUT smstext text, OUT note text, OUT ts timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

--CursorViewContactsPhonesAddress CURSOR FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
CursorViewContactsPhonesAddress refcursor; 

ROWDATAViewContact   public.view_contacts_phones%ROWTYPE;
ROWDATAAccNotif   opensaga.account_notifications%ROWTYPE;

inidcontact INTEGER DEFAULT 0;

BEGIN

SELECT phones.idcontact INTO inidcontact FROM phones WHERE phones.idphone = inidphone LIMIT 1;

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

END
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 184 (class 1259 OID 16976)
-- Dependencies: 2155 2156 2157 2158 2159 2160 2161 2162 2163 1711 7
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
-- TOC entry 2396 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE account; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account IS 'Cuenta de usuario';


--
-- TOC entry 2397 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN account.account; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account.account IS 'Numero de cuenta en 4 digitos';


--
-- TOC entry 203 (class 1259 OID 17772)
-- Dependencies: 2257 2258 2259 2260 2261 2262 2263 7 1709
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
-- TOC entry 2398 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE account_contacts; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_contacts IS 'Usuarios del sistema, tiene acceso al sistema ';


--
-- TOC entry 2399 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN account_contacts.prioritycontact; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_contacts.prioritycontact IS 'Priordad de comunicar novedad a este contacto';


--
-- TOC entry 183 (class 1259 OID 16974)
-- Dependencies: 7 184
-- Name: account_idaccount_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE account_idaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2400 (class 0 OID 0)
-- Dependencies: 183
-- Name: account_idaccount_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_idaccount_seq OWNED BY account.idaccount;


--
-- TOC entry 185 (class 1259 OID 17049)
-- Dependencies: 2164 2165 2166 2167 2168 2169 2170 2171 2172 7
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
-- TOC entry 2401 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE account_installationdata; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_installationdata IS 'Datos basico acerca de la instalacion del sistema de alarma';


--
-- TOC entry 2402 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN account_installationdata.idaccount; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_installationdata.idaccount IS 'idaccount a la que pertenecen estos datos';


--
-- TOC entry 2403 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN account_installationdata.installercode; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_installationdata.installercode IS 'Codigo de instalador del panel de control';


--
-- TOC entry 189 (class 1259 OID 17143)
-- Dependencies: 2180 2181 2182 2183 2184 2185 2186 1711 7
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
-- TOC entry 2404 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE account_location; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_location IS 'Localizacion de la cuenta';


--
-- TOC entry 2405 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN account_location.geox; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_location.geox IS 'Ubicacion georeferenciada';


--
-- TOC entry 2406 (class 0 OID 0)
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
-- TOC entry 2407 (class 0 OID 0)
-- Dependencies: 188
-- Name: account_location_idlocation_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_location_idlocation_seq OWNED BY account_location.idlocation;


--
-- TOC entry 191 (class 1259 OID 17176)
-- Dependencies: 2188 2189 2190 2191 2192 2193 2194 2195 1711 7 1711
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
-- TOC entry 2408 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE account_notifications; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE account_notifications IS 'Contactos a donde se enviara las notificaciones en caso de alarma';


--
-- TOC entry 193 (class 1259 OID 17261)
-- Dependencies: 2197 2198 2199 7
-- Name: account_notifications_eventtype; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_notifications_eventtype (
    idnotifphoneeventtype bigint NOT NULL,
    idnotifaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2409 (class 0 OID 0)
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
-- TOC entry 2410 (class 0 OID 0)
-- Dependencies: 192
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq OWNED BY account_notifications_eventtype.idnotifphoneeventtype;


--
-- TOC entry 227 (class 1259 OID 26445)
-- Dependencies: 2292 2293 2294 7
-- Name: account_notifications_group; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE account_notifications_group (
    idaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2411 (class 0 OID 0)
-- Dependencies: 227
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
-- TOC entry 2412 (class 0 OID 0)
-- Dependencies: 190
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE account_notifications_idnotifaccount_seq OWNED BY account_notifications.idnotifaccount;


--
-- TOC entry 206 (class 1259 OID 18107)
-- Dependencies: 2276 2277 2278 2279 2280 2281 2282 1711 7
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
-- TOC entry 205 (class 1259 OID 18087)
-- Dependencies: 2270 2271 2272 2273 2274 203 7 1711 1709 1711
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
-- TOC entry 2413 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN account_users.numuser; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN account_users.numuser IS 'Numero de usuario';


--
-- TOC entry 195 (class 1259 OID 17289)
-- Dependencies: 2200 2201 2202 2203 2204 2205 2206 2207 2209 2210 2211 2212 2213 2214 2215 2216 2217 2218 2219 2220 7 1711
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
-- TOC entry 2414 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE events; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE events IS 'Eventos del sistema
TODO: Ver la posibilidad de crear llave unica usando todos los campos';


--
-- TOC entry 2415 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN events.dateload; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN events.dateload IS 'Fecha de ingreso del evento';


--
-- TOC entry 202 (class 1259 OID 17714)
-- Dependencies: 2254 1711 7 195
-- Name: events_generated_by_calls; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE events_generated_by_calls (
    idincall integer DEFAULT 0 NOT NULL
)
INHERITS (events);


--
-- TOC entry 2416 (class 0 OID 0)
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
-- TOC entry 2417 (class 0 OID 0)
-- Dependencies: 194
-- Name: events_idevent_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE events_idevent_seq OWNED BY events.idevent;


--
-- TOC entry 196 (class 1259 OID 17352)
-- Dependencies: 2221 2222 2223 2224 2225 2226 2227 2228 7
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
-- TOC entry 2418 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE eventtypes; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE eventtypes IS 'Tipos de eventos. Enumeracion interna desde OpenSAGA, usar unicamente los que no estan reservados.';


--
-- TOC entry 2419 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN eventtypes.name; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON COLUMN eventtypes.name IS 'Nombre del evento';


--
-- TOC entry 225 (class 1259 OID 26381)
-- Dependencies: 2288 2289 2290 2291 1711 1711 7
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
-- TOC entry 224 (class 1259 OID 26379)
-- Dependencies: 225 7
-- Name: groups_idgroup_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE groups_idgroup_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2420 (class 0 OID 0)
-- Dependencies: 224
-- Name: groups_idgroup_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE groups_idgroup_seq OWNED BY groups.idgroup;


--
-- TOC entry 198 (class 1259 OID 17389)
-- Dependencies: 2230 2231 2232 2233 2234 1711 7
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
-- TOC entry 2421 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE keywords; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE keywords IS 'Lista de palabras claves a reconocer en los sms';


--
-- TOC entry 197 (class 1259 OID 17387)
-- Dependencies: 7 198
-- Name: keywords_idkeyword_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE keywords_idkeyword_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2422 (class 0 OID 0)
-- Dependencies: 197
-- Name: keywords_idkeyword_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE keywords_idkeyword_seq OWNED BY keywords.idkeyword;


--
-- TOC entry 216 (class 1259 OID 26202)
-- Dependencies: 2284 2285 2286 7 1709 1709
-- Name: notification_templates; Type: TABLE; Schema: opensaga; Owner: -; Tablespace: 
--

CREATE TABLE notification_templates (
    idnotiftempl bigint NOT NULL,
    description text COLLATE pg_catalog."C.UTF-8" DEFAULT 'description'::text NOT NULL,
    message text COLLATE pg_catalog."C.UTF-8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2423 (class 0 OID 0)
-- Dependencies: 216
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
-- TOC entry 215 (class 1259 OID 26200)
-- Dependencies: 216 7
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE notification_templates_idnotiftempl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2424 (class 0 OID 0)
-- Dependencies: 215
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE notification_templates_idnotiftempl_seq OWNED BY notification_templates.idnotiftempl;


--
-- TOC entry 187 (class 1259 OID 17108)
-- Dependencies: 2174 2175 2176 2177 2178 7
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
-- TOC entry 2425 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE panelmodel; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON TABLE panelmodel IS 'Modelos de paneles de control de alarma';


--
-- TOC entry 186 (class 1259 OID 17106)
-- Dependencies: 187 7
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE; Schema: opensaga; Owner: -
--

CREATE SEQUENCE panelmodel_idpanelmodel_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2426 (class 0 OID 0)
-- Dependencies: 186
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: -
--

ALTER SEQUENCE panelmodel_idpanelmodel_seq OWNED BY panelmodel.idpanelmodel;


--
-- TOC entry 231 (class 1259 OID 26909)
-- Dependencies: 2153 1709 7
-- Name: view_account_contacts; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_account_contacts AS
    SELECT DISTINCT ON (tabla.idaccount, tabla.idcontact) tabla.idaccount, tabla.idcontact, tabla.enable, tabla.firstname, tabla.lastname, tabla.prioritycontact, tabla.enable_as_contact, tabla.appointment, tabla.ts, tabla.note FROM (SELECT account_contacts.idaccount, contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment, account_contacts.ts, account_contacts.note FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact) ORDER BY account_contacts.ts DESC) tabla ORDER BY tabla.idaccount, tabla.idcontact, tabla.ts DESC;


--
-- TOC entry 226 (class 1259 OID 26425)
-- Dependencies: 2149 7 1711
-- Name: view_account_phones_trigger_alarm; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_account_phones_trigger_alarm AS
    SELECT account.idaccount, account.enable, account.account, account.name, account.type, account_phones_trigger_alarm.idphone, (SELECT phones.phone FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS phone, (SELECT phones.idprovider FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS idprovider, (SELECT phones.address FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS address, account_phones_trigger_alarm.enable AS trigger_enable, account_phones_trigger_alarm.fromcall, account_phones_trigger_alarm.fromsms FROM account, account_phones_trigger_alarm WHERE (account.idaccount = account_phones_trigger_alarm.idaccount);


--
-- TOC entry 2427 (class 0 OID 0)
-- Dependencies: 226
-- Name: VIEW view_account_phones_trigger_alarm; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON VIEW view_account_phones_trigger_alarm IS 'TODO: Cambiar la vista usando left join para mejorar desempeño';


--
-- TOC entry 208 (class 1259 OID 26127)
-- Dependencies: 2145 1711 1711 7
-- Name: view_account_users; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_account_users AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_users.idaccount, account_users.prioritycontact, account_users.enable AS enable_as_contact, account_users.appointment, account_users.enable_as_user, account_users.numuser, account_users.pwd, account_users.keyword FROM account_users, public.contacts WHERE (contacts.idcontact = account_users.idcontact);


--
-- TOC entry 223 (class 1259 OID 26345)
-- Dependencies: 2148 7
-- Name: view_events; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW view_events AS
    SELECT events.idevent, events.dateload, events.idaccount, account.partition, account.enable, account.account, account.name, account.type, events.code, events.zu, events.priority, events.description, events.ideventtype, (SELECT eventtypes.label FROM eventtypes WHERE (eventtypes.ideventtype = events.ideventtype)) AS eventtype, events.datetimeevent, events.process1, events.process2, events.process3, events.process4, events.process5, events.dateprocess1, events.dateprocess2, events.dateprocess4, events.dateprocess3, events.dateprocess5 FROM (events LEFT JOIN account ON ((events.idaccount = account.idaccount)));


--
-- TOC entry 229 (class 1259 OID 26897)
-- Dependencies: 2151 7
-- Name: xxview_account_contacts; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW xxview_account_contacts AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.idaccount, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment, account_contacts.ts FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact) ORDER BY account_contacts.ts DESC;


--
-- TOC entry 207 (class 1259 OID 26123)
-- Dependencies: 2144 7
-- Name: xxx_view_account_phones_trigger_alarm; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW xxx_view_account_phones_trigger_alarm AS
    SELECT account.idaccount, account.enable, account.account, account.name, account.type, account_phones_trigger_alarm.idphone, account_phones_trigger_alarm.enable AS trigger_enable, account_phones_trigger_alarm.fromcall, account_phones_trigger_alarm.fromsms FROM account, account_phones_trigger_alarm WHERE (account.idaccount = account_phones_trigger_alarm.idaccount);


--
-- TOC entry 2428 (class 0 OID 0)
-- Dependencies: 207
-- Name: VIEW xxx_view_account_phones_trigger_alarm; Type: COMMENT; Schema: opensaga; Owner: -
--

COMMENT ON VIEW xxx_view_account_phones_trigger_alarm IS 'Vista que muestra la lista de idphones que pueden disparar alarmas via telefonica o sms para cada cuenta.';


--
-- TOC entry 228 (class 1259 OID 26881)
-- Dependencies: 2150 7
-- Name: xxxview_account_contacts; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW xxxview_account_contacts AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.idaccount, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact);


--
-- TOC entry 230 (class 1259 OID 26901)
-- Dependencies: 2152 7
-- Name: xxxxxview_account_contacts; Type: VIEW; Schema: opensaga; Owner: -
--

CREATE VIEW xxxxxview_account_contacts AS
    SELECT DISTINCT ON (tabla.idaccount, tabla.idcontact) tabla.idaccount, tabla.idcontact, tabla.enable, tabla.firstname, tabla.lastname, tabla.prioritycontact, tabla.enable_as_contact, tabla.appointment, tabla.ts FROM (SELECT account_contacts.idaccount, contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment, account_contacts.ts FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact) ORDER BY account_contacts.ts DESC) tabla ORDER BY tabla.idaccount, tabla.idcontact, tabla.ts DESC;


--
-- TOC entry 2154 (class 2604 OID 16979)
-- Dependencies: 184 183 184
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account ALTER COLUMN idaccount SET DEFAULT nextval('account_idaccount_seq'::regclass);


--
-- TOC entry 2179 (class 2604 OID 17146)
-- Dependencies: 189 188 189
-- Name: idlocation; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_location ALTER COLUMN idlocation SET DEFAULT nextval('account_location_idlocation_seq'::regclass);


--
-- TOC entry 2187 (class 2604 OID 17179)
-- Dependencies: 190 191 191
-- Name: idnotifaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications ALTER COLUMN idnotifaccount SET DEFAULT nextval('account_notifications_idnotifaccount_seq'::regclass);


--
-- TOC entry 2196 (class 2604 OID 17264)
-- Dependencies: 193 192 193
-- Name: idnotifphoneeventtype; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications_eventtype ALTER COLUMN idnotifphoneeventtype SET DEFAULT nextval('account_notifications_eventtype_idnotifphoneeventtype_seq'::regclass);


--
-- TOC entry 2264 (class 2604 OID 18090)
-- Dependencies: 205 205
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2265 (class 2604 OID 18091)
-- Dependencies: 205 205
-- Name: idcontact; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN idcontact SET DEFAULT 0;


--
-- TOC entry 2266 (class 2604 OID 18092)
-- Dependencies: 205 205
-- Name: prioritycontact; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN prioritycontact SET DEFAULT 5;


--
-- TOC entry 2267 (class 2604 OID 18093)
-- Dependencies: 205 205
-- Name: enable; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN enable SET DEFAULT true;


--
-- TOC entry 2268 (class 2604 OID 18094)
-- Dependencies: 205 205
-- Name: appointment; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN appointment SET DEFAULT ''::text;


--
-- TOC entry 2269 (class 2604 OID 18095)
-- Dependencies: 205 205
-- Name: note; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN note SET DEFAULT ''::text;


--
-- TOC entry 2275 (class 2604 OID 26457)
-- Dependencies: 205 205
-- Name: ts; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2208 (class 2604 OID 17292)
-- Dependencies: 195 194 195
-- Name: idevent; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2246 (class 2604 OID 17717)
-- Dependencies: 202 202 194
-- Name: idevent; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2247 (class 2604 OID 17718)
-- Dependencies: 202 202
-- Name: dateload; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateload SET DEFAULT now();


--
-- TOC entry 2248 (class 2604 OID 17719)
-- Dependencies: 202 202
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2249 (class 2604 OID 17720)
-- Dependencies: 202 202
-- Name: code; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN code SET DEFAULT '0000'::text;


--
-- TOC entry 2250 (class 2604 OID 17721)
-- Dependencies: 202 202
-- Name: zu; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN zu SET DEFAULT 0;


--
-- TOC entry 2251 (class 2604 OID 17722)
-- Dependencies: 202 202
-- Name: priority; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN priority SET DEFAULT 5;


--
-- TOC entry 2252 (class 2604 OID 17723)
-- Dependencies: 202 202
-- Name: description; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN description SET DEFAULT ''::text;


--
-- TOC entry 2253 (class 2604 OID 17724)
-- Dependencies: 202 202
-- Name: ideventtype; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ideventtype SET DEFAULT 0;


--
-- TOC entry 2255 (class 2604 OID 18022)
-- Dependencies: 202 202
-- Name: datetimeevent; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN datetimeevent SET DEFAULT now();


--
-- TOC entry 2235 (class 2604 OID 25925)
-- Dependencies: 202 202
-- Name: process1; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process1 SET DEFAULT 0;


--
-- TOC entry 2236 (class 2604 OID 25942)
-- Dependencies: 202 202
-- Name: process2; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process2 SET DEFAULT 0;


--
-- TOC entry 2237 (class 2604 OID 25959)
-- Dependencies: 202 202
-- Name: process3; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process3 SET DEFAULT 0;


--
-- TOC entry 2238 (class 2604 OID 25976)
-- Dependencies: 202 202
-- Name: process4; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process4 SET DEFAULT 0;


--
-- TOC entry 2239 (class 2604 OID 25993)
-- Dependencies: 202 202
-- Name: process5; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process5 SET DEFAULT 0;


--
-- TOC entry 2240 (class 2604 OID 26010)
-- Dependencies: 202 202
-- Name: note; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN note SET DEFAULT ' '::text;


--
-- TOC entry 2241 (class 2604 OID 26033)
-- Dependencies: 202 202
-- Name: dateprocess1; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess1 SET DEFAULT now();


--
-- TOC entry 2242 (class 2604 OID 26050)
-- Dependencies: 202 202
-- Name: dateprocess2; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess2 SET DEFAULT now();


--
-- TOC entry 2243 (class 2604 OID 26067)
-- Dependencies: 202 202
-- Name: dateprocess3; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess3 SET DEFAULT now();


--
-- TOC entry 2244 (class 2604 OID 26084)
-- Dependencies: 202 202
-- Name: dateprocess4; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess4 SET DEFAULT now();


--
-- TOC entry 2245 (class 2604 OID 26101)
-- Dependencies: 202 202
-- Name: dateprocess5; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess5 SET DEFAULT now();


--
-- TOC entry 2256 (class 2604 OID 26572)
-- Dependencies: 202 202
-- Name: ts; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2287 (class 2604 OID 26384)
-- Dependencies: 224 225 225
-- Name: idgroup; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN idgroup SET DEFAULT nextval('groups_idgroup_seq'::regclass);


--
-- TOC entry 2229 (class 2604 OID 17392)
-- Dependencies: 197 198 198
-- Name: idkeyword; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY keywords ALTER COLUMN idkeyword SET DEFAULT nextval('keywords_idkeyword_seq'::regclass);


--
-- TOC entry 2283 (class 2604 OID 26205)
-- Dependencies: 216 215 216
-- Name: idnotiftempl; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY notification_templates ALTER COLUMN idnotiftempl SET DEFAULT nextval('notification_templates_idnotiftempl_seq'::regclass);


--
-- TOC entry 2173 (class 2604 OID 17111)
-- Dependencies: 186 187 187
-- Name: idpanelmodel; Type: DEFAULT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY panelmodel ALTER COLUMN idpanelmodel SET DEFAULT nextval('panelmodel_idpanelmodel_seq'::regclass);


--
-- TOC entry 2328 (class 2606 OID 18076)
-- Dependencies: 203 203 203 2370
-- Name: pk_account_contacts; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT pk_account_contacts PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2340 (class 2606 OID 26454)
-- Dependencies: 227 227 227 2370
-- Name: pk_account_notif_group; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications_group
    ADD CONSTRAINT pk_account_notif_group PRIMARY KEY (idaccount, ideventtype);


--
-- TOC entry 2332 (class 2606 OID 18120)
-- Dependencies: 206 206 206 2370
-- Name: pk_account_triggers_phones; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT pk_account_triggers_phones PRIMARY KEY (idaccount, idphone);


--
-- TOC entry 2330 (class 2606 OID 26886)
-- Dependencies: 205 205 205 2370
-- Name: pk_account_users; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT pk_account_users PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2296 (class 2606 OID 16987)
-- Dependencies: 184 184 2370
-- Name: pk_idaccount; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT pk_idaccount PRIMARY KEY (idaccount);


--
-- TOC entry 2318 (class 2606 OID 17295)
-- Dependencies: 195 195 2370
-- Name: pk_idevent; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT pk_idevent PRIMARY KEY (idevent);


--
-- TOC entry 2324 (class 2606 OID 17730)
-- Dependencies: 202 202 2370
-- Name: pk_idevent_from_call; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT pk_idevent_from_call PRIMARY KEY (idevent);


--
-- TOC entry 2320 (class 2606 OID 17362)
-- Dependencies: 196 196 2370
-- Name: pk_ideventtype; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eventtypes
    ADD CONSTRAINT pk_ideventtype PRIMARY KEY (ideventtype);


--
-- TOC entry 2336 (class 2606 OID 26392)
-- Dependencies: 225 225 2370
-- Name: pk_idgroup; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT pk_idgroup PRIMARY KEY (idgroup);


--
-- TOC entry 2302 (class 2606 OID 17061)
-- Dependencies: 185 185 2370
-- Name: pk_idinstallationdata; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT pk_idinstallationdata PRIMARY KEY (idinstallationdata);


--
-- TOC entry 2322 (class 2606 OID 17399)
-- Dependencies: 198 198 2370
-- Name: pk_idkeyword; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT pk_idkeyword PRIMARY KEY (idkeyword);


--
-- TOC entry 2308 (class 2606 OID 17156)
-- Dependencies: 189 189 2370
-- Name: pk_idlocation; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT pk_idlocation PRIMARY KEY (idlocation);


--
-- TOC entry 2312 (class 2606 OID 17182)
-- Dependencies: 191 191 2370
-- Name: pk_idnotifaccount; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT pk_idnotifaccount PRIMARY KEY (idnotifaccount);


--
-- TOC entry 2316 (class 2606 OID 17266)
-- Dependencies: 193 193 2370
-- Name: pk_idnotifphoneeventtype; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT pk_idnotifphoneeventtype PRIMARY KEY (idnotifphoneeventtype);


--
-- TOC entry 2334 (class 2606 OID 26212)
-- Dependencies: 216 216 2370
-- Name: pk_idnotiftempl; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_templates
    ADD CONSTRAINT pk_idnotiftempl PRIMARY KEY (idnotiftempl);


--
-- TOC entry 2306 (class 2606 OID 17119)
-- Dependencies: 187 187 2370
-- Name: pk_idpanelmodel; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY panelmodel
    ADD CONSTRAINT pk_idpanelmodel PRIMARY KEY (idpanelmodel);


--
-- TOC entry 2314 (class 2606 OID 17988)
-- Dependencies: 191 191 191 2370
-- Name: uni_acc_notyf_idacc_idphone; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT uni_acc_notyf_idacc_idphone UNIQUE (idaccount, idphone);


--
-- TOC entry 2298 (class 2606 OID 26363)
-- Dependencies: 184 184 2370
-- Name: uni_account_account; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_account UNIQUE (account);


--
-- TOC entry 2300 (class 2606 OID 17949)
-- Dependencies: 184 184 2370
-- Name: uni_account_name; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_name UNIQUE (name);


--
-- TOC entry 2326 (class 2606 OID 18043)
-- Dependencies: 202 202 202 202 202 2370
-- Name: uni_event_from_calls; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT uni_event_from_calls UNIQUE (idaccount, ideventtype, datetimeevent, idincall);


--
-- TOC entry 2304 (class 2606 OID 17073)
-- Dependencies: 185 185 2370
-- Name: uni_idaccount; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT uni_idaccount UNIQUE (idaccount);


--
-- TOC entry 2310 (class 2606 OID 17173)
-- Dependencies: 189 189 2370
-- Name: uni_idaccount_alocation; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT uni_idaccount_alocation UNIQUE (idaccount);


--
-- TOC entry 2338 (class 2606 OID 26394)
-- Dependencies: 225 225 2370
-- Name: uni_name_groups; Type: CONSTRAINT; Schema: opensaga; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT uni_name_groups UNIQUE (name);


--
-- TOC entry 2354 (class 2620 OID 26838)
-- Dependencies: 184 285 2370
-- Name: ts_account; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account BEFORE UPDATE ON account FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2363 (class 2620 OID 26839)
-- Dependencies: 285 203 2370
-- Name: ts_account_contacts; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_contacts BEFORE UPDATE ON account_contacts FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2355 (class 2620 OID 26840)
-- Dependencies: 285 185 2370
-- Name: ts_account_installationdata; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_installationdata BEFORE UPDATE ON account_installationdata FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2357 (class 2620 OID 26841)
-- Dependencies: 189 285 2370
-- Name: ts_account_location; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_location BEFORE UPDATE ON account_location FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2358 (class 2620 OID 26842)
-- Dependencies: 191 285 2370
-- Name: ts_account_notifications; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_notifications BEFORE UPDATE ON account_notifications FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2359 (class 2620 OID 26843)
-- Dependencies: 285 193 2370
-- Name: ts_account_notifications_eventtype; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_notifications_eventtype BEFORE UPDATE ON account_notifications_eventtype FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2368 (class 2620 OID 26844)
-- Dependencies: 285 227 2370
-- Name: ts_account_notifications_group; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_notifications_group BEFORE UPDATE ON account_notifications_group FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2365 (class 2620 OID 26845)
-- Dependencies: 206 285 2370
-- Name: ts_account_phones_trigger_alarm; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_phones_trigger_alarm BEFORE UPDATE ON account_phones_trigger_alarm FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2364 (class 2620 OID 26846)
-- Dependencies: 205 285 2370
-- Name: ts_account_users; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_account_users BEFORE UPDATE ON account_users FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2360 (class 2620 OID 26847)
-- Dependencies: 195 285 2370
-- Name: ts_events; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_events BEFORE UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2361 (class 2620 OID 26848)
-- Dependencies: 196 285 2370
-- Name: ts_eventtypes; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_eventtypes BEFORE UPDATE ON eventtypes FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2367 (class 2620 OID 26849)
-- Dependencies: 285 225 2370
-- Name: ts_groups; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_groups BEFORE UPDATE ON groups FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2362 (class 2620 OID 26850)
-- Dependencies: 285 198 2370
-- Name: ts_keywords; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_keywords BEFORE UPDATE ON keywords FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2366 (class 2620 OID 26851)
-- Dependencies: 285 216 2370
-- Name: ts_notification_templates; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_notification_templates BEFORE UPDATE ON notification_templates FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2356 (class 2620 OID 26852)
-- Dependencies: 187 285 2370
-- Name: ts_panelmodel; Type: TRIGGER; Schema: opensaga; Owner: -
--

CREATE TRIGGER ts_panelmodel BEFORE UPDATE ON panelmodel FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2352 (class 2606 OID 26561)
-- Dependencies: 2295 206 184 2370
-- Name: fk_accnt_trigg_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2353 (class 2606 OID 26566)
-- Dependencies: 167 206 2370
-- Name: fk_accnt_trigg_idphone; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idphone FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2350 (class 2606 OID 26887)
-- Dependencies: 2295 205 184 2370
-- Name: fk_account_users_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2351 (class 2606 OID 26892)
-- Dependencies: 205 165 2370
-- Name: fk_account_users_idcontact; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idcontact FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2341 (class 2606 OID 26491)
-- Dependencies: 2295 185 184 2370
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2343 (class 2606 OID 26510)
-- Dependencies: 189 2295 184 2370
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2348 (class 2606 OID 26921)
-- Dependencies: 184 203 2295 2370
-- Name: fk_idaccount_contacts; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idaccount_contacts FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2344 (class 2606 OID 26871)
-- Dependencies: 184 191 2295 2370
-- Name: fk_idaccount_notif; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idaccount_notif FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2349 (class 2606 OID 26926)
-- Dependencies: 165 203 2370
-- Name: fk_idcontact_contacts; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idcontact_contacts FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2347 (class 2606 OID 26614)
-- Dependencies: 196 2319 198 2370
-- Name: fk_ideventtype_kw; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT fk_ideventtype_kw FOREIGN KEY (ideventtype) REFERENCES eventtypes(ideventtype) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2346 (class 2606 OID 26540)
-- Dependencies: 191 2311 193 2370
-- Name: fk_idnotifaccount_eetype; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT fk_idnotifaccount_eetype FOREIGN KEY (idnotifaccount) REFERENCES account_notifications(idnotifaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2342 (class 2606 OID 26496)
-- Dependencies: 185 2305 187 2370
-- Name: fk_idpanelmodel; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idpanelmodel FOREIGN KEY (idpanelmodel) REFERENCES panelmodel(idpanelmodel) ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- TOC entry 2345 (class 2606 OID 26876)
-- Dependencies: 167 191 2370
-- Name: fk_idphone_notif; Type: FK CONSTRAINT; Schema: opensaga; Owner: -
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idphone_notif FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-12-31 08:09:26 ECT

--
-- PostgreSQL database dump complete
--

