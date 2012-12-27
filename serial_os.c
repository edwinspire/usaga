// 
//  serial_os.vala
//  
//  Author:
//       Edwin De La Cruz <edwinspire@gmail.com>
//  
//  Copyright (c) 2011 edwinspire
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
//#define LINUX_COM
//#define WINDOWS_COM

#ifdef _WIN_SPIRE_
    #include <stdio.h>   
    #include <string.h>  
    #include <windows.h>
    
    #define MAX_SIZE_BUFFER 8192

    #define NONE      0    
    #define RTSCTS    1
    #define HARD      1
    #define XONXOFF   2
    #define SOFT      2
    
 //   BOOL ERROR_CONFIGURE_PORT=FALSE;

    HANDLE Open_Port(char COMx[])
    {
         HANDLE fd;
         fd = CreateFile( COMx,	          	   // pointer to name of the file 
	             GENERIC_READ | GENERIC_WRITE, // access (read-write) mode 
	             0,				   // share mode 
	             NULL,			   // pointer to security attributes 
	             OPEN_EXISTING,		   // how to create
	             0,				   // file attributes
	             NULL);			   // handle to file with attributes
                                                   // to copy 

         if (fd == INVALID_HANDLE_VALUE) 
         {
              printf("Error:No se puede abrir puerto: %s \n",COMx); 
              return INVALID_HANDLE_VALUE;
         } 
         return fd;
    }

    DCB Get_Configure_Port(HANDLE fd)
    {
         DCB PortDCB;
         PortDCB.DCBlength = sizeof (DCB);     
         
         if(!GetCommState (fd, &PortDCB))
         {
               printf("Error pidiendo la configuración de puerto serie.\n");
            //   ERROR_CONFIGURE_PORT=TRUE; 
               return PortDCB;        
         }
      //   ERROR_CONFIGURE_PORT=FALSE;
         return PortDCB;
    }
    
    
    DCB Configure_Port(HANDLE fd, unsigned int BaudRate, unsigned Bits, unsigned Parity, unsigned BitsStop)
    {
         DCB PortDCB;
         PortDCB.DCBlength = sizeof (DCB); 
         
         // Configuramos el tamaño del buffer de escritura/lectura
         if(!SetupComm(fd, MAX_SIZE_BUFFER, MAX_SIZE_BUFFER)) 
         {
               printf("Error configurando buffer\n");
           //    ERROR_CONFIGURE_PORT=TRUE;
               return PortDCB;
         }

         if(!GetCommState (fd, &PortDCB))
         {
               printf("Error Pidiendo configuración de Puerto\n");
           //    ERROR_CONFIGURE_PORT=TRUE;
               return PortDCB;
         }

         // Change the DCB structure settings.
         PortDCB.BaudRate = BaudRate;             // Current baud 
         PortDCB.fBinary = TRUE;                  // Binary mode; no EOF check 
         //PortDCB.EofChar = 0;
         PortDCB.fErrorChar = FALSE;              // Disable error replacement. 
         PortDCB.fNull = FALSE;                   // Disable null stripping. 
         PortDCB.fAbortOnError = FALSE;           // Do not abort reads/writes on error.
         PortDCB.fParity = FALSE;                 // Disable parity checking.
         
         PortDCB.fRtsControl = RTS_CONTROL_DISABLE; // RTS flow control   
         
         PortDCB.fDtrControl = DTR_CONTROL_DISABLE; // DTR flow control type        

         PortDCB.fOutxCtsFlow = FALSE;            // No CTS output flow control 
         PortDCB.fOutxDsrFlow = FALSE;            // No DSR output flow control

         PortDCB.fDsrSensitivity = FALSE;         // DSR sensitivity 

         PortDCB.fOutX = FALSE;                   // No XON/XOFF out flow control 
         PortDCB.fInX = FALSE;                    // No XON/XOFF in flow control 
         PortDCB.fTXContinueOnXoff = TRUE;        // XOFF continues Tx 
  /*       
         if(strncmp(CharParity,"8N1",3)==0)
         {
         PortDCB.ByteSize = 8;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = NOPARITY;               // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
         }
*/
if((Bits == 8) && (Parity == 0) && (BitsStop == 1)){
       PortDCB.ByteSize = 8;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = NOPARITY;               // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
}
/*
         if(strncmp(CharParity,"7E1",3)==0)
         {
         PortDCB.ByteSize = 7;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = EVENPARITY;             // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
         }
*/
if((Bits == 7) && (Parity == 2) && (BitsStop == 1)){
         PortDCB.ByteSize = 7;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = EVENPARITY;             // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
}
/*
         if(strncmp(CharParity,"7O1",3)==0)
         {
         PortDCB.ByteSize = 7;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = ODDPARITY;              // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
         }
*/
if((Bits == 7) && (Parity == 1) && (BitsStop == 1)){
         PortDCB.ByteSize = 7;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = ODDPARITY;              // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
}

/*
         if(strncmp(CharParity,"7S1",3)==0)
         {
         PortDCB.ByteSize = 7;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = SPACEPARITY;            // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
         }  
*/
if((Bits == 7) && (Parity == 4) && (BitsStop == 1)){
         PortDCB.ByteSize = 7;                    // Number of bits/bytes, 4-8 
         PortDCB.Parity = SPACEPARITY;            // 0-4=no,odd,even,mark,space 
         PortDCB.StopBits = ONESTOPBIT;           // 0,1,2 = 1, 1.5, 2 
} 
         
         if (!SetCommState (fd, &PortDCB))
         {  // Could not configure the serial port.
            printf("Error: configurando puerto\n");
         //   ERROR_CONFIGURE_PORT=TRUE;
            return PortDCB;
         }

         // Configure timeouts 
         COMMTIMEOUTS timeouts;
         // No timeouts 
         timeouts.ReadIntervalTimeout = 0;
         timeouts.ReadTotalTimeoutMultiplier = 0;
         timeouts.ReadTotalTimeoutConstant = 0;
         timeouts.WriteTotalTimeoutMultiplier = 0;
         timeouts.WriteTotalTimeoutConstant = 0;

         if (!SetCommTimeouts(fd, &timeouts)) 
         {
	        printf("ERROR: No se pudo poner SetCommTimeouts: %s\n", 
                                                               GetLastError());
        //    ERROR_CONFIGURE_PORT=TRUE;
            return PortDCB;
         }


     //    ERROR_CONFIGURE_PORT=FALSE;
	     return PortDCB;
    }


    int Set_Configure_Port(HANDLE fd,  unsigned int BaudRate, unsigned Bits, unsigned Parity, unsigned BitsStop)
    {
DCB PortDCB = Configure_Port( fd, BaudRate,  Bits,  Parity,  BitsStop);
	 // Ahora limpiamos el buffer de entrada y salida del puerto 
         // y activamos la configuración del puerto.
         if (!SetCommState (fd, &PortDCB))
         {
            printf("ERROR (WIN): No se pudo poner configuración del puerto serie\n" );
        //    ERROR_CONFIGURE_PORT=TRUE;
            return -1;
         }
    //     ERROR_CONFIGURE_PORT=FALSE;

	     return 0;
    }    

    
    long Write_Port(HANDLE fd,char Data[],int SizeData)
    {
         long n;

         WriteFile(fd,                // Port handle
                   Data,              // Pointer to the data to write 
                   (DWORD)SizeData,   // Number of bytes to write
                   (DWORD*)&n,        // Pointer to the number of bytes written
                   NULL);             // Must be NULL for Windows CE
         return n;
    }
    /*
    //TODO//ELIMINAR ESTA FUNCION YA QUE NO ES NECESARIA
    long Read_Port(HANDLE fd,char *Data,int SizeData)
    {
         long n;

         ReadFile (fd,                // Port handle
                   Data,              // Pointer to the data to write 
                   (DWORD)SizeData,   // Number of bytes to write
                   (DWORD*)(&n),      // Pointer to the number of bytes read
                   NULL);             // Must be NULL for Windows CE
         return n;
    }
*/
/*
    //TODO//ELIMINAR ESTA FUNCION YA QUE NO ES NECESARIA
    long Gets_Port(HANDLE fd,char *Data,int SizeData)
    {
         long n=0,i=0;

         for(i=0;i<SizeData;i++)
         {
               ReadFile(fd,&Data[i],(DWORD)1,(DWORD*)(&n),NULL);
               if(((Data[i]==13)||(Data[i]==10)||(Data[i]==0))&&(i!=0))
               {
                n=i+1;
                if(n<SizeData) Data[n]=0;
                i=SizeData;
               }
         }
         
         return n;
    }
*/

