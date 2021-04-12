; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP3 - Macros
; -------------------------------------------------

.MACRO SET_STACK     ; Inicializa el stack pointer
   LDI @0, LOW(RAMEND) 
   OUT SPL, @0
   LDI @0, HIGH(RAMEND)   
   OUT SPH, @0
.ENDMACRO

.MACRO USART_CONF8N1
   LDI R16, LOW(@0)                ; Prescaler de puerto serie
   LDI R17, HIGH(@0)
   STS UBRR0L, R16                   ; Define el Baud Rate
   STS UBRR0H, R17                 
   LDI R16, (1<<RXEN0)|(1<<TXEN0)    ; Habilita transmision y recepcion
   STS UCSR0B,R16                   
   LDI R16, (1<<UCSZ00)|(1<<UCSZ01)  ; Sin bit de paridad, transmision asincronica de 8 bits
   STS UCSR0C, R16	
.ENDMACRO

.MACRO LED_TOGGLE   ;Prende o apaga un LED segun su estado actual
   SBIC PORTB, @0      ; Si el LED esta apagado, no salta a LED_OFF 
   RJMP LED_OFF
   SBI PORTB, @0       ; Prende el LED
   RJMP @1             ; Salta al lugar especificado
LED_OFF:
   CBI PORTB, @0    ; Apaga el LED
   RJMP @1             ; Salta al lugar especificado
.ENDMACRO

.MACRO TRANSMIT_ERROR   ; Avisa sobre un error cometido
LDI ZL,LOW(@0<<1)       ; Cargo el puntero Z con la direccion
LDI ZH,HIGH(@0<<1)      ; de memoria de el mensaje de error
RCALL	TRANSMIT          ; Transmite
RJMP @1
.ENDMACRO