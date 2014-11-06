--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.13
-- Dumped by pg_dump version 9.1.13
-- Started on 2014-08-06 08:13:50 ECT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2901 (class 1262 OID 16384)
-- Name: usms; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE usms WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'es_EC.utf8' LC_CTYPE = 'es_EC.utf8';


ALTER DATABASE usms OWNER TO postgres;

\connect usms

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2902 (class 1262 OID 16384)
-- Dependencies: 2901
-- Name: usms; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE usms IS 'Base de datos de uSMS.';


--
-- TOC entry 6 (class 2615 OID 17402)
-- Name: usaga; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA usaga;


ALTER SCHEMA usaga OWNER TO postgres;

--
-- TOC entry 2904 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA usaga; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA usaga IS 'Esquema de detos de uSAGA';


--
-- TOC entry 249 (class 3079 OID 11644)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2905 (class 0 OID 0)
-- Dependencies: 249
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 335 (class 1255 OID 18666)
-- Dependencies: 7 986
-- Name: ctrl_tables_changed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ctrl_tables_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN

IF EXISTS(SELECT * FROM tables_changed WHERE tname = TG_TABLE_NAME) THEN
UPDATE tables_changed SET tts = now() WHERE tname = TG_TABLE_NAME;
ELSE
INSERT INTO tables_changed (tname) VALUES (TG_TABLE_NAME);
END IF;

RETURN NULL;
END;$$;


ALTER FUNCTION public.ctrl_tables_changed() OWNER TO postgres;

