.include "m8def.inc"

.def temp = r16


         ldi r16, 0xFF	   					; Port B = Ausgang
         out DDRB, r16     					; Port B = Ausgang

         ldi r16, 0x00	   					; Port C = Eingang
         out DDRC, r16     					; Port C = Eingang
		 
		 ldi temp, HIGH(RAMEND)             ; HIGH-Byte der obersten RAM-Adresse
         out SPH, temp						; Stack Pointer
         ldi temp, LOW(RAMEND)              ; LOW-Byte der obersten RAM-Adresse
         out SPL, temp						; Stack Pointer

		 ldi r16, 0xFF     					; An allen Pins vom Port C die Pullup-Widerstände
         out PORTC, r16	   					; An allen Pins vom Port C die Pullup-Widerstände

         ldi r16, 0xFF	   					; PORTB auf 0xFF setzen -> alle LEDs aus
         out PORTB, r16    					; PORTB auf 0xFF setzen -> alle LEDs aus

main:
	rcall steuerung
	rcall aus	

steuerung:
	rcall lenkrad
	rcall rechts
	rcall rechts2
	rcall links
	rcall links2
	rcall pedal
	rcall pedal1
	rcall pedal2
	ret

pedal:
	pedal1:
	sbic PINC, 0
	ret
	rcall vr
	cbi PORTB, 0
	rcall steuerung
	vr:
	sbic PINC, 1
	ret
	cbi PORTB, 1
	sbi PORTB, 0
	pedal2:	
	sbis PINC, 0
	rcall steuerung
	sbi PORTB, 0
	sbi PORTB, 1
	rcall steuerung

lenkrad:
		tasten:
		rechts:
		sbic PINC, 2
		ret
    	cbi PORTB, 2
		ret
		rechts2:
		sbis PINC, 2
		ret
		sbi PORTB, 2
		ret
		links:
		sbic PINC, 3
		ret
    	cbi PORTB, 3
		ret
		links2:
		sbis PINC, 3
		ret
		sbi PORTB, 3
		ret

aus:
sbic PINC, 0
ret
ende:
ldi r16, 0xFF	   					; PORTB auf 0xFF setzen -> alle LEDs aus
out PORTB, r16    					; PORTB auf 0xFF setzen -> alle LEDs aus
rjmp ende
