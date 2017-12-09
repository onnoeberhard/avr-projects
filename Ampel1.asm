.include "m8def.inc"
.def temp = r17

			ldi r16, $FF
			out DDRB, r16
			ldi r16, $00
			out DDRD, r16

			;rot
loop:		ldi r16, 0b11110111
			out PORTB, r16

			sbis PIND, 0
			rjmp pushed 
			
			ldi  temp, $4
			rcall Pause
			rjmp loop

Pause:
WGLOOP0:   	ldi  r18, $FF
WGLOOP1:   	ldi  r19, $FF
WGLOOP2:   	dec  r19
           	brne WGLOOP2
           	dec  r18
           	brne WGLOOP1
			dec  temp
			brne WGLOOP0
			ret

			;gelb
pushed:		ldi r16, 0b11110011
			out PORTB, r16
			ldi temp, $3
			rcall Pause
			
			;grün + Blinklicht für Autos
			ldi r18, 8
WGLOOP3:	ldi r16, 0b11111100
			out PORTB, r16
			ldi temp, $1
			rcall Pause
			ldi r16, 0b11111101
			out PORTB, r16
			ldi temp, $1
			rcall Pause
			dec r18
			brne WGLOOP3
			rjmp loop

			
