/* libspire_serial.h generated by valac 0.16.1, the Vala compiler, do not modify */


#ifndef ___HOME_EDWINSPIRE_PROGRAMACION_PROYECTOSSOFTWARE_SOFTWARE_VALA_PROYECTOSVALA_PROYECTS_LIBSPIRE_SERIAL_BIN_LNX_LIBSPIRE_SERIAL_H__
#define ___HOME_EDWINSPIRE_PROGRAMACION_PROYECTOSSOFTWARE_SOFTWARE_VALA_PROYECTOSVALA_PROYECTS_LIBSPIRE_SERIAL_BIN_LNX_LIBSPIRE_SERIAL_H__

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>
#include <math.h>
#include <gee.h>

G_BEGIN_DECLS


#define EDWINSPIRE_PORTS_TYPE_HAND_SHAKING (edwinspire_ports_hand_shaking_get_type ())

#define EDWINSPIRE_PORTS_TYPE_PARITY (edwinspire_ports_parity_get_type ())

#define EDWINSPIRE_PORTS_TYPE_STOP_BITS (edwinspire_ports_stop_bits_get_type ())

#define EDWINSPIRE_PORTS_TYPE_DATA_STATUS (edwinspire_ports_data_status_get_type ())

#define EDWINSPIRE_PORTS_TYPE_CONFIGURE (edwinspire_ports_configure_get_type ())
#define EDWINSPIRE_PORTS_CONFIGURE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EDWINSPIRE_PORTS_TYPE_CONFIGURE, edwinspirePortsConfigure))
#define EDWINSPIRE_PORTS_CONFIGURE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EDWINSPIRE_PORTS_TYPE_CONFIGURE, edwinspirePortsConfigureClass))
#define EDWINSPIRE_PORTS_IS_CONFIGURE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EDWINSPIRE_PORTS_TYPE_CONFIGURE))
#define EDWINSPIRE_PORTS_IS_CONFIGURE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EDWINSPIRE_PORTS_TYPE_CONFIGURE))
#define EDWINSPIRE_PORTS_CONFIGURE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EDWINSPIRE_PORTS_TYPE_CONFIGURE, edwinspirePortsConfigureClass))

typedef struct _edwinspirePortsConfigure edwinspirePortsConfigure;
typedef struct _edwinspirePortsConfigureClass edwinspirePortsConfigureClass;
typedef struct _edwinspirePortsConfigurePrivate edwinspirePortsConfigurePrivate;

#define EDWINSPIRE_PORTS_TYPE_SERIAL_PORT (edwinspire_ports_serial_port_get_type ())
#define EDWINSPIRE_PORTS_SERIAL_PORT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EDWINSPIRE_PORTS_TYPE_SERIAL_PORT, edwinspirePortsSerialPort))
#define EDWINSPIRE_PORTS_SERIAL_PORT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EDWINSPIRE_PORTS_TYPE_SERIAL_PORT, edwinspirePortsSerialPortClass))
#define EDWINSPIRE_PORTS_IS_SERIAL_PORT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EDWINSPIRE_PORTS_TYPE_SERIAL_PORT))
#define EDWINSPIRE_PORTS_IS_SERIAL_PORT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EDWINSPIRE_PORTS_TYPE_SERIAL_PORT))
#define EDWINSPIRE_PORTS_SERIAL_PORT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EDWINSPIRE_PORTS_TYPE_SERIAL_PORT, edwinspirePortsSerialPortClass))

typedef struct _edwinspirePortsSerialPort edwinspirePortsSerialPort;
typedef struct _edwinspirePortsSerialPortClass edwinspirePortsSerialPortClass;
typedef struct _edwinspirePortsSerialPortPrivate edwinspirePortsSerialPortPrivate;

#define EDWINSPIRE_PORTS_TYPE_DTMF (edwinspire_ports_dtmf_get_type ())

#define EDWINSPIRE_PORTS_TYPE_RESPONSE_CODE (edwinspire_ports_response_code_get_type ())

#define EDWINSPIRE_PORTS_TYPE_CME (edwinspire_ports_cme_get_type ())

