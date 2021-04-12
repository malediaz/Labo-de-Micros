; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP3
; -------------------------------------------------
.INCLUDE "m328Pdef.inc"
.INCLUDE "macrosTP3.inc"

; Definiciones y constantes
.DEF AUX=R20
.EQU BPS=103      ; Valor de UBRR0
;.EQU NO_INTS=1
.EQU INTS=1

.ORG 0x000
RJMP RESET     ; Salteo los vectores de interrupcion y mensajes

.IFDEF INTS
.ORG UDREaddr  ; Vector de interrupcion
RJMP INT_UDRE  
.ENDIF

; Mensajes
WELCOME_MSG: 
.DB "*** Hola Labo de Micro ***", $0D, $0A, "Escriba 1, 2, 3 o 4 para controlar los LEDs", $0D, $0A, 0

ERROR_MSG:
.DB "ERROR: La entrada debe ser un numero entero comprendido entre el 1 y el 4", $0D, $0A, 0


RESET:            ; Inicio del programa
SET_STACK R16     ; Se inicializa el stack pointer

USART_CONF8N1 BPS ; Se configura la comunicacion USART 8N1
RCALL DELAY       ; Delay para abrir el puerto serie

LDI ZL,LOW(WELCOME_MSG<<1)    ; Carga el puntero Z con la direc
LDI ZH,HIGH(WELCOME_MSG<<1)   ; del mensaje de inicio
RCALL	TRANSMIT                ; Lo transmite a la terminal

LDI R16, 0B0011111   ; Configura las salids del puerto B
OUT DDRB, R16 

; ------------------- SIN INTERRUPCIONES --------------------

.IFDEF NO_INTS       
MAIN:             ; Loop principal
   RCALL RECIEVE  ; Recibe y guarda el caracter tipeado por el usuario en R16
   CPI R16, '1'   ; Compara con el valor de "1" en ASCII
   BREQ LED1      ; Si coincide, prende/apaga el LED 1
   BRLO ERROR     ; Si es menor, avisa sobre el error
   CPI R16, '4'   ; Compara con el valor de "4" en ASCII
   BREQ LED4      ; Si coincide, prende/apaga el LED 4
   BRPL ERROR     ; Si es mayor, avisa sobre el error
   CPI R16, '2'   ; Compara con el valor de "2" en ASCII
   BREQ LED2      ; Si coincide, prende/apaga el LED 2
   CPI R16, '3'   ; Compara con el valor de "3" en ASCII
   BREQ LED3      ; Si coincide, prende/apaga el LED 3
   RJMP MAIN      ; Repite


LED1:
LED_TOGGLE 0, MAIN

LED2:
LED_TOGGLE 1, MAIN

LED3:
LED_TOGGLE 2, MAIN

LED4:
LED_TOGGLE 3, MAIN

ERROR:  ; Transmite el mensaje de error y vuelve al inicio del programa principal
TRANSMIT_ERROR ERROR_MSG, MAIN
.ENDIF

; ------------------- CON INTERRUPCIONES --------------------

.IFDEF INTS
RCALL RXCIE_ENABLE   ; Se habilita las interrupciones por recepcion
SEI                  ; Se habilitan las interrupciones globales

MAIN:                ; Loop principal
   RJMP MAIN


INT_UDRE:         ; Rutina de interrupcion
IN AUX,SREG
PUSH AUX
   RCALL RECEIVE  ; Recibe y guarda el caracter tipeado por el usuario en R16
   CPI R16, '1'   ; Compara con el valor de "1" en ASCII
   BREQ LED1      ; Si coincide, prende/apaga el LED 1
   BRLO ERROR     ; Si es menor, avisa sobre el error
   CPI R16, '4'   ; Compara con el valor de "4" en ASCII
   BREQ LED4      ; Si coincide, prende/apaga el LED 4
   BRPL ERROR     ; Si es mayor, avisa sobre el error
   CPI R16, '2'   ; Compara con el valor de "2" en ASCII
   BREQ LED2      ; Si coincide, prende/apaga el LED 3
   CPI R16, '3'   ; Compara con el valor de "3" en ASCII
   BREQ LED3      ; Si coincide, prende/apaga el LED 4
INT_END:
POP AUX
OUT SREG, AUX
RETI  

RXCIE_ENABLE:      ; Rutina que habilita las interrupciones por recepcion
   LDS AUX, UCSR0B       
   SBR AUX, (1<<RXCIE0)
   STS UCSR0B, AUX
RET

LED1:
LED_TOGGLE 0, INT_END

LED2:
LED_TOGGLE 1, INT_END

LED3:
LED_TOGGLE 2, INT_END

LED4:
LED_TOGGLE 3, INT_END

ERROR:  ; Transmite el mensaje de error y salta al final de la int
TRANSMIT_ERROR ERROR_MSG, INT_END

.ENDIF

; -------------------- SUBRUTINAS ----------------------------

TRANSMIT:	         ; Transmite un mensaje de cadenas de caracteres
LPM R16, Z+	   	   ; Carga el dato del string en el registro
TST R16              ; Chequea si el dato es nulo
BREQ TRANSMIT_END    ; En ese caso, finaliza la transmision
TRANSMIT_WAIT:
   LDS R17, UCSR0A   ; Carga el registro UCSR0A en R17
   SBRS R17, UDRE0   ; Espera a que el buffer de transmision este vacio
   RJMP TRANSMIT_WAIT
   STS UDR0, R16     ; Transmite el dato
   RJMP TRANSMIT     ; Repite
TRANSMIT_END:
RET

RECEIVE:	            ; Recibe un caracter
   LDS R17, UCSR0A   ; Carga el registro UCSR0A en R17
   SBRS R17, RXC0    ; Espera a que haya un dato disponible
   RJMP RECEIVE
   LDS R16, UDR0     ; Almacena el caracter recibido
RET

DELAY:         ; Retardo de 20ms
LDI R24, 2
LDI R25, 160
LDI R26, 147
L1: 
   DEC R26
   BRNE L1
   DEC R25
   BRNE L1
   DEC R24
   BRNE L1
RET

