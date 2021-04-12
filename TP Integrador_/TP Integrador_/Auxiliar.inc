; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador - Macros auxiliares
; -------------------------------------------------

.MACRO Stack_Init       ; Inicializa el stack
   LDI R16, LOW(RAMEND)
   OUT SPL, R16
   LDI R16, HIGH(RAMEND)
   OUT SPH, R16
.ENDMACRO


.MACRO SerialPort_DELAY    ; Retardo para abrir el puerto serie
    ldi  r21, 25
    ldi  r19, 160
    ldi  r20, 147
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r21
    brne L1
    nop
.ENDMACRO


.MACRO DELAY_1s     ; Retardo de 1s 
    ldi  r23, 82     
    ldi  r24, 43
    ldi  r25, 0
L1: dec  r25
    brne L1
    dec  r24
    brne L1
    dec  r23
    brne L1
    lpm
    nop
.ENDMACRO


.MACRO WAIT_FOR_CHAR       ; Loop que espera a que cambie el 
WAIT_FOR_CHAR:             ; valor de COMP a 0xFF
   CPI COMP, 0xFF
   BRNE WAIT_FOR_CHAR
.ENDMACRO


.MACRO CONTINUE            ; Cambia el valor de COMP a 0xFF
   LDI COMP, 0xFF
.ENDMACRO