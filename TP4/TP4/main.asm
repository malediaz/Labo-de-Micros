; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP4
; -------------------------------------------------
.include "m328Pdef.inc"

; Definiciones y constantes
.DEF T1=R18
.DEF T2=R19
.DEF T3=R20
.DEF RPINB=R21
.DEF RPIND=R22
.DEF TEMP=R23
;.EQU OVF=1
.EQU PWM=1


.ORG 0x00
RJMP RESET     ; Se evitan los vectores de interrupciones

.IFDEF OVF
.ORG OVF1addr  ; Vector de interrupcion por overflow
RJMP INT_OVF
.ENDIF


RESET:          ; Inicializacion del stack
LDI TEMP, LOW(RAMEND)
OUT SPL, TEMP
LDI TEMP, HIGH(RAMEND)
OUT SPH, TEMP

SBI DDRB, 1          ; Configura PB1 como una salida
LDI R16, 0
OUT DDRD, R16        ; Configura los bits del PORT D como entradas

RCALL TIMER1_INIT    ; Se inicializa el Timer 1


; ---- Programa utilizando la interrupcion por overflow ----

.IFDEF OVF  
SEI

MAIN:
   IN RPIND, PIND    ; Lee el registro PIN D
   ANDI RPIND, 0x0C  ; Aplica una mascara para eliminar efectos de pines flotantes
   CPI RPIND, 0      ; Si la entrada es 00
   BREQ CLK_OFF      ; apaga el clock
   CPI RPIND, 0x08   ; Si la entrada es  10
   BREQ PRES_64      ; usa un prescaler de 64
   CPI RPIND, 0x04   ; Si la entrada es 01
   BREQ PRES_256     ; usa un prescaler de 256
   CPI RPIND, 0x0C   ; Si la entrada es 11
   BREQ PRES_1024    ; usa un prescaler de 1024
RJMP MAIN            ; Repite


; --------- Rutina de interrupcion -----------

INT_OVF:
PUSH RPIND         ; Guarda el estado de la entrada
IN TEMP, SREG      ; Guarda SREG en un registro
PUSH TEMP          ; Y el mismo lo guarda en el stack
   IN RPINB, PINB  ; Lee el estado del LED
   LDI TEMP, 0x02  ; Aplica una mascara para eliminar efectos de pines flotantes
   EOR TEMP, RPINB ; Realiza una Exclusive OR para invertir el estado del LED
   OUT PORTB, TEMP ; Realiza el toggle
POP TEMP        
OUT SREG, TEMP     ; Restaura el SREG
POP RPIND          ; Copia los valores de los registros guardados en el stack
RETI


CLK_OFF:
   LDI TEMP, 0    
   STS TCCR1B, TEMP  ; Detiene el clock
   SBIS PORTB, 1     ; Si el LED esta prendido ignora lo siguiente
   SBI PORTB, 1      ; Prende el LED
RJMP MAIN            ; Vuelve al loop principal

PRES_64:
   LDI TEMP, (1<<CS11) | (1<<CS10)
   STS TCCR1B, TEMP        ; Prescaler en 64
RJMP MAIN                  ; Vuelve al loop principal

PRES_256:
   LDI TEMP, (1<<CS12)
   STS TCCR1B, TEMP        ; Prescaler en 256
RJMP MAIN                  ; Vuelve al loop principal

PRES_1024:
   LDI TEMP, (1<<CS12) | (1<<CS10)
   STS TCCR1B, TEMP        ; Prescaler en 1024
RJMP MAIN                  ; Vuelve al loop principal


TIMER1_INIT:               ; Configuracion del Timer 1 por overflow
   LDI TEMP, (1<<TOIE1)
   STS TIMSK1, TEMP        ; Habilita interrupcion por overflow
   CLR TEMP
   STS TCNT1H, TEMP        ; Inicializa la parte alta y baja 
   STS TCNT1L, TEMP        ; del Timer 1 en 0
RET
.ENDIF


; ----------- Programa utilizando PWM -------------

.IFDEF PWM
MAIN:
   RCALL DELAY       ; Impone un retardo
   IN RPIND, PIND    ; Lee el registro PIN D
   ANDI RPIND, 0x0C  ; Aplica una mascara para eliminar efectos de pines flotantes
   CPI RPIND, 0      ; Si ningun pulsador esta presionado
   BREQ MAIN         ; Repite
   CPI RPIND, 0x0C   ; Si ambos pulsadores estan presionados
   BREQ MAIN         ; Repite
   CPI RPIND, 0x08   ; Si la entrada es 10
   BREQ BRIGHT       ; Aumenta la intensidad del LED
   CPI RPIND, 0x04   ; Si la entrada es 01
   BREQ FADE         ; Disminuye la intensidad del LED
RJMP MAIN            ; Repite

BRIGHT:
   LDS TEMP, OCR1AL  ; Lee la parte baja del registro OCR1A
   CPI TEMP, 0xFF    ; Si alcanza su maximo valor
   BREQ END          ; no hace nada
   INC TEMP          ; Si no, imcrementa en1 el registro
   STS OCR1AL, TEMP  ; Carga el valor incrementado a la parte baja del registro OCR1A
RJMP MAIN            ; Vuelve al loop principal

FADE:
   LDS TEMP, OCR1AL  ; Lee la parte baja del registro OCR1A
   CPI TEMP, 0       ; Si alcanza su minimo valor
   BREQ END          ; no hace nada
   DEC TEMP          ; Si no, decrementa en1 el registro
   STS OCR1AL, TEMP  ; Carga el valor decrementado a la parte baja del registro OCR1A
RJMP MAIN            ; Vuelve al loop principal

END:
RJMP MAIN            ; Vuelve al loop principal


; ----------- SUBRUTINAS -------------

TIMER1_INIT:            ; Configuracion del Timer 1
   LDI TEMP, (1<<COM1A1) | (1<<WGM10)
   STS TCCR1A, TEMP     ; Fast PWM de 8 bits con salida OC1A
   LDI TEMP, (1<<WGM12) | (1<<CS11) 
   STS TCCR1B, TEMP     ; Sin prescaler, frecuencoa de 16MHz
   CLR TEMP
   STS TCNT1H, TEMP     ; Inicializa el Timer/Counter a 0
   STS TCNT1L, TEMP
   STS OCR1AH, TEMP     ; Inicaliza el LED con el minimo brillo
   STS OCR1AL, TEMP     ; posible utilizando PWM
RET

DELAY:         ; Subrutina de retardo entre incrementos y decrementos
LDI T1, 200   
LOOP0:
   LDI T2, 50 
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
.ENDIF