#define EDWINSPIRE_PORTS_TYPE_RESPONSE (edwinspire_ports_response_get_type ())
#define EDWINSPIRE_PORTS_RESPONSE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EDWINSPIRE_PORTS_TYPE_RESPONSE, edwinspirePortsResponse))
#define EDWINSPIRE_PORTS_RESPONSE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EDWINSPIRE_PORTS_TYPE_RESPONSE, edwinspirePortsResponseClass))
#define EDWINSPIRE_PORTS_IS_RESPONSE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EDWINSPIRE_PORTS_TYPE_RESPONSE))
#define EDWINSPIRE_PORTS_IS_RESPONSE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EDWINSPIRE_PORTS_TYPE_RESPONSE))
#define EDWINSPIRE_PORTS_RESPONSE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EDWINSPIRE_PORTS_TYPE_RESPONSE, edwinspirePortsResponseClass))

typedef struct _edwinspirePortsResponse edwinspirePortsResponse;
typedef struct _edwinspirePortsResponseClass edwinspirePortsResponseClass;
typedef struct _edwinspirePortsResponsePrivate edwinspirePortsResponsePrivate;

#define EDWINSPIRE_PORTS_TYPE_CMS (edwinspire_ports_cms_get_type ())

#define EDWINSPIRE_PORTS_TYPE_LAST_CALL_RECEIVED (edwinspire_ports_last_call_received_get_type ())
typedef struct _edwinspirePortsLastCallReceived edwinspirePortsLastCallReceived;

#define EDWINSPIRE_PORTS_TYPE_MODEM (edwinspire_ports_modem_get_type ())
#define EDWINSPIRE_PORTS_MODEM(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EDWINSPIRE_PORTS_TYPE_MODEM, edwinspirePortsModem))
#define EDWINSPIRE_PORTS_MODEM_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EDWINSPIRE_PORTS_TYPE_MODEM, edwinspirePortsModemClass))
#define EDWINSPIRE_PORTS_IS_MODEM(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EDWINSPIRE_PORTS_TYPE_MODEM))
#define EDWINSPIRE_PORTS_IS_MODEM_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EDWINSPIRE_PORTS_TYPE_MODEM))
#define EDWINSPIRE_PORTS_MODEM_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EDWINSPIRE_PORTS_TYPE_MODEM, edwinspirePortsModemClass))

typedef struct _edwinspirePortsModem edwinspirePortsModem;
typedef struct _edwinspirePortsModemClass edwinspirePortsModemClass;
typedef struct _edwinspirePortsModemPrivate edwinspirePortsModemPrivate;

typedef enum  {
	EDWINSPIRE_PORTS_HAND_SHAKING_NONE,
	EDWINSPIRE_PORTS_HAND_SHAKING_RTS_CTS,
	EDWINSPIRE_PORTS_HAND_SHAKING_XOnXOff,
	EDWINSPIRE_PORTS_HAND_SHAKING_DTR_DSR
} edwinspirePortsHandShaking;

typedef enum  {
	EDWINSPIRE_PORTS_PARITY_NONE,
	EDWINSPIRE_PORTS_PARITY_ODD,
	EDWINSPIRE_PORTS_PARITY_EVEN,
	EDWINSPIRE_PORTS_PARITY_MARK,
	EDWINSPIRE_PORTS_PARITY_SPACE
} edwinspirePortsParity;

typedef enum  {
	EDWINSPIRE_PORTS_STOP_BITS_NONE,
	EDWINSPIRE_PORTS_STOP_BITS_ONE,
	EDWINSPIRE_PORTS_STOP_BITS_TWO
} edwinspirePortsStopBits;

typedef enum  {
	EDWINSPIRE_PORTS_DATA_STATUS_None,
	EDWINSPIRE_PORTS_DATA_STATUS_Sending,
	EDWINSPIRE_PORTS_DATA_STATUS_Receiving
} edwinspirePortsDataStatus;

struct _edwinspirePortsConfigure {
	GObject parent_instance;
	edwinspirePortsConfigurePrivate * priv;
};

struct _edwinspirePortsConfigureClass {
	GObjectClass parent_class;
};

struct _edwinspirePortsSerialPort {
	edwinspirePortsConfigure parent_instance;
	edwinspirePortsSerialPortPrivate * priv;
	gboolean LogModem;
};

struct _edwinspirePortsSerialPortClass {
	edwinspirePortsConfigureClass parent_class;
};

typedef enum  {
	EDWINSPIRE_PORTS_DTMF_Zero,
	EDWINSPIRE_PORTS_DTMF_One,
	EDWINSPIRE_PORTS_DTMF_Two,
	EDWINSPIRE_PORTS_DTMF_Three,
	EDWINSPIRE_PORTS_DTMF_Four,
	EDWINSPIRE_PORTS_DTMF_Five,
	EDWINSPIRE_PORTS_DTMF_Six,
	EDWINSPIRE_PORTS_DTMF_Sever,
	EDWINSPIRE_PORTS_DTMF_Eigth,
	EDWINSPIRE_PORTS_DTMF_Nine,
	EDWINSPIRE_PORTS_DTMF_Asterisc,
	EDWINSPIRE_PORTS_DTMF_Sharp
} edwinspirePortsDTMF;