/*
    long Getc_Port(HANDLE fd, char *Data)
    {
         long n;

         ReadFile(fd,Data,(DWORD)1,(DWORD*)(&n),NULL);
        
         return n;
    }
*/

char Getc(HANDLE fd)
{
    char c = 0;
  long n;
    //Getc_Port(hPort,&c);
         ReadFile(fd,&c,(DWORD)1,(DWORD*)(&n),NULL);
return c;
}

  
    int Kbhit_Port(HANDLE fd)
    {
     	DWORD x;
     	COMSTAT cs;
     	// Actualizar COMSTAT, sirve para averiguar el número de bytes en el 
     	// buffer de entrada:
     	ClearCommError(fd, &x, &cs);
     	return cs.cbInQue;
    }



    int Close_Port(HANDLE fd)
    {
         if (fd != INVALID_HANDLE_VALUE)
         {  // Close the communication port.
            
            // Liberar máscara de eventos del puerto serie:
            SetCommMask(fd, 0);
            
            if (!CloseHandle (fd))
            {printf("Error cerrando el puerto serie\n");return -1;}
            else
            {fd = INVALID_HANDLE_VALUE;return 0;}
         }
	     return -1;
    }


 
    int Set_Hands_Haking(HANDLE fd,int FlowControl)
    {
        DCB PortDCB;
        if(!GetCommState (fd, &PortDCB))
         {
               printf("Error Pidiendo configuración de puerto serie\n");
            //   ERROR_CONFIGURE_PORT=TRUE;
               return FALSE;
         }
        
        switch(FlowControl)
        {
         case 0: ///NONE
              {
              PortDCB.fOutX = FALSE;                      // No XON/XOFF out flow control. 
              PortDCB.fInX = FALSE;                       // No XON/XOFF in flow control.
              
              PortDCB.fRtsControl = RTS_CONTROL_ENABLE;   // RTS flow control.  
               
              PortDCB.fDtrControl = DTR_CONTROL_ENABLE;   // DTR flow control type.
              break;
              }
         case 1: ///RTS/CTS
              {
              PortDCB.fRtsControl = RTS_CONTROL_HANDSHAKE;// RTS flow control.  
              break;
              }
         case 2: ///XON/OFF
              {
              PortDCB.fOutX = TRUE;                       // XON/XOFF out flow control. 
              PortDCB.fInX = TRUE;                        // XON/XOFF in flow control.  
              PortDCB.XonChar=0x11;                       // ASCII_XON.
              PortDCB.XoffChar=0x13;                      // ASCII_XOFF.
              PortDCB.XonLim=100;
              PortDCB.XoffLim=100;
              break;
              }
         case 3: ///DTR/DSR
              {
              PortDCB.fDtrControl = DTR_CONTROL_HANDSHAKE;// DTR flow control type.
              break;
              }
        }
        
        if (!SetCommState (fd, &PortDCB))
        {
              printf("ERROR: Configurando el puerto serie\n");
//              ERROR_CONFIGURE_PORT=0;
              return -1;
        }
  //      ERROR_CONFIGURE_PORT=-1;

	    return 0;
    }
    
