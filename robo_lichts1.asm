;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lichtsensor								   ;;
;; DB4-DB7:       PB0-PB3                      ;;
;; RS:            PB4                          ;;
;; E:             PB5                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "m8def.inc"




;pin B0 = Lenkspule
;pin B1 = enable, negative Logik
;pin B2 = Schrittmotor1_spule1
;pin B3 = Schrittmotor1_spule2
;pin D2 = Taster 1 (Interrupt-Handler 0) = Lenkung nach links
;pin D3 = Taster 2 (Interrupt-Handler 1) = Lenkung nach rechts



.include "m8def.inc"
 
.def temp 		= r16
.def mot 		= r17
.def temp3		= r18
.def temp4 		= r19	
.def adlow 		= r20
.def led 		= r21	; weiter unten auch anstelle adhigh benutzt
.def messungen 	= r22
.def hundert 	= r23



.org 0x000
         rjmp main            ; Reset Handler
.org INT0addr
         rjmp int0_handler    ; IRQ0 Handler
.org INT1addr
         rjmp int1_handler    ; IRQ1 Handler

 
ldi led, 0b00000000			  ; initial LED-Licht aus


main:                         ; hier beginnt das Hauptprogramm
 
         ldi temp, LOW(RAMEND)
         out SPL, temp
         ldi temp, HIGH(RAMEND)
         out SPH, temp
 
         ldi temp, 0x00
         out DDRD, temp			; Port D = Eingang
 
         ldi temp, 0xFF
         out DDRB, temp			; Port B = Ausgang
 
         ldi temp, 0b00000000  	; INT0 und INT1 konfigurieren (bei low am Pin wird Interrupt aktiviert, da fallende Flanke 2x Durchlauf ergeben hat)
         out MCUCR, temp
 
         ldi temp, 0b11000000  	; INT0 und INT1 aktivieren
         out GICR, temp
 
         sei                   	; Interrupts allgemein aktivieren
 		 
		 rcall lichts			; bei jedem reset überprüfen, ob Licht eingeschaltet werden muß

		 ldi temp3, 60

loop:		rcall f_gerade

			cpi temp3, 23			; maximale Geschwindigkeit beim Vorwärtsfahren
			brge langsam			
			rjmp loop    
			
langsam: 	dec temp3
			dec temp3
			dec temp3
			rjmp loop


f_gerade:						; für Geradeausfahrt

			ldi mot, 0b00001010 ; Motor-Schleife an PB2 und PB3,
								; Lenker geradeaus = enable deaktiviert (PB1 = 1)
			eor mot, led 		; ggfs. LED - Licht an
			out DDRB, mot
			rcall delay_s2

			ldi mot, 0b00001110
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			ldi mot, 0b00000110
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			ldi mot, 0b00000010
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
					
			ret

 
int0_handler:
			
            push temp             	; Das SREG in temp sichern. Vorher
            in   temp, SREG       	; muss temp gesichert werden

			push adlow
			ldi adlow, 20				; Zeit, die der Lenker eingeschlagen ist

			push temp3
			ldi temp3, 50				; Schnelligkeit rückwärts
			
			push mot
						
			rcall loop_li
			rcall hand_2
			
		 	reti

 
int1_handler:

            push temp             
            in   temp, SREG       
 			push adlow
			ldi adlow, 20				; Zeit, die der Lenker eingeschlagen ist
			push temp3
			ldi temp3, 50				; Schnelligkeit rückwärts
			push mot

			rcall loop_re
			rcall hand_2
			
   		 	reti


hand_2:		pop temp3
			pop mot
			pop adlow
         	out SREG, temp        
         	pop temp

			ret 



loop_li:	dec adlow 
			ldi mot, 0b00000001 ; Motor-Schleife an PB2 und PB3, rückwärts
			eor mot, led 
			out DDRB, mot		; Lenker links = (PB0 = 1), enable aktiviert (PB1 = 0)
			rcall delay_s2

			ldi mot, 0b00000101
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			ldi mot, 0b00001101
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			ldi mot, 0b00001001
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			cpi adlow, 0
			brne loop_li
			ldi adlow, 20
			ldi temp3, 70		; Schnelligkeit vorwärts

loop_li2:	dec adlow
			ldi mot, 0b00001000 ; Motor-Schleife an PB2 und PB3, vorwärts
			eor mot, led 
			out DDRB, mot		; Lenker rechts = (PB0 = 0), enable aktiviert (PB1 = 0)
			rcall delay_s2

			ldi mot, 0b00001100
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			ldi mot, 0b00000100
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			ldi mot, 0b00000000
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			cpi adlow, 0
			brne loop_li2

			ret


