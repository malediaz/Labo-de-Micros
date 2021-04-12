; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador - Macros Puerto Serie
; -------------------------------------------------

.MACRO SerialPort_Init
   LDI R16, (1<<TXEN0) | (1<<RXEN0)    ; Habilita transmision y recepcion
   STS UCSR0B,R16                   
   LDI R16, (1<<UCSZ00) | (1<<UCSZ01)  ; Sin bit de paridad, transmision asincronica de 8 bits
   STS UCSR0C, R16	
   LDI R16, LOW(@0)                    ; Prescaler de puerto serie
   LDI R17, HIGH(@0)
   STS UBRR0L, R16                     ; Define el Baud Rate
   STS UBRR0H, R17                 
.ENDMACRO

.MACRO TRANSMIT	      ; Transmite el valor del registro pasado como argumento
TRANSMIT_WAIT:
   LDS R17, UCSR0A      ; Carga el registro UCSR0A en R17
   SBRS R17, UDRE0      ; Espera a que el buffer de transmision este vacio
   RJMP TRANSMIT_WAIT
   STS UDR0, @0         ; Transmite el dato
.ENDMACRO


.MACRO RXCIE_Init       
   LDS R16, UCSR0B      ; Modifica el registro UCSR0B para
   SBR R16, (1<<RXCIE0) ; habilitar las interrupciones por recepcion
   STS UCSR0B, R16
.ENDMACRO


.MACRO RECEIVE	      ; Recibe un caracter y lo devuelve almacenado en el registro pasado
RECEIVE:
   LDS AUX, UCSR0A   ; Carga el registro UCSR0A en R17
   SBRS AUX, RXC0    ; Espera a que haya un dato disponible
   RJMP RECEIVE
   LDS @0, UDR0     ; Almacena el caracter recibido
.ENDMACRO