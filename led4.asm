.include "m8def.inc"

			ldi r16, $FF
			out DDRB, r16

			ldi r16, 0b00000001
			ldi r20, 0b00000010

loop:
			
			mov r21, r16
			out PORTB, r21
			
			; Pause
           	ldi  r17, $FF
WGLOOP0:   	ldi  r18, $FF
WGLOOP1:   	dec  r18
           	brne WGLOOP1
           	dec  r17
           	brne WGLOOP0

			cpi r16, 0b00100000
			brsh loop2
               
			mul r16, r20
			mov r16, r0

			rjmp loop

loop2:		ldi r16, 0b00000001
			rjmp loop
