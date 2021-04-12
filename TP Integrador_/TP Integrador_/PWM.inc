; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador - Macros PWM
; -------------------------------------------------

.MACRO FastPWM_Init           ; Inicializa Fast PWM
   LDI R16, (1<<COM0A1) | (1<<WGM00) | (1<<WGM01) | (1<<WGM02)
   OUT TCCR0A, R16            ; Fast PWM de 8 bits con OCR0A como TOP
   LDI R16, (1<<CS02) | (1<<CS00) 
   OUT TCCR0B, R16            ; Prescaler de 1024
   LDI R16, 0
   OUT TCNT0, R16             ; Inicializa el Timer en 0
   LDI R16, @0
   OUT OCR0A, R16             ; Define el Duty Cycle
   SBI DDRD, 6                ; Salida para el fast PWM en PD6
.ENDMACRO

