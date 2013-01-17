--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.7
-- Dumped by pg_dump version 9.1.7
-- Started on 2013-01-15 13:41:59 ECT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2636 (class 1262 OID 16384)
-- Dependencies: 2635
-- Name: usms; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE usms IS 'Base de datos de uSMS.';


--
-- TOC entry 7 (class 2615 OID 16964)
-- Name: opensaga; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA opensaga;


ALTER SCHEMA opensaga OWNER TO postgres;

--
-- TOC entry 2637 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA opensaga; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA opensaga IS 'Esquema de detos de OpenSAGA';


--
-- TOC entry 228 (class 3079 OID 11644)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2640 (class 0 OID 0)
-- Dependencies: 228
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 284 (class 1255 OID 26932)
-- Dependencies: 7 783
-- Name: fun_account_contacts_table(integer, integer, integer, boolean, text, text, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 2641 (class 0 OID 0)
-- Dependencies: 284
-- Name: FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) IS 'Agrega, edita y elimina contactos de una cuenta.';


--
-- TOC entry 287 (class 1255 OID 26948)
-- Dependencies: 783 7
-- Name: fun_account_contacts_table_xml(integer, integer, integer, boolean, text, text, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_contacts_table_xml(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 25923)
-- Dependencies: 783 7
-- Name: fun_account_event_notifications_sms(); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_event_notifications_sms() OWNER TO postgres;

--
-- TOC entry 2642 (class 0 OID 0)
-- Dependencies: 272
-- Name: FUNCTION fun_account_event_notifications_sms(); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_event_notifications_sms() IS 'Genere notificaciones (sms) segun se haya programado para cada cliente.';


--
-- TOC entry 275 (class 1255 OID 26359)
-- Dependencies: 7 783
-- Name: fun_account_insert_update(integer, integer, boolean, text, text, integer, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 2643 (class 0 OID 0)
-- Dependencies: 275
-- Name: FUNCTION fun_account_insert_update(inidaccount integer, inpartition integer, inenable boolean, inaccount text, inname text, intype integer, innote text, OUT outidaccount integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: postgres
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
-- TOC entry 279 (class 1255 OID 26854)
-- Dependencies: 783 7
-- Name: fun_account_location_table(integer, real, real, text, text, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_location_table(inidaccount integer, ingeox real, ingeoy real, inaddress text, inidaddress text, innote text, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 26946)
-- Dependencies: 783 7
-- Name: fun_account_notifications_table(integer, integer, integer, integer, boolean, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_notifications_table(inidnotifaccount integer, inidaccount integer, inidphone integer, inpriority integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 26944)
-- Dependencies: 7 783
-- Name: fun_account_notifications_table_xml(integer, integer, integer, integer, boolean, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_notifications_table_xml(inidnotifaccount integer, inidaccount integer, inidphone integer, prioinrity integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 26870)
-- Dependencies: 783 7
-- Name: fun_account_phones_trigger_alarm_isuser(integer, integer); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) OWNER TO postgres;

--
-- TOC entry 2644 (class 0 OID 0)
-- Dependencies: 281
-- Name: FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) IS 'Chequea que el idphone pasado como parametro pertenesca a un usuario de la cuenta, caso contrario lo elimina.
Devuelve true si es usuario y false si no lo es.';


--
-- TOC entry 282 (class 1255 OID 26420)
-- Dependencies: 7 783
-- Name: fun_account_phones_trigger_alarm_table(integer, integer, boolean, boolean, boolean, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 2645 (class 0 OID 0)
-- Dependencies: 282
-- Name: FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_table(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, OUT outreturn integer, OUT outpgmsg text) IS 'Agregar / elimina los numeros autorizados a disparar la alarma. Solo numeros de usuarios del sistema son permitidos';


--
-- TOC entry 241 (class 1255 OID 17933)
-- Dependencies: 7 783
-- Name: fun_account_search_name(text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_search_name(innameaccount text) OWNER TO postgres;

--
-- TOC entry 2646 (class 0 OID 0)
-- Dependencies: 241
-- Name: FUNCTION fun_account_search_name(innameaccount text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_search_name(innameaccount text) IS 'Devuelve el idaccount de la cuenta que tiene el nombre pasado como parametro, si no hay cuentas con ese nombre devuelve 0, devuelve -1 en caso de falla';


--
-- TOC entry 242 (class 1255 OID 17934)
-- Dependencies: 7 783
-- Name: fun_account_search_number(text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_search_number(innumberaccount text) OWNER TO postgres;

--
-- TOC entry 2647 (class 0 OID 0)
-- Dependencies: 242
-- Name: FUNCTION fun_account_search_number(innumberaccount text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_search_number(innumberaccount text) IS 'Busca el idaccount basado en el numero pasado como parametro';


--
-- TOC entry 267 (class 1255 OID 26378)
-- Dependencies: 783 7
-- Name: fun_account_table(integer, boolean, text, text, integer, integer, integer, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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

EXCEPTION
WHEN UNIQUE_VIOLATION THEN
outpgmsg := SQLERRM;

RETURN;
END;$$;


ALTER FUNCTION opensaga.fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 2648 (class 0 OID 0)
-- Dependencies: 267
-- Name: FUNCTION fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_table(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, innote text, OUT outreturn integer, OUT outpgmsg text) IS 'Crea, actualiza, elimina registros de la tabla account.
0: algo falla
> 0: idaccount';


--
-- TOC entry 274 (class 1255 OID 26412)
-- Dependencies: 7 783
-- Name: fun_account_users_table(integer, integer, text, boolean, integer, text, text, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_users_table(inidaccount integer, inidcontact integer, inappointment text, inenable boolean, innumuser integer, inkeyword text, inpwd text, innote text, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 26867)
-- Dependencies: 7 783
-- Name: fun_account_users_trigger_phones_contacts(integer, integer); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_account_users_trigger_phones_contacts(inidaccount integer, inidcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT trigger_alarm boolean, OUT fromsms boolean, OUT fromcall boolean, OUT note text) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 25922)
-- Dependencies: 783 7
-- Name: fun_auto_process_events(); Type: FUNCTION; Schema: opensaga; Owner: postgres
--

CREATE FUNCTION fun_auto_process_events() RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
PERFORM opensaga.fun_account_event_notifications_sms();

RETURN TRUE;
END;$$;


ALTER FUNCTION opensaga.fun_auto_process_events() OWNER TO postgres;

--
-- TOC entry 2649 (class 0 OID 0)
-- Dependencies: 270
-- Name: FUNCTION fun_auto_process_events(); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_auto_process_events() IS 'Procesa los eventos:
Envia notificaciones basados en los eventos y configuraciones del sistema';


--
-- TOC entry 247 (class 1255 OID 17544)
-- Dependencies: 7 783
-- Name: fun_eventtype_default(integer, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_eventtype_default(inid integer, inname text) OWNER TO postgres;

--
-- TOC entry 2650 (class 0 OID 0)
-- Dependencies: 247
-- Name: FUNCTION fun_eventtype_default(inid integer, inname text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_eventtype_default(inid integer, inname text) IS 'Funcion usada internamente por opesaga para reflejar los EventType usados por el sistema.';


--
-- TOC entry 277 (class 1255 OID 26416)
-- Dependencies: 7 783
-- Name: fun_generate_test_report(); Type: FUNCTION; Schema: opensaga; Owner: postgres
--

CREATE FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN


RETURN;
END;$$;


ALTER FUNCTION opensaga.fun_generate_test_report(OUT outeventsgenerated integer) OWNER TO postgres;

--
-- TOC entry 2651 (class 0 OID 0)
-- Dependencies: 277
-- Name: FUNCTION fun_generate_test_report(OUT outeventsgenerated integer); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) IS 'Genera los eventos de reporte de prueba enviados a los clientes.';


--
-- TOC entry 271 (class 1255 OID 26131)
-- Dependencies: 783 7
-- Name: fun_get_priority_from_ideventtype(integer); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_get_priority_from_ideventtype(inideventtype integer) OWNER TO postgres;

--
-- TOC entry 2652 (class 0 OID 0)
-- Dependencies: 271
-- Name: FUNCTION fun_get_priority_from_ideventtype(inideventtype integer); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_get_priority_from_ideventtype(inideventtype integer) IS 'Devuelve la prioridad segun el ideventtype';


--
-- TOC entry 273 (class 1255 OID 26215)
-- Dependencies: 783 7
-- Name: fun_notification_gen_message(integer, integer, integer, text); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text) OWNER TO postgres;

--
-- TOC entry 2653 (class 0 OID 0)
-- Dependencies: 273
-- Name: FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_notification_gen_message(inidaccount integer, inidevent integer, inideventtype integer, insmstext text) IS 'Genera el texto del mensaje que se enviara como notificcion';


--
-- TOC entry 269 (class 1255 OID 25921)
-- Dependencies: 7 783
-- Name: fun_receiver_from_incomingcalls(); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_receiver_from_incomingcalls(OUT calls integer, OUT eventsgenerated integer) OWNER TO postgres;

--
-- TOC entry 2654 (class 0 OID 0)
-- Dependencies: 269
-- Name: FUNCTION fun_receiver_from_incomingcalls(OUT calls integer, OUT eventsgenerated integer); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_receiver_from_incomingcalls(OUT calls integer, OUT eventsgenerated integer) IS 'Funcion procesa las llamadas recibidas en la tabla inomngcalls, genera el evento.
process:
0 No procesdo
1 Procesado, evento de una cuenta
2 Procesado, numero no registrado en alguna cuenta.
3 Procesado, numero no tiene propietario
';


--
-- TOC entry 276 (class 1255 OID 26415)
-- Dependencies: 7 783
-- Name: fun_receiver_from_incomingsmss(); Type: FUNCTION; Schema: opensaga; Owner: postgres
--

CREATE FUNCTION fun_receiver_from_incomingsmss(OUT outsmss integer, OUT outeventsgenerated integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN


RETURN;
END;$$;


ALTER FUNCTION opensaga.fun_receiver_from_incomingsmss(OUT outsmss integer, OUT outeventsgenerated integer) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 26920)
-- Dependencies: 7 783
-- Name: fun_view_account_contact_notif_eventtypes(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 2655 (class 0 OID 0)
-- Dependencies: 283
-- Name: FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) IS 'Vista de los tipos de eventos habilitados para un determinado idaccountnotif';


--
-- TOC entry 258 (class 1255 OID 26939)
-- Dependencies: 7 783
-- Name: fun_view_account_contact_notif_eventtypes_xml(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_account_contact_notif_eventtypes_xml(inidaccount integer, inidphone integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 26994)
-- Dependencies: 783 7
-- Name: fun_view_account_contacts_xml(integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_account_contacts_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 26915)
-- Dependencies: 783 7
-- Name: fun_view_account_notif_phones(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_account_notif_phones(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean, OUT idnotifcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT address text, OUT priority integer, OUT call boolean, OUT sms boolean, OUT smstext text, OUT note text, OUT ts timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 26938)
-- Dependencies: 783 7
-- Name: fun_view_account_notif_phones_xml(integer, integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_account_notif_phones_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 26986)
-- Dependencies: 783 7
-- Name: fun_view_last_events_xml(integer, boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2656 (class 0 OID 0)
-- Dependencies: 298
-- Name: FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) IS 'Muestra los ultimos eventos registrados en formato xml';


--
-- TOC entry 296 (class 1255 OID 26984)
-- Dependencies: 783 7
-- Name: fun_view_notification_templates_xml(boolean); Type: FUNCTION; Schema: opensaga; Owner: postgres
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


ALTER FUNCTION opensaga.fun_view_notification_templates_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 26417)
-- Dependencies: 783 7
-- Name: hearbeat(); Type: FUNCTION; Schema: opensaga; Owner: postgres
--

CREATE FUNCTION hearbeat() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$BEGIN

INSERT INTO opensaga.events (code, priority, description, ideventtype) VALUES ('SYS', 100, 'Hear Beat Receiver', 83);

RETURN now();
END;$$;


ALTER FUNCTION opensaga.hearbeat() OWNER TO postgres;

--
-- TOC entry 2657 (class 0 OID 0)
-- Dependencies: 268
-- Name: FUNCTION hearbeat(); Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON FUNCTION hearbeat() IS 'Genera un evento de funcionmiento de la receptora';


SET search_path = public, pg_catalog;

--
-- TOC entry 278 (class 1255 OID 26815)
-- Dependencies: 5 783
-- Name: ctrl_ts(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ctrl_ts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.ts = now(); 
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.ctrl_ts() OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 26962)
-- Dependencies: 5 783
-- Name: fun_contact_search_by_name(text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_contact_search_by_name(infirstname text, inlastname text) OWNER TO postgres;

--
-- TOC entry 2658 (class 0 OID 0)
-- Dependencies: 288
-- Name: FUNCTION fun_contact_search_by_name(infirstname text, inlastname text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_contact_search_by_name(infirstname text, inlastname text) IS 'Obtiene el idcontact segun el firstname y lastname pasado como parametro.
Si no lo encuentra devuelve 0.';


--
-- TOC entry 243 (class 1255 OID 26967)
-- Dependencies: 783 5
-- Name: fun_contacts_table(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_contacts_table(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 26966)
-- Dependencies: 783 5
-- Name: fun_contacts_table_xml(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_contacts_table_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress text, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 16818)
-- Dependencies: 5 783
-- Name: fun_correntportproviders_get_idprovider(integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_correntportproviders_get_idprovider(inidport integer) OWNER TO postgres;

--
-- TOC entry 2659 (class 0 OID 0)
-- Dependencies: 249
-- Name: FUNCTION fun_correntportproviders_get_idprovider(inidport integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_correntportproviders_get_idprovider(inidport integer) IS 'Obtiene el idprovider desde la tabla currentportsproviders segun el idport pasado como parametro.';


--
-- TOC entry 260 (class 1255 OID 16714)
-- Dependencies: 5 783
-- Name: fun_currentportsproviders_insertupdate(integer, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text) OWNER TO postgres;

--
-- TOC entry 2660 (class 0 OID 0)
-- Dependencies: 260
-- Name: FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text) IS 'Funcion que inserta o actualiza los datos de la tabla currentportsproviders con datos enviados desde el puerto serial.';


--
-- TOC entry 262 (class 1255 OID 25899)
-- Dependencies: 5 783
-- Name: fun_idphone_from_phone(text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_idphone_from_phone(inphone text) OWNER TO postgres;

--
-- TOC entry 2661 (class 0 OID 0)
-- Dependencies: 262
-- Name: FUNCTION fun_idphone_from_phone(inphone text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_idphone_from_phone(inphone text) IS 'Obtenemos el idphone segun el phone pasado como parametro';


--
-- TOC entry 244 (class 1255 OID 16846)
-- Dependencies: 5 783
-- Name: fun_incomingcalls_insert(timestamp without time zone, integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text) OWNER TO postgres;

--
-- TOC entry 2662 (class 0 OID 0)
-- Dependencies: 244
-- Name: FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text) IS 'Registra las llamadas entrantes provenientes de los modems';


--
-- TOC entry 250 (class 1255 OID 16847)
-- Dependencies: 5 783
-- Name: fun_incomingcalls_insert_online(integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN 
RETURN fun_incomingcalls_insert('now()', inidport, incallaction, inphone, innote); 
END;$$;


ALTER FUNCTION public.fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) OWNER TO postgres;

--
-- TOC entry 2663 (class 0 OID 0)
-- Dependencies: 250
-- Name: FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) IS 'Funcion para insertar la fecha en modo online, registra la llamada con la fecha actual.';


--
-- TOC entry 252 (class 1255 OID 17669)
-- Dependencies: 5 783
-- Name: fun_modem_insert(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text) OWNER TO postgres;

--
-- TOC entry 2664 (class 0 OID 0)
-- Dependencies: 252
-- Name: FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text) IS 'Inserta los datos de un modem';


--
-- TOC entry 261 (class 1255 OID 25896)
-- Dependencies: 783 5
-- Name: fun_phone_from_idphone(integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_phone_from_idphone(inidphone integer) OWNER TO postgres;

--
-- TOC entry 2665 (class 0 OID 0)
-- Dependencies: 261
-- Name: FUNCTION fun_phone_from_idphone(inidphone integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_phone_from_idphone(inidphone integer) IS 'Obtiene el numero telefonico desde la tabla phones segun el idphone';


--
-- TOC entry 263 (class 1255 OID 25900)
-- Dependencies: 5 783
-- Name: fun_phone_idphone_check(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_phone_idphone_check(inidphone integer, inphone text, OUT outidphone integer, OUT outphone text) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 26980)
-- Dependencies: 5 783
-- Name: fun_phone_search_by_number(text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_phone_search_by_number(inphone text) OWNER TO postgres;

--
-- TOC entry 2666 (class 0 OID 0)
-- Dependencies: 292
-- Name: FUNCTION fun_phone_search_by_number(inphone text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_phone_search_by_number(inphone text) IS 'Busca el id segun el numero telefonico';


--
-- TOC entry 293 (class 1255 OID 26979)
-- Dependencies: 783 5
-- Name: fun_phones_table(integer, integer, boolean, text, integer, integer, real, real, text, text, text, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_phones_table(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, ingeox real, ingeoy real, inphone_ext text, inidaddress text, inaddress text, inubiphone integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 26978)
-- Dependencies: 5 783
-- Name: fun_phones_table_xml(integer, integer, boolean, text, integer, integer, real, real, text, text, text, integer, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_phones_table_xml(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, ingeox real, ingeoy real, inphone_ext text, inidaddress text, inaddress text, inubiphone integer, innote text, ts timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 17670)
-- Dependencies: 783 5
-- Name: fun_portmodem_update(integer, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text) OWNER TO postgres;

--
-- TOC entry 2667 (class 0 OID 0)
-- Dependencies: 257
-- Name: FUNCTION fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text) IS 'Actualiza los registros del puerto y del modem que esta usando la base de datos.';


--
-- TOC entry 295 (class 1255 OID 26982)
-- Dependencies: 5 783
-- Name: fun_providers_idname_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_providers_idname_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2668 (class 0 OID 0)
-- Dependencies: 295
-- Name: FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean) IS 'Devuelve la lista de proveedores unicamente los campos id y name';


--
-- TOC entry 248 (class 1255 OID 16828)
-- Dependencies: 783 5
-- Name: fun_smsin_insert(integer, integer, timestamp without time zone, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text) OWNER TO postgres;

--
-- TOC entry 2669 (class 0 OID 0)
-- Dependencies: 248
-- Name: FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text) IS 'Funcion para almacenar sms entrantes en la tabla smsin';


--
-- TOC entry 264 (class 1255 OID 16800)
-- Dependencies: 5 783
-- Name: fun_smsout_insert(integer, integer, integer, integer, text, timestamp without time zone, text, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_smsout_insert(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, indatetosend timestamp without time zone, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) OWNER TO postgres;

--
-- TOC entry 2670 (class 0 OID 0)
-- Dependencies: 264
-- Name: FUNCTION fun_smsout_insert(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, indatetosend timestamp without time zone, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsout_insert(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, indatetosend timestamp without time zone, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) IS 'Ingresa un sms en la tabla smsout haciendo chequeos previos.
Devuelve:
-1 Si no se ha ingresado inphone e idphone <1';


--
-- TOC entry 256 (class 1255 OID 17668)
-- Dependencies: 783 5
-- Name: fun_smsout_insert_sendnow(integer, integer, integer, integer, text, text, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
retorno INTEGER DEFAULT -1; 

BEGIN
retorno := fun_smsout_insert(inidprovider, inidsmstype, inidphone, inpriority, inphone, 'now()', inmessage, inenablemsgclass, inmsgclass, innote);
RETURN retorno;
END;$$;


ALTER FUNCTION public.fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) OWNER TO postgres;

--
-- TOC entry 2671 (class 0 OID 0)
-- Dependencies: 256
-- Name: FUNCTION fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsout_insert_sendnow(inidprovider integer, inidsmstype integer, inidphone integer, inpriority integer, inphone text, inmessage text, inenablemsgclass boolean, inmsgclass integer, innote text) IS 'Ingresa un sms en la tabla smsout haciendo chequeos previos.';


--
-- TOC entry 253 (class 1255 OID 17665)
-- Dependencies: 783 5
-- Name: fun_smsout_preparenewsmsautoprovider(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_smsout_preparenewsmsautoprovider() OWNER TO postgres;

--
-- TOC entry 2672 (class 0 OID 0)
-- Dependencies: 253
-- Name: FUNCTION fun_smsout_preparenewsmsautoprovider(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsout_preparenewsmsautoprovider() IS 'Prepara para enviar los smsout nuevos que han sido marcados como autoproveedor';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 173 (class 1259 OID 16579)
-- Dependencies: 2208 2209 2210 2211 2212 2213 2214 2215 2216 2217 2218 2219 2220 2221 2222 2223 2224 2225 2226 2227 2228 2229 2230 2231 2232 2233 2234 5 1716 1716
-- Name: smsout; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE smsout (
    idsmsout bigint NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    idprovider integer DEFAULT 0 NOT NULL,
    idsmstype integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    datetosend timestamp without time zone DEFAULT now() NOT NULL,
    message text COLLATE pg_catalog."es_EC.utf8",
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
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.smsout OWNER TO postgres;

--
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE smsout; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE smsout IS 'Tabla de mensajes salientes';


--
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.idsmstype; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsout.idsmstype IS 'Estado del envio del sms';


--
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.idphone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsout.idphone IS 'Se es identificado el numero con un idphone se escribe este campo';


--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsout.phone IS 'Numero telefonico';


--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.datetosend; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsout.datetosend IS 'Fecha programada de envio';


--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN smsout.priority; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsout.priority IS 'Prioridad de envio del sms. 5 es el valor de fabrica. 0 es la maxima prioridad.';


--
-- TOC entry 265 (class 1255 OID 16715)
-- Dependencies: 783 642 5
-- Name: fun_smsout_to_send(integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_smsout_to_send(inidport integer) OWNER TO postgres;

--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 265
-- Name: FUNCTION fun_smsout_to_send(inidport integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsout_to_send(inidport integer) IS 'Selecciona un sms de smsout para enviarlo.
-- process: 0 nada, 1 blockeado, 2 enviado, 3 falla, 4 destino no permitido, 5 autoprovider, 6 enviado incompleto, 7 expirado tiempo de vida, 8 falla todos los intentos por enviar por todos los puertos, 9 fallan todos los intentos de envio, 10 Espera por reintento de envio, 11 Phone no valido';


--
-- TOC entry 255 (class 1255 OID 17664)
-- Dependencies: 5 783
-- Name: fun_smsout_update_expired(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_smsout_update_expired() RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
-- Ponemos como expirados todos los sms que hayan sobrepasado el tiempo de vida
UPDATE smsout SET process = 7, dateprocess = now() WHERE process != 7 AND process IN(0, 1, 5, 10) AND (SELECT EXTRACT (MINUTE FROM (now() - dateprocess))) > maxtimelive;
RETURN TRUE;
END;$$;


ALTER FUNCTION public.fun_smsout_update_expired() OWNER TO postgres;

--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 255
-- Name: FUNCTION fun_smsout_update_expired(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsout_update_expired() IS 'Pone como expirados los mensajes que han sobrepasado su tiempo de vida';


--
-- TOC entry 240 (class 1255 OID 16799)
-- Dependencies: 783 5
-- Name: fun_smsout_updatestatus(integer, integer, integer, integer, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_smsout_updatestatus(inidsmsout integer, inprocess integer, inidport integer, inslices integer, inslicessent integer, innote text) OWNER TO postgres;

--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 240
-- Name: FUNCTION fun_smsout_updatestatus(inidsmsout integer, inprocess integer, inidport integer, inslices integer, inslicessent integer, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsout_updatestatus(inidsmsout integer, inprocess integer, inidport integer, inslices integer, inslicessent integer, innote text) IS 'Actualiza el estado de envio del sms.';


--
-- TOC entry 180 (class 1259 OID 16745)
-- Dependencies: 2247 2248 2249 2250 2251 5
-- Name: smsoutoptions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.smsoutoptions OWNER TO postgres;

--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE smsoutoptions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE smsoutoptions IS 'Opciones globales adicionales para envio de mensajes de texto.';


--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.enable; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsoutoptions.enable IS 'usms toma el ultimo registro habilitado para su funcionamiento ignorando los anteriores';


--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsoutoptions.name IS 'Nombre opcional';


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.report; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsoutoptions.report IS 'Solicita reporte de recibido para cada sms';


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.retryonfail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsoutoptions.retryonfail IS '0 = No intenta reenviar el sms en caso de falla.
> 0 Numero de reintentos en caso de falla.';


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN smsoutoptions.maxslices; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN smsoutoptions.maxslices IS 'Numero maximo de sms que se enviara cuando el texto del mensaje es largo.
De fabrica envia un solo mensaje de 160 caracteres.
Si 0 o 1 de fabrica.';


--
-- TOC entry 254 (class 1255 OID 17663)
-- Dependencies: 783 5 657
-- Name: fun_smsoutoptions_current(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_smsoutoptions_current() OWNER TO postgres;

--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 254
-- Name: FUNCTION fun_smsoutoptions_current(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsoutoptions_current() IS 'Obtiene los valores de smsoutoptions actualmente usadas.';


--
-- TOC entry 291 (class 1255 OID 26959)
-- Dependencies: 783 5
-- Name: fun_view_contacts_byidcontact_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 291
-- Name: FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean) IS 'Devuelve un contacto segun el parametro idcontact en formato xml.';


--
-- TOC entry 286 (class 1255 OID 26958)
-- Dependencies: 5 783
-- Name: fun_view_contacts_to_list_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_view_contacts_to_list_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 286
-- Name: FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean) IS 'Lista de contactos con datos basicos, para ser usado en un combobox o lista simplificada.';


--
-- TOC entry 294 (class 1255 OID 26983)
-- Dependencies: 5 783
-- Name: fun_view_incomingcalls_xml(timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 294
-- Name: FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) IS 'Obtiene la tabla entre las fechas seleccionadas en formato xml';


--
-- TOC entry 245 (class 1255 OID 26960)
-- Dependencies: 783 5
-- Name: fun_view_phones_byid_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_view_phones_byid_xml(inidphone integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 26976)
-- Dependencies: 5 783
-- Name: fun_view_phones_byidcontact_simplified_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_view_phones_byidcontact_simplified_xml(inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

SET search_path = opensaga, pg_catalog;

--
-- TOC entry 184 (class 1259 OID 16976)
-- Dependencies: 2265 2266 2267 2268 2269 2270 2271 2272 2273 1716 7
-- Name: account; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.account OWNER TO postgres;

--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE account; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account IS 'Cuenta de usuario';


--
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN account.account; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account.account IS 'Numero de cuenta en 4 digitos';


--
-- TOC entry 203 (class 1259 OID 17772)
-- Dependencies: 2373 2374 2375 2376 2377 2378 2379 1714 7
-- Name: account_contacts; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.account_contacts OWNER TO postgres;

--
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE account_contacts; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account_contacts IS 'Usuarios del sistema, tiene acceso al sistema ';


--
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN account_contacts.prioritycontact; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account_contacts.prioritycontact IS 'Priordad de comunicar novedad a este contacto';


--
-- TOC entry 183 (class 1259 OID 16974)
-- Dependencies: 7 184
-- Name: account_idaccount_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE account_idaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.account_idaccount_seq OWNER TO postgres;

--
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 183
-- Name: account_idaccount_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE account_idaccount_seq OWNED BY account.idaccount;


--
-- TOC entry 185 (class 1259 OID 17049)
-- Dependencies: 2274 2275 2276 2277 2278 2279 2280 2281 2282 7
-- Name: account_installationdata; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.account_installationdata OWNER TO postgres;

--
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE account_installationdata; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account_installationdata IS 'Datos basico acerca de la instalacion del sistema de alarma';


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN account_installationdata.idaccount; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account_installationdata.idaccount IS 'idaccount a la que pertenecen estos datos';


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN account_installationdata.installercode; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account_installationdata.installercode IS 'Codigo de instalador del panel de control';


--
-- TOC entry 189 (class 1259 OID 17143)
-- Dependencies: 2290 2291 2292 2293 2294 2295 2296 1716 7
-- Name: account_location; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.account_location OWNER TO postgres;

--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE account_location; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account_location IS 'Localizacion de la cuenta';


--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN account_location.geox; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account_location.geox IS 'Ubicacion georeferenciada';


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN account_location.address; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account_location.address IS 'Detalle de la direccion, puntos de referencia, etc.';


--
-- TOC entry 188 (class 1259 OID 17141)
-- Dependencies: 7 189
-- Name: account_location_idlocation_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE account_location_idlocation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.account_location_idlocation_seq OWNER TO postgres;

--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 188
-- Name: account_location_idlocation_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE account_location_idlocation_seq OWNED BY account_location.idlocation;


--
-- TOC entry 191 (class 1259 OID 17176)
-- Dependencies: 2298 2299 2300 2301 2302 2303 2304 2305 1716 1716 7
-- Name: account_notifications; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.account_notifications OWNER TO postgres;

--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE account_notifications; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account_notifications IS 'Contactos a donde se enviara las notificaciones en caso de alarma';


--
-- TOC entry 193 (class 1259 OID 17261)
-- Dependencies: 2307 2308 2309 7
-- Name: account_notifications_eventtype; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_notifications_eventtype (
    idnotifphoneeventtype bigint NOT NULL,
    idnotifaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opensaga.account_notifications_eventtype OWNER TO postgres;

--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE account_notifications_eventtype; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account_notifications_eventtype IS 'Tipos de eventos para cada notificacion.
TODO: Verificar llaves unicas';


--
-- TOC entry 192 (class 1259 OID 17259)
-- Dependencies: 7 193
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.account_notifications_eventtype_idnotifphoneeventtype_seq OWNER TO postgres;

--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 192
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq OWNED BY account_notifications_eventtype.idnotifphoneeventtype;


--
-- TOC entry 226 (class 1259 OID 26445)
-- Dependencies: 2429 2430 2431 7
-- Name: account_notifications_group; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_notifications_group (
    idaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opensaga.account_notifications_group OWNER TO postgres;

--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE account_notifications_group; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE account_notifications_group IS 'Tipos de eventos que se enviaran a los grupos';


--
-- TOC entry 190 (class 1259 OID 17174)
-- Dependencies: 191 7
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE account_notifications_idnotifaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.account_notifications_idnotifaccount_seq OWNER TO postgres;

--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 190
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE account_notifications_idnotifaccount_seq OWNED BY account_notifications.idnotifaccount;


--
-- TOC entry 206 (class 1259 OID 18107)
-- Dependencies: 2392 2393 2394 2395 2396 2397 2398 1716 7
-- Name: account_phones_trigger_alarm; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.account_phones_trigger_alarm OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 18087)
-- Dependencies: 2386 2387 2388 2389 2390 7 1716 203 1716 1714
-- Name: account_users; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_users (
    enable_as_user boolean DEFAULT true NOT NULL,
    keyword text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'undefined'::text NOT NULL,
    pwd text COLLATE pg_catalog."es_EC.utf8" DEFAULT '1234'::text NOT NULL,
    numuser integer DEFAULT 0 NOT NULL,
    note_user text DEFAULT ' '::text NOT NULL
)
INHERITS (account_contacts);


ALTER TABLE opensaga.account_users OWNER TO postgres;

--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN account_users.numuser; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN account_users.numuser IS 'Numero de usuario';


--
-- TOC entry 195 (class 1259 OID 17289)
-- Dependencies: 2310 2311 2312 2313 2314 2315 2316 2317 2319 2320 2321 2322 2323 2324 2325 2326 2327 2328 2329 2330 1716 7
-- Name: events; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.events OWNER TO postgres;

--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE events; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE events IS 'Eventos del sistema
TODO: Ver la posibilidad de crear llave unica usando todos los campos';


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN events.dateload; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN events.dateload IS 'Fecha de ingreso del evento';


--
-- TOC entry 202 (class 1259 OID 17714)
-- Dependencies: 2370 195 7 1716
-- Name: events_generated_by_calls; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE events_generated_by_calls (
    idincall integer DEFAULT 0 NOT NULL
)
INHERITS (events);


ALTER TABLE opensaga.events_generated_by_calls OWNER TO postgres;

--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE events_generated_by_calls; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE events_generated_by_calls IS 'Tabla de eventos generados por llamadas telefonicas.
No permite eventos con misma hora, mismo idphone, etc, no permite eventos repetidos.';


--
-- TOC entry 194 (class 1259 OID 17287)
-- Dependencies: 7 195
-- Name: events_idevent_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE events_idevent_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.events_idevent_seq OWNER TO postgres;

--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 194
-- Name: events_idevent_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE events_idevent_seq OWNED BY events.idevent;


--
-- TOC entry 196 (class 1259 OID 17352)
-- Dependencies: 2331 2332 2333 2334 2335 2336 2337 2338 7
-- Name: eventtypes; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
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


ALTER TABLE opensaga.eventtypes OWNER TO postgres;

--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE eventtypes; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE eventtypes IS 'Tipos de eventos. Enumeracion interna desde OpenSAGA, usar unicamente los que no estan reservados.';


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN eventtypes.name; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON COLUMN eventtypes.name IS 'Nombre del evento';


--
-- TOC entry 224 (class 1259 OID 26381)
-- Dependencies: 2425 2426 2427 2428 1716 1716 7
-- Name: groups; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE groups (
    idgroup bigint NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'group'::text NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opensaga.groups OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 26379)
-- Dependencies: 224 7
-- Name: groups_idgroup_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE groups_idgroup_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.groups_idgroup_seq OWNER TO postgres;

--
-- TOC entry 2716 (class 0 OID 0)
-- Dependencies: 223
-- Name: groups_idgroup_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE groups_idgroup_seq OWNED BY groups.idgroup;


--
-- TOC entry 198 (class 1259 OID 17389)
-- Dependencies: 2340 2341 2342 2343 2344 1716 7
-- Name: keywords; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE keywords (
    idkeyword bigint NOT NULL,
    enable boolean DEFAULT false NOT NULL,
    keyword text DEFAULT 'alarm'::text NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text COLLATE pg_catalog."es_EC.utf8" DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opensaga.keywords OWNER TO postgres;

--
-- TOC entry 2717 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE keywords; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE keywords IS 'Lista de palabras claves a reconocer en los sms';


--
-- TOC entry 197 (class 1259 OID 17387)
-- Dependencies: 7 198
-- Name: keywords_idkeyword_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE keywords_idkeyword_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.keywords_idkeyword_seq OWNER TO postgres;

--
-- TOC entry 2718 (class 0 OID 0)
-- Dependencies: 197
-- Name: keywords_idkeyword_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE keywords_idkeyword_seq OWNED BY keywords.idkeyword;


--
-- TOC entry 215 (class 1259 OID 26202)
-- Dependencies: 2413 2414 2415 7 1714 1714
-- Name: notification_templates; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE notification_templates (
    idnotiftempl bigint NOT NULL,
    description text COLLATE pg_catalog."C.UTF-8" DEFAULT 'description'::text NOT NULL,
    message text COLLATE pg_catalog."C.UTF-8" DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opensaga.notification_templates OWNER TO postgres;

--
-- TOC entry 2719 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE notification_templates; Type: COMMENT; Schema: opensaga; Owner: postgres
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
-- TOC entry 214 (class 1259 OID 26200)
-- Dependencies: 7 215
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE notification_templates_idnotiftempl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.notification_templates_idnotiftempl_seq OWNER TO postgres;

--
-- TOC entry 2720 (class 0 OID 0)
-- Dependencies: 214
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE notification_templates_idnotiftempl_seq OWNED BY notification_templates.idnotiftempl;


--
-- TOC entry 187 (class 1259 OID 17108)
-- Dependencies: 2284 2285 2286 2287 2288 7
-- Name: panelmodel; Type: TABLE; Schema: opensaga; Owner: postgres; Tablespace: 
--

CREATE TABLE panelmodel (
    idpanelmodel bigint NOT NULL,
    name text DEFAULT 'Undefined'::text,
    model text DEFAULT 'Undefined'::text NOT NULL,
    version text DEFAULT 'v-0.0'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opensaga.panelmodel OWNER TO postgres;

--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE panelmodel; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON TABLE panelmodel IS 'Modelos de paneles de control de alarma';


--
-- TOC entry 186 (class 1259 OID 17106)
-- Dependencies: 187 7
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE; Schema: opensaga; Owner: postgres
--

CREATE SEQUENCE panelmodel_idpanelmodel_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE opensaga.panelmodel_idpanelmodel_seq OWNER TO postgres;

--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 186
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE OWNED BY; Schema: opensaga; Owner: postgres
--

ALTER SEQUENCE panelmodel_idpanelmodel_seq OWNED BY panelmodel.idpanelmodel;


SET search_path = public, pg_catalog;

--
-- TOC entry 165 (class 1259 OID 16387)
-- Dependencies: 2156 2157 2158 2159 2160 2161 2162 2163 2164 2165 2166 2167 2168 2169 2170 5
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE contacts (
    idcontact integer NOT NULL,
    enable boolean DEFAULT true,
    xxxtitle integer DEFAULT 0,
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


ALTER TABLE public.contacts OWNER TO postgres;

--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 165
-- Name: TABLE contacts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE contacts IS 'Datos basicos de contactos';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 227 (class 1259 OID 26909)
-- Dependencies: 2154 7 1714
-- Name: view_account_contacts; Type: VIEW; Schema: opensaga; Owner: postgres
--

CREATE VIEW view_account_contacts AS
    SELECT DISTINCT ON (tabla.idaccount, tabla.idcontact) tabla.idaccount, tabla.idcontact, tabla.enable, tabla.firstname, tabla.lastname, tabla.prioritycontact, tabla.enable_as_contact, tabla.appointment, tabla.ts, tabla.note FROM (SELECT account_contacts.idaccount, contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment, account_contacts.ts, account_contacts.note FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact) ORDER BY account_contacts.ts DESC) tabla ORDER BY tabla.idaccount, tabla.idcontact, tabla.ts DESC;


ALTER TABLE opensaga.view_account_contacts OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 167 (class 1259 OID 16423)
-- Dependencies: 2172 2173 2174 2175 2176 2177 2178 2179 2180 2181 2182 2183 2184 5 1716
-- Name: phones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.phones OWNER TO postgres;

--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE phones; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE phones IS 'Numeros telefonicos de contactos.';


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN phones.typephone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN phones.typephone IS '0: No especificado
1: Fijo
2: Movil';


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 225 (class 1259 OID 26425)
-- Dependencies: 2153 1716 7
-- Name: view_account_phones_trigger_alarm; Type: VIEW; Schema: opensaga; Owner: postgres
--

CREATE VIEW view_account_phones_trigger_alarm AS
    SELECT account.idaccount, account.enable, account.account, account.name, account.type, account_phones_trigger_alarm.idphone, (SELECT phones.phone FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS phone, (SELECT phones.idprovider FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS idprovider, (SELECT phones.address FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS address, account_phones_trigger_alarm.enable AS trigger_enable, account_phones_trigger_alarm.fromcall, account_phones_trigger_alarm.fromsms FROM account, account_phones_trigger_alarm WHERE (account.idaccount = account_phones_trigger_alarm.idaccount);


ALTER TABLE opensaga.view_account_phones_trigger_alarm OWNER TO postgres;

--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 225
-- Name: VIEW view_account_phones_trigger_alarm; Type: COMMENT; Schema: opensaga; Owner: postgres
--

COMMENT ON VIEW view_account_phones_trigger_alarm IS 'TODO: Cambiar la vista usando left join para mejorar desempeño';


--
-- TOC entry 207 (class 1259 OID 26127)
-- Dependencies: 2149 7 1716 1716
-- Name: view_account_users; Type: VIEW; Schema: opensaga; Owner: postgres
--

CREATE VIEW view_account_users AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_users.idaccount, account_users.prioritycontact, account_users.enable AS enable_as_contact, account_users.appointment, account_users.enable_as_user, account_users.numuser, account_users.pwd, account_users.keyword FROM account_users, public.contacts WHERE (contacts.idcontact = account_users.idcontact);


ALTER TABLE opensaga.view_account_users OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 26345)
-- Dependencies: 2152 7
-- Name: view_events; Type: VIEW; Schema: opensaga; Owner: postgres
--

CREATE VIEW view_events AS
    SELECT events.idevent, events.dateload, events.idaccount, account.partition, account.enable, account.account, account.name, account.type, events.code, events.zu, events.priority, events.description, events.ideventtype, (SELECT eventtypes.label FROM eventtypes WHERE (eventtypes.ideventtype = events.ideventtype)) AS eventtype, events.datetimeevent, events.process1, events.process2, events.process3, events.process4, events.process5, events.dateprocess1, events.dateprocess2, events.dateprocess4, events.dateprocess3, events.dateprocess5 FROM (events LEFT JOIN account ON ((events.idaccount = account.idaccount)));


ALTER TABLE opensaga.view_events OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 213 (class 1259 OID 26177)
-- Dependencies: 2409 2410 2411 5 1716
-- Name: address_city; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_city (
    idcity bigint NOT NULL,
    idstate integer DEFAULT 0 NOT NULL,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'city'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.address_city OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 26134)
-- Dependencies: 2400 2401 2402 5
-- Name: address_country; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_country (
    idcountry bigint NOT NULL,
    name text DEFAULT 'country'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.address_country OWNER TO postgres;

--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE address_country; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE address_country IS 'Paices del mundo';


--
-- TOC entry 217 (class 1259 OID 26237)
-- Dependencies: 2417 2418 2419 1714 5
-- Name: address_sector; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_sector (
    idsector bigint NOT NULL,
    idcity integer DEFAULT 0 NOT NULL,
    name text COLLATE pg_catalog."C.UTF-8" DEFAULT 'sector'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.address_sector OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 26235)
-- Dependencies: 5 217
-- Name: address_sector_idsector_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE address_sector_idsector_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.address_sector_idsector_seq OWNER TO postgres;

--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 216
-- Name: address_sector_idsector_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE address_sector_idsector_seq OWNED BY address_sector.idsector;


--
-- TOC entry 211 (class 1259 OID 26156)
-- Dependencies: 2404 2405 2406 2407 5
-- Name: address_states; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_states (
    idstate bigint NOT NULL,
    idcountry integer DEFAULT 0 NOT NULL,
    name text DEFAULT 'state'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.address_states OWNER TO postgres;

--
-- TOC entry 2729 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE address_states; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE address_states IS 'Estados o provincias';


--
-- TOC entry 219 (class 1259 OID 26257)
-- Dependencies: 2421 2422 2423 1716 5
-- Name: address_subsector; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_subsector (
    idsubsector bigint NOT NULL,
    idsector integer DEFAULT 0 NOT NULL,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'subsector'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.address_subsector OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 26255)
-- Dependencies: 219 5
-- Name: address_subsector_idsubsector_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE address_subsector_idsubsector_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.address_subsector_idsubsector_seq OWNER TO postgres;

--
-- TOC entry 2730 (class 0 OID 0)
-- Dependencies: 218
-- Name: address_subsector_idsubsector_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE address_subsector_idsubsector_seq OWNED BY address_subsector.idsubsector;


--
-- TOC entry 177 (class 1259 OID 16622)
-- Dependencies: 2240 2241 2242 1716 5
-- Name: blacklist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blacklist (
    idbl integer NOT NULL,
    idprovider integer DEFAULT 0,
    idphone integer DEFAULT 0,
    note text COLLATE pg_catalog."es_EC.utf8",
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.blacklist OWNER TO postgres;

--
-- TOC entry 2731 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE blacklist; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE blacklist IS 'Lista de numeros a los que no se enviaran sms.';


--
-- TOC entry 176 (class 1259 OID 16620)
-- Dependencies: 177 5
-- Name: blacklist_idbl_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blacklist_idbl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blacklist_idbl_seq OWNER TO postgres;

--
-- TOC entry 2732 (class 0 OID 0)
-- Dependencies: 176
-- Name: blacklist_idbl_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blacklist_idbl_seq OWNED BY blacklist.idbl;


--
-- TOC entry 212 (class 1259 OID 26175)
-- Dependencies: 5 213
-- Name: city_idcity_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE city_idcity_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.city_idcity_seq OWNER TO postgres;

--
-- TOC entry 2733 (class 0 OID 0)
-- Dependencies: 212
-- Name: city_idcity_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE city_idcity_seq OWNED BY address_city.idcity;


--
-- TOC entry 164 (class 1259 OID 16385)
-- Dependencies: 5 165
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contacts_id_seq OWNER TO postgres;

--
-- TOC entry 2734 (class 0 OID 0)
-- Dependencies: 164
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.idcontact;


--
-- TOC entry 208 (class 1259 OID 26132)
-- Dependencies: 209 5
-- Name: country_idcountry_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE country_idcountry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_idcountry_seq OWNER TO postgres;

--
-- TOC entry 2735 (class 0 OID 0)
-- Dependencies: 208
-- Name: country_idcountry_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE country_idcountry_seq OWNED BY address_country.idcountry;


--
-- TOC entry 178 (class 1259 OID 16696)
-- Dependencies: 2243 2244 2245 5
-- Name: currentportsproviders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.currentportsproviders OWNER TO postgres;

--
-- TOC entry 2736 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE currentportsproviders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE currentportsproviders IS 'Tabla de relacion entre puertos y proveedor que estan usando actualmente';


--
-- TOC entry 2737 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.idport; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.idport IS 'IdPort, dato proveniente de la tabla serialport de usmsd.sqlite';


--
-- TOC entry 2738 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.port; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.port IS 'Dato proveniente de la tabla serialport de usmsd.sqlite';


--
-- TOC entry 2739 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.cimi; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.cimi IS 'Dato proveniente del modem';


--
-- TOC entry 2740 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.imei; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.imei IS 'Dato proveniente del modem';


--
-- TOC entry 2741 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.idprovider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.idprovider IS 'Dato proveniente de la tabla provider usndo como referencia el campo cimi para obtenerlo.';


--
-- TOC entry 2742 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN currentportsproviders.lastupdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.lastupdate IS 'Fecha de la ultima actualizacion. Si este campo exede de 2 minuto en relacion a la fecha actual deberia eliminarse.';


--
-- TOC entry 182 (class 1259 OID 16833)
-- Dependencies: 2253 2254 2255 2256 2257 2258 2259 2260 2261 2262 2263 5
-- Name: incomingcalls; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.incomingcalls OWNER TO postgres;

--
-- TOC entry 2743 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE incomingcalls; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE incomingcalls IS 'Registro de llamadas entrantes';


--
-- TOC entry 2744 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN incomingcalls.datecall; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN incomingcalls.datecall IS 'Fecha de recepcion de la llamada.';


--
-- TOC entry 2745 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN incomingcalls.idport; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN incomingcalls.idport IS 'Idport por el cual se recibio la llamada.';


--
-- TOC entry 2746 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN incomingcalls.callaction; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN incomingcalls.callaction IS 'Accion tomada ante esa llamada: ignorada, rechazada, contestada';


--
-- TOC entry 181 (class 1259 OID 16831)
-- Dependencies: 182 5
-- Name: incomingcalls_idincall_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE incomingcalls_idincall_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incomingcalls_idincall_seq OWNER TO postgres;

--
-- TOC entry 2747 (class 0 OID 0)
-- Dependencies: 181
-- Name: incomingcalls_idincall_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE incomingcalls_idincall_seq OWNED BY incomingcalls.idincall;


--
-- TOC entry 201 (class 1259 OID 17582)
-- Dependencies: 2346 2347 2348 2349 2350 1716 5 1716 1716
-- Name: modem; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.modem OWNER TO postgres;

--
-- TOC entry 2748 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE modem; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE modem IS 'Modems que han sido automaticamente registrados por el sistema';


--
-- TOC entry 200 (class 1259 OID 17580)
-- Dependencies: 5 201
-- Name: modem_idmodem_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE modem_idmodem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.modem_idmodem_seq OWNER TO postgres;

--
-- TOC entry 2749 (class 0 OID 0)
-- Dependencies: 200
-- Name: modem_idmodem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE modem_idmodem_seq OWNED BY modem.idmodem;


--
-- TOC entry 166 (class 1259 OID 16421)
-- Dependencies: 5 167
-- Name: phones_idphone_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE phones_idphone_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.phones_idphone_seq OWNER TO postgres;

--
-- TOC entry 2750 (class 0 OID 0)
-- Dependencies: 166
-- Name: phones_idphone_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE phones_idphone_seq OWNED BY phones.idphone;


--
-- TOC entry 169 (class 1259 OID 16452)
-- Dependencies: 2186 2187 2188 2189 2190 5
-- Name: provider; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE provider (
    idprovider integer NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    cimi text DEFAULT ''::text NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.provider OWNER TO postgres;

--
-- TOC entry 2751 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE provider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE provider IS 'Proveedores de telefonia';


--
-- TOC entry 2752 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN provider.cimi; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN provider.cimi IS 'Obtiene desde el modem con el comando AT+CIMI, numero de identificacion inico de cada proveedor';


--
-- TOC entry 2753 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN provider.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN provider.name IS 'Nombre del proveedor';


--
-- TOC entry 168 (class 1259 OID 16450)
-- Dependencies: 5 169
-- Name: provider_idprovider_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE provider_idprovider_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.provider_idprovider_seq OWNER TO postgres;

--
-- TOC entry 2754 (class 0 OID 0)
-- Dependencies: 168
-- Name: provider_idprovider_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE provider_idprovider_seq OWNED BY provider.idprovider;


--
-- TOC entry 171 (class 1259 OID 16522)
-- Dependencies: 2192 2193 2194 2195 2196 2197 2198 2199 2200 2201 2202 2203 2204 2205 2206 1716 5 1716
-- Name: smsin; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.smsin OWNER TO postgres;

--
-- TOC entry 2755 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE smsin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE smsin IS 'Tabla de sms entrantes';


--
-- TOC entry 170 (class 1259 OID 16520)
-- Dependencies: 171 5
-- Name: smsin_idsmsin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE smsin_idsmsin_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.smsin_idsmsin_seq OWNER TO postgres;

--
-- TOC entry 2756 (class 0 OID 0)
-- Dependencies: 170
-- Name: smsin_idsmsin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE smsin_idsmsin_seq OWNED BY smsin.idsmsin;


--
-- TOC entry 172 (class 1259 OID 16577)
-- Dependencies: 173 5
-- Name: smsout_idsmsout_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE smsout_idsmsout_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.smsout_idsmsout_seq OWNER TO postgres;

--
-- TOC entry 2757 (class 0 OID 0)
-- Dependencies: 172
-- Name: smsout_idsmsout_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE smsout_idsmsout_seq OWNED BY smsout.idsmsout;


--
-- TOC entry 179 (class 1259 OID 16743)
-- Dependencies: 180 5
-- Name: smsoutoptions_idsmsoutopt_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE smsoutoptions_idsmsoutopt_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.smsoutoptions_idsmsoutopt_seq OWNER TO postgres;

--
-- TOC entry 2758 (class 0 OID 0)
-- Dependencies: 179
-- Name: smsoutoptions_idsmsoutopt_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE smsoutoptions_idsmsoutopt_seq OWNED BY smsoutoptions.idsmsoutopt;


--
-- TOC entry 210 (class 1259 OID 26154)
-- Dependencies: 5 211
-- Name: states_idstate_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE states_idstate_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.states_idstate_seq OWNER TO postgres;

--
-- TOC entry 2759 (class 0 OID 0)
-- Dependencies: 210
-- Name: states_idstate_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE states_idstate_seq OWNED BY address_states.idstate;


--
-- TOC entry 220 (class 1259 OID 26275)
-- Dependencies: 2150 5 1716 1714 1716
-- Name: view_address; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_address AS
    SELECT countryx.idcountry, countryx.name AS country, countryx.code AS country_code, statesx.idstate, statesx.name AS state, statesx.code AS state_code, cityx.idcity, cityx.name AS city, sectorx.idsector, sectorx.name AS sector, subsectorx.idsubsector, subsectorx.name AS subsector, ((((COALESCE((countryx.idcountry)::text, 'X'::text) || COALESCE((statesx.idstate)::text, 'X'::text)) || COALESCE((cityx.idcity)::text, 'X'::text)) || COALESCE((sectorx.idsector)::text, 'X'::text)) || COALESCE((subsectorx.idsubsector)::text, 'X'::text)) AS idaddress FROM ((((address_country countryx LEFT JOIN address_states statesx ON ((countryx.idcountry = statesx.idcountry))) LEFT JOIN address_city cityx ON ((statesx.idstate = cityx.idstate))) LEFT JOIN address_sector sectorx ON ((cityx.idcity = sectorx.idcity))) LEFT JOIN address_subsector subsectorx ON ((sectorx.idsector = subsectorx.idsector)));


ALTER TABLE public.view_address OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 17522)
-- Dependencies: 2147 5
-- Name: view_callin; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_callin AS
    SELECT incomingcalls.idincall, incomingcalls.datecall, incomingcalls.idport, incomingcalls.callaction, incomingcalls.idphone, incomingcalls.phone, incomingcalls.flag1, phones.idcontact, phones.enable, phones.phone AS phone_phone, phones.typephone AS type, phones.idprovider, phones.geox, phones.geoy FROM incomingcalls, phones WHERE (incomingcalls.idphone = phones.idphone);


ALTER TABLE public.view_callin OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 26340)
-- Dependencies: 2151 1716 5
-- Name: view_contacts_phones; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_contacts_phones AS
    SELECT contacts.idcontact, contacts.enable AS contact_enable, contacts.xxxtitle AS title, contacts.firstname, contacts.lastname, contacts.gender, contacts.birthday, contacts.typeofid, contacts.identification, contacts.web, contacts.email1, contacts.email2, phones.idphone, phones.enable AS phone_enable, phones.typephone AS type, phones.idprovider, phones.ubiphone, phones.phone, phones.phone_ext, phones.idaddress, phones.address, phones.geox, phones.geoy, phones.note FROM (contacts LEFT JOIN phones ON ((contacts.idcontact = phones.idcontact)));


ALTER TABLE public.view_contacts_phones OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 17874)
-- Dependencies: 2148 5
-- Name: view_contacts_phonesXXX; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "view_contacts_phonesXXX" AS
    SELECT contacts.idcontact, contacts.enable AS contact_enable, contacts.xxxtitle AS title, contacts.firstname, contacts.lastname, contacts.gender, contacts.birthday, contacts.typeofid, contacts.identification, contacts.web, contacts.email1, contacts.email2, phones.enable AS phone_enable, phones.phone, phones.typephone AS type, phones.idprovider, phones.geox, phones.geoy, phones.idphone FROM (contacts JOIN phones ON ((contacts.idcontact = phones.idcontact)));


ALTER TABLE public."view_contacts_phonesXXX" OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 16599)
-- Dependencies: 2236 2237 2238 1716 5
-- Name: whitelist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE whitelist (
    idwl integer NOT NULL,
    idprovider integer DEFAULT 0,
    idphone integer DEFAULT 0,
    note text COLLATE pg_catalog."es_EC.utf8",
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.whitelist OWNER TO postgres;

--
-- TOC entry 2760 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE whitelist; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE whitelist IS 'Lista de numeros para envio de sms sin restriccion';


--
-- TOC entry 174 (class 1259 OID 16597)
-- Dependencies: 175 5
-- Name: whitelist_idwl_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE whitelist_idwl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.whitelist_idwl_seq OWNER TO postgres;

--
-- TOC entry 2761 (class 0 OID 0)
-- Dependencies: 174
-- Name: whitelist_idwl_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE whitelist_idwl_seq OWNED BY whitelist.idwl;


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2264 (class 2604 OID 16979)
-- Dependencies: 183 184 184
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account ALTER COLUMN idaccount SET DEFAULT nextval('account_idaccount_seq'::regclass);


--
-- TOC entry 2289 (class 2604 OID 17146)
-- Dependencies: 188 189 189
-- Name: idlocation; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_location ALTER COLUMN idlocation SET DEFAULT nextval('account_location_idlocation_seq'::regclass);


--
-- TOC entry 2297 (class 2604 OID 17179)
-- Dependencies: 191 190 191
-- Name: idnotifaccount; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications ALTER COLUMN idnotifaccount SET DEFAULT nextval('account_notifications_idnotifaccount_seq'::regclass);


--
-- TOC entry 2306 (class 2604 OID 17264)
-- Dependencies: 193 192 193
-- Name: idnotifphoneeventtype; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications_eventtype ALTER COLUMN idnotifphoneeventtype SET DEFAULT nextval('account_notifications_eventtype_idnotifphoneeventtype_seq'::regclass);


--
-- TOC entry 2380 (class 2604 OID 18090)
-- Dependencies: 205 205
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2381 (class 2604 OID 18091)
-- Dependencies: 205 205
-- Name: idcontact; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN idcontact SET DEFAULT 0;


--
-- TOC entry 2382 (class 2604 OID 18092)
-- Dependencies: 205 205
-- Name: prioritycontact; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN prioritycontact SET DEFAULT 5;


--
-- TOC entry 2383 (class 2604 OID 18093)
-- Dependencies: 205 205
-- Name: enable; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN enable SET DEFAULT true;


--
-- TOC entry 2384 (class 2604 OID 18094)
-- Dependencies: 205 205
-- Name: appointment; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN appointment SET DEFAULT ''::text;


--
-- TOC entry 2385 (class 2604 OID 18095)
-- Dependencies: 205 205
-- Name: note; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN note SET DEFAULT ''::text;


--
-- TOC entry 2391 (class 2604 OID 26457)
-- Dependencies: 205 205
-- Name: ts; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2318 (class 2604 OID 17292)
-- Dependencies: 195 194 195
-- Name: idevent; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2362 (class 2604 OID 17717)
-- Dependencies: 202 194 202
-- Name: idevent; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2363 (class 2604 OID 17718)
-- Dependencies: 202 202
-- Name: dateload; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateload SET DEFAULT now();


--
-- TOC entry 2364 (class 2604 OID 17719)
-- Dependencies: 202 202
-- Name: idaccount; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2365 (class 2604 OID 17720)
-- Dependencies: 202 202
-- Name: code; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN code SET DEFAULT '0000'::text;


--
-- TOC entry 2366 (class 2604 OID 17721)
-- Dependencies: 202 202
-- Name: zu; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN zu SET DEFAULT 0;


--
-- TOC entry 2367 (class 2604 OID 17722)
-- Dependencies: 202 202
-- Name: priority; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN priority SET DEFAULT 5;


--
-- TOC entry 2368 (class 2604 OID 17723)
-- Dependencies: 202 202
-- Name: description; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN description SET DEFAULT ''::text;


--
-- TOC entry 2369 (class 2604 OID 17724)
-- Dependencies: 202 202
-- Name: ideventtype; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ideventtype SET DEFAULT 0;


--
-- TOC entry 2371 (class 2604 OID 18022)
-- Dependencies: 202 202
-- Name: datetimeevent; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN datetimeevent SET DEFAULT now();


--
-- TOC entry 2351 (class 2604 OID 25925)
-- Dependencies: 202 202
-- Name: process1; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process1 SET DEFAULT 0;


--
-- TOC entry 2352 (class 2604 OID 25942)
-- Dependencies: 202 202
-- Name: process2; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process2 SET DEFAULT 0;


--
-- TOC entry 2353 (class 2604 OID 25959)
-- Dependencies: 202 202
-- Name: process3; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process3 SET DEFAULT 0;


--
-- TOC entry 2354 (class 2604 OID 25976)
-- Dependencies: 202 202
-- Name: process4; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process4 SET DEFAULT 0;


--
-- TOC entry 2355 (class 2604 OID 25993)
-- Dependencies: 202 202
-- Name: process5; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process5 SET DEFAULT 0;


--
-- TOC entry 2356 (class 2604 OID 26010)
-- Dependencies: 202 202
-- Name: note; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN note SET DEFAULT ' '::text;


--
-- TOC entry 2357 (class 2604 OID 26033)
-- Dependencies: 202 202
-- Name: dateprocess1; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess1 SET DEFAULT now();


--
-- TOC entry 2358 (class 2604 OID 26050)
-- Dependencies: 202 202
-- Name: dateprocess2; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess2 SET DEFAULT now();


--
-- TOC entry 2359 (class 2604 OID 26067)
-- Dependencies: 202 202
-- Name: dateprocess3; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess3 SET DEFAULT now();


--
-- TOC entry 2360 (class 2604 OID 26084)
-- Dependencies: 202 202
-- Name: dateprocess4; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess4 SET DEFAULT now();


--
-- TOC entry 2361 (class 2604 OID 26101)
-- Dependencies: 202 202
-- Name: dateprocess5; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess5 SET DEFAULT now();


--
-- TOC entry 2372 (class 2604 OID 26572)
-- Dependencies: 202 202
-- Name: ts; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2424 (class 2604 OID 26384)
-- Dependencies: 224 223 224
-- Name: idgroup; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY groups ALTER COLUMN idgroup SET DEFAULT nextval('groups_idgroup_seq'::regclass);


--
-- TOC entry 2339 (class 2604 OID 17392)
-- Dependencies: 198 197 198
-- Name: idkeyword; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY keywords ALTER COLUMN idkeyword SET DEFAULT nextval('keywords_idkeyword_seq'::regclass);


--
-- TOC entry 2412 (class 2604 OID 26205)
-- Dependencies: 215 214 215
-- Name: idnotiftempl; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY notification_templates ALTER COLUMN idnotiftempl SET DEFAULT nextval('notification_templates_idnotiftempl_seq'::regclass);


--
-- TOC entry 2283 (class 2604 OID 17111)
-- Dependencies: 187 186 187
-- Name: idpanelmodel; Type: DEFAULT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY panelmodel ALTER COLUMN idpanelmodel SET DEFAULT nextval('panelmodel_idpanelmodel_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2408 (class 2604 OID 26180)
-- Dependencies: 213 212 213
-- Name: idcity; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_city ALTER COLUMN idcity SET DEFAULT nextval('city_idcity_seq'::regclass);


--
-- TOC entry 2399 (class 2604 OID 26137)
-- Dependencies: 209 208 209
-- Name: idcountry; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_country ALTER COLUMN idcountry SET DEFAULT nextval('country_idcountry_seq'::regclass);


--
-- TOC entry 2416 (class 2604 OID 26240)
-- Dependencies: 216 217 217
-- Name: idsector; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_sector ALTER COLUMN idsector SET DEFAULT nextval('address_sector_idsector_seq'::regclass);


--
-- TOC entry 2403 (class 2604 OID 26159)
-- Dependencies: 211 210 211
-- Name: idstate; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_states ALTER COLUMN idstate SET DEFAULT nextval('states_idstate_seq'::regclass);


--
-- TOC entry 2420 (class 2604 OID 26260)
-- Dependencies: 218 219 219
-- Name: idsubsector; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_subsector ALTER COLUMN idsubsector SET DEFAULT nextval('address_subsector_idsubsector_seq'::regclass);


--
-- TOC entry 2239 (class 2604 OID 16625)
-- Dependencies: 177 176 177
-- Name: idbl; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blacklist ALTER COLUMN idbl SET DEFAULT nextval('blacklist_idbl_seq'::regclass);


--
-- TOC entry 2155 (class 2604 OID 16390)
-- Dependencies: 165 164 165
-- Name: idcontact; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contacts ALTER COLUMN idcontact SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- TOC entry 2252 (class 2604 OID 16836)
-- Dependencies: 181 182 182
-- Name: idincall; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY incomingcalls ALTER COLUMN idincall SET DEFAULT nextval('incomingcalls_idincall_seq'::regclass);


--
-- TOC entry 2345 (class 2604 OID 17585)
-- Dependencies: 201 200 201
-- Name: idmodem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY modem ALTER COLUMN idmodem SET DEFAULT nextval('modem_idmodem_seq'::regclass);


--
-- TOC entry 2171 (class 2604 OID 16426)
-- Dependencies: 166 167 167
-- Name: idphone; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phones ALTER COLUMN idphone SET DEFAULT nextval('phones_idphone_seq'::regclass);


--
-- TOC entry 2185 (class 2604 OID 16455)
-- Dependencies: 168 169 169
-- Name: idprovider; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY provider ALTER COLUMN idprovider SET DEFAULT nextval('provider_idprovider_seq'::regclass);


--
-- TOC entry 2191 (class 2604 OID 16525)
-- Dependencies: 171 170 171
-- Name: idsmsin; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY smsin ALTER COLUMN idsmsin SET DEFAULT nextval('smsin_idsmsin_seq'::regclass);


--
-- TOC entry 2207 (class 2604 OID 16582)
-- Dependencies: 172 173 173
-- Name: idsmsout; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY smsout ALTER COLUMN idsmsout SET DEFAULT nextval('smsout_idsmsout_seq'::regclass);


--
-- TOC entry 2246 (class 2604 OID 16748)
-- Dependencies: 180 179 180
-- Name: idsmsoutopt; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY smsoutoptions ALTER COLUMN idsmsoutopt SET DEFAULT nextval('smsoutoptions_idsmsoutopt_seq'::regclass);


--
-- TOC entry 2235 (class 2604 OID 16602)
-- Dependencies: 174 175 175
-- Name: idwl; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY whitelist ALTER COLUMN idwl SET DEFAULT nextval('whitelist_idwl_seq'::regclass);


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2595 (class 0 OID 16976)
-- Dependencies: 184 2631
-- Data for Name: account; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account (idaccount, partition, enable, account, name, type, dateload, note, ts, idgroup) FROM stdin;
21	4	t	0000	Farmacia America	0	2012-11-21 00:07:35.045579	jjjjjjjcc vvvvccgc	2012-12-10 22:55:03.407684	0
39	0	f	0118	Lion Security Systema	0	2012-12-10 22:58:35.933947	Mi trabajo	2012-12-10 22:58:35.933947	0
40	-2147483647	t	233456	Parroquia de Tumbaco	0	2012-12-10 23:01:55.874097	Nada	2012-12-10 23:02:34.621937	0
43	0	t	0000(2)	Ferreteria Colon	0	2012-12-26 04:20:37.717312		2012-12-26 04:20:37.717312	0
45	0	t	0000(4)	Mi nueva cuenta	0	2012-12-31 19:19:59.445999		2012-12-31 19:19:59.445999	0
1	1	t	0152	Edwin De La Cruz	0	2012-10-23 22:24:52.859298	Esta es la web de prueba - ok hghjgj	2012-12-31 19:32:41.840842	0
41	0	t	0000(0)	Nuevo cliente Barrial	0	2012-12-25 08:14:58.064627	kkv	2013-01-03 05:30:42.077842	0
47	0	t	1266	Barrio Cumbaya	0	2013-01-03 05:31:41.922639	Nueva cuenta creada	2013-01-03 05:31:54.137758	0
37	-2147483648	t	12445	Farmacia La primavera 2	0	2012-12-10 22:53:14.035044		2013-01-03 06:11:27.456928	0
33	-2147483648	t	00066	Libreria Carrion	0	2012-12-03 03:20:42.647959	Esta es una nueva cuenta	2012-12-03 03:20:42.647959	0
3	1	t	01520	Erika Tatiana De La Cruz	0	2012-11-05 00:56:47.716814	nota de eriaki\n	2012-12-05 03:11:17.671996	0
35	0	t	0000w	Josue De La Cruz	0	2012-12-03 03:33:13.905356	dsadas	2012-12-10 22:36:12.709735	0
\.


--
-- TOC entry 2613 (class 0 OID 17772)
-- Dependencies: 203 2631
-- Data for Name: account_contacts; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_contacts (idaccount, idcontact, prioritycontact, enable, appointment, note, ts) FROM stdin;
37	13	0	f	Propietario		2013-01-09 06:06:27.053018
3	10	0	f	Vecino	Este es un nuevo usuario	2012-12-20 08:30:29.007575
1	13	0	f	Propietario		2013-01-15 10:04:19.92112
1	7	0	f	Propietario	HSA G mamá h h	2013-01-01 08:18:08.175713
40	7	2	f	Propietario	kjjj	2013-01-01 08:24:55.183857
\.


--
-- TOC entry 2762 (class 0 OID 0)
-- Dependencies: 183
-- Name: account_idaccount_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('account_idaccount_seq', 47, true);


--
-- TOC entry 2596 (class 0 OID 17049)
-- Dependencies: 185 2631
-- Data for Name: account_installationdata; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_installationdata (idinstallationdata, idaccount, installationdate, installercode, note, idpanelmodel, idphone, idcommunicationformat, ts) FROM stdin;
\.


--
-- TOC entry 2600 (class 0 OID 17143)
-- Dependencies: 189 2631
-- Data for Name: account_location; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_location (idlocation, idaccount, geox, geoy, address, note, idaddress, ts) FROM stdin;
1	3	1.99796999	0.667568028	Direccion desconodica hasta el momento	Esta nota es para que sepas que la direccion es incorrecta - ok		2012-12-05 03:11:17.728702
4	35	0	0	ok	nooooooooooooo		2012-12-10 22:36:12.791179
3	21	0	0	ok, pendiente	ya		2012-12-10 22:55:03.453075
5	40	0	0	En quito	oriente		2012-12-10 23:02:35.514864
8	43	NaN	NaN				2012-12-26 04:20:39.909974
10	45	NaN	NaN				2012-12-31 19:20:01.966867
2	1	0.876659989	3.14159989	Tumbaco la Morita	No hay nada que anotar		2012-12-31 19:32:43.591306
6	41	NaN	NaN				2013-01-03 05:30:43.321823
14	47	NaN	NaN				2013-01-03 05:31:55.958223
15	37	0	0				2013-01-03 06:11:30.041748
\.


--
-- TOC entry 2763 (class 0 OID 0)
-- Dependencies: 188
-- Name: account_location_idlocation_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('account_location_idlocation_seq', 15, true);


--
-- TOC entry 2602 (class 0 OID 17176)
-- Dependencies: 191 2631
-- Data for Name: account_notifications; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_notifications (idnotifaccount, idaccount, idphone, priority, call, sms, smstext, note, ts) FROM stdin;
2	1	3	3	f	f	ok		2012-12-30 07:23:15.421566
16	40	3	0	t	f			2013-01-01 08:23:02.826561
17	37	9	0	f	f	jj		2013-01-09 06:06:42.084785
18	1	12	0	t	f		Una nota es ingresada	2013-01-13 13:11:07.235275
\.


--
-- TOC entry 2604 (class 0 OID 17261)
-- Dependencies: 193 2631
-- Data for Name: account_notifications_eventtype; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_notifications_eventtype (idnotifphoneeventtype, idnotifaccount, ideventtype, ts) FROM stdin;
1	2	34	2012-12-16 14:45:08.116356
2	2	12	2012-12-17 02:34:28.529746
\.


--
-- TOC entry 2764 (class 0 OID 0)
-- Dependencies: 192
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('account_notifications_eventtype_idnotifphoneeventtype_seq', 2, true);


--
-- TOC entry 2630 (class 0 OID 26445)
-- Dependencies: 226 2631
-- Data for Name: account_notifications_group; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_notifications_group (idaccount, ideventtype, note, ts) FROM stdin;
\.


--
-- TOC entry 2765 (class 0 OID 0)
-- Dependencies: 190
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('account_notifications_idnotifaccount_seq', 18, true);


--
-- TOC entry 2615 (class 0 OID 18107)
-- Dependencies: 206 2631
-- Data for Name: account_phones_trigger_alarm; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_phones_trigger_alarm (idaccount, idphone, enable, fromsms, fromcall, note, ts) FROM stdin;
1	3	f	t	f	Llamar  primero	2012-12-28 06:28:52.22784
37	11	f	t	f		2013-01-09 06:07:10.572359
40	3	f	t	t	 	2012-12-11 00:30:55.753377
3	10	t	t	t	Esta es la nota que debemos almacenar	2013-01-10 05:00:14.798511
1	7	f	t	f		2013-01-13 13:11:34.687127
\.


--
-- TOC entry 2614 (class 0 OID 18087)
-- Dependencies: 205 2631
-- Data for Name: account_users; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY account_users (idaccount, idcontact, prioritycontact, enable, appointment, note, enable_as_user, keyword, pwd, numuser, note_user, ts) FROM stdin;
3	7	5	t	Empleado		t	undefined	1234	0	 ok funciona	2012-12-03 00:28:43.175162
21	7	5	t	Gerente		t	undefined	1234	0		2012-12-03 00:28:43.175162
33	10	5	t	Vecino		t	v	jj	0		2012-12-09 17:00:57.353996
33	7	5	t	Vecino		t			1	Esta es una prueba	2012-12-10 22:26:46.093892
35	10	5	t	Administrador		f			3	Este es un mensaje como notra a tomar en cuenta	2012-12-10 22:38:18.879251
37	14	5	t	Propietario		f			0		2013-01-09 06:07:01.456378
1	7	0	f	Propietario	HSA G mamá h h	t			1	MOdificados ok mam	2013-01-13 13:11:25.358542
1	10	5	t	Vecino	hghgh&max=m mamá oCCCC chi 'no'	t	jkhjhkj	5675	2	Estamos probando el sistema	2013-01-15 10:13:31.936266
\.


--
-- TOC entry 2606 (class 0 OID 17289)
-- Dependencies: 195 2631
-- Data for Name: events; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY events (idevent, dateload, idaccount, code, zu, priority, description, ideventtype, datetimeevent, process1, process2, process3, process4, process5, note, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5, ts) FROM stdin;
5015	2013-01-15 12:05:24.67695	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 12:05:24.67695	1	0	0	0	0	 	2013-01-15 12:05:24.809557	2013-01-15 12:05:24.67695	2013-01-15 12:05:24.67695	2013-01-15 12:05:24.67695	2013-01-15 12:05:24.67695	2013-01-15 12:05:24.809557
5016	2013-01-15 12:17:02.624134	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 12:17:02.624134	1	0	0	0	0	 	2013-01-15 12:17:02.776217	2013-01-15 12:17:02.624134	2013-01-15 12:17:02.624134	2013-01-15 12:17:02.624134	2013-01-15 12:17:02.624134	2013-01-15 12:17:02.776217
5017	2013-01-15 12:28:38.674025	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 12:28:38.674025	1	0	0	0	0	 	2013-01-15 12:28:38.790809	2013-01-15 12:28:38.674025	2013-01-15 12:28:38.674025	2013-01-15 12:28:38.674025	2013-01-15 12:28:38.674025	2013-01-15 12:28:38.790809
5018	2013-01-15 12:40:10.389011	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 12:40:10.389011	1	0	0	0	0	 	2013-01-15 12:40:10.517246	2013-01-15 12:40:10.389011	2013-01-15 12:40:10.389011	2013-01-15 12:40:10.389011	2013-01-15 12:40:10.389011	2013-01-15 12:40:10.517246
5019	2013-01-15 12:51:36.777623	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 12:51:36.777623	1	0	0	0	0	 	2013-01-15 12:51:36.914655	2013-01-15 12:51:36.777623	2013-01-15 12:51:36.777623	2013-01-15 12:51:36.777623	2013-01-15 12:51:36.777623	2013-01-15 12:51:36.914655
5020	2013-01-15 13:03:05.002387	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 13:03:05.002387	1	0	0	0	0	 	2013-01-15 13:03:05.140696	2013-01-15 13:03:05.002387	2013-01-15 13:03:05.002387	2013-01-15 13:03:05.002387	2013-01-15 13:03:05.002387	2013-01-15 13:03:05.140696
5021	2013-01-15 13:14:32.453472	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 13:14:32.453472	1	0	0	0	0	 	2013-01-15 13:14:32.582427	2013-01-15 13:14:32.453472	2013-01-15 13:14:32.453472	2013-01-15 13:14:32.453472	2013-01-15 13:14:32.453472	2013-01-15 13:14:32.582427
5022	2013-01-15 13:26:11.584218	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 13:26:11.584218	1	0	0	0	0	 	2013-01-15 13:26:11.739713	2013-01-15 13:26:11.584218	2013-01-15 13:26:11.584218	2013-01-15 13:26:11.584218	2013-01-15 13:26:11.584218	2013-01-15 13:26:11.739713
5023	2013-01-15 13:37:50.144572	0	SYS	0	100	Hear Beat Receiver	83	2013-01-15 13:37:50.144572	1	0	0	0	0	 	2013-01-15 13:37:50.268476	2013-01-15 13:37:50.144572	2013-01-15 13:37:50.144572	2013-01-15 13:37:50.144572	2013-01-15 13:37:50.144572	2013-01-15 13:37:50.268476
\.


--
-- TOC entry 2612 (class 0 OID 17714)
-- Dependencies: 202 2631
-- Data for Name: events_generated_by_calls; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY events_generated_by_calls (idevent, dateload, idaccount, code, zu, priority, description, ideventtype, idincall, datetimeevent, process1, process2, process3, process4, process5, note, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5, ts) FROM stdin;
\.


--
-- TOC entry 2766 (class 0 OID 0)
-- Dependencies: 194
-- Name: events_idevent_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('events_idevent_seq', 5023, true);


--
-- TOC entry 2607 (class 0 OID 17352)
-- Dependencies: 196 2631
-- Data for Name: eventtypes; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY eventtypes (ideventtype, name, priority, accountdefault, label, note, groupdefault, ts) FROM stdin;
51	sms-burglary	0	f	sms-burglary		f	2013-01-15 10:21:59.524523
55	battery-restore	0	f	battery-restore		f	2013-01-15 10:21:59.56788
56	weekyreport	0	f	weekyreport		f	2013-01-15 10:21:59.579081
57	weekyreport-no-received	0	f	weekyreport-no-received		f	2013-01-15 10:21:59.590535
58	periodicreport	0	f	periodicreport		f	2013-01-15 10:21:59.60708
59	periodicreport-no-received	0	f	periodicreport-no-received		f	2013-01-15 10:21:59.616453
71	sms-violency	0	f	sms-violency		f	2013-01-15 10:21:59.746236
72	alarm-call-phone	5	f	alarm-call-phone		f	2013-01-15 10:21:59.757336
74	sms-alarm-silent	0	f	sms-alarm-silent		f	2013-01-15 10:21:59.779507
75	sms-message	0	f	sms-message		f	2013-01-15 10:21:59.790613
76	receiverinformfromaccount	0	f	receiverinformfromaccount		f	2013-01-15 10:21:59.808303
77	receiverinformfromgroup	0	f	receiverinformfromgroup		f	2013-01-15 10:21:59.812992
81	account-user-new	0	f	account-user-new		f	2013-01-15 10:21:59.857589
82	account-user-deleted	0	f	account-user-deleted		f	2013-01-15 10:21:59.86816
83	hearbeat-receiver	0	f	hearbeat-receiver		f	2013-01-15 10:21:59.879611
84	reserver1	0	f	reserver9		f	2013-01-15 10:21:59.890871
85	reserver2	0	f	reserver10		f	2013-01-15 10:21:59.909732
86	reserver3	0	f	reserver11		f	2013-01-15 10:21:59.914247
87	reserver4	0	f	reserver12		f	2013-01-15 10:21:59.925191
88	reserver5	0	f	reserver13		f	2013-01-15 10:21:59.935269
89	reserver6	0	f	Undefined		f	2013-01-15 10:21:59.94654
90	reserver7	0	f	reserver15		f	2013-01-15 10:21:59.957629
91	reserver8	0	f	reserver16		f	2013-01-15 10:21:59.968609
92	reserver9	0	f	reserver17		f	2013-01-15 10:21:59.980216
93	reserver10	0	f	reserver18		f	2013-01-15 10:21:59.990875
95	reserver12	0	f	reserver20		f	2013-01-15 10:22:00.01367
96	reserver13	0	f	Undefined		f	2013-01-15 10:22:00.028896
99	reserver16	0	f	Undefined		f	2013-01-15 10:22:00.057635
100	reserver17	0	f	Undefined		f	2013-01-15 10:22:00.068744
101	reserver18	0	f	Undefined		f	2013-01-15 10:22:00.079981
103	reserver20	0	f	Undefined		f	2013-01-15 10:22:00.10263
104	reserver21	0	f	Undefined		f	2013-01-15 10:22:00.113784
106	reserver23	0	f	Undefined		f	2013-01-15 10:22:00.139383
108	reserver25	0	f	reserver33		f	2013-01-15 10:22:00.158145
111	reserver28	0	f	reserver29		f	2013-01-15 10:22:00.191644
112	reserver29	0	f	reserver30		f	2013-01-15 10:22:00.202643
4	trouble	0	f	trouble		f	2013-01-15 10:21:59.000155
5	trouble-restore	0	f	trouble-restore		f	2013-01-15 10:21:59.011193
6	sms-alarm	0	f	sms-alarm		f	2013-01-15 10:21:59.022317
7	medical-alarm	0	f	medical-alarm		f	2013-01-15 10:21:59.033341
9	medical-trouble	0	f	medical-trouble		f	2013-01-15 10:21:59.055673
10	medical-trouble-restore	0	f	medical-trouble-restore		f	2013-01-15 10:21:59.066771
11	sms-medical	0	f	sms-medical		f	2013-01-15 10:21:59.07789
12	perimeter-alarm	0	f	perimeter-alarm		f	2013-01-15 10:21:59.089076
13	perimeter-alarm-restore	0	f	perimeter-alarm-restore		f	2013-01-15 10:21:59.100522
14	perimeter-trouble	0	f	perimeter-trouble		f	2013-01-15 10:21:59.111385
15	perimeter-trouble-restore	0	f	perimeter-trouble-restore		f	2013-01-15 10:21:59.122416
17	interior-alarm	0	f	interior-alarm		f	2013-01-15 10:21:59.144677
18	interior-alarm-restore	0	f	interior-alarm-restore		f	2013-01-15 10:21:59.155661
19	interior-trouble	0	f	interior-trouble		f	2013-01-15 10:21:59.166777
21	sms-interior	0	f	sms-interior		f	2013-01-15 10:21:59.189061
22	z24h-alarm	0	f	z24h-alarm		f	2013-01-15 10:21:59.200613
26	sms-z24h	0	f	sms-z24h		f	2013-01-15 10:21:59.244791
27	fire-alarm	0	f	fire-alarm		f	2013-01-15 10:21:59.255763
28	fire-alarm-restore	0	f	fire-alarm-restore		f	2013-01-15 10:21:59.267591
29	fire-trouble	0	f	fire-trouble		f	2013-01-15 10:21:59.278307
30	fire-trouble-restore	0	f	fire-trouble-restore		f	2013-01-15 10:21:59.289454
31	sms-fire	0	f	sms-fire		f	2013-01-15 10:21:59.301169
32	smoke-alarm	0	f	smoke-alarm		f	2013-01-15 10:21:59.314972
33	smoke-alarm-restore	0	f	smoke-alarm-restore		f	2013-01-15 10:21:59.323332
34	smoke-trouble	0	f	smoke-trouble		f	2013-01-15 10:21:59.334455
35	smoke-trouble-restore	0	f	smoke-trouble-restore		f	2013-01-15 10:21:59.345449
36	sms-smoke	0	f	sms-smoke		f	2013-01-15 10:21:59.356287
37	panic-alarm	0	f	panic-alarm		f	2013-01-15 10:21:59.367389
38	panic-alarm-restore	0	f	panic-alarm-restore		f	2013-01-15 10:21:59.378421
39	panic-trouble	0	f	panic-trouble		f	2013-01-15 10:21:59.39002
40	panic-trouble-restore	0	f	panic-trouble-restore		f	2013-01-15 10:21:59.401132
41	sms-panic	0	f	sms-panic		f	2013-01-15 10:21:59.411883
42	tamper-alarm	0	f	tamper-alarm		f	2013-01-15 10:21:59.423276
43	tamper-alarm-restore	0	f	tamper-alarm-restore		f	2013-01-15 10:21:59.434526
44	tamper-trouble	0	f	tamper-trouble		f	2013-01-15 10:21:59.445513
47	burglary-alarm	0	f	burglary-alarm		f	2013-01-15 10:21:59.479025
48	burglary-alarm-restore	0	f	burglary-alarm-restore		f	2013-01-15 10:21:59.489924
49	burglary-trouble	0	f	burglary-trouble		f	2013-01-15 10:21:59.502177
60	entry-unauthorized	0	f	entry-unauthorized		f	2013-01-15 10:21:59.623564
61	exit-unauthorized	0	f	exit-unauthorized		f	2013-01-15 10:21:59.634908
62	entry-undetected	0	f	entry-undetected		f	2013-01-15 10:21:59.646187
63	exit-undetected	0	f	exit-undetected		f	2013-01-15 10:21:59.657163
64	request-service	0	f	request-service		f	2013-01-15 10:21:59.668072
65	request-service-finalized	0	f	request-service-finalized		f	2013-01-15 10:21:59.679149
66	request-service-pending	0	f	request-service-pending		f	2013-01-15 10:21:59.690179
67	request-service-ignore	0	f	request-service-ignore		f	2013-01-15 10:21:59.705899
68	system-fail	0	f	system-fail		f	2013-01-15 10:21:59.712498
69	sms-holdup	0	f	sms-holdup		f	2013-01-15 10:21:59.723628
23	z24h-alarm-restore	0	f	z24h-alarm-restore		f	2013-01-15 10:21:59.211405
24	z24h-trouble	0	f	z24h-trouble		f	2013-01-15 10:21:59.222471
25	z24h-trouble-restore	0	f	z24h-trouble-restore		f	2013-01-15 10:21:59.233515
46	sms-tamper	0	f	sms-tamper		f	2013-01-15 10:21:59.468058
0	unknow	0	f	unknow		f	2013-01-15 10:21:58.926299
1	alarm-cancel	0	f	alarm-cancel		f	2013-01-15 10:21:58.966664
2	alarm	0	f	alarm		f	2013-01-15 10:21:58.977439
3	alarm-restore	0	f	alarm-restore		f	2013-01-15 10:21:58.988524
8	medical-alarm-restore	0	f	medical-alarm-restore		f	2013-01-15 10:21:59.044431
16	sms-perimeter	0	f	sms-perimeter		f	2013-01-15 10:21:59.133437
20	interior-trouble-restore	0	f	interior-trouble-restore		f	2013-01-15 10:21:59.178031
45	tamper-trouble-restore	0	f	tamper-trouble-restore		f	2013-01-15 10:21:59.456586
50	burglary-trouble-restore	0	f	burglary-trouble-restore		f	2013-01-15 10:21:59.512413
52	acfail	0	f	acfail		f	2013-01-15 10:21:59.534501
53	acrestore	0	f	acrestore		f	2013-01-15 10:21:59.545724
54	batterylow	0	f	batterylow		f	2013-01-15 10:21:59.556487
70	sms-earthquake	0	f	sms-earthquake		f	2013-01-15 10:21:59.734784
73	alarm-call-phone-mobile	0	f	alarm-call-phone-mobile		f	2013-01-15 10:21:59.768537
78	account-edited	0	f	account-edited		f	2013-01-15 10:21:59.823722
79	account-created	0	f	account-created		f	2013-01-15 10:21:59.837153
80	account-user-edited	0	f	account-user-edited		f	2013-01-15 10:21:59.846196
94	reserver11	0	f	Undefined		f	2013-01-15 10:22:00.008328
97	reserver14	0	f	Undefined		f	2013-01-15 10:22:00.035851
98	reserver15	0	f	reserver23		f	2013-01-15 10:22:00.04696
102	reserver19	0	f	reserver27		f	2013-01-15 10:22:00.091421
105	reserver22	0	f	reserver30		f	2013-01-15 10:22:00.124888
107	reserver24	0	f	Undefined		f	2013-01-15 10:22:00.147107
109	reserver26	0	f	reserver34		f	2013-01-15 10:22:00.169834
110	reserver27	0	f	reserver28		f	2013-01-15 10:22:00.180439
113	reserver30	0	f	reserver31		f	2013-01-15 10:22:00.213679
114	reserver31	0	f	reserver32		f	2013-01-15 10:22:00.224979
115	reserver32	0	f	reserver33		f	2013-01-15 10:22:00.236144
116	reserver33	0	f	reserver34		f	2013-01-15 10:22:00.24735
117	reserver34	0	f	reserver34		f	2013-01-15 10:22:00.258661
\.


--
-- TOC entry 2629 (class 0 OID 26381)
-- Dependencies: 224 2631
-- Data for Name: groups; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY groups (idgroup, enable, name, note, ts) FROM stdin;
\.


--
-- TOC entry 2767 (class 0 OID 0)
-- Dependencies: 223
-- Name: groups_idgroup_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('groups_idgroup_seq', 1, false);


--
-- TOC entry 2609 (class 0 OID 17389)
-- Dependencies: 198 2631
-- Data for Name: keywords; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY keywords (idkeyword, enable, keyword, ideventtype, note, ts) FROM stdin;
\.


--
-- TOC entry 2768 (class 0 OID 0)
-- Dependencies: 197
-- Name: keywords_idkeyword_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('keywords_idkeyword_seq', 1, false);


--
-- TOC entry 2623 (class 0 OID 26202)
-- Dependencies: 215 2631
-- Data for Name: notification_templates; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY notification_templates (idnotiftempl, description, message, ts) FROM stdin;
1	Este es el mensaje a enviar	Auxilo me &U01 mantat	2012-12-03 00:35:04.343385
\.


--
-- TOC entry 2769 (class 0 OID 0)
-- Dependencies: 214
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('notification_templates_idnotiftempl_seq', 1, true);


--
-- TOC entry 2598 (class 0 OID 17108)
-- Dependencies: 187 2631
-- Data for Name: panelmodel; Type: TABLE DATA; Schema: opensaga; Owner: postgres
--

COPY panelmodel (idpanelmodel, name, model, version, note, ts) FROM stdin;
\.


--
-- TOC entry 2770 (class 0 OID 0)
-- Dependencies: 186
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE SET; Schema: opensaga; Owner: postgres
--

SELECT pg_catalog.setval('panelmodel_idpanelmodel_seq', 1, false);


SET search_path = public, pg_catalog;

--
-- TOC entry 2621 (class 0 OID 26177)
-- Dependencies: 213 2631
-- Data for Name: address_city; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY address_city (idcity, idstate, name, ts) FROM stdin;
1	1	Quito	2012-12-03 00:37:19.528583
\.


--
-- TOC entry 2617 (class 0 OID 26134)
-- Dependencies: 209 2631
-- Data for Name: address_country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY address_country (idcountry, name, code, ts) FROM stdin;
1	Ecuador	593	2012-12-03 00:37:52.343905
2	cOLOMBIA	000	2012-12-03 00:37:52.343905
\.


--
-- TOC entry 2625 (class 0 OID 26237)
-- Dependencies: 217 2631
-- Data for Name: address_sector; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY address_sector (idsector, idcity, name, ts) FROM stdin;
1	1	Tumbaco	2012-12-03 00:38:19.237276
2	1	Cumbaya	2012-12-03 00:38:19.237276
\.


--
-- TOC entry 2771 (class 0 OID 0)
-- Dependencies: 216
-- Name: address_sector_idsector_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('address_sector_idsector_seq', 2, true);


--
-- TOC entry 2619 (class 0 OID 26156)
-- Dependencies: 211 2631
-- Data for Name: address_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY address_states (idstate, idcountry, name, code, ts) FROM stdin;
1	1	Pichincha	2	2012-12-03 00:38:43.494419
\.


--
-- TOC entry 2627 (class 0 OID 26257)
-- Dependencies: 219 2631
-- Data for Name: address_subsector; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY address_subsector (idsubsector, idsector, name, ts) FROM stdin;
1	1	Barrio la dolorosa	2012-12-03 00:39:08.749004
\.


--
-- TOC entry 2772 (class 0 OID 0)
-- Dependencies: 218
-- Name: address_subsector_idsubsector_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('address_subsector_idsubsector_seq', 1, true);


--
-- TOC entry 2588 (class 0 OID 16622)
-- Dependencies: 177 2631
-- Data for Name: blacklist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blacklist (idbl, idprovider, idphone, note, ts) FROM stdin;
\.


--
-- TOC entry 2773 (class 0 OID 0)
-- Dependencies: 176
-- Name: blacklist_idbl_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blacklist_idbl_seq', 1, false);


--
-- TOC entry 2774 (class 0 OID 0)
-- Dependencies: 212
-- Name: city_idcity_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('city_idcity_seq', 1, true);


--
-- TOC entry 2576 (class 0 OID 16387)
-- Dependencies: 165 2631
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contacts (idcontact, enable, xxxtitle, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note, idaddress, ts, title) FROM stdin;
13	f	0	Jose	Soto	0	1990-01-17	0							2013-01-03 16:41:04.147281	Sr.
7	f	0	Edwin	De La Cruz	1	1980-08-21	2	00099878	ddd	ddddd	dd	ok		2013-01-13 13:24:42.445567	Sr.
14	f	0	Julio	Jaramillo	0	1990-01-29	1	543434353	hhhd.com	hshshds@hh.com	sggss@ddd.com.net	Esta es la nota		2013-01-13 13:25:03.882917	Sr.
12	f	0	Josue	De La Cruz	0	1980-08-22	0	00099878	ddd	ddddd	dd	notits		2013-01-14 07:16:06.666667	Ing.
10	t	0	Erika	DLCA	0	1899-12-27	0			sddd@ff.com		jj		2013-01-15 10:27:01.919142	Tecnologo
\.


--
-- TOC entry 2775 (class 0 OID 0)
-- Dependencies: 164
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('contacts_id_seq', 14, true);


--
-- TOC entry 2776 (class 0 OID 0)
-- Dependencies: 208
-- Name: country_idcountry_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('country_idcountry_seq', 2, true);


--
-- TOC entry 2589 (class 0 OID 16696)
-- Dependencies: 178 2631
-- Data for Name: currentportsproviders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY currentportsproviders (idport, port, cimi, imei, idprovider, lastupdate, idmodem) FROM stdin;
2	/dev/ttyACM0	740010107143639	353612013057216	5	2012-12-08 17:44:16.594136	8
\.


--
-- TOC entry 2593 (class 0 OID 16833)
-- Dependencies: 182 2631
-- Data for Name: incomingcalls; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY incomingcalls (idincall, datecall, idport, idphone, callaction, phone, note, flag1, flag2, flag3, flag4, flag5, idmodem, ts) FROM stdin;
10	2012-10-21 19:27:05.245921	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
7	2012-10-21 18:09:39.208381	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
6	2012-10-21 17:34:41.982891	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
12	2012-10-30 09:45:46.100293	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
13	2012-10-30 09:51:38.731804	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
5	2012-10-21 17:34:17.364147	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
8	2012-10-21 18:10:14.890678	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
33	2012-11-09 02:15:16.800219	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
11	2012-10-30 09:32:43.932976	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
16	2012-11-06 05:03:03.16712	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
29	2012-11-09 00:30:54.485449	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
15	2012-10-30 22:47:40.990614	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
21	2012-11-06 08:11:34.130995	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
9	2012-10-21 18:23:14.600686	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
30	2012-11-09 00:32:08.873298	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
18	2012-11-06 05:22:56.063586	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
17	2012-11-06 05:03:26.709115	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
31	2012-11-09 00:32:40.447122	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
34	2012-11-17 02:17:57.582871	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
28	2012-11-08 23:53:55.257976	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
19	2012-11-06 05:25:56.522629	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
20	2012-11-06 05:28:44.531237	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
22	2012-11-06 09:40:20.034876	2	4	0	0991443001		2	0	0	0	0	0	2012-12-03 00:41:18.287161
23	2012-11-06 09:41:37.216068	2	4	0	0991443001		2	0	0	0	0	0	2012-12-03 00:41:18.287161
32	2012-11-09 01:58:58.161052	2	3	0	0982448598		1	0	0	0	0	0	2012-12-03 00:41:18.287161
35	2012-12-05 11:33:13.380164	2	3	0	0982448598		1	0	0	0	0	0	2012-12-05 11:34:17.415732
1	2012-10-21 17:30:46.621118	0	0	0	123455	innote text	3	0	0	0	0	0	2013-01-15 13:41:58.304927
2	2012-10-21 17:31:34.294586	2	0	0	0982448598		3	0	0	0	0	0	2013-01-15 13:41:58.304927
3	2012-10-21 17:33:28.935915	2	0	0	0982448598		3	0	0	0	0	0	2013-01-15 13:41:58.304927
4	2012-10-21 17:33:33.986637	2	0	0	0982448598		3	0	0	0	0	0	2013-01-15 13:41:58.304927
14	2012-10-30 19:46:05.154104	2	0	0	025004700		3	0	0	0	0	0	2013-01-15 13:41:58.304927
24	2012-11-06 10:59:25.744843	2	0	0	0991443001		3	0	0	0	0	0	2013-01-15 13:41:58.304927
25	2012-11-06 11:35:51.506449	2	0	0	02100034		3	0	0	0	0	0	2013-01-15 13:41:58.304927
26	2012-11-06 11:42:51.773974	2	0	0	02100034		3	0	0	0	0	0	2013-01-15 13:41:58.304927
37	2012-12-08 13:20:02.865266	2	3	0	0982448598		1	0	0	0	0	0	2012-12-08 13:20:05.879166
27	2012-11-06 11:45:12.641625	2	0	0	02100034		3	0	0	0	0	0	2013-01-15 13:41:58.304927
36	2012-12-05 11:36:44.0637	2	3	0	0982448598		1	0	0	0	0	0	2012-12-05 11:36:46.262737
\.


--
-- TOC entry 2777 (class 0 OID 0)
-- Dependencies: 181
-- Name: incomingcalls_idincall_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('incomingcalls_idincall_seq', 37, true);


--
-- TOC entry 2611 (class 0 OID 17582)
-- Dependencies: 201 2631
-- Data for Name: modem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY modem (idmodem, imei, manufacturer, model, revision, note, ts) FROM stdin;
8	353612013057216	Motorola CE, Copyright 2000	"GSM1800","GSM1900","GSM850","MODEL=L6i"	R3443H1_G_0A.65.0BR		2012-12-03 00:42:00.560719
15	520338421575569	SIEMENS	TC35	REVISION 04.00		2012-12-03 00:42:00.560719
16		EVDO Datacard	CE100			2012-12-03 00:42:00.560719
17	0123456789	unknown	unknown	unknown		2012-12-08 11:21:37.641585
\.


--
-- TOC entry 2778 (class 0 OID 0)
-- Dependencies: 200
-- Name: modem_idmodem_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('modem_idmodem_seq', 17, true);


--
-- TOC entry 2578 (class 0 OID 16423)
-- Dependencies: 167 2631
-- Data for Name: phones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY phones (idphone, idcontact, enable, phone, typephone, idprovider, note, geox, geoy, idaddress, phone_ext, ubiphone, address, ts) FROM stdin;
10	7	t	0982448598	1	6	okl J	0.119999997	0.232999995		 	1	La direccionn ha cambiado	2013-01-14 07:32:12.895542
3	7	t	4646788	0	1	okl	NaN	NaN		 	0	La misma direccion de antes	2013-01-14 07:32:47.148974
12	7	t	9897	2	7	sss	NaN	NaN			2		2013-01-15 10:28:34.137136
11	14	t	1234	0	0	mi nota hhhh j h	NaN	NaN			0	La misma calle de ayer	2013-01-09 05:46:56.106115
9	13	t	224545	0	0	jj	NaN	NaN			0	jjj	2013-01-09 05:47:19.944177
7	7	t	77574123	0	11	nuevo ggg	NaN	NaN			0		2013-01-13 11:48:29.436174
\.


--
-- TOC entry 2779 (class 0 OID 0)
-- Dependencies: 166
-- Name: phones_idphone_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('phones_idphone_seq', 12, true);


--
-- TOC entry 2580 (class 0 OID 16452)
-- Dependencies: 169 2631
-- Data for Name: provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY provider (idprovider, enable, cimi, name, note, ts) FROM stdin;
8	f	740020080212988	Undefined	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2012-12-03 00:43:04.518839
4	f	ssdsfsdfdsf	Proveedor 1	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:39:33.232543
1	t	0000	Sin restriccion	No hay restriccion	2013-01-10 05:39:43.099891
5	t	740010107143639	Proveedor 3	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:39:58.758855
6	f	740020120072446	Proveedor 4	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:40:04.206724
7	f	unknow	Provedor 5	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:40:09.166579
9	f	unknown	Proveedor 7	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:40:14.92097
10	f	740020756085046	Proveedor 8	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:40:20.468446
11	f	0000000000	Proveedor 9	No exitia previamente este cimi asi que fue creado automaticamente por usmsd	2013-01-10 05:40:25.634491
\.


--
-- TOC entry 2780 (class 0 OID 0)
-- Dependencies: 168
-- Name: provider_idprovider_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('provider_idprovider_seq', 11, true);


--
-- TOC entry 2582 (class 0 OID 16522)
-- Dependencies: 171 2631
-- Data for Name: smsin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY smsin (idsmsin, dateload, idprovider, idphone, phone, datesms, message, note, idport, status, flag1, flag2, flag3, flag4, flag5, ts) FROM stdin;
1	2012-10-21 12:13:48.77956	5	0	1234	1990-01-01 00:00:00	HOLAMMUNDO		1	2	0	0	0	0	0	2012-12-03 00:45:18.464493
2	2012-10-21 12:13:58.839314	5	0	1234	1990-01-01 00:00:00	HOLAMMUNDO		1	2	0	0	0	0	0	2012-12-03 00:45:18.464493
3	2012-10-21 12:14:08.133097	5	0	1234	1990-01-01 00:00:00	HOLAMMUNDO		1	2	0	0	0	0	0	2012-12-03 00:45:18.464493
4	2012-10-21 12:14:18.041646	5	0	1234	1990-01-01 00:00:00	HOLAMMUNDO		1	2	0	0	0	0	0	2012-12-03 00:45:18.464493
5	2012-10-21 12:17:57.031536	8	0	+1234	2012-10-19 11:41:28	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
6	2012-10-21 12:17:57.186592	8	0	+1234	2012-10-19 11:19:47	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
7	2012-10-21 12:17:57.307763	8	0	+1234	2012-10-19 10:58:51	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
8	2012-10-21 12:17:57.430576	8	0	+1234	2012-10-19 10:31:14	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
9	2012-10-21 12:17:57.555658	8	0	+1234	2012-10-19 03:01:04	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
10	2012-10-21 12:17:57.791966	8	0	+1234	2012-10-19 02:44:12	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
11	2012-10-21 12:17:57.969056	8	0	2533	2012-10-11 15:04:31	ERIKA TATIANApor su negativa de pago HOY su cuenta incremento a  76.5y pasa a LEGAL evite proceso Lic Andrade 0993990130 LBEL 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
12	2012-10-21 12:17:58.148486	8	0	3333	2012-10-10 15:34:38	5 SMS GRATIS! Responde SI, el acumulado de esta semana debe ser tuyo! No dejes que te lo quiten! P.Final x msj $0.56		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
13	2012-10-21 12:17:58.258906	8	0	2533	2012-10-10 09:55:22	ERIKA TATIANA Su saldo de $ 12.5 pago URGENTE evite recargos Cobranzas por $64 evite futuras molestias Lic Andrade 0993990130  @		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
14	2012-10-21 12:17:58.407898	8	0	2533	2012-10-09 16:02:03	ERIKA TATIANA su cuenta vencida por $ 12.5 Registe su pago y evite futuras molestias  Lic Andrade 0993990130  		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
15	2012-10-21 12:17:58.516078	8	0	2533	2012-10-09 10:45:07	 ERIKA TATIANA no hemos registrado su pago de $ 12.5 LBEL Favor comunicarse con su Ejecutiva de cuenta  Lic Andrade 0993990130  		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
16	2012-10-21 12:17:58.628659	8	0	+59399491282	2012-08-30 18:56:28	Querida consultora Lbel, hoy es el ultimo dia para pasar pedido de campaña 13, no pierda su horno eléctrico, y si tiene saldo puede pagar maximo mañana 12am 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
17	2012-10-21 12:17:58.771047	8	0	+59399491282	2012-08-21 12:24:45	Querida consultora Lbel no olvide el pedido de campaña 13 pasamos el 28 de agosto, pero si cancela y pasa pedido hasta el 27 gana un regalo especial y el horno@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
18	2012-10-21 12:17:58.895187	8	0	+0016462261376	2012-08-19 09:56:57	Mijo escribe		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
19	2012-10-21 12:17:59.003293	8	0	+0016462261376	2012-08-19 09:26:35	Hola amor da senales de vida		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
20	2012-10-21 12:17:59.118229	8	0	+0016462261376	2012-08-19 09:02:49	Hola mi amor da senales de vida@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
21	2012-10-21 12:17:59.22594	8	0	+59396071225	2012-07-11 10:49:54	Erika llego en 5 minutos no te ocupes ...		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
22	2012-10-21 12:17:59.357623	8	0	+59396071225	2012-07-11 10:07:13	Erika buenos dias soy Daniela ... Estoy ahi a las 10h45 para que me ayudes pintando las uqas de los pies y manos		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
23	2012-10-21 12:17:59.459076	8	0	+59399491282	2012-07-09 15:01:32	Querida consultora Lbel, recuerde que sus cambios de productos ya NO se realizan en vista hermosa, tiene que llamar a los numeros que le llego en su carton    @		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
24	2012-10-21 12:17:59.577142	8	0	+59399022188	2012-07-02 08:59:30	Si ves el mensaje te espero en la pasada de los tumbacos estoy saliendo@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
25	2012-10-21 12:17:59.7822	8	0	+59399022188	2012-07-02 08:11:14	probando mensaje		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
26	2012-10-21 12:17:59.934663	8	0	+59399022188	2012-07-02 08:06:06	probando mensaje		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
27	2012-10-21 12:18:00.072764	8	0	+59399022188	2012-07-01 06:14:58	Contestaras		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
28	2012-10-21 12:18:00.207782	8	0	+59399022188	2012-06-29 04:05:29	Te amo		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
29	2012-10-21 12:18:00.515294	8	0	+59399022188	2012-06-29 04:02:02	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
30	2012-10-21 12:18:00.7085	8	0	+59399022188	2012-06-28 23:17:07	Mi amor no puedo llamar. Mañana te despierto a las cuatro.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
31	2012-10-21 12:18:00.817194	8	0	+59399022188	2012-06-28 20:31:02	Ya llegué		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
32	2012-10-21 12:18:00.98748	8	0	+59399022188	2012-06-28 04:01:10	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
33	2012-10-21 12:18:01.141274	8	0	+59399022188	2012-06-25 21:45:30	Contesta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
34	2012-10-21 12:18:01.30774	8	0	+59388661903	2012-06-25 14:11:28	Rosa soy Raquel este es mi nro también tengo movistar 087807720@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
35	2012-10-21 12:18:01.428471	8	0	+59399022188	2012-06-25 06:00:36	Que ya esta por llegar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
36	2012-10-21 12:18:01.545927	8	0	+59399022188	2012-06-25 05:10:35	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
37	2012-10-21 12:18:01.651945	8	0	+59399022188	2012-06-25 04:34:44	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
38	2012-10-21 12:18:01.764733	8	0	+59399022188	2012-06-23 05:39:21	Ya va		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
39	2012-10-21 12:18:01.882044	8	0	+59399022188	2012-06-23 04:28:10	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
40	2012-10-21 12:18:01.990619	8	0	+59399022188	2012-06-22 22:47:40	Ok. Déjale no mas donde mi mama mañana.@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
41	2012-10-21 12:18:02.24759	8	0	+59399022188	2012-06-22 04:43:54	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
42	2012-10-21 12:18:02.432578	8	0	+59399022188	2012-06-22 04:32:10	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
43	2012-10-21 12:18:02.54036	8	0	+59399022188	2012-06-21 22:09:29	No contesta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
44	2012-10-21 12:18:02.650625	8	0	+59395360022	2012-06-18 10:14:31	Mi amor contestame 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
45	2012-10-21 12:18:02.757525	8	0	+59399022188	2012-06-16 04:24:29	Despierta. Buenos dias mi vida.@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
46	2012-10-21 12:18:02.866996	8	0	+59399022188	2012-06-16 04:21:22	Despierta. Buenos dias mi vida.@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
47	2012-10-21 12:18:03.045231	8	0	+59395360022	2012-06-14 23:20:21	Mijo me voy a levantar a las cuatro a ver que hago me llamar o me mandar mensaje a esa hora para hacerm levantar 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
48	2012-10-21 12:18:03.163172	8	0	+59399022188	2012-06-06 15:27:47	Ya tengo el numero estoy insistiendo con la llamada porque no responden 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
49	2012-10-21 12:18:03.280789	8	0	+59399022188	2012-06-06 15:15:59	Compa cual es el numero del modem		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
50	2012-10-21 12:18:03.411555	8	0	9070	2012-06-04 16:18:35	Gana RECARGAS con el C.S.EMELEC!!! Responde OK a este msje y participas, ademas te suscribes para recibir noticias del equipo. Precio x dia ¿0.17		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
51	2012-10-21 12:18:03.565214	8	0	+16462441769	2012-05-30 15:00:36	El numero es, B938509784 me avisad si lo recibiste		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
52	2012-10-21 12:18:03.755675	8	0	+16462441769	2012-05-29 18:51:12	No pude ya estaba cerrado pero manana temprano lo ago		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
53	2012-10-21 12:18:03.885078	8	0	+1234	2012-05-29 08:46:14	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
54	2012-10-21 12:18:04.019061	8	0	+1234	2012-05-29 08:41:24	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
55	2012-10-21 12:18:04.132242	8	0	+1234	2012-05-29 08:41:20	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
56	2012-10-21 12:18:04.243247	8	0	+1234	2012-05-29 08:41:16	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
57	2012-10-21 12:18:04.370938	8	0	+1234	2012-05-29 08:41:12	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
58	2012-10-21 12:18:04.477385	8	0	+16462441769	2012-05-28 11:52:56	Sera manana pq hoy es dia de fiesta y esta cerrado todo@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
59	2012-10-21 12:18:04.587365	8	0	3333	2012-05-27 16:04:57	5 SMS Gratis! Envia SI al 3333 si tu CLARO termina en 01 ! Tu iPhone 4S y los 1000 dolares de hoy estan listos para ti, NO LOS DEJES IR!!!  Si al 3333		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
60	2012-10-21 12:18:04.714879	8	0	+59399022188	2012-05-27 05:44:44	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
61	2012-10-21 12:18:04.819894	8	0	+59399022188	2012-05-27 05:42:49	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
62	2012-10-21 12:18:04.982146	8	0	+59399022188	2012-05-27 05:34:04	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
63	2012-10-21 12:18:05.084983	8	0	+59399022188	2012-05-27 05:11:30	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
64	2012-10-21 12:18:05.20577	8	0	+59399022188	2012-05-27 05:11:06	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
65	2012-10-21 12:18:05.391179	8	0	3C12	2012-05-26 11:43:15	Se acredito USD 1, Precio Oficial de la recarga USD 1.Si no puedes enviar SMS o llamar ACTUALIZA tus DATOS. Marca al *145# Si ya lo hiciste DESATIENDE este SMS@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
66	2012-10-21 12:18:05.656913	8	0	+59399022188	2012-05-25 16:07:27	Esta listo		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
67	2012-10-21 12:18:05.782453	8	0	+6826	2012-05-22 14:08:50	Estimado Cliente actualiza los parametros de tu celular para que disfrutes al maximo la experiencia movistar! Haz clic en aceptar y listo		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
68	2012-10-21 12:18:05.891626	8	0	+59391443001	2012-05-19 13:38:35	esto es OK\r\nnada mas te toca test\r\nok\r\no\r\nERROR\r\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
69	2012-10-21 12:18:06.004469	8	0	+59391443001	2012-05-19 13:38:29	Veamos un esto es\r\nOK\r\n@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
70	2012-10-21 12:18:06.140904	8	0	+59391443001	2012-05-19 13:38:19	Veamos un esto es\r\nOK\r\n@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
71	2012-10-21 12:18:06.2736	8	0	3C12	2012-05-19 12:03:57	Se acredito USD 1, Precio Oficial de la recarga USD 1.Si no puedes enviar SMS o llamar ACTUALIZA tus DATOS. Marca al *145# Si ya lo hiciste DESATIENDE este SMS@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
72	2012-10-21 12:18:06.400561	8	0	+1234	2012-05-18 19:54:16	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
73	2012-10-21 12:18:06.553062	8	0	+1234	2012-05-18 19:54:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
74	2012-10-21 12:18:06.664772	8	0	+1234	2012-05-18 19:00:32	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
75	2012-10-21 12:18:06.777875	8	0	+59399022188	2012-05-05 11:10:20	Dice edwin que le busqué una libreta de ahorros de produbanco		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
76	2012-10-21 12:18:06.922999	8	0	+59393072898	2012-05-05 11:03:27	Este fin de semana Ofertas INCREIBLES para Mama en DIAS HOME VEGA! Electrodomesticos-Banos-Ceramicas-Hogar. Cdla. La Garzota Junto al Cafe de Tere.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
77	2012-10-21 12:18:07.036404	8	0	+1234	2012-05-05 09:29:05	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
78	2012-10-21 12:18:07.149705	8	0	+1234	2012-05-05 09:28:56	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
79	2012-10-21 12:18:07.257507	8	0	+1234	2012-05-05 09:28:52	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
80	2012-10-21 12:18:07.386621	8	0	+1234	2012-05-04 19:48:14	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
81	2012-10-21 12:18:07.509602	8	0	+1234	2012-05-04 19:48:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
82	2012-10-21 12:18:07.675	8	0	+1234	2012-05-04 19:47:43	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
83	2012-10-21 12:18:07.779289	8	0	+1234	2012-05-04 19:19:55	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
84	2012-10-21 12:18:07.94904	8	0	+1234	2012-05-04 19:19:50	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
85	2012-10-21 12:18:08.153864	8	0	+59399022188	2012-05-04 19:07:44	Cobrar el cheque de ercom. El proximo lunes.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
86	2012-10-21 12:18:08.340572	8	0	+1234	2012-05-04 19:06:55	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
87	2012-10-21 12:18:08.469394	8	0	+1234	2012-05-04 18:56:09	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
88	2012-10-21 12:18:08.582453	8	0	+1234	2012-05-04 18:49:44	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
89	2012-10-21 12:18:08.69626	8	0	+59399022188	2012-05-04 18:16:14	Cobrar el cheque de ercom. El proximo lunes.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
90	2012-10-21 12:18:08.802212	8	0	+1234	2012-05-04 18:14:24	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
91	2012-10-21 12:18:08.922795	8	0	+1234	2012-05-04 18:05:44	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
92	2012-10-21 12:18:09.063066	8	0	+1234	2012-05-04 17:54:31	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
93	2012-10-21 12:18:09.191532	8	0	+1234	2012-05-04 17:49:02	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
94	2012-10-21 12:18:09.305174	8	0	+1234	2012-05-04 16:15:46	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
95	2012-10-21 12:18:09.42789	8	0	+1234	2012-05-04 16:15:42	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
96	2012-10-21 12:18:09.542342	8	0	+1234	2012-05-04 15:44:39	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
97	2012-10-21 12:18:09.677898	8	0	+1234	2012-05-04 14:55:50	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
98	2012-10-21 12:18:09.783817	8	0	+1234	2012-05-04 14:55:43	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
99	2012-10-21 12:18:09.892962	8	0	+1234	2012-05-03 19:49:22	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
100	2012-10-21 12:18:10.004972	8	0	+1234	2012-05-03 19:49:04	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
101	2012-10-21 12:18:10.132803	8	0	+1234	2012-05-03 19:47:59	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
102	2012-10-21 12:18:10.262436	8	0	+1234	2012-05-03 19:47:39	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
103	2012-10-21 12:18:10.3925	8	0	+1234	2012-05-03 19:45:43	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
104	2012-10-21 12:18:10.507027	8	0	0982448598	1990-01-01 00:00:00	Este mensaje es desde usmsd proyect 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
105	2012-10-21 12:18:10.623217	8	0	0982448598	1990-01-01 00:00:00	Este mensaje es desde usmsd proyect 		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
106	2012-10-21 12:18:10.740823	8	0	1234	1990-01-01 00:00:00	hola mundo modem tc35\rv@		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
107	2012-10-21 12:21:38.10313	8	0	+1234	2012-10-19 11:41:28	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
108	2012-10-21 12:21:38.47565	8	0	+1234	2012-10-19 11:19:47	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
109	2012-10-21 12:21:38.992023	8	0	+1234	2012-10-19 10:58:51	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
110	2012-10-21 12:21:39.406812	8	0	+1234	2012-10-19 10:31:14	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
111	2012-10-21 12:21:39.843458	8	0	+1234	2012-10-19 03:01:04	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
112	2012-10-21 12:21:40.250676	8	0	+1234	2012-10-19 02:44:12	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
113	2012-10-21 12:21:40.628535	8	0	2533	2012-10-11 15:04:31	ERIKA TATIANApor su negativa de pago HOY su cuenta incremento a  76.5y pasa a LEGAL evite proceso Lic Andrade 0993990130 LBEL 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
114	2012-10-21 12:21:41.059606	8	0	3333	2012-10-10 15:34:38	5 SMS GRATIS! Responde SI, el acumulado de esta semana debe ser tuyo! No dejes que te lo quiten! P.Final x msj $0.56		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
115	2012-10-21 12:21:41.463061	8	0	2533	2012-10-10 09:55:22	ERIKA TATIANA Su saldo de $ 12.5 pago URGENTE evite recargos Cobranzas por $64 evite futuras molestias Lic Andrade 0993990130  @		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
116	2012-10-21 12:21:41.877897	8	0	2533	2012-10-09 16:02:03	ERIKA TATIANA su cuenta vencida por $ 12.5 Registe su pago y evite futuras molestias  Lic Andrade 0993990130  		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
117	2012-10-21 12:21:42.337811	8	0	2533	2012-10-09 10:45:07	 ERIKA TATIANA no hemos registrado su pago de $ 12.5 LBEL Favor comunicarse con su Ejecutiva de cuenta  Lic Andrade 0993990130  		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
118	2012-10-21 12:21:42.718668	8	0	+59399491282	2012-08-30 18:56:28	Querida consultora Lbel, hoy es el ultimo dia para pasar pedido de campaña 13, no pierda su horno eléctrico, y si tiene saldo puede pagar maximo mañana 12am 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
119	2012-10-21 12:21:43.153372	8	0	+59399491282	2012-08-21 12:24:45	Querida consultora Lbel no olvide el pedido de campaña 13 pasamos el 28 de agosto, pero si cancela y pasa pedido hasta el 27 gana un regalo especial y el horno@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
120	2012-10-21 12:21:43.530365	8	0	+0016462261376	2012-08-19 09:56:57	Mijo escribe		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
121	2012-10-21 12:21:43.953719	8	0	+0016462261376	2012-08-19 09:26:35	Hola amor da senales de vida		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
122	2012-10-21 12:21:44.389112	8	0	+0016462261376	2012-08-19 09:02:49	Hola mi amor da senales de vida@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
123	2012-10-21 12:21:44.786827	8	0	+59396071225	2012-07-11 10:49:54	Erika llego en 5 minutos no te ocupes ...		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
124	2012-10-21 12:21:45.221225	8	0	+59396071225	2012-07-11 10:07:13	Erika buenos dias soy Daniela ... Estoy ahi a las 10h45 para que me ayudes pintando las uqas de los pies y manos		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
125	2012-10-21 12:21:45.586774	8	0	+59399491282	2012-07-09 15:01:32	Querida consultora Lbel, recuerde que sus cambios de productos ya NO se realizan en vista hermosa, tiene que llamar a los numeros que le llego en su carton    @		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
126	2012-10-21 12:21:45.994938	8	0	+59399022188	2012-07-02 08:59:30	Si ves el mensaje te espero en la pasada de los tumbacos estoy saliendo@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
127	2012-10-21 12:21:46.389977	8	0	+59399022188	2012-07-02 08:11:14	probando mensaje		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
128	2012-10-21 12:21:46.812533	8	0	+59399022188	2012-07-02 08:06:06	probando mensaje		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
129	2012-10-21 12:21:47.241752	8	0	+59399022188	2012-07-01 06:14:58	Contestaras		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
130	2012-10-21 12:21:47.628423	8	0	+59399022188	2012-06-29 04:05:29	Te amo		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
131	2012-10-21 12:21:48.023918	8	0	+59399022188	2012-06-29 04:02:02	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
132	2012-10-21 12:21:48.467744	8	0	+59399022188	2012-06-28 23:17:07	Mi amor no puedo llamar. Mañana te despierto a las cuatro.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
133	2012-10-21 12:21:48.859399	8	0	+59399022188	2012-06-28 20:31:02	Ya llegué		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
134	2012-10-21 12:21:49.269339	8	0	+59399022188	2012-06-28 04:01:10	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
135	2012-10-21 12:21:49.682607	8	0	+59399022188	2012-06-25 21:45:30	Contesta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
136	2012-10-21 12:21:50.118601	8	0	+59388661903	2012-06-25 14:11:28	Rosa soy Raquel este es mi nro también tengo movistar 087807720@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
137	2012-10-21 12:21:50.464994	8	0	+59399022188	2012-06-25 06:00:36	Que ya esta por llegar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
138	2012-10-21 12:21:50.914496	8	0	+59399022188	2012-06-25 05:10:35	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
139	2012-10-21 12:21:51.331221	8	0	+59399022188	2012-06-25 04:34:44	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
140	2012-10-21 12:21:51.726495	8	0	+59399022188	2012-06-23 05:39:21	Ya va		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
141	2012-10-21 12:21:52.206866	8	0	+59399022188	2012-06-23 04:28:10	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
142	2012-10-21 12:21:52.56293	8	0	+59399022188	2012-06-22 22:47:40	Ok. Déjale no mas donde mi mama mañana.@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
143	2012-10-21 12:21:52.980344	8	0	+59399022188	2012-06-22 04:43:54	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
144	2012-10-21 12:21:53.359356	8	0	+59399022188	2012-06-22 04:32:10	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
145	2012-10-21 12:21:53.770009	8	0	+59399022188	2012-06-21 22:09:29	No contesta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
146	2012-10-21 12:21:54.225374	8	0	+59395360022	2012-06-18 10:14:31	Mi amor contestame 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
147	2012-10-21 12:21:54.661807	8	0	+59399022188	2012-06-16 04:24:29	Despierta. Buenos dias mi vida.@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
148	2012-10-21 12:21:55.008791	8	0	+59399022188	2012-06-16 04:21:22	Despierta. Buenos dias mi vida.@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
149	2012-10-21 12:21:55.394556	8	0	+59395360022	2012-06-14 23:20:21	Mijo me voy a levantar a las cuatro a ver que hago me llamar o me mandar mensaje a esa hora para hacerm levantar 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
150	2012-10-21 12:21:55.800952	8	0	+59399022188	2012-06-06 15:27:47	Ya tengo el numero estoy insistiendo con la llamada porque no responden 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
151	2012-10-21 12:21:56.214663	8	0	+59399022188	2012-06-06 15:15:59	Compa cual es el numero del modem		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
152	2012-10-21 12:21:56.625359	8	0	9070	2012-06-04 16:18:35	Gana RECARGAS con el C.S.EMELEC!!! Responde OK a este msje y participas, ademas te suscribes para recibir noticias del equipo. Precio x dia ¿0.17		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
153	2012-10-21 12:21:57.020023	8	0	+16462441769	2012-05-30 15:00:36	El numero es, B938509784 me avisad si lo recibiste		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
154	2012-10-21 12:21:57.508863	8	0	+16462441769	2012-05-29 18:51:12	No pude ya estaba cerrado pero manana temprano lo ago		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
155	2012-10-21 12:21:57.886267	8	0	+1234	2012-05-29 08:46:14	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
156	2012-10-21 12:21:58.405663	8	0	+1234	2012-05-29 08:41:24	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
157	2012-10-21 12:21:58.786595	8	0	+1234	2012-05-29 08:41:20	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
158	2012-10-21 12:21:59.266478	8	0	+1234	2012-05-29 08:41:16	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
159	2012-10-21 12:21:59.658173	8	0	+1234	2012-05-29 08:41:12	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
160	2012-10-21 12:22:00.064886	8	0	+16462441769	2012-05-28 11:52:56	Sera manana pq hoy es dia de fiesta y esta cerrado todo@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
161	2012-10-21 12:22:00.457489	8	0	3333	2012-05-27 16:04:57	5 SMS Gratis! Envia SI al 3333 si tu CLARO termina en 01 ! Tu iPhone 4S y los 1000 dolares de hoy estan listos para ti, NO LOS DEJES IR!!!  Si al 3333		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
162	2012-10-21 12:22:00.888499	8	0	+59399022188	2012-05-27 05:44:44	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
163	2012-10-21 12:22:01.305425	8	0	+59399022188	2012-05-27 05:42:49	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
164	2012-10-21 12:22:01.663446	8	0	+59399022188	2012-05-27 05:34:04	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
165	2012-10-21 12:22:02.105171	8	0	+59399022188	2012-05-27 05:11:30	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
166	2012-10-21 12:22:02.547291	8	0	+59399022188	2012-05-27 05:11:06	Despierta		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
167	2012-10-21 12:22:02.950522	8	0	3C12	2012-05-26 11:43:15	Se acredito USD 1, Precio Oficial de la recarga USD 1.Si no puedes enviar SMS o llamar ACTUALIZA tus DATOS. Marca al *145# Si ya lo hiciste DESATIENDE este SMS@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
168	2012-10-21 12:22:03.301457	8	0	+59399022188	2012-05-25 16:07:27	Esta listo		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
169	2012-10-21 12:22:03.645287	8	0	+6826	2012-05-22 14:08:50	Estimado Cliente actualiza los parametros de tu celular para que disfrutes al maximo la experiencia movistar! Haz clic en aceptar y listo		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
170	2012-10-21 12:22:04.049202	8	0	+59391443001	2012-05-19 13:38:35	esto es OK\r\nnada mas te toca test\r\nok\r\no\r\nERROR\r\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
171	2012-10-21 12:22:04.412014	8	0	+59391443001	2012-05-19 13:38:29	Veamos un esto es\r\nOK\r\n@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
172	2012-10-21 12:22:04.919847	8	0	+59391443001	2012-05-19 13:38:19	Veamos un esto es\r\nOK\r\n@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
173	2012-10-21 12:22:05.315164	8	0	3C12	2012-05-19 12:03:57	Se acredito USD 1, Precio Oficial de la recarga USD 1.Si no puedes enviar SMS o llamar ACTUALIZA tus DATOS. Marca al *145# Si ya lo hiciste DESATIENDE este SMS@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
174	2012-10-21 12:22:05.678458	8	0	+1234	2012-05-18 19:54:16	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
175	2012-10-21 12:22:06.084408	8	0	+1234	2012-05-18 19:54:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
176	2012-10-21 12:22:06.462298	8	0	+1234	2012-05-18 19:00:32	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
177	2012-10-21 12:22:06.825335	8	0	+59399022188	2012-05-05 11:10:20	Dice edwin que le busqué una libreta de ahorros de produbanco		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
178	2012-10-21 12:22:07.30563	8	0	+59393072898	2012-05-05 11:03:27	Este fin de semana Ofertas INCREIBLES para Mama en DIAS HOME VEGA! Electrodomesticos-Banos-Ceramicas-Hogar. Cdla. La Garzota Junto al Cafe de Tere.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
179	2012-10-21 12:22:07.730639	8	0	+1234	2012-05-05 09:29:05	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
180	2012-10-21 12:22:08.113623	8	0	+1234	2012-05-05 09:28:56	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
181	2012-10-21 12:22:08.512387	8	0	+1234	2012-05-05 09:28:52	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
182	2012-10-21 12:22:08.866568	8	0	+1234	2012-05-04 19:48:14	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
183	2012-10-21 12:22:09.012444	5	0	1234	1990-01-01 00:00:00	HOLAMMUNDO		1	2	0	0	0	0	0	2012-12-03 00:45:18.464493
184	2012-10-21 12:22:09.288744	8	0	+1234	2012-05-04 19:48:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
185	2012-10-21 12:22:09.640041	8	0	+1234	2012-05-04 19:47:43	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
186	2012-10-21 12:22:10.268841	8	0	+1234	2012-05-04 19:19:55	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
187	2012-10-21 12:22:10.698067	8	0	+1234	2012-05-04 19:19:50	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
188	2012-10-21 12:22:11.03904	8	0	+59399022188	2012-05-04 19:07:44	Cobrar el cheque de ercom. El proximo lunes.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
189	2012-10-21 12:22:11.419535	8	0	+1234	2012-05-04 19:06:55	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
190	2012-10-21 12:22:11.842634	8	0	+1234	2012-05-04 18:56:09	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
191	2012-10-21 12:22:12.263711	8	0	+1234	2012-05-04 18:49:44	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
192	2012-10-21 12:22:12.655341	8	0	+59399022188	2012-05-04 18:16:14	Cobrar el cheque de ercom. El proximo lunes.		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
193	2012-10-21 12:22:13.010593	8	0	+1234	2012-05-04 18:14:24	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
194	2012-10-21 12:22:13.374821	8	0	+1234	2012-05-04 18:05:44	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
195	2012-10-21 12:22:13.782042	8	0	+1234	2012-05-04 17:54:31	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
196	2012-10-21 12:22:14.213588	8	0	+1234	2012-05-04 17:49:02	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
197	2012-10-21 12:22:14.607687	8	0	+1234	2012-05-04 16:15:46	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
198	2012-10-21 12:22:15.015838	8	0	+1234	2012-05-04 16:15:42	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
199	2012-10-21 12:22:15.427046	8	0	+1234	2012-05-04 15:44:39	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
200	2012-10-21 12:22:15.849472	8	0	+1234	2012-05-04 14:55:50	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
201	2012-10-21 12:22:16.188184	8	0	+1234	2012-05-04 14:55:43	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
202	2012-10-21 12:22:16.572834	8	0	+1234	2012-05-03 19:49:22	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
203	2012-10-21 12:22:16.935654	8	0	+1234	2012-05-03 19:49:04	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
204	2012-10-21 12:22:17.321254	8	0	+1234	2012-05-03 19:47:59	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
205	2012-10-21 12:22:17.710396	8	0	+1234	2012-05-03 19:47:39	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
206	2012-10-21 12:22:18.071957	8	0	+1234	2012-05-03 19:45:43	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
207	2012-10-21 12:22:18.541197	8	0	0982448598	1990-01-01 00:00:00	Este mensaje es desde usmsd proyect 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
208	2012-10-21 12:22:18.883233	8	0	0982448598	1990-01-01 00:00:00	Este mensaje es desde usmsd proyect 		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
209	2012-10-21 12:22:19.333766	8	0	1234	1990-01-01 00:00:00	hola mundo modem tc35\rv@		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
210	2012-10-21 12:22:40.936067	8	0	+0016462261376	1990-01-01 00:00:00	Hola mi amor ya estoy yendo al trabajo no se xq pero no se estan yendo los mensajes al celu me mandas un mensaje al celu del correo para responderte mas rapido y mi amor para ver si hoy noche nos podemos ver los amo mis preciosos\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
211	2012-10-21 12:22:41.418552	8	0	+59395360022	1990-01-01 00:00:00	Mi amor estoy feliz feliz feliz ya me dieron mi propia mesa tengo mi propio escritorio que emocion y te cuento que me van a dar uniforme tambiin como que ya no me voy a new york los amo los adoro besitos mis amores\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
212	2012-10-21 12:22:41.778668	8	0	+59395360022	1990-01-01 00:00:00	Mi amor esta un ambiente super lindo te cuento que las chicas me dicen que minimo se hacen unos quince dolares diarios y el fin de semana hasta 50 dolares diarios ya puedes estar renunciando\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
213	2012-10-21 12:22:42.163672	8	0	+16462441769	1990-01-01 00:00:00	Buenos dias hija de mi corazon feliz cumpleanos q disfrutes este dia junto a tu  familia todos te mandan un beso un abrazo deceandote lo mejor en este dia felicidades\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
214	2012-10-21 15:24:13.592089	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
215	2012-10-21 15:24:23.626405	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
216	2012-10-21 15:24:50.759828	5	0	+1234	1990-01-01 00:00:00	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
217	2012-10-21 15:24:55.090196	5	0	+1234	1990-01-01 00:00:00	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
218	2012-10-21 16:46:34.120149	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
219	2012-10-21 16:46:49.385017	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
220	2012-10-21 16:47:03.781766	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
221	2012-10-21 16:47:21.445598	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
222	2012-10-21 16:47:26.894505	5	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
223	2012-10-21 17:11:11.594128	9	0	+1234	1990-01-01 00:00:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
224	2012-10-21 18:08:54.230195	5	0	+593982448598	1990-01-01 00:00:00	Este es m`ama mensaje @gmail.com q~^& cuatro raros\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
225	2012-10-21 18:20:04.610429	5	0	+593982448598	1990-01-01 00:00:00	Otro mensaje se supene que ya no llega con formato internacional\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
226	2012-10-21 18:23:45.110111	5	0	+593982448598	1990-01-01 00:00:00	ojala\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
227	2012-10-21 18:37:24.005724	5	0	+593982448598	1990-01-01 00:00:00	Hhhclhjfdf\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
228	2012-10-21 18:50:18.957752	5	0	+593982448598	1990-01-01 00:00:00	Ya es hora\n		2	0	0	0	0	0	0	2012-12-03 00:45:18.464493
229	2012-10-21 18:50:23.110094	5	0	+593982448598	1990-01-01 00:00:00	Ya es hora\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
230	2012-10-21 18:50:27.306133	5	0	+593982448598	1990-01-01 00:00:00	Ya es hora\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
231	2012-10-21 18:50:31.465658	5	0	+593982448598	1990-01-01 00:00:00	Ya es hora\n		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
232	2012-10-21 18:56:55.904054	5	0	593982448598	1990-01-01 00:00:00	Ya es hora		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
233	2012-10-21 18:59:56.956076	5	0	593982448598	1990-01-01 00:00:00	Ya es hora		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
234	2012-10-21 19:24:29.683414	5	0	593982448598	2012-10-21 18:52:00	Ya es hora		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
235	2012-10-21 19:26:45.829106	5	0	593982448598	2012-10-21 18:52:00	Ya es hora		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
236	2012-10-21 19:28:03.068587	5	0	593982448598	2012-10-21 19:29:42	CNT Movil le informa que usted ha acreditado ¤3.00, su nuevo saldo es: 7.35		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
237	2012-10-30 09:16:38.761636	5	0	3C12	2012-10-23 10:49:56	Estimado cliente, recuerda que puedes hablar a UN CENTAVO mas Imp. el minuto con tu MEJOR AMIGO CLARO que tienes registrado. Yo + Claro Promocion		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
238	2012-10-30 14:27:21.831275	5	0	12355	1990-01-01 00:00:00	Llll		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
239	2012-10-30 14:28:04.180492	5	4	1234	1990-01-01 00:00:00	Llll		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
240	2012-10-30 15:44:03.877281	5	0	092222	1990-01-01 00:00:00	Lll.		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
241	2012-10-30 23:47:55.84911	5	4	1234	2012-10-30 23:32:25	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
242	2012-10-30 23:47:56.514092	5	0	09923333	1990-01-01 00:00:00	Me		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
243	2012-10-31 05:59:34.766214	5	4	1234	2012-10-30 23:27:23	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
244	2012-10-31 06:00:41.195834	5	4	1234	2012-10-30 23:22:21	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
245	2012-10-31 06:00:45.38784	5	4	1234	2012-10-30 23:17:19	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
246	2012-10-31 06:00:49.644499	5	4	1234	2012-10-30 23:12:17	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
247	2012-10-31 06:00:53.669165	5	4	1234	2012-10-30 23:07:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
248	2012-10-31 06:03:48.576601	5	4	1234	2012-10-31 06:05:07	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
249	2012-10-31 06:06:32.431931	5	0	0986664	1990-01-01 00:00:00	Mia		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
250	2012-10-31 06:11:09.841006	5	4	1234	2012-10-31 06:12:14	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
251	2012-10-31 06:11:14.684456	5	4	1234	2012-10-31 06:10:09	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
252	2012-10-31 06:15:37.29076	5	0	09999226666666	1990-01-01 00:00:00	Monono		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
253	2012-10-31 06:15:37.869313	5	0	09533333	1990-01-01 00:00:00	Mios 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
254	2012-10-31 06:15:38.437456	5	4	1234	2012-10-31 06:15:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
255	2012-10-31 06:15:39.003093	5	4	1234	2012-10-31 06:15:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
256	2012-10-31 06:18:23.823622	5	0	09999226666666	1990-01-01 00:00:00	Monono		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
257	2012-10-31 06:18:24.19975	5	0	09533333	1990-01-01 00:00:00	Mios 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
258	2012-10-31 06:18:24.596151	5	4	1234	2012-10-31 06:15:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
259	2012-10-31 06:18:25.022355	5	4	1234	2012-10-31 06:15:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
260	2012-10-31 06:18:45.521674	5	0	09999226666666	1990-01-01 00:00:00	Monono		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
261	2012-10-31 06:18:46.092092	5	0	09533333	1990-01-01 00:00:00	Mios 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
262	2012-10-31 06:18:46.671852	5	4	1234	2012-10-31 06:15:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
263	2012-10-31 06:18:47.252355	5	4	1234	2012-10-31 06:15:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
264	2012-10-31 06:18:47.846473	5	4	1234	2012-10-31 06:20:13	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
265	2012-10-31 06:18:48.458663	5	4	1234	2012-10-31 06:20:17	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
266	2012-10-31 06:18:53.393525	5	0	09999226666666	1990-01-01 00:00:00	Monono		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
267	2012-10-31 06:18:53.989076	5	0	09533333	1990-01-01 00:00:00	Mios 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
268	2012-10-31 06:18:54.60026	5	4	1234	2012-10-31 06:15:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
269	2012-10-31 06:18:55.199528	5	4	1234	2012-10-31 06:15:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
270	2012-10-31 06:21:08.835053	5	0	09999226666666	1990-01-01 00:00:00	Monono		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
271	2012-10-31 06:21:09.411282	5	0	09533333	1990-01-01 00:00:00	Mios 		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
272	2012-10-31 06:21:09.975589	5	4	1234	2012-10-31 06:15:11	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
273	2012-10-31 06:21:10.560349	5	4	1234	2012-10-31 06:15:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
274	2012-10-31 06:21:11.110764	5	4	1234	2012-10-31 06:20:13	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
275	2012-10-31 06:21:11.67059	5	4	1234	2012-10-31 06:20:17	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
276	2012-11-01 09:06:16.95714	5	0	09855222243	1990-01-01 00:00:00	Mika 12 ( a .   mg ja		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
277	2012-11-01 09:06:17.856289	5	4	1234	2012-11-01 06:10:38	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
278	2012-11-01 09:06:18.730689	5	4	1234	2012-11-01 06:15:40	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
279	2012-11-01 09:06:19.521702	5	4	1234	2012-11-01 06:20:43	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
280	2012-11-01 09:06:20.307301	5	4	1234	2012-11-01 06:25:45	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
281	2012-11-01 09:06:21.147253	5	4	1234	2012-11-01 06:30:47	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
282	2012-11-01 09:06:21.963251	5	4	1234	2012-11-01 06:35:50	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
283	2012-11-01 09:06:22.73162	5	4	1234	1990-01-01 00:00:00	hola mundo		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
284	2012-11-04 11:11:47.377822	5	4	1234	2012-11-04 11:14:01	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
285	2012-11-04 11:13:20.729041	5	4	1234	2012-11-04 11:15:30	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
286	2012-11-04 11:13:31.098857	5	4	1234	2012-11-04 11:15:39	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
287	2012-11-04 11:13:40.9951	5	4	1234	2012-11-04 11:15:49	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
288	2012-11-04 11:13:52.008639	5	4	1234	2012-11-04 11:15:59	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
289	2012-11-04 11:14:01.202932	5	4	1234	2012-11-04 11:16:10	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
290	2012-11-04 11:14:12.016635	5	4	1234	2012-11-04 11:16:19	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
291	2012-11-04 11:14:22.044941	5	4	1234	2012-11-04 11:16:30	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
292	2012-11-04 11:14:31.094611	5	4	1234	2012-11-04 11:16:40	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
293	2012-11-04 11:14:40.275496	5	4	1234	2012-11-04 11:16:49	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
294	2012-11-04 11:14:50.460233	5	4	1234	2012-11-04 11:16:58	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
295	2012-11-04 11:14:59.316833	5	4	1234	2012-11-04 11:17:08	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
296	2012-11-04 11:15:09.671025	5	4	1234	2012-11-04 11:17:17	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
297	2012-11-04 11:15:21.287061	5	4	1234	2012-11-04 11:17:37	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
298	2012-11-04 11:15:22.080724	5	4	1234	2012-11-04 11:17:28	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
299	2012-11-04 11:15:41.193696	5	4	1234	2012-11-04 11:17:49	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
300	2012-11-04 11:15:50.254795	5	4	1234	2012-11-04 11:17:59	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
301	2012-11-04 11:16:00.0202	5	4	1234	2012-11-04 11:18:08	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
302	2012-11-04 11:16:09.81368	5	4	1234	2012-11-04 11:18:18	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
303	2012-11-04 11:16:19.162636	5	4	1234	2012-11-04 11:18:28	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
304	2012-11-04 11:16:29.083543	5	4	1234	2012-11-04 11:18:37	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
305	2012-11-04 11:16:38.225881	5	4	1234	2012-11-04 11:18:47	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
306	2012-11-04 11:16:48.335761	5	4	1234	2012-11-04 11:18:56	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
386	2012-11-08 23:52:48.126045	5	0	59399022188	1990-01-01 00:00:00	@??		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
307	2012-11-04 11:16:58.211	5	4	1234	2012-11-04 11:19:06	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
308	2012-11-04 11:17:07.473388	5	4	1234	2012-11-04 11:19:16	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
309	2012-11-04 11:17:19.849751	5	4	1234	2012-11-04 11:19:25	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
310	2012-11-04 11:17:31.614826	5	4	1234	2012-11-04 11:19:37	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
311	2012-11-04 11:18:27.090792	5	4	1234	2012-11-04 11:19:49	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
312	2012-11-04 11:18:27.658931	5	4	1234	2012-11-04 11:20:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
313	2012-11-04 11:19:39.076635	5	4	1234	2012-11-04 11:21:50	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
314	2012-11-04 11:25:10.990573	5	4	1234	2012-11-04 11:21:57	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
315	2012-11-04 11:25:11.853281	5	4	1234	2012-11-04 11:22:05	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
316	2012-11-04 11:25:39.273998	5	4	1234	2012-11-04 11:27:48	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
317	2012-11-04 11:25:48.407202	5	4	1234	2012-11-04 11:27:57	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
318	2012-11-04 11:30:38.008923	5	4	1234	2012-11-04 11:28:06	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
319	2012-11-04 11:30:47.979845	5	4	1234	2012-11-04 11:32:56	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
320	2012-11-04 11:30:57.436568	5	4	1234	2012-11-04 11:33:06	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
321	2012-11-04 11:32:31.201356	5	4	1234	2012-11-04 11:33:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
322	2012-11-04 11:32:31.806667	5	4	1234	2012-11-04 11:33:25	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
323	2012-11-04 11:32:55.355071	5	4	1234	2012-11-04 11:35:09	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
324	2012-11-04 11:33:40.474725	5	4	1234	2012-11-04 11:35:33	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
325	2012-11-04 11:33:41.064214	5	4	1234	2012-11-04 11:35:40	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
326	2012-11-04 11:33:53.06547	5	4	1234	2012-11-04 11:36:07	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
327	2012-11-04 11:36:22.518528	5	4	1234	2012-11-04 11:38:33	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
328	2012-11-04 11:36:28.298896	5	4	1234	2012-11-04 11:38:41	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
329	2012-11-04 11:37:26.38136	5	4	1234	2012-11-04 11:39:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
330	2012-11-04 11:37:37.091235	5	4	1234	2012-11-04 11:39:44	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
331	2012-11-04 11:37:42.24307	5	4	1234	2012-11-04 11:39:55	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
332	2012-11-04 11:44:21.610081	5	4	1234	2012-11-04 11:46:34	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
333	2012-11-04 11:45:21.116281	5	4	1234	2012-11-04 11:47:33	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
334	2012-11-04 11:47:23.879642	5	4	1234	2012-11-04 11:49:34	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
335	2012-11-04 11:47:30.526387	5	4	1234	2012-11-04 11:49:42	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
336	2012-11-04 11:48:24.688896	5	4	1234	2012-11-04 11:50:39	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
337	2012-11-06 05:22:27.80286	5	0	400	2012-11-06 05:13:36	Messaging Application Server 4.3.1¿0		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
338	2012-11-06 05:28:58.573896	5	4	1234	2012-11-06 05:31:12	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
339	2012-11-06 08:11:46.997167	5	4	1234	2012-11-06 08:14:02	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
340	2012-11-06 08:17:00.803759	5	4	1234	2012-11-06 08:18:58	Estimado Cliente, al momento no cuenta con saldo suficiente para realizar esta transaccion, ingrese una Tarjeta Prepago Amigo y continue enviando mensajes		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
341	2012-11-06 09:38:03.624334	6	0	593991443001	1990-01-01 00:00:00	Otro mensaje se supene que ya no llega con formato internacional		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
342	2012-11-06 09:38:04.610003	6	0	16462261376	1990-01-01 00:00:00	Mija  no tengo intertnet. Te amo, elll mati ya esta mejor		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
343	2012-11-06 09:38:05.450131	6	0	593991443001	1990-01-01 00:00:00	ojala		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
344	2012-11-06 09:38:06.315093	6	0	593991443001	2012-10-19 02:41:33	Mensaje de texto tiee caracteres mam     pap         a    o, 'select' viasta  /ddd ok ss 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
345	2012-11-06 09:38:07.208099	6	0	593991443001	1990-01-01 00:00:00	Hhhclhjfdf		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
346	2012-11-06 09:38:08.066861	6	0	593991443001	2012-10-19 11:07:49	Este mensaje es desde usmsd proyect		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
387	2012-11-08 23:52:48.926066	5	0	59399022188	1990-01-01 00:00:00	hellohello		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
388	2012-11-08 23:52:49.738363	5	0	59399022188	1990-01-01 00:00:00	@mama		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
347	2012-11-06 09:38:08.932648	6	0	123	2012-10-10 02:48:20	à£@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
348	2012-11-06 09:38:09.889656	6	0	593991443001	1990-01-01 00:00:00	Ya es hora		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
349	2012-11-06 09:38:10.688699	6	0	593991443001	2012-10-19 11:20:48	Este mensaje es desde usmsd proyect 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
350	2012-11-06 09:38:11.493037	6	0	593987051467	2012-10-10 18:53:57	Hola Erika soy Daniela. Como te fue en los EU ? Quiero ir mañana para que me ayudes con las uñas. Ya tienes mi esmalte ?		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
351	2012-11-06 09:38:12.418846	6	0	593991443001	1990-01-01 00:00:00	CNT Movil le informa que usted ha acreditado $3.00, su nuevo saldo es: 7.35		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
352	2012-11-06 09:38:13.222714	6	0	123	2012-10-22 02:44:10	à£@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
353	2012-11-06 09:38:14.097782	6	0	593991443001	2012-10-19 11:29:41	Este mensaje es desde usmsd proyect 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
354	2012-11-06 09:38:14.92488	6	0	123	2012-10-11 10:22:32	à£@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
355	2012-11-06 09:38:15.792711	6	0	593991443001	2012-10-19 11:54:10	Este mensaje es desde usmsd proyect. amor de Dios 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
356	2012-11-06 09:38:16.687184	6	0	0991443001	1990-01-01 00:00:00	Mensaje de prueba desde\nTelefono alegro mdm`a		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
357	2012-11-06 09:38:17.610203	6	0	16462261376	1990-01-01 00:00:00	Te quito cinco segundos de tu tiempo para que sepas que estoy pensando en ti y que te amo.		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
358	2012-11-06 09:38:18.415328	6	0	60700	2012-11-01 11:03:33	Quieres iPhones y Playstation?, envia CHANCE al 60700 y participa!, ademas recibe 3 creditos x sem 0,50+iva c/u, CHANCE al 60700		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
359	2012-11-06 09:38:19.269688	6	0	593991443001	2012-10-19 20:11:23	 OTRO mensaje de texto de prueba desde usmsd 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
360	2012-11-06 09:38:20.185817	6	0	16462261376	1990-01-01 00:00:00	Hola mija no t pude escribir del trabajo yya estoy donde mi mama		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
361	2012-11-06 09:38:20.957626	6	0	16462261376	2012-11-05 15:08:24	Te amo mi amor		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
362	2012-11-06 09:38:21.780183	6	0	593991443001	2012-10-21 15:26:09	 OTRO mensaje de texto de prueba desde usmsd 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
363	2012-11-06 09:38:22.574956	6	0	123	2012-10-16 12:15:34	à£@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡£¥ùø?0¿¡		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
364	2012-11-06 09:38:23.360229	6	0	593991443001	2012-10-21 15:26:19	 OTRO mensaje de texto de prueba desde usmsd 		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
365	2012-11-06 09:38:24.133504	6	0	777	2012-10-17 18:04:37	CNT Movil le informa que usted ha acreditado $3.00, su nuevo saldo es: 4.39		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
366	2012-11-06 09:38:25.069842	6	0	16462261376	1990-01-01 00:00:00	Mi amor estoy donde mi mama comemos y  nos vamos. Te amo todo bien. Te escribo de la casa.		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
367	2012-11-06 09:38:25.939465	6	0	593991443001	1990-01-01 00:00:00	Este es m`ama mensaje @gmail.com q~^& cuatro raros		2	3	0	0	0	0	0	2012-12-03 00:45:18.464493
368	2012-11-06 10:56:58.897058	6	0	60700	2012-11-06 10:59:08	HOY es tu dia de Suerte gana iPhones, PS3 y descarga GRATIS super Pkman. Envia PLAY al 60700,recibe 3 creditos x sem 0,50+iva c/u. PLAY al 60700		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
369	2012-11-06 11:05:12.127812	6	4	1234	2012-11-06 11:07:27	No group ID was specified		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
370	2012-11-08 23:52:34.829321	5	0	59399022188	1990-01-01 00:00:00	€		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
371	2012-11-08 23:52:35.796311	5	0	59399022188	1990-01-01 00:00:00	@£$¥èeùìòÇ\nØøÅå?_??????????()<=>¡eÆæßE!#%#		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
372	2012-11-08 23:52:36.988889	5	0	59399022188	1990-01-01 00:00:00	€		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
373	2012-11-08 23:52:37.763816	5	0	59399022188	1990-01-01 00:00:00	@£$¥èeùìòÇ\nØø\rÅå?_??????????\n?()/<=>¡eÆæßE !"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüàACEGIKLMNOPQR		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
374	2012-11-08 23:52:38.50555	5	0	59399022188	1990-01-01 00:00:00	>>> @£$¥èéùìq		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
375	2012-11-08 23:52:39.304171	5	0	59399022188	1990-01-01 00:00:00	@£$¥èeùìòÇ\nØø\rÅå?_??????????()/<=>¡eÆæßE!"#¤%&'()*+,-/0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüàACEGIKLMNOPQRUVWY		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
376	2012-11-08 23:52:40.165454	5	0	59399022188	1990-01-01 00:00:00	>>> @£$¥èeùìòÇ\nØø\rÅå?_??????????()/<=>¡eÆæßE!"#¤%&'()*+,-/0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüàACEGIKLMNOPQR		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
377	2012-11-08 23:52:40.991666	5	0	59399022188	1990-01-01 00:00:00	>>> @£$¥èeùìòÇ\nØø\rÅå?_??????????()/<=>¡eÆæßE!"#¤%&'()*+,-/0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüàACEGIKLMNOPQR		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
378	2012-11-08 23:52:41.735986	5	0		1990-01-01 00:00:00	Dim@e		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
379	2012-11-08 23:52:42.60871	5	0	59399022188	1990-01-01 00:00:00	>>> @£$¥èeùìòÇ\nØø\rÅå?_??????????()/<=>¡eÆæßE!"#¤%&'()*+,-/0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüàACEGIKLMNOPQR		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
380	2012-11-08 23:52:43.350424	5	0	59399022188	1990-01-01 00:00:00	4849505152535455565748495051525354555657484950515253545556574849505152535455565797989910010110210348495051525354555657484950515253545556574849505152535455565748495051525354555657		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
381	2012-11-08 23:52:44.158106	5	0	59399022188	1990-01-01 00:00:00	>>> @£$¥èeùìòÇ\nØø\rÅå?_??????????()/<=>¡eÆæßE!"#¤%&'()*+,-/0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwx		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
382	2012-11-08 23:52:44.889152	5	0	59399022188	1990-01-01 00:00:00	@		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
383	2012-11-08 23:52:45.72905	5	0	59399022188	1990-01-01 00:00:00	>>> @£$¥èeùìòÇ\nØø\rÅå?_??????????()/<=>¡eÆæßE!"#¤%&'()*+,-/0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopq		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
384	2012-11-08 23:52:46.619111	5	0	59399022188	1990-01-01 00:00:00	@@		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
385	2012-11-08 23:52:47.359261	5	0	59399022188	1990-01-01 00:00:00	a		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
389	2012-11-08 23:52:50.452284	5	0	59399022188	1990-01-01 00:00:00	hellohellohellohellohellohello		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
390	2012-11-08 23:52:51.149321	5	0	59399022188	1990-01-01 00:00:00	£		2	2	0	0	0	0	0	2012-12-03 00:45:18.464493
391	2012-11-08 23:52:55.756047	5	4	1234	2012-11-08 23:54:57	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
392	2012-11-08 23:54:14.317949	5	4	1234	2012-11-08 23:56:30	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
393	2012-11-08 23:54:24.349628	5	4	1234	2012-11-08 23:56:40	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
394	2012-11-08 23:54:29.264351	5	4	1234	2012-11-08 23:56:50	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
395	2012-11-09 00:32:36.485741	5	4	1234	2012-11-09 00:34:27	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
396	2012-11-09 00:32:51.757037	5	4	1234	2012-11-09 00:35:01	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
397	2012-11-09 00:33:05.220854	5	4	1234	2012-11-09 00:35:16	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
398	2012-11-09 00:33:21.026657	5	4	1234	2012-11-09 00:35:30	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
399	2012-11-09 00:33:36.403866	5	4	1234	2012-11-09 00:35:45	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
400	2012-11-09 00:33:49.927564	5	4	1234	2012-11-09 00:36:01	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
401	2012-11-09 00:34:05.234258	5	4	1234	2012-11-09 00:36:15	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
402	2012-11-09 00:34:21.048562	5	4	1234	2012-11-09 00:36:30	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
403	2012-11-09 00:34:30.73481	5	4	1234	2012-11-09 00:36:45	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
404	2012-11-09 02:15:19.834851	5	4	1234	2012-11-09 02:17:35	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
405	2012-11-09 02:15:43.201961	5	4	1234	2012-11-09 02:18:00	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
406	2012-11-09 02:15:51.923788	5	4	1234	2012-11-09 02:18:09	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
407	2012-11-09 02:16:00.165039	5	4	1234	2012-11-09 02:18:18	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
408	2012-11-09 02:16:09.989165	5	4	1234	2012-11-09 02:18:26	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
409	2012-11-09 02:16:19.615323	5	4	1234	2012-11-09 02:18:36	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
410	2012-11-09 02:16:24.404198	5	4	1234	2012-11-09 02:18:46	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
411	2012-11-09 02:18:15.01621	5	4	1234	2012-11-09 02:20:34	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
412	2012-11-09 02:18:24.95371	5	4	1234	2012-11-09 02:20:41	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
413	2012-11-09 02:18:36.790254	5	4	1234	2012-11-09 02:20:51	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
414	2012-11-09 02:18:37.547384	5	4	1234	2012-11-09 02:21:01	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-03 00:45:18.464493
415	2012-12-05 11:31:23.962085	5	0	9292	2012-11-16 17:44:05	Suscribete a las noticias de FUTBOL y recibe un tono de un gol historico de la Seleccion GRATIS! Responde OK a este msje para suscribirte. P.final 0.17 x dia.		2	1	0	0	0	0	0	2012-12-05 11:31:23.962085
416	2012-12-05 11:31:24.951049	5	0	9080	2012-11-26 18:13:49	Recibe el tono del Gol 5 - 0 del Kitu Diaz GRATIS! Responde OK y ademas te suscribes a las noticias del Barcelona S.C. P.final 0.17 x dia.		2	1	0	0	0	0	0	2012-12-05 11:31:24.951049
417	2012-12-05 11:31:25.658263	5	0	999	2012-11-28 13:33:32	Usted tiene 2 mensajes de voz		2	1	0	0	0	0	0	2012-12-05 11:31:25.658263
418	2012-12-05 11:34:35.254342	5	4	1234	2012-12-05 11:38:06	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-05 11:34:35.254342
419	2012-12-05 11:34:44.570579	5	4	1234	2012-12-05 11:38:14	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-05 11:34:44.570579
420	2012-12-05 11:34:49.202376	5	4	1234	2012-12-05 11:38:23	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-05 11:34:49.202376
421	2012-12-05 11:37:02.817297	5	4	1234	2012-12-05 11:40:34	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-05 11:37:02.817297
422	2012-12-05 11:47:14.61559	5	4	1234	2012-12-05 11:40:42	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-05 11:47:14.61559
423	2012-12-08 11:23:42.896345	5	0	593982448598	2012-12-08 11:27:08	Hola ppruba		2	1	0	0	0	0	0	2012-12-08 11:23:42.896345
424	2012-12-08 13:20:22.397037	5	4	1234	2012-12-08 13:24:03	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-08 13:20:22.397037
425	2012-12-08 13:20:31.866725	5	4	1234	2012-12-08 13:24:12	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-08 13:20:31.866725
426	2012-12-08 13:20:36.505124	5	4	1234	2012-12-08 13:24:22	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-08 13:20:36.505124
427	2012-12-08 14:32:13.022097	5	4	1234	2012-12-08 14:35:53	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-08 14:32:13.022097
428	2012-12-08 14:32:17.700669	5	4	1234	2012-12-08 14:36:03	Estimado cliente:  Para poder enviar el mensaje, por favor verifique el numero destino y vuelva a intentar		2	1	0	0	0	0	0	2012-12-08 14:32:17.700669
\.


--
-- TOC entry 2781 (class 0 OID 0)
-- Dependencies: 170
-- Name: smsin_idsmsin_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('smsin_idsmsin_seq', 428, true);


--
-- TOC entry 2584 (class 0 OID 16579)
-- Dependencies: 173 2631
-- Data for Name: smsout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY smsout (idsmsout, dateload, idprovider, idsmstype, idphone, phone, datetosend, message, dateprocess, process, note, priority, attempts, idprovidersent, slices, slicessent, messageclass, report, maxslices, enablemessageclass, idport, flag1, flag2, flag3, flag4, flag5, retryonfail, maxtimelive, ts) FROM stdin;
83	2012-10-16 10:22:03.551061	0	0	0	091443001	2012-10-16 10:22:03	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 18:32:58.320072	7	Nota de mensaje	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
85	2012-10-16 12:05:39.846122	0	0	0	082786003	2012-10-16 12:05:39	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
383	2012-11-09 02:18:00.394635	0	10	4	1234	2012-11-09 02:18:00.394635	TETO DE PRUEBA	2012-11-09 02:18:13.828826	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
343	2012-11-06 05:03:04.276131	0	1	4	1234	2012-11-06 05:03:04.276131	Alarma recibida 0982448598	2012-11-06 05:03:10.800727	8	mansajes de prueba	3	0	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
355	2012-11-08 07:30:50.556834	5	10	3	0982448598	2012-11-08 07:30:50.556834	Alarma generada desde el numero 0982448598	2012-11-08 23:52:26.464453	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
356	2012-11-08 07:30:50.556834	0	10	4	1234	2012-11-08 07:30:50.556834	Alarma generada desde el numero 0982448598	2012-11-08 23:52:26.464453	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
382	2012-11-09 02:18:00.394635	5	10	3	0982448598	2012-11-09 02:18:00.394635	OpenSAGA ha recibido su señal	2012-11-09 02:18:23.753533	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
357	2012-11-08 23:53:57.228048	5	10	3	0982448598	2012-11-08 23:53:57.228048	Señal recibida	2012-11-08 23:54:03.430999	9	SMS generado automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
384	2012-11-09 02:18:00.394635	5	10	3	0982448598	2012-11-09 02:18:00.394635	OpenSAGA ha recibido su señal	2012-11-09 02:18:35.216864	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
358	2012-11-08 23:53:57.228048	5	10	3	0982448598	2012-11-08 23:53:57.228048	ALARMA! De La Cruz Edwin [0982448598]	2012-11-08 23:54:13.066045	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
359	2012-11-08 23:53:57.228048	0	10	4	1234	2012-11-08 23:53:57.228048	ALARMA! De La Cruz Edwin [0982448598]	2012-11-08 23:54:23.110137	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
381	2012-11-09 02:18:00.394635	5	10	3	0982448598	2012-11-09 02:18:00.394635	TEXTO DEL MENSAJE	2012-11-09 02:18:06.543299	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
335	2012-11-05 02:46:36.154289	0	1	4	1234	2012-11-05 02:46:36.154289	Alarma recibida	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
344	2012-11-06 05:03:29.010763	0	1	4	1234	2012-11-06 05:03:29.010763	Alarma recibida 0982448598	2012-11-06 11:05:07.092788	2	mansajes de prueba	3	0	6	1	1	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
360	2012-11-09 00:31:55.577229	5	10	3	0982448598	2012-11-09 00:31:55.577229	Señal recibida	2012-11-09 00:32:00.369877	9	SMS generado automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
361	2012-11-09 00:31:55.577229	5	10	3	0982448598	2012-11-09 00:31:55.577229	ALARMA! De La Cruz Edwin [0982448598]	2012-11-09 00:32:35.229721	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
362	2012-11-09 00:31:55.577229	0	10	4	1234	2012-11-09 00:31:55.577229	ALARMA! De La Cruz Edwin [0982448598]	2012-11-09 00:32:50.571361	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
223	2012-10-20 04:34:48.848863	5	0	0	082786003	2012-10-20 04:34:48	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	0	1	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
336	2012-11-05 03:01:20.682946	0	1	4	1234	2012-11-05 03:01:20.682946	Alarma recibida	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
345	2012-11-06 05:25:29.080476	1	1	3	0982448598	2012-11-06 05:25:29.080476	Alarma recibida 0982448598	2012-11-06 05:28:30.350449	7	mansajes de prueba	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
363	2012-11-09 00:32:11.070847	5	10	3	0982448598	2012-11-09 00:32:11.070847	Señal recibida	2012-11-09 00:33:04.019093	9	SMS generado automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
364	2012-11-09 00:32:11.070847	5	10	3	0982448598	2012-11-09 00:32:11.070847	ALARMA! De La Cruz Edwin [0982448598]	2012-11-09 00:33:19.856484	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
365	2012-11-09 00:32:11.070847	0	10	4	1234	2012-11-09 00:32:11.070847	ALARMA! De La Cruz Edwin [0982448598]	2012-11-09 00:33:35.218378	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
337	2012-11-05 03:05:45.124851	0	1	4	1234	2012-11-05 03:05:45.124851	Alarma recibida	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
346	2012-11-06 05:25:56.797206	1	1	3	0982448598	2012-11-06 05:25:56.797206	Alarma recibida 0982448598	2012-11-06 05:28:57.712475	7	mansajes de prueba	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
366	2012-11-09 00:32:41.996042	5	10	3	0982448598	2012-11-09 00:32:41.996042	Señal recibida	2012-11-09 00:33:48.662677	9	SMS generado automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
367	2012-11-09 00:32:41.996042	5	10	3	0982448598	2012-11-09 00:32:41.996042	ALARMA! De La Cruz Edwin [0982448598]	2012-11-09 00:34:04.024636	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
368	2012-11-09 00:32:41.996042	0	10	4	1234	2012-11-09 00:32:41.996042	ALARMA! De La Cruz Edwin [0982448598]	2012-11-09 00:34:19.855605	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
338	2012-11-05 03:06:00.550885	0	1	4	1234	2012-11-05 03:06:00.550885	Alarma recibida	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
347	2012-11-06 05:28:45.934597	0	1	3	0982448598	2012-11-06 05:28:45.934597	Alarma recibida 0982448598	2012-11-06 05:28:52.900241	8	mansajes de prueba	1	0	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
339	2012-11-05 03:06:06.708994	0	1	4	1234	2012-11-05 03:06:06.708994	Alarma recibida	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
348	2012-11-06 08:11:34.581989	5	1	3	0982448598	2012-11-06 08:11:34.581989	Alarma recibida 0982448598	2012-11-06 08:11:42.660138	9	mansajes de prueba	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
318	2012-10-21 16:58:41.046643	0	0	0	0988888	2012-10-21 16:58:40	 Mas Auto mensaje de texto de prueba	2012-10-21 16:58:41.046643	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
340	2012-11-05 03:09:26.621541	0	1	4	1234	2012-11-05 03:09:26.621541	Alarma recibida 0982448598	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
349	2012-11-07 22:49:32.043844	5	10	3	0982448598	2012-11-07 22:49:32.043844	Señal recibida	2012-11-08 23:52:30.167049	9	SMS generado automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
350	2012-11-07 22:49:32.043844	5	10	3	0982448598	2012-11-07 22:49:32.043844	Señal recibida	2012-11-08 23:52:54.612449	7	SMS generado automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
341	2012-11-05 03:09:29.701353	0	1	4	1234	2012-11-05 03:09:29.701353	Alarma recibida 0982448598	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
351	2012-11-08 07:30:01.195915	5	10	3	0982448598	2012-11-08 07:30:01.195915	Señal recibida	2012-11-08 23:52:26.464453	7	SMS generado automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
327	2012-10-29 08:00:30.011823	0	1	4	1234	2012-10-29 08:00:30.011823	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
328	2012-10-29 08:28:03.861838	0	1	4	1234	2012-10-29 08:28:03.861838	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
330	2012-10-29 08:28:03.861838	0	1	4	1234	2012-10-29 08:28:03.861838	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
329	2012-10-29 08:28:03.861838	0	1	4	1234	2012-10-29 08:28:03.861838	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
331	2012-10-30 09:40:01.454824	0	1	4	1234	2012-10-30 09:40:01.454824	Alarma recibida	2012-10-30 09:46:03.57634	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
332	2012-10-30 09:51:16.102264	0	1	4	1234	2012-10-30 09:51:16.102264	Alarma recibida	2012-10-30 09:57:19.745546	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
375	2012-11-09 02:15:00.219051	0	10	4	1234	2012-11-09 02:15:00.219051	TETO DE PRUEBA	2012-11-09 02:15:07.677844	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
342	2012-11-05 03:09:32.781973	0	1	4	1234	2012-11-05 03:09:32.781973	Alarma recibida 0982448598	2012-11-06 04:59:35.313193	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
352	2012-11-08 07:30:04.394142	5	10	3	0982448598	2012-11-08 07:30:04.394142	Señal recibida	2012-11-08 23:52:26.464453	7	SMS generado automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
239	2012-10-20 16:38:17.694072	5	0	0	082786003	2012-10-20 16:38:17	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
122	2012-10-17 07:18:33.978091	0	0	0	082786003	2012-10-17 07:18:33	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
190	2012-10-19 11:05:17.757992	0	0	0	082786003	2012-10-19 11:05:17	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
136	2012-10-18 02:57:04.107261	0	0	0	082786003	2012-10-18 02:57:04	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
178	2012-10-19 02:37:18.820424	0	0	0	082786003	2012-10-19 02:37:18	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
101	2012-10-16 18:40:41.155887	0	0	0	082786003	2012-10-16 18:40:41	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
262	2012-10-21 12:10:38.491635	5	0	0	0982448598	2012-10-21 12:10:38	 Auto mensaje de texto de prueba	2012-10-21 12:13:47.575692	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
264	2012-10-21 12:13:04.214287	5	0	0	082786003	2012-10-21 12:13:04	mensaje de texto de prueba	2012-10-21 12:14:06.931554	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
133	2012-10-18 02:51:12.579115	7	0	3	0909987	2012-10-18 02:51:12	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
74	2012-10-15 03:56:37.433632	8	0	3	0909987	2012-10-15 03:56:37	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:56:35.139641	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
265	2012-10-21 12:13:04.348899	5	0	0	0982448598	2012-10-21 12:13:04	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 12:14:16.797442	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
263	2012-10-21 12:10:38.637998	0	0	0	0988888	2012-10-21 12:10:38	 Mas Auto mensaje de texto de prueba	2012-10-21 12:17:44.103356	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
95	2012-10-16 17:55:31.791613	0	0	0	082786003	2012-10-16 17:55:31	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
233	2012-10-20 04:44:06.924916	0	0	0	0988888	2012-10-20 04:44:06	 Mas Auto mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
148	2012-10-18 03:42:31.326706	0	0	0	082786003	2012-10-18 03:42:31	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
158	2012-10-18 03:49:38.985949	0	0	0	082786003	2012-10-18 03:49:38	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
138	2012-10-18 02:57:04.637204	0	0	0	082786003	2012-10-18 02:57:04	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
240	2012-10-20 16:38:17.965997	5	0	0	0982448598	2012-10-20 16:38:17	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
287	2012-10-21 12:21:25.657754	5	0	0	0982448598	2012-10-21 12:21:25	 Auto mensaje de texto de prueba	2012-10-21 12:23:31.693825	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
234	2012-10-20 04:49:37.094309	5	0	0	082786003	2012-10-20 04:49:37	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
333	2012-10-30 09:51:40.975874	0	1	4	1234	2012-11-04 11:09:00	Alarma recibida	2012-11-04 11:09:24.97524	8	mansajes de prueba	3	0	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
334	2012-11-03 15:01:57.912363	5	0	0	091443001	2012-11-04 10:28:00	now inmessage text	2012-11-04 11:48:19.291751	9	0	6	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
373	2012-11-09 02:15:00.219051	5	10	3	0982448598	2012-11-09 02:15:00.219051	TEXTO DEL MENSAJE	2012-11-09 02:15:17.97994	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
374	2012-11-09 02:15:00.219051	5	10	3	0982448598	2012-11-09 02:15:00.219051	OpenSAGA ha recinido su señal	2012-11-09 02:15:33.15772	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
376	2012-11-09 02:15:00.219051	5	10	3	0982448598	2012-11-09 02:15:00.219051	OpenSAGA ha recinido su señal	2012-11-09 02:15:42.001477	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
220	2012-10-20 04:32:42.478496	5	0	0	082786003	2012-10-20 04:32:42	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	0	1	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
40	2012-10-15 02:54:54.782705	8	0	3	0909987	2012-10-15 02:54:54	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:54:50.182636	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
92	2012-10-16 16:27:33.292913	5	0	3	0909987	2012-10-16 16:27:33	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
235	2012-10-20 04:49:37.220486	5	0	0	0982448598	2012-10-20 04:49:37	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	1	0	1	1	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
241	2012-10-20 16:38:18.064581	8	0	3	0909987	2012-10-20 16:38:17	 OTRO mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
103	2012-10-16 18:47:00.831152	0	0	3		2012-01-01 00:00:00	mensaje de test	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
198	2012-10-19 19:58:29.719267	0	0	0	082786003	2012-10-19 19:58:29	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	3	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
176	2012-10-19 02:33:41.507455	0	0	0	082786003	2012-10-19 02:33:41	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
266	2012-10-21 12:13:04.459795	8	0	3	0909987	2012-10-21 12:13:04	 OTRO mensaje de texto de prueba	2012-10-21 12:17:49.700091	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
150	2012-10-18 03:42:31.780495	0	0	0	082786003	2012-10-18 03:42:31	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
97	2012-10-16 18:20:54.896891	0	0	0	082786003	2012-10-16 18:20:54	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
91	2012-10-16 16:27:32.940195	0	0	0	082786003	2012-10-16 16:27:32	mensaje de texto de prueba	2012-10-20 18:33:32.860113	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
236	2012-10-20 04:49:37.326612	8	0	3	0909987	2012-10-20 04:49:37	 OTRO mensaje de texto de prueba	2012-10-20 04:58:09.650625	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
51	2012-10-15 03:08:24.077605	5	0	3	0909987	2012-10-15 03:08:23	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
90	2012-10-16 16:24:47.5482	7	0	3	0909987	2012-10-16 16:24:47	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	7	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
201	2012-10-19 20:00:15.570314	8	0	3	0909987	2012-10-19 20:00:15	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
177	2012-10-19 02:33:41.692741	7	0	3	0909987	2012-10-19 02:33:41	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
193	2012-10-19 11:39:40.57908	7	0	3	0909987	2012-10-19 11:39:40	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
134	2012-10-18 02:53:15.61601	0	0	0	082786003	2012-10-18 02:53:15	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
309	2012-10-21 16:58:39.955466	5	0	0	082786003	2012-10-21 16:58:39	mensaje de texto de prueba	2012-10-21 16:58:44.075028	2		5	0	0	0	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
307	2012-10-21 16:45:27.803704	5	0	0	09824458598	2012-10-21 16:45:27	 Auto mensaje de texto de prueba	2012-10-21 16:46:13.790426	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
288	2012-10-21 12:21:25.75817	0	0	0	0988888	2012-10-21 12:21:25	 Mas Auto mensaje de texto de prueba	2012-10-21 12:27:27.409853	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
242	2012-10-20 16:38:18.161171	0	0	0	0982448598	2012-10-20 16:38:18	 Auto mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
267	2012-10-21 12:13:04.606551	5	0	0	0982448598	2012-10-21 12:13:04	 Auto mensaje de texto de prueba	2012-10-21 12:21:29.162484	7		5	0	0	0	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
218	2012-10-20 04:28:27.858842	5	0	0	0982448598	2012-10-20 04:28:27	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
79	2012-10-15 04:09:19.261811	8	0	3	0909987	2012-10-15 04:09:19	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
222	2012-10-20 04:32:42.714675	8	0	3	0909987	2012-10-20 04:32:42	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
215	2012-10-20 04:27:13.220317	5	0	0	0982448598	2012-10-20 04:27:13	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
53	2012-10-15 03:09:23.344917	8	0	3	0909987	2012-10-15 03:09:23	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
141	2012-10-18 03:34:40.218864	7	0	3	0909987	2012-10-18 03:34:40	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
39	2012-10-15 02:52:30.351821	5	0	3	0909987	2012-10-15 02:52:30	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:52:29.239272	7	Nota de mensaje	5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
243	2012-10-20 16:38:18.253823	0	0	0	0988888	2012-10-20 16:38:18	 Mas Auto mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
87	2012-10-16 16:21:56.009414	0	0	0	082786003	2012-10-16 16:21:55	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
160	2012-10-18 03:51:18.024834	0	0	0	082786003	2012-10-18 03:51:17	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
232	2012-10-20 04:44:06.818355	0	0	0	0982448598	2012-10-20 04:44:06	 Auto mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
268	2012-10-21 12:13:04.801439	0	0	0	0988888	2012-10-21 12:13:04	 Mas Auto mensaje de texto de prueba	2012-10-21 12:21:29.162484	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
143	2012-10-18 03:34:40.785702	7	0	3	0909987	2012-10-18 03:34:40	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
169	2012-10-18 07:24:40.434231	7	0	3	0909987	2012-10-18 07:24:40	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
54	2012-10-15 03:11:39.867615	8	0	3	0909987	2012-10-15 03:11:39	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
59	2012-10-15 03:20:04.115259	8	0	3	0909987	2012-10-15 03:20:04	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
191	2012-10-19 11:05:17.942802	7	0	3	0909987	2012-10-19 11:05:17	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
173	2012-10-19 02:31:12.413593	7	0	3	0909987	2012-10-19 02:31:12	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
60	2012-10-15 03:23:48.369596	8	0	3	0909987	2012-10-15 03:23:48	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
73	2012-10-15 03:55:05.723636	8	0	3	0909987	2012-10-15 03:55:05	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:55:02.671608	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
229	2012-10-20 04:44:06.404463	5	0	0	082786003	2012-10-20 04:44:06	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	0	1	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
100	2012-10-16 18:39:33.583485	7	0	3	0909987	2012-10-16 18:39:33	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
102	2012-10-16 18:40:41.39523	7	0	3	0909987	2012-10-16 18:40:41	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
127	2012-10-17 23:39:37.242461	7	0	3	0909987	2012-10-17 23:39:37	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
228	2012-10-20 04:35:52.284979	8	0	3	0909987	2012-10-20 04:35:52	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
125	2012-10-17 07:29:12.90021	7	0	3	0909987	2012-10-17 07:29:12	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
96	2012-10-16 17:55:32.124236	7	0	3	0909987	2012-10-16 17:55:32	 OTRO mensaje de texto de prueba	2012-10-20 04:55:31.806185	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
19	2012-10-14 20:00:30.67377	5	0	3	0909987	2012-10-14 20:00:30	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
20	2012-10-14 20:02:43.679057	2	0	3	4545	2012-10-14 20:02:43	hola postgres	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	0	2	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
25	2012-10-15 01:51:39.733565	8	0	3	0909987	2012-10-15 01:51:39	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
27	2012-10-15 02:28:00.085164	5	0	3	0909987	2012-10-15 02:27:59	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
33	2012-10-15 02:37:21.205013	8	0	3	0909987	2012-10-15 02:37:21	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
311	2012-10-21 16:58:40.227206	8	0	3	0909987	2012-10-21 16:58:40	 OTRO mensaje de texto de prueba	2012-10-21 16:58:40.227206	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
310	2012-10-21 16:58:40.099289	5	0	0	09824548598	2012-10-21 16:58:40	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 17:00:59.499547	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
98	2012-10-16 18:20:55.12066	7	0	3	0909987	2012-10-16 18:20:55	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
104	2012-10-16 18:50:50.307123	5	0	3	0909987	2012-01-12 23:00:00	Texto del mensaje	2012-10-20 04:58:06.15129	7	kkkaa	2	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
107	2012-10-17 05:37:46.681028	7	0	3	0909987	2012-10-17 05:37:46	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
111	2012-10-17 05:44:36.733436	7	0	3	0909987	2012-10-17 05:44:36	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
117	2012-10-17 07:11:15.400499	7	0	3	0909987	2012-10-17 07:11:15	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
119	2012-10-17 07:13:44.210298	7	0	3	0909987	2012-10-17 07:13:44	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
123	2012-10-17 07:18:34.295987	7	0	3	0909987	2012-10-17 07:18:34	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
118	2012-10-17 07:13:44.002755	5	0	0	082786003	2012-10-17 07:13:43	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
113	2012-10-17 05:46:36.19815	7	0	3	0909987	2012-10-17 05:46:36	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
109	2012-10-17 05:37:57.819408	7	0	3	0909987	2012-10-17 05:37:57	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
225	2012-10-20 04:34:49.28874	8	0	3	0909987	2012-10-20 04:34:49	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
269	2012-10-21 12:17:38.567708	5	0	0	082786003	2012-10-21 12:17:38	mensaje de texto de prueba	2012-10-21 12:22:07.781768	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
84	2012-10-16 11:55:00.266721	5	0	0	082786003	2012-10-16 11:55:00	mensaje de texto de prueba	2012-10-20 04:54:58.892464	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
93	2012-10-16 17:54:37.212488	5	0	0	082786003	2012-10-16 17:54:37	mensaje de texto de prueba	2012-10-20 04:54:36.295404	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
94	2012-10-16 17:54:37.471586	7	0	3	0909987	2012-10-16 17:54:37	 OTRO mensaje de texto de prueba	2012-10-20 04:54:36.295404	7		5	1	7	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
75	2012-10-15 03:56:37.686608	8	0	3	0909987	2012-10-15 03:56:37	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:56:35.139641	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
115	2012-10-17 05:49:39.768581	7	0	3	0909987	2012-10-17 05:49:39	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
170	2012-10-18 07:24:40.57768	0	0	0	082786003	2012-10-18 07:24:40	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
89	2012-10-16 16:24:47.249088	0	0	0	082786003	2012-10-16 16:24:47	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
231	2012-10-20 04:44:06.697424	8	0	3	0909987	2012-10-20 04:44:06	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
140	2012-10-18 03:34:39.952606	0	0	0	082786003	2012-10-18 03:34:39	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
196	2012-10-19 11:51:40.042723	0	0	0	082786003	2012-10-19 11:51:39	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
244	2012-10-20 18:32:17.375413	5	0	0	082786003	2012-10-20 18:32:17	mensaje de texto de prueba	2012-10-20 18:33:00.527747	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
174	2012-10-19 02:32:08.832965	0	0	0	082786003	2012-10-19 02:32:08	mensaje de texto de prueba	2012-10-20 18:40:44.580858	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
270	2012-10-21 12:17:38.829479	5	0	0	0982448598	2012-10-21 12:17:38	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 12:22:18.213682	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
130	2012-10-18 02:43:41.417316	0	0	0	082786003	2012-10-18 02:43:41	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
156	2012-10-18 03:49:38.495524	0	0	0	082786003	2012-10-18 03:49:38	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
237	2012-10-20 04:49:37.419262	0	0	0	0982448598	2012-10-20 04:49:37	 Auto mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
238	2012-10-20 04:49:37.522069	0	0	0	0988888	2012-10-20 04:49:37	 Mas Auto mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
245	2012-10-20 18:32:17.653612	5	0	0	0982448598	2012-10-20 18:32:17	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 18:33:08.696843	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
184	2012-10-19 10:28:33.598168	0	0	0	082786003	2012-10-19 10:28:33	mensaje de texto de prueba	2012-10-20 18:34:33.680701	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
289	2012-10-21 15:23:55.179458	5	0	0	082786003	2012-10-21 15:23:55	mensaje de texto de prueba	2012-10-21 15:24:13.157834	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
129	2012-10-18 01:53:01.691832	7	0	3	0909987	2012-10-18 01:53:01	 OTRO mensaje de texto de prueba	2012-10-20 04:53:00.44031	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
197	2012-10-19 11:51:40.2196	7	0	3	0909987	2012-10-19 11:51:40	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
290	2012-10-21 15:23:54.789376	5	0	0	082786003	2012-10-21 15:23:54	mensaje de texto de prueba	2012-10-21 15:24:04.876454	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
271	2012-10-21 12:17:39.069037	8	0	3	0909987	2012-10-21 12:17:38	 OTRO mensaje de texto de prueba	2012-10-21 12:23:38.169955	7		5	0	0	0	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
152	2012-10-18 03:46:46.314474	0	0	0	082786003	2012-10-18 03:46:46	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
26	2012-10-15 02:27:59.893905	8	0	3	0909987	2012-10-15 02:27:59	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
28	2012-10-15 02:31:32.861296	2	0	3	0909987	2012-10-15 02:31:32	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	2	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
313	2012-10-21 16:58:40.566552	5	0	0	082786003	2012-10-21 16:58:40	mensaje de texto de prueba	2012-10-21 16:58:40.566552	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
312	2012-10-21 16:58:40.430552	5	0	0	09824458598	2012-10-21 16:58:40	 Auto mensaje de texto de prueba	2012-10-21 16:58:40.430552	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
154	2012-10-18 03:46:46.760668	0	0	0	082786003	2012-10-18 03:46:46	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
146	2012-10-18 03:40:01.354268	0	0	0	082786003	2012-10-18 03:40:01	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
108	2012-10-17 05:37:57.586714	0	0	0	082786003	2012-10-17 05:37:57	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
188	2012-10-19 11:02:06.679154	0	0	0	082786003	2012-10-19 11:02:06	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
246	2012-10-20 18:32:17.785551	5	0	3	0909987	2012-10-20 18:32:17	 OTRO mensaje de texto de prueba	2012-10-20 18:35:40.210399	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
230	2012-10-20 04:44:06.57364	5	0	0	0982448598	2012-10-20 04:44:06	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	1	0	1	1	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
153	2012-10-18 03:46:46.569565	7	0	3	0909987	2012-10-18 03:46:46	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
64	2012-10-15 03:34:04.282085	5	0	3	0909987	2012-10-15 03:34:04	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
221	2012-10-20 04:32:42.623199	5	0	0	0982448598	2012-10-20 04:32:42	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	1	0	1	1	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
124	2012-10-17 07:29:12.634102	0	0	0	082786003	2012-10-17 07:29:12	mensaje de texto de prueba	2012-10-20 18:35:13.574004	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
247	2012-10-20 18:32:17.882964	0	0	0	0982448598	2012-10-20 18:32:17	 Auto mensaje de texto de prueba	2012-10-20 18:40:44.580858	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
272	2012-10-21 12:17:39.335309	5	0	0	0982448598	2012-10-21 12:17:39	 Auto mensaje de texto de prueba	2012-10-21 12:22:27.242581	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
227	2012-10-20 04:35:52.18281	5	0	0	0982448598	2012-10-20 04:35:52	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	1	0	1	1	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
294	2012-10-21 15:23:56.732865	8	0	3	0909987	2012-10-21 15:23:56	 OTRO mensaje de texto de prueba	2012-10-21 15:29:56.440199	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
202	2012-10-19 20:00:55.414424	5	0	0	082786003	2012-10-19 20:00:55	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
70	2012-10-15 03:41:46.692903	8	0	3	0909987	2012-10-15 03:41:46	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
182	2012-10-19 02:58:55.357542	0	0	0	082786003	2012-10-19 02:58:55	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
248	2012-10-20 18:32:17.971735	0	0	0	0988888	2012-10-20 18:32:17	 Mas Auto mensaje de texto de prueba	2012-10-20 18:40:44.580858	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
273	2012-10-21 12:17:39.619616	0	0	0	0988888	2012-10-21 12:17:39	 Mas Auto mensaje de texto de prueba	2012-10-21 12:23:44.480025	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
76	2012-10-15 04:07:24.067861	8	0	3	0909987	2012-10-15 04:07:23	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
161	2012-10-18 03:51:18.295312	7	0	3	0909987	2012-10-18 03:51:18	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
199	2012-10-19 19:58:29.903205	7	0	3	0909987	2012-10-19 19:58:29	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
171	2012-10-18 07:24:40.843787	7	0	3	0909987	2012-10-18 07:24:40	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
208	2012-10-19 20:08:07.325503	5	0	0	082786003	2012-10-19 20:08:07	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
88	2012-10-16 16:23:44.072342	0	0	0	082786003	2012-10-16 16:23:43	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
126	2012-10-17 23:39:36.240372	0	0	0	082786003	2012-10-17 23:39:36	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
110	2012-10-17 05:44:36.516903	0	0	0	082786003	2012-10-17 05:44:36	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
166	2012-10-18 03:54:40.545196	0	0	0	082786003	2012-10-18 03:54:40	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
116	2012-10-17 07:11:15.111556	0	0	0	082786003	2012-10-17 07:11:15	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
249	2012-10-20 18:40:03.641797	5	0	0	082786003	2012-10-20 18:40:03	mensaje de texto de prueba	2012-10-20 18:40:46.722126	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
274	2012-10-21 12:17:39.639925	5	0	0	082786003	2012-10-21 12:17:39	mensaje de texto de prueba	2012-10-21 12:22:35.846306	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
56	2012-10-15 03:13:01.933064	8	0	3	0909987	2012-10-15 03:13:01	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
49	2012-10-15 03:03:47.35685	8	0	3	0909987	2012-10-15 03:03:47	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
214	2012-10-20 04:27:12.97559	5	0	0	082786003	2012-10-20 04:27:12	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
317	2012-10-21 16:58:40.95118	5	0	0	09824458598	2012-10-21 16:58:40	 Auto mensaje de texto de prueba	2012-10-21 16:58:40.95118	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
316	2012-10-21 16:58:40.818545	8	0	3	0909987	2012-10-21 16:58:40	 OTRO mensaje de texto de prueba	2012-10-21 16:58:40.818545	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
315	2012-10-21 16:58:40.704918	5	0	0	09824548598	2012-10-21 16:58:40	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 16:58:40.704918	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
314	2012-10-21 16:58:40.566687	0	0	0	0988888	2012-10-21 16:58:40	 Mas Auto mensaje de texto de prueba	2012-10-21 16:58:40.566687	2		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
293	2012-10-21 15:23:56.728362	8	0	3	0909987	2012-10-21 15:23:56	 OTRO mensaje de texto de prueba	2012-10-21 15:29:56.440199	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
292	2012-10-21 15:23:56.574549	5	0	0	0982448598	2012-10-21 15:23:56	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 15:24:33.303973	2		5	1	0	1	1	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
291	2012-10-21 15:23:56.567591	5	0	0	0982448598	2012-10-21 15:23:56	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 15:24:23.184819	2		5	1	0	1	1	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
135	2012-10-18 02:53:15.865197	7	0	3	0909987	2012-10-18 02:53:15	 OTRO mensaje de texto de prueba	2012-10-20 04:53:14.665493	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
105	2012-10-16 18:52:36.042165	0	0	0	088989777	2012-01-12 23:00:00	Texto del mensaje	2012-10-20 18:32:58.320072	7	kkkaa	7	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
186	2012-10-19 10:56:54.864227	0	0	0	082786003	2012-10-19 10:56:54	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
81	2012-10-15 20:26:39.660597	8	0	3	0909987	2012-10-15 20:26:39	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
297	2012-10-21 15:23:56.955146	0	0	0	0988888	2012-10-21 15:23:56	 Mas Auto mensaje de texto de prueba	2012-10-21 15:29:56.440199	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
65	2012-10-15 03:34:04.477488	8	0	3	0909987	2012-10-15 03:34:04	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
224	2012-10-20 04:34:49.094485	5	0	0	0982448598	2012-10-20 04:34:48	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	1	0	1	1	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
204	2012-10-19 20:02:12.945972	5	0	0	082786003	2012-10-19 20:02:12	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
250	2012-10-20 18:40:03.879752	5	0	0	0982448598	2012-10-20 18:40:03	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 18:40:54.977325	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
275	2012-10-21 12:17:39.82173	5	0	0	0982448598	2012-10-21 12:17:39	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 12:22:45.426753	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
137	2012-10-18 02:57:04.36312	7	0	3	0909987	2012-10-18 02:57:04	 OTRO mensaje de texto de prueba	2012-10-20 04:57:00.720949	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
114	2012-10-17 05:49:39.549875	0	0	0	082786003	2012-10-17 05:49:39	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
112	2012-10-17 05:46:35.973514	0	0	0	082786003	2012-10-17 05:46:35	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
142	2012-10-18 03:34:40.488631	0	0	0	082786003	2012-10-18 03:34:40	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
251	2012-10-20 18:40:03.970297	8	0	3	0909987	2012-10-20 18:40:03	 OTRO mensaje de texto de prueba	2012-10-20 19:34:44.596932	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
276	2012-10-21 12:17:39.937357	8	0	3	0909987	2012-10-21 12:17:39	 OTRO mensaje de texto de prueba	2012-10-21 12:21:31.842341	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
47	2012-10-15 03:00:34.166448	8	0	3	0909987	2012-10-15 03:00:34	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
212	2012-10-19 20:09:20.589115	5	0	0	0982448598	2012-10-19 20:09:20	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
68	2012-10-15 03:38:56.742231	8	0	3	0909987	2012-10-15 03:38:56	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
55	2012-10-15 03:11:40.123984	8	0	3	0909987	2012-10-15 03:11:39	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
219	2012-10-20 04:28:27.992813	8	0	3	0909987	2012-10-20 04:28:27	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
41	2012-10-15 02:54:54.978698	8	0	3	0909987	2012-10-15 02:54:54	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:54:50.182636	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
67	2012-10-15 03:34:53.229272	8	0	3	0909987	2012-10-15 03:34:53	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
57	2012-10-15 03:13:02.104643	8	0	3	0909987	2012-10-15 03:13:02	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
252	2012-10-20 18:40:04.068953	0	0	0	0982448598	2012-10-20 18:40:03	 Auto mensaje de texto de prueba	2012-10-20 19:34:44.596932	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
277	2012-10-21 12:17:40.049158	5	0	0	0982448598	2012-10-21 12:17:39	 Auto mensaje de texto de prueba	2012-10-21 12:22:54.745671	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
203	2012-10-19 20:00:55.600873	8	0	3	0909987	2012-10-19 20:00:55	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
195	2012-10-19 11:50:26.843953	7	0	3	0909987	2012-10-19 11:50:26	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
48	2012-10-15 03:03:47.221089	8	0	3	0909987	2012-10-15 03:03:47	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
211	2012-10-19 20:09:20.468953	5	0	0	082786003	2012-10-19 20:09:20	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
80	2012-10-15 20:26:39.305804	5	0	3	0909987	2012-10-15 20:26:39	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
167	2012-10-18 03:54:40.864834	7	0	3	0909987	2012-10-18 03:54:40	 OTRO mensaje de texto de prueba	2012-10-20 04:54:39.803023	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
82	2012-10-16 10:22:03.351249	8	0	3	0909987	2012-10-16 10:22:03	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	9	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
163	2012-10-18 03:51:18.784377	7	0	3	0909987	2012-10-18 03:51:18	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
296	2012-10-21 15:23:56.860777	5	0	0	0982448598	2012-10-21 15:23:56	 Auto mensaje de texto de prueba	2012-10-21 15:24:50.335543	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
295	2012-10-21 15:23:56.842483	5	0	0	0982448598	2012-10-21 15:23:56	 Auto mensaje de texto de prueba	2012-10-21 15:24:41.944756	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
301	2012-10-21 16:45:27.190941	8	0	3	0909987	2012-10-21 16:45:27	 OTRO mensaje de texto de prueba	2012-10-21 16:51:32.439547	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
278	2012-10-21 12:17:40.161083	0	0	0	0988888	2012-10-21 12:17:40	 Mas Auto mensaje de texto de prueba	2012-10-21 12:23:44.480025	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
159	2012-10-18 03:49:39.319191	7	0	3	0909987	2012-10-18 03:49:39	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
131	2012-10-18 02:43:41.641967	7	0	3	0909987	2012-10-18 02:43:41	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
66	2012-10-15 03:34:53.052903	8	0	3	0909987	2012-10-15 03:34:52	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
58	2012-10-15 03:20:03.974389	8	0	3	0909987	2012-10-15 03:20:03	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
120	2012-10-17 07:16:37.897721	0	0	0	082786003	2012-10-17 07:16:37	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
99	2012-10-16 18:39:33.299913	0	0	0	082786003	2012-10-16 18:39:33	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
106	2012-10-17 05:37:46.429117	0	0	0	082786003	2012-10-17 05:37:46	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
168	2012-10-18 07:24:40.142487	0	0	0	082786003	2012-10-18 07:24:40	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
172	2012-10-19 02:31:11.78211	0	0	0	082786003	2012-10-19 02:31:11	mensaje de texto de prueba	2012-10-20 18:40:44.580858	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
253	2012-10-20 18:40:04.185556	0	0	0	0988888	2012-10-20 18:40:04	 Mas Auto mensaje de texto de prueba	2012-10-20 19:34:44.596932	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
254	2012-10-20 19:34:03.822506	5	0	0	082786003	2012-10-20 19:34:03	mensaje de texto de prueba	2012-10-20 19:34:46.591051	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
279	2012-10-21 12:21:24.505021	5	0	0	082786003	2012-10-21 12:21:24	mensaje de texto de prueba	2012-10-21 12:23:03.686858	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
165	2012-10-18 03:54:40.330979	7	0	3	0909987	2012-10-18 03:54:40	 OTRO mensaje de texto de prueba	2012-10-20 04:54:39.803023	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
205	2012-10-19 20:02:13.149633	8	0	3	0909987	2012-10-19 20:02:13	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
217	2012-10-20 04:28:27.69541	5	0	0	082786003	2012-10-20 04:28:27	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
121	2012-10-17 07:16:38.122959	5	0	3	0909987	2012-10-17 07:16:38	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
43	2012-10-15 02:56:21.090496	8	0	3	0909987	2012-10-15 02:56:20	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:56:16.944863	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
300	2012-10-21 16:45:27.100359	5	0	0	09824548598	2012-10-21 16:45:27	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 16:46:33.527244	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
38	2012-10-15 02:52:30.206044	8	0	3	0909987	2012-10-15 02:52:30	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:52:29.239272	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
255	2012-10-20 19:34:04.02956	5	0	0	0982448598	2012-10-20 19:34:03	 OTRO mensaje de texto de prueba desde usmsd	2012-10-20 19:34:55.381083	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
280	2012-10-21 12:21:24.644594	5	0	0	0982448598	2012-10-21 12:21:24	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 12:23:13.398142	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
151	2012-10-18 03:42:31.996483	7	0	3	0909987	2012-10-18 03:42:31	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
226	2012-10-20 04:35:52.07072	5	0	0	082786003	2012-10-20 04:35:51	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	0	1	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
216	2012-10-20 04:27:13.315666	8	0	3	0909987	2012-10-20 04:27:13	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
183	2012-10-19 02:58:55.557066	7	0	3	0909987	2012-10-19 02:58:55	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
139	2012-10-18 02:57:04.939069	7	0	3	0909987	2012-10-18 02:57:04	 OTRO mensaje de texto de prueba	2012-10-20 04:57:00.720949	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
162	2012-10-18 03:51:18.491976	0	0	0	082786003	2012-10-18 03:51:18	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
256	2012-10-20 19:34:04.128355	8	0	3	0909987	2012-10-20 19:34:04	 OTRO mensaje de texto de prueba	2012-10-21 12:11:19.027288	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
281	2012-10-21 12:21:24.801779	8	0	3	0909987	2012-10-21 12:21:24	 OTRO mensaje de texto de prueba	2012-10-21 12:22:27.363726	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
46	2012-10-15 03:00:34.030165	8	0	3	0909987	2012-10-15 03:00:33	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
16	1990-01-01 00:00:00	7	0	7		2012-10-14 19:47:15	Mensaje de texto	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	7	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
18	2012-10-14 19:55:34.658708	8	0	3	0909987	2012-10-14 19:55:34	Mensaje de texto	2012-10-20 04:55:31.806185	7	Nota de mensaje	5	3	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
24	2012-10-15 01:51:39.499041	5	0	3	0982448598	2012-10-15 01:51:39	Este mensaje es desde usmsd proyect. amor de Dios	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	9	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
29	2012-10-15 02:31:32.996321	8	0	3	0909987	2012-10-15 02:31:32	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
37	2012-10-15 02:44:50.651114	8	0	3	0909987	2012-10-15 02:44:50	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
299	2012-10-21 16:45:27.004869	5	0	0	082786003	2012-10-21 16:45:26	mensaje de texto de prueba	2012-10-21 16:45:40.477045	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
298	2012-10-21 15:23:56.980283	0	0	0	0988888	2012-10-21 15:23:56	 Mas Auto mensaje de texto de prueba	2012-10-21 15:29:56.440199	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
145	2012-10-18 03:40:01.109556	7	0	3	0909987	2012-10-18 03:40:01	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
147	2012-10-18 03:40:01.647814	7	0	3	0909987	2012-10-18 03:40:01	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
185	2012-10-19 10:28:33.841449	7	0	3	0909987	2012-10-19 10:28:33	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
71	2012-10-15 03:41:47.387109	8	0	3	0909987	2012-10-15 03:41:47	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
61	2012-10-15 03:23:48.540687	8	0	3	0909987	2012-10-15 03:23:48	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
62	2012-10-15 03:25:57.065677	8	0	3	0909987	2012-10-15 03:25:56	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
128	2012-10-18 01:53:01.483466	0	0	0	082786003	2012-10-18 01:53:01	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
132	2012-10-18 02:51:12.349851	0	0	0	082786003	2012-10-18 02:51:12	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
257	2012-10-20 19:34:04.230915	5	0	0	0982448598	2012-10-20 19:34:04	 Auto mensaje de texto de prueba	2012-10-20 19:35:03.557052	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
42	2012-10-15 02:56:20.923639	8	0	3	0909987	2012-10-15 02:56:20	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:56:16.944863	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
282	2012-10-21 12:21:25.034334	5	0	0	0982448598	2012-10-21 12:21:24	 Auto mensaje de texto de prueba	2012-10-21 12:23:22.569962	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
179	2012-10-19 02:37:19.0093	7	0	3	0909987	2012-10-19 02:37:18	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
210	2012-10-19 20:08:07.574746	8	0	3	0909987	2012-10-19 20:08:07	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
63	2012-10-15 03:25:57.268598	8	0	3	0909987	2012-10-15 03:25:57	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
213	2012-10-19 20:09:20.662676	8	0	3	0909987	2012-10-19 20:09:20	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
45	2012-10-15 02:57:45.423331	8	0	3	0909987	2012-10-15 02:57:45	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:57:41.627813	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
258	2012-10-20 19:34:04.353299	0	0	0	0988888	2012-10-20 19:34:04	 Mas Auto mensaje de texto de prueba	2012-10-21 12:11:19.027288	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
283	2012-10-21 12:21:25.242643	5	0	0	082786003	2012-10-21 12:21:25	mensaje de texto de prueba	2012-10-21 12:23:40.588774	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
44	2012-10-15 02:57:45.233788	8	0	3	0909987	2012-10-15 02:57:45	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:57:41.627813	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
72	2012-10-15 03:55:05.523951	8	0	3	0909987	2012-10-15 03:55:05	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:55:02.671608	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
303	2012-10-21 16:45:27.447565	5	0	0	082786003	2012-10-21 16:45:27	mensaje de texto de prueba	2012-10-21 16:47:03.284481	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
50	2012-10-15 03:08:23.925284	8	0	3	0909987	2012-10-15 03:08:23	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
155	2012-10-18 03:46:47.031122	7	0	3	0909987	2012-10-18 03:46:46	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
157	2012-10-18 03:49:38.788792	7	0	3	0909987	2012-10-18 03:49:38	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
207	2012-10-19 20:07:00.595633	8	0	3	0909987	2012-10-19 20:07:00	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
175	2012-10-19 02:32:09.012164	7	0	3	0909987	2012-10-19 02:32:08	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
194	2012-10-19 11:50:26.662004	0	0	0	082786003	2012-10-19 11:50:26	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
259	2012-10-21 12:10:38.074679	5	0	0	082786003	2012-10-21 12:10:37	mensaje de texto de prueba	2012-10-21 12:11:21.094643	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
206	2012-10-19 20:07:00.365752	5	0	0	082786003	2012-10-19 20:07:00	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
209	2012-10-19 20:08:07.498676	5	0	0	1234	2012-10-19 20:08:07	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	1	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
200	2012-10-19 20:00:15.394782	5	0	0	082786003	2012-10-19 20:00:15	mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
69	2012-10-15 03:38:56.880776	8	0	3	0909987	2012-10-15 03:38:56	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
302	2012-10-21 16:45:27.393166	5	0	0	09824458598	2012-10-21 16:45:27	 Auto mensaje de texto de prueba	2012-10-21 16:46:48.889238	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
187	2012-10-19 10:56:55.048904	7	0	3	0909987	2012-10-19 10:56:54	 OTRO mensaje de texto de prueba	2012-10-20 04:56:53.406162	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
260	2012-10-21 12:10:38.233228	5	0	0	0982448598	2012-10-21 12:10:38	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 12:13:57.631112	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
32	2012-10-15 02:37:21.059746	8	0	3	0909987	2012-10-15 02:37:20	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
304	2012-10-21 16:45:27.57735	0	0	0	0988888	2012-10-21 16:45:27	 Mas Auto mensaje de texto de prueba	2012-10-21 16:51:32.439547	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
284	2012-10-21 12:21:25.384355	0	0	0	0988888	2012-10-21 12:21:25	 Mas Auto mensaje de texto de prueba	2012-10-21 12:27:27.409853	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
189	2012-10-19 11:02:06.836164	7	0	3	0909987	2012-10-19 11:02:06	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
77	2012-10-15 04:07:24.244454	8	0	3	0909987	2012-10-15 04:07:24	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
78	2012-10-15 04:09:19.135494	8	0	3	0909987	2012-10-15 04:09:19	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
52	2012-10-15 03:09:23.20782	8	0	3	0909987	2012-10-15 03:09:23	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
149	2012-10-18 03:42:31.597803	7	0	3	0909987	2012-10-18 03:42:31	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
181	2012-10-19 02:42:00.108817	7	0	3	0909987	2012-10-19 02:42:00	 OTRO mensaje de texto de prueba	2012-10-20 04:58:06.15129	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
86	2012-10-16 15:21:39.145904	0	0	0	082786003	2012-10-16 15:21:39	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
180	2012-10-19 02:41:59.877459	0	0	0	082786003	2012-10-19 02:41:59	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
144	2012-10-18 03:40:00.845372	0	0	0	082786003	2012-10-18 03:40:00	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
192	2012-10-19 11:39:40.364637	0	0	0	082786003	2012-10-19 11:39:40	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
164	2012-10-18 03:54:40.069362	0	0	0	082786003	2012-10-18 03:54:39	mensaje de texto de prueba	2012-10-20 18:32:58.320072	7		5	0	1	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
261	2012-10-21 12:10:38.376317	8	0	3	0909987	2012-10-21 12:10:38	 OTRO mensaje de texto de prueba	2012-10-21 12:17:44.103356	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
10	1990-01-01 00:00:00	8	0	0	123444	2001-12-12 00:34:00	Este mensaje de preba	2012-10-20 04:58:06.15129	7	Sin nota	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
11	1990-01-01 00:00:00	8	1	0	989988711	2009-12-23 12:12:00	inmessage text	2012-10-20 04:58:06.15129	7	innote text	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
12	1990-01-01 00:00:00	8	1	0	989988711	2009-12-23 12:12:00	inmessage text	2012-10-20 04:58:06.15129	7	innote text	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
15	1990-01-01 00:00:00	0	0	7		2009-01-09 00:00:00	inmessage text	2012-10-20 18:32:58.320072	7	innote text	5	0	\N	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
17	1990-01-01 00:00:00	8	0	3	0909987	2012-10-14 19:52:23	Mensaje de texto	2012-10-20 04:52:20.760389	7	Nota de mensaje	5	1	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
21	2012-10-14 20:02:43.803555	8	0	3	0909987	2012-10-14 20:02:43	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
22	2012-10-15 01:13:08.940278	8	0	3	0909987	2012-10-15 01:13:08	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	3	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
23	2012-10-15 01:13:15.855815	5	0	3	0909987	2012-10-15 01:13:15	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 18:34:33.680701	7	Nota de mensaje	5	3	5	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
30	2012-10-15 02:33:47.626967	8	0	3	0909987	2012-10-15 02:33:47	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
31	2012-10-15 02:33:47.789431	8	0	3	0909987	2012-10-15 02:33:47	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
34	2012-10-15 02:41:38.299522	8	0	3	0909987	2012-10-15 02:41:38	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
35	2012-10-15 02:41:38.442551	8	0	3	0909987	2012-10-15 02:41:38	sin problema Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
36	2012-10-15 02:44:50.468009	8	0	3	0909987	2012-10-15 02:44:50	Mensaje de texto tiee caracteres mamá papá ñaño, 'select' viasta \\ddd ok ss	2012-10-20 04:58:06.15129	7	Nota de mensaje	5	2	8	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
308	2012-10-21 16:45:27.891547	0	0	0	0988888	2012-10-21 16:45:27	 Mas Auto mensaje de texto de prueba	2012-10-21 16:51:32.439547	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
306	2012-10-21 16:45:27.682081	8	0	3	0909987	2012-10-21 16:45:27	 OTRO mensaje de texto de prueba	2012-10-21 16:51:32.439547	7		5	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
305	2012-10-21 16:45:27.5983	5	0	0	09824548598	2012-10-21 16:45:27	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 16:47:20.985686	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
286	2012-10-21 12:21:25.557215	8	0	3	0909987	2012-10-21 12:21:25	 OTRO mensaje de texto de prueba	2012-10-21 12:22:33.94583	3		5	1	0	1	0	1	f	1	f	2	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
285	2012-10-21 12:21:25.452978	5	0	0	0982448598	2012-10-21 12:21:25	 OTRO mensaje de texto de prueba desde usmsd	2012-10-21 12:23:49.884159	3		5	1	0	1	0	1	f	1	f	1	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
322	2012-10-29 08:00:30.011823	0	1	4	1234	2012-10-29 08:00:30.011823	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
323	2012-10-29 08:00:30.011823	0	1	4	1234	2012-10-29 08:00:30.011823	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
324	2012-10-29 08:00:30.011823	0	1	4	1234	2012-10-29 08:00:30.011823	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
325	2012-10-29 08:00:30.011823	0	1	4	1234	2012-10-29 08:00:30.011823	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
326	2012-10-29 08:00:30.011823	0	1	4	1234	2012-10-29 08:00:30.011823	Alarma recibida	2012-10-30 09:16:37.711799	7	mansajes de prueba	3	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
353	2012-11-08 07:30:44.320322	5	10	3	0982448598	2012-11-08 07:30:44.320322	Alarma generada desde el numero 0982448598	2012-11-08 23:52:26.464453	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
354	2012-11-08 07:30:44.320322	0	10	4	1234	2012-11-08 07:30:44.320322	Alarma generada desde el numero 0982448598	2012-11-08 23:52:26.464453	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-03 00:45:56.356426
380	2012-11-09 02:15:18.891534	5	10	3	0982448598	2012-11-09 02:15:18.891534	OpenSAGA ha recinido su señal	2012-11-09 02:16:18.337887	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
379	2012-11-09 02:15:18.891534	0	10	4	1234	2012-11-09 02:15:18.891534	TETO DE PRUEBA	2012-11-09 02:15:59.021625	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
377	2012-11-09 02:15:18.891534	5	10	3	0982448598	2012-11-09 02:15:18.891534	TEXTO DEL MENSAJE	2012-11-09 02:15:50.734668	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
378	2012-11-09 02:15:18.891534	5	10	3	0982448598	2012-11-09 02:15:18.891534	OpenSAGA ha recinido su señal	2012-11-09 02:16:08.764206	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-03 00:45:56.356426
385	2012-11-16 02:19:15.219469	5	10	3	0982448598	2012-11-16 02:19:15.219469	TEXTO DEL MENSAJE	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
386	2012-11-16 02:19:15.219469	0	10	4	1234	2012-11-16 02:19:15.219469	TETO DE PRUEBA	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
387	2012-11-16 02:19:15.219469	5	10	3	0982448598	2012-11-16 02:19:15.219469	OpenSAGA ha recibido su señal	2012-12-05 11:31:22.180289	7	SMS generado automaticamente	10	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
388	2012-11-16 02:49:15.454956	5	10	3	0982448598	2012-11-16 02:19:15.219469	Auxilo me De La Cruz Edwin mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
389	2012-11-16 02:49:15.454956	0	10	4	1234	2012-11-16 02:19:15.219469	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
390	2012-11-16 02:49:15.454956	5	10	3	0982448598	2012-11-16 02:19:15.219469	OpenSAGA ha recibido su señal	2012-12-05 11:31:22.180289	7	SMS generado automaticamente	10	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
391	2012-11-22 23:44:41.564018	5	10	3	0982448598	2012-11-22 23:44:41.564018	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
392	2012-11-22 23:44:41.564018	0	10	4	1234	2012-11-22 23:44:41.564018	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
405	2012-11-24 13:39:01.801201	5	10	3	0982448598	2012-11-24 13:39:01.801201	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
406	2012-11-24 13:39:01.801201	0	10	4	1234	2012-11-24 13:39:01.801201	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
393	2012-11-22 23:46:10.076471	5	10	3	0982448598	2012-11-22 23:46:10.076471	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
394	2012-11-22 23:46:10.076471	0	10	4	1234	2012-11-22 23:46:10.076471	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
407	2012-11-24 13:39:17.585364	5	10	3	0982448598	2012-11-24 13:39:17.585364	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
408	2012-11-24 13:39:17.585364	0	10	4	1234	2012-11-24 13:39:17.585364	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
395	2012-11-22 23:48:38.353673	5	10	3	0982448598	2012-11-22 23:48:38.353673	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
396	2012-11-22 23:48:38.353673	0	10	4	1234	2012-11-22 23:48:38.353673	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
397	2012-11-23 01:36:10.015425	5	10	3	0982448598	2012-11-23 01:36:10.015425	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
398	2012-11-23 01:36:10.015425	0	10	4	1234	2012-11-23 01:36:10.015425	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
399	2012-11-23 01:36:29.575354	5	10	3	0982448598	2012-11-23 01:36:29.575354	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
400	2012-11-23 01:36:29.575354	0	10	4	1234	2012-11-23 01:36:29.575354	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
401	2012-11-23 01:36:45.537461	5	10	3	0982448598	2012-11-23 01:36:45.537461	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
402	2012-11-23 01:36:45.537461	0	10	4	1234	2012-11-23 01:36:45.537461	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
403	2012-11-23 01:49:22.112868	5	10	3	0982448598	2012-11-23 01:49:22.112868	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
404	2012-11-23 01:49:22.112868	0	10	4	1234	2012-11-23 01:49:22.112868	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
409	2012-12-05 03:12:04.221581	5	10	3	0982448598	2012-12-05 03:12:04.221581	Auxilo me &U01 mantat	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
410	2012-12-05 03:12:04.221581	0	10	4	1234	2012-12-05 03:12:04.221581	Disparar modulo gsm	2012-12-05 11:31:22.180289	7	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-05 11:31:22.180289
419	2012-12-08 13:20:05.879166	5	10	3	0982448598	2012-12-08 13:20:05.879166	OpenSAGA ha recibido su señal	2012-12-08 13:20:30.69488	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-08 13:20:30.69488
414	2012-12-05 11:36:46.262737	5	10	3	0982448598	2012-12-05 11:36:46.262737	Auxilo me De La Cruz Edwin mantat	2012-12-05 11:36:53.757637	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-05 11:36:53.757637
411	2012-12-05 11:34:17.415732	5	10	3	0982448598	2012-12-05 11:34:17.415732	Auxilo me De La Cruz Edwin mantat	2012-12-05 11:34:26.261063	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-05 11:34:26.261063
415	2012-12-05 11:36:46.262737	0	10	4	1234	2012-12-05 11:36:46.262737	Disparar modulo gsm	2012-12-05 11:37:01.647935	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-05 11:37:01.647935
412	2012-12-05 11:34:17.415732	0	10	4	1234	2012-12-05 11:34:17.415732	Disparar modulo gsm	2012-12-05 11:34:34.092049	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-05 11:34:34.092049
418	2012-12-08 13:20:05.879166	0	10	4	1234	2012-12-08 13:20:05.879166	Disparar modulo gsm	2012-12-08 13:20:12.459135	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-08 13:20:12.459135
426	2012-12-31 19:32:43.922904	0	10	4	1234	2012-12-31 19:32:43.922904	Actualizada la cuenta idaccount = 1	2012-12-31 19:32:43.922904	0	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-31 19:32:43.922904
413	2012-12-05 11:34:17.415732	5	10	3	0982448598	2012-12-05 11:34:17.415732	OpenSAGA ha recibido su señal	2012-12-05 11:34:43.388011	9	SMS generado automaticamente	10	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-05 11:34:43.388011
427	2012-12-31 19:32:43.922904	5	10	3	0982448598	2012-12-31 19:32:43.922904	ok	2012-12-31 19:32:43.922904	0	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-31 19:32:43.922904
417	2012-12-08 13:20:05.879166	5	10	3	0982448598	2012-12-08 13:20:05.879166	Auxilo me De La Cruz Edwin mantat	2012-12-08 13:20:21.174317	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-08 13:20:21.174317
416	2012-12-05 11:36:46.262737	5	10	3	0982448598	2012-12-05 11:36:46.262737	OpenSAGA ha recibido su señal	2012-12-05 11:47:13.788527	7	SMS generado automaticamente	10	0	0	0	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-05 11:47:13.788527
421	2012-12-08 14:31:54.374662	0	10	4	1234	2012-12-08 14:31:54.374662	Disparar modulo gsm	2012-12-08 14:32:11.855391	8	Notificacion generada automaticamente	1	1	0	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-08 14:32:11.855391
422	2012-12-17 09:58:38.830633	5	10	3	0982448598	2012-12-17 09:58:38.830633	Auxilo me &U01 mantat	2012-12-17 09:58:38.830633	0	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-17 09:58:38.830633
420	2012-12-08 14:31:54.374662	5	10	3	0982448598	2012-12-08 14:31:54.374662	Auxilo me &U01 mantat	2012-12-08 14:32:02.047943	9	Notificacion generada automaticamente	1	1	5	1	0	1	f	1	f	2	0	0	0	0	0	1	5	2012-12-08 14:32:02.047943
423	2012-12-18 23:47:56.907394	5	10	3	0982448598	2012-12-18 23:47:56.907394	Auxilo me &U01 mantat	2012-12-18 23:47:56.907394	0	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-18 23:47:56.907394
424	2012-12-26 04:20:20.697223	5	10	3	0982448598	2012-12-26 04:20:20.697223	ok	2012-12-26 04:20:20.697223	0	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-26 04:20:20.697223
425	2012-12-26 04:20:20.697223	0	10	4	1234	2012-12-26 04:20:20.697223	Alarma de emergencia mañana	2012-12-26 04:20:20.697223	0	Notificacion generada automaticamente	1	0	0	0	0	1	f	1	f	0	0	0	0	0	0	0	2	2012-12-26 04:20:20.697223
\.


--
-- TOC entry 2782 (class 0 OID 0)
-- Dependencies: 172
-- Name: smsout_idsmsout_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('smsout_idsmsout_seq', 427, true);


--
-- TOC entry 2591 (class 0 OID 16745)
-- Dependencies: 180 2631
-- Data for Name: smsoutoptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY smsoutoptions (idsmsoutopt, enable, name, report, retryonfail, maxslices, maxtimelive, ts) FROM stdin;
1	t	\N	f	1	1	5	2012-12-03 00:46:31.19102
\.


--
-- TOC entry 2783 (class 0 OID 0)
-- Dependencies: 179
-- Name: smsoutoptions_idsmsoutopt_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('smsoutoptions_idsmsoutopt_seq', 1, true);


--
-- TOC entry 2784 (class 0 OID 0)
-- Dependencies: 210
-- Name: states_idstate_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('states_idstate_seq', 1, true);


--
-- TOC entry 2586 (class 0 OID 16599)
-- Dependencies: 175 2631
-- Data for Name: whitelist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY whitelist (idwl, idprovider, idphone, note, ts) FROM stdin;
\.


--
-- TOC entry 2785 (class 0 OID 0)
-- Dependencies: 174
-- Name: whitelist_idwl_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('whitelist_idwl_seq', 1, false);


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2489 (class 2606 OID 18076)
-- Dependencies: 203 203 203 2632
-- Name: pk_account_contacts; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT pk_account_contacts PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2521 (class 2606 OID 26454)
-- Dependencies: 226 226 226 2632
-- Name: pk_account_notif_group; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications_group
    ADD CONSTRAINT pk_account_notif_group PRIMARY KEY (idaccount, ideventtype);


--
-- TOC entry 2493 (class 2606 OID 18120)
-- Dependencies: 206 206 206 2632
-- Name: pk_account_triggers_phones; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT pk_account_triggers_phones PRIMARY KEY (idaccount, idphone);


--
-- TOC entry 2491 (class 2606 OID 26886)
-- Dependencies: 205 205 205 2632
-- Name: pk_account_users; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT pk_account_users PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2453 (class 2606 OID 16987)
-- Dependencies: 184 184 2632
-- Name: pk_idaccount; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT pk_idaccount PRIMARY KEY (idaccount);


--
-- TOC entry 2475 (class 2606 OID 17295)
-- Dependencies: 195 195 2632
-- Name: pk_idevent; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT pk_idevent PRIMARY KEY (idevent);


--
-- TOC entry 2485 (class 2606 OID 17730)
-- Dependencies: 202 202 2632
-- Name: pk_idevent_from_call; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT pk_idevent_from_call PRIMARY KEY (idevent);


--
-- TOC entry 2477 (class 2606 OID 17362)
-- Dependencies: 196 196 2632
-- Name: pk_ideventtype; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY eventtypes
    ADD CONSTRAINT pk_ideventtype PRIMARY KEY (ideventtype);


--
-- TOC entry 2517 (class 2606 OID 26392)
-- Dependencies: 224 224 2632
-- Name: pk_idgroup; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT pk_idgroup PRIMARY KEY (idgroup);


--
-- TOC entry 2459 (class 2606 OID 17061)
-- Dependencies: 185 185 2632
-- Name: pk_idinstallationdata; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT pk_idinstallationdata PRIMARY KEY (idinstallationdata);


--
-- TOC entry 2479 (class 2606 OID 17399)
-- Dependencies: 198 198 2632
-- Name: pk_idkeyword; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT pk_idkeyword PRIMARY KEY (idkeyword);


--
-- TOC entry 2465 (class 2606 OID 17156)
-- Dependencies: 189 189 2632
-- Name: pk_idlocation; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT pk_idlocation PRIMARY KEY (idlocation);


--
-- TOC entry 2469 (class 2606 OID 17182)
-- Dependencies: 191 191 2632
-- Name: pk_idnotifaccount; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT pk_idnotifaccount PRIMARY KEY (idnotifaccount);


--
-- TOC entry 2473 (class 2606 OID 17266)
-- Dependencies: 193 193 2632
-- Name: pk_idnotifphoneeventtype; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT pk_idnotifphoneeventtype PRIMARY KEY (idnotifphoneeventtype);


--
-- TOC entry 2507 (class 2606 OID 26212)
-- Dependencies: 215 215 2632
-- Name: pk_idnotiftempl; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notification_templates
    ADD CONSTRAINT pk_idnotiftempl PRIMARY KEY (idnotiftempl);


--
-- TOC entry 2463 (class 2606 OID 17119)
-- Dependencies: 187 187 2632
-- Name: pk_idpanelmodel; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY panelmodel
    ADD CONSTRAINT pk_idpanelmodel PRIMARY KEY (idpanelmodel);


--
-- TOC entry 2471 (class 2606 OID 17988)
-- Dependencies: 191 191 191 2632
-- Name: uni_acc_notyf_idacc_idphone; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT uni_acc_notyf_idacc_idphone UNIQUE (idaccount, idphone);


--
-- TOC entry 2455 (class 2606 OID 26363)
-- Dependencies: 184 184 2632
-- Name: uni_account_account; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_account UNIQUE (account);


--
-- TOC entry 2457 (class 2606 OID 17949)
-- Dependencies: 184 184 2632
-- Name: uni_account_name; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_name UNIQUE (name);


--
-- TOC entry 2487 (class 2606 OID 18043)
-- Dependencies: 202 202 202 202 202 2632
-- Name: uni_event_from_calls; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT uni_event_from_calls UNIQUE (idaccount, ideventtype, datetimeevent, idincall);


--
-- TOC entry 2461 (class 2606 OID 17073)
-- Dependencies: 185 185 2632
-- Name: uni_idaccount; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT uni_idaccount UNIQUE (idaccount);


--
-- TOC entry 2467 (class 2606 OID 17173)
-- Dependencies: 189 189 2632
-- Name: uni_idaccount_alocation; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT uni_idaccount_alocation UNIQUE (idaccount);


--
-- TOC entry 2519 (class 2606 OID 26394)
-- Dependencies: 224 224 2632
-- Name: uni_name_groups; Type: CONSTRAINT; Schema: opensaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT uni_name_groups UNIQUE (name);


SET search_path = public, pg_catalog;

--
-- TOC entry 2435 (class 2606 OID 16428)
-- Dependencies: 167 167 2632
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT id PRIMARY KEY (idphone);


--
-- TOC entry 2433 (class 2606 OID 16400)
-- Dependencies: 165 165 2632
-- Name: idcontact; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT idcontact PRIMARY KEY (idcontact);


--
-- TOC entry 2503 (class 2606 OID 26187)
-- Dependencies: 213 213 2632
-- Name: pk_city; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_city
    ADD CONSTRAINT pk_city PRIMARY KEY (idcity);


--
-- TOC entry 2445 (class 2606 OID 16632)
-- Dependencies: 177 177 2632
-- Name: pk_idbl; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT pk_idbl PRIMARY KEY (idbl);


--
-- TOC entry 2495 (class 2606 OID 26142)
-- Dependencies: 209 209 2632
-- Name: pk_idcountry; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_country
    ADD CONSTRAINT pk_idcountry PRIMARY KEY (idcountry);


--
-- TOC entry 2447 (class 2606 OID 16704)
-- Dependencies: 178 178 2632
-- Name: pk_idcpp; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY currentportsproviders
    ADD CONSTRAINT pk_idcpp PRIMARY KEY (idport);


--
-- TOC entry 2451 (class 2606 OID 16845)
-- Dependencies: 182 182 2632
-- Name: pk_idincall; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY incomingcalls
    ADD CONSTRAINT pk_idincall PRIMARY KEY (idincall);


--
-- TOC entry 2481 (class 2606 OID 17587)
-- Dependencies: 201 201 2632
-- Name: pk_idmodem; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY modem
    ADD CONSTRAINT pk_idmodem PRIMARY KEY (idmodem);


--
-- TOC entry 2437 (class 2606 OID 16464)
-- Dependencies: 169 169 2632
-- Name: pk_idprovider; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY provider
    ADD CONSTRAINT pk_idprovider PRIMARY KEY (idprovider);


--
-- TOC entry 2509 (class 2606 OID 26247)
-- Dependencies: 217 217 2632
-- Name: pk_idsector; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_sector
    ADD CONSTRAINT pk_idsector PRIMARY KEY (idsector);


--
-- TOC entry 2439 (class 2606 OID 16528)
-- Dependencies: 171 171 2632
-- Name: pk_idsmsin; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smsin
    ADD CONSTRAINT pk_idsmsin PRIMARY KEY (idsmsin);


--
-- TOC entry 2449 (class 2606 OID 16756)
-- Dependencies: 180 180 2632
-- Name: pk_idsmsoutopt; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smsoutoptions
    ADD CONSTRAINT pk_idsmsoutopt PRIMARY KEY (idsmsoutopt);


--
-- TOC entry 2499 (class 2606 OID 26167)
-- Dependencies: 211 211 2632
-- Name: pk_idstate; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_states
    ADD CONSTRAINT pk_idstate PRIMARY KEY (idstate);


--
-- TOC entry 2513 (class 2606 OID 26267)
-- Dependencies: 219 219 2632
-- Name: pk_idsubsector; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_subsector
    ADD CONSTRAINT pk_idsubsector PRIMARY KEY (idsubsector);


--
-- TOC entry 2443 (class 2606 OID 16609)
-- Dependencies: 175 175 2632
-- Name: pk_idwl; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT pk_idwl PRIMARY KEY (idwl);


--
-- TOC entry 2441 (class 2606 OID 16596)
-- Dependencies: 173 173 2632
-- Name: pk_smsout; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smsout
    ADD CONSTRAINT pk_smsout PRIMARY KEY (idsmsout);


--
-- TOC entry 2511 (class 2606 OID 26249)
-- Dependencies: 217 217 217 2632
-- Name: uni_idcity_name_sector; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_sector
    ADD CONSTRAINT uni_idcity_name_sector UNIQUE (idcity, name);


--
-- TOC entry 2515 (class 2606 OID 26269)
-- Dependencies: 219 219 219 2632
-- Name: uni_idsector_name_subsector; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_subsector
    ADD CONSTRAINT uni_idsector_name_subsector UNIQUE (idsector, name);


--
-- TOC entry 2505 (class 2606 OID 26229)
-- Dependencies: 213 213 213 2632
-- Name: uni_idstate_name_city; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_city
    ADD CONSTRAINT uni_idstate_name_city UNIQUE (idstate, name);


--
-- TOC entry 2501 (class 2606 OID 26222)
-- Dependencies: 211 211 211 2632
-- Name: uni_idstate_name_states; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_states
    ADD CONSTRAINT uni_idstate_name_states UNIQUE (idcountry, name);


--
-- TOC entry 2483 (class 2606 OID 17624)
-- Dependencies: 201 201 2632
-- Name: uni_imei_modem; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY modem
    ADD CONSTRAINT uni_imei_modem UNIQUE (imei);


--
-- TOC entry 2497 (class 2606 OID 26153)
-- Dependencies: 209 209 2632
-- Name: uni_namecountry; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_country
    ADD CONSTRAINT uni_namecountry UNIQUE (name);


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2554 (class 2620 OID 26838)
-- Dependencies: 278 184 2632
-- Name: ts_account; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account BEFORE UPDATE ON account FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2564 (class 2620 OID 26839)
-- Dependencies: 203 278 2632
-- Name: ts_account_contacts; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_contacts BEFORE UPDATE ON account_contacts FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2555 (class 2620 OID 26840)
-- Dependencies: 278 185 2632
-- Name: ts_account_installationdata; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_installationdata BEFORE UPDATE ON account_installationdata FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2557 (class 2620 OID 26841)
-- Dependencies: 278 189 2632
-- Name: ts_account_location; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_location BEFORE UPDATE ON account_location FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2558 (class 2620 OID 26842)
-- Dependencies: 278 191 2632
-- Name: ts_account_notifications; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_notifications BEFORE UPDATE ON account_notifications FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2559 (class 2620 OID 26843)
-- Dependencies: 193 278 2632
-- Name: ts_account_notifications_eventtype; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_notifications_eventtype BEFORE UPDATE ON account_notifications_eventtype FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2574 (class 2620 OID 26844)
-- Dependencies: 226 278 2632
-- Name: ts_account_notifications_group; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_notifications_group BEFORE UPDATE ON account_notifications_group FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2566 (class 2620 OID 26845)
-- Dependencies: 278 206 2632
-- Name: ts_account_phones_trigger_alarm; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_phones_trigger_alarm BEFORE UPDATE ON account_phones_trigger_alarm FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2565 (class 2620 OID 26846)
-- Dependencies: 205 278 2632
-- Name: ts_account_users; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_account_users BEFORE UPDATE ON account_users FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2560 (class 2620 OID 26847)
-- Dependencies: 195 278 2632
-- Name: ts_events; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_events BEFORE UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2561 (class 2620 OID 26848)
-- Dependencies: 196 278 2632
-- Name: ts_eventtypes; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_eventtypes BEFORE UPDATE ON eventtypes FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2573 (class 2620 OID 26849)
-- Dependencies: 224 278 2632
-- Name: ts_groups; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_groups BEFORE UPDATE ON groups FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2562 (class 2620 OID 26850)
-- Dependencies: 278 198 2632
-- Name: ts_keywords; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_keywords BEFORE UPDATE ON keywords FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2570 (class 2620 OID 26851)
-- Dependencies: 278 215 2632
-- Name: ts_notification_templates; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_notification_templates BEFORE UPDATE ON notification_templates FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2556 (class 2620 OID 26852)
-- Dependencies: 278 187 2632
-- Name: ts_panelmodel; Type: TRIGGER; Schema: opensaga; Owner: postgres
--

CREATE TRIGGER ts_panelmodel BEFORE UPDATE ON panelmodel FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


SET search_path = public, pg_catalog;

--
-- TOC entry 2569 (class 2620 OID 26822)
-- Dependencies: 278 213 2632
-- Name: ts_address_city; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_address_city BEFORE UPDATE ON address_city FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2567 (class 2620 OID 26824)
-- Dependencies: 209 278 2632
-- Name: ts_address_country; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_address_country BEFORE UPDATE ON address_country FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2571 (class 2620 OID 26825)
-- Dependencies: 217 278 2632
-- Name: ts_address_sector; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_address_sector BEFORE UPDATE ON address_sector FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2568 (class 2620 OID 26827)
-- Dependencies: 211 278 2632
-- Name: ts_address_states; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_address_states BEFORE UPDATE ON address_states FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2572 (class 2620 OID 26826)
-- Dependencies: 219 278 2632
-- Name: ts_address_subsector; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_address_subsector BEFORE UPDATE ON address_subsector FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2551 (class 2620 OID 26828)
-- Dependencies: 177 278 2632
-- Name: ts_blacklist; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_blacklist BEFORE UPDATE ON blacklist FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2544 (class 2620 OID 26829)
-- Dependencies: 165 278 2632
-- Name: ts_contacts; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_contacts BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2553 (class 2620 OID 26830)
-- Dependencies: 278 182 2632
-- Name: ts_incomingcalls; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_incomingcalls BEFORE UPDATE ON incomingcalls FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2563 (class 2620 OID 26831)
-- Dependencies: 201 278 2632
-- Name: ts_modem; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_modem BEFORE UPDATE ON modem FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2546 (class 2620 OID 26816)
-- Dependencies: 167 278 2632
-- Name: ts_phone; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_phone BEFORE UPDATE ON phones FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2545 (class 2620 OID 26832)
-- Dependencies: 167 278 2632
-- Name: ts_phones; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_phones BEFORE UPDATE ON phones FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2547 (class 2620 OID 26833)
-- Dependencies: 278 169 2632
-- Name: ts_provider; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_provider BEFORE UPDATE ON provider FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2548 (class 2620 OID 26834)
-- Dependencies: 278 171 2632
-- Name: ts_smsin; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_smsin BEFORE UPDATE ON smsin FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2549 (class 2620 OID 26835)
-- Dependencies: 173 278 2632
-- Name: ts_smsout; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_smsout BEFORE UPDATE ON smsout FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2552 (class 2620 OID 26836)
-- Dependencies: 278 180 2632
-- Name: ts_smsoutoptions; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_smsoutoptions BEFORE UPDATE ON smsoutoptions FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2550 (class 2620 OID 26837)
-- Dependencies: 278 175 2632
-- Name: ts_whitelist; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_whitelist BEFORE UPDATE ON whitelist FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


SET search_path = opensaga, pg_catalog;

--
-- TOC entry 2538 (class 2606 OID 26561)
-- Dependencies: 206 2452 184 2632
-- Name: fk_accnt_trigg_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2539 (class 2606 OID 26566)
-- Dependencies: 167 206 2434 2632
-- Name: fk_accnt_trigg_idphone; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idphone FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2536 (class 2606 OID 26887)
-- Dependencies: 2452 205 184 2632
-- Name: fk_account_users_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2537 (class 2606 OID 26892)
-- Dependencies: 205 165 2432 2632
-- Name: fk_account_users_idcontact; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idcontact FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2527 (class 2606 OID 26491)
-- Dependencies: 184 185 2452 2632
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2529 (class 2606 OID 26510)
-- Dependencies: 189 2452 184 2632
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_location
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2534 (class 2606 OID 26921)
-- Dependencies: 2452 203 184 2632
-- Name: fk_idaccount_contacts; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idaccount_contacts FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2530 (class 2606 OID 26871)
-- Dependencies: 2452 191 184 2632
-- Name: fk_idaccount_notif; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idaccount_notif FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2535 (class 2606 OID 26926)
-- Dependencies: 165 203 2432 2632
-- Name: fk_idcontact_contacts; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idcontact_contacts FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2533 (class 2606 OID 26614)
-- Dependencies: 2476 198 196 2632
-- Name: fk_ideventtype_kw; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT fk_ideventtype_kw FOREIGN KEY (ideventtype) REFERENCES eventtypes(ideventtype) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2532 (class 2606 OID 26540)
-- Dependencies: 191 193 2468 2632
-- Name: fk_idnotifaccount_eetype; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT fk_idnotifaccount_eetype FOREIGN KEY (idnotifaccount) REFERENCES account_notifications(idnotifaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2528 (class 2606 OID 26496)
-- Dependencies: 2462 187 185 2632
-- Name: fk_idpanelmodel; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idpanelmodel FOREIGN KEY (idpanelmodel) REFERENCES panelmodel(idpanelmodel) ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- TOC entry 2531 (class 2606 OID 26876)
-- Dependencies: 2434 191 167 2632
-- Name: fk_idphone_notif; Type: FK CONSTRAINT; Schema: opensaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idphone_notif FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- TOC entry 2542 (class 2606 OID 26667)
-- Dependencies: 2502 217 213 2632
-- Name: fk_idcity_sector; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_sector
    ADD CONSTRAINT fk_idcity_sector FOREIGN KEY (idcity) REFERENCES address_city(idcity) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2522 (class 2606 OID 26817)
-- Dependencies: 165 2432 167 2632
-- Name: fk_idcontact; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT fk_idcontact FOREIGN KEY (idcontact) REFERENCES contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2540 (class 2606 OID 26681)
-- Dependencies: 211 209 2494 2632
-- Name: fk_idcountry_states; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_states
    ADD CONSTRAINT fk_idcountry_states FOREIGN KEY (idcountry) REFERENCES address_country(idcountry) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2525 (class 2606 OID 26709)
-- Dependencies: 177 167 2434 2632
-- Name: fk_idphone; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT fk_idphone FOREIGN KEY (idphone) REFERENCES phones(idphone);


--
-- TOC entry 2523 (class 2606 OID 26805)
-- Dependencies: 167 2434 175 2632
-- Name: fk_idphone; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT fk_idphone FOREIGN KEY (idphone) REFERENCES phones(idphone);


--
-- TOC entry 2526 (class 2606 OID 26714)
-- Dependencies: 177 169 2436 2632
-- Name: fk_idprovider; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT fk_idprovider FOREIGN KEY (idprovider) REFERENCES provider(idprovider) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2524 (class 2606 OID 26810)
-- Dependencies: 169 175 2436 2632
-- Name: fk_idprovider; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT fk_idprovider FOREIGN KEY (idprovider) REFERENCES provider(idprovider) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2543 (class 2606 OID 26696)
-- Dependencies: 219 217 2508 2632
-- Name: fk_idsector; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_subsector
    ADD CONSTRAINT fk_idsector FOREIGN KEY (idsector) REFERENCES address_sector(idsector) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2541 (class 2606 OID 26644)
-- Dependencies: 213 211 2498 2632
-- Name: fk_idstate_city; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_city
    ADD CONSTRAINT fk_idstate_city FOREIGN KEY (idstate) REFERENCES address_states(idstate) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2639 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-01-15 13:42:02 ECT

--
-- PostgreSQL database dump complete
--