loop_re:	dec adlow 
			ldi mot, 0b00000000 ; Motor-Schleife an PB2 und PB3, rückwärts
			eor mot, led 
			out DDRB, mot		; Lenker rechts = (PB0 = 0), enable aktiviert (PB1 = 0)
			rcall delay_s2

			ldi mot, 0b00000100
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			ldi mot, 0b00001100
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			ldi mot, 0b00001000
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			cpi adlow, 0	
			brne loop_re
			ldi adlow, 20
			ldi temp3, 70		;Schnelligkeit vorwärts

loop_re2:	dec adlow
			ldi mot, 0b00001001 ; Motor-Schleife an PB2 und PB3, vorwärts
			eor mot, led 
			out DDRB, mot		; Lenker links = (PB0 = 1), enable aktiviert (PB1 = 0)
			rcall delay_s2

			ldi mot, 0b00001101
			eor mot, led 
			out DDRB, mot
			rcall delay_s2

			ldi mot, 0b00000101
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			ldi mot, 0b00000001
			eor mot, led 
			out DDRB, mot
			rcall delay_s2
			
			cpi adlow, 0	
			brne loop_re2
			
			ret


delay_s2:						; variable Zeitverzögerung über temp3
			push mot
			push temp4
			mov mot, temp3   	
WLOOP1:   	ldi  temp4, 255
WLOOP2:   	dec  temp4
			cpi temp4, 0
           	brne WLOOP2
           	dec  mot
			cpi mot, 0
           	brne WLOOP1

			pop mot
			pop temp4   
			ret


lichts:
		push temp ;= r16
		push mot  ;= r17
		push temp3;= r18
		push temp4;= r19
		push adlow;= r20
		push led  ;= r21


; ADC initialisieren: single conversion, Vorteiler 8


	ldi 	temp, (1<<REFS0)		; interne Referenzspannung 5V, ADLAR rechtsbündig, Kanal 0
									; entspricht wohl 0b01000000
	out ADMUX, temp
	ldi temp, (1<<ADEN)|(0<<ADPS2)|(1<<ADPS1)|(1<<ADPS0) 
	out ADCSRA, temp			; ADC ein, Conversion nicht gestartet, kein free running, kein Interrupt, 
								; Vorteiler 8, entspricht wohl 0b10000011

	clr temp
	clr mot
	clr temp3
	clr temp4
	clr adlow

	ldi messungen, 255		; 256 Schleifendurchläufe


sample_adc:
	sbi ADCSRA, ADSC		; den ADC starten

wait_adc:
	sbic ADCSRA, ADSC		; wenn der ADC fertig ist, wird ADSC 0 und die Schleife beendet
	rjmp wait_adc

; ADC einlesen
	in adlow, ADCL			; zuerst low-byte einlesen
	in led, ADCH			; dann gesperrtes high-byte

; 256 ADC-Werte addieren über 24 Bit breites Akkumulationsregister
	add mot, adlow		
	adc temp3, led
	adc temp4, temp		; temp1 enthält 0 
	dec messungen
	brne sample_adc

; aus den 256 Werten den Mittelwert berechnen

	cpi mot, 128			; "Kommastelle" kleiner als 128 ?
	brlo no_round			; Sprung, wenn kleiner

; Aufrunden
	subi temp3, low(-1)		; addieren von 1 (subtrahieren von -1)
	sbci temp4, high(-1)	; addieren des Carry

no_round:
	mov adlow, temp3
	mov led, temp4



; in ASCII umwandeln
; Division durch mehrfache Subtraktion (hier nur Hunderter)
 

 
    ldi     hundert, '0'-1      ; Ziffernzähler direkt als ASCII Code
Z_hundert:
    inc     hundert
    subi    adlow, low(100)     ; -100
    sbci    led, high(100)   ; 16 Bit
    brcc    Z_hundert
                                    
    subi    adlow, low(-100)    ; nach Unterlauf wieder einmal addieren
    sbci    led, high(-100)  ; +100
 

	pop temp ;= r16
	pop	mot  ;= r17
	pop temp3;= r18
	pop temp4;= r19
	pop adlow;= r20
	pop led  ;= r21
	
	cpi 	hundert, '4'				; bei hoher Helligkeit (>= 4 Hunderter) Licht aus
	brge 	li_aus
	ldi led, 0b00010000	; LED Ereignis: ein 
	ret								

li_aus:							
	ldi led, 0b00000000	; LED Ereignis: aus 
	ret

	

