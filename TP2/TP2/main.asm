; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP2
; -------------------------------------------------
.include "m328Pdef.inc"

; Definiciones y constantes
.DEF T1=R21
.DEF T2=R22
.DEF T3=R23
.EQU SWITCH1_ON=0B00100001
.EQU SWITCH1_OFF=0

.ORG 0x00
RJMP RESET     ; Se evitan los vectores de interrupciones

.ORG INT0addr  ; Vector de interrupcion 1
RJMP SWITCH1

.ORG INT1addr  ; Vector de interrupcion 2
RJMP SWITCH2


RESET:                  ; Inicializacion del stack
LDI R17, LOW(RAMEND)
OUT SPL, R17
LDI R17, HIGH(RAMEND)
OUT SPH, R17

LDI R16, 0B00001111     ; Configuro ambas interrupciones para que 
STS EICRA, R16          ; se ejecuten ante un flanco ascendente
LDI R16, 0B00000011
OUT EIMSK, R16          ; Habilito particularmente cada interrupcion
LDI R16, 0B00000011
OUT EIFR, R16           ; Borro los flags
SEI                     ; Habilito las interrupciones globales

LDI R16, 0B00111111
OUT DDRC, R16           ; Configuro los 5 pines del PORT C como salidas
CLR R16
OUT DDRD, R16           ; Configuro los bits del PORT D como entradas

LDI R16, 0B01000000

RIGHT:
   LSR R16              ; Corro los bits un espacio a la derecha
   OUT PORTC, R16       ; Prendo el LED correspondiente al bit en alto
   RCALL DELAY250m
   CPI R16, 1           ; Si llego a 00000001, salto a LEFT
   BREQ LEFT
   RJMP RIGHT           ; En otro caso, repito

LEFT:
   LSL R16              ; Corro los bits un espacio hacia la izquierda
   OUT PORTC, R16
   RCALL DELAY250m
   CPI R16, 0B00100000  ; Si esta en alto el bit correspondiente al LED
   BREQ RIGHT           ; que esta mas a la derecha, salto a RIGHT
   RJMP LEFT            ; Si no, repito


DELAY250m:       ; Retardo de 250ms a 16MHz
LDI T1, 243      ; Loops anidados
LOOP0:
   LDI T2, 229 
LOOP1:
   LDI T3, 23
LOOP2:
   DEC T3
   BRNE LOOP2
   DEC T2 
   BRNE LOOP1 
   DEC T1
   BRNE LOOP0 
RET

DELAY500m:         ; Retardo de 500ms a 16MHz
    LDI  R24, 41
    LDI  R25, 150
    LDI  R26, 128
L1: DEC  R26
    BRNE L1
    DEC  R25
    BRNE L1
    DEC  R24
    BRNE L1
RET

SWITCH1:          ; Interrupcion para el pulsador 1
PUSH R16          ; Guardo en el stack el contador 
IN R18, SREG      ; Guardo SREG en un registro
PUSH R18          ; Y el mismo lo guardo en el stack
LDI R16, 15
LDI R18, SWITCH1_ON
LDI R19, SWITCH1_OFF
BLINK:
   OUT PORTC, R18 ; Prendo los LEDs de los extremos
   RCALL DELAY500m
   OUT PORTC, R19 ; Apago los LEDs de los extremos
   RCALL DELAY500m
   DEC R16
   BRNE BLINK
POP R18        
OUT SREG, R18     ; Restauro el SREG como lo encontre
POP R16           ; Copio los valores de los registros que guarde en el stack
RETI

SWITCH2:          ; Interrupcion para el pulsador 2
PUSH R16          ; Guardo en el stack el contador 
IN R18, SREG      ; Guardo SREG en un registo
PUSH R18          ; Y el mismo lo guardo en el stack
LDI R16, 0
INCREMENT:
   OUT PORTC, R16 ; Prendo LEDs segun el valor de R16
   RCALL DELAY250m
   INC R16
   CPI R16, 64    ; Si se supera el valor 63, salgo del loop
   BRNE INCREMENT
POP R18        
OUT SREG, R18     ; Restauro el SREG como lo encontre
POP R16           ; Copio los valores de los registros que guarde en el stack
RETI