; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador - Macros Modo Captura 0
; -------------------------------------------------

.MACRO Capture_Init
   LDI R16, (1<<ICES1) | (1<<CS10) | (1<<CS12)
   STS TCCR1B, R16      ; Flanco ascendente con prescaler de 1024
   CBI DDRB, 0          ; Entrada para ICP1 en PB0
.ENDMACRO


.MACRO READ_ICR1     ; Lee la parte baja y alta del registro contador
   LDS @1, ICR1L
   LDS @0, ICR1H
.ENDMACRO


.MACRO TOGGLE_EDGE
   CLR R16                 ; Se vuelve a inicializar el timer en 0
   STS TCNT1L, R16
   STS TCNT1H, R16
   LDI R16, (1<<ICES1)     ; Se cambia la actualizacion de ICR1
   LDS R17, TCCR1B         ; de flanco ascendente a descendente
   EOR R17, R16            ; y viceversa
   STS TCCR1B, R17         
.ENDMACRO


.MACRO Capture_Close ; Inhabilita el modo captura
   CLR R16
   STS TCCR1B, R16
.ENDMACRO


