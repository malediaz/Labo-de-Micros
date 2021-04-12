; Diaz Falvo, Malena - 102374
; mcdiaz@fi.uba.ar
; 86.07 Laboratorio de Microprocesadores - 2C2020
; TP1
; -------------------------------------------------

.DEF RPINB=R18
.DEF RPIND=R19
.DEF T1=R20
.DEF T2=R21
.DEF T3=R22
;.EQU BLINK=1
;.EQU BUTTONS=1
.EQU PULLUP=1


; Codigo para la primera practica	
.IFDEF BLINK     
LDI R16, 0B11111111
OUT DDRD, R16       ; Configuro el PORT D como un puerto de salida

LOOP:               ; Encendido y apagado del LED conectandolo al PIN 2 (PD0)
   SBI PORTD, 0     ; Prendo el LED
   RCALL DELAY      ; Impongo un retardo
   CBI PORTD, 0     ; Apago el LED
   RCALL DELAY	     ; Vuelvo a imponer el retardo
   RJMP LOOP 

DELAY:              ; Retardo de 250ms a 16MHz
LDI T1, 243         ; Loops anidados
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

.ENDIF


; Codigo para la segunda practica
.IFDEF BUTTONS	

LDI R16, 0B00001111 ; Configuro la parte baja del PORT D como un puerto de salida
OUT DDRD, R16       ; y la alta como uno de entrada
LDI R16, 0B00000000
OUT DDRB, R16       ; Configuro el PORT B como un puerto de entrada

START:              ; Comienzo el programa con el LED apagado hasta que se presiona el pulsador 1
IN RPINB, PINB
SBRS RPINB, 0
RJMP START 

LOOP:
   IN RPINB, PINB ; Leo el registro PIN B
   IN RPIND, PIND ; Leo el registro PIN D
   SBRC RPIND, 7  ; Si no se presiona el pulsador, no se llama a la rutina OFF
   RJMP OFF
   SBI PORTD, 2   ; Prendo el LED
   RCALL DELAY    ; Llamo a la rutina de retardo
   SBRC RPIND, 7    
   RJMP OFF
   CBI PORTD, 2   ; Apago el LED
   RCALL DELAY
   RJMP LOOP         


; Rutina que mantiene apagado el LED hasta que se presiona el pulsador 1
OFF:          
   CBI PORTD, 2   ; Apago el LED
READ:
   IN RPINB, PINB ; Leo el registo PIN B
   SBRC RPINB, 0  ; Si se apreta el pulsador 1, se salta al loop principal
   RJMP LOOP			
   RJMP READ      ; Si no se apreta el pulsador 1, se sigue leyendo el PIN B

; Retardo de 500ms a 16MHz mientras se lee PD7
DELAY:            
LDI T1, 243       ; Loops anidados
LOOP0:
   LDI T2, 224 
LOOP1:
   LDI T3, 24
LOOP2:
   IN RPIND, PIND ; Leo el registro PIN D
   SBRC RPIND, 7  ; Si no se presiona el pulsador, no se llama a la rutina OFF
   RJMP OFF
   DEC T3
   BRNE LOOP2
   DEC T2 
   BRNE LOOP1 
   DEC T1
   BRNE LOOP0 
RET

.ENDIF


; Codigo para la tercera practica
.IFDEF PULLUP

LDI R16, 0B00001111  ; Parte baja del PORT D como un puerto de 
OUT DDRD, R16        ; salida y la alta como uno de entrada
LDI R16, 0B00000000
OUT DDRB, R16        ; PORT B como un puerto de entrada
LDI R16, 0B00000001
OUT PORTB, R16       ; Resistencia de pull-up en el LSB
LDI R16, 0B10000000  
OUT PORTD, R16       ; Resistencia de pull-up en el MSB

START:               ; Comienzo el programa con el LED apagado 
IN RPINB, PINB       ; hasta que se presiona el pulsador 1
SBRC RPINB, 0
RJMP START

LOOP:
   IN RPINB, PINB ; Leo el registro PIN B
   IN RPIND, PIND ; Leo el registro PIN D
   SBRS RPIND, 7  ; Si no se presiona el pulsador, no se llama a la rutina OFF
   RJMP OFF
   SBI PORTD, 2   ; Prendo el LED
   RCALL DELAY    ; Llamo a la rutina de retardo
   SBRS RPIND, 7    
   RJMP OFF
   CBI PORTD, 2   ; Apago el LED
   RCALL DELAY
   RJMP LOOP         


OFF:          
   CBI PORTD, 2   ; Apago el LED
READ:
   IN RPINB, PINB ; Leo el registo PIN B
   SBRS RPINB, 0  ; En caso de que se aprete el pulsador 1, se salta al loop principal
   RJMP LOOP			
   RJMP READ      ; Si no se apreta el pulsador 1, se sigue leyendo el PIN B

DELAY:            
LDI T1, 243    
LOOP0:
   LDI T2, 224 
LOOP1:
   LDI T3, 24
LOOP2:
   IN RPIND, PIND ; Leo el registro PIN D
   SBRS RPIND, 7  ; Si no se presiona el pulsador, no se llama a la rutina OFF
   RJMP OFF
   DEC T3
   BRNE LOOP2
   DEC T2 
   BRNE LOOP1 
   DEC T1
   BRNE LOOP0 
RET

.ENDIF

