; Diaz Falvo,Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP Integrador - Macros ADC
; -------------------------------------------------

.MACRO ADC_Init               ; Inicializa el ADC
   CBI DDRC, 0          ; Entrada analogica PC0
   ; Ajusta el registro de salida a la izquierda y configura la entrada ADC0
   LDI R16, (1<<ADLAR) | (1<<REFS0)
   STS ADMUX, R16
   ; Habilita el ADC, el inicio de la conversion y un prescaler de 128 para el clock interno
   LDI R16, (1<<ADEN) | (1<<ADSC) | (1<<ADPS2) | (1<<ADPS1)| (1<<ADPS0)  
   STS ADCSRA, R16     
   LDI R16, (1<<ADC0D)        ; Deshabilita el buffer digital de entrada del pin ADC0
   STS DIDR0, R16             ; a fin de disminuir el consumo de potencia
.ENDMACRO

.MACRO Read_ADC         ; Lee la entrada analógica y la devuelve en el registro pasado
READ:
   LDS R16, ADCSRA      ; Lee el registro ADCSRA
   SBRC R16, ADSC       ; Si el flag ADIF esta en estado alto
   RJMP MAIN            ; la conversion continua y se repite el loop
   ORI R16, (1<<ADSC)   ; Si no, se carga un 1 en el bit ADSC
   STS ADCSRA, R16      ; del registro ADCSRA al inicio de conversion
   LDS @0, ADCH         ; Lee la parte alta del registro conversor
.ENDMACRO