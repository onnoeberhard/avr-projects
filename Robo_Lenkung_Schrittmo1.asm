;pin B0 = Lenkspule
;pin B1 = enable, negative Logik
;pin B2 = Schrittmotor1_spule1
;pin B3 = Schrittmotor1_spule2
;pin D2 = Taster 1 (Interrupt-Handler 0) = Lenkung nach links
;pin D3 = Taster 2 (Interrupt-Handler 1) = Lenkung nach rechts



.include "m8def.inc"
 
.def temp = r16
.def mot = r17
 
.org 0x000
         rjmp main            ; Reset Handler
.org INT0addr
         rjmp int0_handler    ; IRQ0 Handler
.org INT1addr
         rjmp int1_handler    ; IRQ1 Handler
 
 
main:                         ; hier beginnt das Hauptprogramm
 
         ldi temp, LOW(RAMEND)
         out SPL, temp
         ldi temp, HIGH(RAMEND)
         out SPH, temp
 
         ldi temp, 0x00
         out DDRD, temp			; Port D = Eingang
 
         ldi temp, 0xFF
         out DDRB, temp			; Port B = Ausgang
 
         ldi temp, 0b00001010  	; INT0 und INT1 konfigurieren
         out MCUCR, temp
 
         ldi temp, 0b11000000  	; INT0 und INT1 aktivieren
         out GICR, temp
 
         sei                   	; Interrupts allgemein aktivieren
 



loop:		ldi mot, 0b00001010 ; Motor-Schleife an PB2 und PB3,
			out DDRB, mot		; Lenker geradeaus = enable deaktiviert (PB1 = 1)

			rcall delay_sm

			ldi mot, 0b00001110
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00000110
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00000010
			out DDRB, mot
			rcall delay_sm

			rjmp loop            



 
int0_handler:
         push temp             	; Das SREG in temp sichern. Vorher
         in   temp, SREG       	; muss nat�rlich temp gesichert werden
 
		
         
			push r20
			ldi r20, 15			; Zeit, die der Lenker eingeschlagen ist

loop_li:	dec r20 
			ldi mot, 0b00000001 ; Motor-Schleife an PB2 und PB3, r�ckw�rts
			out DDRB, mot		; Lenker links = (PB0 = 1), enable aktiviert (PB1 = 0)
			rcall delay_sm

			ldi mot, 0b00000101
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00001101
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00001001
			out DDRB, mot
			rcall delay_sm

			cpi r20, 0
			brne loop_li
			ldi r20, 15

loop_li2:	dec r20
			ldi mot, 0b00001000 ; Motor-Schleife an PB2 und PB3, vorw�rts
			out DDRB, mot		; Lenker rechts = (PB0 = 0), enable aktiviert (PB1 = 0)

			rcall delay_sm

			ldi mot, 0b00001100
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00000100
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00000000
			out DDRB, mot
			rcall delay_sm
			
			cpi r20, 0
			brne loop_li2
			
			pop r20
			
									
			ldi mot,0b00000010	; Lenker geradeaus, enable deaktiviert (PB1 = 1)	
			out DDRB, mot 

  			 

         out SREG, temp        ; Die Register SREG und temp wieder
         pop temp              ; herstellen
		 reti




 
int1_handler:
         push temp             
         in   temp, SREG       

 
        
			push r20
			ldi r20, 15			; Zeit, die der Lenker eingeschlagen ist

loop_re:	dec r20 
			ldi mot, 0b00000000 ; Motor-Schleife an PB2 und PB3, r�ckw�rts
			out DDRB, mot		; Lenker rechts = (PB0 = 0), enable aktiviert (PB1 = 0)

			rcall delay_sm

			ldi mot, 0b00000100
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00001100
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00001000
			out DDRB, mot
			rcall delay_sm

			cpi r20, 0	
			brne loop_re
			ldi r20, 15

loop_re2:	dec r20
			ldi mot, 0b00001001 ; Motor-Schleife an PB2 und PB3, vorw�rts
			out DDRB, mot		; Lenker links = (PB0 = 1), enable aktiviert (PB1 = 0)
			rcall delay_sm

			ldi mot, 0b00001101
			out DDRB, mot
			rcall delay_sm

			ldi mot, 0b00000101
			out DDRB, mot
			rcall delay_sm
			
			ldi mot, 0b00000001
			out DDRB, mot
			rcall delay_sm
			
			cpi r20, 0	
			brne loop_re2
			
			pop r20

			ldi mot,0b00000010	; Lenker geradeaus, enable deaktiviert (PB1 = 1)	
			out DDRB, mot 
 
         out SREG, temp        
         pop temp              
		 reti



delay_sm:						; Zeitverz�gerung
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