/*
      //TODO//FUNCION NO UTIL AL PARECER-ELIMINAR
    int Set_RThreshold(HANDLE fd,int n)
    {
	    return 0;
    }
*/
    
  /*
    int Set_BaudRate(HANDLE fd,unsigned int BaudRate)
    {
        DCB PortDCB;

        if(!GetCommState (fd, &PortDCB))
         {
               printf("Error Pidiendo configuración del Puerto\n");
               ERROR_CONFIGURE_PORT=0;
               return -1;
         }
         
        PortDCB.BaudRate = BaudRate;                // Binary mode; no EOF check 

        if (!SetCommState (fd, &PortDCB))
        {
              printf("Error configurando el BaudRate\n");
              ERROR_CONFIGURE_PORT=0;
              return -1;
        }
        ERROR_CONFIGURE_PORT=-1;

	    return 0;
    }
*/

  
    int Set_Time(HANDLE fd,unsigned int Time) 
    {
        COMMTIMEOUTS CommTimeouts;

        if(!GetCommTimeouts (fd, &CommTimeouts))
        {
              printf("Error obteniendo configuración time-out actual: %s\n", 
                                                              GetLastError());
              return -1;
        }

        // Tiempo maximo en mseg. entre caracteres consecutivos
        CommTimeouts.ReadIntervalTimeout = Time*200;

        // Time-Out=TotalTimeoutMultiplier*number_of_bytes+TotalTimeoutConstant

        // Especifique el multiplicador de tiempo fuera de lectura con el miembro 
        // ReadTotalTimeoutMultiplier. En cada operación de lectura , este número 
        // se multiplica por el número de bytes que la lectura espera recibir .
        CommTimeouts.ReadTotalTimeoutMultiplier = Time*100;
        // Constante a sumar al time-out total de recepción.
        CommTimeouts.ReadTotalTimeoutConstant = 0;

        // Igual que lectura.
        CommTimeouts.WriteTotalTimeoutMultiplier = Time*100;
        // Igual que lectura
        CommTimeouts.WriteTotalTimeoutConstant = 0;

        // Establecemos nuevos valores de time-out.
        if(!SetCommTimeouts (fd, &CommTimeouts)) 
        {
              printf("Error estableciendo nueva configuración time-out: %s\n", 
                                                              GetLastError());
              return -1;
        }

        return 0;
    }

 
    int IO_Blocking(HANDLE fd,int Modo) 
    {
        COMMTIMEOUTS CommTimeouts;

        if(!GetCommTimeouts (fd, &CommTimeouts))
        {
              printf("Error obteniendo configuracion time-out actual: %s\n", 
                                                              GetLastError());
              return -1;
        }
        
        // Especifica que la operación de lectura debe regresar inmediatamente 
        // con los caracteres que ya se hayan recibido, incluso aunque no se 
        // haya recibido ninguno.
        if(Modo==-1)// No bloqueante
        {
         CommTimeouts.ReadIntervalTimeout = MAXDWORD;
         CommTimeouts.ReadTotalTimeoutMultiplier = 0;
         CommTimeouts.ReadTotalTimeoutConstant = 0;
         CommTimeouts.WriteTotalTimeoutMultiplier = 0;
         CommTimeouts.WriteTotalTimeoutConstant = 0;
        }
        // indica que el tiempo total de time-out no se usa para operaciones de
        // lectura/escritura.
        if(Modo==0)// Bloqueante.
        {
         CommTimeouts.ReadIntervalTimeout = 0;
         CommTimeouts.ReadTotalTimeoutMultiplier = 0;
         CommTimeouts.ReadTotalTimeoutConstant = 0;
         CommTimeouts.WriteTotalTimeoutMultiplier = 0;
         CommTimeouts.WriteTotalTimeoutConstant = 0;
        }

        if(!SetCommTimeouts (fd, &CommTimeouts)) 
        {
              printf("Error estableciendo nueva configuración bloqueante/no-bloqueante: %s\n", 
                                                              GetLastError());
              return -1;
        }

        return 0;
    }

  
    int Clean_Buffer(HANDLE fd) 
    {
       return PurgeComm( fd , PURGE_TXABORT | PURGE_RXABORT | PURGE_TXCLEAR | PURGE_RXCLEAR );
    }
    
 
    int Setup_Buffer(HANDLE fd,unsigned long InQueue,unsigned long OutQueue) 
    {
       return SetupComm(fd,InQueue,OutQueue);
    }
