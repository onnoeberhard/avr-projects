.include "m8def.inc"
 
.def temp    = r16                              ; Register für kleinere Arbeiten
.def zeichen = r17                              ; in diesem Register wird das Zeichen an die
                                                ; Ausgabefunktion übergeben
 
.equ F_CPU = 4000000                            ; Systemtakt in Hz
.equ BAUD  = 9600                               ; Baudrate
 
; Berechnungen
.equ UBRR_VAL   = ((F_CPU+BAUD*8)/(BAUD*16)-1)  ; clever runden
.equ BAUD_REAL  = (F_CPU/(16*(UBRR_VAL+1)))     ; Reale Baudrate
.equ BAUD_ERROR = ((BAUD_REAL*1000)/BAUD-1000)  ; Fehler in Promille
 
.if ((BAUD_ERROR>10) || (BAUD_ERROR<-10))       ; max. +/-10 Promille Fehler
  .error "Systematischer Fehler der Baudrate grösser 1 Prozent und damit zu hoch!"
.endif
 
    ; Stackpointer initialisieren
 
    ldi     temp, LOW(RAMEND)
    out     SPL, temp
    ldi     temp, HIGH(RAMEND)
    out     SPH, temp
 
    ; Baudrate einstellen
 
    ldi     temp, HIGH(UBRR_VAL)
    out     UBRRH, temp
    ldi     temp, LOW(UBRR_VAL)
    out     UBRRL, temp
 
    ; Frame-Format: 8 Bit
 
    ldi     temp, (1<<URSEL)|(3<<UCSZ0)
    out     UCSRC, temp
 
    sbi     UCSRB,TXEN                  ; TX aktivieren
 
loop:
    ldi     zeichen, 'T'
    rcall   serout                      ; Unterprogramm aufrufen
    ldi     zeichen, 'e'
    rcall   serout                      ; Unterprogramm aufrufen
    ldi     zeichen, 's'
    rcall   serout                      ; ...
    ldi     zeichen, 't'
    rcall   serout
    ldi     zeichen, '!'
    rcall   serout
    ldi     zeichen, 10
    rcall   serout
    ldi     zeichen, 13
    rcall   serout
    rcall   sync                        
    rjmp    loop
 
serout:
    sbis    UCSRA,UDRE                  ; Warten bis UDR für das nächste
                                        ; Byte bereit ist
    rjmp    serout
    out     UDR, zeichen
    ret                                 ; zurück zum Hauptprogramm
 
; kleine Pause zum Synchronisieren des Empfängers, falls zwischenzeitlich
; das Kabel getrennt wurde
                                    
sync:
    ldi     r16,0
sync_1:
    ldi     r17,0
sync_loop:
    dec     r17
    brne    sync_loop
    dec     r16
    brne    sync_1  
    ret
