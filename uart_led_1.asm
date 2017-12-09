;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCD mit 4bit-Interface und UART             ;;
;; DB4-DB7:       PB0-PB3                      ;;
;; RS:            PB4                          ;;
;; E:             PB5                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "m8def.inc"




.def temp1 		= r16	; für LCD
.def temp2 		= r17
.def temp3 		= r18

.def temp4 		= r19	; für ADC
.def adlow 		= r20
.def adhigh 	= r21
.def messungen 	= r22
.def zeichen 	= r23
.def ztausend 	= r24	
.def tausend	= r25
.def hundert 	= r26
.def zehner 	= r27
.def pinc_alt	= r28 ; für Wechsel zwischen den beiden Sensoren
.def unterbr	= r29 ; für Unterbrechung von der Computertastatur aus

.equ F_CPU = 4000000  ; Systemtakt in Hz
.equ BAUD  = 9600                               ; Baudrate
 
; Berechnungen
.equ UBRR_VAL   = ((F_CPU+BAUD*8)/(BAUD*16)-1)  ; clever runden
.equ BAUD_REAL  = (F_CPU/(16*(UBRR_VAL+1)))     ; Reale Baudrate
.equ BAUD_ERROR = ((BAUD_REAL*1000)/BAUD-1000)  ; Fehler in Promille
 
.if ((BAUD_ERROR>10) || (BAUD_ERROR<-10))       ; max. +/-10 Promille Fehler
  .error "Systematischer Fehler der Baudrate grösser 1 Prozent und damit zu hoch!"
.endif

.org 0x00								; Sprungadressen für Interrupt
        rjmp start
 
.org URXCaddr
        rjmp int_rxc

    
 
start:
	ldi temp1, LOW(RAMEND)				; Stack-Pointer initialisieren
	out SPL, temp1
	ldi temp1, HIGH(RAMEND)
	out SPH, temp1


	ldi temp1, 0xFF						; Port B = Ausgang
	out DDRB, temp1

 
    ldi     temp1, HIGH(UBRR_VAL) 		; Baudrate einstellen
    out     UBRRH, temp1
    ldi     temp1, LOW(UBRR_VAL)
    out     UBRRL, temp1
 
   
    ldi     temp1, (1<<URSEL)|(3<<UCSZ0) ; Frame-Format: 8 Bit
    out     UCSRC, temp1

 
    sbi     UCSRB,TXEN                  	; TX aktivieren

	sbi     UCSRB, RXCIE                    ; Interrupt bei Empfang
    sbi     UCSRB, RXEN                     ; RX (Empfang) aktivieren
    
    sei                                     ; Interrupts global aktivieren



	rcall lcd_init
	rcall lcd_clear

	ldi pinc_alt, 0x01



; ADC initialisieren: single conversion, Vorteiler 8

Main:

loop_no:
	cpi		unterbr, 'n'
	sbi		PORTB, 7 				; für Relaissteuerung
	brne	Main2
	rjmp 	loop_no

Main2:
	cbi		PORTB, 7
	cpi 	pinc_alt, 0x00
	brne 	nicht_gleich
	ldi 	pinc_alt, 0x01
	ldi 	temp1, (1<<REFS0)		; interne Referenzspannung 5V, ADLAR rechtsbündig, Kanal 0
									; entspricht wohl 0b01000000
	rjmp weiter
	
nicht_gleich:
	ldi pinc_alt, 0x00
	ldi temp1, (1<<REFS0)|(1<<MUX0) ; Kanal 1 statt Kanal 0
	
weiter:
	out ADMUX, temp1
	ldi temp1, (1<<ADEN)|(0<<ADPS2)|(1<<ADPS1)|(1<<ADPS0) 
	out ADCSRA, temp1			; ADC ein, Conversion nicht gestartet, kein free running, kein Interrupt, 
								; Vorteiler 8, entspricht wohl 0b10000011

	clr temp1
	clr temp2
	clr temp3
	clr temp4

	ldi messungen, 255		; 256 Schleifendurchläufe