#endif

#ifdef _LNX_SPIRE_

    #include <stdio.h>   /* Standard input/output definitions. */
    #include <string.h>  /* String function definitions. */
    #include <unistd.h>  /* UNIX standard function definitions. */
    #include <fcntl.h>   /* File control definitions. */
    #include <sys/ioctl.h>
    #include <sys/time.h>
    
    #include <termios.h> /* POSIX terminal control definitions. */

    #ifndef FALSE
       #define FALSE 0
    #endif
    
    #ifndef TRUE
       #define TRUE  1
    #endif
 
    #ifndef BOOL
       #define BOOL  int
    #endif

    #define INVALID_HANDLE_VALUE -1
    #define NONE      0    
    #define RTSCTS    1
    #define HARD      1
    #define XONXOFF   2
    #define SOFT      2
    
//    BOOL ERROR_CONFIGURE_PORT=FALSE;

    typedef  struct termios	DCB;
    typedef  int	        HANDLE;

    int Kbhit_Port(HANDLE fd);
    
/**
 * @}
 */

  /** \fn HANDLE Open_Port(char COMx[])
   *  \brief Abre el puerto de comunicaciones.
   *  \param COMx Es el puerto a abrir.<br>
   *  En Gnu-Linux: "/dev/ttyS0","/dev/ttyS1","/dev/ttyACM0","/dev/ttyUSB0",... <br>
   *  En Windows: "COM1","COM2","COM3","COM4",... <br>
   *  \return El manejador del puerto, en caso de error devuelve INVALID_HANDLE_VALUE.
   *  \ingroup HeaderLinux
   */
    HANDLE Open_Port(char COMx[])
    {
	int fd; // File descriptor for the port.

	fd = open(COMx, O_RDWR | O_NOCTTY );//| O_NDELAY);
		//printf("OPEN %i - %i\n",O_RDWR,O_NOCTTY);
	if (fd <0)	
	{
		printf("open_port:fd=%d: No se puede abrir %s\n",fd,COMx);
		return INVALID_HANDLE_VALUE;
	}
	printf("open_port:fd=%d: Abierto puerto %s\n",fd,COMx);
	tcflush(fd, TCIOFLUSH);
	return fd;
    }

    
  /** \fn DCB Get_Configure_Port(HANDLE fd)
   *  \brief Devuelve la configuración actual del Puerto serie.
   *  \param fd Es el manejador del puerto.
   *  \return Una estructura de tipo DCB con la configuración actual del puerto
   *  serie, además carga ERROR_CONFIGURE_PORT con FALSE, en caso de error carga
   *  ERROR_CONFIGURE_PORT con TRUE.
   *  \ingroup HeaderLinux
   */  
    DCB Get_Configure_Port(HANDLE fd)
    {
	struct termios oldtio;
	if(tcgetattr(fd,&oldtio)!=0)  /* almacenamos la configuración actual del puerto */
	{
		printf("Error pidiendo la configuración de puerto serie.\n");
		//ERROR_CONFIGURE_PORT=TRUE;
		return oldtio;
	}
	//ERROR_CONFIGURE_PORT=FALSE;
	return oldtio;
    }
    

