.include "m8def.inc"

.def og = r16
.def n  = r17
.def o  = r18
.def blank = r19

.def taus = r20
.def hund = r21
.def zehn = r22
.def eine = r23

.def zeit = r24

	ldi r16, LOW(RAMEND)		; Stack-Pointer initialisieren
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16

	ldi r16, $FF
	out DDRB, r16
	ldi r16, $FF
	out DDRD, r16

ldi og, 	0b01000000
ldi n, 		0b00101011
ldi o, 		0b00100011
ldi blank, 	0b11111111

ldi taus, 	0b11110111
ldi hund, 	0b11111011
ldi zehn, 	0b11111101
ldi eine, 	0b11111110

ldi zeit, 	255		
			

loop:
			out PORTD, og
			out PORTB, eine
			rcall pause
			out PORTD, blank
			out PORTB, zehn
			rcall pause
			out PORTD, blank
			out PORTB, hund
			rcall pause
			out PORTD, blank
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop
			
loop2:
			out PORTD, n
			out PORTB, eine
			rcall pause
			out PORTD, og
			out PORTB, zehn
			rcall pause
			out PORTD, blank
			out PORTB, hund
			rcall pause
			out PORTD, blank
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop2
			
loop3:
			out PORTD, n
			out PORTB, eine
			rcall pause
			out PORTD, n
			out PORTB, zehn
			rcall pause
			out PORTD, og
			out PORTB, hund
			rcall pause
			out PORTD, blank
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop3

loop4:
			out PORTD, o
			out PORTB, eine
			rcall pause
			out PORTD, n
			out PORTB, zehn
			rcall pause
			out PORTD, n
			out PORTB, hund
			rcall pause
			out PORTD, og
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop4
			

loop5:
			out PORTD, blank
			out PORTB, eine
			rcall pause
			out PORTD, blank
			out PORTB, zehn
			rcall pause
			out PORTD, blank
			out PORTB, hund
			rcall pause
			out PORTD, blank
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop5	

loop6:
			out PORTD, o
			out PORTB, eine
			rcall pause
			out PORTD, n
			out PORTB, zehn
			rcall pause
			out PORTD, n
			out PORTB, hund
			rcall pause
			out PORTD, og
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop6
			

loop7:
			out PORTD, blank
			out PORTB, eine
			rcall pause
			out PORTD, blank
			out PORTB, zehn
			rcall pause
			out PORTD, blank
			out PORTB, hund
			rcall pause
			out PORTD, blank
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop7	

loop8:
			out PORTD, o
			out PORTB, eine
			rcall pause
			out PORTD, n
			out PORTB, zehn
			rcall pause
			out PORTD, n
			out PORTB, hund
			rcall pause
			out PORTD, og
			out PORTB, taus
			rcall pause

			dec zeit
			brne loop8

rjmp loop			
			


pause:
			push r16
			push r17
			push r18
			
			ldi  r16, 1
WGLOOP1:   	ldi  r17, 1
WGLOOP2:   	ldi  r18, 96
WGLOOP3:   	dec  r18
           	brne WGLOOP3
           	dec  r17
           	brne WGLOOP2
			dec  r16
			brne WGLOOP1

			pop r18
			pop r17
			pop r16

			ret