sample_adc:
	sbi ADCSRA, ADSC		; den ADC starten

wait_adc:
	sbic ADCSRA, ADSC		; wenn der ADC fertig ist, wird ADSC 0 und die Schleife beendet
	rjmp wait_adc

; ADC einlesen
	in adlow, ADCL			; zuerst low-byte einlesen
	in adhigh, ADCH			; dann gesperrtes high-byte

; 256 ADC-Werte addieren über 24 Bit breites Akkumulationsregister
	add temp2, adlow		
	adc temp3, adhigh
	adc temp4, temp1		; temp1 enthält 0 
	dec messungen
	brne sample_adc

; aus den 256 Werten den Mittelwert berechnen

	cpi temp2, 128			; "Kommastelle" kleiner als 128 ?
	brlo no_round			; Sprung, wenn kleiner

; Aufrunden
	subi temp3, low(-1)		; addieren von 1 (subtrahieren von -1)
	sbci temp4, high(-1)	; addieren des Carry

no_round:
	mov adlow, temp3
	mov adhigh, temp4



; in ASCII umwandeln
; Division durch mehrfache Subtraktion
 
    ldi     ztausend, '0'-1     ; Ziffernzähler direkt als ASCII Code
Z_ztausend:
    inc     ztausend
    subi    adlow, low(10000)   ; -10,000
    sbci    adhigh, high(10000) ; 16 Bit
    brcc    Z_ztausend
                                    
    subi    adlow, low(-10000)  ; nach Unterlauf wieder einmal addieren
    sbci    adhigh, high(-10000); +10,000
 
    ldi     tausend, '0'-1      ; Ziffernzähler direkt als ASCII Code
Z_tausend:
    inc     tausend
    subi    adlow, low(1000)    ; -1,000
    sbci    adhigh, high(1000)  ; 16 Bit
    brcc    Z_tausend
                                    
    subi    adlow, low(-1000)   ; nach Unterlauf wieder einmal addieren
    sbci    adhigh, high(-1000) ; +1,000
 
    ldi     hundert, '0'-1      ; Ziffernzähler direkt als ASCII Code
Z_hundert:
    inc     hundert
    subi    adlow, low(100)     ; -100
    sbci    adhigh, high(100)   ; 16 Bit
    brcc    Z_hundert
                                    
    subi    adlow, low(-100)    ; nach Unterlauf wieder einmal addieren
    sbci    adhigh, high(-100)  ; +100
 
    ldi     zehner, '0'-1       ; Ziffernzähler direkt als ASCII Code
Z_zehner:
    inc     zehner
    subi    adlow, low(10)      ; -10
    sbci    adhigh, high(10)    ; 16 Bit
    brcc    Z_zehner
                                    
    subi    adlow, low(-10)     ; nach Unterlauf wieder einmal addieren
    sbci    adhigh, high(-10)   ; +10
 
    subi    adlow, -'0'         ; adlow enthält die Einer, Umwandlung in ASCII
 
;an LCD senden
	cpi pinc_alt, 0x00
	brne soundsen
	
	ldi zeichen, 'H'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'e'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'l'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'l'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'i'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'g'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'k'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'e'
	rcall lcd_data
	rcall serout

	rcall lcd_DDhigh


	ldi zeichen, 'i'
	rcall lcd_data
	rcall serout
	ldi zeichen, 't'
	rcall lcd_data
	rcall serout
	ldi zeichen, ':'
	rcall lcd_data
	rcall serout

	ldi zeichen, $20 ; Leerzeichen
	rcall lcd_data
	rcall serout

	rjmp weiter2

soundsen:
	ldi zeichen, 'L'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'a'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'u'
	rcall lcd_data
	rcall serout
	ldi zeichen, 't'
	rcall lcd_data
	rcall serout
	ldi zeichen, 's'
	rcall lcd_data
	rcall serout
	ldi zeichen, 't'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'a'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'e'
	rcall lcd_data
	rcall serout
	
	rcall lcd_DDhigh

	ldi zeichen, 'r'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'k'
	rcall lcd_data
	rcall serout
	ldi zeichen, 'e'
	rcall lcd_data
	rcall serout
	ldi zeichen, ':'
	rcall lcd_data
	rcall serout
	ldi zeichen, $20
	rcall lcd_data
	rcall serout
	
