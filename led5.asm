.include "m8def.inc"

			ldi r16, 0xFF
			out DDRB, r16

			ldi r16, 0b00000001
loop:
			com r16
			out PORTB, r16

			; Pause
           	ldi  r17, $FF
WGLOOP0:   	ldi  r18, $FF
WGLOOP1:   	dec  r18
           	brne WGLOOP1
           	dec  r17
           	brne WGLOOP0

			com r16	
			cpi r16, 0b00000001
			brsh loop2
            
			ldi r16, 0b00000001
			;out PORTB, r16
			   
			rjmp loop

loop2:		ldi r16, 0x00
			;out PORTB, r16

			rjmp loop
