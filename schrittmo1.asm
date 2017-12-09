.include "m8def.inc"
.def temp1 = r17

   			ldi temp1, LOW(RAMEND)		; Stack-Pointer initialisieren
			out SPL, temp1
			ldi temp1, HIGH(RAMEND)
			out SPH, temp1

			ldi r16, $FF
			out DDRB, r16
;			ldi r16, $00
;			out DDRD, r16
			


loop:		ldi r16, 0b00001001		; 4+1
			out PORTB, r16
			rcall Pause

			ldi r16, 0b00000101		; 3+1
			out PORTB, r16
			rcall Pause

			ldi r16, 0b00000110		; 3+2
			out PORTB, r16
			rcall Pause

			ldi r16, 0b00001010		; 4+2
			out PORTB, r16
			rcall Pause

;			sbis PIND, 0
;			rjmp pushed 
			
;			ldi  temp, $4
;			rcall Pause
			rjmp loop

Pause:
			ldi  temp1, 1
WGLOOP0:   	ldi  r18, 8
WGLOOP1:   	ldi  r19, 255
WGLOOP2:   	dec  r19
           	brne WGLOOP2
           	dec  r18
           	brne WGLOOP1
			dec  temp1
			brne WGLOOP0
			ret