weiter2:
	;mov     zeichen, ztausend   ; Zehntausender Stelle, hier nicht benutzt
    ;rcall lcd_data
   	
	cpi pinc_alt, 0x00
	brne soundsen3				; bei Lautstärke nur Hunderter, Zehner, Einer

    mov     zeichen, tausend    ; Tausender Stelle ausgeben
    rcall lcd_data
	rcall serout

soundsen3:   
    mov     zeichen, hundert    ; Hunderter Stelle ausgeben
    rcall lcd_data
	rcall serout
	
    mov     zeichen, zehner     ; Zehner Stelle ausgeben
    rcall lcd_data
	rcall serout
   
  	mov     zeichen, adlow      ; Einer Stelle ausgeben
    
	cpi hundert, $30			; Korrektur für Soundsensor: 006 = 0
	brne soundsen4
	cpi zehner, $30
	brne soundsen4
	cpi adlow, $37
	brsh soundsen4
	ldi zeichen, $30 

soundsen4:
	rcall lcd_data
	rcall serout
	    
	rcall delay_long
	rcall delay_long	; mehrfach bei 4 MHz Systemtakt
    rcall lcd_clear
	rcall lcd_home
	rcall delay_long

	 
    rjmp    Main
 


lcd_init:				; Initialisierung: muss ganz am Anfang des Programms aufgerufen werden 
	push temp1
	push temp2
	push temp3

	ldi   temp3,50			
powerupwait:
           rcall delay5ms
           dec   temp3
           brne  powerupwait
           ldi   temp1,    0b00000011   ; muss 3mal hintereinander gesendet
           out   PORTB, temp1        	; werden zur Initialisierung
           rcall lcd_enable             ; 1
           rcall delay5ms
           rcall lcd_enable             ; 2
           rcall delay5ms
           rcall lcd_enable             ; und 3!
           rcall delay5ms
           ldi   temp1,    0b00000010   ; 4bit-Modus einstellen
           out   PORTB, temp1
           rcall lcd_enable
           rcall delay5ms
           ldi   temp1,    0b00101000   ; 4 Bit, 2 Zeilen, 5x8 dots
           rcall lcd_command
           ldi   temp1,    0b00001100   ; Display on, Cursor off
           rcall lcd_command
           ldi   temp1,    0b00000100   ; inkrement, kein Scrollen
           rcall lcd_command

		   pop temp3
		   pop temp2
		   pop temp1
		   ret
 

lcd_data:								 ;sendet ein Datenbyte an das LCD
           push temp1
		   push temp2
		   mov temp1, zeichen
		   mov   temp2, temp1            ; "Sicherungskopie" für
                                         ; die Übertragung des 2.Nibbles
           swap  temp1                   ; Vertauschen
           andi  temp1, 0b00001111       ; oberes Nibble auf Null setzen
           sbr   temp1, 1<<4	         ; entspricht 0b00010000
           out   PORTB, temp1        	 ; ausgeben
           rcall lcd_enable              ; Enable-Routine aufrufen
                                         ; 2. Nibble, kein swap da es schon
                                         ; an der richtigen Stelle ist
           andi  temp2, 0b00001111       ; obere Hälfte auf Null setzen 
           sbr   temp2, 1<<4	         ; entspricht 0b00010000
           out   PORTB, temp2         	 ; ausgeben
           rcall lcd_enable              ; Enable-Routine aufrufen
           rcall delay50us               ; Delay-Routine aufrufen

		   pop temp2
		   pop temp1
		   ret                           

 

lcd_command:                             ; sendet einen Befehl an das LCD, wie lcd_data, nur ohne RS zu setzen
           push temp1
		   push temp2

		   mov   temp2, temp1
           swap  temp1
           andi  temp1, 0b00001111
	   	   out 	 PORTB, temp1
           rcall lcd_enable
           andi  temp2, 0b00001111
           out   PORTB, temp2
           rcall lcd_enable
           rcall delay50us

		   pop temp2
		   pop temp1
           ret
 

