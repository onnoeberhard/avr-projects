.include"m8def.inc"

	ldi r16, $FF
	out DDRB, r16

	ldi r16, $00
	out DDRD, r16
	ldi r17, $00

loop:
	in r16, PIND	
	add r17, r16	
	out PORTB, r17
	rjmp loop
	
		
	