typedef enum  {
	EDWINSPIRE_PORTS_RESPONSE_CODE_OK = 0,
	EDWINSPIRE_PORTS_RESPONSE_CODE_CONNECT = 1,
	EDWINSPIRE_PORTS_RESPONSE_CODE_RING = 2,
	EDWINSPIRE_PORTS_RESPONSE_CODE_NOCARRIER = 3,
	EDWINSPIRE_PORTS_RESPONSE_CODE_ERROR = 4,
	EDWINSPIRE_PORTS_RESPONSE_CODE_NODIALTONE = 5,
	EDWINSPIRE_PORTS_RESPONSE_CODE_BUSY = 6,
	EDWINSPIRE_PORTS_RESPONSE_CODE_NOANSWER = 7,
	EDWINSPIRE_PORTS_RESPONSE_CODE_ERROR_CMS = 98,
	EDWINSPIRE_PORTS_RESPONSE_CODE_ERROR_CME = 99,
	EDWINSPIRE_PORTS_RESPONSE_CODE_UNKNOW = 100
} edwinspirePortsResponseCode;

typedef enum  {
	EDWINSPIRE_PORTS_CME_PhoneFailure = 0,
	EDWINSPIRE_PORTS_CME_NoConnectionToPhone = 1,
	EDWINSPIRE_PORTS_CME_PhoneAdaptorLinkReserved = 2,
	EDWINSPIRE_PORTS_CME_OperationNotAllowed = 3,
	EDWINSPIRE_PORTS_CME_OperationNotSupported = 4,
	EDWINSPIRE_PORTS_CME_PH_SIM_PIN_Required = 5,
	EDWINSPIRE_PORTS_CME_PH_FSIM_PIN_Rrequired = 6,
	EDWINSPIRE_PORTS_CME_PH_FSIM_PUK_Required = 7,
	EDWINSPIRE_PORTS_CME_SIM_NotInserted = 10,
	EDWINSPIRE_PORTS_CME_SIM_PIN_Required = 11,
	EDWINSPIRE_PORTS_CME_SIM_PUK_Required = 12,
	EDWINSPIRE_PORTS_CME_SIM_Failure = 13,
	EDWINSPIRE_PORTS_CME_SIM_Busy = 14,
	EDWINSPIRE_PORTS_CME_SIM_Wrong = 15,
	EDWINSPIRE_PORTS_CME_IncorrectPassword = 16,
	EDWINSPIRE_PORTS_CME_SIM_PIN2_Required = 17,
	EDWINSPIRE_PORTS_CME_SIM_PUK2_Rrequired = 18,
	EDWINSPIRE_PORTS_CME_MemoryFull = 20,
	EDWINSPIRE_PORTS_CME_InvalidIndex = 21,
	EDWINSPIRE_PORTS_CME_NotFound = 22,
	EDWINSPIRE_PORTS_CME_MemoryFailure = 23,
	EDWINSPIRE_PORTS_CME_TextStringTooLong = 24,
	EDWINSPIRE_PORTS_CME_InvalidCharactersInTextString = 25,
	EDWINSPIRE_PORTS_CME_DialStringTooLong = 26,
	EDWINSPIRE_PORTS_CME_InvalidCharactersInDialString = 27,
	EDWINSPIRE_PORTS_CME_NoNetworkService = 30,
	EDWINSPIRE_PORTS_CME_NetworkTimeout = 31,
	EDWINSPIRE_PORTS_CME_EmergencyCallsOnly = 32,
	EDWINSPIRE_PORTS_CME_NetworkPersonalizationPIN_Required = 40,
	EDWINSPIRE_PORTS_CME_NetworkPersonalization_PUK_Required = 41,
	EDWINSPIRE_PORTS_CME_NetworkSubsetPersonalization_PIN_Required = 42,
	EDWINSPIRE_PORTS_CME_NetworkSubsetPersonalization_PUK_Required = 43,
	EDWINSPIRE_PORTS_CME_ServiceProviderPersonalization_PIN_Required = 44,
	EDWINSPIRE_PORTS_CME_ServiceProviderPersonalization_PUK_Required = 45,
	EDWINSPIRE_PORTS_CME_CorporatePersonalization_PIN_Required = 46,
	EDWINSPIRE_PORTS_CME_CorporatePersonalization_PUK_Required = 47,
	EDWINSPIRE_PORTS_CME_Unknown = 100,
	EDWINSPIRE_PORTS_CME_None = 1000
} edwinspirePortsCME;

