; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador
; -------------------------------------------------

; ------- DEFINICIONES Y CONSTANTES -------

.INCLUDE "m328Pdef.inc"
.INCLUDE "PWM.inc"
.INCLUDE "SerialPort.inc"
.INCLUDE "ADC.inc"
.INCLUDE "Auxiliar.inc"
.INCLUDE "Int0.inc"
.INCLUDE "Capture.inc"

.DEF COMP=R25
.DEF AUX=R24
.EQU BPS=68      ; Valor de UBRR0


.ORG 0x00
   RJMP RESET     ; Se evitan los vectores de interrupciones

.ORG INT0addr     ; Vector de interrupcion 0
   RJMP EXT_INT0

.ORG UDREaddr     ; Vector de interrupcion por recepcion
   RJMP INT_UDRE  


RESET:

; ------ INICIALIZACIONES -------

Stack_Init              ; Inicializa el stack

FastPWM_Init 127        ; Configura Fast PWM
SerialPort_Init BPS     ; Configura el puerto serie
SerialPort_DELAY        ; Delay para abrir el puerto serie
ADC_Init                ; Configura el ADC
RXCIE_Init              ; Configura la interrupcion por recepcion
Capture_Init            ; Configura el modo captura del Timer 1

CLR COMP                ; Limpia el registro de referencia para la espera
SEI                     ; Habilita las interrupciones globales

WAIT_FOR_CHAR           ; Espera a que se genere una interrupcion por recepcion

Int0_Init               ; Una vez recibido el caracter ' ', inicia

DELAY_1s                ; Retardo de 1s en el que se mandan los valores obtenidos por el modo captura

Int0_Close              ; Termina las interrupciones internas por INT0
Capture_Close           ; Termina la captura de los flancos ascendentes y descendentes
WAIT_FOR_CHAR           ; Espera a que se genere una interrupcion por recepcion

CLI                     ; Deshabilita las interrupciones globales


; ------- PROGRAMA PRINCIPAL -------

MAIN: 
   Read_ADC R18         ; Lee el valor arrojado por el ADC y lo almacena en R18
   TRANSMIT R18         ; Transmite el dato a la terminal
RJMP MAIN


; ------- INTERRUPCIONES -------

EXT_INT0:              ; Interrupcion externa INT0
IN AUX,SREG
PUSH AUX
PUSH COMP
   READ_ICR1 R19, R18   ; Lee la parte baja y alta de ICP1 y las devuelve 
   TOGGLE_EDGE         ; Cambia el flanco en el que se actualiza ICP1
   TRANSMIT R18        ; Se transmite la parte baja del registro leido
POP COMP
POP AUX
OUT SREG, AUX
RETI


INT_UDRE:              ; Interrupcion por recepcion de datos
IN AUX,SREG
PUSH AUX
   RECEIVE AUX         ; Recive el dato y lo almacena en AUX
   CPI AUX, ' '        ; Compara el dato con un caracter espacio
   BREQ START          ; Si coinciden, modifica el registro COMP en CONTINUE
   RJMP INT_UDRE_END   ; Si no, sale de la interrupcion
START:
   CONTINUE            ; Carga el valor 0xFF en COMP
INT_UDRE_END:
POP AUX
OUT SREG, AUX
RETI