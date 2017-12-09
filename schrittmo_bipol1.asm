.include "m8def.inc"
.def temp1 = r17

   			ldi temp1, LOW(RAMEND)		; Stack-Pointer initialisieren
			out SPL, temp1
			ldi temp1, HIGH(RAMEND)
			out SPH, temp1

			
			ldi r16, 0x00
			out DDRB, r16
			
			ldi r16, 0b00000000
			out DDRB, r16
			rcall delay_sm

			ldi r16, 0b00001000
			out DDRB, r16
			rcall delay_sm

loop:		ldi r16, 0b00000011
			out DDRB, r16
			rcall delay_sm
			
			ldi r16, 0b00001001
			out DDRB, r16
			rcall delay_sm

			ldi r16, 0b00000000
			out DDRB, r16
			rcall delay_sm

			ldi r16, 0b00001010
			out DDRB, r16
			rcall delay_sm

			rjmp loop



			

delay_sm:
			ldi  temp1, 8
WGLOOP0:   	ldi  r18, 255
WGLOOP1:   	ldi  r19, 255
WGLOOP2:   	dec  r19
           	brne WGLOOP2
           	dec  r18
           	brne WGLOOP1
			dec  temp1
			brne WGLOOP0
			ret