int ConvertBaudRate(unsigned int BaudRate){

int  Baudios = B9600;

switch(BaudRate){
case 0:
Baudios = B0;
break;
case 50:
Baudios = B50;
break;
case 75:
Baudios = B75;
break;
case 110:
Baudios = B110;
break;
case 134:
Baudios = B134;
break;
case 150:
Baudios = B150;
break;
case 200:
Baudios = B200;
break;
case 300:
Baudios = B300;
break;
case 600:
Baudios = B600;
break;
case 1200:
Baudios = B1200;
break;
case 1800:
Baudios = B1800;
break;
case 2400:
Baudios = B2400;
break;
case 4800:
Baudios = B4800;
break;
case 9600:
Baudios = B9600;
break;
case 19200:
Baudios = B19200;
break;
case 38400:
Baudios = B38400;
break;
case 57600:
Baudios = B57600;
break;
case 115200:
Baudios = B115200;
break;
case 1500000:
Baudios = B1500000;
break;
case 2000000:
Baudios = B2000000;
break;
case 2500000:
Baudios = B2500000;
break;
case 3000000:
Baudios = B3000000;
break;
case 3500000:
Baudios = B3500000;
break;
case 4000000:
Baudios = B4000000;
break;
default:
if(BaudRate<50){
Baudios = B0;
}else if(BaudRate<75){
Baudios = B50;
}else if(BaudRate<110){
Baudios = B75;
}else if(BaudRate<134){
Baudios = B110;
}else if(BaudRate<150){
Baudios = B134;
}else if(BaudRate<200){
Baudios = B150;
}else if(BaudRate<300){
Baudios = B200;
}else if(BaudRate<600){
Baudios = B300;
}else if(BaudRate<1200){
Baudios = B600;
}else if(BaudRate<1800){
Baudios = B1200;
}else if(BaudRate<2400){
Baudios = B1800;
}else if(BaudRate<4800){
Baudios = B2400;
}else if(BaudRate<9600){
Baudios = B4800;
}else if(BaudRate<19200){
Baudios = B9600;
}else if(BaudRate<38400){
Baudios = B19200;
}else if(BaudRate<57600){
Baudios = B38400;
}else if(BaudRate<115200){
Baudios = B57600;
}else if(BaudRate<1500000){
Baudios = B115200;
}else if(BaudRate<2000000){
Baudios = B1500000;
}else if(BaudRate<2500000){
Baudios = B2000000;
}else if(BaudRate<3000000){
Baudios = B2500000;
}else if(BaudRate<3500000){
Baudios = B3000000;
}else if(BaudRate<4000000){
Baudios = B3500000;
}else if(BaudRate>4000000){
Baudios = B4000000;
}
break;
}

	//	printf("Baudos Usados %i = %i => %i\n", BaudRate, Baudios, B115200);

return Baudios;
}




    
  /** \fn DCB Configure_Port(HANDLE fd,unsigned int BaudRate,char CharParity[])
   *  \brief Configura el puerto serie. 
   *  \param fd Es el manejador del puerto.
   *  \param BaudRate Es la velocidad en baudios del puerto.
   *  \param CharParity Indica el número de bits en la transmisión y la paridad "8N1","8E1","7E1","7O1" y "7S1".
   *  \return Una estructura de tipo DCB con la configuración del puerto
   *  serie, además carga ERROR_CONFIGURE_PORT con FALSE, en caso de error carga
   *  ERROR_CONFIGURE_PORT con TRUE.
   *  \ingroup HeaderLinux
   */    
    DCB Configure_Port(HANDLE fd,unsigned int BaudRate, unsigned Bits, unsigned Parity, unsigned BitsStop)
    {
int Baudios = ConvertBaudRate(BaudRate);

	DCB newtio;
	bzero(&newtio, sizeof(newtio));    //limpiamos struct para recibir los
                                           //nuevos parámetros del puerto.
	//tcflush(fd, TCIOFLUSH);

	//CLOCAL  : conexion local, sin control de modem.
	//CREAD   : activa recepcion de caracteres.
	newtio.c_cflag =CLOCAL | CREAD ;
	
	cfsetispeed(&newtio,Baudios);
	cfsetospeed(&newtio,Baudios);
/*	
	if(strncmp(CharParity,"8N1",3)==0)	//CS8     : 8n1 (8bit,no paridad,1 bit de parada)
	{
		newtio.c_cflag &= ~PARENB;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS8;
	}
*/

if((Bits == 8) && (Parity == 0) && (BitsStop == 1)){
newtio.c_cflag &= ~PARENB;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS8;
		//printf("Usa 8N1.\n");
}

/*
	if(strncmp(CharParity,"8E1",3)==0)
	{
		newtio.c_cflag |=PARENB;
		newtio.c_cflag &= ~PARODD;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS8;
	}
*/

if((Bits == 8) && (Parity == 2) && (BitsStop == 1)){
newtio.c_cflag |=PARENB;
		newtio.c_cflag &= ~PARODD;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS8;
}
/*
	if(strncmp(CharParity,"7E1",3)==0)
	{
		newtio.c_cflag |= PARENB;
		newtio.c_cflag &= ~PARODD;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS7;
	}
*/
if((Bits == 7) && (Parity == 2) && (BitsStop == 1)){
newtio.c_cflag |= PARENB;
		newtio.c_cflag &= ~PARODD;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS7;
}
/*
	if(strncmp(CharParity,"7O1",3)==0)
	{
		newtio.c_cflag |= PARENB;
		newtio.c_cflag |= PARODD;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS7;
	}
*/

if((Bits == 7) && (Parity == 1) && (BitsStop == 1)){
		newtio.c_cflag |= PARENB;
		newtio.c_cflag |= PARODD;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS7;
}
/*
	if(strncmp(CharParity,"7S1",3)==0)
	{
		newtio.c_cflag &= ~PARENB;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS8;
	}
*/
if((Bits == 7) && (Parity == 4) && (BitsStop == 1)){
		newtio.c_cflag &= ~PARENB;
		newtio.c_cflag &= ~CSTOPB;
		newtio.c_cflag &= ~CSIZE;
		newtio.c_cflag |= CS8;
}

	// IGNPAR  : ignora los bytes con error de paridad.
	// ICRNL   : mapea CR a NL (en otro caso una entrada CR del otro ordenador
	// no terminaría la entrada) en otro caso hace un dispositivo en bruto
	// (sin otro proceso de entrada).
	newtio.c_iflag = 0;
	//newtio.c_iflag = IGNPAR;
	//newtio.c_iflag |= ICRNL;

	//Salida en bruto.
	newtio.c_oflag = 0;

	//ICANON  : activa entrada canónica(Modo texto).
	//desactiva todas las funcionalidades del eco, y no envía señales al
	//programa llamador.
	//newtio.c_lflag = ICANON;
	newtio.c_lflag = 0;

	// inicializa todos los caracteres de control.
	// Los valores por defecto se pueden encontrar en /usr/include/termios.h,
	// y vienen dadas en los comentarios, pero no los necesitamos aquí.

	newtio.c_cc[VTIME]    = 0;     /* temporizador entre caracter, no usado */
	newtio.c_cc[VMIN]     = 1;     /* bloquea lectura hasta llegada de un caracter */
	
	if(tcsetattr(fd,TCSANOW,&newtio)!=0)
	{
		printf("ERROR: No se pudo poner la configuración del puerto serie\n" );
		//ERROR_CONFIGURE_PORT=TRUE;
		return newtio;
	}

return newtio;
    }
    
    
  /** \fn int Set_Configure_Port(HANDLE fd,DCB PortDCB)
   *  \brief Coloca la configuración en el puerto serie a partir de una estructura DCB.
   *  \param fd Es el manejador del puerto.
   *  \param PortDCB Es la configuración del puerto.
   *  \return TRUE Si todo fue bien o FALSE si no lo fue. 
   *  \ingroup HeaderLinux
   */  
    int Set_Configure_Port(HANDLE fd, unsigned int BaudRate, unsigned Bits, unsigned Parity, unsigned BitsStop)
    {

DCB newtio = Configure_Port( fd, BaudRate,  Bits,  Parity,  BitsStop);


	// ahora limpiamos el buffer de entrada y salida del modem y activamos 
	// la configuración del puerto
	//tcflush(fd, TCIOFLUSH);
	
	if(tcsetattr(fd,TCSANOW,&newtio)!=0)
	{
		printf("ERROR (LNX): No se pudo poner configuración del puerto serie\n" );
        //	ERROR_CONFIGURE_PORT=TRUE;
        	return -1;
	}
//	ERROR_CONFIGURE_PORT=FALSE;
	
    	return 0;
    }
    
    
  /** \fn long Write_Port(HANDLE fd,char Data[],int SizeData)
   *  \brief Escribe en el puerto serie.
   *  \param fd Es el manejador del puerto.
   *  \param Data Es el vector de datos a mandar.
   *  \param SizeData es el tamaño del vector de datos.
   *  \return En caso de éxito, se devuelve el número de bytes escritos (cero 
   *          indica que no se ha escrito nada). En GNU-LINUX en caso de error se devuelve -1.
   *  \ingroup HeaderLinux
   */
    long Write_Port(HANDLE fd,char Data[], int SizeData)
    {
	return  write(fd,Data,SizeData);
    }
    
    //TODO//ELIMINAR ESTA FUNCION YA QUE NO ES NECESARIA
  /** \fn long Read_Port(HANDLE fd,char *Data,int SizeData)
   *  \brief Recibe datos en el puerto serie.
   *  \param fd Es el manejador del puerto.
   *  \param Data Es el vector donde se almacenarán los datos recibidos.
   *  \param SizeData Es el número de datos que se desea recibir, este número tiene
   *  que ser menor o igual que el tamaño del vector Data.
   *  \return En caso de éxito, se devuelve el número de bytes recibidos (cero 
   *          indica que no se ha recibido nada). En GNU-LINUX en caso de error, se devuelve -1.
   *  \ingroup HeaderLinux
   */  
