.include "m8def.inc"
 
.def temp1         = r17
 
;	.equ XTAL = 4000000 			deaktiviert, da kein Quarz
 
    rjmp    init
 
;.include "keys.asm" 
;
;
 
init:
    ldi      temp1, LOW(RAMEND)     ; Stackpointer initialisieren
    out      SPL, temp1
    ldi      temp1, HIGH(RAMEND)
    out      SPH, temp1
  
    ;
    ; Timer 1 einstellen
    ;
    ; Modus 14:
    ;    Fast PWM, Top von ICR1
    ;
    ;     WGM13    WGM12   WGM11    WGM10
    ;      1        1       1        0
    ;
    ;    Timer Vorteiler: 256
    ;     CS12     CS11    CS10
    ;      1        0       0
    ;
    ; Steuerung des Ausgangsport: Set at BOTTOM, Clear at match
    ;     COM1A1   COM1A0
    ;      1        0
    ;
 
    ldi      temp1, 1<<COM1A1 | 1<<WGM11
    out      TCCR1A, temp1
 
    ldi      temp1, 1<<WGM13 | 1<<WGM12 | 1<<CS10 ; Vorteiler für Timer = 1
    out      TCCR1B, temp1
 
    ;
    ; den Endwert (TOP) für den Zähler setzen
    ; der Zähler zählt bis zu diesem Wert
    ;
    ldi      temp1, 0			; Periodendauer 25 µs bei internem Oszillator
    out      ICR1H, temp1		; entspricht 40.000 Hz
    ldi      temp1, 22   
    out      ICR1L, temp1
 
    ;
    ; der Compare Wert
    ; Wenn der Zähler diesen Wert erreicht, wird mit
    ; obiger Konfiguration der OC1A Ausgang abgeschaltet
    ; Sobald der Zähler wieder bei 0 startet, wird der
    ; Ausgang wieder auf 1 gesetzt
    ;
    ldi      temp1, 0x00		; nach der halben Periode wird angeschaltet
    out      OCR1AH, temp1
    ldi      temp1, 11
    out      OCR1AL, temp1
 
    ; Den Pin OC1A zu guter letzt noch auf Ausgang schalten
    ldi      temp1, 0x02
    out      DDRB, temp1
 
main:
    rjmp     main
