;pin B0 = Lenkspule
;pin B1 = enable, negative Logik
;pin B2 = Schrittmotor1_spule1
;pin B3 = Schrittmotor1_spule2
;pin D2 = Taster 1 (Interrupt-Handler 0) = Lenkung nach links
;pin D3 = Taster 2 (Interrupt-Handler 1) = Lenkung nach rechts



.include "m8def.inc"
 
.def temp = r16
.def mot = r17
.def led = r21


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
 
     	 ldi r18, 63			; initiale Verzögerung beim Anfahren (delay_s2)

		 
	

loop:		

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
			
			cpi r18, 23			; maximale Geschwindigkeit beim Vorwärtsfahren
			brge langsam			
			rjmp loop            
langsam:
			dec r18
			rjmp loop


 
int0_handler:
			
            push temp             	; Das SREG in temp sichern. Vorher
            in   temp, SREG       	; muss temp gesichert werden

			push r20
			ldi r20, 15			; Zeit, die der Lenker eingeschlagen ist
			
			push mot			

			ldi led, 0b00010000	; LED Ereignis: ein bei Ereignis Interrupt 0
			
			rcall loop_li
			rcall hand_2
			
		 	reti

 
int1_handler:

            push temp             
            in   temp, SREG       

 			push r20
			ldi r20, 15			; Zeit, die der Lenker eingeschlagen ist
			
			push mot

			ldi led, 0b00000000	; LED Ereignis: aus bei Ereignis Interrupt 1

			rcall loop_re
			rcall hand_2
			
   		 	reti


hand_2:		pop mot
			out DDRB, mot		
			rcall delay_sm

			pop r20
         	out SREG, temp        
         	pop temp
			ldi r18, 63			

			ret 



loop_li:	dec r20 
			ldi mot, 0b00000001 ; Motor-Schleife an PB2 und PB3, rückwärts
			eor mot, led 
			out DDRB, mot		; Lenker links = (PB0 = 1), enable aktiviert (PB1 = 0)
			rcall delay_sm

			ldi mot, 0b00000101
			eor mot, led 
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00001101
			eor mot, led 
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00001001
			eor mot, led 
			out DDRB, mot
			rcall delay_sm

			cpi r20, 0
			brne loop_li
			ldi r20, 15

loop_li2:	dec r20
			ldi mot, 0b00001000 ; Motor-Schleife an PB2 und PB3, vorwärts
			eor mot, led 
			out DDRB, mot		; Lenker rechts = (PB0 = 0), enable aktiviert (PB1 = 0)
			rcall delay_sm

			ldi mot, 0b00001100
			eor mot, led 
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00000100
			eor mot, led 
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00000000
			eor mot, led 
			out DDRB, mot
			rcall delay_sm
			
			cpi r20, 0
			brne loop_li2

			ret


loop_re:	dec r20 
			ldi mot, 0b00000000 ; Motor-Schleife an PB2 und PB3, rückwärts
			eor mot, led 
			out DDRB, mot		; Lenker rechts = (PB0 = 0), enable aktiviert (PB1 = 0)
			rcall delay_sm

			ldi mot, 0b00000100
			eor mot, led 
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00001100
			eor mot, led 
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00001000
			eor mot, led 
			out DDRB, mot
			rcall delay_sm

			cpi r20, 0	
			brne loop_re
			ldi r20, 15

loop_re2:	dec r20
			ldi mot, 0b00001001 ; Motor-Schleife an PB2 und PB3, vorwärts
			eor mot, led 
			out DDRB, mot		; Lenker links = (PB0 = 1), enable aktiviert (PB1 = 0)
			rcall delay_sm

			ldi mot, 0b00001101
			eor mot, led 
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00000101
			eor mot, led 
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00000001
			eor mot, led 
			out DDRB, mot
			rcall delay_sm
			
			cpi r20, 0	
			brne loop_re2
			
			ret


delay_sm:						; Zeitverzögerung
			push mot
			push r18
			push r19

			ldi  mot, 1	
WGLOOP0:   	ldi  r18, 63
WGLOOP1:   	ldi  r19, 255
WGLOOP2:   	dec  r19
           	brne WGLOOP2
           	dec  r18
           	brne WGLOOP1
			dec  mot
			brne WGLOOP0

			pop mot
			pop r18
			pop r19   

			ret



delay_s2:						; Zeitverzögerung mit Beschleunigung
			push mot
			push r19
			mov mot, r18   	
WLOOP1:   	ldi  r19, 255
WLOOP2:   	dec  r19
			cpi r19, 0
           	brne WLOOP2
           	dec  mot
			cpi mot, 0
           	brne WLOOP1

			pop mot
			pop r19   
			ret