/*
    long Read_Port(HANDLE fd,char *Data, int SizeData)
    {
	struct termios newtio;
	struct timeval inic,fin,temp;
	float tiempo,t;
	int bytes;
	int ESTADO;
	int TEMPO;

	if(tcgetattr(fd,&newtio)!=0) return -1;
	else
	{
		ESTADO=newtio.c_cc[VMIN];
		TEMPO=newtio.c_cc[VTIME];
		if( (ESTADO==0)&&(TEMPO==0) )
		{
			return read(fd,Data,SizeData);
		}
		else
		{
			if(TEMPO==0)
			{
				do{ioctl(fd, FIONREAD, &bytes);}
				while(bytes<SizeData);
				return read(fd,Data,SizeData);
			}
			else
			{
				gettimeofday(&inic,NULL);
				tiempo=newtio.c_cc[VTIME];
				do
				{
					gettimeofday(&fin,NULL);
					temp.tv_sec=fin.tv_sec-inic.tv_sec;
					temp.tv_usec=fin.tv_usec-inic.tv_usec ;
					t=((temp.tv_usec/1000.0)+temp.tv_sec*1000.0)/100.0;
				}while( (t<tiempo*SizeData) && (Kbhit_Port(fd)<SizeData) );

				if(Kbhit_Port(fd)!=0)	return read(fd,Data,SizeData);
				else			return 0;
			}
		}
	}
    }
    */
    //TODO//ELIMINAR ESTA FUNCION YA QUE NO ES NECESARIA
  /** \fn long Gets_Port(HANDLE fd,char *Data,int SizeData)
   *  \brief Recibe datos en el puerto serie,lee hasta encontrar un 0x0A,0x0D  
   *         (rellenando el siguiente byte con un cero - "solo si existe")   
   *         o hasta completar SizeData caracteres.
   *  \param fd Es el manejador del puerto.
   *  \param Data Es el vector donde se almacenarán los datos recibidos.
   *  \param SizeData Es el tamaño máximo del vector.
   *  \return En caso de éxito, se devuelve el número de bytes recibidos (los
   *          números serán siempre mayores o iguales a cero). 
   *  \ingroup HeaderLinux    
   */
