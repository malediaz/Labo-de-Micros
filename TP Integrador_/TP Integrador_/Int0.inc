; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador - Macros Vector de Interrupcion 0
; -------------------------------------------------

.MACRO Int0_Init
   LDI R16, (1<<ISC00)     ; Configura la interrupcion para que 
   STS EICRA, R16          ; se ejecute ante cualquier cambio de estado
   LDI R16, (1<<INT0)
   OUT EIMSK, R16          ; Habilita particularmente la interrupcion
   LDI R16, (1<<INTF0)
   OUT EIFR, R16           ; Borra los flags
   CBI DDRD, 2          ; Entrada para INT0 en PD2                     
.ENDMACRO

.MACRO Int0_Close    ; Inhabilita la interrupción externa INT0
   CLR R16
   OUT EIMSK, R16
.ENDMACRO