typedef enum  {
	EDWINSPIRE_PORTS_CMS_Phonefailure = 300,
	EDWINSPIRE_PORTS_CMS_SMSServiceOfPhoneReserved = 301,
	EDWINSPIRE_PORTS_CMS_OperationNotAllowed = 302,
	EDWINSPIRE_PORTS_CMS_OperationNotSupported = 303,
	EDWINSPIRE_PORTS_CMS_InvalidPDUModeParameter = 304,
	EDWINSPIRE_PORTS_CMS_InvalidTextModeParameter = 305,
	EDWINSPIRE_PORTS_CMS_SIMNotInserted = 310,
	EDWINSPIRE_PORTS_CMS_SIMPINNecessary = 311,
	EDWINSPIRE_PORTS_CMS_PH_SIMPINNecessary = 312,
	EDWINSPIRE_PORTS_CMS_SIMFailure = 313,
	EDWINSPIRE_PORTS_CMS_SIMBusy = 314,
	EDWINSPIRE_PORTS_CMS_SIMWrong = 315,
	EDWINSPIRE_PORTS_CMS_MemoryFailure = 320,
	EDWINSPIRE_PORTS_CMS_InvalidMemoryIndex = 321,
	EDWINSPIRE_PORTS_CMS_MemoryFull = 322,
	EDWINSPIRE_PORTS_CMS_SMSCAddressUnknown = 330,
	EDWINSPIRE_PORTS_CMS_NoNetworkService = 331,
	EDWINSPIRE_PORTS_CMS_NetworkTimeout = 332,
	EDWINSPIRE_PORTS_CMS_UnknownError = 500,
	EDWINSPIRE_PORTS_CMS_ManufacturerSpecific = 512,
	EDWINSPIRE_PORTS_CMS_None = 1000
} edwinspirePortsCMS;

struct _edwinspirePortsResponse {
	GObject parent_instance;
	edwinspirePortsResponsePrivate * priv;
	edwinspirePortsCME CMEError;
	edwinspirePortsCMS CMSError;
	edwinspirePortsResponseCode Return;
	gchar* Raw;
	GeeArrayList* Lines;
};

struct _edwinspirePortsResponseClass {
	GObjectClass parent_class;
};

struct _edwinspirePortsLastCallReceived {
	gchar* Number;
	GDateTime* Date;
	gboolean Read;
};

struct _edwinspirePortsModem {
	edwinspirePortsSerialPort parent_instance;
	edwinspirePortsModemPrivate * priv;
	edwinspirePortsLastCallReceived LastCall;
};

struct _edwinspirePortsModemClass {
	edwinspirePortsSerialPortClass parent_class;
};