--
-- TOC entry 2906 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION ctrl_tables_changed(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION ctrl_tables_changed() IS 'Inserta en la tabla tables_changed cuando existe algun cambio en una tabla.';


--
-- TOC entry 261 (class 1255 OID 17403)
-- Dependencies: 7 986
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
-- TOC entry 262 (class 1255 OID 17404)
-- Dependencies: 7 986
-- Name: fun_address_edit(integer, integer, double precision, double precision, text, text, text, text, text, text, text, text, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_address_edit(inidaddress integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

outreturn := 0;
outpgmsg := 'Ninguna acción realizada';

CASE

WHEN inidaddress = 0  OR inidaddress IS NULL THEN   
INSERT INTO address (idlocation, geox, geoy, field1, field2, field3, field4, field5, field6, field7, field8, field9, field10) VALUES (inidlocation, ingeox, ingeoy, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10) RETURNING idaddress INTO outreturn;
outpgmsg := 'Nuevo registro creado, idaddress = '||outreturn::text;

WHEN inidaddress > 0 THEN

IF EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
UPDATE address SET idlocation = inidlocation, geox = ingeox, geoy = ingeoy, field1 = f1, field2 = f2, field3 = f3, field4 = f4, field5 = f5, field6  = f6, field7 = f7, field8 = f8, field9 = f9, field10 = f10 WHERE idaddress = inidaddress RETURNING idaddress INTO outreturn;
outpgmsg := 'Actualizado registro idaddress = '||outreturn::text;
ELSE
outreturn := 0;
outpgmsg := 'El idaddress '||inidaddress::text||' no existe.';
END IF;

WHEN inidaddress < 0 AND EXISTS(SELECT * FROM address WHERE idaddress = abs(inidaddress)) THEN
DELETE FROM address WHERE idaddress = abs(inidaddress);
outreturn := 0;
outpgmsg := 'Eliminado el registro idaddress '|| abs(inidaddress)::text;


ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION public.fun_address_edit(inidaddress integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 2907 (class 0 OID 0)
-- Dependencies: 262
-- Name: FUNCTION fun_address_edit(inidaddress integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_address_edit(inidaddress integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) IS 'Edita la direccion.';


--
-- TOC entry 263 (class 1255 OID 17405)
-- Dependencies: 7 986
-- Name: fun_address_edit_xml(integer, integer, double precision, double precision, text, text, text, text, text, text, text, text, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_address_edit_xml(inidaddress integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE
outreturn integer default 0;
outpgmsg TEXT DEFAULT 'Ninguna acción realizada';
BEGIN
SELECT fun_address_edit.outreturn, fun_address_edit.outpgmsg INTO outreturn, outpgmsg FROM fun_address_edit(inidaddress, inidlocation, ingeox, ingeoy, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, ints, fieldtextasbase64);
RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_address_edit_xml(inidaddress integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 17406)
-- Dependencies: 7 986
-- Name: fun_address_getdata_string(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_address_getdata_string(inidaddress integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
AddressROWDATA   address%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO AddressROWDATA FROM address WHERE idaddress = inidaddress;

--Retorno := fun_location_getdata_string(AddressROWDATA.idlocation, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
                            --    raise notice 'row = %',i_string[1];                      
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(AddressROWDATA.idaddress::text,''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(AddressROWDATA.idlocation::text,''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(AddressROWDATA.geox::text,''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(AddressROWDATA.geoy::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(AddressROWDATA.field1::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(AddressROWDATA.field2::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(AddressROWDATA.field3::text,''));

	WHEN i_string[1] = '08' THEN
Retorno := replace(Retorno, prefix||'08', COALESCE(AddressROWDATA.field4::text,''));

	WHEN i_string[1] = '09' THEN
Retorno := replace(Retorno, prefix||'09', COALESCE(AddressROWDATA.field5::text,''));

	WHEN i_string[1] = '10' THEN
Retorno := replace(Retorno, prefix||'10', COALESCE(AddressROWDATA.field6::text,''));

	WHEN i_string[1] = '11' THEN
Retorno := replace(Retorno, prefix||'11', COALESCE(AddressROWDATA.field7::text,''));

	WHEN i_string[1] = '12' THEN
Retorno := replace(Retorno, prefix||'12', COALESCE(AddressROWDATA.field8::text,''));

	WHEN i_string[1] = '13' THEN
Retorno := replace(Retorno, prefix||'13', COALESCE(AddressROWDATA.field8::text,''));

	WHEN i_string[1] = '14' THEN
Retorno := replace(Retorno, prefix||'14', COALESCE(AddressROWDATA.field10::text,''));

	WHEN i_string[1] = '15' THEN
Retorno := replace(Retorno, prefix||'15', COALESCE(AddressROWDATA.geourl::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;


RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_address_getdata_string(inidaddress integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 403 (class 1255 OID 35688)
-- Dependencies: 7 986
-- Name: fun_attachments_insert_row(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_attachments_insert_row(inname text, inmd5 text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

R INTEGER DEFAULT 0;

BEGIN

IF EXISTS(SELECT * FROM attachments WHERE md5 = inmd5) THEN

SELECT idattach INTO R FROM attachments WHERE md5 = inmd5;

ELSE

INSERT INTO attachments (file, md5) VALUES (inname, inmd5) RETURNING idattach INTO R;

END IF;

RETURN R;
END;$$;


ALTER FUNCTION public.fun_attachments_insert_row(inname text, inmd5 text) OWNER TO postgres;

--
-- TOC entry 2908 (class 0 OID 0)
-- Dependencies: 403
-- Name: FUNCTION fun_attachments_insert_row(inname text, inmd5 text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_attachments_insert_row(inname text, inmd5 text) IS 'Revisa si el archivo existe, si es asi devuelve su id, caso contrario lo inserta y devuelve el id';


--
-- TOC entry 414 (class 1255 OID 35589)
-- Dependencies: 986 7
-- Name: fun_attachments_rows_as_json(integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_attachments_rows_as_json(inidattach integer[]) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

temp_array text[];
_Cursor CURSOR FOR SELECT * FROM attachments WHERE idattach = ANY(inidattach);
_Registro attachments%ROWTYPE;

BEGIN

OPEN _Cursor;

        loop fetch _Cursor into _Registro;
        exit when not found;

      --PERFORM SELECT * FROM attachments;
		
    --raise notice 'Retornocxx = %','asdasd';                                                
temp_array := array_append(temp_array, '{"real_name":"'||tob64(_Registro.file)||'",'||'"file_name":"'||_Registro.md5||'"}');
        end loop;
        close _Cursor;

return  '{"attachments":['||  array_to_string(temp_array, ',')||']}';
END;$$;


ALTER FUNCTION public.fun_attachments_rows_as_json(inidattach integer[]) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 17407)
-- Dependencies: 7 986
-- Name: fun_contact_address_edit_xml(integer, integer, double precision, double precision, text, text, text, text, text, text, text, text, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contact_address_edit_xml(inidcontact integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
Retorno text default '<table></table>';
xidaddress INTEGER DEFAULT 0;
outreturn integer default 0;
outpgmsg text default 'Ninguna acción realizada';

BEGIN

IF EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
SELECT contacts.idaddress INTO xidaddress FROM contacts WHERE idcontact = inidcontact;

SELECT fun_address_edit.outreturn, fun_address_edit.outpgmsg INTO outreturn, outpgmsg FROM fun_address_edit(xidaddress, inidlocation, ingeox, ingeoy, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, ints, false);

IF outreturn > 0 THEN
UPDATE contacts SET idaddress = outreturn WHERE idcontact = inidcontact;
ELSE
UPDATE contacts SET idaddress = NULL WHERE idcontact = inidcontact;
END IF;



ELSE
outreturn := 0;
outpgmsg := 'El idaccount ='||abs(inidaccount)::text||' no existe.';
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_contact_address_edit_xml(inidcontact integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 412 (class 1255 OID 35397)
-- Dependencies: 986 7
-- Name: fun_contact_change_groups(integer, integer, boolean, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contact_change_groups(inidcontact integer, inidgroup integer, inbelong boolean, fieldtextasbase64 boolean, OUT outpgmsg text, OUT outreturn integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE
tempArray integer[];
--tempArrayini integer[];
tempidgroup integer;

BEGIN

outpgmsg := 'Ninguna accion realizada';
outreturn := 0;

--SELECT groups INTO tempArrayini FROM contacts WHERE idcontact = inidcontact;

IF NOT EXISTS(SELECT * FROM groups WHERE idgroup = inidgroup) THEN
inbelong:=false;
END IF;

--SELECT groups INTO temArray FROM contacts WHERE idcontact = inidcontact;

IF inbelong THEN
UPDATE contacts SET groups = array_append(groups, inidgroup) WHERE idcontact = inidcontact;
outpgmsg := 'Contacto agregado al grupo';
ELSE

  FOREACH tempidgroup IN ARRAY (SELECT groups FROM contacts WHERE idcontact = inidcontact)
  LOOP
IF tempidgroup != inidgroup THEN
tempArray := array_append(tempArray, tempidgroup);
END IF;

    
  END LOOP;

UPDATE contacts SET groups = tempArray WHERE idcontact = inidcontact;
outpgmsg := 'Contacto eliminado del grupo';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;

END;$$;


ALTER FUNCTION public.fun_contact_change_groups(inidcontact integer, inidgroup integer, inbelong boolean, fieldtextasbase64 boolean, OUT outpgmsg text, OUT outreturn integer) OWNER TO postgres;

--
-- TOC entry 409 (class 1255 OID 35410)
-- Dependencies: 986 7
-- Name: fun_contact_change_groups_xml(integer, integer, boolean, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contact_change_groups_xml(inidcontact integer, inidgroup integer, inbelong boolean, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN
--fun_contacts_table_xml(IN inidcontact integer, IN inenable boolean, IN intitle text, IN infirstname text, IN inlastname text, IN ingender integer, IN inbirthday date, IN intypeofid integer, IN inidentification text, IN inweb text, IN inemail1 text, IN inemail2 text, IN inidaddress text, IN note text)

OPEN CursorResultado FOR SELECT * FROM fun_contact_change_groups(inidcontact, inidgroup, inbelong, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_contact_change_groups_xml(inidcontact integer, inidgroup integer, inbelong boolean, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 17408)
-- Dependencies: 7 986
-- Name: fun_contact_getdata_string(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contact_getdata_string(inidcontact integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
ContactROWDATA   contacts%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO ContactROWDATA FROM contacts WHERE idcontact = inidcontact;
  
--Retorno := fun_address_getdata_string(ContactROWDATA.idaddress, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';

--raise notice 'i_query = %',i_query;                                                

    open i_strings for execute i_query; 
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
    --raise notice 'Retornocxx = %',Retorno;                                                
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(ContactROWDATA.idcontact::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(ContactROWDATA.enable::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(ContactROWDATA.title::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(ContactROWDATA.firstname::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(ContactROWDATA.lastname::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(ContactROWDATA.gender::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(ContactROWDATA.birthday::text,''));

	WHEN i_string[1] = '08' THEN
Retorno := replace(Retorno, prefix||'08', COALESCE(ContactROWDATA.typeofid::text,''));

	WHEN i_string[1] = '09' THEN
Retorno := replace(Retorno, prefix||'09', COALESCE(ContactROWDATA.identification::text,''));

	WHEN i_string[1] = '10' THEN
Retorno := replace(Retorno, prefix||'10', COALESCE(ContactROWDATA.web::text,''));

	WHEN i_string[1] = '11' THEN
Retorno := replace(Retorno, prefix||'11', COALESCE(ContactROWDATA.email1::text,''));

	WHEN i_string[1] = '12' THEN
Retorno := replace(Retorno, prefix||'12', COALESCE(ContactROWDATA.email2::text,''));

	WHEN i_string[1] = '13' THEN
Retorno := replace(Retorno, prefix||'13', COALESCE(ContactROWDATA.idaddress::text,''));

	WHEN i_string[1] = '14' THEN
Retorno := replace(Retorno, prefix||'14', COALESCE(ContactROWDATA.note::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;

--raise notice 'Retornoxxx = %',Retorno;                                                


RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_contact_getdata_string(inidcontact integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 17409)
-- Dependencies: 7 986
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
-- TOC entry 2909 (class 0 OID 0)
-- Dependencies: 267
-- Name: FUNCTION fun_contact_search_by_name(infirstname text, inlastname text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_contact_search_by_name(infirstname text, inlastname text) IS 'Obtiene el idcontact segun el firstname y lastname pasado como parametro.
Si no lo encuentra devuelve 0.';


--
-- TOC entry 431 (class 1255 OID 35848)
-- Dependencies: 986 7
-- Name: fun_contacts_check_data(integer, text, text, text, integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contacts_check_data(cinidcontact integer, INOUT cinfirstname text, INOUT cinlastname text, INOUT cinidentification text, INOUT cintypeofid integer, INOUT cinemail1 text, INOUT cinemail2 text, INOUT cinidaddress integer, OUT isvalid integer, OUT coutpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
isvalid := 0;

IF NOT EXISTS(SELECT * FROM address WHERE idaddress = cinidaddress) THEN
cinidaddress := null;
END IF;


CASE
	WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = cinidentification AND typeofid = cintypeofid AND NOT idcontact = cinidcontact) AND cinidcontact >= 0 THEN
 -- El numero de identification ya existe en otro contacto
isvalid := 1;
coutpgmsg := 'El número de identificación '||cinidentification::text||' tipo '||cintypeofid::text||' ya existe en otro contacto, verifique los datos';

	WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(cinfirstname)) AND upper(trim(lastname)) = upper(trim(cinlastname)) AND NOT idcontact = cinidcontact) AND cinidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
isvalid := 2;
coutpgmsg := 'El nombre '||cinfirstname::text||' '||cinlastname::text||' ya existe, utilice otro nombre';

	WHEN (length(cinfirstname) < 1 OR length(cinlastname) < 1) AND cinidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
isvalid := 3;
coutpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

WHEN length(cinemail1) > 0 AND cinemail1 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := 4;
coutpgmsg := 'La direccion de email: '||cinemail1||' no tiene un formato válido';

WHEN length(cinemail2) > 0  AND cinemail2 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := 5;
coutpgmsg := 'La direccion de email: '||cinemail2||' no tiene un formato válido';

--	WHEN cinidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = cinidcontact) THEN
-- Actualiza si el contacto existe
--UPDATE contacts SET enable = inenable, title = intitle, firstname =cinfirstname, lastname = cinlastname, gender = ingender, birthday = inbirthday, typeofid = cintypeofid, identification = cinidentification, web = inweb, email1 = cinemail1, email2 = cinemail2, note = innote, idaddress = cinidaddress WHERE idcontact = cinidcontact RETURNING idcontact INTO outreturn;
--coutpgmsg := 'idcontact '||cinidcontact::text||' actualizado.';
--isvalid := false;

	--WHEN cinidcontact = 0 THEN
-- Insertamos un nuevo registro
--INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, cinfirstname, cinlastname, ingender, inbirthday, cintypeofid, cinidentification, inweb, cinemail1, cinemail2, innote) RETURNING idcontact INTO outreturn;
--coutpgmsg := 'idcontact '||outreturn::text||' creado.';


--	WHEN cinidcontact < 0 THEN
-- Eliminamos el registro de direccion
--DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(cinidcontact));
-- Eliminamos el contacto
--DELETE FROM contacts WHERE idcontact = abs(cinidcontact);
--outreturn := 0;
--coutpgmsg := 'idcontact '||cinidcontact::text||' eliminado.';

ELSE
--outreturn := abs(cinidcontact);
--coutpgmsg := 'Ninguna accion realizada';
isvalid := 0;
END CASE;

--IF fieldtextasbase64 THEN
--coutpgmsg := encode(coutpgmsg::bytea, 'base64');
--END IF;

RETURN;
END;$_$;


ALTER FUNCTION public.fun_contacts_check_data(cinidcontact integer, INOUT cinfirstname text, INOUT cinlastname text, INOUT cinidentification text, INOUT cintypeofid integer, INOUT cinemail1 text, INOUT cinemail2 text, INOUT cinidaddress integer, OUT isvalid integer, OUT coutpgmsg text) OWNER TO postgres;

--
-- TOC entry 432 (class 1255 OID 17410)
-- Dependencies: 986 7
-- Name: fun_contacts_edit(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contacts_edit(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE
valid_data integer default 0;

BEGIN

-- Chequeamos la validez de los datos
SELECT cinfirstname, cinlastname, cinidentification, cintypeofid, cinemail1, cinemail2, cinidaddress, isvalid, coutpgmsg 
 INTO infirstname, inlastname, inidentification, intypeofid, inemail1, inemail2, inidaddress, valid_data, outpgmsg
FROM fun_contacts_check_data(inidcontact, infirstname, inlastname, inidentification, intypeofid, inemail1, inemail2, inidaddress);

  
--IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
--inidaddress := null;
--END IF;

CASE
WHEN valid_data > 0  THEN
	--WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = inidentification AND typeofid = intypeofid AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El numero de identification ya existe en otro contacto
outreturn := abs(inidcontact);

--outpgmsg := 'El número de identificación '||inidentification::text||' tipo '||intypeofid::text||' ya existe en otro contacto, verifique los datos';

--WHEN isvalid = 2 THEN
	--WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
--outreturn := abs(inidcontact);
--outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';

--WHEN isvalid = 3 THEN
--	WHEN (length(infirstname) < 1 OR length(inlastname) < 1) AND inidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
--outreturn := abs(inidcontact);
--outpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
-- Actualiza si el contacto existe
UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';

	WHEN inidcontact = 0 THEN
-- Insertamos un nuevo registro
INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote) RETURNING idcontact INTO outreturn;
outpgmsg := 'idcontact '||outreturn::text||' creado.';


	WHEN inidcontact < 0 THEN
-- Eliminamos el registro de direccion
DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(inidcontact));
-- Eliminamos el contacto
DELETE FROM contacts WHERE idcontact = abs(inidcontact);
outreturn := 0;
outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

ELSE
outreturn := abs(inidcontact);
outpgmsg := 'Ninguna accion realizada';
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION public.fun_contacts_edit(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 423 (class 1255 OID 17411)
-- Dependencies: 986 7
-- Name: fun_contacts_edit_xml(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_contacts_edit_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN
--fun_contacts_table_xml(IN inidcontact integer, IN inenable boolean, IN intitle text, IN infirstname text, IN inlastname text, IN ingender integer, IN inbirthday date, IN intypeofid integer, IN inidentification text, IN inweb text, IN inemail1 text, IN inemail2 text, IN inidaddress text, IN note text)

--TODO Esta funcion es temporal para ingresar el contacto directamente en la tabla accounts de uSAGA y DEBE ser eliminada.
--OPEN CursorResultado FOR SELECT * FROM usaga.fun_accounts_edit(inidcontact, inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, inidaddress, innote, fieldtextasbase64);

OPEN CursorResultado FOR SELECT * FROM fun_contacts_edit(inidcontact, inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, inidaddress, innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_contacts_edit_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 17412)
-- Dependencies: 986 7
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
-- TOC entry 2910 (class 0 OID 0)
-- Dependencies: 269
-- Name: FUNCTION fun_correntportproviders_get_idprovider(inidport integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_correntportproviders_get_idprovider(inidport integer) IS 'Obtiene el idprovider desde la tabla currentportsproviders segun el idport pasado como parametro.';


--
-- TOC entry 270 (class 1255 OID 17413)
-- Dependencies: 7 986
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
-- TOC entry 2911 (class 0 OID 0)
-- Dependencies: 270
-- Name: FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_currentportsproviders_insertupdate(inidport integer, inport text, incimi text, inimei text) IS 'Funcion que inserta o actualiza los datos de la tabla currentportsproviders con datos enviados desde el puerto serial.';


--
-- TOC entry 407 (class 1255 OID 35724)
-- Dependencies: 7 986
-- Name: fun_gen_query_view_contacts_groups(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_gen_query_view_contacts_groups() RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE
R TEXT DEFAULT 'SELECT * FROM contacts';
groups_cursor CURSOR FOR SELECT idgroup, name FROM groups;
idgtemp INTEGER DEFAULT 0;
namegtemp TEXT DEFAULT '';

BEGIN

R := 'SELECT * ';

OPEN groups_cursor;
loop
--fetch the table row inside the loop
FETCH groups_cursor INTO idgtemp, namegtemp;
--check if there is no record
   --exit from loop when record not found
   if not found then
        exit ;

   end if;

R := R||', COALESCE((SELECT '||idgtemp::text||' = ANY(groups)), false) as '||regexp_replace(lower(namegtemp), '[^\w\.@-\\s]+', '', 'g');
end loop;

R := R||' FROM contacts';

RETURN R;
END;
$$;


ALTER FUNCTION public.fun_gen_query_view_contacts_groups() OWNER TO postgres;

--
-- TOC entry 2912 (class 0 OID 0)
-- Dependencies: 407
-- Name: FUNCTION fun_gen_query_view_contacts_groups(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_gen_query_view_contacts_groups() IS 'Genera el Query necesario para mostar en cada registro de contacto a que grupo pertenece';


--
-- TOC entry 271 (class 1255 OID 17414)
-- Dependencies: 986 7
-- Name: fun_get_idsim(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_get_idsim(inphone text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno integer default 0;

BEGIN

IF EXISTS(SELECT idsim FROM sim WHERE phone = inphone) THEN
SELECT idsim INTO Retorno FROM sim WHERE phone = inphone;
ELSE
INSERT INTO sim (phone) VALUES (inphone) RETURNING idsim INTO Retorno; 
END IF;

return Retorno;
END;$$;


ALTER FUNCTION public.fun_get_idsim(inphone text) OWNER TO postgres;

--
-- TOC entry 2913 (class 0 OID 0)
-- Dependencies: 271
-- Name: FUNCTION fun_get_idsim(inphone text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_get_idsim(inphone text) IS 'Obtiene el idsim segun el número telefonico pasado como parametro, si no existe se crea un registro.';


--
-- TOC entry 380 (class 1255 OID 18500)
-- Dependencies: 7 986
-- Name: fun_group_getdata_string(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_group_getdata_string(inidgroup integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
GroupROWDATA   groups%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO GroupROWDATA FROM groups WHERE idgroup = inidgroup;
  
--Retorno := fun_address_getdata_string(PhonesROWDATA.idaddress, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
--    raise notice 'row4 = %',Retorno;                                                
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(GroupROWDATA.idgroup::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(GroupROWDATA.enable::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(GroupROWDATA.name::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(GroupROWDATA.note::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;




RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_group_getdata_string(inidgroup integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 415 (class 1255 OID 18501)
-- Dependencies: 7 986
-- Name: fun_groups_edit(integer, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_groups_edit(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outpgmsg text, OUT outreturn integer) RETURNS record
    LANGUAGE plpgsql
    AS $$BEGIN

-- Veirificar que los nombres de los grupos no se repitan

CASE

	WHEN inidgroup > 0 AND EXISTS(SELECT * FROM groups WHERE idgroup = inidgroup)  THEN
	-- Verificamos que el nombre no este en blanco y que no exista ya en otro registro
IF length(inname) > 0 AND NOT EXISTS(SELECT * FROM groups WHERE name = inname AND NOT (idgroup = inidgroup)) THEN
-- Actualizamos
UPDATE groups SET enable = inenable, name = inname, note = innote WHERE idgroup = inidgroup RETURNING idgroup INTO outreturn;
outpgmsg:='Registro actualizado';
ELSE
outpgmsg:='No se pudo actualizar, verifique el nombre del grupo no este en blanco o que ya exista en otro registro.';
outreturn := 0;
END IF;
	WHEN  inidgroup = 0 THEN
IF length(inname) > 0 AND NOT EXISTS(SELECT * FROM groups WHERE name = inname)  THEN
-- Creamo un nuevo registro
INSERT INTO groups (enable, name, note) VALUES (inenable, inname, innote) RETURNING idgroup INTO outreturn;
outpgmsg:='Nuevo grupo registrado';
ELSE
outpgmsg:='El nombre de grupo "'||inname::text||'" no es válido, utilice otro.';
outreturn := 0;
END IF;

	WHEN inidgroup < 0 AND EXISTS(SELECT * FROM groups WHERE idgroup = abs(inidgroups)) THEN
DELETE FROM groups WHERE idgroup = abs(inidgroups);
outpgmsg:='Registro eliminado';
outreturn := 0;
ELSE
outpgmsg:='Ninguna accion realizada';
outreturn := 0;
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;

END;$$;


ALTER FUNCTION public.fun_groups_edit(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outpgmsg text, OUT outreturn integer) OWNER TO postgres;

--
-- TOC entry 381 (class 1255 OID 18502)
-- Dependencies: 7 986
-- Name: fun_groups_edit_xml(integer, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_groups_edit_xml(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM fun_groups_edit(inidgroup, inenable, inname, innote, ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_groups_edit_xml(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 382 (class 1255 OID 18503)
-- Dependencies: 986 7
-- Name: fun_groups_remove_selected(integer[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_groups_remove_selected(idgroups integer[], fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$BEGIN
outpgmsg := 'Ninguna accion realizada';
outreturn := 0;


FOR i IN array_lower(idgroups,1) .. array_upper(idgroups,1) LOOP

-- Buscamos si existe el registro

IF EXISTS(SELECT * FROM groups WHERE idgroup = idgroups[i]) THEN
DELETE FROM groups WHERE idgroup = idgroups[i];
outreturn := outreturn+1;
END IF;


END LOOP;

outpgmsg := 'Se han eliminado '||outreturn::text||' grupos.';

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION public.fun_groups_remove_selected(idgroups integer[], fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 383 (class 1255 OID 18504)
-- Dependencies: 7 986
-- Name: fun_groups_remove_selected_xml(integer[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_groups_remove_selected_xml(idgroups integer[], fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM fun_groups_remove_selected(idgroups, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_groups_remove_selected_xml(idgroups integer[], fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 17415)
-- Dependencies: 7 986
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
-- TOC entry 2914 (class 0 OID 0)
-- Dependencies: 272
-- Name: FUNCTION fun_idphone_from_phone(inphone text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_idphone_from_phone(inphone text) IS 'Obtenemos el idphone segun el phone pasado como parametro';


--
-- TOC entry 273 (class 1255 OID 17416)
-- Dependencies: 986 7
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
-- TOC entry 2915 (class 0 OID 0)
-- Dependencies: 273
-- Name: FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_incomingcalls_insert(indatecall timestamp without time zone, inidport integer, incalaction integer, inphone text, innote text) IS 'Registra las llamadas entrantes provenientes de los modems';


--
-- TOC entry 274 (class 1255 OID 17417)
-- Dependencies: 986 7
-- Name: fun_incomingcalls_insert_online(integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN 
RETURN fun_incomingcalls_insert('now()', inidport, incallaction, inphone, innote); 
END;$$;


ALTER FUNCTION public.fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) OWNER TO postgres;

--
-- TOC entry 2916 (class 0 OID 0)
-- Dependencies: 274
-- Name: FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_incomingcalls_insert_online(inidport integer, incallaction integer, inphone text, innote text) IS 'Funcion para insertar la fecha en modo online, registra la llamada con la fecha actual.';


--
-- TOC entry 276 (class 1255 OID 17418)
-- Dependencies: 986 7
-- Name: fun_location_getdata_string(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_getdata_string(inidlocation integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
VLIdLROWDATA   view_location_idlocation%ROWTYPE;
VLFROWDATA   view_locations_full%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO VLIdLROWDATA FROM view_location_idlocation WHERE idlocation = inidlocation LIMIT 1;
-- raise notice 'row = %',VLIdLROWDATA;                                                     
SELECT * INTO VLFROWDATA FROM view_locations_full WHERE (idl1 = VLIdLROWDATA.idl1 OR idl1 IS NULL) AND (idl2 = VLIdLROWDATA.idl2 OR idl2 IS NULL) AND (idl3 = VLIdLROWDATA.idl3 OR idl3 IS NULL) AND (idl4 = VLIdLROWDATA.idl4 OR idl4 IS NULL) AND (idl5 = VLIdLROWDATA.idl5 OR idl5 IS NULL) AND (idl6 = VLIdLROWDATA.idl6 OR idl6 IS NULL) limit 1;

-- raise notice 'row = %',VLFROWDATA;                                                     

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
                               -- raise notice 'row = %',i_query;  
  --raise notice 'row = %',i_string[1];                                                     
CASE   
	WHEN i_string[1] = '01' THEN
	    --raise notice 'row = %',VLFROWDATA.l1name;  
Retorno := replace(Retorno, prefix||'01', COALESCE(VLFROWDATA.idl1::text,''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(VLFROWDATA.l1name::text,''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(VLFROWDATA.l1code::text,''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(VLFROWDATA.idl2::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(VLFROWDATA.l2name::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(VLFROWDATA.l2code::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(VLFROWDATA.idl3::text,''));

	WHEN i_string[1] = '08' THEN
Retorno := replace(Retorno, prefix||'08', COALESCE(VLFROWDATA.l3name::text,''));

	WHEN i_string[1] = '09' THEN
Retorno := replace(Retorno, prefix||'09', COALESCE(VLFROWDATA.l3code::text,''));

	WHEN i_string[1] = '10' THEN
Retorno := replace(Retorno, prefix||'10', COALESCE(VLFROWDATA.idl4::text,''));

	WHEN i_string[1] = '11' THEN
Retorno := replace(Retorno, prefix||'11', COALESCE(VLFROWDATA.l4name::text,''));

	WHEN i_string[1] = '12' THEN
Retorno := replace(Retorno, prefix||'12', COALESCE(VLFROWDATA.l4code::text,''));

	WHEN i_string[1] = '13' THEN
Retorno := replace(Retorno, prefix||'13', COALESCE(VLFROWDATA.idl5::text,''));

	WHEN i_string[1] = '14' THEN
Retorno := replace(Retorno, prefix||'14', COALESCE(VLFROWDATA.l5name::text,''));

	WHEN i_string[1] = '15' THEN
Retorno := replace(Retorno, prefix||'15', COALESCE(VLFROWDATA.l5code::text,''));

	WHEN i_string[1] = '16' THEN
Retorno := replace(Retorno, prefix||'16', COALESCE(VLFROWDATA.idl6::text,''));

	WHEN i_string[1] = '17' THEN
Retorno := replace(Retorno, prefix||'17', COALESCE(VLFROWDATA.l6name::text,''));

	WHEN i_string[1] = '18' THEN
Retorno := replace(Retorno, prefix||'18', COALESCE(VLFROWDATA.l6code::text,''));

	WHEN i_string[1] = '19' THEN
Retorno := replace(Retorno, prefix||'19', COALESCE(inidlocation::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;



RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_location_getdata_string(inidlocation integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 17419)
-- Dependencies: 7 986
-- Name: fun_location_level1_edit_xml(integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level1_edit_xml(inidl1 integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn INTEGER DEFAULT 0;
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';
namevalid BOOLEAN DEFAULT FALSE;

BEGIN

-- Verificamos que el nombre no se repita en otro registro
IF length(inname) > 2 AND NOT EXISTS(SELECT * FROM location_level1 WHERE name = inname AND idl1 != inidl1)  THEN
namevalid := TRUE;
END IF;


CASE

WHEN inidl1 = 0 THEN   

IF namevalid THEN
INSERT INTO location_level1 (name, code) VALUES (inname, incode) RETURNING idl1 INTO outreturn;
outpgmsg := 'Nuevo registro creado, id = '||outreturn::text;
ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;

WHEN inidl1 > 0 THEN

IF namevalid THEN
UPDATE location_level1 SET name = inname, code = incode WHERE idl1 = inidl1 RETURNING idl1 INTO outreturn;
outpgmsg := 'Registro actualizado';
ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;


ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level1_edit_xml(inidl1 integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 17420)
-- Dependencies: 7 986
-- Name: fun_location_level2_edit_xml(integer, integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level2_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn INTEGER DEFAULT 0;
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';

BEGIN

-- Verificamos que el nombre no se repita en otro registro
IF length(inname) > 2 AND NOT EXISTS(SELECT * FROM location_level2 WHERE name = inname AND idl2 != idpk)  THEN

CASE

WHEN idpk = 0 THEN   

IF EXISTS(SELECT * FROM location_level1 WHERE idl1 = idfk) THEN
INSERT INTO location_level2 (idl1, name, code) VALUES (idfk, inname, incode) RETURNING idl2 INTO outreturn;
outpgmsg := 'Nuevo registro creado, id = '||outreturn::text;
ELSE
outreturn:= 0;
outpgmsg := 'No se insertado un nuevo registro porque la llave foranea idl2 = '||idfk::text||' no existe';
END IF;

WHEN idpk > 0 THEN

UPDATE location_level2 SET name = inname, code = incode WHERE idl2 = idpk RETURNING idl2 INTO outreturn;
outpgmsg := 'Registro actualizado';

ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level2_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 17421)
-- Dependencies: 986 7
-- Name: fun_location_level3_edit_xml(integer, integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level3_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn INTEGER DEFAULT 0;
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';

BEGIN

-- Verificamos que el nombre no se repita en otro registro
IF length(inname) > 2 AND NOT EXISTS(SELECT * FROM location_level3 WHERE name = inname AND idl3 != idpk)  THEN

CASE

WHEN idpk = 0 THEN   

IF EXISTS(SELECT * FROM location_level2 WHERE idl2 = idfk) THEN
INSERT INTO location_level3 (idl2, name, code) VALUES (idfk, inname, incode) RETURNING idl3 INTO outreturn;
outpgmsg := 'Nuevo registro creado, id = '||outreturn::text;
ELSE
outreturn:= 0;
outpgmsg := 'No se insertado un nuevo registro porque la llave foranea idl3 = '||idfk::text||' no existe';
END IF;

WHEN idpk > 0 THEN

UPDATE location_level3 SET name = inname, code = incode WHERE idl3 = idpk RETURNING idl3 INTO outreturn;
outpgmsg := 'Registro actualizado';

ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level3_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 17422)
-- Dependencies: 986 7
-- Name: fun_location_level4_edit_xml(integer, integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level4_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn INTEGER DEFAULT 0;
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';

BEGIN

-- Verificamos que el nombre no se repita en otro registro
IF length(inname) > 2 AND NOT EXISTS(SELECT * FROM location_level4 WHERE name = inname AND idl4 != idpk)  THEN

CASE

WHEN idpk = 0 THEN   

IF EXISTS(SELECT * FROM location_level3 WHERE idl3 = idfk) THEN
INSERT INTO location_level4 (idl3, name, code) VALUES (idfk, inname, incode) RETURNING idl4 INTO outreturn;
outpgmsg := 'Nuevo registro creado, id = '||outreturn::text;
ELSE
outreturn:= 0;
outpgmsg := 'No se insertado un nuevo registro porque la llave foranea idl3 = '||idfk::text||' no existe';
END IF;

WHEN idpk > 0 THEN

UPDATE location_level4 SET name = inname, code = incode WHERE idl4 = idpk RETURNING idl4 INTO outreturn;
outpgmsg := 'Registro actualizado';

ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level4_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 17423)
-- Dependencies: 7 986
-- Name: fun_location_level5_edit_xml(integer, integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level5_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn INTEGER DEFAULT 0;
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';

BEGIN

-- Verificamos que el nombre no se repita en otro registro
IF length(inname) > 2 AND NOT EXISTS(SELECT * FROM location_level5 WHERE name = inname AND idl5 != idpk)  THEN

CASE

WHEN idpk = 0 THEN   

IF EXISTS(SELECT * FROM location_level4 WHERE idl4 = idfk) THEN
INSERT INTO location_level5 (idl4, name, code) VALUES (idfk, inname, incode) RETURNING idl5 INTO outreturn;
outpgmsg := 'Nuevo registro creado, id = '||outreturn::text;
ELSE
outreturn:= 0;
outpgmsg := 'No se insertado un nuevo registro porque la llave foranea idl4 = '||idfk::text||' no existe';
END IF;

WHEN idpk > 0 THEN

UPDATE location_level5 SET name = inname, code = incode WHERE idl5 = idpk RETURNING idl5 INTO outreturn;
outpgmsg := 'Registro actualizado';

ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level5_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 17424)
-- Dependencies: 7 986
-- Name: fun_location_level6_edit_xml(integer, integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level6_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn INTEGER DEFAULT 0;
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';

BEGIN

-- Verificamos que el nombre no se repita en otro registro
IF length(inname) > 2 AND NOT EXISTS(SELECT * FROM location_level6 WHERE name = inname AND idl6 != idpk)  THEN

CASE

WHEN idpk = 0 THEN   

IF EXISTS(SELECT * FROM location_level5 WHERE idl5 = idfk) THEN
INSERT INTO location_level6 (idl5, name, code) VALUES (idfk, inname, incode) RETURNING idl6 INTO outreturn;
outpgmsg := 'Nuevo registro creado, id = '||outreturn::text;
ELSE
outreturn:= 0;
outpgmsg := 'No se insertado un nuevo registro porque la llave foranea idl5 = '||idfk::text||' no existe';
END IF;

WHEN idpk > 0 THEN

UPDATE location_level6 SET name = inname, code = incode WHERE idl6 = idpk RETURNING idl6 INTO outreturn;
outpgmsg := 'Registro actualizado';

ELSE
outreturn := 0;
outpgmsg := 'Ninguna accion realizada';
END CASE;

ELSE
outreturn:= 0;
outpgmsg := 'El nombre '||inname::text||' no es válido, el nombre no debe estar vacio o repetirse en otro registro.';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level6_edit_xml(idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 17425)
-- Dependencies: 7 986
-- Name: fun_location_level_edit_xml(integer, integer, integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level_edit_xml(l integer, idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';

BEGIN

CASE

	WHEN l = 1 THEN
Retorno:= fun_location_level1_edit_xml(idpk, inname, incode, ints, fieldtextasbase64);
	WHEN l = 2 THEN
Retorno:= fun_location_level2_edit_xml(idpk, idfk, inname, incode, ints, fieldtextasbase64);
	WHEN l = 3 THEN
Retorno:= fun_location_level3_edit_xml(idpk, idfk, inname, incode, ints, fieldtextasbase64);
	WHEN l = 4 THEN
Retorno:= fun_location_level4_edit_xml(idpk, idfk, inname, incode, ints, fieldtextasbase64);
	WHEN l = 5 THEN
Retorno:= fun_location_level5_edit_xml(idpk, idfk, inname, incode, ints, fieldtextasbase64);
	WHEN l = 6 THEN
Retorno:= fun_location_level6_edit_xml(idpk, idfk, inname, incode, ints, fieldtextasbase64);
	ELSE
Retorno := '<table></table>';
END CASE;

RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_location_level_edit_xml(l integer, idpk integer, idfk integer, inname text, incode text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 17426)
-- Dependencies: 7 986
-- Name: fun_location_level_remove_selected_xml(integer, integer[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_location_level_remove_selected_xml(l integer, ids integer[], fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE
outpgmsg TEXT DEFAULT 'Ninguna accion realizada';
outreturn INTEGER DEFAULT 0;

BEGIN

IF l > 0 AND l < 7 THEN

IF array_length(ids, 1) > 0 THEN

FOR i IN array_lower(ids,1) .. array_upper(ids,1) LOOP

CASE

	WHEN l = 1 THEN
DELETE FROM location_level1 WHERE idl1 = ids[i];
	WHEN l = 2 THEN
DELETE FROM location_level2 WHERE idl2 = ids[i];
	WHEN l = 3 THEN
DELETE FROM location_level3 WHERE idl3 = ids[i];
	WHEN l = 4 THEN
DELETE FROM location_level4 WHERE idl4 = ids[i];
	WHEN l = 5 THEN
DELETE FROM location_level5 WHERE idl5 = ids[i];
	WHEN l = 6 THEN
DELETE FROM location_level6 WHERE idl6 = ids[i];
ELSE
outpgmsg := 'Ninguna accion realizada';
outreturn:=0;
END CASE;


IF FOUND THEN
outreturn := outreturn+1;    
END IF;



END LOOP;
outpgmsg := 'Se han eliminado '||outreturn::text||' registros.';
ELSE
outreturn:= 0;
outpgmsg := 'La tabla location_level'||l::text||' no es válida.';
END IF;


END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_location_level_remove_selected_xml(l integer, ids integer[], fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 17427)
-- Dependencies: 986 7
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
-- TOC entry 2917 (class 0 OID 0)
-- Dependencies: 285
-- Name: FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_modem_insert(inimei text, inmanufacturer text, inmodel text, inrevision text, innote text) IS 'Inserta los datos de un modem';


--
-- TOC entry 406 (class 1255 OID 18845)
-- Dependencies: 7 986
-- Name: fun_notifications_insert(integer, integer, boolean, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_notifications_insert(inurgency integer, intimeout integer, incloseable boolean, inimg text, insnd text, intitle text, inbody text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

id integer;

BEGIN

IF intimeout < 5 THEN
intimeout := 5;
END IF;

INSERT INTO notification_area (urgency, timeout, closable, img, snd, title, body) VALUES (inurgency, intimeout, incloseable, inimg, insnd, intitle, inbody) RETURNING idnotify INTO id;
RETURN id;
END;$$;


ALTER FUNCTION public.fun_notifications_insert(inurgency integer, intimeout integer, incloseable boolean, inimg text, insnd text, intitle text, inbody text) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 17428)
-- Dependencies: 7 986
-- Name: fun_outgoing_log_insert(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_log_insert(inidsmsout integer, inidsim integer, instatus integer, inparts integer, inpart integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno integer default 0;

BEGIN

INSERT INTO outgoing_log (idsmsout, idsim, status, parts, part) VALUES (inidsmsout, inidsim, instatus, inparts, inpart) RETURNING idoutgoinglog INTO Retorno;

IF Retorno > 0 THEN
-- Actualizamos el estado del sms
-- Si al menos una parte del sms es enviado se da como enviado incompleto
-- Si no se ha enviado una sola parte volver a intentarlo


UPDATE outgoing SET status = instatus WHERE idsmsout = inidsmsout;
END IF;


RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_outgoing_log_insert(inidsmsout integer, inidsim integer, instatus integer, inparts integer, inpart integer) OWNER TO postgres;

--
-- TOC entry 2918 (class 0 OID 0)
-- Dependencies: 286
-- Name: FUNCTION fun_outgoing_log_insert(inidsmsout integer, inidsim integer, instatus integer, inparts integer, inpart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_outgoing_log_insert(inidsmsout integer, inidsim integer, instatus integer, inparts integer, inpart integer) IS 'Estados:
';


--
-- TOC entry 288 (class 1255 OID 17429)
-- Dependencies: 7 986
-- Name: fun_outgoing_new(integer, integer, integer, integer, text, text, timestamp without time zone, integer, boolean, boolean, integer, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_new(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, indatetosend timestamp without time zone, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno integer default 0;

BEGIN

-- Buscamos el idprovider, si no existe lo ponemos a null para no tener problema con la llave foranea
IF NOT EXISTS(SELECT * FROM provider WHERE idprovider = inidprovider) THEN
inidprovider := null;
END IF;

-- Buscamos si idsim existe caso contrario la seteamos a null
IF NOT EXISTS(SELECT * FROM sim WHERE idsim = inidsim) THEN
inidsim := null;
END IF;

-- Si existe el idphone omitimos el phone
IF EXISTS(SELECT * FROM phones WHERE idphone = inidphone) THEN
inphone := '';
ELSE

-- Si no existe el idphone buscamos el phone en el directorio de contactos para tratar de obtener el idphone
IF EXISTS(SELECT * FROM phones WHERE phone = inphone) THEN
SELECT idphone INTO inidphone FROM phones WHERE phone = inphone;
-- Encontramos el idphone, inphone lo ignoramos
inphone := '';
ELSE
inidphone := null;
END IF;

END IF;


IF (inidphone > 0) OR (length(inphone) > 0)  THEN
INSERT INTO outgoing (idowner, idprovider, idsim, idsmstype, idphone, phone, message, datetosend, priority, report, enablemessageclass, messageclass, status, note) VALUES (inidowner, inidprovider, inidsim, inidsmstype, inidphone, inphone, inmsg, indatetosend, inpriority, inreport, inenablemsgclass, inmsgclass, 0, innote) RETURNING idsmsout INTO Retorno;
ELSE
-- Datos del destinatario son incorrectos
Retorno := -1;
END IF;


RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_outgoing_new(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, indatetosend timestamp without time zone, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text) OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 17430)
-- Dependencies: 7 986
-- Name: fun_outgoing_new_now(integer, integer, integer, integer, text, text, integer, boolean, boolean, integer, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_new_now(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

RETURN fun_outgoing_new(inidprovider, inidsim, inidsmstype, inidphone, inphone, inmsg, 'now()', inpriority, inreport, inenablemsgclass, inmsgclass, inidowner, innote);
END;$$;


ALTER FUNCTION public.fun_outgoing_new_now(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text) OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 17431)
-- Dependencies: 7 986
-- Name: fun_outgoing_new_now_xml(integer, integer, integer, integer, text, text, integer, boolean, boolean, integer, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_new_now_xml(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';

BEGIN

Retorno := fun_outgoing_new_xml(inidprovider, inidsim, inidsmstype, inidphone, inphone, inmsg, 'now()', inpriority, inreport, inenablemsgclass, inmsgclass, inidowner, innote, fieldtextasbase64);

RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_outgoing_new_now_xml(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 17432)
-- Dependencies: 986 7
-- Name: fun_outgoing_new_xml(integer, integer, integer, integer, text, text, timestamp without time zone, integer, boolean, boolean, integer, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_new_xml(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, indatetosend timestamp without time zone, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
id INTEGER DEFAULT 0;
msg TEXT DEFAULT 'Ninguna accion realizada';

BEGIN

id = fun_outgoing_new(inidprovider, inidsim, inidsmstype, inidphone, inphone, inmsg, indatetosend, inpriority, inreport, inenablemsgclass, inmsgclass, inidowner, innote);

CASE
    WHEN id > 0 THEN
msg := 'Nuevo mensaje en la cola de envío';
    WHEN id = -1 THEN
msg := 'Los datos de destinatario son incorrectos';
    WHEN id < 0 THEN
msg := 'Se ha presentado algun problema y no pudo enviarse registrarse el mensaje';
ELSE
msg := 'Error desconocido: '||id::TEXT;
END CASE;


IF fieldtextasbase64 THEN
msg := encode(msg::bytea, 'base64');
END IF;

Retorno := '<return>'||id::TEXT||'</return><msg>'||msg::TEXT||'</msg>';


RETURN '<table><row>'||Retorno||'</row></table>';
END;$$;


ALTER FUNCTION public.fun_outgoing_new_xml(inidprovider integer, inidsim integer, inidsmstype integer, inidphone integer, inphone text, inmsg text, indatetosend timestamp without time zone, inpriority integer, inreport boolean, inenablemsgclass boolean, inmsgclass integer, inidowner integer, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 17433)
-- Dependencies: 7 986
-- Name: fun_outgoing_sms_update_to_expired(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_sms_update_to_expired(intimeout integer DEFAULT 5) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno INTEGER DEFAULT 0;

BEGIN

--SELECT idsmsout, datetosend FROM outgoing WHERE age(now(), datetosend) > interval '1 MINUTE' AND (status = 0 OR status IS NULL)  ORDER BY idsmsout DESC
UPDATE outgoing SET status = 6 WHERE age(now(), datetosend) > (interval '1 MINUTE'*intimeout) AND (status = 0 OR status IS NULL);

RETURN Retorno;
END;

$$;


ALTER FUNCTION public.fun_outgoing_sms_update_to_expired(intimeout integer) OWNER TO postgres;

--
-- TOC entry 2919 (class 0 OID 0)
-- Dependencies: 292
-- Name: FUNCTION fun_outgoing_sms_update_to_expired(intimeout integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_outgoing_sms_update_to_expired(intimeout integer) IS 'Marca como coducados a todos los mensajes de texto que no han sido enviados y han superado los 5 minutos desde la fecha programada de envio.
Devuelve el número de registros actualizados.';


--
-- TOC entry 293 (class 1255 OID 17434)
-- Dependencies: 986 7
-- Name: fun_outgoing_tosend(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_outgoing_tosend(inidsim integer, OUT _idsmsout integer, OUT _phone text, OUT _message text, OUT _report boolean, OUT _enablemessageclass boolean, OUT _messageclass integer, OUT _maxparts integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

RowViewOut view_outgoing_idphone%ROWTYPE;
tempPhone text default '';
idprovider_sim integer default null;
_smsout_enabled_other_providers boolean default false;

BEGIN

_idsmsout := 0;
_message := '';
_report := false;
_enablemessageclass := false;
_messageclass := 0;
_maxparts := 1;

PERFORM fun_outgoing_sms_update_to_expired();

IF EXISTS(SELECT * FROM sim WHERE idsim = inidsim) THEN

SELECT smsout_max_length, idprovider, smsout_enabled_other_providers INTO _maxparts, idprovider_sim, _smsout_enabled_other_providers FROM sim WHERE idsim = inidsim;

IF _smsout_enabled_other_providers THEN
SELECT * INTO RowViewOut FROM view_outgoing_idphone WHERE datetosend < now() AND status = 0 ORDER BY datetosend, priority LIMIT 1;
ELSE
SELECT * INTO RowViewOut FROM view_outgoing_idphone WHERE datetosend < now() AND status = 0 AND (idprovider = idprovider_sim OR idprovider IS NULL OR idprovider = 0) ORDER BY datetosend, priority LIMIT 1;
END IF;

_idsmsout := RowViewOut.idsmsout;
_phone := RowViewOut.phone;
_message := RowViewOut.message;
_report := RowViewOut.report;
_enablemessageclass := RowViewOut.enablemessageclass;
_messageclass := RowViewOut.messageclass;

UPDATE outgoing SET status = 4 WHERE idsmsout = _idsmsout;

END IF;

RETURN;
END;$$;


ALTER FUNCTION public.fun_outgoing_tosend(inidsim integer, OUT _idsmsout integer, OUT _phone text, OUT _message text, OUT _report boolean, OUT _enablemessageclass boolean, OUT _messageclass integer, OUT _maxparts integer) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 17435)
-- Dependencies: 986 7
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
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 294
-- Name: FUNCTION fun_phone_from_idphone(inidphone integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_phone_from_idphone(inidphone integer) IS 'Obtiene el numero telefonico desde la tabla phones segun el idphone';


--
-- TOC entry 268 (class 1255 OID 17436)
-- Dependencies: 986 7
-- Name: fun_phone_getdata_string(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_phone_getdata_string(inidphone integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
PhonesROWDATA   phones%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO PhonesROWDATA FROM phones WHERE idphone = inidphone;
  
--Retorno := fun_address_getdata_string(PhonesROWDATA.idaddress, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
--    raise notice 'row4 = %',Retorno;                                                
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(PhonesROWDATA.idphone::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(PhonesROWDATA.idcontact::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(PhonesROWDATA.enable::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(PhonesROWDATA.idprovider::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(PhonesROWDATA.phone::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(PhonesROWDATA.phone_ext::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(PhonesROWDATA.typephone::text,''));

	WHEN i_string[1] = '08' THEN
Retorno := replace(Retorno, prefix||'08', COALESCE(PhonesROWDATA.ubiphone::text,''));

	WHEN i_string[1] = '09' THEN
Retorno := replace(Retorno, prefix||'09', COALESCE(PhonesROWDATA.idaddress::text,''));

	WHEN i_string[1] = '10' THEN
Retorno := replace(Retorno, prefix||'10', COALESCE(PhonesROWDATA.note::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;




RETURN Retorno;
END;$$;


ALTER FUNCTION public.fun_phone_getdata_string(inidphone integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 17437)
-- Dependencies: 986 7
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
-- TOC entry 295 (class 1255 OID 17438)
-- Dependencies: 986 7
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
-- TOC entry 2921 (class 0 OID 0)
-- Dependencies: 295
-- Name: FUNCTION fun_phone_search_by_number(inphone text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_phone_search_by_number(inphone text) IS 'Busca el id segun el numero telefonico';


--
-- TOC entry 296 (class 1255 OID 17439)
-- Dependencies: 7 986
-- Name: fun_phones_address_edit_xml(integer, integer, double precision, double precision, text, text, text, text, text, text, text, text, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_phones_address_edit_xml(inidphone integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
xidaddress INTEGER DEFAULT 0;
outreturn integer default 0;
outpgmsg text default 'Ninguna acción realizada';
BEGIN

IF EXISTS(SELECT * FROM phones WHERE idphone = inidphone) THEN
SELECT phones.idaddress INTO xidaddress FROM phones WHERE idphone = inidphone;

SELECT fun_address_edit.outreturn, fun_address_edit.outpgmsg INTO outreturn, outpgmsg FROM fun_address_edit(xidaddress, inidlocation, ingeox, ingeoy, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, ints, false);
IF outreturn>0 THEN
UPDATE phones SET idaddress = outreturn WHERE idphone = inidphone;
ELSE
UPDATE phones SET idaddress = NULL WHERE idphone = inidphone;
END IF;

ELSE
outreturn := 0;
outpgmsg := 'El inidphone = '||inidphone::text||' no existe.';
END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_phones_address_edit_xml(inidphone integer, inidlocation integer, ingeox double precision, ingeoy double precision, f1 text, f2 text, f3 text, f4 text, f5 text, f6 text, f7 text, f8 text, f9 text, f10 text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 17440)
-- Dependencies: 7 986
-- Name: fun_phones_table(integer, integer, boolean, text, integer, integer, text, integer, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_phones_table(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, inphone_ext text, inidaddress integer, inubiphone integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

InternalIdPhone INTEGER DEFAULT 0;

BEGIN

IF inidphone >= 0 THEN

IF length(inphone) > 0 THEN

IF EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact)  THEN
--
InternalIdPhone := fun_phone_search_by_number(inphone);
IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
inidaddress := null;
END IF;

CASE

	WHEN inidphone = 0 THEN
	
	IF InternalIdPhone < 1 THEN
	-- idaddress se ingresa siempre a 0 al crear un telefono para evitar que se vaya a usar un idaddress que ya este siendo usado.
	INSERT INTO phones (idcontact, enable, phone, typephone, idprovider, note, idaddress, phone_ext, ubiphone) VALUES (inidcontact, inenable, inphone, intypephone, inidprovider, innote, inidaddress, inphone_ext, inubiphone) RETURNING idphone INTO outreturn;
	outpgmsg := 'Nuevo telefono ingresado';
	ELSE
	outpgmsg := 'El numero telefonico ingresado ya existe, debe ingresar uno diferente';
	outreturn := -1;
	END IF;

	WHEN inidphone > 0 AND EXISTS(SELECT * FROM phones WHERE idphone = inidphone) THEN
	
	IF InternalIdPhone < 1 OR InternalIdPhone = inidphone THEN
	UPDATE phones SET idcontact = inidcontact, enable = inenable, phone = inphone, typephone = intypephone, idprovider = inidprovider, note = innote, idaddress = inidaddress, phone_ext = inphone_ext, ubiphone = inubiphone WHERE idphone = inidphone RETURNING  idphone INTO outreturn;
	outpgmsg := 'Telefono actualizado';
	ELSE
	outpgmsg := 'El numero telefonico ingresado ya existe, debe ingresar uno diferente';
	outreturn := -2;
	END IF;

	END CASE;

ELSE
outreturn := -1;
outpgmsg := 'El contacto no existe';
END IF;

ELSE
outreturn := -1;
outpgmsg := 'El numero no puede estar vacio';
END IF;

ELSE

	-- Seteamos el idaddress = 0 para que se elimine el registro de la tabla address
	-- UPDATE phones SET idaddress = 0 WHERE idphone = abs(inidphone);
	DELETE FROM phones WHERE idphone = abs(inidphone);
	outpgmsg := 'Telefono eliminado';
	outreturn := 0;

END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION public.fun_phones_table(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, inphone_ext text, inidaddress integer, inubiphone integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 17441)
-- Dependencies: 986 7
-- Name: fun_phones_table_xml(integer, integer, boolean, text, integer, integer, text, integer, integer, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_phones_table_xml(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, inphone_ext text, inidaddress integer, inubiphone integer, innote text, ts timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN

OPEN CursorResultado FOR SELECT * FROM fun_phones_table(inidphone, inidcontact, inenable, inphone, intypephone, inidprovider, inphone_ext, inidaddress, inubiphone, innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_phones_table_xml(inidphone integer, inidcontact integer, inenable boolean, inphone text, intypephone integer, inidprovider integer, inphone_ext text, inidaddress integer, inubiphone integer, innote text, ts timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 17442)
-- Dependencies: 7 986
-- Name: fun_portmodem_update(integer, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
--internalidprovider integer DEFAULT 0;
--Retorno integer DEFAULT 0;

BEGIN

--IF NOT EXISTS(SELECT * FROM cimi WHERE cimi = incimi) THEN
--INSERT INTO cimi (cimi) VALUES (incimi);
--END IF;

-- Inserta los datos del modem si no existe
--PERFORM fun_modem_insert(inimei, inmanufacturer, inmodel, inrevision, '');
-- Mantiene actualizada la tabla currentportsproviders 
--PERFORM fun_currentportsproviders_insertupdate(inidport, inport, incimi, inimei); 
RETURN TRUE;
END;$$;


ALTER FUNCTION public.fun_portmodem_update(inidport integer, inport text, incimi text, inimei text, inmanufacturer text, inmodel text, inrevision text) OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 17443)
-- Dependencies: 7 986
-- Name: fun_provider_delete_selection_xml(integer[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_provider_delete_selection_xml(delete_idproviders integer[], fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';

BEGIN

IF array_length(delete_idproviders, 1) > 0 THEN
DELETE FROM provider WHERE idprovider = ALL(delete_idproviders);
Retorno := 'Registros eliminados';
ELSE
Retorno := 'No ha seleccionado registros para eliminar';
END IF;


IF fieldtextasbase64 THEN
Retorno := encode(Retorno::bytea, 'base64');
END IF;
RETURN '<table><row><outreturn>0</outreturn><outpgmsg>'||Retorno||'</outpgmsg></row></table>';
END;$$;


ALTER FUNCTION public.fun_provider_delete_selection_xml(delete_idproviders integer[], fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 17444)
-- Dependencies: 986 7
-- Name: fun_provider_edit(integer, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_provider_edit(inidprovider integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

ValidData BOOLEAN DEFAULT false;

BEGIN

-- Validamos que los campos no esten vacios
IF inidprovider >= 0 AND length(inname) > 0 AND NOT EXISTS(SELECT * FROM provider WHERE name = inname AND idprovider != inidprovider) THEN
ValidData := TRUE;

ELSE
outpgmsg := 'El campo Name no puede estar vacio o repetirse con uno ya existente';
outreturn := -1;
END IF;

CASE

	WHEN inidprovider = 0  THEN
-- Ingresamos un nuevo registro
IF ValidData THEN
INSERT INTO provider (enable, name, note) VALUES (inenable, inname, innote) RETURNING idprovider INTO outreturn;
outpgmsg := 'Nuevo proveedor registrado';
END IF;

	WHEN inidprovider > 0  THEN
-- Actualizamos
IF ValidData THEN
UPDATE provider SET enable = inenable, name = inname, note = innote WHERE idprovider = inidprovider RETURNING idprovider INTO outreturn;
outpgmsg := 'Proveedor actualizado';
END IF;

	WHEN inidprovider < 0  THEN
-- Eliminamos
DELETE FROM provider WHERE idprovider = abs(inidprovider);
outpgmsg := 'Proveedor eliminado';
END CASE;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;
RETURN;
END;$$;


ALTER FUNCTION public.fun_provider_edit(inidprovider integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 17445)
-- Dependencies: 986 7
-- Name: fun_provider_edit_xml(integer, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_provider_edit_xml(inidprovider integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN

OPEN CursorResultado FOR SELECT * FROM fun_provider_edit(inidprovider, inenable , inname , innote,  ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_provider_edit_xml(inidprovider integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 17446)
-- Dependencies: 986 7
-- Name: fun_providers_idname_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF EXISTS(SELECT * FROM provider WHERE idprovider = 0) THEN
UPDATE provider SET name = 'Undefined' WHERE idprovider = 0;
ELSE
INSERT INTO provider (idprovider, name, enable) VALUES (0, 'Undefined', true);
END IF;

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
-- TOC entry 2922 (class 0 OID 0)
-- Dependencies: 304
-- Name: FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_providers_idname_xml(fieldtextasbase64 boolean) IS 'Devuelve la lista de proveedores unicamente los campos id y name';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 17759)
-- Dependencies: 2350 2351 2352 2353 2354 2355 2356 2357 2358 2359 1917 7
-- Name: sim; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sim (
    idsim bigint NOT NULL,
    idprovider integer,
    enable boolean DEFAULT true NOT NULL,
    phone text NOT NULL,
    smsout_request_reports boolean DEFAULT false NOT NULL,
    smsout_retryonfail integer DEFAULT 3 NOT NULL,
    smsout_max_length integer DEFAULT 1 NOT NULL,
    smsout_enabled_other_providers boolean DEFAULT false NOT NULL,
    on_incommingcall integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone,
    note text COLLATE pg_catalog."C.UTF-8",
    enable_sendsms boolean DEFAULT true NOT NULL,
    dtmf_tone integer DEFAULT 0 NOT NULL,
    dtmf_tone_time integer DEFAULT 3 NOT NULL,
    enable_readsms boolean DEFAULT true NOT NULL
);


ALTER TABLE public.sim OWNER TO postgres;

--
-- TOC entry 2923 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE sim; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sim IS 'Lista de tarjetas SIM GSM, para poder identificar cada tarjeta SIM en el sistema debe tener registrado un contacto con nombre usms, en el numero telefonico debe constar en numero telefonico de esa SIM. 
En los campos de esta tabla tenemos datos que ingresar, el proveedor al que pertenece esa SIM es importante el sistema.';


--
-- TOC entry 2924 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.enable; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.enable IS 'Habilitado el uso de esta SIM';


--
-- TOC entry 2925 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.phone IS 'Numero telefonico de esta sim, este campo no es editable, usms lo obtiene de contacto almacenado en la SIM';


--
-- TOC entry 2926 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.smsout_request_reports; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.smsout_request_reports IS 'Solicitar siempre reporte de entrega de sms enviados';


--
-- TOC entry 2927 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.smsout_retryonfail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.smsout_retryonfail IS 'Numero maximo de intentos al enviar un sms';


--
-- TOC entry 2928 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.smsout_max_length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.smsout_max_length IS 'Longitud maxima de mensajes en que un texto largo puede dividirse.  Si el texto exede esta cantidad el resto del mensaje será ignorado.';


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.smsout_enabled_other_providers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.smsout_enabled_other_providers IS 'Habilita el uso de esta SIM para enviar mensajes a otras operadoras.';


--
-- TOC entry 2930 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN sim.on_incommingcall; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sim.on_incommingcall IS 'Accion a tomar en caso de recibir una llamada entrante.
0 = Ignorar
1 = Responder
2 = Rechazar
 ';


--
-- TOC entry 408 (class 1255 OID 18956)
-- Dependencies: 832 7 986
-- Name: fun_sim_getrow(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_sim_getrow(inphone text) RETURNS sim
    LANGUAGE plpgsql
    AS $$DECLARE

   Retorno sim%ROWTYPE;
   id INTEGER DEFAULT 0;

BEGIN

IF EXISTS(SELECT idsim FROM sim WHERE phone = inphone) THEN
SELECT * INTO Retorno FROM sim WHERE phone = inphone;
ELSE
INSERT INTO sim (phone) VALUES (inphone) RETURNING idsim INTO id; 
IF id > 0 THEN
SELECT * INTO Retorno FROM sim WHERE idsim = id;
END IF;
END IF;

return Retorno;
END;$$;


ALTER FUNCTION public.fun_sim_getrow(inphone text) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 17447)
-- Dependencies: 986 7
-- Name: fun_sim_table_edit(integer, integer, boolean, boolean, text, boolean, integer, integer, boolean, integer, integer, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_sim_table_edit(inidsim integer, inidprovider integer, inenable boolean, inenable_sendsms boolean, inphone text, insmsout_request_reports boolean, insmsout_retryonfail integer, insmsout_max_length integer, insmsout_enabled_other_providers boolean, inon_incommingcall integer, indtmf_tone integer, indtmf_tone_time integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outreturn := 0;
outpgmsg := 'Ninguna acción realizada';

IF NOT EXISTS(SELECT * FROM provider WHERE idprovider = inidprovider) THEN
inidprovider := null;
END IF;

CASE

	WHEN inidsim = 0 THEN
-- Normalmente deberia crear un nuevo registro pero no está habilitado ya que este registro debe crearse automaticamente leyendo el contacto usms de la tarjeta SIM
outreturn := 0;
outpgmsg := 'Este registro solo puede ser creado automáticamente por uSMS.';

	WHEN inidsim > 0 AND EXISTS(SELECT * FROM sim WHERE idsim = inidsim) THEN
-- Actualiza
UPDATE sim SET idprovider = inidprovider, enable = inenable, enable_sendsms = inenable_sendsms, phone = inphone, smsout_request_reports = insmsout_request_reports, smsout_retryonfail = insmsout_retryonfail, smsout_max_length = insmsout_max_length, smsout_enabled_other_providers = insmsout_enabled_other_providers, on_incommingcall = inon_incommingcall, dtmf_tone_time = indtmf_tone_time, dtmf_tone = indtmf_tone, note = innote WHERE idsim = inidsim RETURNING idsim INTO outreturn;
outpgmsg := 'Registro Actualizado';

	WHEN inidsim < 0 AND EXISTS(SELECT * FROM sim WHERE idsim = abs(inidsim)) THEN
DELETE FROM sim WHERE idsim = abs(inidsim);
outreturn := inidsim;
outpgmsg := 'Registro eliminado';

ELSE
outreturn := 0;
outpgmsg := 'Ninguna acción realizada';
END CASE;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION public.fun_sim_table_edit(inidsim integer, inidprovider integer, inenable boolean, inenable_sendsms boolean, inphone text, insmsout_request_reports boolean, insmsout_retryonfail integer, insmsout_max_length integer, insmsout_enabled_other_providers boolean, inon_incommingcall integer, indtmf_tone integer, indtmf_tone_time integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 17448)
-- Dependencies: 7 986
-- Name: fun_sim_table_edit_xml(integer, integer, boolean, boolean, text, boolean, integer, integer, boolean, integer, integer, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_sim_table_edit_xml(inidsim integer, inidprovider integer, inenable boolean, inenable_sendsms boolean, inphone text, insmsout_request_reports boolean, insmsout_retryonfail integer, insmsout_max_length integer, insmsout_enabled_other_providers boolean, inon_incommingcall integer, indtmf_tone integer, indtmf_tone_time integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN

OPEN CursorResultado FOR SELECT * FROM fun_sim_table_edit(inidsim, inidprovider, inenable, inenable_sendsms, inphone, insmsout_request_reports, insmsout_retryonfail, insmsout_max_length, insmsout_enabled_other_providers, inon_incommingcall, indtmf_tone, indtmf_tone_time,  innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_sim_table_edit_xml(inidsim integer, inidprovider integer, inenable boolean, inenable_sendsms boolean, inphone text, insmsout_request_reports boolean, insmsout_retryonfail integer, insmsout_max_length integer, insmsout_enabled_other_providers boolean, inon_incommingcall integer, indtmf_tone integer, indtmf_tone_time integer, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 410 (class 1255 OID 17449)
-- Dependencies: 7 986
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

IF NOT EXISTS(SELECT * FROM smsin WHERE datesms = indatesms AND phone = inphone AND message = inmsj)  THEN

INSERT INTO smsin (idport, idprovider, idphone, datesms, status, phone, message) VALUES (inidport, inidprovider, inidphone, indatesms, instatus, inphone, inmsj) RETURNING idsmsin INTO Retorno;

IF Retorno > 0 THEN
PERFORM fun_notifications_insert(10, 45, TRUE, '', '', 'Nuevo SMS del numero '||inphone, inmsj);
END IF;

--EXCEPTION WHEN unique_violation THEN
            -- do nothing, and loop to try the UPDATE again

END IF;

RETURN Retorno;

END;$$;


ALTER FUNCTION public.fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text) OWNER TO postgres;

--
-- TOC entry 2931 (class 0 OID 0)
-- Dependencies: 410
-- Name: FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_smsin_insert(inidport integer, instatus integer, indatesms timestamp without time zone, inphone text, inmsj text, innote text) IS 'Funcion para almacenar sms entrantes en la tabla smsin';


--
-- TOC entry 307 (class 1255 OID 17450)
-- Dependencies: 986 7
-- Name: fun_view_address_byid_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_address_byid_xml(inidaddress integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idaddress, idlocation, geox, geoy, encode(field1::bytea, 'base64') AS field1, 
encode(field2::bytea, 'base64') AS field2, 
encode(field3::bytea, 'base64') AS field3, 
encode(field4::bytea, 'base64') AS field4, 
encode(field5::bytea, 'base64') AS field5, 
encode(field6::bytea, 'base64') AS field6, 
encode(field7::bytea, 'base64') AS field7, 
encode(field8::bytea, 'base64') AS field8, 
encode(field9::bytea, 'base64') AS field9, 
encode(field10::bytea, 'base64') AS field10,
ts 
 FROM address WHERE idaddress = inidaddress;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM address WHERE idaddress = inidaddress;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_view_address_byid_xml(inidaddress integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 17451)
-- Dependencies: 986 7
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
-- TOC entry 2932 (class 0 OID 0)
-- Dependencies: 308
-- Name: FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_contacts_byidcontact_xml(inidcontact integer, fieldtextasbase64 boolean) IS 'Devuelve un contacto segun el parametro idcontact en formato xml.';


--
-- TOC entry 411 (class 1255 OID 35391)
-- Dependencies: 986 7
-- Name: fun_view_contacts_groups_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_contacts_groups_xml(inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idgroup, enable, encode(name::bytea, 'base64') AS name, encode(note::bytea, 'base64') AS note, idcontact, belong FROM view_contacts_groups WHERE idcontact = inidcontact ORDER BY view_contacts_groups.name ASC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM view_contacts_groups WHERE idcontact = inidcontact ORDER BY name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_contacts_groups_xml(inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 17452)
-- Dependencies: 986 7
-- Name: fun_view_contacts_phones_with_search_xml(text, integer[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_contacts_phones_with_search_xml(name_phone text, exclude_idphone integer[], fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT encode((lastname ||' '||firstname)::bytea, 'base64') AS name, idphone, encode(phone::bytea, 'base64') AS phone FROM view_contacts_phones WHERE (idphone > 0 AND idphone != ALL(exclude_idphone)) AND (lastname ILIKE '%'||name_phone::text||'%' OR firstname ILIKE '%'||name_phone::text||'%' OR phone ILIKE '%'||name_phone::text||'%') ORDER BY lastname, firstname, view_contacts_phones.phone;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT (lastname||' '||firstname) AS name, idphone, phone FROM view_contacts_phones WHERE (idphone > 0 AND idphone != ALL(exclude_idphone)) AND (lastname ILIKE '%'||name_phone::text||'%' OR firstname ILIKE '%'||name_phone::text||'%' OR phone ILIKE '%'||name_phone::text||'%') ORDER BY name, phone;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;


RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_view_contacts_phones_with_search_xml(name_phone text, exclude_idphone integer[], fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2933 (class 0 OID 0)
-- Dependencies: 310
-- Name: FUNCTION fun_view_contacts_phones_with_search_xml(name_phone text, exclude_idphone integer[], fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_contacts_phones_with_search_xml(name_phone text, exclude_idphone integer[], fieldtextasbase64 boolean) IS 'Muestra una lista de contactos con sus telefonos según un criterio de busqueda por nombre o telefonos y exceptuando los idphone pasados como array.';


--
-- TOC entry 395 (class 1255 OID 17453)
-- Dependencies: 986 7
-- Name: fun_view_contacts_to_list_search_xml(text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_contacts_to_list_search_xml(insearch text DEFAULT ''::text, fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, enable, identification, encode((lastname ||' '||firstname)::bytea, 'base64') AS name FROM contacts WHERE contacts.lastname ILIKE '%'||insearch::text||'%' OR contacts.firstname ILIKE '%'||insearch::text||'%' OR contacts.identification ILIKE '%'||insearch::text||'%' ORDER BY contacts.lastname, contacts.firstname;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idcontact, enable, identification, (lastname ||' '||firstname) AS name FROM contacts WHERE contacts.lastname ILIKE '%'||insearch::text||'%' OR contacts.firstname ILIKE '%'||insearch::text||'%' OR contacts.firstname ILIKE '%'||insearch::text||'%' ORDER BY contacts.lastname, contacts.firstname;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_contacts_to_list_search_xml(insearch text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 390 (class 1255 OID 17454)
-- Dependencies: 986 7
-- Name: fun_view_contacts_to_list_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, enable, encode((lastname ||' '||firstname)::bytea, 'base64') AS name FROM contacts ORDER BY lastname, firstname;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idcontact, enable, (lastname ||' '||firstname) AS name FROM contacts  ORDER BY lastname, firstname;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_contacts_to_list_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2934 (class 0 OID 0)
-- Dependencies: 390
-- Name: FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_contacts_to_list_xml(fieldtextasbase64 boolean) IS 'Lista de contactos con datos basicos, para ser usado en un combobox o lista simplificada.';


--
-- TOC entry 385 (class 1255 OID 18505)
-- Dependencies: 7 986
-- Name: fun_view_groups_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_groups_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idgroup, enable, encode(name::bytea, 'base64') AS name, encode(note::bytea, 'base64') AS note, ts FROM groups ORDER BY groups.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM groups ORDER BY groups.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_groups_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 384 (class 1255 OID 18506)
-- Dependencies: 986 7
-- Name: fun_view_idgroup_name_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_idgroup_name_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idgroup, encode(name::bytea, 'base64') AS name FROM groups ORDER BY idgroup;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idgroup, name FROM groups ORDER BY idgroup;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_idgroup_name_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 17455)
-- Dependencies: 7 986
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
-- TOC entry 2935 (class 0 OID 0)
-- Dependencies: 311
-- Name: FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_incomingcalls_xml(datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) IS 'Obtiene la tabla entre las fechas seleccionadas en formato xml';


--
-- TOC entry 312 (class 1255 OID 17456)
-- Dependencies: 986 7
-- Name: fun_view_location_level_xml(integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_location_level_xml(l integer, idfk integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;
query TEXT DEFAULT '';

BEGIN

CASE  
	WHEN l = 1 THEN
IF fieldtextasbase64 THEN
query := 'SELECT idl1, encode(name::bytea, ''base64'') as name, encode(code::bytea, ''base64'') as code, ts FROM location_level1';
ELSE
query:= 'SELECT * FROM location_level1;';
END IF;

	WHEN l = 2 THEN
IF fieldtextasbase64 THEN
query := 'SELECT idl2, idl1, encode(name::bytea, ''base64'') as name, encode(code::bytea, ''base64'') as code, ts FROM location_level2 WHERE idl1 = '||idfk::text;
ELSE
query:= 'SELECT * FROM location_level2 WHERE idl1 = '||idfk::text;
END IF;

	WHEN l = 3 THEN
IF fieldtextasbase64 THEN
query := 'SELECT idl3, idl2, encode(name::bytea, ''base64'') as name, encode(code::bytea, ''base64'') as code, ts FROM location_level3 WHERE idl2 = '||idfk::text;
ELSE
query:= 'SELECT * FROM location_level3 WHERE idl2 = '||idfk::text;
END IF;


	WHEN l = 4 THEN
IF fieldtextasbase64 THEN
query := 'SELECT idl4, idl3, encode(name::bytea, ''base64'') as name, encode(code::bytea, ''base64'') as code, ts FROM location_level4 WHERE idl3 = '||idfk::text;
ELSE
query:= 'SELECT * FROM location_level4 WHERE idl3 = '||idfk::text;
END IF;

	WHEN l = 5 THEN
IF fieldtextasbase64 THEN
query := 'SELECT idl5, idl4, encode(name::bytea, ''base64'') as name, encode(code::bytea, ''base64'') as code, ts FROM location_level5 WHERE idl4 = '||idfk::text;
ELSE
query:= 'SELECT * FROM location_level5 WHERE idl4 = '||idfk::text;
END IF;

	WHEN l = 6 THEN
IF fieldtextasbase64 THEN
query := 'SELECT idl6, idl5, encode(name::bytea, ''base64'') as name, encode(code::bytea, ''base64'') as code, ts FROM location_level6 WHERE idl5 = '||idfk::text;
ELSE
query:= 'SELECT * FROM location_level6 WHERE idl5 = '||idfk::text;
END IF;


ELSE
Retorno :='';
END CASE;

IF length(query) > 0 THEN
OPEN CursorResult FOR EXECUTE query;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_location_level_xml(l integer, idfk integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 17457)
-- Dependencies: 986 7
-- Name: fun_view_locations_ids_from_idlocation_xml(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_locations_ids_from_idlocation_xml(inidlocation numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

OPEN CursorResult FOR SELECT * FROM view_location_idlocation WHERE idlocation = inidlocation;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_locations_ids_from_idlocation_xml(inidlocation numeric) OWNER TO postgres;

--
-- TOC entry 399 (class 1255 OID 18842)
-- Dependencies: 986 7
-- Name: fun_view_notification_area_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_notification_area_xml(lastidnotify integer DEFAULT 0, fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idnotify, urgency, timeout, closable, encode(img::bytea, 'base64') AS img, encode(snd::bytea, 'base64') AS snd, encode(title::bytea, 'base64') AS title, encode(body::bytea, 'base64') AS body FROM notification_area WHERE idnotify > lastidnotify AND extract(epoch from (now() - datetime)) < 10;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM notification_area WHERE idnotify > lastidnotify  AND extract(epoch from (now() - datetime)) < 10;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_notification_area_xml(lastidnotify integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 17458)
-- Dependencies: 7 986
-- Name: fun_view_outgoing_view_filter_xml(timestamp without time zone, timestamp without time zone, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_outgoing_view_filter_xml(datestart timestamp without time zone, dateend timestamp without time zone, maxrows integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idsmsout, idowner, dateload, idsim, idsmstype, idcontact, idphone, enable, typephone, encode(phone::bytea, 'base64') AS phone, idprovider, encode(message::bytea, 'base64') AS message, datetosend, priority, report, enablemessageclass, messageclass, status, encode(note::bytea, 'base64') AS note, ts FROM view_outgoing_idphone WHERE datetosend BETWEEN datestart AND dateend ORDER BY datetosend DESC LIMIT maxrows;
SELECT * FROM cursor_to_xml(CursorResult, maxrows+1, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM view_outgoing_idphone WHERE datetosend BETWEEN datestart AND dateend ORDER BY datetosend DESC LIMIT maxrows;
SELECT * FROM cursor_to_xml(CursorResult, maxrows+1, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_outgoing_view_filter_xml(datestart timestamp without time zone, dateend timestamp without time zone, maxrows integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 17459)
-- Dependencies: 986 7
-- Name: fun_view_phones_byid_xml(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_phones_byid_xml(inidphone integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idphone, idcontact, enable, encode(phone::bytea, 'base64') as phone, typephone, idprovider, encode(note::bytea, 'base64') as note, idaddress, encode(phone_ext::bytea, 'base64') as phone_ext, ubiphone, ts FROM phones WHERE idphone = inidphone;
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
-- TOC entry 315 (class 1255 OID 17460)
-- Dependencies: 986 7
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

--
-- TOC entry 316 (class 1255 OID 17461)
-- Dependencies: 7 986
-- Name: fun_view_provider_table_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_provider_table_xml(fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idprovider, enable,  encode(name::bytea, 'base64') AS name, encode(note::bytea, 'base64') AS note, ts FROM provider ORDER BY provider.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM provider ORDER BY provider.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION public.fun_view_provider_table_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2936 (class 0 OID 0)
-- Dependencies: 316
-- Name: FUNCTION fun_view_provider_table_xml(fieldtextasbase64 boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fun_view_provider_table_xml(fieldtextasbase64 boolean) IS 'Devuelve la tabla en formato xml';


--
-- TOC entry 317 (class 1255 OID 17462)
-- Dependencies: 986 7
-- Name: fun_view_sim_idname_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_sim_idname_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;
None_ TEXT DEFAULT 'Ninguno';

BEGIN

IF fieldtextasbase64 THEN
None_ := encode(None_::bytea, 'base64');
OPEN CursorResult FOR SELECT idsim, enable, encode(phone::bytea, 'base64') AS phone  FROM sim;

SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idsim, enable, phone FROM sim;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||'<row><idsim>0</idsim><enable>true</enable><phone>'||None_::text||'</phone></row>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_sim_idname_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 17463)
-- Dependencies: 7 986
-- Name: fun_view_sim_xml(boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_view_sim_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idsim, idprovider, enable, encode(phone::bytea, 'base64') AS phone, smsout_request_reports, smsout_retryonfail, smsout_max_length, smsout_enabled_other_providers,  on_incommingcall, ts, encode(note::bytea, 'base64') as note, enable_sendsms, dtmf_tone, dtmf_tone_time  FROM sim ORDER BY sim.phone;

SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM sim ORDER BY sim.phone;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION public.fun_view_sim_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 17464)
-- Dependencies: 7 986
-- Name: fun_view_smsin_table_filter_xml(timestamp without time zone, timestamp without time zone, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_view_smsin_table_filter_xml(datestart timestamp without time zone, dateend timestamp without time zone, maxrows integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 320 (class 1255 OID 17465)
-- Dependencies: 7 986
-- Name: generate_create_table_statement(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION generate_create_table_statement(p_table_name character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_table_ddl   text;
    column_record record;
BEGIN
    FOR column_record IN 
        SELECT 
            b.nspname as schema_name,
            b.relname as table_name,
            a.attname as column_name,
            pg_catalog.format_type(a.atttypid, a.atttypmod) as column_type,
            CASE WHEN 
                (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
                 FROM pg_catalog.pg_attrdef d
                 WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) IS NOT NULL THEN
                'DEFAULT '|| (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
                              FROM pg_catalog.pg_attrdef d
                              WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef)
            ELSE
                ''
            END as column_default_value,
            CASE WHEN a.attnotnull = true THEN 
                'NOT NULL'
            ELSE
                'NULL'
            END as column_not_null,
            a.attnum as attnum,
            e.max_attnum as max_attnum
        FROM 
            pg_catalog.pg_attribute a
            INNER JOIN 
             (SELECT c.oid,
                n.nspname,
                c.relname
              FROM pg_catalog.pg_class c
                   LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
              WHERE c.relname ~ ('^('||p_table_name||')$')
                AND pg_catalog.pg_table_is_visible(c.oid)
              ORDER BY 2, 3) b
            ON a.attrelid = b.oid
            INNER JOIN 
             (SELECT 
                  a.attrelid,
                  max(a.attnum) as max_attnum
              FROM pg_catalog.pg_attribute a
              WHERE a.attnum > 0 
                AND NOT a.attisdropped
              GROUP BY a.attrelid) e
            ON a.attrelid=e.attrelid
        WHERE a.attnum > 0 
          AND NOT a.attisdropped
        ORDER BY a.attnum
    LOOP
        IF column_record.attnum = 1 THEN
            v_table_ddl:='CREATE TABLE '||column_record.schema_name||'.'||column_record.table_name||' ('||chr(10)||
                         '    '||column_record.column_name||' '||column_record.column_type||' '||column_record.column_default_value||' '||column_record.column_not_null;
        END IF;

        IF column_record.attnum < column_record.max_attnum THEN
            v_table_ddl:=v_table_ddl||','||chr(10)||
                         '    '||column_record.column_name||' '||column_record.column_type||' '||column_record.column_default_value||' '||column_record.column_not_null;
        ELSE
            v_table_ddl:=v_table_ddl||');';
        END IF;
    END LOOP;

    RETURN v_table_ddl;
END;
$_$;


ALTER FUNCTION public.generate_create_table_statement(p_table_name character varying) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 17466)
-- Dependencies: 986 7
-- Name: incomingcalls_triggered_after_changing(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION incomingcalls_triggered_after_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN
-- Esto no funcionara si no definimos que se dispare DESPUES de haber hecho los cambios

CASE  

WHEN TG_OP = 'INSERT' THEN 
PERFORM usaga.fun_receiver_from_incomingcall(NEW.idincall);
WHEN TG_OP = 'UPDATE' THEN 
PERFORM usaga.fun_receiver_from_incomingcall(NEW.idincall);
ELSE
--Retorno := OLD;
END CASE;

RETURN NULL; 
END;$$;


ALTER FUNCTION public.incomingcalls_triggered_after_changing() OWNER TO postgres;

--
-- TOC entry 2937 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION incomingcalls_triggered_after_changing(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION incomingcalls_triggered_after_changing() IS 'Esta funcion debe dispararse DESPUES de haberse ejecutado una accion.';


--
-- TOC entry 402 (class 1255 OID 27202)
-- Dependencies: 986 7
-- Name: tob64(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION tob64(intext text) RETURNS text
    LANGUAGE plpgsql
    AS $$BEGIN
RETURN encode(replace(intext, '\', '\\')::bytea, 'base64');
END;$$;


ALTER FUNCTION public.tob64(intext text) OWNER TO postgres;

--
-- TOC entry 2938 (class 0 OID 0)
-- Dependencies: 402
-- Name: FUNCTION tob64(intext text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION tob64(intext text) IS 'Convierte una cadena en Base64, hace escape de caracteres especiales que han presentado problemas especialmente en texto con etiquetas HTML.';


--
-- TOC entry 424 (class 1255 OID 35843)
-- Dependencies: 7 986
-- Name: xxfun_contacts_check_data(integer, text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
isvalid := true;

IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
inidaddress := null;
END IF;


CASE
	WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = inidentification AND typeofid = intypeofid AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
 -- El numero de identification ya existe en otro contacto
isvalid := false;
outpgmsg := 'El número de identificación '||inidentification::text||' tipo '||intypeofid::text||' ya existe en otro contacto, verifique los datos';

	WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
isvalid := false;
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';

	WHEN (length(infirstname) < 1 OR length(inlastname) < 1) AND inidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
isvalid := false;
outpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

WHEN length(inemail1) AND inemail1 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := false;
outpgmsg := inemail1||' no tiene un formato válido';

WHEN length(inemail2) AND inemail2 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := false;
outpgmsg := inemail2||' no tiene un formato válido';

--	WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
-- Actualiza si el contacto existe
--UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';
--isvalid := false;

	--WHEN inidcontact = 0 THEN
-- Insertamos un nuevo registro
--INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote) RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||outreturn::text||' creado.';


--	WHEN inidcontact < 0 THEN
-- Eliminamos el registro de direccion
--DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(inidcontact));
-- Eliminamos el contacto
--DELETE FROM contacts WHERE idcontact = abs(inidcontact);
--outreturn := 0;
--outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

ELSE
--outreturn := abs(inidcontact);
--outpgmsg := 'Ninguna accion realizada';
isvalid := true;
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$_$;


ALTER FUNCTION public.xxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 429 (class 1255 OID 35846)
-- Dependencies: 7 986
-- Name: xxxxfun_contacts_check_data(integer, text, text, text, integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xxxxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT intypeofid integer, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid boolean, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
isvalid := true;

IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
inidaddress := null;
END IF;


CASE
	WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = inidentification AND typeofid = intypeofid AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
 -- El numero de identification ya existe en otro contacto
isvalid := false;
outpgmsg := 'El número de identificación '||inidentification::text||' tipo '||intypeofid::text||' ya existe en otro contacto, verifique los datos';

	WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
isvalid := false;
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';

	WHEN (length(infirstname) < 1 OR length(inlastname) < 1) AND inidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
isvalid := false;
outpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

WHEN length(inemail1) > 0 AND inemail1 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := false;
outpgmsg := 'La direccion de email: '||inemail1||' no tiene un formato válido';

WHEN length(inemail2) > 0  AND inemail2 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := false;
outpgmsg := 'La direccion de email: '||inemail2||' no tiene un formato válido';

--	WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
-- Actualiza si el contacto existe
--UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';
--isvalid := false;

	--WHEN inidcontact = 0 THEN
-- Insertamos un nuevo registro
--INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote) RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||outreturn::text||' creado.';


--	WHEN inidcontact < 0 THEN
-- Eliminamos el registro de direccion
--DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(inidcontact));
-- Eliminamos el contacto
--DELETE FROM contacts WHERE idcontact = abs(inidcontact);
--outreturn := 0;
--outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

ELSE
--outreturn := abs(inidcontact);
--outpgmsg := 'Ninguna accion realizada';
isvalid := true;
END CASE;

--IF fieldtextasbase64 THEN
--outpgmsg := encode(outpgmsg::bytea, 'base64');
--END IF;

RETURN;
END;$_$;


ALTER FUNCTION public.xxxxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT intypeofid integer, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid boolean, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 427 (class 1255 OID 35845)
-- Dependencies: 7 986
-- Name: xxxxxfun_contacts_check_data(integer, text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xxxxxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid boolean, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
isvalid := true;

IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
inidaddress := null;
END IF;


CASE
	WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = inidentification AND typeofid = intypeofid AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
 -- El numero de identification ya existe en otro contacto
isvalid := false;
outpgmsg := 'El número de identificación '||inidentification::text||' tipo '||intypeofid::text||' ya existe en otro contacto, verifique los datos';

	WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
isvalid := false;
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';

	WHEN (length(infirstname) < 1 OR length(inlastname) < 1) AND inidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
isvalid := false;
outpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

WHEN length(inemail1) AND inemail1 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := false;
outpgmsg := inemail1||' no tiene un formato válido';

WHEN length(inemail2) AND inemail2 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := false;
outpgmsg := inemail2||' no tiene un formato válido';

--	WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
-- Actualiza si el contacto existe
--UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';
--isvalid := false;

	--WHEN inidcontact = 0 THEN
-- Insertamos un nuevo registro
--INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote) RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||outreturn::text||' creado.';


--	WHEN inidcontact < 0 THEN
-- Eliminamos el registro de direccion
--DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(inidcontact));
-- Eliminamos el contacto
--DELETE FROM contacts WHERE idcontact = abs(inidcontact);
--outreturn := 0;
--outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

ELSE
--outreturn := abs(inidcontact);
--outpgmsg := 'Ninguna accion realizada';
isvalid := true;
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$_$;


ALTER FUNCTION public.xxxxxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid boolean, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 430 (class 1255 OID 35847)
-- Dependencies: 986 7
-- Name: xxxxxfun_contacts_check_data(integer, text, text, text, integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xxxxxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT intypeofid integer, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
isvalid := 0;

IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
inidaddress := null;
END IF;


CASE
	WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = inidentification AND typeofid = intypeofid AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
 -- El numero de identification ya existe en otro contacto
isvalid := 1;
outpgmsg := 'El número de identificación '||inidentification::text||' tipo '||intypeofid::text||' ya existe en otro contacto, verifique los datos';

	WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
isvalid := 2;
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';

	WHEN (length(infirstname) < 1 OR length(inlastname) < 1) AND inidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
isvalid := 3;
outpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

WHEN length(inemail1) > 0 AND inemail1 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := 4;
outpgmsg := 'La direccion de email: '||inemail1||' no tiene un formato válido';

WHEN length(inemail2) > 0  AND inemail2 !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
isvalid := 5;
outpgmsg := 'La direccion de email: '||inemail2||' no tiene un formato válido';

--	WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
-- Actualiza si el contacto existe
--UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';
--isvalid := false;

	--WHEN inidcontact = 0 THEN
-- Insertamos un nuevo registro
--INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote) RETURNING idcontact INTO outreturn;
--outpgmsg := 'idcontact '||outreturn::text||' creado.';


--	WHEN inidcontact < 0 THEN
-- Eliminamos el registro de direccion
--DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(inidcontact));
-- Eliminamos el contacto
--DELETE FROM contacts WHERE idcontact = abs(inidcontact);
--outreturn := 0;
--outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

ELSE
--outreturn := abs(inidcontact);
--outpgmsg := 'Ninguna accion realizada';
isvalid := 0;
END CASE;

--IF fieldtextasbase64 THEN
--outpgmsg := encode(outpgmsg::bytea, 'base64');
--END IF;

RETURN;
END;$_$;


ALTER FUNCTION public.xxxxxfun_contacts_check_data(inidcontact integer, INOUT infirstname text, INOUT inlastname text, INOUT inidentification text, INOUT intypeofid integer, INOUT inemail1 text, INOUT inemail2 text, INOUT inidaddress integer, OUT isvalid integer, OUT outpgmsg text) OWNER TO postgres;

SET search_path = usaga, pg_catalog;

--
-- TOC entry 275 (class 1255 OID 17469)
-- Dependencies: 986 6
-- Name: event_trigger_after_changing(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION event_trigger_after_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN

-- TODO: Hay que modificar esto mas adelante para que dependiendo de la cuenta y el tipo de evento se envie o no las notificaciones.
-- Se puso este IF ya que estaba enviando notificaciones cuando se hacia algun cambio en los datos de una cuenta.
IF NEW.ideventtype = 72 THEN
PERFORM usaga.fun_account_event_notifications_sms(NEW.idevent);
END IF;

RETURN NULL;
END;$$;


ALTER FUNCTION usaga.event_trigger_after_changing() OWNER TO postgres;

--
-- TOC entry 2939 (class 0 OID 0)
-- Dependencies: 275
-- Name: FUNCTION event_trigger_after_changing(); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION event_trigger_after_changing() IS 'Dispara funciones despues de haber ingresado un evento.';


--
-- TOC entry 322 (class 1255 OID 17470)
-- Dependencies: 986 6
-- Name: fun_account_contacts_byid(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_contacts_byid(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResultado FOR SELECT idaccount, idcontact, enable, encode(firstname::bytea, 'base64') as firstname, encode(lastname::bytea, 'base64') as lastname, prioritycontact, enable_as_contact, encode(appointment::bytea, 'base64') as appointment, encode(note::bytea, 'base64') as note, ts  FROM usaga.view_account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;

ELSE

OPEN CursorResultado FOR SELECT * FROM usaga.view_account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact;
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;

END IF;

RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_account_contacts_byid(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 323 (class 1255 OID 17471)
-- Dependencies: 6 986
-- Name: fun_account_contacts_table(integer, integer, integer, boolean, text, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN


IF EXISTS(SELECT * FROM usaga.account WHERE idaccount = inidaccount) AND EXISTS(SELECT * FROM contacts WHERE idcontact = abs(inidcontact)) THEN

IF inidcontact > 0 THEN

IF EXISTS(SELECT * FROM usaga.account_contacts WHERE idaccount = inidaccount AND idcontact = inidcontact) THEN
-- Actualizamos
UPDATE usaga.account_contacts SET prioritycontact = inpriority, enable = inenable, appointment = inappointment, note = innote WHERE idaccount = inidaccount AND idcontact = inidcontact;

IF FOUND THEN
outpgmsg := 'Registro actualizado';
outreturn := inidcontact; 
ELSE
outpgmsg := 'El registro no pudo ser actualizado';
outreturn := -2; 
END IF;

ELSE
-- Creamos nuevo
INSERT INTO usaga.account_contacts (idcontact, idaccount, enable, prioritycontact, appointment, note) VALUES (inidcontact, inidaccount, inenable, inpriority, inappointment, innote) RETURNING idcontact INTO outreturn;
outpgmsg := 'Nuevo contacto registrado';
END IF;

ELSE
-- Eliminamos el registro
DELETE FROM usaga.account_contacts WHERE idaccount = inidaccount AND idcontact = abs(inidcontact);
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


ALTER FUNCTION usaga.fun_account_contacts_table(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 324 (class 1255 OID 17472)
-- Dependencies: 986 6
-- Name: fun_account_contacts_table_xml(integer, integer, integer, boolean, text, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_contacts_table_xml(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_account_contacts_table(inidaccount, inidcontact, inpriority, inenable, inappointment, innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_account_contacts_table_xml(inidaccount integer, inidcontact integer, inpriority integer, inenable boolean, inappointment text, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 325 (class 1255 OID 17473)
-- Dependencies: 6 986
-- Name: fun_account_event_notifications_sms(bigint); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_event_notifications_sms(id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE

EventROWDATA   usaga.events%ROWTYPE;

CursorNotifactions refcursor;
NotificationROWDATA   usaga.account_notifications%ROWTYPE;

TextSMS TEXT DEFAULT 'Alarma!';
InternalidphoneToAlarmaFromCall INTEGER DEFAULT 0;
InternalidincallToAlarmaFromCall INTEGER DEFAULT 0;
IdOwner integer default 0;

BEGIN
--
IdOwner :=  usaga.fun_get_idowner_usaga();

-- Obtenemos todos los eventos que no hay sido procesados automaticamente
SELECT * INTO EventROWDATA FROM usaga.events WHERE idevent = id;

   
-- El el evento es tipo 72 (Generado por llamada telefonica) Enviamos las notificaciones a todas las persona configuradas         
-- TODO: Debe enviarse a las personas que tiene asignado ese tipo de evento

    OPEN CursorNotifactions FOR SELECT * FROM usaga.account_notifications WHERE idaccount = EventROWDATA.idaccount;
    loop

        FETCH CursorNotifactions INTO NotificationROWDATA;
        EXIT WHEN NOT FOUND;

-- Definimos el texto del mensaje
IF length(NotificationROWDATA.smstext) > 0 THEN
TextSMS := usaga.fun_notification_gen_message(EventROWDATA.idevent::INTEGER, NotificationROWDATA.smstext::TEXT);
ELSE
TextSMS := EventROWDATA.description;
END IF;
      
--PERFORM fun_smsout_insert_sendnow(0, 10, NotificationROWDATA.idphone::INTEGER, EventROWDATA.priority, ''::text, TextSMS, false, 1, 'Notificacion generada automaticamente');
PERFORM fun_outgoing_new_now(0, 0, 10, NotificationROWDATA.idphone::INTEGER, ''::text, TextSMS, EventROWDATA.priority, true, false, 1, IdOwner, 'Notificacion generada automaticamente');

    end loop;
    CLOSE CursorNotifactions;

-- Tipo de evento 72 es alarma por llamada telefonica, debemos enviar una notificacion al propietario de la linea informando la recepcion de la alarma
IF EventROWDATA.ideventtype = 72 THEN

SELECT idincall INTO InternalidincallToAlarmaFromCall FROM usaga.events_generated_by_calls WHERE idevent = EventROWDATA.idevent;

IF InternalidincallToAlarmaFromCall>0 THEN

SELECT idphone INTO InternalidphoneToAlarmaFromCall FROM incomingcalls WHERE idincall = InternalidincallToAlarmaFromCall;
IF InternalidphoneToAlarmaFromCall > 0 THEN
--PERFORM fun_smsout_insert_sendnow(0, 10, InternalidphoneToAlarmaFromCall, 10, ''::text, 'uSAGA ha recibido su señal', true, 0, 'SMS generado automaticamente');
PERFORM fun_outgoing_new_now(0, 0, 10, InternalidphoneToAlarmaFromCall, ''::text, 'uSAGA ha recibido su señal', 10, true, false, 0, IdOwner, 'Notificacion de alarma recibida');
END IF;
END IF;

END IF;

-- Actualizamos el proceso del evento a 1
UPDATE usaga.events  SET process1 = 1, dateprocess1 = now() WHERE idevent = EventROWDATA.idevent;


RETURN TRUE;
END;$$;


ALTER FUNCTION usaga.fun_account_event_notifications_sms(id bigint) OWNER TO postgres;

--
-- TOC entry 326 (class 1255 OID 17474)
-- Dependencies: 6 986
-- Name: fun_account_getdata_string(integer, text, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_getdata_string(inidaccount integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
AccountROWDATA   usaga.account%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO AccountROWDATA FROM usaga.account WHERE idaccount = inidaccount;
  
    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
    
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(AccountROWDATA.idaccount::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(AccountROWDATA.partition::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(AccountROWDATA.enable::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(AccountROWDATA.account::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(AccountROWDATA.name::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(AccountROWDATA.type::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(AccountROWDATA.dateload::text,''));

	WHEN i_string[1] = '08' THEN
Retorno := replace(Retorno, prefix||'08', COALESCE(AccountROWDATA.idgroup::text,''));

	WHEN i_string[1] = '09' THEN
--Retorno := replace(Retorno, '&P09', COALESCE(AccountROWDATA.idaddress::text,''));
Retorno := replace(Retorno, '09', COALESCE(AccountROWDATA.idaddress::text,''));

	WHEN i_string[1] = '10' THEN
Retorno := replace(Retorno, prefix||'10', COALESCE(AccountROWDATA.note::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;


--raise notice 'Retornox = %',Retorno;                                                

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_account_getdata_string(inidaccount integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 17475)
-- Dependencies: 986 6
-- Name: fun_account_location_table(integer, real, real, text, text, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_location_table(inidaccount integer, ingeox real, ingeoy real, inaddress text, inidaddress text, innote text, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outpgmsg := '';
outreturn := 0;

-- Verificamos que el numero de cuenta sea mayos que 0
IF abs(inidaccount) > 0 THEN

IF EXISTS(SELECT * FROM usaga.account_location WHERE idaccount = abs(inidaccount)) THEN

IF inidaccount > 0 THEN
-- Actualiza los datos
UPDATE usaga.account_location SET geox = ingeox, geoy = ingeoy, address = inaddress, idaddress = inidaddress, note = innote WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Localizacion de idaccount '||inidaccount::text||' actualizada';
ELSE
-- Borra los datos (No elimina el registro)
UPDATE usaga.account_location SET geox = 0, geoy = 0, address = '', idaddress = '', note = '' WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Borrardos datos de localización idaccount '||inidaccount::text;
END IF;

ELSE
-- Inserta
INSERT INTO usaga.account_location (idaccount, geox, geoy, address, idaddress, note) VALUES (inidaccount, ingeox, ingeoy, inaddress, inidaddress, innote) RETURNING idaccount INTO outreturn;
outpgmsg := 'Localizacion de idaccount '||inidaccount::text||' creada';
END IF;

ELSE
outpgmsg := 'El idaccount '||inidaccount::text||' no es valido.';
outreturn := -1;
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.fun_account_location_table(inidaccount integer, ingeox real, ingeoy real, inaddress text, inidaddress text, innote text, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 328 (class 1255 OID 17476)
-- Dependencies: 986 6
-- Name: fun_account_notifications_applyselected(integer, integer[], boolean, boolean, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_notifications_applyselected(inidaccount integer, idphones integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

internalidnotifaccount INTEGER DEFAULT 0;
numphones INTEGER DEFAULT 0;

BEGIN
outpgmsg := 'Ninguna accion realizada';
outreturn := 0;


FOR i IN array_lower(idphones,1) .. array_upper(idphones,1) LOOP
internalidnotifaccount := 0;
-- Buscamos si existe el registro
SELECT idnotifaccount INTO internalidnotifaccount FROM usaga.account_notifications WHERE idaccount = inidaccount AND idphone = idphones[i] LIMIT 1;

IF internalidnotifaccount > 0 THEN
-- Actualizamos
UPDATE usaga.account_notifications SET call = incall, sms = insms, smstext = inmsg WHERE idnotifaccount = internalidnotifaccount;
ELSE
-- Insertamos
INSERT INTO usaga.account_notifications (idaccount, idphone, priority, call, sms, smstext, note) VALUES (inidaccount, idphones[i], 5, incall, insms, inmsg, '') RETURNING idnotifaccount INTO internalidnotifaccount;
END IF;

-- Sumamos 1
IF internalidnotifaccount > 0 THEN
outreturn := outreturn+1;
END IF;


END LOOP;

outpgmsg := 'Se han aplicado los cambios a '||outreturn::text||' teléfonos.';

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.fun_account_notifications_applyselected(inidaccount integer, idphones integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 17477)
-- Dependencies: 6 986
-- Name: fun_account_notifications_applyselected_xml(integer, integer[], boolean, boolean, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_notifications_applyselected_xml(inidaccount integer, idphones integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_account_notifications_applyselected(inidaccount, idphones, incall, insms, inmsg, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_account_notifications_applyselected_xml(inidaccount integer, idphones integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 330 (class 1255 OID 17478)
-- Dependencies: 986 6
-- Name: fun_account_notifications_table(integer, integer, integer, integer, boolean, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_notifications_table(inidnotifaccount integer, inidaccount integer, inidphone integer, inpriority integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

internalidnotifaccount INTEGER DEFAULT 0;

BEGIN

outreturn := 0;
outpgmsg := 'Ninguna accion realizada';

SELECT idnotifaccount INTO internalidnotifaccount FROM usaga.account_notifications WHERE idaccount = inidaccount AND idphone = inidphone LIMIT 1;

IF internalidnotifaccount > 0 THEN
-- Actualizamos
UPDATE usaga.account_notifications SET priority = inpriority, call = incall, sms = insms, smstext = insmstext, note = innote WHERE idnotifaccount = internalidnotifaccount;
outreturn := internalidnotifaccount;
outpgmsg := 'Registro actualizado';
ELSE
-- Insertamos
INSERT INTO usaga.account_notifications (idaccount, idphone, priority, call, sms, smstext, note) VALUES (inidaccount, inidphone, inpriority, incall, insms, insmstext, innote) RETURNING idnotifaccount INTO outreturn;
outpgmsg := 'Registro insertado';
END IF;


IF fieldtextasbase64 THEN

outpgmsg := encode(outpgmsg::bytea, 'base64');

END IF;


RETURN;
END;$$;


ALTER FUNCTION usaga.fun_account_notifications_table(inidnotifaccount integer, inidaccount integer, inidphone integer, inpriority integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 331 (class 1255 OID 17479)
-- Dependencies: 986 6
-- Name: fun_account_notifications_table_xml(integer, integer, integer, integer, boolean, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_notifications_table_xml(inidnotifaccount integer, inidaccount integer, inidphone integer, prioinrity integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_account_notifications_table(inidnotifaccount, inidaccount, inidphone, prioinrity, incall, insms, insmstext, innote, ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_account_notifications_table_xml(inidnotifaccount integer, inidaccount integer, inidphone integer, prioinrity integer, incall boolean, insms boolean, insmstext text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 332 (class 1255 OID 17480)
-- Dependencies: 6 986
-- Name: fun_account_notify_applied_to_selected_contacts(integer, integer[], boolean, boolean, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_notify_applied_to_selected_contacts(inidaccount integer, idcontacts integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

InternalIdPhone INTEGER DEFAULT 0;
CursorPhones refcursor;
numcontacts INTEGER DEFAULT 0;
numphonesx INTEGER DEFAULT 0;
numphonesy INTEGER DEFAULT 0;

BEGIN

-- Recorremos cada idcontcat

FOR i IN array_lower(idcontacts,1) .. array_upper(idcontacts,1) LOOP

-- Verificamos que efectivamente cada idcontact pertenesca a la cuenta
IF EXISTS(SELECT * FROM usaga.view_account_contacts WHERE idaccount = inidaccount AND idcontact = idcontacts[i]) THEN
numcontacts := numcontacts+1;
-- Recorremos todos los telefonos que tiene ese contacto
OPEN CursorPhones FOR SELECT idphone FROM phones WHERE idcontact = idcontacts[i];

    loop 

        FETCH CursorPhones INTO InternalIdPhone;
        EXIT WHEN NOT FOUND;


SELECT xyz.outreturn INTO numphonesy FROM usaga.fun_account_notifications_applyselected(inidaccount, ARRAY[InternalIdPhone], incall, insms, inmsg, false) as xyz;
numphonesx = numphonesx+numphonesy;


    end loop;
    CLOSE CursorPhones;


END IF;


END LOOP;

outreturn :=0;

outpgmsg:= 'Se aplicó los cambios a '||numphonesx::text||' teléfonos de '||numcontacts::text||' de '||array_length(idcontacts, 1)::text||' contactos solicitados.';

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.fun_account_notify_applied_to_selected_contacts(inidaccount integer, idcontacts integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 333 (class 1255 OID 17481)
-- Dependencies: 986 6
-- Name: fun_account_notify_applied_to_selected_contacts_xml(integer, integer[], boolean, boolean, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_notify_applied_to_selected_contacts_xml(inidaccount integer, idcontacts integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_account_notify_applied_to_selected_contacts(inidaccount, idcontacts, incall, insms, inmsg, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_account_notify_applied_to_selected_contacts_xml(inidaccount integer, idcontacts integer[], incall boolean, insms boolean, inmsg text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 334 (class 1255 OID 17482)
-- Dependencies: 6 986
-- Name: fun_account_phones_trigger_alarm_isuser(integer, integer); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno BOOLEAN DEFAULT FALSE;
InIdContact INTEGER DEFAULT 0;
BEGIN

-- Obtenemos el IdContact a quien pertenece ese idphone
SELECT idcontact INTO InIdContact FROM phones WHERE idphone = inidphone; 
IF EXISTS(SELECT * FROM usaga.account_users WHERE idaccount = inidaccount AND idcontact = InIdContact) THEN
-- El telefono pertenece a un usuario del sistema
Retorno := TRUE;
ELSE
-- Eliminamos ese registro si existe
IF EXISTS(SELECT * FROM usaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone) THEN
DELETE FROM usaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone;
END IF;
Retorno := FALSE;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) OWNER TO postgres;

--
-- TOC entry 2940 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_phones_trigger_alarm_isuser(inidaccount integer, inidphone integer) IS 'Chequea que el idphone pasado como parametro pertenesca a un usuario de la cuenta, caso contrario lo elimina.
Devuelve true si es usuario y false si no lo es.';


--
-- TOC entry 336 (class 1255 OID 17483)
-- Dependencies: 6 986
-- Name: fun_account_phones_trigger_alarm_table_xml(integer, integer, boolean, boolean, boolean, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_phones_trigger_alarm_table_xml(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn integer DEFAULT 0;
outpgmsg text DEFAULT 'Ninguna acción realizada';

BEGIN

-- TODO: Aqui hacer un chequeo de todos los registros


IF usaga.fun_account_phones_trigger_alarm_isuser(inidaccount, inidphone)  THEN
-- idphone pertenece a un usuario del sistema, proseguir.

IF EXISTS(SELECT * FROM usaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone) THEN

IF inenable OR infromsms OR infromcall OR length(innote) > 0 THEN
-- Actualizamos el registro
UPDATE usaga.account_phones_trigger_alarm SET enable = inenable, fromsms = infromsms, fromcall = infromcall, note = innote WHERE idaccount = inidaccount AND idphone = inidphone RETURNING idphone INTO outreturn;
outpgmsg := 'Registro actualizado';
ELSE
-- Todos los valores son falsos eliminamos el registro
DELETE FROM usaga.account_phones_trigger_alarm WHERE idaccount = inidaccount AND idphone = inidphone;
outpgmsg := 'Registro limpiado';
END IF;

ELSE
-- Crear Registro si hay datos que crear
IF inenable OR infromsms OR infromcall OR length(innote) > 0 THEN
INSERT INTO usaga.account_phones_trigger_alarm (idaccount, idphone, enable, fromsms, fromcall, note) VALUES (inidaccount, inidphone, inenable, infromsms, infromcall, innote) RETURNING idphone INTO outreturn;
outpgmsg := 'Registro insertado';
ELSE
outreturn := -1;
outpgmsg := 'No hay datos que ingresar';
END IF;

END IF;


END IF;


IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';

END;$$;


ALTER FUNCTION usaga.fun_account_phones_trigger_alarm_table_xml(inidaccount integer, inidphone integer, inenable boolean, infromsms boolean, infromcall boolean, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 337 (class 1255 OID 17484)
-- Dependencies: 6 986
-- Name: fun_account_search_name(text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_search_name(innameaccount text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT -1;

BEGIN

SELECT idaccount INTO Retorno FROM usaga.account WHERE name = innameaccount;

IF Retorno<1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_account_search_name(innameaccount text) OWNER TO postgres;

--
-- TOC entry 2941 (class 0 OID 0)
-- Dependencies: 337
-- Name: FUNCTION fun_account_search_name(innameaccount text); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_search_name(innameaccount text) IS 'Devuelve el idaccount de la cuenta que tiene el nombre pasado como parametro, si no hay cuentas con ese nombre devuelve 0, devuelve -1 en caso de falla';


--
-- TOC entry 338 (class 1255 OID 17485)
-- Dependencies: 6 986
-- Name: fun_account_search_number(text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_search_number(innumberaccount text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT -1;

BEGIN

SELECT idaccount INTO Retorno FROM usaga.account WHERE account = innumberaccount;

IF Retorno<1 OR Retorno IS NULL THEN
Retorno := 0;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_account_search_number(innumberaccount text) OWNER TO postgres;

--
-- TOC entry 2942 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION fun_account_search_number(innumberaccount text); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_account_search_number(innumberaccount text) IS 'Busca el idaccount basado en el numero pasado como parametro';


--
-- TOC entry 420 (class 1255 OID 17486)
-- Dependencies: 986 6
-- Name: fun_account_table_xml(integer, boolean, text, text, integer, integer, integer, integer, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_table_xml(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, inidcontact integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

 outreturn integer DEFAULT 0;
 outpgmsg text DEFAULT 'Ninguna acción realizada';
IdAccountSearchByName INTEGER DEFAULT 0;
IdAccountSearchByNumber INTEGER DEFAULT 0;
initialaccount TEXT DEFAULT '0000';
i INTEGER DEFAULT 0;
inxname TEXT DEFAULT '';

BEGIN

outreturn := 0;
outpgmsg := 'Ninguna operacion realizada';
initialaccount := inaccount;

IF NOT EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
inidcontact := null;
END IF;

IF length(inname) < 1 AND inidcontact > 0 THEN
 SELECT (lastname||' '||firstname) INTO inxname FROM contacts WHERE idcontact = inidcontact;
ELSE
inxname := inname;
END IF;



IF length(inxname) > 0  OR inidaccount < 0 THEN

-- Primero validamos los datos antes de proseguir
-- Buscamos un idaccount con el nombre pasado como parametro
IdAccountSearchByName := usaga.fun_account_search_name(inxname);

IF NOT EXISTS(SELECT * FROM groups WHERE idgroup = inidgroup) THEN
inidgroup := NULL;
END IF;

CASE
    WHEN inidaccount = 0 THEN

-- Chequeamo que el numero de la cuenta no se repita, si lo hace buscamos el siguiente numero disponible
WHILE usaga.fun_account_search_number(inaccount) > 0 LOOP
    inaccount := initialaccount||'('||i::text||')';
i := i+1;
END LOOP;

IF IdAccountSearchByName < 1 THEN
        -- Nuevo registro
INSERT INTO usaga.account (partition, enable, account, name, type, dateload, note, idgroup, idcontact) VALUES (inpartition, inenable, inaccount, inxname, intype, now(), innote, inidgroup, inidcontact) RETURNING idaccount INTO outreturn;       
outpgmsg := 'Nuevo abonado: '||inxname::TEXT||' con ID '||outreturn::TEXT;
--INSERT INTO usaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent, process1, dateprocess1) VALUES 
--(now(), inidaccount, 'SYS', 100, outpgmsg, 79, now(), 1, now());
--PERFORM usaga.fun_insert_internal_event(inidaccount, 'LOG', 100, outpgmsg, 79, 1, '');
PERFORM usaga.fun_event_insert(0, 'LOG', 0, 100, outpgmsg, 76, NOW()::timestamp without time zone, '', TRUE, FALSE);

ELSE
outpgmsg := 'El nombre ['|| inxname::text ||'] ya esta siendo utilizado por otra cuenta. Utilice otro nombre';
outreturn := -1;
END IF;


    WHEN inidaccount > 0 THEN

IF IdAccountSearchByName < 1 OR IdAccountSearchByName = inidaccount THEN
        -- Actualia registro
UPDATE usaga.account SET partition = inpartition, idcontact = inidcontact, enable = inenable, account = inaccount, name = inxname, type = intype, note = innote, idgroup = inidgroup WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Actualizada la cuenta idaccount = '||outreturn::TEXT;
--INSERT INTO usaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent, process1, dateprocess1) VALUES 
--(now(), inidaccount, 'SYS', 100, outpgmsg, 78, now(), 1, now());
--PERFORM usaga.fun_insert_internal_event(inidaccount, 'LOG', 100, outpgmsg, 78, 1, '');
--PERFORM usaga.fun_event_insert(inidaccount, 'LOG', 0, 100, outpgmsg, 78, NOW()::timestamp without time zone, '', TRUE, FALSE);

ELSE
outpgmsg := 'El nombre ['|| inxname::text ||'] y esta siendo utilizado por otra cuenta. Utilice otro nombre';
outreturn := -1;
END IF;

        WHEN inidaccount < 0 THEN
        -- Eliminamos el registro si existe
IF EXISTS(SELECT account FROM usaga.account WHERE idaccount = abs(inidaccount)) THEN
DELETE FROM  usaga.account WHERE idaccount = abs(inidaccount);
outpgmsg := 'Abonado ID '|| abs(inidaccount) ||' ha sido eliminado.';
outreturn := inidaccount;
--PERFORM usaga.fun_insert_internal_event(0, 'LOG', 100, outpgmsg, 80, 1, '');
PERFORM usaga.fun_event_insert(0, 'LOG', 0, 100, outpgmsg, 80, NOW()::timestamp without time zone, '', TRUE, FALSE);
END IF;

END CASE;

ELSE

outpgmsg := 'El nombre '|| inxname::text ||' no es válido.';
outreturn := inidaccount;

END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';

END;$$;


ALTER FUNCTION usaga.fun_account_table_xml(inidaccount integer, inenable boolean, inaccount text, inname text, inidgroup integer, inpartition integer, intype integer, inidcontact integer, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 339 (class 1255 OID 17487)
-- Dependencies: 6 986
-- Name: fun_account_users_table_xml(integer, integer, text, boolean, integer, text, text, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_account_users_table_xml(inidaccount integer, inidcontact integer, inappointment text, inenable boolean, innumuser integer, inkeyword text, inpwd text, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

outreturn integer DEFAULT 0;
outpgmsg text DEFAULT 'Ninguna acción realizada';

BEGIN

IF EXISTS(SELECT idaccount FROM usaga.account WHERE idaccount = inidaccount) AND EXISTS(SELECT idcontact FROM contacts WHERE idcontact = abs(inidcontact)) THEN

CASE

	WHEN EXISTS(SELECT * FROM usaga.account_users WHERE  idcontact = inidcontact AND NOT idaccount = inidaccount) THEN
outreturn := 0;
outpgmsg := 'El usuario (Id: '||inidcontact::text||') que intenta ingresar ya pertenece a otro abonado';

	WHEN EXISTS(SELECT idaccount FROM usaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount) AND inidcontact > 0 THEN
	-- El registro ya existe, actualizarlo
	UPDATE usaga.account_users SET appointment = inappointment, enable_as_user = inenable, keyword = inkeyword, pwd = inpwd, numuser = innumuser, note_user = innote  WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount;
outreturn := abs(inidcontact);
outpgmsg := 'Usuario actualizado';

	WHEN NOT EXISTS(SELECT idaccount FROM usaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount) AND inidcontact > 0 THEN
	-- El registro no existe, crearlo
INSERT INTO usaga.account_users (idaccount, idcontact, appointment, enable_as_user, keyword, pwd, numuser, note_user) VALUES (inidaccount, inidcontact, inappointment, inenable, inkeyword, inpwd, innumuser, innote);
outreturn := abs(inidcontact);
outpgmsg := 'Usuario insertado';

	WHEN inidcontact < 0 THEN
	-- Eliminamos el registro
	DELETE  FROM usaga.account_users WHERE idcontact = abs(inidcontact) AND idaccount = inidaccount;
outreturn := abs(inidcontact);
outpgmsg := 'Usuario eliminado';
-- Tambien lo eliminamos de la tabla trigger alarm
DELETE FROM usaga.account_phones_trigger_alarm WHERE idphone IN (SELECT idphone FROM view_contacts_phones WHERE idcontact = abs(inidcontact)) AND idaccount = inidaccount;
outpgmsg := 'Usuario eliminado y eliminada la autorizacion para dispara alarmas';
	END CASE;


ELSE
-- 
outpgmsg := 'idaccount '||inidaccount::text||' o idcontact '||inidcontact::text||' no existen';
outreturn := -1;
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN '<table><row><outreturn>'||outreturn::text||'</outreturn><outpgmsg>'||outpgmsg::text||'</outpgmsg></row></table>';
END;



$$;


ALTER FUNCTION usaga.fun_account_users_table_xml(inidaccount integer, inidcontact integer, inappointment text, inenable boolean, innumuser integer, inkeyword text, inpwd text, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 433 (class 1255 OID 35840)
-- Dependencies: 986 6
-- Name: fun_accounts_edit(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, integer, integer, boolean, text, text, integer, timestamp without time zone, text, integer, integer, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_accounts_edit(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE
valid_data integer default 0;
inxname text default '';
IdAccountSearchByName INTEGER DEFAULT 0;
IdAccountSearchByNumber INTEGER DEFAULT 0;
initialaccount TEXT DEFAULT '0000';
i INTEGER DEFAULT 0;

BEGIN

-- Chequeamos la validez de los datos
SELECT cinfirstname, cinlastname, cinidentification, cintypeofid, cinemail1, cinemail2, cinidaddress, isvalid, coutpgmsg 
 INTO infirstname, inlastname, inidentification, intypeofid, inemail1, inemail2, inidaddress, valid_data, outpgmsg
FROM fun_contacts_check_data(inidcontact, infirstname, inlastname, inidentification, intypeofid, inemail1, inemail2, inidaddress);

IF length(inaccount_name) < 1 AND inidcontact > 0 THEN
 SELECT (inlastname||' '||infirstname) INTO inxname FROM usaga.accounts WHERE idcontact = inidcontact;
ELSE
inxname := inaccount_name;
END IF;

IF length(inxname) > 0  OR inidcontact < 0 THEN

-- Primero validamos los datos antes de proseguir
-- Buscamos un idaccount con el nombre pasado como parametro
IdAccountSearchByName := usaga.fun_account_search_name(inxname);

CASE
    WHEN inidcontact = 0 THEN

-- Chequeamo que el numero de la cuenta no se repita, si lo hace buscamos el siguiente numero disponible
WHILE usaga.fun_account_search_number(inidcontact) > 0 LOOP
    inaccount_number := initialaccount||'('||i::text||')';
i := i+1;
END LOOP;

IF IdAccountSearchByName < 1 THEN
        -- Nuevo registro
INSERT INTO usaga.accounts (partition, enable, account, name, type, dateload, note, idgroup, idcontact) VALUES (inpartition, inenable, inaccount, inxname, intype, now(), innote, inidgroup, inidcontact) RETURNING idaccount INTO outreturn;       
outpgmsg := 'Nuevo abonado: '||inxname::TEXT||' con ID '||outreturn::TEXT;
--INSERT INTO usaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent, process1, dateprocess1) VALUES 
--(now(), inidaccount, 'SYS', 100, outpgmsg, 79, now(), 1, now());
--PERFORM usaga.fun_insert_internal_event(inidaccount, 'LOG', 100, outpgmsg, 79, 1, '');
PERFORM usaga.fun_event_insert(0, 'LOG', 0, 100, outpgmsg, 76, NOW()::timestamp without time zone, '', TRUE, FALSE);

ELSE
outpgmsg := 'El nombre ['|| inxname::text ||'] ya esta siendo utilizado por otra cuenta. Utilice otro nombre';
outreturn := -1;
END IF;


    WHEN inidaccount > 0 THEN

IF IdAccountSearchByName < 1 OR IdAccountSearchByName = inidaccount THEN
        -- Actualia registro
UPDATE usaga.account SET partition = inpartition, idcontact = inidcontact, enable = inenable, account = inaccount, name = inxname, type = intype, note = innote, idgroup = inidgroup WHERE idaccount = abs(inidaccount) RETURNING idaccount INTO outreturn;
outpgmsg := 'Actualizada la cuenta idaccount = '||outreturn::TEXT;
--INSERT INTO usaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent, process1, dateprocess1) VALUES 
--(now(), inidaccount, 'SYS', 100, outpgmsg, 78, now(), 1, now());
--PERFORM usaga.fun_insert_internal_event(inidaccount, 'LOG', 100, outpgmsg, 78, 1, '');
--PERFORM usaga.fun_event_insert(inidaccount, 'LOG', 0, 100, outpgmsg, 78, NOW()::timestamp without time zone, '', TRUE, FALSE);

ELSE
outpgmsg := 'El nombre ['|| inxname::text ||'] y esta siendo utilizado por otra cuenta. Utilice otro nombre';
outreturn := -1;
END IF;

        WHEN inidaccount < 0 THEN
        -- Eliminamos el registro si existe
IF EXISTS(SELECT account FROM usaga.account WHERE idaccount = abs(inidaccount)) THEN
DELETE FROM  usaga.account WHERE idaccount = abs(inidaccount);
outpgmsg := 'Abonado ID '|| abs(inidaccount) ||' ha sido eliminado.';
outreturn := inidaccount;
--PERFORM usaga.fun_insert_internal_event(0, 'LOG', 100, outpgmsg, 80, 1, '');
PERFORM usaga.fun_event_insert(0, 'LOG', 0, 100, outpgmsg, 80, NOW()::timestamp without time zone, '', TRUE, FALSE);
END IF;

END CASE;

ELSE

outpgmsg := 'El nombre '|| inxname::text ||' no es válido.';
outreturn := inidaccount;

END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.fun_accounts_edit(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 413 (class 1255 OID 35841)
-- Dependencies: 6 986
-- Name: fun_accounts_edit_xml(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, integer, integer, boolean, text, text, integer, timestamp without time zone, text, integer, integer, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_accounts_edit_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN

OPEN CursorResultado FOR SELECT * FROM usaga.fun_accounts_edit(inidcontact, inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, inidaddress, inpartition, inaccount_enable, inaccount_number, inaccount_name, inidaccounttype, ininstalation_date, ininstaller_code, inidpanelmodel, inidcommunicationformat, insecurity_contacts,  innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_accounts_edit_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 340 (class 1255 OID 17488)
-- Dependencies: 986 6
-- Name: fun_auto_process_events(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_auto_process_events() RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
PERFORM usaga.fun_account_event_notifications_sms();

RETURN TRUE;
END;$$;


ALTER FUNCTION usaga.fun_auto_process_events() OWNER TO postgres;

--
-- TOC entry 2943 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION fun_auto_process_events(); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_auto_process_events() IS 'Procesa los eventos:
Envia notificaciones basados en los eventos y configuraciones del sistema';


--
-- TOC entry 416 (class 1255 OID 35585)
-- Dependencies: 6 986
-- Name: fun_event_comment_insert(integer, integer, integer, integer, text, integer[], boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_event_comment_insert(inidevent integer, inidadmin integer, inseconds integer, status integer, incomment text, inidattachs integer[], fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

my_interval interval;
my_comment text;


BEGIN

-- Removemos el atributo id del codigo HTML para que no cause problemas porteriormente al insetar el codigo en el navegador
my_comment = regexp_replace(incomment, '\s(id|widgetid|data-dojo-attach-point)="[^"]+"', '', 'g');

-- TODO: Utilizar idadmin
inidadmin := 0;
select into my_interval (inseconds::varchar(24) || ' seconds')::interval;

IF EXISTS(SELECT * FROM usaga.events WHERE idevent = inidevent) THEN
-- Creamos nuevo
INSERT INTO usaga.events_comments (idevent, idadmin, date_end, date_start, comment, idstatusevent, attachments) VALUES (inidevent, inidadmin, now(), now() - my_interval, my_comment, status, inidattachs) RETURNING idcomment INTO outreturn;
outpgmsg := 'Nuevo comentario registrado';
ELSE
outreturn := -1;
outpgmsg := 'El evento idevent '||inidevent::text||' no existen';
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;

$$;


ALTER FUNCTION usaga.fun_event_comment_insert(inidevent integer, inidadmin integer, inseconds integer, status integer, incomment text, inidattachs integer[], fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 417 (class 1255 OID 35586)
-- Dependencies: 986 6
-- Name: fun_event_comment_insert_xml(integer, integer, integer, integer, text, integer[], boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_event_comment_insert_xml(inidevent integer, inidadmin integer, inseconds integer, status integer, incomment text, inidattachs integer[], fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_event_comment_insert(inidevent, inidadmin, inseconds, status, incomment, inidattachs, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_event_comment_insert_xml(inidevent integer, inidadmin integer, inseconds integer, status integer, incomment text, inidattachs integer[], fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 401 (class 1255 OID 18942)
-- Dependencies: 6 986
-- Name: fun_event_future_to_notification_area(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_event_future_to_notification_area() RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE

CursorEvents refcursor;
--EventROWDATA   usaga.events%ROWTYPE;
id INTEGER DEFAULT -1;

BEGIN

    OPEN CursorEvents FOR SELECT idevent FROM usaga.events WHERE na = false AND datetimeevent < now() ORDER BY datetimeevent;
    loop

        FETCH CursorEvents INTO id;
        EXIT WHEN NOT FOUND;

PERFORM usaga.fun_event_to_notification_area(id);
      
    end loop;
    CLOSE CursorEvents;

RETURN TRUE;
END;$$;


ALTER FUNCTION usaga.fun_event_future_to_notification_area() OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 18579)
-- Dependencies: 6 986
-- Name: fun_event_insert(integer, text, integer, integer, text, integer, timestamp without time zone, text, boolean, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_event_insert(inidaccount integer, incode text, inzu integer, inpriority integer, indescription text, inideventtype integer, indatetimeevent timestamp without time zone, innote text, inautomatic boolean, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql STRICT
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;
BEGIN

-- Obtenemos la prioridad del evento si el valor pasado es menor que 1, si aun asi el valor es 0 se lo pone automaticamente a 100
IF inpriority < 1 THEN
SELECT priority INTO inpriority FROM usaga.eventtypes WHERE ideventtype = inideventtype;
END IF;

IF inpriority < 1 THEN
inpriority := 100;
END IF;

IF length(indescription) < 1 THEN
SELECT label INTO indescription FROM usaga.eventtypes WHERE ideventtype = inideventtype;
END IF;

	CASE

	WHEN NOT EXISTS(SELECT * FROM usaga.account WHERE idaccount = inidaccount) AND inidaccount > 0  THEN
outreturn := -1;
outpgmsg := 'idaccount '||inidaccount::text||' no existe';

	WHEN inautomatic = FALSE AND EXISTS(SELECT * FROM usaga.eventtypes WHERE ideventtype = inideventtype AND manual = FALSE) THEN  
outreturn := -1;
outpgmsg := 'El Evento no se puede crear porque este tipo de evento no esta habilitado para ser creado de forma manual';

	ELSE

IF NOT EXISTS(SELECT * FROM usaga.eventtypes WHERE ideventtype = inideventtype AND enable_datetime = true) THEN
-- Unicamente los eventos tipo tarea (87) pueden ser programados a una fecha determinada, el resto se crean con la fecha actual
indatetimeevent := now();
END IF;

INSERT INTO usaga.events (dateload, idaccount, code, zu, priority, description, ideventtype, datetimeevent, note) VALUES (now(), abs(inidaccount), incode, inzu,  inpriority, indescription, inideventtype, indatetimeevent, innote) RETURNING idevent INTO outreturn;
outpgmsg := 'Nuevo evento tipo '||inideventtype::text||' a sido regitrado';

-- Finalizamos el evento automaticamente si no requiere tratamiento de un operador
IF outreturn > 0 AND EXISTS(SELECT  * FROM usaga.eventtypes WHERE ideventtype = inideventtype AND treatment = FALSE) THEN
PERFORM usaga.fun_event_comment_insert(outreturn, 0, 0, 1, 'Evento no requiere tratamiento de un administrador, se lo finaliza automaticamente', '{}'::integer[], FALSE);
END IF;

	END CASE;

-- Enviamos la notificacion si la fecha es igual o menor a la fecha actual
IF indatetimeevent <= now() THEN
PERFORM usaga.fun_event_to_notification_area(outreturn);
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.fun_event_insert(inidaccount integer, incode text, inzu integer, inpriority integer, indescription text, inideventtype integer, indatetimeevent timestamp without time zone, innote text, inautomatic boolean, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 389 (class 1255 OID 18580)
-- Dependencies: 6 986
-- Name: fun_event_insert_manual_xml(integer, text, integer, integer, text, integer, timestamp without time zone, text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_event_insert_manual_xml(inidaccount integer, incode text, inzu integer, inpriority integer, indescription text, inideventtype integer, indatetimeevent timestamp without time zone, innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_event_insert(inidaccount, incode, inzu, inpriority, indescription, inideventtype, indatetimeevent, innote, FALSE, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_event_insert_manual_xml(inidaccount integer, incode text, inzu integer, inpriority integer, indescription text, inideventtype integer, indatetimeevent timestamp without time zone, innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 18911)
-- Dependencies: 6 986
-- Name: fun_event_to_notification_area(integer); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_event_to_notification_area(inidevent integer DEFAULT 0) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno INTEGER DEFAULT 0;
Titulo TEXT DEFAULT '';
--Abonado TEXT DEFAULT 'System';

RowData usaga.view_events%ROWTYPE;
EventtypesROWDATA usaga.eventtypes%ROWTYPE;


BEGIN

IF EXISTS(SELECT * FROM usaga.view_events WHERE idevent = inidevent)  THEN

SELECT * INTO RowData FROM usaga.view_events WHERE idevent = inidevent;
SELECT * INTO EventtypesROWDATA FROM usaga.eventtypes WHERE ideventtype = RowData.ideventtype;

--IF EXISTS(SELECT * FROM usaga.account WHERE idaccount = EventROWDATA.idaccount) THEN
--SELECT name INTO Abonado FROM usaga.account WHERE idaccount = EventROWDATA.idaccount;
--END IF;

Titulo := RowData.eventtype||' en '||RowData.name;
PERFORM fun_notifications_insert(RowData.priority, EventtypesROWDATA.na_timeout, EventtypesROWDATA.na_closable, EventtypesROWDATA.na_img, EventtypesROWDATA.na_snd, Titulo, RowData.description);

UPDATE usaga.events SET na = true WHERE idevent = inidevent;

END IF;


RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_event_to_notification_area(inidevent integer) OWNER TO postgres;

--
-- TOC entry 2944 (class 0 OID 0)
-- Dependencies: 398
-- Name: FUNCTION fun_event_to_notification_area(inidevent integer); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_event_to_notification_area(inidevent integer) IS 'Esta funcion muestra un mensaje en el area de notificacion de la interface grafica en base al idevent, no realiza ningun chequeo si el evento es pasado o futuro, unicamente verifica que el idevent exista.';


--
-- TOC entry 393 (class 1255 OID 18601)
-- Dependencies: 986 6
-- Name: fun_events_comments_table_is_changed(timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_events_comments_table_is_changed(ints timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE


Retorno BOOLEAN DEFAULT FALSE;

BEGIN

IF ints < (SELECT ts FROM usaga.events_comments ORDER BY ts DESC LIMIT 1) THEN
Retorno := TRUE;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_events_comments_table_is_changed(ints timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 387 (class 1255 OID 18550)
-- Dependencies: 6 986
-- Name: fun_events_getbyid_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_events_getbyid_xml(inid integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idevent, idaccount, datetimeevent, encode(code::bytea, 'base64') AS code, zu, priority, encode(description::bytea, 'base64') AS description, ideventtype, ts FROM usaga.events WHERE idevent = inid LIMIT 1;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.events WHERE idevent = inid LIMIT 1;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_events_getbyid_xml(inid integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 341 (class 1255 OID 17489)
-- Dependencies: 6 986
-- Name: fun_events_getdata_string(integer, text, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_events_getdata_string(inidevent integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
EventsROWDATA   usaga.events%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO EventsROWDATA FROM usaga.events WHERE idevent = inidevent;
  
--Retorno := fun_address_getdata_string(PhonesROWDATA.idaddress, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
--    raise notice 'row4 = %',Retorno;                                                
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(EventsROWDATA.idevent::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(EventsROWDATA.dateload::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(EventsROWDATA.idaccount::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(EventsROWDATA.code::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(EventsROWDATA.zu::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(EventsROWDATA.priority::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(EventsROWDATA.description::text,''));

	WHEN i_string[1] = '08' THEN
Retorno := replace(Retorno, prefix||'08', COALESCE(EventsROWDATA.ideventtype::text,''));

	WHEN i_string[1] = '09' THEN
Retorno := replace(Retorno, prefix||'09', COALESCE(EventsROWDATA.datetimeevent::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;




RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_events_getdata_string(inidevent integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 342 (class 1255 OID 17490)
-- Dependencies: 6 986
-- Name: fun_events_lastid_xml(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_events_lastid_xml() RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT idevent FROM usaga.events ORDER BY idevent DESC LIMIT 1;
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_events_lastid_xml() OWNER TO postgres;

--
-- TOC entry 392 (class 1255 OID 18600)
-- Dependencies: 986 6
-- Name: fun_events_table_is_changed(timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_events_table_is_changed(ints timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE


Retorno BOOLEAN DEFAULT FALSE;

BEGIN

IF ints < (SELECT ts FROM usaga.events ORDER BY ts DESC LIMIT 1) THEN
Retorno := TRUE;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_events_table_is_changed(ints timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 303 (class 1255 OID 17491)
-- Dependencies: 6 986
-- Name: fun_eventtype_default(integer, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_eventtype_default(inid integer, inname text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno INTEGER DEFAULT 0;

BEGIN

IF EXISTS(SELECT name FROM usaga.eventtypes WHERE ideventtype=inid)  THEN
-- El registro existe, se lo puede actualizar
UPDATE usaga.eventtypes SET name = inname WHERE ideventtype = inid RETURNING ideventtype INTO Retorno;
ELSE
-- El registro no existe, lo insertamos
INSERT INTO usaga.eventtypes (ideventtype, name, label) VALUES (inid, inname, inname) RETURNING ideventtype INTO Retorno;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_eventtype_default(inid integer, inname text) OWNER TO postgres;

--
-- TOC entry 2945 (class 0 OID 0)
-- Dependencies: 303
-- Name: FUNCTION fun_eventtype_default(inid integer, inname text); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_eventtype_default(inid integer, inname text) IS 'Funcion usada internamente por opesaga para reflejar los EventType usados por el sistema.';


--
-- TOC entry 404 (class 1255 OID 18840)
-- Dependencies: 6 986
-- Name: fun_eventtypes_edit(integer, integer, text, boolean, boolean, boolean, boolean, boolean, integer, boolean, text, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_eventtypes_edit(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, inmanual boolean, intreatment boolean, inenable_datetime boolean, inna_timeout integer, inna_closeable boolean, inna_img text, inna_snd text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

outreturn := 0;
outpgmsg := '';

IF EXISTS(SELECT ideventtype FROM usaga.eventtypes WHERE ideventtype = inideventtype) THEN
UPDATE usaga.eventtypes SET priority = inpriority, label = inlabel, note = innote, accountdefault = inadefault, groupdefault = ingdefault, manual = inmanual, treatment = intreatment, enable_datetime = inenable_datetime, na_timeout = inna_timeout, na_closable = inna_closeable, na_img = inna_img, na_snd = inna_snd WHERE ideventtype = inideventtype RETURNING ideventtype INTO outreturn;
outpgmsg := 'El registro actualizado';
ELSE
outreturn := 0;
outpgmsg := 'El registro no existe';
END IF;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;



$$;


ALTER FUNCTION usaga.fun_eventtypes_edit(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, inmanual boolean, intreatment boolean, inenable_datetime boolean, inna_timeout integer, inna_closeable boolean, inna_img text, inna_snd text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 405 (class 1255 OID 18841)
-- Dependencies: 986 6
-- Name: fun_eventtypes_edit_xml(integer, integer, text, boolean, boolean, boolean, boolean, boolean, integer, boolean, text, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_eventtypes_edit_xml(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, inmanual boolean, intreatment boolean, inenable_datetime boolean, inna_timeout integer, inna_closeable boolean, inna_img text, inna_snd text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_eventtypes_edit(inideventtype, inpriority, inlabel, inadefault, ingdefault, inmanual, intreatment, inenable_datetime, inna_timeout, inna_closeable, inna_img, inna_snd, innote, ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_eventtypes_edit_xml(inideventtype integer, inpriority integer, inlabel text, inadefault boolean, ingdefault boolean, inmanual boolean, intreatment boolean, inenable_datetime boolean, inna_timeout integer, inna_closeable boolean, inna_img text, inna_snd text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 17494)
-- Dependencies: 986 6
-- Name: fun_eventtypes_getdata_string(integer, text, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_eventtypes_getdata_string(inideventtype integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
EventTypesROWDATA   usaga.eventtypes%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO EventTypesROWDATA FROM usaga.eventtypes WHERE ideventtype = inideventtype;
  
--Retorno := fun_address_getdata_string(PhonesROWDATA.idaddress, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
--    raise notice 'row4 = %',Retorno;                                                
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(EventTypesROWDATA.ideventtype::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(EventTypesROWDATA.name::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(EventTypesROWDATA.priority::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(EventTypesROWDATA.accountdefault::text,''));

	WHEN i_string[1] = '05' THEN
Retorno := replace(Retorno, prefix||'05', COALESCE(EventTypesROWDATA.groupdefault::text,''));

	WHEN i_string[1] = '06' THEN
Retorno := replace(Retorno, prefix||'06', COALESCE(EventTypesROWDATA.label::text,''));

	WHEN i_string[1] = '07' THEN
Retorno := replace(Retorno, prefix||'07', COALESCE(EventTypesROWDATA.note::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;




RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_eventtypes_getdata_string(inideventtype integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 394 (class 1255 OID 18612)
-- Dependencies: 986 6
-- Name: fun_eventtypes_table_is_changed(timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_eventtypes_table_is_changed(ints timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE


Retorno BOOLEAN DEFAULT FALSE;

BEGIN

IF ints < (SELECT ts FROM usaga.eventtypes ORDER BY ts DESC LIMIT 1) THEN
Retorno := TRUE;
END IF;

RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_eventtypes_table_is_changed(ints timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 386 (class 1255 OID 18548)
-- Dependencies: 6 986
-- Name: fun_eventtypes_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_eventtypes_xml(inmanual integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN
-- Manual 1 = Solo manuales
-- Manual 2 = Excepto manuales
-- Manual diferente a 1 o 2 = Todos los registros

CASE
	WHEN inmanual = 1 THEN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  ideventtype, encode(label::bytea, 'base64') AS label FROM usaga.eventtypes WHERE manual = true ORDER BY label;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT ideventtype, label FROM usaga.eventtypes WHERE manual = true ORDER BY label;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;


	WHEN inmanual = 2 THEN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  ideventtype, encode(label::bytea, 'base64') AS label FROM usaga.eventtypes WHERE manual = false ORDER BY label;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT ideventtype, label FROM usaga.eventtypes WHERE manual = false ORDER BY label;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;


ELSE

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  ideventtype, encode(label::bytea, 'base64') AS label FROM usaga.eventtypes ORDER BY label;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT ideventtype, label FROM usaga.eventtypes ORDER BY label;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

END CASE;


RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_eventtypes_xml(inmanual integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 17495)
-- Dependencies: 6 986
-- Name: fun_generate_test_report(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$BEGIN


RETURN;
END;$$;


ALTER FUNCTION usaga.fun_generate_test_report(OUT outeventsgenerated integer) OWNER TO postgres;

--
-- TOC entry 2946 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION fun_generate_test_report(OUT outeventsgenerated integer); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_generate_test_report(OUT outeventsgenerated integer) IS 'Genera los eventos de reporte de prueba enviados a los clientes.';


--
-- TOC entry 345 (class 1255 OID 17496)
-- Dependencies: 6 986
-- Name: fun_get_idowner_usaga(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_get_idowner_usaga() RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno integer default 0;

BEGIN

IF EXISTS(SELECT * FROM owners WHERE name = 'uSAGA Software') THEN
SELECT idowner INTO Retorno FROM owners WHERE name = 'uSAGA Software';
ELSE
INSERT INTO owners (name, description) VALUES ('uSAGA Software', 'Micro Sistema Automático de gestión de alarmas') RETURNING idowner INTO Retorno; 
END IF;

return Retorno;
END;$$;


ALTER FUNCTION usaga.fun_get_idowner_usaga() OWNER TO postgres;

--
-- TOC entry 346 (class 1255 OID 17497)
-- Dependencies: 986 6
-- Name: fun_get_priority_from_ideventtype(integer); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_get_priority_from_ideventtype(inideventtype integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;

BEGIN
SELECT priority INTO Retorno FROM usaga.eventtypes WHERE ideventtype = inideventtype;
IF Retorno IS NULL OR Retorno < 0 THEN
Retorno := 10;
END IF;
RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_get_priority_from_ideventtype(inideventtype integer) OWNER TO postgres;

--
-- TOC entry 2947 (class 0 OID 0)
-- Dependencies: 346
-- Name: FUNCTION fun_get_priority_from_ideventtype(inideventtype integer); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_get_priority_from_ideventtype(inideventtype integer) IS 'Devuelve la prioridad segun el ideventtype';


--
-- TOC entry 347 (class 1255 OID 17498)
-- Dependencies: 6 986
-- Name: fun_group_getdata_string(integer, text, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_group_getdata_string(inidgroup integer, prefix text, stringfields text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

i_strings              refcursor := null;
i_string                text[];
i_query                text;

Retorno TEXT DEFAULT '';
GroupROWDATA   usaga.groups%ROWTYPE;

BEGIN

Retorno := trim(stringfields);
prefix := '&'||prefix::text;

SELECT * INTO GroupROWDATA FROM usaga.groups WHERE idgroup = inidgroup;
  
--Retorno := fun_address_getdata_string(PhonesROWDATA.idaddress, Retorno);

    i_query := 'select regexp_matches('''||Retorno||''', '''||prefix||'(\d\d)'',''g'')';
    open i_strings for execute i_query; 
    
    if i_strings is not null then
        loop    fetch i_strings into i_string;
        exit when not found;
--    raise notice 'row4 = %',Retorno;                                                
CASE   
	WHEN i_string[1] = '01' THEN
Retorno := replace(Retorno, prefix||'01', COALESCE(GroupROWDATA.idgroup::text, ''));

	WHEN i_string[1] = '02' THEN
Retorno := replace(Retorno, prefix||'02', COALESCE(GroupROWDATA.enable::text, ''));

	WHEN i_string[1] = '03' THEN
Retorno := replace(Retorno, prefix||'03', COALESCE(GroupROWDATA.name::text, ''));

	WHEN i_string[1] = '04' THEN
Retorno := replace(Retorno, prefix||'04', COALESCE(GroupROWDATA.note::text,''));

ELSE
-- No concide con ninguno
--Retorno := Retorno;
END CASE;
                                
        end loop;
        close i_strings;
    end if;




RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_group_getdata_string(inidgroup integer, prefix text, stringfields text) OWNER TO postgres;

--
-- TOC entry 350 (class 1255 OID 17499)
-- Dependencies: 6 986
-- Name: fun_groups_edit(integer, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_groups_edit(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outpgmsg text, OUT outreturn integer) RETURNS record
    LANGUAGE plpgsql
    AS $$BEGIN

-- Veirificar que los nombres de los grupos no se repitan

CASE

	WHEN inidgroup > 0 AND EXISTS(SELECT * FROM usaga.groups WHERE idgroup = inidgroup)  THEN
	-- Verificamos que el namobre no este en blanco y que no exista ya en otro registro
IF length(inname) > 0 AND NOT EXISTS(SELECT * FROM usaga.groups WHERE name = inname AND NOT (idgroup = inidgroup)) THEN
-- Actualizamos
UPDATE usaga.groups SET enable = inenable, name = inname, note = innote WHERE idgroup = inidgroup RETURNING idgroup INTO outreturn;
outpgmsg:='Registro actualizado';
ELSE
outpgmsg:='No se pudo actualizar, verifique el nombre del grupo no este en blanco o que ya exista en otro registro.';
outreturn := 0;
END IF;
	WHEN  inidgroup = 0 THEN
IF length(inname) > 0 AND NOT EXISTS(SELECT * FROM usaga.groups WHERE name = inname)  THEN
-- Creamo un nuevo registro
INSERT INTO usaga.groups (enable, name, note) VALUES (inenable, inname, innote) RETURNING idgroup INTO outreturn;
outpgmsg:='Nuevo grupo registrado';
ELSE
outpgmsg:='El nombre de grupo "'||inname::text||'" no es válido, utilice otro.';
outreturn := 0;
END IF;

	WHEN inidgroup < 0 AND EXISTS(SELECT * FROM usaga.groups WHERE idgroup = abs(inidgroups)) THEN
DELETE FROM usaga.groups WHERE idgroup = abs(inidgroups);
outpgmsg:='Registro eliminado';
outreturn := 0;
ELSE
outpgmsg:='Ninguna accion realizada';
outreturn := 0;
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;

END;$$;


ALTER FUNCTION usaga.fun_groups_edit(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outpgmsg text, OUT outreturn integer) OWNER TO postgres;

--
-- TOC entry 351 (class 1255 OID 17500)
-- Dependencies: 6 986
-- Name: fun_groups_edit_xml(integer, boolean, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_groups_edit_xml(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_groups_edit(inidgroup, inenable, inname, innote, ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_groups_edit_xml(inidgroup integer, inenable boolean, inname text, innote text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 352 (class 1255 OID 17501)
-- Dependencies: 6 986
-- Name: fun_groups_remove_selected(integer[], boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_groups_remove_selected(idgroups integer[], fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$BEGIN
outpgmsg := 'Ninguna accion realizada';
outreturn := 0;


FOR i IN array_lower(idgroups,1) .. array_upper(idgroups,1) LOOP

-- Buscamos si existe el registro

IF EXISTS(SELECT * FROM usaga.groups WHERE idgroup = idgroups[i]) THEN
DELETE FROM usaga.groups WHERE idgroup = idgroups[i];
outreturn := outreturn+1;
END IF;


END LOOP;

outpgmsg := 'Se han eliminado '||outreturn::text||' grupos.';

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.fun_groups_remove_selected(idgroups integer[], fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 353 (class 1255 OID 17502)
-- Dependencies: 6 986
-- Name: fun_groups_remove_selected_xml(integer[], boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_groups_remove_selected_xml(idgroups integer[], fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_groups_remove_selected(idgroups, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_groups_remove_selected_xml(idgroups integer[], fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 354 (class 1255 OID 17503)
-- Dependencies: 6 986
-- Name: fun_insert_internal_event(integer, text, integer, text, integer, integer, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_insert_internal_event(inidaccount integer, incode text, inpriority integer, indescription text, inideventtype integer, inprocess integer, innote text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$DECLARE
Retorno INTEGER DEFAULT 0;
BEGIN
INSERT INTO usaga.events (dateload, idaccount, code, priority, description, ideventtype, datetimeevent, process1, dateprocess1, note) VALUES (now(), inidaccount, incode, inpriority, indescription, inideventtype, now(), 1, now(), innote) RETURNING idevent INTO Retorno;
RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_insert_internal_event(inidaccount integer, incode text, inpriority integer, indescription text, inideventtype integer, inprocess integer, innote text) OWNER TO postgres;

--
-- TOC entry 391 (class 1255 OID 17504)
-- Dependencies: 986 6
-- Name: fun_insert_system_log(integer, text, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_insert_system_log(inpriority integer, indescription text, innote text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
Retorno INTEGER DEFAULT 100;
BEGIN

--INSERT INTO usaga.events (idaccount, code, priority, description, ideventtype, process1, process2, process3, process4, process5, note) VALUES(0, 'LOG', inpriority, indescription, 89, 1, 1, 1, 1, 1, innote);
SELECT outreturn INTO Retorno FROM usaga.fun_event_insert(0, 'LOG', 0, inpriority, indescription, 86, now(), innote, TRUE, FALSE);
RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_insert_system_log(inpriority integer, indescription text, innote text) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 17505)
-- Dependencies: 6 986
-- Name: fun_notification_gen_message(integer, text); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_notification_gen_message(inidevent integer, insmstext text) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';

IIdAddressAccount INTEGER DEFAULT 0;
IIdLocationAccount INTEGER DEFAULT 0;

Internalidphone INTEGER DEFAULT 0;

IIdAddressContact INTEGER DEFAULT 0;
IIdLocationContact INTEGER DEFAULT 0;

IIdAddressPhone INTEGER DEFAULT 0;
IIdLocationPhone INTEGER DEFAULT 0;

EventROWDATA   usaga.events%ROWTYPE;

idnt INTEGER DEFAULT 0; -- Notification template

BEGIN

Retorno := trim(insmstext);

-- Verificamos si el mensaje tiene el formato &NTXX que representa el idnotiftempl, si existe utilizamos ese mensaje.
idnt :=  to_number((regexp_matches(Retorno, '&NT(\d\d\d)'))[1], '999');
    --raise notice 'idnt = %',idnt; 
IF  EXISTS(SELECT * FROM usaga.notification_templates WHERE idnotiftempl = idnt) THEN
SELECT message INTO Retorno FROM usaga.notification_templates WHERE idnotiftempl = idnt;
END IF;


SELECT * INTO EventROWDATA FROM usaga.events WHERE idevent = inidevent LIMIT 1;

-- DATOS RELACIONADOS CON LA CUENTA DE ABONADO
Retorno := usaga.fun_account_getdata_string(COALESCE(EventROWDATA.idaccount, 0), 'A', Retorno);
SELECT idaddress INTO IIdAddressAccount FROM usaga.account WHERE idaccount = EventROWDATA.idaccount;
Retorno := fun_address_getdata_string(COALESCE(IIdAddressAccount, 0), 'AA', Retorno);
SELECT idlocation INTO IIdLocationAccount FROM address WHERE idaddress = IIdAddressAccount;
Retorno := fun_location_getdata_string(COALESCE(IIdLocationAccount, 0), 'AL', Retorno);

-- DATOS RELACIONADOS CON EL USUARIO QUE GENERA LA ALARMA
Retorno := fun_contact_getdata_string(COALESCE(EventROWDATA.idcontact, 0), 'AU', Retorno);
SELECT idaddress INTO IIdAddressContact FROM contacts WHERE idcontact = EventROWDATA.idcontact;
Retorno := fun_address_getdata_string(COALESCE(IIdAddressContact, 0), 'AUA', Retorno);
SELECT idlocation INTO IIdLocationContact FROM address WHERE idaddress = IIdAddressContact;
Retorno := fun_location_getdata_string(COALESCE(IIdLocationContact, 0), 'AUL', Retorno);


IF EventROWDATA.ideventtype = 72 THEN
-- Obtenemos el idphone que generó la alarma
SELECT idphone INTO Internalidphone FROM incomingcalls WHERE idincall = (SELECT idincall FROM usaga.events_generated_by_calls WHERE idevent = EventROWDATA.idevent);
END IF;

-- DATOS RELACIONADOS CON EL TELEFONO QUE GENERA LA ALARMA (En caso de ser una alarma tipo 72)
Retorno := fun_phone_getdata_string(Internalidphone, 'APU', Retorno);
SELECT idaddress INTO IIdAddressPhone FROM phones WHERE idphone = Internalidphone;
Retorno := fun_address_getdata_string(COALESCE(IIdAddressPhone, 0), 'APUA', Retorno);
SELECT idlocation INTO IIdLocationPhone FROM address WHERE idaddress = IIdAddressPhone;
Retorno := fun_location_getdata_string(COALESCE(IIdLocationContact, 0), 'APUL', Retorno);

-- DATOS RELACIONADOS CON EL EVENTO
Retorno := usaga.fun_events_getdata_string(inidevent, 'AE', Retorno);


RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_notification_gen_message(inidevent integer, insmstext text) OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 17506)
-- Dependencies: 986 6
-- Name: fun_notification_templates_edit(integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_notification_templates_edit(inidnotiftempl integer, indescription text, inmessage text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN

CASE

WHEN inidnotiftempl > 0 AND EXISTS(SELECT * FROM usaga.notification_templates WHERE idnotiftempl = inidnotiftempl) THEN
-- Actualizamos opensaga.notification_templates
UPDATE usaga.notification_templates SET description = indescription, message = inmessage WHERE idnotiftempl = inidnotiftempl RETURNING idnotiftempl INTO outreturn;
outpgmsg := 'Registro id '||outreturn::text||' fue actualizado';

WHEN inidnotiftempl < 0 THEN
-- Eliminamos el registro
DELETE FROM usaga.notification_templates WHERE idnotiftempl = abs(inidnotiftempl);
outpgmsg := 'Registro id '||abs(inidnotiftempl)::text||' fue eliminado';

WHEN inidnotiftempl = 0 THEN
-- Insertamos un nuevo registro
INSERT INTO usaga.notification_templates (description, message) VALUES (indescription, inmessage) RETURNING idnotiftempl INTO outreturn;
outpgmsg := 'Registro id '||outreturn::text||' fue creado';
END CASE;

IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;
RETURN;
END;$$;


ALTER FUNCTION usaga.fun_notification_templates_edit(inidnotiftempl integer, indescription text, inmessage text, ints timestamp without time zone, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 348 (class 1255 OID 17507)
-- Dependencies: 6 986
-- Name: fun_notification_templates_edit_xml(integer, text, text, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_notification_templates_edit_xml(inidnotiftempl integer, indescription text, inmessage text, ints timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_notification_templates_edit(inidnotiftempl , indescription , inmessage , ints, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;
$$;


ALTER FUNCTION usaga.fun_notification_templates_edit_xml(inidnotiftempl integer, indescription text, inmessage text, ints timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 349 (class 1255 OID 18803)
-- Dependencies: 986 6
-- Name: fun_periodic_functions(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_periodic_functions() RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE

r boolean DEFAULT true;

BEGIN

--PERFORM usaga.fun_event_insert(0, 'LOG', 0, 100, 'Hear Beat Receiver', 85, NOW()::timestamp without time zone, '', TRUE, FALSE);
PERFORM usaga.fun_event_future_to_notification_area();

RETURN r;
END;
$$;


ALTER FUNCTION usaga.fun_periodic_functions() OWNER TO postgres;

--
-- TOC entry 2948 (class 0 OID 0)
-- Dependencies: 349
-- Name: FUNCTION fun_periodic_functions(); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_periodic_functions() IS 'Funciones que se ejecutan en forma periodica.
Esta funcion es llamada desde uSAGA automaticamente en cada heart beat del servidor.';


--
-- TOC entry 357 (class 1255 OID 17508)
-- Dependencies: 986 6
-- Name: fun_receiver_from_incomingcall(bigint); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_receiver_from_incomingcall(id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE

--Retorno INTEGER DEFAULT 0;
--vcursor CURSOR FOR SELECT * FROM public.view_callin WHERE flag1=0 AND idphone > 0;
VROWDATA   public.view_callin%ROWTYPE;
IdAccountInternal INTEGER DEFAULT 0;

Internalfirstname TEXT DEFAULT '';
Internallastname TEXT DEFAULT '';
Internalphone TEXT DEFAULT '';
Internalidcontact INTEGER DEFAULT 0;

InternalAlarmPriority INTEGER DEFAULT 1;
Retorno BOOLEAN DEFAULT FALSE;

BEGIN

SELECT * INTO VROWDATA FROM public.view_callin WHERE idincall = id;

CASE 

-- Las llamadas NUEVAS (flag1 = 0) y sin idphone lo marcamos como sin propietario, para ignorarlos a futuro.
-- 3 = Telefono sin propietario
WHEN  VROWDATA.idphone < 1 AND VROWDATA.flag1 = 0 THEN

UPDATE incomingcalls SET flag1 = 3 WHERE idincall = VROWDATA.idincall;

IF tempidincall > 0 THEN

PERFORM usaga.fun_insert_system_log(100, 'Número telefónico '||VROWDATA.phone::text||' no está asignado a algún contacto. Obtenido de las llamadas entrantes registradas en uSMS.', '');
END IF;

-- Procesamos la llamada
WHEN VROWDATA.idphone > 0 AND VROWDATA.flag1 = 0 THEN

-- Obtenemos el IdAccount de la cuenta a la que pertenece ese idphone
SELECT idaccount INTO IdAccountInternal FROM usaga.view_account_phones_trigger_alarm WHERE idphone = VROWDATA.idphone AND enable = true AND trigger_enable = true AND fromcall = true LIMIT 1;

IF IdAccountInternal > 0 THEN 

-- Obtenemos la prioridad de la alarma segun su tipo
  InternalAlarmPriority := usaga.fun_get_priority_from_ideventtype(72);

-- Obtenemos los datos del contacto
SELECT idcontact, firstname, lastname, phone INTO Internalidcontact, Internalfirstname, Internallastname, Internalphone  FROM view_contacts_phones WHERE idphone = VROWDATA.idphone;

-- Marcamos la llamada como procesada
UPDATE public.incomingcalls SET flag1 = 1 WHERE idincall = VROWDATA.idincall;

-- Ingresamos el evento.
INSERT INTO usaga.events_generated_by_calls (idaccount, code, zu, priority, description, ideventtype, idincall, datetimeevent, idcontact) VALUES (IdAccountInternal, 'A-CALL', Internalidcontact, InternalAlarmPriority, 'ALARMA! ' || Internallastname || ' ' || Internalfirstname || ' [' || Internalphone::text || ']', 72, VROWDATA.idincall, VROWDATA.datecall, VROWDATA.idcontact); 

Retorno := TRUE;
        
ELSE
-- La llamada no pertenece a ningun abonado
UPDATE public.incomingcalls SET flag1 = 2 WHERE idincall = VROWDATA.idincall;
PERFORM usaga.fun_insert_system_log(100, 'Número telefónico '||VROWDATA.phone::text||' no pertenece a algún abonado del sistema. Obtenido de las llamadas entrantes de uSMS.', '');    
END IF;

ELSE


END CASE;




RETURN Retorno;
END;$$;


ALTER FUNCTION usaga.fun_receiver_from_incomingcall(id bigint) OWNER TO postgres;

--
-- TOC entry 358 (class 1255 OID 17509)
-- Dependencies: 6 986
-- Name: fun_receiver_from_incomingsmss(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_receiver_from_incomingsmss(OUT outsmss integer, OUT outeventsgenerated integer) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE


BEGIN


RETURN;
END;$$;


ALTER FUNCTION usaga.fun_receiver_from_incomingsmss(OUT outsmss integer, OUT outeventsgenerated integer) OWNER TO postgres;

--
-- TOC entry 396 (class 1255 OID 17510)
-- Dependencies: 6 986
-- Name: fun_view_account_byid_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_byid_xml(inidaccount integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idaccount, partition, enable, encode(account::bytea, 'base64') AS account, encode(name::bytea, 'base64') AS name, type, dateload, encode(note::bytea, 'base64') AS note, idgroup, idcontact, ts   FROM usaga.account  WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 20, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.account  WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 20, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;
--PERFORM usaga.fun_insert_internal_event(inidaccount, 'LOG', 100, 'Acceso a los datos de la cuenta id '||inidaccount::TEXT, 81, 1, '');
--PERFORM usaga.fun_event_insert(inidaccount, 'LOG', 0, 100, 'Acceso a los datos de la cuenta id '||inidaccount::TEXT, 81, NOW(), '', TRUE, FALSE);
--PERFORM usaga.fun_event_insert(inidaccount, 'LOG', 0, 100, 'Acceso a los datos de la cuenta id '||inidaccount::TEXT, 81, NOW()::timestamp without time zone, '', TRUE, FALSE);
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_byid_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 17511)
-- Dependencies: 986 6
-- Name: fun_view_account_contact_notif_eventtypes(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$DECLARE

CursorEventtypes refcursor; 

ROWDATAEventType   usaga.eventtypes%ROWTYPE;
ROWDATANET   usaga.account_notifications_eventtype%ROWTYPE;

InternalIdNotifAccount INTEGER DEFAULT 0;


BEGIN

SELECT usaga.account_notifications.idnotifaccount INTO InternalIdNotifAccount FROM usaga.account_notifications WHERE idphone = inidphone AND idaccount = inidaccount LIMIT 1;

IF InternalIdNotifAccount > 0 THEN

OPEN CursorEventtypes FOR SELECT * FROM usaga.eventtypes ORDER BY label;
    loop    

        FETCH CursorEventtypes INTO ROWDATAEventType;
        EXIT WHEN NOT FOUND;

IF EXISTS(SELECT usaga.account_notifications_eventtype.idnotifphoneeventtype FROM usaga.account_notifications_eventtype WHERE usaga.account_notifications_eventtype.idnotifaccount = InternalIdNotifAccount AND usaga.account_notifications_eventtype.ideventtype = ROWDATAEventType.ideventtype LIMIT 1) THEN
SELECT * INTO ROWDATANET FROM usaga.account_notifications_eventtype WHERE usaga.account_notifications_eventtype.idnotifaccount = InternalIdNotifAccount AND usaga.account_notifications_eventtype.ideventtype = ROWDATAEventType.ideventtype LIMIT 1;
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


ALTER FUNCTION usaga.fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 2949 (class 0 OID 0)
-- Dependencies: 359
-- Name: FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_view_account_contact_notif_eventtypes(inidaccount integer, inidphone integer, fieldtextasbase64 boolean, OUT idnotifaccount integer, OUT ideventtype integer, OUT enable boolean, OUT label text, OUT ts timestamp without time zone) IS 'Vista de los tipos de eventos habilitados para un determinado idaccountnotif';


--
-- TOC entry 360 (class 1255 OID 17512)
-- Dependencies: 986 6
-- Name: fun_view_account_contact_notif_eventtypes_xml(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_contact_notif_eventtypes_xml(inidaccount integer, inidphone integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_view_account_contact_notif_eventtypes(inidaccount, inidphone, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_view_account_contact_notif_eventtypes_xml(inidaccount integer, inidphone integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 361 (class 1255 OID 17513)
-- Dependencies: 986 6
-- Name: fun_view_account_contacts_address_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_contacts_address_xml(inidaccount integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, 
  enable, 
  encode(firstname::bytea, 'base64') AS firstname,
  encode(lastname::bytea, 'base64') AS lastname,
  encode(title::bytea, 'base64') AS title,
  geox, 
  geoy, 
  encode(field1::bytea, 'base64') AS field1,
  encode(field2::bytea, 'base64') AS field2,
  encode(field3::bytea, 'base64') AS field3,
  encode(field4::bytea, 'base64') AS field4,
  encode(field5::bytea, 'base64') AS field5,
  encode(field6::bytea, 'base64') AS field6,
  encode(field7::bytea, 'base64') AS field7,
  encode(field8::bytea, 'base64') AS field8,
  encode(field9::bytea, 'base64') AS field9,
  encode(field10::bytea, 'base64') AS field10,
  idaddress
FROM view_contacts_address WHERE idcontact IN (SELECT idcontact FROM  usaga.account_contacts WHERE idaccount = inidaccount);
  
SELECT * FROM cursor_to_xml(CursorResult, 20, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM view_contacts_address WHERE idcontact IN (SELECT idcontact FROM  usaga.account_contacts WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 20, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;
--PERFORM usaga.fun_insert_internal_event(inidaccount, 'LOG', 100, 'Acceso a los datos de la cuenta id '||inidaccount::TEXT, 81, 1, '');
RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_contacts_address_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 362 (class 1255 OID 17514)
-- Dependencies: 6 986
-- Name: fun_view_account_contacts_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_contacts_xml(inidaccount integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idaccount, idcontact, enable, encode(firstname::bytea, 'base64') AS firstname, encode(lastname::bytea, 'base64') AS lastname, prioritycontact, enable_as_contact, encode(appointment::bytea, 'base64') as appointment, ts FROM usaga.view_account_contacts WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.view_account_contacts WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_contacts_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 364 (class 1255 OID 17515)
-- Dependencies: 6 986
-- Name: fun_view_account_events_xml(integer, timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_events_xml(inidaccount integer, datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idevent, dateload, CASE WHEN idaccount IS NULL THEN '0' ELSE idaccount END AS idaccount, CASE WHEN partition IS NULL THEN '0' ELSE partition END AS partition, CASE WHEN enable IS NULL THEN 'false' ELSE enable END AS enable, CASE WHEN account IS NULL THEN encode('System'::bytea, 'base64') ELSE encode(account::bytea, 'base64') END AS account, CASE WHEN name IS NULL THEN encode('uSAGA'::bytea, 'base64') ELSE encode(name::bytea, 'base64') END AS name, CASE WHEN type IS NULL THEN '0' ELSE type END AS type, encode(code::bytea, 'base64') as code, zu, priority, encode(description::bytea, 'base64') as description, ideventtype, datetimeevent, encode(eventtype::bytea, 'base64') AS eventtype, process1, process2, process3, process4, process5, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5 FROM usaga.view_events WHERE idaccount = inidaccount AND dateload BETWEEN datestart AND dateend ORDER BY idevent DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idevent, dateload, CASE WHEN idaccount IS NULL THEN '0' ELSE idaccount END AS idaccount, CASE WHEN partition IS NULL THEN '0' ELSE partition END AS partition, CASE WHEN enable IS NULL THEN 'false' ELSE enable END AS enable, CASE WHEN account IS NULL THEN 'System' ELSE account END AS account, CASE WHEN name IS NULL THEN 'uSAGA' ELSE name END AS name, CASE WHEN type IS NULL THEN '0' ELSE type END AS type, code, zu, priority, description, ideventtype, eventtype, datetimeevent, process1, process2, process3, process4, process5, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5 FROM usaga.view_events WHERE idaccount = inidaccount AND dateload BETWEEN datestart AND dateend ORDER BY idevent DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_events_xml(inidaccount integer, datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 365 (class 1255 OID 17516)
-- Dependencies: 986 6
-- Name: fun_view_account_location_byid_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_location_byid_xml(inidaccount integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idaddress, geox, geoy  FROM address WHERE idaddress = (SELECT idaddress FROM usaga.account WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 20, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idaddress, geox, geoy  FROM address WHERE idaddress = (SELECT idaddress FROM usaga.account WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 20, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_location_byid_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 17517)
-- Dependencies: 986 6
-- Name: fun_view_account_notif_phones(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_notif_phones(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean, OUT idnotifcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT priority integer, OUT call boolean, OUT sms boolean, OUT smstext text, OUT note text, OUT ts timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

--CursorViewContactsPhonesAddress CURSOR FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
CursorViewContactsPhonesAddress refcursor; 

ROWDATAViewContact   public.view_contacts_phones%ROWTYPE;
ROWDATAAccNotif   usaga.account_notifications%ROWTYPE;

BEGIN

IF EXISTS(SELECT phones.idphone FROM phones WHERE phones.idcontact = inidcontact) THEN

OPEN CursorViewContactsPhonesAddress FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
    loop    

        FETCH CursorViewContactsPhonesAddress INTO ROWDATAViewContact;
        EXIT WHEN NOT FOUND;
--fieldtextasbase64
IF EXISTS(SELECT usaga.account_notifications.idnotifaccount FROM usaga.account_notifications WHERE usaga.account_notifications.idaccount = inidaccount AND usaga.account_notifications.idphone = ROWDATAViewContact.idphone LIMIT 1) THEN
SELECT * INTO ROWDATAAccNotif FROM usaga.account_notifications WHERE usaga.account_notifications.idaccount = inidaccount AND usaga.account_notifications.idphone = ROWDATAViewContact.idphone LIMIT 1;

IF fieldtextasbase64 THEN
RETURN QUERY SELECT ROWDATAAccNotif.idnotifaccount::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, encode(ROWDATAViewContact.phone::bytea, 'base64'), ROWDATAAccNotif.priority::integer, ROWDATAAccNotif.call::boolean, ROWDATAAccNotif.sms::boolean, encode(ROWDATAAccNotif.smstext::bytea, 'base64'), encode(ROWDATAAccNotif.note::bytea, 'base64'), ROWDATAAccNotif.ts::timestamp without time zone;
ELSE
RETURN QUERY SELECT ROWDATAAccNotif.idnotifaccount::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAAccNotif.priority::integer, ROWDATAAccNotif.call::boolean, ROWDATAAccNotif.sms::boolean, ROWDATAAccNotif.smstext::text, ROWDATAAccNotif.note::text, ROWDATAAccNotif.ts::timestamp without time zone;
END IF;

ELSE

IF fieldtextasbase64 THEN
RETURN QUERY SELECT '0'::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, encode(ROWDATAViewContact.phone::bytea, 'base64'), '0'::integer, 'false'::boolean, 'false'::boolean, ''::text, ''::text, '1990-01-01 00:00'::timestamp without time zone;
ELSE
RETURN QUERY SELECT '0'::integer, inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, '0'::integer, 'false'::boolean, 'false'::boolean, ''::text, ''::text, '1990-01-01 00:00'::timestamp without time zone;
END IF;



END IF;

    end loop;
    CLOSE CursorViewContactsPhonesAddress;

END IF;

END
$$;


ALTER FUNCTION usaga.fun_view_account_notif_phones(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean, OUT idnotifcontact integer, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT priority integer, OUT call boolean, OUT sms boolean, OUT smstext text, OUT note text, OUT ts timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 367 (class 1255 OID 17518)
-- Dependencies: 6 986
-- Name: fun_view_account_notif_phones_xml(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_notif_phones_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_view_account_notif_phones(inidaccount, inidcontact, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_view_account_notif_phones_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 368 (class 1255 OID 17519)
-- Dependencies: 986 6
-- Name: fun_view_account_to_list_search_xml(text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_to_list_search_xml(insearch text DEFAULT ''::text, fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idaccount, enable, partition, encode(usaga.account.account::bytea, 'base64') AS account, encode(usaga.account.name::bytea, 'base64') AS name  FROM usaga.account WHERE usaga.account.name ILIKE '%'||insearch::text||'%' OR usaga.account.account ILIKE '%'||insearch::text||'%' ORDER BY usaga.account.name, usaga.account.account;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT *  FROM usaga.account WHERE usaga.account.name ILIKE '%'||insearch::text||'%' OR usaga.account.account ILIKE '%'||insearch::text||'%' ORDER BY usaga.account.name, usaga.account.account;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_to_list_search_xml(insearch text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 369 (class 1255 OID 17520)
-- Dependencies: 6 986
-- Name: fun_view_account_unregistered_contacts_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_unregistered_contacts_xml(inidaccount integer, fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, enable, encode((lastname ||' '||firstname)::bytea, 'base64') AS name FROM contacts WHERE idcontact NOT IN (SELECT idcontact FROM usaga.account_contacts WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idcontact, enable, (lastname ||' '||firstname) AS name FROM contacts WHERE idcontact NOT IN (SELECT idcontact FROM usaga.account_contacts WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_unregistered_contacts_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 17521)
-- Dependencies: 986 6
-- Name: fun_view_account_unregistered_users_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_unregistered_users_xml(inidaccount integer, fieldtextasbase64 boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idcontact, enable, encode((lastname ||' '||firstname)::bytea, 'base64') AS name FROM contacts WHERE idcontact NOT IN (SELECT idcontact FROM usaga.account_users WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idcontact, enable, (lastname ||' '||firstname) AS name FROM contacts WHERE idcontact NOT IN (SELECT idcontact FROM usaga.account_users WHERE idaccount = inidaccount);
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_unregistered_users_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 371 (class 1255 OID 17522)
-- Dependencies: 6 986
-- Name: fun_view_account_user_byidaccountidcontact_xml(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_user_byidaccountidcontact_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idaccount, idcontact, encode(firstname::bytea, 'base64') AS firstname, encode(lastname::bytea, 'base64') AS lastname, prioritycontact, enable, encode(appointment::bytea, 'base64') AS appointment, enable_as_user, encode(keyword::bytea, 'base64') AS keyword, encode(pwd::bytea, 'base64') AS pwd, numuser, encode(note_user::bytea, 'base64') AS note_user, ts FROM usaga.view_account_users WHERE idaccount = inidaccount AND idcontact = inidcontact LIMIT 1;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM  usaga.view_account_users WHERE idaccount = inidaccount AND idcontact = inidcontact LIMIT 1;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_user_byidaccountidcontact_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 372 (class 1255 OID 17523)
-- Dependencies: 6 986
-- Name: fun_view_account_users_trigger_phones_contacts(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_users_trigger_phones_contacts(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT trigger_alarm boolean, OUT fromsms boolean, OUT fromcall boolean, OUT note text) RETURNS SETOF record
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorViewContactsPhonesAddress CURSOR FOR SELECT * FROM view_contacts_phones WHERE view_contacts_phones.idcontact = inidcontact;
ROWDATAViewContact   public.view_contacts_phones%ROWTYPE;
ROWDATAPhoneTrigger   usaga.account_phones_trigger_alarm%ROWTYPE;
BEGIN


OPEN CursorViewContactsPhonesAddress;
    loop    

        FETCH CursorViewContactsPhonesAddress INTO ROWDATAViewContact;
        EXIT WHEN NOT FOUND;

IF EXISTS(SELECT usaga.account_phones_trigger_alarm.enable FROM usaga.account_phones_trigger_alarm WHERE usaga.account_phones_trigger_alarm.idaccount = inidaccount AND usaga.account_phones_trigger_alarm.idphone = ROWDATAViewContact.idphone LIMIT 1) THEN
SELECT * INTO ROWDATAPhoneTrigger FROM usaga.account_phones_trigger_alarm WHERE usaga.account_phones_trigger_alarm.idaccount = inidaccount AND usaga.account_phones_trigger_alarm.idphone = ROWDATAViewContact.idphone LIMIT 1;

IF fieldtextasbase64 THEN
RETURN QUERY SELECT inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, encode(ROWDATAViewContact.phone::text::bytea, 'base64')::text, ROWDATAPhoneTrigger.enable::boolean, ROWDATAPhoneTrigger.fromsms::boolean, ROWDATAPhoneTrigger.fromcall::boolean, encode(ROWDATAPhoneTrigger.note::text::bytea, 'base64')::text;
ELSE
RETURN QUERY SELECT inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, ROWDATAPhoneTrigger.enable::boolean, ROWDATAPhoneTrigger.fromsms::boolean, ROWDATAPhoneTrigger.fromcall::boolean, ROWDATAPhoneTrigger.note::text;
END IF;



ELSE
IF fieldtextasbase64 THEN
RETURN QUERY SELECT inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, encode(ROWDATAViewContact.phone::text::bytea, 'base64'), 'false'::boolean, 'false'::boolean, 'false'::boolean, encode(''::bytea, 'base64')::text;
ELSE
RETURN QUERY SELECT inidaccount::integer, ROWDATAViewContact.idcontact::integer, ROWDATAViewContact.idphone::integer, ROWDATAViewContact.phone_enable::boolean, ROWDATAViewContact.type::integer, ROWDATAViewContact.idprovider::integer, ROWDATAViewContact.phone::text, 'false'::boolean, 'false'::boolean, 'false'::boolean, ''::text;
END IF;


END IF;

    end loop;
    CLOSE CursorViewContactsPhonesAddress;


END;
$$;


ALTER FUNCTION usaga.fun_view_account_users_trigger_phones_contacts(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean, OUT idaccount integer, OUT idcontact integer, OUT idphone integer, OUT phone_enable boolean, OUT type integer, OUT idprovider integer, OUT phone text, OUT trigger_alarm boolean, OUT fromsms boolean, OUT fromcall boolean, OUT note text) OWNER TO postgres;

--
-- TOC entry 373 (class 1255 OID 17524)
-- Dependencies: 6 986
-- Name: fun_view_account_users_trigger_phones_contacts_xml(integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_users_trigger_phones_contacts_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $$DECLARE

CursorResultado refcursor; 
Retorno TEXT DEFAULT '';

BEGIN
OPEN CursorResultado FOR SELECT * FROM usaga.fun_view_account_users_trigger_phones_contacts(inidaccount, inidcontact, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 1000, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.fun_view_account_users_trigger_phones_contacts_xml(inidaccount integer, inidcontact integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 374 (class 1255 OID 17525)
-- Dependencies: 986 6
-- Name: fun_view_account_users_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_account_users_xml(inidaccount integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idaccount, idcontact, prioritycontact, enable, encode(firstname::bytea, 'base64') AS firstname, encode(lastname::bytea, 'base64') AS lastname, encode(appointment::bytea, 'base64') AS appointment, enable_as_user, numuser FROM usaga.view_account_users WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM  usaga.view_account_users WHERE idaccount = inidaccount;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_account_users_xml(inidaccount integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 36001)
-- Dependencies: 6 986
-- Name: fun_view_accounts_events_only_idevents(integer[], integer[], timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_accounts_events_only_idevents(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno bigint[] DEFAULT '{}'::bigint[];
CursorResult refcursor;

BEGIN

RETURN array(SELECT idevent FROM usaga.events WHERE idaccount = ANY(inidaccounts) AND ideventtype = ANY(ineventtypes) AND (datetimeevent BETWEEN datestart AND dateend) ORDER BY datetimeevent);

END;$$;


ALTER FUNCTION usaga.fun_view_accounts_events_only_idevents(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 428 (class 1255 OID 36002)
-- Dependencies: 986 6
-- Name: fun_view_accounts_events_only_idevents_xml(integer[], integer[], timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_accounts_events_only_idevents_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

OPEN CursorResult FOR SELECT * FROM fun_view_accounts_events_only_idevents(inidaccounts, ineventtypes, datestart, dateend);
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_accounts_events_only_idevents_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 426 (class 1255 OID 35977)
-- Dependencies: 6 986
-- Name: fun_view_accounts_events_reports_xml(integer[], integer[], timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_accounts_events_reports_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT * FROM usaga.view_events_fieldtextasb64 WHERE idaccount = ANY(inidaccounts) AND datetimeevent BETWEEN datestart AND dateend ORDER BY datetimeevent;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.view_events WHERE idaccount = ANY(inidaccounts) AND datetimeevent BETWEEN datestart AND dateend ORDER BY datetimeevent;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_accounts_events_reports_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 388 (class 1255 OID 18574)
-- Dependencies: 986 6
-- Name: fun_view_accounts_list_xml(boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_accounts_list_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idaccount, encode((name||'   ['||account||']')::bytea, 'base64') AS label  FROM usaga.account ORDER BY usaga.account.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT  idaccount, (name||'   ['||account||']') AS label  FROM usaga.account ORDER BY usaga.account.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_accounts_list_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 397 (class 1255 OID 18563)
-- Dependencies: 986 6
-- Name: fun_view_events_comments_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_events_comments_xml(inidevent integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

-- TODO: quote_literal
OPEN CursorResult FOR SELECT  idcomment, idevent, idstatusevent, idadmin, ts, date_start, date_end, tob64(comment) AS comment, extract(epoch from (date_end - date_start)) as seconds, fun_attachments_rows_as_json(attachments) as files  FROM usaga.events_comments WHERE idevent = inidevent ORDER BY date_start DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT  * FROM usaga.events_comments WHERE idevent = inidevent ORDER BY date_start DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;



RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_events_comments_xml(inidevent integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 419 (class 1255 OID 35636)
-- Dependencies: 986 6
-- Name: fun_view_events_system(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_events_system() RETURNS TABLE(idevent bigint, dateload timestamp without time zone, idaccount integer, partition integer, enable boolean, account text, name text, type integer, code text, zu integer, priority integer, description text, ideventtype integer, eventtype text, datetimeevent timestamp without time zone, status integer, last_comment_time double precision)
    LANGUAGE plpgsql
    AS $$DECLARE 
    R record;
	--evcm usaga.events_comments%ROWTYPE;
	_last_status_event integer default 0;
	_end_comment_datetime timestamp with time zone;
BEGIN
     FOR R IN(

 SELECT *  FROM usaga.events
	LEFT JOIN usaga.account ON events.idaccount = account.idaccount
	--LEFT JOIN usaga.events_comments ON events.idevent = events_comments.idevent

)  
     LOOP
            idevent := R.idevent;
		dateload := R.dateload;
		idaccount := R.idaccount;
		partition := CASE WHEN R.partition IS NULL THEN 0 ELSE R.partition END;
		enable := CASE WHEN R.enable IS NULL THEN false ELSE R.enable END;
		name := CASE WHEN R.name IS NULL THEN 'uSAGA' ELSE R.name END;
		account := CASE WHEN R.account IS NULL THEN 'uSAGA' ELSE R.account END;
		type := CASE WHEN R.type IS NULL THEN 0 ELSE R.type END;
		code := R.code;
		zu := R.zu;
		priority := R.priority;
		description := R.description;
		ideventtype := R.ideventtype;
		SELECT label INTO eventtype FROM usaga.eventtypes WHERE eventtypes.ideventtype = R.ideventtype LIMIT 1;
		datetimeevent := R.datetimeevent;
		SELECT idstatusevent, date_end INTO _last_status_event, _end_comment_datetime FROM usaga.events_comments WHERE events_comments.idevent = R.idevent ORDER BY events_comments.idcomment DESC LIMIT 1;
		status := CASE WHEN _last_status_event IS NULL THEN 0 ELSE _last_status_event END;
		last_comment_time := CASE WHEN _end_comment_datetime IS NULL THEN -1 ELSE date_part('epoch'::text, age(now(), _end_comment_datetime)) / 60 END;


            RETURN NEXT;
     END LOOP;
END;
$$;


ALTER FUNCTION usaga.fun_view_events_system() OWNER TO postgres;

--
-- TOC entry 400 (class 1255 OID 18614)
-- Dependencies: 6 986
-- Name: fun_view_events_xml(integer[], timestamp without time zone, timestamp without time zone, integer, integer, integer[], integer[], integer, integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_events_xml(inidaccounts integer[], datestart timestamp without time zone, dateend timestamp without time zone, infunction integer, inrows integer, inideventtypes integer[], instatus integer[], inprioritymin integer, inprioritymax integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

CASE
-- Devuelve los eventos de esa cuenta
WHEN infunction = 0 AND inidaccounts[1] > 0 THEN

IF fieldtextasbase64 THEN
OPEN CursorResult FOR SELECT * FROM usaga.view_events_fieldtextasb64 WHERE idaccount = inidaccounts[1] AND datetimeevent BETWEEN datestart AND dateend ORDER BY datetimeevent DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
ELSE
OPEN CursorResult FOR SELECT * FROM usaga.view_events WHERE idaccount = inidaccounts[1] AND datetimeevent BETWEEN datestart AND dateend ORDER BY datetimeevent DESC;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
END IF;

-- Devuelve los ultimos X eventos registrados ordenados por datetimeevent
WHEN infunction = 1 THEN

IF fieldtextasbase64 THEN
OPEN CursorResult FOR SELECT * FROM usaga.view_events_fieldtextasb64 ORDER BY datetimeevent DESC LIMIT inrows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
ELSE
OPEN CursorResult FOR SELECT * FROM usaga.view_events ORDER BY datetimeevent DESC LIMIT inrows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
END IF;

-- Devuelve todos los eventos que no hay sido finalizados de todas las cuentas
WHEN infunction = 2 THEN

IF fieldtextasbase64 THEN
OPEN CursorResult FOR SELECT * FROM usaga.view_events_fieldtextasb64 WHERE status = 0 ORDER BY datetimeevent;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
ELSE
OPEN CursorResult FOR SELECT * FROM usaga.view_events WHERE status = 0 ORDER BY datetimeevent;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
END IF;

-- Aplica todos los filtros
WHEN infunction = 3 THEN

IF fieldtextasbase64 THEN
OPEN CursorResult FOR SELECT * FROM usaga.view_events_fieldtextasb64 WHERE idaccount = ANY(inidaccounts) AND status = ANY(instatus) AND datetimeevent BETWEEN datestart AND dateend ORDER BY datetimeevent DESC LIMIT inrows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
ELSE
OPEN CursorResult FOR SELECT * FROM usaga.view_events WHERE status = 0 AND datetimeevent BETWEEN datestart AND dateend ORDER BY datetimeevent DESC  LIMIT inrows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;
END IF;

ELSE
-- No devuelve datos
END CASE;





RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_events_xml(inidaccounts integer[], datestart timestamp without time zone, dateend timestamp without time zone, infunction integer, inrows integer, inideventtypes integer[], instatus integer[], inprioritymin integer, inprioritymax integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 375 (class 1255 OID 17527)
-- Dependencies: 986 6
-- Name: fun_view_eventtypes_xml(boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_eventtypes_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  ideventtype, encode(name::bytea, 'base64') AS name, priority, accountdefault, groupdefault, encode(label::bytea, 'base64') AS label, encode(note::bytea, 'base64') AS note, manual, treatment, ts, enable_datetime, encode(na_img::bytea, 'base64') AS na_img, encode(na_snd::bytea, 'base64') AS na_snd, na_timeout, na_closable FROM usaga.eventtypes ORDER BY usaga.eventtypes.label, usaga.eventtypes.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.eventtypes ORDER BY usaga.eventtypes.label, usaga.eventtypes.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_eventtypes_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 376 (class 1255 OID 17528)
-- Dependencies: 6 986
-- Name: fun_view_groups_xml(boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_groups_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idgroup, enable, encode(name::bytea, 'base64') AS name, encode(note::bytea, 'base64') AS note, ts FROM usaga.groups ORDER BY usaga.groups.name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.groups ORDER BY name;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_groups_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 363 (class 1255 OID 17530)
-- Dependencies: 986 6
-- Name: fun_view_idgroup_name_xml(boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_idgroup_name_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT  idgroup, encode(name::bytea, 'base64') AS name FROM usaga.groups ORDER BY idgroup;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idgroup, name FROM usaga.groups ORDER BY idgroup;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_idgroup_name_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 377 (class 1255 OID 17531)
-- Dependencies: 986 6
-- Name: fun_view_last_events_xml(integer, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idevent, dateload, CASE WHEN idaccount IS NULL THEN '0' ELSE idaccount END AS idaccount, CASE WHEN partition IS NULL THEN '0' ELSE partition END AS partition, CASE WHEN enable IS NULL THEN 'false' ELSE enable END AS enable, CASE WHEN account IS NULL THEN encode('System'::bytea, 'base64') ELSE encode(account::bytea, 'base64') END AS account, CASE WHEN name IS NULL THEN encode('uSAGA'::bytea, 'base64') ELSE encode(name::bytea, 'base64') END AS name, CASE WHEN type IS NULL THEN '0' ELSE type END AS type, encode(code::bytea, 'base64') as code, zu, priority, encode(description::bytea, 'base64') as description, ideventtype, datetimeevent, encode(eventtype::bytea, 'base64') AS eventtype, process1, process2, process3, process4, process5, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5 FROM usaga.view_events ORDER BY idevent DESC LIMIT rows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT idevent, dateload, CASE WHEN idaccount IS NULL THEN '0' ELSE idaccount END AS idaccount, CASE WHEN partition IS NULL THEN '0' ELSE partition END AS partition, CASE WHEN enable IS NULL THEN 'false' ELSE enable END AS enable, CASE WHEN account IS NULL THEN 'System' ELSE account END AS account, CASE WHEN name IS NULL THEN 'uSAGA' ELSE name END AS name, CASE WHEN type IS NULL THEN '0' ELSE type END AS type, code, zu, priority, description, ideventtype, eventtype, datetimeevent, process1, process2, process3, process4, process5, dateprocess1, dateprocess2, dateprocess3, dateprocess4, dateprocess5 FROM usaga.view_events ORDER BY idevent DESC LIMIT rows;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 2950 (class 0 OID 0)
-- Dependencies: 377
-- Name: FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION fun_view_last_events_xml(rows integer, fieldtextasbase64 boolean) IS 'Muestra los ultimos eventos registrados en formato xml';


--
-- TOC entry 378 (class 1255 OID 17532)
-- Dependencies: 986 6
-- Name: fun_view_notification_templates_xml(boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION fun_view_notification_templates_xml(fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN

IF fieldtextasbase64 THEN

OPEN CursorResult FOR SELECT idnotiftempl, encode(description::bytea, 'base64') AS description, encode(message::bytea, 'base64') AS message, ts FROM usaga.notification_templates;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

ELSE

OPEN CursorResult FOR SELECT * FROM usaga.notification_templates;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

END IF;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.fun_view_notification_templates_xml(fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 379 (class 1255 OID 17533)
-- Dependencies: 6 986
-- Name: hearbeat(); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION hearbeat() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$BEGIN

--INSERT INTO usaga.events (code, priority, description, ideventtype) VALUES ('SYS', 100, 'Hear Beat Receiver', 88);
PERFORM usaga.fun_event_insert(0, 'LOG', 0, 99, 'Hear Beat Receiver', 85, NOW()::timestamp without time zone, '', TRUE, FALSE);

RETURN now();
END;$$;


ALTER FUNCTION usaga.hearbeat() OWNER TO postgres;

--
-- TOC entry 2951 (class 0 OID 0)
-- Dependencies: 379
-- Name: FUNCTION hearbeat(); Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON FUNCTION hearbeat() IS 'Genera un evento de funcionmiento de la receptora';


--
-- TOC entry 421 (class 1255 OID 35838)
-- Dependencies: 6 986
-- Name: xxxfun_accounts_edit(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, integer, integer, boolean, text, text, integer, timestamp without time zone, text, integer, integer, integer[], text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION xxxfun_accounts_edit(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, insecurity_contacts integer[], innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE

BEGIN

IF NOT EXISTS(SELECT * FROM address WHERE idaddress = inidaddress) THEN
inidaddress := null;
END IF;

CASE
	WHEN EXISTS(SELECT idcontact FROM contacts WHERE identification = inidentification AND typeofid = intypeofid AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El numero de identification ya existe en otro contacto
outreturn := abs(inidcontact);
outpgmsg := 'El número de identificación '||inidentification::text||' tipo '||intypeofid::text||' ya existe en otro contacto, verifique los datos';

	WHEN EXISTS(SELECT idcontact FROM contacts WHERE upper(trim(firstname)) = upper(trim(infirstname)) AND upper(trim(lastname)) = upper(trim(inlastname)) AND NOT idcontact = inidcontact) AND inidcontact >= 0 THEN
-- El nombre ya existe en otra cuenta
outreturn := abs(inidcontact);
outpgmsg := 'El nombre '||infirstname::text||' '||inlastname::text||' ya existe, utilice otro nombre';

	WHEN (length(infirstname) < 1 OR length(inlastname) < 1) AND inidcontact >= 0  THEN
-- Nombre y apellido no pueden estar vacios
outreturn := abs(inidcontact);
outpgmsg := 'El campo nombre y apellido no pueden estar vacios.';

	WHEN inidcontact > 0 AND EXISTS(SELECT * FROM contacts WHERE idcontact = inidcontact) THEN
-- Actualiza si el contacto existe
UPDATE contacts SET enable = inenable, title = intitle, firstname =infirstname, lastname = inlastname, gender = ingender, birthday = inbirthday, typeofid = intypeofid, identification = inidentification, web = inweb, email1 = inemail1, email2 = inemail2, note = innote, idaddress = inidaddress WHERE idcontact = inidcontact RETURNING idcontact INTO outreturn;
outpgmsg := 'idcontact '||inidcontact::text||' actualizado.';

	WHEN inidcontact = 0 THEN
-- Insertamos un nuevo registro
INSERT INTO contacts (enable, title, firstname, lastname, gender, birthday, typeofid, identification, web, email1, email2, note) VALUES (inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, innote) RETURNING idcontact INTO outreturn;
outpgmsg := 'idcontact '||outreturn::text||' creado.';


	WHEN inidcontact < 0 THEN
-- Eliminamos el registro de direccion
DELETE FROM address WHERE idaddress = (SELECT idaddress FROM contacts WHERE idcontact = abs(inidcontact));
-- Eliminamos el contacto
DELETE FROM contacts WHERE idcontact = abs(inidcontact);
outreturn := 0;
outpgmsg := 'idcontact '||inidcontact::text||' eliminado.';

ELSE
outreturn := abs(inidcontact);
outpgmsg := 'Ninguna accion realizada';
END CASE;




IF fieldtextasbase64 THEN
outpgmsg := encode(outpgmsg::bytea, 'base64');
END IF;

RETURN;
END;$$;


ALTER FUNCTION usaga.xxxfun_accounts_edit(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, insecurity_contacts integer[], innote text, fieldtextasbase64 boolean, OUT outreturn integer, OUT outpgmsg text) OWNER TO postgres;

--
-- TOC entry 422 (class 1255 OID 35839)
-- Dependencies: 6 986
-- Name: xxxfun_accounts_edit_xml(integer, boolean, text, text, text, integer, date, integer, text, text, text, text, integer, integer, boolean, text, text, integer, timestamp without time zone, text, integer, integer, integer[], text, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION xxxfun_accounts_edit_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, insecurity_contacts integer[], innote text, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

CursorResultado refcursor;
Retorno TEXT DEFAULT '';

BEGIN

OPEN CursorResultado FOR SELECT * FROM usaga.fun_accounts_edit(inidcontact, inenable, intitle, infirstname, inlastname, ingender, inbirthday, intypeofid, inidentification, inweb, inemail1, inemail2, inidaddress, inpartition, inaccount_enable, inaccount_number, inaccount_name, inidaccounttype, ininstalation_date, ininstaller_code, inidpanelmodel, inidcommunicationformat, insecurity_contacts,  innote, fieldtextasbase64);
SELECT * FROM cursor_to_xml(CursorResultado, 10, false, false, '') INTO Retorno;
CLOSE CursorResultado;
RETURN '<table>'||Retorno||'</table>';
END;$$;


ALTER FUNCTION usaga.xxxfun_accounts_edit_xml(inidcontact integer, inenable boolean, intitle text, infirstname text, inlastname text, ingender integer, inbirthday date, intypeofid integer, inidentification text, inweb text, inemail1 text, inemail2 text, inidaddress integer, inpartition integer, inaccount_enable boolean, inaccount_number text, inaccount_name text, inidaccounttype integer, ininstalation_date timestamp without time zone, ininstaller_code text, inidpanelmodel integer, inidcommunicationformat integer, insecurity_contacts integer[], innote text, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 434 (class 1255 OID 35995)
-- Dependencies: 6 986
-- Name: xxxxfun_view_accounts_events_only_idevents(integer[], integer[], timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION xxxxfun_view_accounts_events_only_idevents(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno bigint[] DEFAULT '{}'::bigint[];
CursorResult refcursor;

BEGIN


RETURN array(
SELECT idevent 
FROM 
usaga.events 
WHERE 
idaccount = ANY(inidaccounts) 
AND
ideventtype = ANY(ineventtypes) 
AND
 (datetimeevent BETWEEN datestart AND dateend) 
ORDER BY datetimeevent);

END;$$;


ALTER FUNCTION usaga.xxxxfun_view_accounts_events_only_idevents(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 435 (class 1255 OID 35994)
-- Dependencies: 6 986
-- Name: xxxxfun_view_accounts_events_only_idevents_xml(integer[], integer[], timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION xxxxfun_view_accounts_events_only_idevents_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) RETURNS integer[]
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno integer[] DEFAULT '{}'::integer[];
CursorResult refcursor;

BEGIN

RETURN array(SELECT idevent FROM usaga.view_events_fieldtextasb64 WHERE idaccount IN(inidaccounts) AND (datetimeevent BETWEEN datestart AND dateend) ORDER BY datetimeevent);

--OPEN CursorResult FOR SELECT idevent FROM usaga.view_events_fieldtextasb64 WHERE idaccount IN(inidaccounts) AND (datetimeevent BETWEEN datestart AND dateend) ORDER BY datetimeevent;
--SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
--CLOSE CursorResult;

--RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.xxxxfun_view_accounts_events_only_idevents_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 425 (class 1255 OID 35993)
-- Dependencies: 986 6
-- Name: xxxxxfun_view_accounts_events_only_idevents_xml(integer[], integer[], timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION xxxxxfun_view_accounts_events_only_idevents_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE

Retorno TEXT DEFAULT '';
CursorResult refcursor;

BEGIN


OPEN CursorResult FOR SELECT idevent FROM usaga.view_events_fieldtextasb64 WHERE idaccount IN(inidaccounts) AND (datetimeevent BETWEEN datestart AND dateend) ORDER BY datetimeevent;
SELECT * FROM cursor_to_xml(CursorResult, 1000, false, false, '') INTO Retorno;
CLOSE CursorResult;

RETURN '<table>'||Retorno||'</table>';

END;$$;


ALTER FUNCTION usaga.xxxxxfun_view_accounts_events_only_idevents_xml(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone, fieldtextasbase64 boolean) OWNER TO postgres;

--
-- TOC entry 437 (class 1255 OID 35999)
-- Dependencies: 6 986
-- Name: xxxxxxfun_view_accounts_events_only_idevents(integer[], integer[], timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: usaga; Owner: postgres
--

CREATE FUNCTION xxxxxxfun_view_accounts_events_only_idevents(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$DECLARE

--Retorno bigint[] DEFAULT '{}'::bigint[];
CursorResult refcursor;

BEGIN

RETURN QUERY SELECT idevent FROM usaga.events WHERE idaccount = ANY(inidaccounts) AND ideventtype = ANY(ineventtypes) AND (datetimeevent BETWEEN datestart AND dateend) ORDER BY datetimeevent;
--RETURN array(SELECT idevent FROM usaga.events WHERE idaccount = ANY(inidaccounts) AND ideventtype = ANY(ineventtypes) AND (datetimeevent BETWEEN datestart AND dateend) ORDER BY datetimeevent);

END;$$;


ALTER FUNCTION usaga.xxxxxxfun_view_accounts_events_only_idevents(inidaccounts integer[], ineventtypes integer[], datestart timestamp without time zone, dateend timestamp without time zone) OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 162 (class 1259 OID 17537)
-- Dependencies: 2249 2250 2251 2252 7
-- Name: address; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address (
    idaddress bigint NOT NULL,
    geox double precision DEFAULT 0 NOT NULL,
    geoy double precision DEFAULT 0 NOT NULL,
    field1 text,
    field2 text,
    field3 text,
    field4 text,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    field5 text,
    field6 text,
    field7 text,
    field8 text,
    field9 text,
    field10 text,
    idlocation integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.address OWNER TO postgres;

--
-- TOC entry 2952 (class 0 OID 0)
-- Dependencies: 162
-- Name: TABLE address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE address IS 'Tabla de Direcciones, contiene todas las direcciones de las diferentes tablas.';


--
-- TOC entry 2953 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN address.field1; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN address.field1 IS 'Calle principal';


--
-- TOC entry 2954 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN address.field2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN address.field2 IS 'Calle secundaria';


--
-- TOC entry 2955 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN address.field3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN address.field3 IS 'Otros detalles';


--
-- TOC entry 163 (class 1259 OID 17547)
-- Dependencies: 2255 7
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE admin (
    idadmin bigint NOT NULL,
    ts timestamp without time zone,
    enable boolean DEFAULT false,
    idcontact integer,
    pwd text NOT NULL
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- TOC entry 2956 (class 0 OID 0)
-- Dependencies: 163
-- Name: TABLE admin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE admin IS 'Administradores del sistema';


--
-- TOC entry 2957 (class 0 OID 0)
-- Dependencies: 163
-- Name: COLUMN admin.idcontact; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN admin.idcontact IS 'Id del contacto asociado';


--
-- TOC entry 164 (class 1259 OID 17551)
-- Dependencies: 7 163
-- Name: admin_idadmin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE admin_idadmin_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_idadmin_seq OWNER TO postgres;

--
-- TOC entry 2958 (class 0 OID 0)
-- Dependencies: 164
-- Name: admin_idadmin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE admin_idadmin_seq OWNED BY admin.idadmin;


--
-- TOC entry 244 (class 1259 OID 35538)
-- Dependencies: 2547 7
-- Name: attachments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attachments (
    idattach bigint NOT NULL,
    date timestamp without time zone DEFAULT now(),
    file text,
    md5 text
);


ALTER TABLE public.attachments OWNER TO postgres;

--
-- TOC entry 2959 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE attachments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE attachments IS 'Archivos adjuntos del sistema';


--
-- TOC entry 243 (class 1259 OID 35536)
-- Dependencies: 244 7
-- Name: attachments_idattach_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attachments_idattach_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attachments_idattach_seq OWNER TO postgres;

--
-- TOC entry 2960 (class 0 OID 0)
-- Dependencies: 243
-- Name: attachments_idattach_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE attachments_idattach_seq OWNED BY attachments.idattach;


--
-- TOC entry 165 (class 1259 OID 17553)
-- Dependencies: 2256 2257 7
-- Name: blacklist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blacklist (
    idbl integer NOT NULL,
    idphone integer DEFAULT 0,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.blacklist OWNER TO postgres;

--
-- TOC entry 2961 (class 0 OID 0)
-- Dependencies: 165
-- Name: TABLE blacklist; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE blacklist IS 'Lista de numeros a los que no se enviaran sms.';


--
-- TOC entry 166 (class 1259 OID 17561)
-- Dependencies: 165 7
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
-- TOC entry 2962 (class 0 OID 0)
-- Dependencies: 166
-- Name: blacklist_idbl_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blacklist_idbl_seq OWNED BY blacklist.idbl;


--
-- TOC entry 167 (class 1259 OID 17563)
-- Dependencies: 2259 2260 2261 2262 2263 2264 2265 2266 2267 2268 2269 2270 2271 2273 7
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE contacts (
    idcontact integer NOT NULL,
    enable boolean DEFAULT true,
    firstname text DEFAULT 'nombre'::text NOT NULL,
    lastname text DEFAULT ' '::text NOT NULL,
    gender integer DEFAULT 0 NOT NULL,
    birthday date DEFAULT '1900-01-01'::date NOT NULL,
    typeofid integer DEFAULT 0 NOT NULL,
    identification text DEFAULT ''::text,
    web text DEFAULT ''::text NOT NULL,
    email1 text DEFAULT ''::text NOT NULL,
    email2 text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    title text DEFAULT 'Sr@'::text NOT NULL,
    idaddress integer,
    idgroup1 integer,
    idgroup2 integer,
    idgroup3 integer,
    groups integer[],
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- TOC entry 2963 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE contacts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE contacts IS 'Datos basicos de contactos';


--
-- TOC entry 168 (class 1259 OID 17582)
-- Dependencies: 167 7
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
-- TOC entry 2964 (class 0 OID 0)
-- Dependencies: 168
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.idcontact;


--
-- TOC entry 169 (class 1259 OID 17584)
-- Dependencies: 2274 2275 2276 7
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
-- TOC entry 2965 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE currentportsproviders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE currentportsproviders IS 'Tabla de relacion entre puertos y proveedor que estan usando actualmente';


--
-- TOC entry 2966 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN currentportsproviders.idport; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.idport IS 'IdPort, dato proveniente de la tabla serialport de usmsd.sqlite';


--
-- TOC entry 2967 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN currentportsproviders.port; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.port IS 'Dato proveniente de la tabla serialport de usmsd.sqlite';


--
-- TOC entry 2968 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN currentportsproviders.cimi; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.cimi IS 'Dato proveniente del modem';


--
-- TOC entry 2969 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN currentportsproviders.imei; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.imei IS 'Dato proveniente del modem';


--
-- TOC entry 2970 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN currentportsproviders.idprovider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.idprovider IS 'Dato proveniente de la tabla provider usndo como referencia el campo cimi para obtenerlo.';


--
-- TOC entry 2971 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN currentportsproviders.lastupdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN currentportsproviders.lastupdate IS 'Fecha de la ultima actualizacion. Si este campo exede de 2 minuto en relacion a la fecha actual deberia eliminarse.';


--
-- TOC entry 236 (class 1259 OID 18422)
-- Dependencies: 2526 2527 2528 2529 7
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE groups (
    idgroup bigint NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    name text DEFAULT 'group'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- TOC entry 2972 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE groups; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE groups IS 'Grupos';


--
-- TOC entry 235 (class 1259 OID 18420)
-- Dependencies: 7 236
-- Name: groups_idgroup_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE groups_idgroup_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_idgroup_seq OWNER TO postgres;

--
-- TOC entry 2973 (class 0 OID 0)
-- Dependencies: 235
-- Name: groups_idgroup_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE groups_idgroup_seq OWNED BY groups.idgroup;


--
-- TOC entry 170 (class 1259 OID 17593)
-- Dependencies: 2277 2278 2279 2280 2281 2282 2283 2284 2285 2286 2287 7
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
-- TOC entry 2974 (class 0 OID 0)
-- Dependencies: 170
-- Name: TABLE incomingcalls; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE incomingcalls IS 'Registro de llamadas entrantes';


--
-- TOC entry 2975 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN incomingcalls.datecall; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN incomingcalls.datecall IS 'Fecha de recepcion de la llamada.';


--
-- TOC entry 2976 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN incomingcalls.idport; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN incomingcalls.idport IS 'Idport por el cual se recibio la llamada.';


--
-- TOC entry 2977 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN incomingcalls.callaction; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN incomingcalls.callaction IS 'Accion tomada ante esa llamada: ignorada, rechazada, contestada';


--
-- TOC entry 171 (class 1259 OID 17610)
-- Dependencies: 170 7
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
-- TOC entry 2978 (class 0 OID 0)
-- Dependencies: 171
-- Name: incomingcalls_idincall_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE incomingcalls_idincall_seq OWNED BY incomingcalls.idincall;


--
-- TOC entry 172 (class 1259 OID 17612)
-- Dependencies: 162 7
-- Name: loc_level1_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loc_level1_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loc_level1_seq OWNER TO postgres;

--
-- TOC entry 2979 (class 0 OID 0)
-- Dependencies: 172
-- Name: loc_level1_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loc_level1_seq OWNED BY address.idaddress;


--
-- TOC entry 173 (class 1259 OID 17614)
-- Dependencies: 2289 2290 2291 2292 7
-- Name: location_level1; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location_level1 (
    idl1 bigint DEFAULT nextval('loc_level1_seq'::regclass) NOT NULL,
    name text DEFAULT 'country'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.location_level1 OWNER TO postgres;

--
-- TOC entry 2980 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE location_level1; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE location_level1 IS 'Nivel 1.
Usarlo preferentemente para el pais';


--
-- TOC entry 174 (class 1259 OID 17624)
-- Dependencies: 173 7
-- Name: loc_level5_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loc_level5_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loc_level5_seq OWNER TO postgres;

--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 174
-- Name: loc_level5_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loc_level5_seq OWNED BY location_level1.idl1;


--
-- TOC entry 175 (class 1259 OID 17626)
-- Dependencies: 2293 2294 2295 1917 1917 7
-- Name: location_level5; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location_level5 (
    idl5 bigint DEFAULT nextval('loc_level5_seq'::regclass) NOT NULL,
    idl4 integer,
    name text COLLATE pg_catalog."C.UTF-8" DEFAULT 'sector'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    code text COLLATE pg_catalog."C.UTF-8"
);


ALTER TABLE public.location_level5 OWNER TO postgres;

--
-- TOC entry 176 (class 1259 OID 17635)
-- Dependencies: 175 7
-- Name: loc_level2_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loc_level2_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loc_level2_seq OWNER TO postgres;

--
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 176
-- Name: loc_level2_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loc_level2_seq OWNED BY location_level5.idl5;


--
-- TOC entry 177 (class 1259 OID 17637)
-- Dependencies: 2296 2297 2298 2299 7
-- Name: location_level2; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location_level2 (
    idl2 bigint DEFAULT nextval('loc_level2_seq'::regclass) NOT NULL,
    idl1 integer,
    name text DEFAULT 'state'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.location_level2 OWNER TO postgres;

--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE location_level2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE location_level2 IS 'Estados o provincias';


--
-- TOC entry 178 (class 1259 OID 17647)
-- Dependencies: 7 177
-- Name: loc_level6_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loc_level6_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loc_level6_seq OWNER TO postgres;

--
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 178
-- Name: loc_level6_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loc_level6_seq OWNED BY location_level2.idl2;


--
-- TOC entry 179 (class 1259 OID 17649)
-- Dependencies: 2300 2301 2302 7 1919 1917
-- Name: location_level6; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location_level6 (
    idl6 bigint DEFAULT nextval('loc_level6_seq'::regclass) NOT NULL,
    idl5 integer,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'subsector'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    code text COLLATE pg_catalog."C.UTF-8"
);


ALTER TABLE public.location_level6 OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 17658)
-- Dependencies: 7 179
-- Name: loc_level3_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loc_level3_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loc_level3_seq OWNER TO postgres;

--
-- TOC entry 2985 (class 0 OID 0)
-- Dependencies: 180
-- Name: loc_level3_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loc_level3_seq OWNED BY location_level6.idl6;


--
-- TOC entry 181 (class 1259 OID 17660)
-- Dependencies: 2303 2304 2305 7 1919
-- Name: location_level4; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location_level4 (
    idl4 bigint NOT NULL,
    idl3 integer,
    name text COLLATE pg_catalog."es_EC.utf8" DEFAULT 'city'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    code text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.location_level4 OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 17669)
-- Dependencies: 181 7
-- Name: loc_level4_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loc_level4_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loc_level4_seq OWNER TO postgres;

--
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 182
-- Name: loc_level4_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loc_level4_seq OWNED BY location_level4.idl4;


--
-- TOC entry 183 (class 1259 OID 17671)
-- Dependencies: 2307 2308 2309 2310 7
-- Name: location_level3; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location_level3 (
    idl3 bigint DEFAULT nextval('loc_level3_seq'::regclass) NOT NULL,
    idl2 integer,
    name text DEFAULT 'state'::text NOT NULL,
    code text DEFAULT '000'::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.location_level3 OWNER TO postgres;

--
-- TOC entry 2987 (class 0 OID 0)
-- Dependencies: 183
-- Name: TABLE location_level3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE location_level3 IS 'Estados o provincias';


--
-- TOC entry 184 (class 1259 OID 17681)
-- Dependencies: 2311 2312 2313 2314 2315 7
-- Name: modem; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE modem (
    idmodem bigint NOT NULL,
    imei text DEFAULT '01234'::text NOT NULL,
    manufacturer text DEFAULT 'Could not be obtained'::text NOT NULL,
    model text DEFAULT 'Could not be obtained'::text NOT NULL,
    revision text DEFAULT 'Could not be obtained'::text NOT NULL,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.modem OWNER TO postgres;

--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE modem; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE modem IS 'Modems que han sido automaticamente registrados por el sistema';


--
-- TOC entry 185 (class 1259 OID 17692)
-- Dependencies: 184 7
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
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 185
-- Name: modem_idmodem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE modem_idmodem_seq OWNED BY modem.idmodem;


--
-- TOC entry 241 (class 1259 OID 18885)
-- Dependencies: 2538 2539 2540 2541 2542 2543 2544 2545 7
-- Name: notification_area; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE notification_area (
    idnotify bigint NOT NULL,
    datetime timestamp without time zone DEFAULT now(),
    urgency integer DEFAULT 10,
    timeout integer DEFAULT 5,
    closable boolean DEFAULT false,
    img text DEFAULT ''::text,
    snd text DEFAULT ''::text,
    title text DEFAULT ''::text,
    body text DEFAULT ''::text
);


ALTER TABLE public.notification_area OWNER TO postgres;

--
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE notification_area; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE notification_area IS 'Notificaciones para el area de notificacion de la interface grafica';


--
-- TOC entry 240 (class 1259 OID 18883)
-- Dependencies: 7 241
-- Name: notification_area_idnotify_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE notification_area_idnotify_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_area_idnotify_seq OWNER TO postgres;

--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 240
-- Name: notification_area_idnotify_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE notification_area_idnotify_seq OWNED BY notification_area.idnotify;


--
-- TOC entry 186 (class 1259 OID 17694)
-- Dependencies: 2317 2318 2319 2320 2321 2322 2323 2324 2325 2326 2327 2328 7
-- Name: outgoing; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE outgoing (
    idsmsout bigint NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    idprovider integer,
    idsim integer,
    idsmstype integer DEFAULT 0 NOT NULL,
    idphone integer,
    message text DEFAULT ''::text NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    datetosend timestamp without time zone DEFAULT now() NOT NULL,
    priority integer DEFAULT 5,
    report boolean DEFAULT false,
    enablemessageclass boolean DEFAULT false NOT NULL,
    messageclass integer DEFAULT 1 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    idowner integer
);


ALTER TABLE public.outgoing OWNER TO postgres;

--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE outgoing; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE outgoing IS 'Bandeja de salida de mensajes de texto.';


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.dateload; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.dateload IS 'Fecha en la que el sms fue almacenado en la base de datos.';


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.idprovider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.idprovider IS 'Normalmente 0 a menos que se fuerce al sistema a usar el proveedor almacenado en este campo.';


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.idsim; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.idsim IS 'Normalmente 0 a menos que se fuerce al sistema a usar la sim almacenada en este campo.';


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.idphone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.idphone IS 'El sistema usa normalmente este campo para referenciar al número telefonico.
Si es nulo se tomará el campo phone para el envio del sms';


--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.phone IS 'Campo tomado para el envio del sms en caso de que idphone sea nulo.';


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.datetosend; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.datetosend IS 'Fecha programada para el envio del sms';


--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.priority; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.priority IS 'Prioridad del envio del sms.
Default 5.
0 Máximo
>= 10 Minima prioridad';


--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN outgoing.report; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing.report IS 'Acuse de recepción del sms enviado.';


--
-- TOC entry 187 (class 1259 OID 17712)
-- Dependencies: 186 7
-- Name: outgoing_idsmsout_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE outgoing_idsmsout_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outgoing_idsmsout_seq OWNER TO postgres;

--
-- TOC entry 3001 (class 0 OID 0)
-- Dependencies: 187
-- Name: outgoing_idsmsout_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE outgoing_idsmsout_seq OWNED BY outgoing.idsmsout;


--
-- TOC entry 188 (class 1259 OID 17714)
-- Dependencies: 2331 7
-- Name: outgoing_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE outgoing_log (
    idoutgoinglog integer NOT NULL,
    idsmsout integer,
    datelog timestamp without time zone DEFAULT now() NOT NULL,
    idsim integer,
    status integer,
    parts integer,
    part integer
);


ALTER TABLE public.outgoing_log OWNER TO postgres;

--
-- TOC entry 3002 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE outgoing_log; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE outgoing_log IS 'Bitacora de envio de sms.';


--
-- TOC entry 3003 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN outgoing_log.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing_log.status IS 'Estado del mensaje';


--
-- TOC entry 3004 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN outgoing_log.parts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing_log.parts IS 'Total de partes del mensaje';


--
-- TOC entry 3005 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN outgoing_log.part; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outgoing_log.part IS 'Número de parte del sms';


--
-- TOC entry 189 (class 1259 OID 17718)
-- Dependencies: 188 7
-- Name: outgoing_log_idoutgoinglog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE outgoing_log_idoutgoinglog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outgoing_log_idoutgoinglog_seq OWNER TO postgres;

--
-- TOC entry 3006 (class 0 OID 0)
-- Dependencies: 189
-- Name: outgoing_log_idoutgoinglog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE outgoing_log_idoutgoinglog_seq OWNED BY outgoing_log.idoutgoinglog;


--
-- TOC entry 190 (class 1259 OID 17720)
-- Dependencies: 2332 2333 7
-- Name: owners; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE owners (
    idowner integer NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    description text,
    note text
);


ALTER TABLE public.owners OWNER TO postgres;

--
-- TOC entry 3007 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE owners; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE owners IS 'Propietarios o consumidores de uSMS.
Son los software o procesos derivados de uSMS que hacen uso de sus recursos.
Por ejemplo uSAGA es un software derivado de uSMS.';


--
-- TOC entry 191 (class 1259 OID 17728)
-- Dependencies: 190 7
-- Name: owners_idowner_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE owners_idowner_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.owners_idowner_seq OWNER TO postgres;

--
-- TOC entry 3008 (class 0 OID 0)
-- Dependencies: 191
-- Name: owners_idowner_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE owners_idowner_seq OWNED BY owners.idowner;


--
-- TOC entry 192 (class 1259 OID 17730)
-- Dependencies: 2335 2336 2337 2338 2339 2340 2341 2342 2343 7
-- Name: phones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE phones (
    idphone integer NOT NULL,
    idcontact integer DEFAULT 0 NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    typephone integer DEFAULT 0 NOT NULL,
    idprovider integer DEFAULT 0,
    note text DEFAULT ' '::text NOT NULL,
    phone_ext text DEFAULT ' '::text NOT NULL,
    ubiphone integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    idaddress integer
);


ALTER TABLE public.phones OWNER TO postgres;

--
-- TOC entry 3009 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE phones; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE phones IS 'Numeros telefonicos de contactos.';


--
-- TOC entry 3010 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN phones.typephone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN phones.typephone IS '0: No especificado
1: Fijo
2: Movil';


--
-- TOC entry 193 (class 1259 OID 17745)
-- Dependencies: 192 7
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
-- TOC entry 3011 (class 0 OID 0)
-- Dependencies: 193
-- Name: phones_idphone_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE phones_idphone_seq OWNED BY phones.idphone;


--
-- TOC entry 194 (class 1259 OID 17747)
-- Dependencies: 2345 2346 2347 2348 7
-- Name: provider; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE provider (
    idprovider integer NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.provider OWNER TO postgres;

--
-- TOC entry 3012 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE provider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE provider IS 'Proveedores de telefonia';


--
-- TOC entry 3013 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN provider.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN provider.name IS 'Nombre del proveedor';


--
-- TOC entry 195 (class 1259 OID 17757)
-- Dependencies: 7 194
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
-- TOC entry 3014 (class 0 OID 0)
-- Dependencies: 195
-- Name: provider_idprovider_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE provider_idprovider_seq OWNED BY provider.idprovider;


--
-- TOC entry 197 (class 1259 OID 17775)
-- Dependencies: 196 7
-- Name: sim_idsim_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sim_idsim_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sim_idsim_seq OWNER TO postgres;

--
-- TOC entry 3015 (class 0 OID 0)
-- Dependencies: 197
-- Name: sim_idsim_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sim_idsim_seq OWNED BY sim.idsim;


--
-- TOC entry 198 (class 1259 OID 17777)
-- Dependencies: 2361 2362 2363 2364 2365 2366 2367 2368 2369 2370 2371 2372 2373 2374 2376 7 1917
-- Name: smsin; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE smsin (
    idsmsin bigint NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    idprovider integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    datesms timestamp without time zone DEFAULT '1990-01-01 00:00:00'::timestamp without time zone NOT NULL,
    message text COLLATE pg_catalog."C.UTF-8" DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
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
-- TOC entry 3016 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE smsin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE smsin IS 'Tabla de sms entrantes';


--
-- TOC entry 199 (class 1259 OID 17798)
-- Dependencies: 7 198
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
-- TOC entry 3017 (class 0 OID 0)
-- Dependencies: 199
-- Name: smsin_idsmsin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE smsin_idsmsin_seq OWNED BY smsin.idsmsin;


--
-- TOC entry 239 (class 1259 OID 18649)
-- Dependencies: 2535 2536 7
-- Name: tables_changed; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tables_changed (
    tname text NOT NULL,
    tts timestamp without time zone DEFAULT now() NOT NULL,
    trows integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.tables_changed OWNER TO postgres;

--
-- TOC entry 3018 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE tables_changed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE tables_changed IS 'Esta tabla guarda el ultimo timestamp en que se realizó algun INSERT, UPDATE, DELETE.
Permite saber que tablas han sido modificadas';


--
-- TOC entry 200 (class 1259 OID 17800)
-- Dependencies: 2883 7
-- Name: view_callin; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_callin AS
    SELECT incomingcalls.idincall, incomingcalls.datecall, incomingcalls.idport, incomingcalls.callaction, incomingcalls.idphone, incomingcalls.phone, incomingcalls.flag1, incomingcalls.flag2, incomingcalls.flag3, incomingcalls.flag4, incomingcalls.flag5, phones.idcontact, phones.enable, phones.phone AS phone_phone, phones.typephone AS type, phones.idprovider FROM incomingcalls, phones WHERE (incomingcalls.idphone = phones.idphone);


ALTER TABLE public.view_callin OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 17804)
-- Dependencies: 2884 7
-- Name: view_contacts_address; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_contacts_address AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, contacts.title, contacts.idaddress, address.geox, address.geoy, address.field1, address.field2, address.field3, address.field4, address.field5, address.field6, address.field7, address.field8, address.field9, address.field10 FROM (contacts LEFT JOIN address ON ((contacts.idaddress = address.idaddress)));


ALTER TABLE public.view_contacts_address OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 35392)
-- Dependencies: 2893 7
-- Name: view_contacts_groups; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_contacts_groups AS
    SELECT groups.idgroup, groups.enable, groups.name, groups.note, contacts.idcontact, CASE WHEN (((('{'::text || (groups.idgroup)::text) || '}'::text))::integer[] <@ contacts.groups) THEN true ELSE false END AS belong FROM groups, contacts;


ALTER TABLE public.view_contacts_groups OWNER TO postgres;

--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 242
-- Name: VIEW view_contacts_groups; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW view_contacts_groups IS 'Lista de grupos a los que pertenece cada contacto';


--
-- TOC entry 202 (class 1259 OID 17809)
-- Dependencies: 2885 7
-- Name: view_contacts_phones; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_contacts_phones AS
    SELECT contacts.idcontact, contacts.enable AS contact_enable, contacts.title, contacts.firstname, contacts.lastname, contacts.gender, contacts.birthday, contacts.typeofid, contacts.identification, contacts.web, contacts.email1, contacts.email2, phones.idphone, phones.enable AS phone_enable, phones.typephone AS type, phones.idprovider, phones.ubiphone, phones.phone, phones.phone_ext, phones.note FROM (contacts LEFT JOIN phones ON ((contacts.idcontact = phones.idcontact)));


ALTER TABLE public.view_contacts_phones OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 17814)
-- Dependencies: 2886 1917 1917 1919 1919 7 1917
-- Name: view_locations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_locations AS
    SELECT l1.idl1, l1.name AS l1name, l1.code AS l1code, l2.idl2, l2.name AS l2name, l2.code AS l2code, l3.idl3, l3.name AS l3name, l3.code AS l3code, l4.idl4, l4.name AS l4name, l4.code AS l4code, l5.idl5, l5.name AS l5name, l5.code AS l5code, l6.idl6, l6.name AS l6name, l6.code AS l6code FROM (((((location_level1 l1 LEFT JOIN location_level2 l2 ON ((l1.idl1 = l2.idl1))) LEFT JOIN location_level3 l3 ON ((l2.idl2 = l3.idl2))) LEFT JOIN location_level4 l4 ON ((l3.idl3 = l4.idl3))) LEFT JOIN location_level5 l5 ON ((l4.idl4 = l5.idl4))) LEFT JOIN location_level6 l6 ON ((l5.idl5 = l6.idl5)));


ALTER TABLE public.view_locations OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 17819)
-- Dependencies: 2887 7 1917 1919 1917 1917 1919
-- Name: view_locations_full; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_locations_full AS
    ((((SELECT view_locations.idl1, view_locations.l1name, view_locations.l1code, view_locations.idl2, view_locations.l2name, view_locations.l2code, view_locations.idl3, view_locations.l3name, view_locations.l3code, view_locations.idl4, view_locations.l4name, view_locations.l4code, view_locations.idl5, view_locations.l5name, view_locations.l5code, view_locations.idl6, view_locations.l6name, view_locations.l6code FROM view_locations UNION SELECT view_locations.idl1, view_locations.l1name, view_locations.l1code, NULL::bigint AS idl2, NULL::text AS l2name, NULL::text AS l2code, NULL::bigint AS idl3, NULL::text AS l3name, NULL::text AS l3code, NULL::bigint AS idl4, NULL::text AS l4name, NULL::text AS l4code, NULL::bigint AS idl5, NULL::text AS l5name, NULL::text AS l5code, NULL::bigint AS idl6, NULL::text AS l6name, NULL::text AS l6code FROM view_locations WHERE (view_locations.idl1 > 0)) UNION SELECT view_locations.idl1, view_locations.l1name, view_locations.l1code, view_locations.idl2, view_locations.l2name, view_locations.l2code, NULL::bigint AS idl3, NULL::text AS l3name, NULL::text AS l3code, NULL::bigint AS idl4, NULL::text AS l4name, NULL::text AS l4code, NULL::bigint AS idl5, NULL::text AS l5name, NULL::text AS l5code, NULL::bigint AS idl6, NULL::text AS l6name, NULL::text AS l6code FROM view_locations WHERE ((view_locations.idl1 > 0) AND (view_locations.idl2 > 0))) UNION SELECT view_locations.idl1, view_locations.l1name, view_locations.l1code, view_locations.idl2, view_locations.l2name, view_locations.l2code, view_locations.idl3, view_locations.l3name, view_locations.l3code, NULL::bigint AS idl4, NULL::text AS l4name, NULL::text AS l4code, NULL::bigint AS idl5, NULL::text AS l5name, NULL::text AS l5code, NULL::bigint AS idl6, NULL::text AS l6name, NULL::text AS l6code FROM view_locations WHERE (((view_locations.idl1 > 0) AND (view_locations.idl2 > 0)) AND (view_locations.idl3 > 0))) UNION SELECT view_locations.idl1, view_locations.l1name, view_locations.l1code, view_locations.idl2, view_locations.l2name, view_locations.l2code, view_locations.idl3, view_locations.l3name, view_locations.l3code, view_locations.idl4, view_locations.l4name, view_locations.l4code, NULL::bigint AS idl5, NULL::text AS l5name, NULL::text AS l5code, NULL::bigint AS idl6, NULL::text AS l6name, NULL::text AS l6code FROM view_locations WHERE ((((view_locations.idl1 > 0) AND (view_locations.idl2 > 0)) AND (view_locations.idl3 > 0)) AND (view_locations.idl4 > 0))) UNION SELECT view_locations.idl1, view_locations.l1name, view_locations.l1code, view_locations.idl2, view_locations.l2name, view_locations.l2code, view_locations.idl3, view_locations.l3name, view_locations.l3code, view_locations.idl4, view_locations.l4name, view_locations.l4code, view_locations.idl5, view_locations.l5name, view_locations.l5code, NULL::bigint AS idl6, NULL::text AS l6name, NULL::text AS l6code FROM view_locations WHERE (((((view_locations.idl1 > 0) AND (view_locations.idl2 > 0)) AND (view_locations.idl3 > 0)) AND (view_locations.idl4 > 0)) AND (view_locations.idl5 > 0));


ALTER TABLE public.view_locations_full OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 17824)
-- Dependencies: 2888 7
-- Name: view_location_idlocation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_location_idlocation AS
    SELECT ((((((COALESCE((view_locations_full.idl1)::text, '0'::text) || COALESCE((view_locations_full.idl2)::text, '0'::text)) || COALESCE((view_locations_full.idl3)::text, '0'::text)) || COALESCE((view_locations_full.idl4)::text, '0'::text)) || COALESCE((view_locations_full.idl5)::text, '0'::text)) || COALESCE((view_locations_full.idl6)::text, '0'::text)))::numeric AS idlocation, view_locations_full.idl1, view_locations_full.idl2, view_locations_full.idl3, view_locations_full.idl4, view_locations_full.idl5, view_locations_full.idl6 FROM view_locations_full;


ALTER TABLE public.view_location_idlocation OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 17828)
-- Dependencies: 2889 7
-- Name: view_outgoing_idphone; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_outgoing_idphone AS
    SELECT outgoing.idsmsout, outgoing.idowner, outgoing.dateload, outgoing.idsim, outgoing.idsmstype, phones.idcontact, outgoing.idphone, COALESCE(phones.enable, true) AS enable, phones.typephone, COALESCE(phones.phone, outgoing.phone) AS phone, COALESCE(outgoing.idprovider, phones.idprovider) AS idprovider, outgoing.message, outgoing.datetosend, outgoing.priority, outgoing.report, outgoing.enablemessageclass, outgoing.messageclass, outgoing.status, outgoing.ts, outgoing.note FROM (outgoing LEFT JOIN phones ON ((outgoing.idphone = phones.idphone)));


ALTER TABLE public.view_outgoing_idphone OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 17833)
-- Dependencies: 2377 2378 7
-- Name: whitelist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE whitelist (
    idwl integer NOT NULL,
    idphone integer DEFAULT 0,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.whitelist OWNER TO postgres;

--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE whitelist; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE whitelist IS 'Lista de numeros para envio de sms sin restriccion';


--
-- TOC entry 208 (class 1259 OID 17841)
-- Dependencies: 7 207
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
-- TOC entry 3021 (class 0 OID 0)
-- Dependencies: 208
-- Name: whitelist_idwl_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE whitelist_idwl_seq OWNED BY whitelist.idwl;


SET search_path = usaga, pg_catalog;

--
-- TOC entry 209 (class 1259 OID 17843)
-- Dependencies: 2380 2381 2382 2383 2384 2385 2386 2387 6
-- Name: account; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account (
    idaccount bigint NOT NULL,
    partition integer DEFAULT 0 NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    account text DEFAULT '0000'::text NOT NULL,
    name text DEFAULT 'Undefined'::text NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    dateload timestamp without time zone DEFAULT now() NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    idgroup integer,
    idaddress_xxx integer,
    idcontact integer
);


ALTER TABLE usaga.account OWNER TO postgres;

--
-- TOC entry 3022 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE account; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE account IS 'Cuenta de usuario';


--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN account.account; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN account.account IS 'Numero de cuenta en 4 digitos';


--
-- TOC entry 210 (class 1259 OID 17857)
-- Dependencies: 2389 2390 2391 2392 2393 2394 2395 6
-- Name: account_contacts; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_contacts (
    idaccount integer DEFAULT 0 NOT NULL,
    idcontact integer DEFAULT 0 NOT NULL,
    prioritycontact integer DEFAULT 5 NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    appointment text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.account_contacts OWNER TO postgres;

--
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE account_contacts; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE account_contacts IS 'Usuarios del sistema, tiene acceso al sistema ';


--
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN account_contacts.prioritycontact; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN account_contacts.prioritycontact IS 'Priordad de comunicar novedad a este contacto';


--
-- TOC entry 211 (class 1259 OID 17870)
-- Dependencies: 6 209
-- Name: account_idaccount_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE account_idaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.account_idaccount_seq OWNER TO postgres;

--
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 211
-- Name: account_idaccount_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE account_idaccount_seq OWNED BY account.idaccount;


--
-- TOC entry 212 (class 1259 OID 17872)
-- Dependencies: 2396 2397 2398 2399 2400 2401 2402 2403 2404 6
-- Name: account_installationdata; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
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


ALTER TABLE usaga.account_installationdata OWNER TO postgres;

--
-- TOC entry 3027 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE account_installationdata; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE account_installationdata IS 'Datos basico acerca de la instalacion del sistema de alarma';


--
-- TOC entry 3028 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN account_installationdata.idaccount; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN account_installationdata.idaccount IS 'idaccount a la que pertenecen estos datos';


--
-- TOC entry 3029 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN account_installationdata.installercode; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN account_installationdata.installercode IS 'Codigo de instalador del panel de control';


--
-- TOC entry 213 (class 1259 OID 17887)
-- Dependencies: 2405 2406 2407 2408 2409 2410 2411 2412 6
-- Name: account_notifications; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_notifications (
    idnotifaccount bigint NOT NULL,
    idaccount integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 5 NOT NULL,
    call boolean DEFAULT false NOT NULL,
    sms boolean DEFAULT false NOT NULL,
    smstext text DEFAULT ' '::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.account_notifications OWNER TO postgres;

--
-- TOC entry 3030 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE account_notifications; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE account_notifications IS 'Contactos a donde se enviara las notificaciones en caso de alarma';


--
-- TOC entry 214 (class 1259 OID 17901)
-- Dependencies: 2414 2415 2416 6
-- Name: account_notifications_eventtype; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_notifications_eventtype (
    idnotifphoneeventtype bigint NOT NULL,
    idnotifaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.account_notifications_eventtype OWNER TO postgres;

--
-- TOC entry 3031 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE account_notifications_eventtype; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE account_notifications_eventtype IS 'Tipos de eventos para cada notificacion.
TODO: Verificar llaves unicas';


--
-- TOC entry 215 (class 1259 OID 17907)
-- Dependencies: 214 6
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.account_notifications_eventtype_idnotifphoneeventtype_seq OWNER TO postgres;

--
-- TOC entry 3032 (class 0 OID 0)
-- Dependencies: 215
-- Name: account_notifications_eventtype_idnotifphoneeventtype_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE account_notifications_eventtype_idnotifphoneeventtype_seq OWNED BY account_notifications_eventtype.idnotifphoneeventtype;


--
-- TOC entry 216 (class 1259 OID 17909)
-- Dependencies: 2418 2419 2420 6
-- Name: account_notifications_group; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_notifications_group (
    idaccount integer DEFAULT 0 NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.account_notifications_group OWNER TO postgres;

--
-- TOC entry 3033 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE account_notifications_group; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE account_notifications_group IS 'Tipos de eventos que se enviaran a los grupos';


--
-- TOC entry 217 (class 1259 OID 17918)
-- Dependencies: 6 213
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE account_notifications_idnotifaccount_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.account_notifications_idnotifaccount_seq OWNER TO postgres;

--
-- TOC entry 3034 (class 0 OID 0)
-- Dependencies: 217
-- Name: account_notifications_idnotifaccount_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE account_notifications_idnotifaccount_seq OWNED BY account_notifications.idnotifaccount;


--
-- TOC entry 218 (class 1259 OID 17920)
-- Dependencies: 2421 2422 2423 2424 2425 2426 2427 6
-- Name: account_phones_trigger_alarm; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_phones_trigger_alarm (
    idaccount integer DEFAULT 0 NOT NULL,
    idphone integer DEFAULT 0 NOT NULL,
    enable boolean DEFAULT false NOT NULL,
    fromsms boolean DEFAULT true NOT NULL,
    fromcall boolean DEFAULT true NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.account_phones_trigger_alarm OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17933)
-- Dependencies: 2428 2429 2430 2431 2432 210 6
-- Name: account_users; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE account_users (
    enable_as_user boolean DEFAULT true NOT NULL,
    keyword text DEFAULT 'undefined'::text NOT NULL,
    pwd text DEFAULT '1234'::text NOT NULL,
    numuser integer DEFAULT 0 NOT NULL,
    note_user text DEFAULT ' '::text NOT NULL
)
INHERITS (account_contacts);


ALTER TABLE usaga.account_users OWNER TO postgres;

--
-- TOC entry 3035 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN account_users.numuser; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN account_users.numuser IS 'Numero de usuario';


--
-- TOC entry 247 (class 1259 OID 35746)
-- Dependencies: 2562 2563 2564 2565 2566 2567 2568 6 167
-- Name: accounts; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE accounts (
    partition integer DEFAULT 0,
    account_enable boolean DEFAULT false,
    account_number text DEFAULT '0000'::text NOT NULL,
    account_name text,
    idaccounttype integer DEFAULT 0,
    instalation_date timestamp without time zone DEFAULT now(),
    installer_code text DEFAULT '0000'::text NOT NULL,
    idpanelmodel integer,
    idcommunicationformat integer DEFAULT 0 NOT NULL,
    security_contacts integer[]
)
INHERITS (public.contacts);


ALTER TABLE usaga.accounts OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17951)
-- Dependencies: 2440 2441 2442 2443 2444 2445 2446 2447 2448 2449 2450 2451 2452 2453 2454 2455 2456 2457 2458 2459 2461 2462 2463 6
-- Name: events; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
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
    note text DEFAULT ' '::text NOT NULL,
    dateprocess1 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess2 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess3 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess4 timestamp without time zone DEFAULT now() NOT NULL,
    dateprocess5 timestamp without time zone DEFAULT now() NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    idcontact integer DEFAULT 0,
    idamin integer DEFAULT 0,
    na boolean DEFAULT false
);


ALTER TABLE usaga.events OWNER TO postgres;

--
-- TOC entry 3036 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE events; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE events IS 'Eventos del sistema
TODO: Ver la posibilidad de crear llave unica usando todos los campos
TODO: Para evitar complicaciones en el diseño de las tablas hacer que cuando se genere el evento en la descripcion se ingrese la descripcion de la zona o el o los nombre de los usuarios segun sea el caso.';


--
-- TOC entry 3037 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN events.dateload; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN events.dateload IS 'Fecha de ingreso del evento';


--
-- TOC entry 3038 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN events.idcontact; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN events.idcontact IS 'TODO: No se recuerda cual es la razon por la cual este campo fue creado';


--
-- TOC entry 238 (class 1259 OID 18509)
-- Dependencies: 2531 2532 2533 2534 1917 6
-- Name: events_comments; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE events_comments (
    idcomment bigint NOT NULL,
    idevent integer,
    idadmin integer,
    ts timestamp without time zone DEFAULT now(),
    date_start timestamp without time zone DEFAULT now(),
    comment text COLLATE pg_catalog."C.UTF-8",
    date_end timestamp without time zone DEFAULT now(),
    idstatusevent integer DEFAULT 0,
    attachments integer[]
);


ALTER TABLE usaga.events_comments OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 18507)
-- Dependencies: 238 6
-- Name: events_comments_idcomment_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE events_comments_idcomment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.events_comments_idcomment_seq OWNER TO postgres;

--
-- TOC entry 3039 (class 0 OID 0)
-- Dependencies: 237
-- Name: events_comments_idcomment_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE events_comments_idcomment_seq OWNED BY events_comments.idcomment;


--
-- TOC entry 221 (class 1259 OID 17977)
-- Dependencies: 2464 6 220
-- Name: events_generated_by_calls; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE events_generated_by_calls (
    idincall integer DEFAULT 0 NOT NULL
)
INHERITS (events);


ALTER TABLE usaga.events_generated_by_calls OWNER TO postgres;

--
-- TOC entry 3040 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE events_generated_by_calls; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE events_generated_by_calls IS 'Tabla de eventos generados por llamadas telefonicas.
No permite eventos con misma hora, mismo idphone, etc, no permite eventos repetidos.';


--
-- TOC entry 222 (class 1259 OID 18004)
-- Dependencies: 220 6
-- Name: events_idevent_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE events_idevent_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.events_idevent_seq OWNER TO postgres;

--
-- TOC entry 3041 (class 0 OID 0)
-- Dependencies: 222
-- Name: events_idevent_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE events_idevent_seq OWNED BY events.idevent;


--
-- TOC entry 223 (class 1259 OID 18006)
-- Dependencies: 2489 2490 2491 2492 2493 2494 2495 2496 2497 2498 2499 2500 2501 2502 2503 6
-- Name: eventtypes; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE eventtypes (
    ideventtype integer DEFAULT 0 NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    priority integer DEFAULT 100 NOT NULL,
    accountdefault boolean DEFAULT false NOT NULL,
    label text DEFAULT 'Undefined'::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    groupdefault boolean DEFAULT false NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    manual boolean DEFAULT false,
    treatment boolean DEFAULT false,
    enable_datetime boolean DEFAULT false,
    na_timeout integer DEFAULT 30,
    na_closable boolean DEFAULT true,
    na_img text DEFAULT ''::text,
    na_snd text DEFAULT ''::text
);


ALTER TABLE usaga.eventtypes OWNER TO postgres;

--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE eventtypes; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE eventtypes IS 'Tipos de eventos. Enumeracion interna desde uSAGA, usar unicamente los que no estan reservados.';


--
-- TOC entry 3043 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN eventtypes.name; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN eventtypes.name IS 'Nombre del evento';


--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN eventtypes.accountdefault; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN eventtypes.accountdefault IS 'Habilita si este tipo de evento se notifica a los usuarios y contactos del abonado.';


--
-- TOC entry 3045 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN eventtypes.groupdefault; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN eventtypes.groupdefault IS 'Habilita si este tipo de evento se notifica a los usuarios y contactos del grupo al que pertenece el abonado.';


--
-- TOC entry 3046 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN eventtypes.manual; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON COLUMN eventtypes.manual IS 'Habilita para que este tipo de evento se pueda crear manualmente';


--
-- TOC entry 224 (class 1259 OID 18021)
-- Dependencies: 2504 2505 2506 2507 6
-- Name: xxxgroups; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE xxxgroups (
    idgroup bigint NOT NULL,
    enable boolean DEFAULT true NOT NULL,
    name text DEFAULT 'group'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.xxxgroups OWNER TO postgres;

--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE xxxgroups; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE xxxgroups IS 'Se pasa la tabla grupos a uSMS';


--
-- TOC entry 225 (class 1259 OID 18031)
-- Dependencies: 6 224
-- Name: groups_idgroup_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE groups_idgroup_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.groups_idgroup_seq OWNER TO postgres;

--
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 225
-- Name: groups_idgroup_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE groups_idgroup_seq OWNED BY xxxgroups.idgroup;


--
-- TOC entry 226 (class 1259 OID 18033)
-- Dependencies: 2509 2510 2511 2512 2513 6
-- Name: keywords; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE keywords (
    idkeyword bigint NOT NULL,
    enable boolean DEFAULT false NOT NULL,
    keyword text DEFAULT 'alarm'::text NOT NULL,
    ideventtype integer DEFAULT 0 NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.keywords OWNER TO postgres;

--
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE keywords; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE keywords IS 'Lista de palabras claves a reconocer en los sms';


--
-- TOC entry 227 (class 1259 OID 18044)
-- Dependencies: 6 226
-- Name: keywords_idkeyword_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE keywords_idkeyword_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.keywords_idkeyword_seq OWNER TO postgres;

--
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 227
-- Name: keywords_idkeyword_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE keywords_idkeyword_seq OWNED BY keywords.idkeyword;


--
-- TOC entry 228 (class 1259 OID 18046)
-- Dependencies: 2515 2516 2517 6
-- Name: notification_templates; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE notification_templates (
    idnotiftempl bigint NOT NULL,
    description text DEFAULT 'description'::text NOT NULL,
    message text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.notification_templates OWNER TO postgres;

--
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE notification_templates; Type: COMMENT; Schema: usaga; Owner: postgres
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
-- TOC entry 229 (class 1259 OID 18055)
-- Dependencies: 228 6
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE notification_templates_idnotiftempl_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.notification_templates_idnotiftempl_seq OWNER TO postgres;

--
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 229
-- Name: notification_templates_idnotiftempl_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE notification_templates_idnotiftempl_seq OWNED BY notification_templates.idnotiftempl;


--
-- TOC entry 230 (class 1259 OID 18057)
-- Dependencies: 2519 2520 2521 2522 2523 6
-- Name: panelmodel; Type: TABLE; Schema: usaga; Owner: postgres; Tablespace: 
--

CREATE TABLE panelmodel (
    idpanelmodel bigint NOT NULL,
    name text DEFAULT 'Undefined'::text,
    model text DEFAULT 'Undefined'::text NOT NULL,
    version text DEFAULT 'v-0.0'::text NOT NULL,
    note text DEFAULT ' '::text NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE usaga.panelmodel OWNER TO postgres;

--
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE panelmodel; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TABLE panelmodel IS 'Modelos de paneles de control de alarma';


--
-- TOC entry 231 (class 1259 OID 18068)
-- Dependencies: 230 6
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE; Schema: usaga; Owner: postgres
--

CREATE SEQUENCE panelmodel_idpanelmodel_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usaga.panelmodel_idpanelmodel_seq OWNER TO postgres;

--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 231
-- Name: panelmodel_idpanelmodel_seq; Type: SEQUENCE OWNED BY; Schema: usaga; Owner: postgres
--

ALTER SEQUENCE panelmodel_idpanelmodel_seq OWNED BY panelmodel.idpanelmodel;


--
-- TOC entry 232 (class 1259 OID 18070)
-- Dependencies: 2890 6
-- Name: view_account_contacts; Type: VIEW; Schema: usaga; Owner: postgres
--

CREATE VIEW view_account_contacts AS
    SELECT DISTINCT ON (tabla.idaccount, tabla.idcontact) tabla.idaccount, tabla.idcontact, tabla.enable, tabla.firstname, tabla.lastname, tabla.prioritycontact, tabla.enable_as_contact, tabla.appointment, tabla.ts, tabla.note FROM (SELECT account_contacts.idaccount, contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_contacts.prioritycontact, account_contacts.enable AS enable_as_contact, account_contacts.appointment, account_contacts.ts, account_contacts.note FROM account_contacts, public.contacts WHERE (contacts.idcontact = account_contacts.idcontact) ORDER BY account_contacts.ts DESC) tabla ORDER BY tabla.idaccount, tabla.idcontact, tabla.ts DESC;


ALTER TABLE usaga.view_account_contacts OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 18074)
-- Dependencies: 2891 6
-- Name: view_account_phones_trigger_alarm; Type: VIEW; Schema: usaga; Owner: postgres
--

CREATE VIEW view_account_phones_trigger_alarm AS
    SELECT account.idaccount, account.enable, account.account, account.name, account.type, account_phones_trigger_alarm.idphone, (SELECT phones.phone FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS phone, (SELECT phones.idprovider FROM public.phones WHERE (phones.idphone = account_phones_trigger_alarm.idphone)) AS idprovider, account_phones_trigger_alarm.enable AS trigger_enable, account_phones_trigger_alarm.fromcall, account_phones_trigger_alarm.fromsms FROM account, account_phones_trigger_alarm WHERE (account.idaccount = account_phones_trigger_alarm.idaccount);


ALTER TABLE usaga.view_account_phones_trigger_alarm OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18078)
-- Dependencies: 2892 6
-- Name: view_account_users; Type: VIEW; Schema: usaga; Owner: postgres
--

CREATE VIEW view_account_users AS
    SELECT contacts.idcontact, contacts.enable, contacts.firstname, contacts.lastname, account_users.idaccount, account_users.prioritycontact, account_users.enable AS enable_as_contact, account_users.appointment, account_users.enable_as_user, account_users.numuser, account_users.pwd, account_users.keyword, account_users.note_user, account_users.ts FROM account_users, public.contacts WHERE (contacts.idcontact = account_users.idcontact);


ALTER TABLE usaga.view_account_users OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 35988)
-- Dependencies: 2896 6
-- Name: view_events; Type: VIEW; Schema: usaga; Owner: postgres
--

CREATE VIEW view_events AS
    SELECT DISTINCT ON (events.idevent) events.idevent, events.dateload, COALESCE(account.idaccount, (0)::bigint) AS idaccount, COALESCE(account.partition, 0) AS partition, COALESCE(account.enable, false) AS enable, COALESCE(account.name, 'uSAGA'::text) AS name, COALESCE(account.account, 'uSAGA'::text) AS account, COALESCE(account.type, 0) AS type, events.code, events.zu, events.priority, events.description, events.ideventtype, (SELECT eventtypes.label FROM eventtypes WHERE (eventtypes.ideventtype = events.ideventtype)) AS eventtype, events.datetimeevent, CASE WHEN (events_comments.idstatusevent IS NULL) THEN 0 ELSE events_comments.idstatusevent END AS status, CASE WHEN (events_comments.date_end IS NULL) THEN ((-1))::double precision ELSE (date_part('epoch'::text, age(now(), (events_comments.date_end)::timestamp with time zone)) / (60)::double precision) END AS last_comment_time, events_comments.ts FROM ((events LEFT JOIN account ON ((events.idaccount = account.idaccount))) LEFT JOIN events_comments ON ((events.idevent = events_comments.idevent))) ORDER BY events.idevent, events_comments.date_end DESC;


ALTER TABLE usaga.view_events OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 35648)
-- Dependencies: 2895 6
-- Name: view_events_fieldtextasb64; Type: VIEW; Schema: usaga; Owner: postgres
--

CREATE VIEW view_events_fieldtextasb64 AS
    SELECT view_events.idevent, view_events.dateload, view_events.idaccount, view_events.partition, view_events.enable, public.tob64(view_events.account) AS account, public.tob64(view_events.name) AS name, view_events.type, public.tob64(view_events.code) AS code, view_events.zu, view_events.priority, public.tob64(view_events.description) AS description, view_events.ideventtype, public.tob64(view_events.eventtype) AS eventtype, view_events.datetimeevent, view_events.status, view_events.last_comment_time FROM view_events view_events;


ALTER TABLE usaga.view_events_fieldtextasb64 OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 35643)
-- Dependencies: 2894 6
-- Name: xxx_view_events; Type: VIEW; Schema: usaga; Owner: postgres
--

CREATE VIEW xxx_view_events AS
    SELECT DISTINCT ON (events.idevent) events.idevent, events.dateload, account.idaccount, CASE WHEN (account.partition IS NULL) THEN 0 ELSE account.partition END AS partition, CASE WHEN (account.enable IS NULL) THEN false ELSE account.enable END AS enable, CASE WHEN (account.name IS NULL) THEN 'uSAGA'::text ELSE account.name END AS name, CASE WHEN (account.account IS NULL) THEN 'uSAGA'::text ELSE account.account END AS account, CASE WHEN (account.type IS NULL) THEN 0 ELSE account.type END AS type, events.code, events.zu, events.priority, events.description, events.ideventtype, (SELECT eventtypes.label FROM eventtypes WHERE (eventtypes.ideventtype = events.ideventtype)) AS eventtype, events.datetimeevent, CASE WHEN (events_comments.idstatusevent IS NULL) THEN 0 ELSE events_comments.idstatusevent END AS status, CASE WHEN (events_comments.date_end IS NULL) THEN ((-1))::double precision ELSE (date_part('epoch'::text, age(now(), (events_comments.date_end)::timestamp with time zone)) / (60)::double precision) END AS last_comment_time, events_comments.ts FROM ((events LEFT JOIN account ON ((events.idaccount = account.idaccount))) LEFT JOIN events_comments ON ((events.idevent = events_comments.idevent))) ORDER BY events.idevent, events_comments.date_end DESC;


ALTER TABLE usaga.xxx_view_events OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 2253 (class 2604 OID 18087)
-- Dependencies: 172 162
-- Name: idaddress; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN idaddress SET DEFAULT nextval('loc_level1_seq'::regclass);


--
-- TOC entry 2254 (class 2604 OID 18088)
-- Dependencies: 164 163
-- Name: idadmin; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY admin ALTER COLUMN idadmin SET DEFAULT nextval('admin_idadmin_seq'::regclass);


--
-- TOC entry 2546 (class 2604 OID 35541)
-- Dependencies: 244 243 244
-- Name: idattach; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attachments ALTER COLUMN idattach SET DEFAULT nextval('attachments_idattach_seq'::regclass);


--
-- TOC entry 2258 (class 2604 OID 18089)
-- Dependencies: 166 165
-- Name: idbl; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blacklist ALTER COLUMN idbl SET DEFAULT nextval('blacklist_idbl_seq'::regclass);


--
-- TOC entry 2272 (class 2604 OID 18090)
-- Dependencies: 168 167
-- Name: idcontact; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contacts ALTER COLUMN idcontact SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- TOC entry 2525 (class 2604 OID 18425)
-- Dependencies: 236 235 236
-- Name: idgroup; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY groups ALTER COLUMN idgroup SET DEFAULT nextval('groups_idgroup_seq'::regclass);


--
-- TOC entry 2288 (class 2604 OID 18091)
-- Dependencies: 171 170
-- Name: idincall; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY incomingcalls ALTER COLUMN idincall SET DEFAULT nextval('incomingcalls_idincall_seq'::regclass);


--
-- TOC entry 2306 (class 2604 OID 18092)
-- Dependencies: 182 181
-- Name: idl4; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_level4 ALTER COLUMN idl4 SET DEFAULT nextval('loc_level4_seq'::regclass);


--
-- TOC entry 2316 (class 2604 OID 18093)
-- Dependencies: 185 184
-- Name: idmodem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY modem ALTER COLUMN idmodem SET DEFAULT nextval('modem_idmodem_seq'::regclass);


--
-- TOC entry 2537 (class 2604 OID 18888)
-- Dependencies: 240 241 241
-- Name: idnotify; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notification_area ALTER COLUMN idnotify SET DEFAULT nextval('notification_area_idnotify_seq'::regclass);


--
-- TOC entry 2329 (class 2604 OID 18094)
-- Dependencies: 187 186
-- Name: idsmsout; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY outgoing ALTER COLUMN idsmsout SET DEFAULT nextval('outgoing_idsmsout_seq'::regclass);


--
-- TOC entry 2330 (class 2604 OID 18095)
-- Dependencies: 189 188
-- Name: idoutgoinglog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY outgoing_log ALTER COLUMN idoutgoinglog SET DEFAULT nextval('outgoing_log_idoutgoinglog_seq'::regclass);


--
-- TOC entry 2334 (class 2604 OID 18096)
-- Dependencies: 191 190
-- Name: idowner; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY owners ALTER COLUMN idowner SET DEFAULT nextval('owners_idowner_seq'::regclass);


--
-- TOC entry 2344 (class 2604 OID 18097)
-- Dependencies: 193 192
-- Name: idphone; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phones ALTER COLUMN idphone SET DEFAULT nextval('phones_idphone_seq'::regclass);


--
-- TOC entry 2349 (class 2604 OID 18098)
-- Dependencies: 195 194
-- Name: idprovider; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY provider ALTER COLUMN idprovider SET DEFAULT nextval('provider_idprovider_seq'::regclass);


--
-- TOC entry 2360 (class 2604 OID 18099)
-- Dependencies: 197 196
-- Name: idsim; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sim ALTER COLUMN idsim SET DEFAULT nextval('sim_idsim_seq'::regclass);


--
-- TOC entry 2375 (class 2604 OID 18100)
-- Dependencies: 199 198
-- Name: idsmsin; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY smsin ALTER COLUMN idsmsin SET DEFAULT nextval('smsin_idsmsin_seq'::regclass);


--
-- TOC entry 2379 (class 2604 OID 18101)
-- Dependencies: 208 207
-- Name: idwl; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY whitelist ALTER COLUMN idwl SET DEFAULT nextval('whitelist_idwl_seq'::regclass);


SET search_path = usaga, pg_catalog;

--
-- TOC entry 2388 (class 2604 OID 18102)
-- Dependencies: 211 209
-- Name: idaccount; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account ALTER COLUMN idaccount SET DEFAULT nextval('account_idaccount_seq'::regclass);


--
-- TOC entry 2413 (class 2604 OID 18103)
-- Dependencies: 217 213
-- Name: idnotifaccount; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications ALTER COLUMN idnotifaccount SET DEFAULT nextval('account_notifications_idnotifaccount_seq'::regclass);


--
-- TOC entry 2417 (class 2604 OID 18104)
-- Dependencies: 215 214
-- Name: idnotifphoneeventtype; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications_eventtype ALTER COLUMN idnotifphoneeventtype SET DEFAULT nextval('account_notifications_eventtype_idnotifphoneeventtype_seq'::regclass);


--
-- TOC entry 2433 (class 2604 OID 18105)
-- Dependencies: 219 219
-- Name: idaccount; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2434 (class 2604 OID 18106)
-- Dependencies: 219 219
-- Name: idcontact; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN idcontact SET DEFAULT 0;


--
-- TOC entry 2435 (class 2604 OID 18107)
-- Dependencies: 219 219
-- Name: prioritycontact; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN prioritycontact SET DEFAULT 5;


--
-- TOC entry 2436 (class 2604 OID 18108)
-- Dependencies: 219 219
-- Name: enable; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN enable SET DEFAULT true;


--
-- TOC entry 2437 (class 2604 OID 18109)
-- Dependencies: 219 219
-- Name: appointment; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN appointment SET DEFAULT ''::text;


--
-- TOC entry 2438 (class 2604 OID 18110)
-- Dependencies: 219 219
-- Name: note; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN note SET DEFAULT ''::text;


--
-- TOC entry 2439 (class 2604 OID 18111)
-- Dependencies: 219 219
-- Name: ts; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2548 (class 2604 OID 35749)
-- Dependencies: 247 168 247
-- Name: idcontact; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN idcontact SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- TOC entry 2549 (class 2604 OID 35750)
-- Dependencies: 247 247
-- Name: enable; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN enable SET DEFAULT true;


--
-- TOC entry 2550 (class 2604 OID 35751)
-- Dependencies: 247 247
-- Name: firstname; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN firstname SET DEFAULT 'nombre'::text;


--
-- TOC entry 2551 (class 2604 OID 35752)
-- Dependencies: 247 247
-- Name: lastname; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN lastname SET DEFAULT ' '::text;


--
-- TOC entry 2552 (class 2604 OID 35753)
-- Dependencies: 247 247
-- Name: gender; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN gender SET DEFAULT 0;


--
-- TOC entry 2553 (class 2604 OID 35754)
-- Dependencies: 247 247
-- Name: birthday; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN birthday SET DEFAULT '1900-01-01'::date;


--
-- TOC entry 2554 (class 2604 OID 35755)
-- Dependencies: 247 247
-- Name: typeofid; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN typeofid SET DEFAULT 0;


--
-- TOC entry 2555 (class 2604 OID 35756)
-- Dependencies: 247 247
-- Name: identification; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN identification SET DEFAULT ''::text;


--
-- TOC entry 2556 (class 2604 OID 35757)
-- Dependencies: 247 247
-- Name: web; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN web SET DEFAULT ''::text;


--
-- TOC entry 2557 (class 2604 OID 35758)
-- Dependencies: 247 247
-- Name: email1; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN email1 SET DEFAULT ''::text;


--
-- TOC entry 2558 (class 2604 OID 35759)
-- Dependencies: 247 247
-- Name: email2; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN email2 SET DEFAULT ''::text;


--
-- TOC entry 2559 (class 2604 OID 35760)
-- Dependencies: 247 247
-- Name: note; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN note SET DEFAULT ''::text;


--
-- TOC entry 2560 (class 2604 OID 35761)
-- Dependencies: 247 247
-- Name: ts; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2561 (class 2604 OID 35762)
-- Dependencies: 247 247
-- Name: title; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN title SET DEFAULT 'Sr@'::text;


--
-- TOC entry 2569 (class 2604 OID 35864)
-- Dependencies: 247 247
-- Name: deleted; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY accounts ALTER COLUMN deleted SET DEFAULT false;


--
-- TOC entry 2460 (class 2604 OID 18112)
-- Dependencies: 222 220
-- Name: idevent; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2530 (class 2604 OID 18512)
-- Dependencies: 237 238 238
-- Name: idcomment; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_comments ALTER COLUMN idcomment SET DEFAULT nextval('events_comments_idcomment_seq'::regclass);


--
-- TOC entry 2465 (class 2604 OID 18113)
-- Dependencies: 221 221 222
-- Name: idevent; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idevent SET DEFAULT nextval('events_idevent_seq'::regclass);


--
-- TOC entry 2466 (class 2604 OID 18114)
-- Dependencies: 221 221
-- Name: dateload; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateload SET DEFAULT now();


--
-- TOC entry 2467 (class 2604 OID 18115)
-- Dependencies: 221 221
-- Name: idaccount; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idaccount SET DEFAULT 0;


--
-- TOC entry 2468 (class 2604 OID 18116)
-- Dependencies: 221 221
-- Name: code; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN code SET DEFAULT '0000'::text;


--
-- TOC entry 2469 (class 2604 OID 18117)
-- Dependencies: 221 221
-- Name: zu; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN zu SET DEFAULT 0;


--
-- TOC entry 2470 (class 2604 OID 18118)
-- Dependencies: 221 221
-- Name: priority; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN priority SET DEFAULT 5;


--
-- TOC entry 2471 (class 2604 OID 18119)
-- Dependencies: 221 221
-- Name: description; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN description SET DEFAULT ''::text;


--
-- TOC entry 2472 (class 2604 OID 18120)
-- Dependencies: 221 221
-- Name: ideventtype; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ideventtype SET DEFAULT 0;


--
-- TOC entry 2473 (class 2604 OID 18121)
-- Dependencies: 221 221
-- Name: datetimeevent; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN datetimeevent SET DEFAULT now();


--
-- TOC entry 2474 (class 2604 OID 18122)
-- Dependencies: 221 221
-- Name: process1; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process1 SET DEFAULT 0;


--
-- TOC entry 2475 (class 2604 OID 18123)
-- Dependencies: 221 221
-- Name: process2; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process2 SET DEFAULT 0;


--
-- TOC entry 2476 (class 2604 OID 18124)
-- Dependencies: 221 221
-- Name: process3; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process3 SET DEFAULT 0;


--
-- TOC entry 2477 (class 2604 OID 18125)
-- Dependencies: 221 221
-- Name: process4; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process4 SET DEFAULT 0;


--
-- TOC entry 2478 (class 2604 OID 18126)
-- Dependencies: 221 221
-- Name: process5; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN process5 SET DEFAULT 0;


--
-- TOC entry 2479 (class 2604 OID 18127)
-- Dependencies: 221 221
-- Name: note; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN note SET DEFAULT ' '::text;


--
-- TOC entry 2480 (class 2604 OID 18128)
-- Dependencies: 221 221
-- Name: dateprocess1; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess1 SET DEFAULT now();


--
-- TOC entry 2481 (class 2604 OID 18129)
-- Dependencies: 221 221
-- Name: dateprocess2; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess2 SET DEFAULT now();


--
-- TOC entry 2482 (class 2604 OID 18130)
-- Dependencies: 221 221
-- Name: dateprocess3; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess3 SET DEFAULT now();


--
-- TOC entry 2483 (class 2604 OID 18131)
-- Dependencies: 221 221
-- Name: dateprocess4; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess4 SET DEFAULT now();


--
-- TOC entry 2484 (class 2604 OID 18132)
-- Dependencies: 221 221
-- Name: dateprocess5; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN dateprocess5 SET DEFAULT now();


--
-- TOC entry 2485 (class 2604 OID 18133)
-- Dependencies: 221 221
-- Name: ts; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN ts SET DEFAULT now();


--
-- TOC entry 2487 (class 2604 OID 18762)
-- Dependencies: 221 221
-- Name: idcontact; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idcontact SET DEFAULT 0;


--
-- TOC entry 2486 (class 2604 OID 18746)
-- Dependencies: 221 221
-- Name: idamin; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN idamin SET DEFAULT 0;


--
-- TOC entry 2488 (class 2604 OID 18913)
-- Dependencies: 221 221
-- Name: na; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_generated_by_calls ALTER COLUMN na SET DEFAULT false;


--
-- TOC entry 2514 (class 2604 OID 18135)
-- Dependencies: 227 226
-- Name: idkeyword; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY keywords ALTER COLUMN idkeyword SET DEFAULT nextval('keywords_idkeyword_seq'::regclass);


--
-- TOC entry 2518 (class 2604 OID 18136)
-- Dependencies: 229 228
-- Name: idnotiftempl; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY notification_templates ALTER COLUMN idnotiftempl SET DEFAULT nextval('notification_templates_idnotiftempl_seq'::regclass);


--
-- TOC entry 2524 (class 2604 OID 18137)
-- Dependencies: 231 230
-- Name: idpanelmodel; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY panelmodel ALTER COLUMN idpanelmodel SET DEFAULT nextval('panelmodel_idpanelmodel_seq'::regclass);


--
-- TOC entry 2508 (class 2604 OID 18134)
-- Dependencies: 225 224
-- Name: idgroup; Type: DEFAULT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY xxxgroups ALTER COLUMN idgroup SET DEFAULT nextval('groups_idgroup_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2623 (class 2606 OID 18139)
-- Dependencies: 192 192 2898
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT id PRIMARY KEY (idphone);


--
-- TOC entry 2579 (class 2606 OID 18141)
-- Dependencies: 167 167 2898
-- Name: idcontact; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT idcontact PRIMARY KEY (idcontact);


--
-- TOC entry 2571 (class 2606 OID 18143)
-- Dependencies: 162 162 2898
-- Name: pk_idaddress; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT pk_idaddress PRIMARY KEY (idaddress);


--
-- TOC entry 2573 (class 2606 OID 18145)
-- Dependencies: 163 163 2898
-- Name: pk_idadmin; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT pk_idadmin PRIMARY KEY (idadmin);


--
-- TOC entry 2691 (class 2606 OID 35547)
-- Dependencies: 244 244 2898
-- Name: pk_idattach_attach; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT pk_idattach_attach PRIMARY KEY (idattach);


--
-- TOC entry 2577 (class 2606 OID 18147)
-- Dependencies: 165 165 2898
-- Name: pk_idbl; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT pk_idbl PRIMARY KEY (idbl);


--
-- TOC entry 2583 (class 2606 OID 18149)
-- Dependencies: 169 169 2898
-- Name: pk_idcpp; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY currentportsproviders
    ADD CONSTRAINT pk_idcpp PRIMARY KEY (idport);


--
-- TOC entry 2681 (class 2606 OID 18434)
-- Dependencies: 236 236 2898
-- Name: pk_idgroups; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT pk_idgroups PRIMARY KEY (idgroup);


--
-- TOC entry 2585 (class 2606 OID 18151)
-- Dependencies: 170 170 2898
-- Name: pk_idincall; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY incomingcalls
    ADD CONSTRAINT pk_idincall PRIMARY KEY (idincall);


--
-- TOC entry 2587 (class 2606 OID 18153)
-- Dependencies: 173 173 2898
-- Name: pk_idl1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level1
    ADD CONSTRAINT pk_idl1 PRIMARY KEY (idl1);


--
-- TOC entry 2595 (class 2606 OID 18155)
-- Dependencies: 177 177 2898
-- Name: pk_idl2; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level2
    ADD CONSTRAINT pk_idl2 PRIMARY KEY (idl2);


--
-- TOC entry 2607 (class 2606 OID 18157)
-- Dependencies: 183 183 2898
-- Name: pk_idl3; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level3
    ADD CONSTRAINT pk_idl3 PRIMARY KEY (idl3);


--
-- TOC entry 2603 (class 2606 OID 18159)
-- Dependencies: 181 181 2898
-- Name: pk_idl4; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level4
    ADD CONSTRAINT pk_idl4 PRIMARY KEY (idl4);


--
-- TOC entry 2591 (class 2606 OID 18161)
-- Dependencies: 175 175 2898
-- Name: pk_idl5; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level5
    ADD CONSTRAINT pk_idl5 PRIMARY KEY (idl5);


--
-- TOC entry 2599 (class 2606 OID 18163)
-- Dependencies: 179 179 2898
-- Name: pk_idl6; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level6
    ADD CONSTRAINT pk_idl6 PRIMARY KEY (idl6);


--
-- TOC entry 2611 (class 2606 OID 18165)
-- Dependencies: 184 184 2898
-- Name: pk_idmodem; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY modem
    ADD CONSTRAINT pk_idmodem PRIMARY KEY (idmodem);


--
-- TOC entry 2689 (class 2606 OID 18901)
-- Dependencies: 241 241 2898
-- Name: pk_idnotify_notification_area; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notification_area
    ADD CONSTRAINT pk_idnotify_notification_area PRIMARY KEY (idnotify);


--
-- TOC entry 2617 (class 2606 OID 18167)
-- Dependencies: 188 188 2898
-- Name: pk_idoutgoinglog; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY outgoing_log
    ADD CONSTRAINT pk_idoutgoinglog PRIMARY KEY (idoutgoinglog);


--
-- TOC entry 2619 (class 2606 OID 18169)
-- Dependencies: 190 190 2898
-- Name: pk_idowner; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT pk_idowner PRIMARY KEY (idowner);


--
-- TOC entry 2627 (class 2606 OID 18171)
-- Dependencies: 194 194 2898
-- Name: pk_idprovider; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY provider
    ADD CONSTRAINT pk_idprovider PRIMARY KEY (idprovider);


--
-- TOC entry 2631 (class 2606 OID 18173)
-- Dependencies: 196 196 2898
-- Name: pk_idsim_sim; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sim
    ADD CONSTRAINT pk_idsim_sim PRIMARY KEY (idsim);


--
-- TOC entry 2633 (class 2606 OID 18175)
-- Dependencies: 198 198 2898
-- Name: pk_idsmsin; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smsin
    ADD CONSTRAINT pk_idsmsin PRIMARY KEY (idsmsin);


--
-- TOC entry 2637 (class 2606 OID 18177)
-- Dependencies: 207 207 2898
-- Name: pk_idwl; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT pk_idwl PRIMARY KEY (idwl);


--
-- TOC entry 2615 (class 2606 OID 18179)
-- Dependencies: 186 186 2898
-- Name: pk_outgoing; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY outgoing
    ADD CONSTRAINT pk_outgoing PRIMARY KEY (idsmsout);


--
-- TOC entry 2687 (class 2606 OID 18658)
-- Dependencies: 239 239 2898
-- Name: pk_tname; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tables_changed
    ADD CONSTRAINT pk_tname PRIMARY KEY (tname);


--
-- TOC entry 2581 (class 2606 OID 18181)
-- Dependencies: 167 167 167 2898
-- Name: uni_contact_typeofid_identification; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT uni_contact_typeofid_identification UNIQUE (typeofid, identification);


--
-- TOC entry 2613 (class 2606 OID 18183)
-- Dependencies: 184 184 2898
-- Name: uni_imei_modem; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY modem
    ADD CONSTRAINT uni_imei_modem UNIQUE (imei);


--
-- TOC entry 2683 (class 2606 OID 18436)
-- Dependencies: 236 236 2898
-- Name: uni_name_groups; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT uni_name_groups UNIQUE (name);


--
-- TOC entry 2589 (class 2606 OID 18185)
-- Dependencies: 173 173 2898
-- Name: uni_name_loc_l1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level1
    ADD CONSTRAINT uni_name_loc_l1 UNIQUE (name);


--
-- TOC entry 2597 (class 2606 OID 18187)
-- Dependencies: 177 177 177 2898
-- Name: uni_name_loc_l2; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level2
    ADD CONSTRAINT uni_name_loc_l2 UNIQUE (idl1, name);


--
-- TOC entry 2609 (class 2606 OID 18189)
-- Dependencies: 183 183 183 2898
-- Name: uni_name_loc_l3; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level3
    ADD CONSTRAINT uni_name_loc_l3 UNIQUE (idl2, name);


--
-- TOC entry 2605 (class 2606 OID 18191)
-- Dependencies: 181 181 181 2898
-- Name: uni_name_loc_l4; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level4
    ADD CONSTRAINT uni_name_loc_l4 UNIQUE (idl3, name);


--
-- TOC entry 2601 (class 2606 OID 18193)
-- Dependencies: 179 179 179 2898
-- Name: uni_name_loc_l6; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level6
    ADD CONSTRAINT uni_name_loc_l6 UNIQUE (idl5, name);


--
-- TOC entry 2621 (class 2606 OID 18195)
-- Dependencies: 190 190 2898
-- Name: uni_name_owners; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT uni_name_owners UNIQUE (name);


--
-- TOC entry 2629 (class 2606 OID 18197)
-- Dependencies: 194 194 2898
-- Name: uni_name_provider; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY provider
    ADD CONSTRAINT uni_name_provider UNIQUE (name);


--
-- TOC entry 2593 (class 2606 OID 18199)
-- Dependencies: 175 175 175 2898
-- Name: uni_nme_loc_l5; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location_level5
    ADD CONSTRAINT uni_nme_loc_l5 UNIQUE (name, idl4);


--
-- TOC entry 2625 (class 2606 OID 18201)
-- Dependencies: 192 192 192 2898
-- Name: uni_phones_phone_phoneext; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT uni_phones_phone_phoneext UNIQUE (phone, phone_ext);


--
-- TOC entry 2575 (class 2606 OID 18499)
-- Dependencies: 163 163 2898
-- Name: uni_pwd_admin; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT uni_pwd_admin UNIQUE (pwd);


--
-- TOC entry 2635 (class 2606 OID 27216)
-- Dependencies: 198 198 198 198 2898
-- Name: uni_smsin_date_phone_msg; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smsin
    ADD CONSTRAINT uni_smsin_date_phone_msg UNIQUE (datesms, phone, message);


SET search_path = usaga, pg_catalog;

--
-- TOC entry 2645 (class 2606 OID 18203)
-- Dependencies: 210 210 210 2898
-- Name: pk_account_contacts; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT pk_account_contacts PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2657 (class 2606 OID 18205)
-- Dependencies: 216 216 216 2898
-- Name: pk_account_notif_group; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications_group
    ADD CONSTRAINT pk_account_notif_group PRIMARY KEY (idaccount, ideventtype);


--
-- TOC entry 2659 (class 2606 OID 18207)
-- Dependencies: 218 218 218 2898
-- Name: pk_account_triggers_phones; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT pk_account_triggers_phones PRIMARY KEY (idaccount, idphone);


--
-- TOC entry 2661 (class 2606 OID 18209)
-- Dependencies: 219 219 219 2898
-- Name: pk_account_users; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT pk_account_users PRIMARY KEY (idaccount, idcontact);


--
-- TOC entry 2693 (class 2606 OID 35768)
-- Dependencies: 247 247 2898
-- Name: pk_accounts_idcontact; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT pk_accounts_idcontact PRIMARY KEY (idcontact);


--
-- TOC entry 2639 (class 2606 OID 18211)
-- Dependencies: 209 209 2898
-- Name: pk_idaccount; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT pk_idaccount PRIMARY KEY (idaccount);


--
-- TOC entry 2685 (class 2606 OID 18515)
-- Dependencies: 238 238 2898
-- Name: pk_idcomment_comment; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events_comments
    ADD CONSTRAINT pk_idcomment_comment PRIMARY KEY (idcomment);


--
-- TOC entry 2665 (class 2606 OID 18213)
-- Dependencies: 220 220 2898
-- Name: pk_idevent; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT pk_idevent PRIMARY KEY (idevent);


--
-- TOC entry 2667 (class 2606 OID 18215)
-- Dependencies: 221 221 2898
-- Name: pk_idevent_from_call; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events_generated_by_calls
    ADD CONSTRAINT pk_idevent_from_call PRIMARY KEY (idevent);


--
-- TOC entry 2669 (class 2606 OID 18217)
-- Dependencies: 223 223 2898
-- Name: pk_ideventtype; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY eventtypes
    ADD CONSTRAINT pk_ideventtype PRIMARY KEY (ideventtype);


--
-- TOC entry 2671 (class 2606 OID 18219)
-- Dependencies: 224 224 2898
-- Name: pk_idgroup; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY xxxgroups
    ADD CONSTRAINT pk_idgroup PRIMARY KEY (idgroup);


--
-- TOC entry 2647 (class 2606 OID 18221)
-- Dependencies: 212 212 2898
-- Name: pk_idinstallationdata; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT pk_idinstallationdata PRIMARY KEY (idinstallationdata);


--
-- TOC entry 2675 (class 2606 OID 18223)
-- Dependencies: 226 226 2898
-- Name: pk_idkeyword; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT pk_idkeyword PRIMARY KEY (idkeyword);


--
-- TOC entry 2651 (class 2606 OID 18225)
-- Dependencies: 213 213 2898
-- Name: pk_idnotifaccount; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT pk_idnotifaccount PRIMARY KEY (idnotifaccount);


--
-- TOC entry 2655 (class 2606 OID 18227)
-- Dependencies: 214 214 2898
-- Name: pk_idnotifphoneeventtype; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT pk_idnotifphoneeventtype PRIMARY KEY (idnotifphoneeventtype);


--
-- TOC entry 2677 (class 2606 OID 18229)
-- Dependencies: 228 228 2898
-- Name: pk_idnotiftempl; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notification_templates
    ADD CONSTRAINT pk_idnotiftempl PRIMARY KEY (idnotiftempl);


--
-- TOC entry 2679 (class 2606 OID 18231)
-- Dependencies: 230 230 2898
-- Name: pk_idpanelmodel; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY panelmodel
    ADD CONSTRAINT pk_idpanelmodel PRIMARY KEY (idpanelmodel);


--
-- TOC entry 2653 (class 2606 OID 18233)
-- Dependencies: 213 213 213 2898
-- Name: uni_acc_notyf_idacc_idphone; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT uni_acc_notyf_idacc_idphone UNIQUE (idaccount, idphone);


--
-- TOC entry 2641 (class 2606 OID 18235)
-- Dependencies: 209 209 2898
-- Name: uni_account_account; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_account UNIQUE (account);


--
-- TOC entry 2643 (class 2606 OID 18237)
-- Dependencies: 209 209 2898
-- Name: uni_account_name; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT uni_account_name UNIQUE (name);


--
-- TOC entry 2695 (class 2606 OID 35823)
-- Dependencies: 247 247 2898
-- Name: uni_account_name_accounts; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT uni_account_name_accounts UNIQUE (account_name);


--
-- TOC entry 2697 (class 2606 OID 35821)
-- Dependencies: 247 247 2898
-- Name: uni_account_number_accounts; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT uni_account_number_accounts UNIQUE (account_number);


--
-- TOC entry 2663 (class 2606 OID 18239)
-- Dependencies: 219 219 2898
-- Name: uni_account_user_idcontact; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT uni_account_user_idcontact UNIQUE (idcontact);


--
-- TOC entry 2699 (class 2606 OID 35825)
-- Dependencies: 247 247 247 2898
-- Name: uni_fname_lname_accounts; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT uni_fname_lname_accounts UNIQUE (firstname, lastname);


--
-- TOC entry 2649 (class 2606 OID 18241)
-- Dependencies: 212 212 2898
-- Name: uni_idaccount; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT uni_idaccount UNIQUE (idaccount);


--
-- TOC entry 2701 (class 2606 OID 35827)
-- Dependencies: 247 247 2898
-- Name: uni_identification_accounts; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT uni_identification_accounts UNIQUE (identification);


--
-- TOC entry 2673 (class 2606 OID 18243)
-- Dependencies: 224 224 2898
-- Name: uni_name_groups; Type: CONSTRAINT; Schema: usaga; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY xxxgroups
    ADD CONSTRAINT uni_name_groups UNIQUE (name);


SET search_path = public, pg_catalog;

--
-- TOC entry 2737 (class 2620 OID 18667)
-- Dependencies: 335 167 2898
-- Name: contacts_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER contacts_changed AFTER INSERT OR DELETE OR UPDATE ON contacts FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2776 (class 2620 OID 35420)
-- Dependencies: 335 236 2898
-- Name: groups_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER groups_changed AFTER INSERT OR DELETE OR UPDATE ON groups FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2740 (class 2620 OID 18673)
-- Dependencies: 170 335 2898
-- Name: incomingcalls_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER incomingcalls_changed AFTER INSERT OR DELETE OR UPDATE ON incomingcalls FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2738 (class 2620 OID 18244)
-- Dependencies: 170 321 2898
-- Name: incomingcalls_tac; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER incomingcalls_tac AFTER INSERT OR DELETE OR UPDATE ON incomingcalls FOR EACH ROW EXECUTE PROCEDURE incomingcalls_triggered_after_changing();


--
-- TOC entry 2779 (class 2620 OID 18902)
-- Dependencies: 335 241 2898
-- Name: notification_area_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER notification_area_changed AFTER INSERT ON notification_area FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2749 (class 2620 OID 18672)
-- Dependencies: 335 186 2898
-- Name: outgoing_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER outgoing_changed AFTER INSERT OR DELETE OR UPDATE ON outgoing FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2751 (class 2620 OID 18671)
-- Dependencies: 335 192 2898
-- Name: phones_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER phones_changed AFTER INSERT OR DELETE OR UPDATE ON phones FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2754 (class 2620 OID 18674)
-- Dependencies: 335 198 2898
-- Name: smsin_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER smsin_changed AFTER INSERT OR DELETE OR UPDATE ON smsin FOR EACH ROW EXECUTE PROCEDURE ctrl_tables_changed();


--
-- TOC entry 2734 (class 2620 OID 18245)
-- Dependencies: 162 261 2898
-- Name: ts_address; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_address AFTER UPDATE ON address FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2735 (class 2620 OID 18246)
-- Dependencies: 261 165 2898
-- Name: ts_blacklist; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_blacklist BEFORE UPDATE ON blacklist FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2736 (class 2620 OID 18247)
-- Dependencies: 261 167 2898
-- Name: ts_contacts; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_contacts BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2775 (class 2620 OID 18437)
-- Dependencies: 261 236 2898
-- Name: ts_groups; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_groups BEFORE UPDATE ON groups FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2739 (class 2620 OID 18248)
-- Dependencies: 170 261 2898
-- Name: ts_incomingcalls; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_incomingcalls BEFORE UPDATE ON incomingcalls FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2741 (class 2620 OID 18249)
-- Dependencies: 261 173 2898
-- Name: ts_loc_level1; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_loc_level1 BEFORE UPDATE ON location_level1 FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2743 (class 2620 OID 18250)
-- Dependencies: 177 261 2898
-- Name: ts_loc_level2; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_loc_level2 BEFORE UPDATE ON location_level2 FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2746 (class 2620 OID 18251)
-- Dependencies: 261 183 2898
-- Name: ts_loc_level3; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_loc_level3 BEFORE UPDATE ON location_level3 FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2745 (class 2620 OID 18252)
-- Dependencies: 181 261 2898
-- Name: ts_loc_level4; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_loc_level4 BEFORE UPDATE ON location_level4 FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2742 (class 2620 OID 18253)
-- Dependencies: 261 175 2898
-- Name: ts_loc_level5; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_loc_level5 BEFORE UPDATE ON location_level5 FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2744 (class 2620 OID 18254)
-- Dependencies: 261 179 2898
-- Name: ts_loc_level6; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_loc_level6 BEFORE UPDATE ON location_level6 FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2747 (class 2620 OID 18255)
-- Dependencies: 261 184 2898
-- Name: ts_modem; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_modem BEFORE UPDATE ON modem FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2748 (class 2620 OID 18256)
-- Dependencies: 186 261 2898
-- Name: ts_outgoing; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_outgoing BEFORE UPDATE ON outgoing FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2750 (class 2620 OID 18257)
-- Dependencies: 192 261 2898
-- Name: ts_phones; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_phones BEFORE UPDATE ON phones FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2752 (class 2620 OID 18258)
-- Dependencies: 261 194 2898
-- Name: ts_provider; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_provider BEFORE UPDATE ON provider FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2753 (class 2620 OID 18259)
-- Dependencies: 261 198 2898
-- Name: ts_smsin; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_smsin BEFORE UPDATE ON smsin FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


--
-- TOC entry 2755 (class 2620 OID 18260)
-- Dependencies: 261 207 2898
-- Name: ts_whitelist; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_whitelist BEFORE UPDATE ON whitelist FOR EACH ROW EXECUTE PROCEDURE ctrl_ts();


SET search_path = usaga, pg_catalog;

--
-- TOC entry 2757 (class 2620 OID 18668)
-- Dependencies: 209 335 2898
-- Name: account_changed; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER account_changed AFTER INSERT OR DELETE OR UPDATE ON account FOR EACH ROW EXECUTE PROCEDURE public.ctrl_tables_changed();


--
-- TOC entry 2781 (class 2620 OID 35819)
-- Dependencies: 247 335 2898
-- Name: accounts_changed; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER accounts_changed AFTER INSERT OR DELETE OR UPDATE ON accounts FOR EACH ROW EXECUTE PROCEDURE public.ctrl_tables_changed();


--
-- TOC entry 2768 (class 2620 OID 18261)
-- Dependencies: 275 221 2898
-- Name: events_by_calls_tai; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER events_by_calls_tai AFTER INSERT ON events_generated_by_calls FOR EACH ROW EXECUTE PROCEDURE event_trigger_after_changing();


--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 2768
-- Name: TRIGGER events_by_calls_tai ON events_generated_by_calls; Type: COMMENT; Schema: usaga; Owner: postgres
--

COMMENT ON TRIGGER events_by_calls_tai ON events_generated_by_calls IS 'Trigger after insert';


--
-- TOC entry 2767 (class 2620 OID 18669)
-- Dependencies: 220 335 2898
-- Name: events_changed; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER events_changed AFTER INSERT OR DELETE OR UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE public.ctrl_tables_changed();


--
-- TOC entry 2778 (class 2620 OID 18670)
-- Dependencies: 238 335 2898
-- Name: events_comments_changed; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER events_comments_changed AFTER INSERT OR DELETE OR UPDATE ON events_comments FOR EACH ROW EXECUTE PROCEDURE public.ctrl_tables_changed();


--
-- TOC entry 2765 (class 2620 OID 18262)
-- Dependencies: 220 275 2898
-- Name: events_tac; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER events_tac AFTER INSERT ON events FOR EACH ROW EXECUTE PROCEDURE event_trigger_after_changing();


--
-- TOC entry 2770 (class 2620 OID 18675)
-- Dependencies: 335 223 2898
-- Name: eventtypes_changed; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER eventtypes_changed AFTER INSERT OR DELETE OR UPDATE ON eventtypes FOR EACH ROW EXECUTE PROCEDURE public.ctrl_tables_changed();


--
-- TOC entry 2756 (class 2620 OID 18263)
-- Dependencies: 209 261 2898
-- Name: ts_account; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account BEFORE UPDATE ON account FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2758 (class 2620 OID 18264)
-- Dependencies: 210 261 2898
-- Name: ts_account_contacts; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_contacts BEFORE UPDATE ON account_contacts FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2759 (class 2620 OID 18265)
-- Dependencies: 212 261 2898
-- Name: ts_account_installationdata; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_installationdata BEFORE UPDATE ON account_installationdata FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2760 (class 2620 OID 18266)
-- Dependencies: 213 261 2898
-- Name: ts_account_notifications; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_notifications BEFORE UPDATE ON account_notifications FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2761 (class 2620 OID 18267)
-- Dependencies: 261 214 2898
-- Name: ts_account_notifications_eventtype; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_notifications_eventtype BEFORE UPDATE ON account_notifications_eventtype FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2762 (class 2620 OID 18268)
-- Dependencies: 216 261 2898
-- Name: ts_account_notifications_group; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_notifications_group BEFORE UPDATE ON account_notifications_group FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2763 (class 2620 OID 18269)
-- Dependencies: 218 261 2898
-- Name: ts_account_phones_trigger_alarm; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_phones_trigger_alarm BEFORE UPDATE ON account_phones_trigger_alarm FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2764 (class 2620 OID 18270)
-- Dependencies: 261 219 2898
-- Name: ts_account_users; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_account_users BEFORE UPDATE ON account_users FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2780 (class 2620 OID 35818)
-- Dependencies: 247 261 2898
-- Name: ts_accounts; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_accounts AFTER INSERT OR UPDATE ON accounts FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2766 (class 2620 OID 18271)
-- Dependencies: 220 261 2898
-- Name: ts_events; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_events BEFORE UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2777 (class 2620 OID 18599)
-- Dependencies: 261 238 2898
-- Name: ts_events; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_events BEFORE UPDATE ON events_comments FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2769 (class 2620 OID 18272)
-- Dependencies: 261 223 2898
-- Name: ts_eventtypes; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_eventtypes BEFORE UPDATE ON eventtypes FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2771 (class 2620 OID 18273)
-- Dependencies: 261 224 2898
-- Name: ts_groups; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_groups BEFORE UPDATE ON xxxgroups FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2772 (class 2620 OID 18274)
-- Dependencies: 261 226 2898
-- Name: ts_keywords; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_keywords BEFORE UPDATE ON keywords FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2773 (class 2620 OID 18275)
-- Dependencies: 228 261 2898
-- Name: ts_notification_templates; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_notification_templates BEFORE UPDATE ON notification_templates FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


--
-- TOC entry 2774 (class 2620 OID 18276)
-- Dependencies: 261 230 2898
-- Name: ts_panelmodel; Type: TRIGGER; Schema: usaga; Owner: postgres
--

CREATE TRIGGER ts_panelmodel BEFORE UPDATE ON panelmodel FOR EACH ROW EXECUTE PROCEDURE public.ctrl_ts();


SET search_path = public, pg_catalog;

--
-- TOC entry 2704 (class 2606 OID 35884)
-- Dependencies: 2570 162 167 2898
-- Name: fk_idaddress_contacts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT fk_idaddress_contacts FOREIGN KEY (idaddress) REFERENCES address(idaddress) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2715 (class 2606 OID 18282)
-- Dependencies: 192 162 2570 2898
-- Name: fk_idaddress_phones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT fk_idaddress_phones FOREIGN KEY (idaddress) REFERENCES address(idaddress) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2716 (class 2606 OID 18287)
-- Dependencies: 192 167 2578 2898
-- Name: fk_idcontact; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT fk_idcontact FOREIGN KEY (idcontact) REFERENCES contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2702 (class 2606 OID 18493)
-- Dependencies: 2578 163 167 2898
-- Name: fk_idcontact_admin; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT fk_idcontact_admin FOREIGN KEY (idcontact) REFERENCES contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2705 (class 2606 OID 35889)
-- Dependencies: 2680 167 236 2898
-- Name: fk_idgroup1_contacts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT fk_idgroup1_contacts FOREIGN KEY (idgroup1) REFERENCES groups(idgroup) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2706 (class 2606 OID 35894)
-- Dependencies: 167 2680 236 2898
-- Name: fk_idgroup2_contacts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT fk_idgroup2_contacts FOREIGN KEY (idgroup2) REFERENCES groups(idgroup) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2707 (class 2606 OID 35899)
-- Dependencies: 236 167 2680 2898
-- Name: fk_idgroup3_contacts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT fk_idgroup3_contacts FOREIGN KEY (idgroup3) REFERENCES groups(idgroup) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2709 (class 2606 OID 18297)
-- Dependencies: 177 173 2586 2898
-- Name: fk_idl1_loc_l2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_level2
    ADD CONSTRAINT fk_idl1_loc_l2 FOREIGN KEY (idl1) REFERENCES location_level1(idl1) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2712 (class 2606 OID 18302)
-- Dependencies: 183 177 2594 2898
-- Name: fk_idl2_loc_l3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_level3
    ADD CONSTRAINT fk_idl2_loc_l3 FOREIGN KEY (idl2) REFERENCES location_level2(idl2) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2711 (class 2606 OID 18307)
-- Dependencies: 181 183 2606 2898
-- Name: fk_idl3_loc_l4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_level4
    ADD CONSTRAINT fk_idl3_loc_l4 FOREIGN KEY (idl3) REFERENCES location_level3(idl3) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2708 (class 2606 OID 18312)
-- Dependencies: 181 2602 175 2898
-- Name: fk_idl4_loc_l5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_level5
    ADD CONSTRAINT fk_idl4_loc_l5 FOREIGN KEY (idl4) REFERENCES location_level4(idl4) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2710 (class 2606 OID 18317)
-- Dependencies: 175 179 2590 2898
-- Name: fk_idl5_l6; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_level6
    ADD CONSTRAINT fk_idl5_l6 FOREIGN KEY (idl5) REFERENCES location_level5(idl5) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2703 (class 2606 OID 18322)
-- Dependencies: 2622 192 165 2898
-- Name: fk_idphone; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blacklist
    ADD CONSTRAINT fk_idphone FOREIGN KEY (idphone) REFERENCES phones(idphone);


--
-- TOC entry 2719 (class 2606 OID 18327)
-- Dependencies: 2622 207 192 2898
-- Name: fk_idphone; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY whitelist
    ADD CONSTRAINT fk_idphone FOREIGN KEY (idphone) REFERENCES phones(idphone);


--
-- TOC entry 2713 (class 2606 OID 18332)
-- Dependencies: 2622 192 186 2898
-- Name: fk_idphone_outgoing; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY outgoing
    ADD CONSTRAINT fk_idphone_outgoing FOREIGN KEY (idphone) REFERENCES phones(idphone) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2717 (class 2606 OID 18337)
-- Dependencies: 194 2626 192 2898
-- Name: fk_idprovider_phones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT fk_idprovider_phones FOREIGN KEY (idprovider) REFERENCES provider(idprovider) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2718 (class 2606 OID 18342)
-- Dependencies: 2626 194 196 2898
-- Name: fk_idprovider_sim; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sim
    ADD CONSTRAINT fk_idprovider_sim FOREIGN KEY (idprovider) REFERENCES provider(idprovider) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2714 (class 2606 OID 18347)
-- Dependencies: 186 2614 188 2898
-- Name: fk_idsmsout_log; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY outgoing_log
    ADD CONSTRAINT fk_idsmsout_log FOREIGN KEY (idsmsout) REFERENCES outgoing(idsmsout) ON UPDATE CASCADE ON DELETE SET NULL;


SET search_path = usaga, pg_catalog;

--
-- TOC entry 2729 (class 2606 OID 18352)
-- Dependencies: 2638 209 218 2898
-- Name: fk_accnt_trigg_idaccount; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2730 (class 2606 OID 18357)
-- Dependencies: 218 2622 192 2898
-- Name: fk_accnt_trigg_idphone; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_phones_trigger_alarm
    ADD CONSTRAINT fk_accnt_trigg_idphone FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2720 (class 2606 OID 18362)
-- Dependencies: 209 167 2578 2898
-- Name: fk_account_idcontact; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account
    ADD CONSTRAINT fk_account_idcontact FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2731 (class 2606 OID 18367)
-- Dependencies: 219 2638 209 2898
-- Name: fk_account_users_idaccount; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2732 (class 2606 OID 18372)
-- Dependencies: 167 2578 219 2898
-- Name: fk_account_users_idcontact; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT fk_account_users_idcontact FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2724 (class 2606 OID 35712)
-- Dependencies: 209 212 2638 2898
-- Name: fk_idaccount; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idaccount FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2722 (class 2606 OID 18382)
-- Dependencies: 2638 209 210 2898
-- Name: fk_idaccount_contacts; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idaccount_contacts FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2726 (class 2606 OID 18387)
-- Dependencies: 2638 213 209 2898
-- Name: fk_idaccount_notif; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idaccount_notif FOREIGN KEY (idaccount) REFERENCES account(idaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2723 (class 2606 OID 18392)
-- Dependencies: 210 2578 167 2898
-- Name: fk_idcontact_contacts; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_contacts
    ADD CONSTRAINT fk_idcontact_contacts FOREIGN KEY (idcontact) REFERENCES public.contacts(idcontact) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2733 (class 2606 OID 35637)
-- Dependencies: 220 2664 238 2898
-- Name: fk_idevent_events_comments; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY events_comments
    ADD CONSTRAINT fk_idevent_events_comments FOREIGN KEY (idevent) REFERENCES events(idevent) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2721 (class 2606 OID 18397)
-- Dependencies: 224 2670 209 2898
-- Name: fk_idgroup_account; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account
    ADD CONSTRAINT fk_idgroup_account FOREIGN KEY (idgroup) REFERENCES xxxgroups(idgroup) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2728 (class 2606 OID 18402)
-- Dependencies: 2650 214 213 2898
-- Name: fk_idnotifaccount_eetype; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications_eventtype
    ADD CONSTRAINT fk_idnotifaccount_eetype FOREIGN KEY (idnotifaccount) REFERENCES account_notifications(idnotifaccount) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2725 (class 2606 OID 35717)
-- Dependencies: 230 2678 212 2898
-- Name: fk_idpanelmodel; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_installationdata
    ADD CONSTRAINT fk_idpanelmodel FOREIGN KEY (idpanelmodel) REFERENCES panelmodel(idpanelmodel) ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- TOC entry 2727 (class 2606 OID 18412)
-- Dependencies: 192 213 2622 2898
-- Name: fk_idphone_notif; Type: FK CONSTRAINT; Schema: usaga; Owner: postgres
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT fk_idphone_notif FOREIGN KEY (idphone) REFERENCES public.phones(idphone) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2014-08-06 08:13:51 ECT

--
-- PostgreSQL database dump complete
--