/*
    long Gets_Port(HANDLE fd,char *Data,int SizeData)
    {
	struct termios newtio;
	long n=0,i=0;
	struct timeval inic,fin,temp;
	float tiempo,t;

	if(tcgetattr(fd,&newtio)!=0) return -1;

	for(i=0;i<SizeData;i++)
	{
		gettimeofday(&inic,NULL);
		tiempo=(float)newtio.c_cc[VTIME];
		do
		{
			gettimeofday(&fin,NULL);
			temp.tv_sec=fin.tv_sec-inic.tv_sec;
			temp.tv_usec=fin.tv_usec-inic.tv_usec ;
			t=((temp.tv_usec/1000.0)+temp.tv_sec*1000.0)/100.0;
		}while( (t<tiempo) && (Kbhit_Port(fd)==0) );

		Data[i]=0;
		if( (Kbhit_Port(fd)!=0)||(tiempo==0) ) read(fd,&Data[i],1);

		if( ((Data[i]==13)||(Data[i]==10)||(Data[i]==0))&&(i!=0) )
		{
			n=i+1;
			if(n<SizeData) Data[n]=0;
			i=SizeData;
		}
	}
 
	return n;
    }
*/
    
  /** \fn Getc_Port(HANDLE fd,char *Data)
   *  \brief Recibe un caracter en el puerto serie.
   *  \param fd Es el manejador del puerto.
   *  \param Data Es el dato(8-bit) a mandar.
   *  \return En caso de éxito, se devuelve el número de bytes recibidos (cero 
   *          indica que no se ha recibido nada). En GNU-LINUX en caso de error, se devuelve -1.
   *  \ingroup HeaderLinux    
   */  
/*  
    long Getc_Port(HANDLE fd, char *Data)
    {
	struct termios newtio;
	struct timeval inic,fin,temp;
	float tiempo,t;

	if(tcgetattr(fd,&newtio)!=0) return 0;

	gettimeofday(&inic,NULL);
	tiempo=(float)newtio.c_cc[VTIME];
	do
	{
		gettimeofday(&fin,NULL);
		temp.tv_sec=fin.tv_sec-inic.tv_sec;
		temp.tv_usec=fin.tv_usec-inic.tv_usec ;
		t=((temp.tv_usec/1000.0)+temp.tv_sec*1000.0)/100.0;
	}while( (t<tiempo) && (Kbhit_Port(fd)==0) );

	if( (Kbhit_Port(fd)!=0)||(tiempo==0) )	return read(fd,Data,1);
	else					return 0;
  }
*/


char Getc(HANDLE fd)
{
    char c = 0;
    //Getc_Port(hPort,&c);
     read(fd,&c,1);
return c;
}


  /** \fn int Kbhit_Port(HANDLE fd)
   *  \brief Indica el número de caracteres disponibles en el buffer de entrada del puerto serie.
   *  \param fd Es el manejador del puerto. 
   *  \return El número de caracteres en el buffer de entrada del puerto serie.
   *  \ingroup HeaderLinux    
   */   
    int Kbhit_Port(HANDLE fd)
    {
       int bytes;
       ioctl(fd, FIONREAD, &bytes);
       return bytes;

    }
    

  /** \fn int Close_Port(HANDLE fd)
   *  \brief Cierra el puerto serie.
   *  \param fd Es el manejador del puerto. 
   *  \return TRUE si se ha cerrado el Puerto y FALSE en el caso contrario.
   *  \ingroup HeaderLinux    
   */    
    int Close_Port(HANDLE fd)
    {
	 if (fd != INVALID_HANDLE_VALUE)
         {  // Close the communication port.
		// Ahora limpiamos el buffer de entrada y salida del puerto y activamos 
		// la configuración del puerto.
		//tcflush(fd, TCIOFLUSH);
            if (close(fd)!=0)
            {printf("Error cerrando el puerto serie\n");return -1;}
            else
            {fd = INVALID_HANDLE_VALUE;return 0;}
         }
	 return -1;
    }


  /** \fn int Set_Hands_Haking(HANDLE fd,int FlowControl)
   *  \brief Configura el control de flujo en el puerto serie.
   *  \param fd Es el manejador del puerto. 
   *  \param FlowControl 
   *                     0    Ninguno<br>                                            
   *                     1    RTS/CTS<br>                                             
   *                     2    Xon/Xoff<br>                                            
   *                     3    DTR/DSR  
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *  \ingroup HeaderLinux    
   */    
    int Set_Hands_Haking(HANDLE fd,int FlowControl)
    {
	struct termios newtio;
	tcgetattr(fd,&newtio);  /* almacenamos la configuración actual del puerto */
	switch (FlowControl)
	{
		case 0://NONE
		{
			newtio.c_cflag &= ~CRTSCTS;
			newtio.c_iflag &= ~(IXON | IXOFF | IXANY);
			newtio.c_cc[VSTART]   = 0;     /* Ctrl-q */
			newtio.c_cc[VSTOP]    = 0;     /* Ctrl-s */
			break;
		}
		case 1://RTS/CTS - HARD
		{
			newtio.c_cflag |= CRTSCTS;
			newtio.c_iflag &= ~(IXON | IXOFF | IXANY);
			newtio.c_cc[VSTART]   = 0;     /* Ctrl-q */
			newtio.c_cc[VSTOP]    = 0;     /* Ctrl-s */
			break;
		}
		case 2://XON/XOFF - SOFT
		{
			newtio.c_cflag &= ~CRTSCTS;
			newtio.c_iflag |= (IXON | IXOFF );//| IXANY);
			newtio.c_cc[VSTART]   = 17;     /* Ctrl-q */
			newtio.c_cc[VSTOP]    = 19;     /* Ctrl-s */
			break;
		}
	}
	tcsetattr(fd, TCSANOW, &newtio);
	return 0;
    }

