# uSAGA - Micro Sistema Automático de Gestión de Alarmas

***

## _uSAGA_ es un proyecto OpenSource para administración de alarmas, muy adaptable.

Inicialmente orientado para manejar alarmas comunitarias con notificaciones via SMS, actualmente sigue en crecimiento y desarrollo.

Entre las principales caracteristicas están:
* Interface web para funcionar facilmente en red
* Utiliza modems GSM para el envío y recepción de mensajes de texto (SMS) y llamadas telefónicas.
* Geoposicionamiento de clientes usando OpenStreetMap (OSM)
* Cantidad ilimitada (depende de la capacidad del computador) de usuarios.
* Permite grupos de usuarios
* Una vez configurado puede funcionar de forma totalmente autónoma
* Las notificaciones vía sms pueden contener datos de la persona que produjo la alarma, datos como: nombres, direcciones, teléfonos, geoposicionamiento, etc, pueden ser incluidos fácilmente.

Está escrito en Vala por lo que se puede compilar facilmente para que corra en Linux y Windows. Usa PostgreSQL como base de datos, SQLite para guardar algunas configuraciones.

Para la configuración y administración del sistema usa una interface web, que ha sido implementada usando AJAX, Dojo y HTML5.

El proyecto requiere de ayuda, ya sea económica, con ideas, aportes de codigo, depuración, lo que sea es bienvenido.

***


uSAGA depende de las siguientes librerias:

* [libspire_usms](https://github.com/edwinspire/libspire_usms): Librería Base de uSMS
* [uSMS](https://github.com/edwinspire/usms): uSMS - Micro Servidor de Mensajes de Texto
* [libspire_pg](https://github.com/edwinspire/libspire_pg): Librería para conexión con PostgreSQL
* [libspire_uhttp](https://github.com/edwinspire/libspire_uhttp): Librería para crear un micro servidor web para la interface gráfica.
* [libspire_pdu](https://github.com/edwinspire/libspire_pdu): Librería para codificar y decodificar mensajes de texto en formato PDU.
* [libspire_gsm](https://github.com/edwinspire/libspire_gsm): Librería para manejo de modems GSM.
* [libspire_serial](https://github.com/edwinspire/libspire_serial): Librería para comunicación con puertos seriales.


***
### Soporte o Contacto
Puede reportar algún bug en el sistema a:
* edwinspire@gmail.com
* usaga@edwinspire.com
* software@edwinspire.com
* o de preferencia a [Issues](https://github.com/edwinspire/opensaga/issues) para poder hacer un seguimiento y solucionarlo.


Más información la puede encontrar en:
* [Página oficial de EDWINSPIRE] (http://www.edwinspire.com)
* [Página oficial de uSAGA - Software](http://www.usaga-software.edwinspire.com)
* [Página de Software libre para Alarmas Comunitarias](http://www.alarmascomunitarias.edwinspire.com)
