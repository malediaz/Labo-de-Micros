; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP5
; -------------------------------------------------
.include "m328Pdef.inc"

; Definiciones y constantes
.DEF TEMP=R23

.ORG 0x00
RJMP RESET

RESET:                  ; Inicializacion del stack
LDI R17, LOW(RAMEND)
OUT SPL, TEMP
LDI R17, HIGH(RAMEND)
OUT SPH, TEMP

CBI DDRC, 3          ; Entrada analogica PC2
LDI TEMP, 0xFF   
OUT DDRD, TEMP       ; Salidas digitales

; Habilita el ADC, el inicio de la conversion y un prescaler de 128 para el clock interno
LDI TEMP, (1<<ADEN) | (1<<ADSC) | (1<<ADPS0) | (1<<ADPS1) | (1<<ADPS2)  
STS ADCSRA, TEMP     
; Ajusta el registro de salida a la izquierda y configura la entrada ADC2
LDI TEMP, (1<<ADLAR) | (1<<MUX1)
STS ADMUX, TEMP      

CLI                     ; Deshabilita las interrupciones globales

MAIN:                   ; Loop principal
   LDS TEMP, ADCSRA     ; Lee el registro ADCSRA
   SBRS TEMP, 4         ; Si el flag ADIF esta en estado bajo
   RJMP MAIN            ; la conversion continua y se repite el loop
   LDI R16, (1<<ADSC)   
   LDS R17, ADCSRA
   OR R16, R17          ; Si no, se carga un 1 en el bit ADSC 
   STS ADCSRA, R16      ; del registro ADCSRA al inicio de conversion
   LDS R17, ADCH        ; Lee la parte alta del registro contador
   LSR R17              ; Corre el valor del registro dos bits
   LSR R17              ; a la derecha, tomando los 6 MSB
   OUT PORTD, R17       ; El resultado se carga al puerto D
RJMP MAIN               ; Repite