GType edwinspire_ports_hand_shaking_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_parity_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_stop_bits_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_data_status_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_configure_get_type (void) G_GNUC_CONST;
edwinspirePortsConfigure* edwinspire_ports_configure_new (void);
edwinspirePortsConfigure* edwinspire_ports_configure_construct (GType object_type);
const gchar* edwinspire_ports_configure_get_Port (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_Port (edwinspirePortsConfigure* self, const gchar* value);
guint edwinspire_ports_configure_get_BaudRate (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_BaudRate (edwinspirePortsConfigure* self, guint value);
edwinspirePortsParity edwinspire_ports_configure_get_Parityp (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_Parityp (edwinspirePortsConfigure* self, edwinspirePortsParity value);
edwinspirePortsStopBits edwinspire_ports_configure_get_StopBitsp (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_StopBitsp (edwinspirePortsConfigure* self, edwinspirePortsStopBits value);
guint edwinspire_ports_configure_get_DataBits (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_DataBits (edwinspirePortsConfigure* self, guint value);
edwinspirePortsHandShaking edwinspire_ports_configure_get_HandShake (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_HandShake (edwinspirePortsConfigure* self, edwinspirePortsHandShaking value);
gboolean edwinspire_ports_configure_get_Enable (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_Enable (edwinspirePortsConfigure* self, gboolean value);
gulong edwinspire_ports_configure_get_BufferIn (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_BufferIn (edwinspirePortsConfigure* self, gulong value);
gulong edwinspire_ports_configure_get_BufferOut (edwinspirePortsConfigure* self);
void edwinspire_ports_configure_set_BufferOut (edwinspirePortsConfigure* self, gulong value);
GType edwinspire_ports_serial_port_get_type (void) G_GNUC_CONST;
edwinspirePortsSerialPort* edwinspire_ports_serial_port_new_with_args (const gchar* Port_, guint Baudrate, guint DataBits, edwinspirePortsParity Parity_, edwinspirePortsStopBits StopBits_, edwinspirePortsHandShaking HS_);
edwinspirePortsSerialPort* edwinspire_ports_serial_port_construct_with_args (GType object_type, const gchar* Port_, guint Baudrate, guint DataBits, edwinspirePortsParity Parity_, edwinspirePortsStopBits StopBits_, edwinspirePortsHandShaking HS_);
edwinspirePortsSerialPort* edwinspire_ports_serial_port_new (void);
edwinspirePortsSerialPort* edwinspire_ports_serial_port_construct (GType object_type);
gboolean edwinspire_ports_serial_port_DiscardBuffer (edwinspirePortsSerialPort* self);
gchar** edwinspire_ports_serial_port_Get_PortName (edwinspirePortsSerialPort* self, int* result_length1);
gboolean edwinspire_ports_serial_port_Time (edwinspirePortsSerialPort* self, guint Time_);
gboolean edwinspire_ports_serial_port_Open (edwinspirePortsSerialPort* self);
glong edwinspire_ports_serial_port_Write (edwinspirePortsSerialPort* self, const gchar* Data_);
gchar edwinspire_ports_serial_port_ReadChar (edwinspirePortsSerialPort* self);
void edwinspire_ports_serial_port_LogCommandAT (const gchar* text);
gdouble edwinspire_ports_serial_port_BaudRateTouseg (edwinspirePortsSerialPort* self);
gdouble edwinspire_ports_serial_port_BaudRateTomseg (edwinspirePortsSerialPort* self);
gchar* edwinspire_ports_serial_port_ReadLine (edwinspirePortsSerialPort* self, gdouble timeout_ms_for_line);
gchar* edwinspire_ports_serial_port_ReadLineWithoutStrip (edwinspirePortsSerialPort* self, gdouble timeout_ms_for_line);
gchar* edwinspire_ports_serial_port_Strip (const gchar* String);
gboolean edwinspire_ports_serial_port_Close (edwinspirePortsSerialPort* self);
gboolean edwinspire_ports_serial_port_get_Blocking (edwinspirePortsSerialPort* self);
void edwinspire_ports_serial_port_set_Blocking (edwinspirePortsSerialPort* self, gboolean value);
gint edwinspire_ports_serial_port_get_BytesToRead (edwinspirePortsSerialPort* self);
gboolean edwinspire_ports_serial_port_get_IsOpen (edwinspirePortsSerialPort* self);
GType edwinspire_ports_dtmf_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_response_code_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_cme_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_response_get_type (void) G_GNUC_CONST;
GType edwinspire_ports_cms_get_type (void) G_GNUC_CONST;
edwinspirePortsResponse* edwinspire_ports_response_new_with_args (edwinspirePortsResponseCode Return, GeeArrayList* Lines, const gchar* raw, edwinspirePortsCME cmeError, edwinspirePortsCMS cmsError);
edwinspirePortsResponse* edwinspire_ports_response_construct_with_args (GType object_type, edwinspirePortsResponseCode Return, GeeArrayList* Lines, const gchar* raw, edwinspirePortsCME cmeError, edwinspirePortsCMS cmsError);
edwinspirePortsResponse* edwinspire_ports_response_new (void);
edwinspirePortsResponse* edwinspire_ports_response_construct (GType object_type);
gchar* edwinspire_ports_response_ToString (edwinspirePortsResponse* self);
GType edwinspire_ports_last_call_received_get_type (void) G_GNUC_CONST;
edwinspirePortsLastCallReceived* edwinspire_ports_last_call_received_dup (const edwinspirePortsLastCallReceived* self);
void edwinspire_ports_last_call_received_free (edwinspirePortsLastCallReceived* self);
void edwinspire_ports_last_call_received_copy (const edwinspirePortsLastCallReceived* self, edwinspirePortsLastCallReceived* dest);
void edwinspire_ports_last_call_received_destroy (edwinspirePortsLastCallReceived* self);
void edwinspire_ports_last_call_received_init (edwinspirePortsLastCallReceived *self);
GType edwinspire_ports_modem_get_type (void) G_GNUC_CONST;
edwinspirePortsModem* edwinspire_ports_modem_new (void);
edwinspirePortsModem* edwinspire_ports_modem_construct (GType object_type);
guint edwinspire_ports_modem_AutoBaudRate (edwinspirePortsModem* self);
edwinspirePortsResponse* edwinspire_ports_modem_Receive (edwinspirePortsModem* self, gdouble waitforresponse_ms, gboolean preventDetectFalseResponse);
gboolean edwinspire_ports_modem_Send (edwinspirePortsModem* self, const gchar* ComandoAT);
gboolean edwinspire_ports_modem_SendSimpleCommand (edwinspirePortsModem* self, const gchar* ATCommand, gdouble waitforresponse_ms);
gboolean edwinspire_ports_modem_DialCommand (edwinspirePortsModem* self, const gchar* number);
gboolean edwinspire_ports_modem_ATD (edwinspirePortsModem* self, const gchar* Number);
gboolean edwinspire_ports_modem_SetToDefaultConfiguration (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATZ (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATE (edwinspirePortsModem* self, gboolean enable);
gboolean edwinspire_ports_modem_ATV (edwinspirePortsModem* self, gboolean enable);
gboolean edwinspire_ports_modem_VerboseMode (edwinspirePortsModem* self, gboolean enable);
gboolean edwinspire_ports_modem_Echo (edwinspirePortsModem* self, gboolean enable);
gboolean edwinspire_ports_modem_ATS_Set (edwinspirePortsModem* self, gint _register_, gint value);
gboolean edwinspire_ports_modem_AutomaticAnswerControl_Set (edwinspirePortsModem* self, gint rings);
gint edwinspire_ports_modem_AutomaticAnswerControl (edwinspirePortsModem* self);
gint edwinspire_ports_modem_ATS0 (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATS0_Set (edwinspirePortsModem* self, gint rings);
gboolean edwinspire_ports_modem_EscapeSequenseCharacter_Set (edwinspirePortsModem* self, gint character);
gint edwinspire_ports_modem_EscapeSequenseCharacter (edwinspirePortsModem* self);
gint edwinspire_ports_modem_ATS2 (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATS2_Set (edwinspirePortsModem* self, gint character);
gboolean edwinspire_ports_modem_CommandLineTerminationCharacter_Set (edwinspirePortsModem* self, gint character);
gint edwinspire_ports_modem_CommandLineTerminationCharacter (edwinspirePortsModem* self);
gint edwinspire_ports_modem_ATS3 (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATS3_Set (edwinspirePortsModem* self, gint character);
gboolean edwinspire_ports_modem_ResponseFormattingCharacter_Set (edwinspirePortsModem* self, gint character);
gint edwinspire_ports_modem_ResponseFormattingCharacter (edwinspirePortsModem* self);
gint edwinspire_ports_modem_ATS4 (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATS4_Set (edwinspirePortsModem* self, gint character);
gboolean edwinspire_ports_modem_CommandLineEditingCharacter_Set (edwinspirePortsModem* self, gint character);
gint edwinspire_ports_modem_CommandLineEditingCharacter (edwinspirePortsModem* self);
gint edwinspire_ports_modem_ATS5 (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATS5_Set (edwinspirePortsModem* self, gint character);
gboolean edwinspire_ports_modem_ATS7_Set (edwinspirePortsModem* self, gint timeout);
gboolean edwinspire_ports_modem_CompletionConnectionTimeOut_Set (edwinspirePortsModem* self, gint timeout);
gint edwinspire_ports_modem_ATS7 (edwinspirePortsModem* self);
gint edwinspire_ports_modem_CompletionConnectionTimeOut (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATS10_Set (edwinspirePortsModem* self, gint delay);
gboolean edwinspire_ports_modem_AutomaticDisconnectDelayControl_Set (edwinspirePortsModem* self, gint delay);
gint edwinspire_ports_modem_ATS10 (edwinspirePortsModem* self);
gint edwinspire_ports_modem_AutomaticDisconnectDelayControl (edwinspirePortsModem* self);
gint edwinspire_ports_modem_ATS (edwinspirePortsModem* self, gint _register_);
gboolean edwinspire_ports_modem_AT (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_EscapeSequense (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_AcceptCall (edwinspirePortsModem* self);
gboolean edwinspire_ports_modem_ATA (edwinspirePortsModem* self);


G_END_DECLS

#endif