lcd_enable:							; erzeugt den Enable-Puls
           sbi PORTB, 5	          	; Enable high
           nop                      ; 3 Taktzyklen warten
           nop
           nop
           cbi PORTB, 5		        ; Enable wieder low
           ret                                               
 
lcd_DDhigh:
		   push temp1
		   ldi temp1, 0b11000000	;Cursor-Position auf Zeile 2, Spalte 0
		   rcall lcd_command
		   rcall delay5ms
		   pop temp1
		   ret

 
delay50us:                          	; 50us Pause nach jeder Übertragung
           push temp1

		   ldi  temp1, $42
delay50us_:
           dec  temp1
           brne delay50us_

		   pop temp1
           ret                         


delay5ms:                         	    ; 5ms Pause, längere Pause für manche Befehle
           push temp1
		   push temp2

		   ldi  temp1, $21
WGLOOP0:   ldi  temp2, $C9
WGLOOP1:   dec  temp2
           brne WGLOOP1
           dec  temp1
           brne WGLOOP0
           
		   pop temp2
		   pop temp1
		   ret
		   
		   
delay_long:								; längere Pause (bestimmen über temp1)
			push temp1
			push temp2
			push temp3

			ldi  temp1, $8				
WGLOOP2:   	ldi  temp2, $FF
WGLOOP3:   	ldi  temp3, $FF
WGLOOP4:   	dec  temp3
           	brne WGLOOP4
           	dec  temp2
           	brne WGLOOP3
			dec  temp1
			brne WGLOOP2

			pop temp3
			pop temp2
			pop temp1
			ret                         
 
lcd_clear:								; Sendet den Befehl zur Löschung des Displays
           push  temp1
           
		   ldi   temp1,    0b00000001   ; Display löschen
           rcall lcd_command
           rcall delay5ms
           
		   pop   temp1
           ret

lcd_home:								; Cursor Home
           push temp1
		   push zeichen

		   ldi   temp1,    0b00000010   ; entspricht Cursor home
           rcall lcd_command
           rcall delay5ms

		   	ldi     zeichen, 10			;am Computer neue Zeile und Wagenrücklauf
   	    	rcall   serout
    		ldi     zeichen, 13
    		rcall   serout
           
		   pop zeichen
		   pop temp1
		   ret

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



; Interruptroutine: wird ausgeführt sobald ein Byte über das UART empfangen wurde

int_rxc:
	push 	zeichen
    push    temp1                       ; temp1 auf dem Stack sichern
    in      temp1, sreg                 ; SREG sichern
    push    temp1

   
    in      temp1, UDR                  ; UART Daten lesen
    cpi     temp1, 'n'                  ; empfangenes Byte mit 'n' vergleichen
    brne    int_rxc_1                   ; wenn nicht gleich, dann zu int_rxc_1
	rcall 	lcd_clear
	rcall	lcd_home
    ldi 	zeichen, 'n'
	ldi		unterbr, 'n'
	rcall 	lcd_data
	rcall 	serout
	rjmp	int_rxc_2
	
		
int_rxc_1:
	
    cpi     temp1, 'y'                  ; empfangenes Byte mit 'y' vergleichen
    brne    int_rxc_2                   ; wenn nicht gleich, dann zu int_rxc_2
	rcall 	lcd_clear
	rcall	lcd_home
    ldi 	zeichen, 'y'
	ldi		unterbr, 'y'
	rcall 	lcd_data
	rcall 	serout
	
int_rxc_2:
	rcall delay_long
	rcall delay_long	; mehrfach bei 4 MHz Systemtakt
    rcall lcd_clear
	rcall lcd_home
	rcall delay_long
    pop     temp1
    out     sreg, temp1                 ; SREG wiederherstellen
    pop     temp1                       ; temp1 wiederherstellen
	pop 	zeichen
    reti

	