//TODO//FUNCION NO UTIL AL PARECER-ELIMINAR
  /** \fn int Set_RThreshold(HANDLE fd,int n)
   *  \brief configura el numero mínimo de caracteres que permitirá
   *         que se ejecute la lectura del puerto
   *  \param fd Es el manejador del puerto. 
   *  \param n  Es el numero de caracteres que activará la lectura.
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *  \ingroup HeaderLinux    
   */        
/*
    int Set_RThreshold(HANDLE fd,int n)
    {
	    return 0;
    }
*/
    
  /** \fn int Set_BaudRate(HANDLE fd,unsigned int BaudRate)
   *  \brief Configura la  velocidad puerto serie.
   *  \param fd Es el manejador del puerto. 
   *  \param BaudRate Es la velocidad en baudios del puerto.
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *  \ingroup HeaderLinux    
   */   
/* 
    int Set_BaudRate(HANDLE fd,unsigned int BaudRate)
    {

int Baudios = ConvertBaudRate(BaudRate);
	struct termios newtio;

	if(tcgetattr(fd,&newtio)!=0)
        {
              printf("Error obteniendo configuración del puerto\n");
              return -1;
        }
	
	cfsetispeed(&newtio, Baudios);
	cfsetospeed(&newtio, Baudios);
	
	if(tcsetattr(fd, TCSANOW, &newtio)!=0)
        {
              printf("Error configurando el BaudRate\n");
              return -1;
        }
	
	return 0;	
    }
*/
	

  /** \fn int Set_Time(HANDLE fd,unsigned int Time)
   *  \brief Configura temporizador para la lectura y escritura en el puerto serie.
   *  \param fd Es el manejador del puerto. 
   *  \param Time Tiempo (T) entre bits, T=Time*0.1s, para tamaño total de time-out   
   *               en la lectura y escritura.<br>
   *               Timeout = (Time *0.1* number_of_bytes) seg 
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *  \ingroup HeaderLinux    
   */  
    int Set_Time(HANDLE fd,unsigned int Time) //t =Time*0.1 s)
    {
	struct termios newtio;
        /* almacenamos la configuracion actual del puerto */
	if(tcgetattr(fd,&newtio)!=0)
        {
              printf("Error obteniendo configuración time-out actual\n");
              return 0;
        }
        
	newtio.c_cc[VTIME]    = Time;/*temporizador entre caracter*/
	newtio.c_cc[VMIN]     = 1;   /*bloquea lectura hasta llegada de un
                                       caracter  */
	
	if(tcsetattr(fd, TCSANOW, &newtio)!=0)
        {
              printf("Error estableciendo nueva configuración time-out\n");
              return -1;
        }
	
	    return 0;	
    }
    
  /** \fn int IO_Blocking(HANDLE fd,int Modo)
   *  \brief Configura si la lectura y escritura de datos se ejecutará en modo bloqueante.
   *  \param fd Es el manejador del puerto. 
   *  \param Modo Escoge el tipo de bloqueo.<br>
   *   TRUE : Modo bloqueante.<br>                                          
   *   FALSE: Modo no bloqueante.
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *  \ingroup HeaderLinux    
   */  
    int IO_Blocking(HANDLE fd,int Modo) 
    {
	struct termios newtio;
        /* almacenamos la configuracion actual del puerto */
	if(tcgetattr(fd,&newtio)!=0)
        {
		printf("Error obteniendo configuración time-out actual\n");
		return -1;
        }
	
	if(Modo==-1)
	{
		newtio.c_cc[VTIME]    = 0;     /* Temporizador entre caracter.*/
		newtio.c_cc[VMIN]     = 0;     /* No bloquea lectura hasta llegada de un caracter. */
//		printf("Nueva configuración no-bloqueante.\n");
	}
	if(Modo==0)
	{
		newtio.c_cc[VTIME]    = 0;     /* Temporizador entre caracter.*/
		newtio.c_cc[VMIN]     = 1;     /* Bloquea lectura hasta llegada de un caracter. */
//		printf("Nueva configuración bloqueante\n");
	}
	
	if(tcsetattr(fd, TCSANOW, &newtio)!=0)
        {
		printf("Error estableciendo nueva configuración bloqueante/no-bloqueante.\n");
		return -1;
        }
	
	return 0;	
    }

  /** \fn int Clean_Buffer(HANDLE fd)
   *  \brief Termina las operaciones de lectura y escritura pendientes y limpia
   *         las colas de recepción y de transmisión.
   *  \param fd Es el manejador del puerto. 
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *  \ingroup HeaderLinux    
   */  
    int Clean_Buffer(HANDLE fd) 
    {
       	if(tcflush(fd, TCIOFLUSH)!=0)
        {
              printf("Error Limpiando el Buffer  de entrada y salida.\n");
              return -1;
        }
       return 0;
    }
    
  /** \fn int Setup_Buffer(HANDLE fd,unsigned long InQueue,unsigned long OutQueue) 
   *  \brief Especifica el tamaño en Bytes del buffer de entrada y salida.
   *  \param fd Es el manejador del puerto. 
   *  \param InQueue Especifica el tamaño en Bytes del buffer de entrada, se 
   *                 Recomienda el uso de numero pares.
   *  \param OutQueue Especifica el tamaño en Bytes del buffer de salida, se 
   *                 Recomienda el uso de numero pares.
   *  \return TRUE si todo fue bien y FALSE si no lo fue.
   *      
   */  
    int Setup_Buffer(HANDLE fd,unsigned long InQueue,unsigned long OutQueue) 
    {
       return 0;
    }
    
#endif


