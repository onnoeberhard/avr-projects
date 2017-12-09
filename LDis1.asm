.include "m8def.inc"
.def temp = r17

			ldi r16, $FF
			out DDRB, r16
			ldi r16, $FF
			out DDRD, r16

			;___O
loop:		ldi r16, 0b01000000
			out PORTD, r16
			ldi r16, 0b11111110
			out PORTB, r16
			rcall Pause
			
			;__O
loop2:		ldi r16, 0b01000000
			out PORTD, r16
			ldi r16, 0b11111101
			out PORTB, r16
			rcall Pause1

			;_O
loop3:		ldi r16, 0b01000000
			out PORTD, r16
			ldi r16, 0b11111011
			out PORTB, r16
			rcall Pause2

			;O
loop4:		ldi r16, 0b01000000
			out PORTD, r16
			ldi r16, 0b11110111
			out PORTB, r16
			rcall Pause3

			;___n
loop5:		ldi r16, 0b00101011
			out PORTD, r16
			ldi r16, 0b11111110
			out PORTB, r16
			rcall Pause4
			
			;__n
loop6:		ldi r16, 0b00101011
			out PORTD, r16
			ldi r16, 0b11111101
			out PORTB, r16
			rcall Pause5
		
			;_n
loop7:		ldi r16, 0b00101011
			out PORTD, r16
			ldi r16, 0b11111011
			out PORTB, r16
			rcall Pause6

			;___n
loop8:		ldi r16, 0b00101011
			out PORTD, r16
			ldi r16, 0b11111110
			out PORTB, r16
			rcall Pause7

			;__n
loop9:		ldi r16, 0b00101011
			out PORTD, r16
			ldi r16, 0b11111101
			out PORTB, r16
			rcall Pause8

			;___o
loop10:		ldi r16, 0b00100011
			out PORTD, r16
			ldi r16, 0b11111110
			out PORTB, r16
			rcall Pause9

Pause:
WGLOOP0:   	ldi  r18, 100
WGLOOP1:   	ldi  r19, 10
WGLOOP2:   	dec  r19
           	brne WGLOOP2
           	dec  r18
           	brne WGLOOP1
			dec  temp
			brne WGLOOP0
			rjmp loop2
Pause1:
WGLOOP3:   	ldi  r18, 100
WGLOOP4:   	ldi  r19, 10
WGLOOP5:   	dec  r19
           	brne WGLOOP5
           	dec  r18
           	brne WGLOOP4
			dec  temp
			brne WGLOOP3
			rjmp loop3

Pause2:
WGLOOP6:   	ldi  r18, 100
WGLOOP7:   	ldi  r19, 10
WGLOOP8:   	dec  r19
           	brne WGLOOP8
           	dec  r18
           	brne WGLOOP7
			dec  temp
			brne WGLOOP6
			rjmp loop4

Pause3:
WGLOOP9:   	ldi  r18, 1
WGLOOP10:  	ldi  r19, 1
WGLOOP11:  	dec  r19
           	brne WGLOOP11
           	dec  r18
           	brne WGLOOP10
			dec  temp
			brne WGLOOP9
			rjmp loop5

Pause4:
WGLOOP12:   ldi  r18, 1
WGLOOP13:  	ldi  r19, 1
WGLOOP14:  	dec  r19
           	brne WGLOOP14
           	dec  r18
           	brne WGLOOP13
			dec  temp
			brne WGLOOP12
			rjmp loop4

Pause5:
WGLOOP15:   ldi  r18, 100
WGLOOP16:  	ldi  r19, 10
WGLOOP17:  	dec  r19
           	brne WGLOOP17
           	dec  r18
           	brne WGLOOP16
			dec  temp
			brne WGLOOP15
			rjmp loop7

Pause6:
WGLOOP18:   ldi  r18, 100
WGLOOP19:  	ldi  r19, 10
WGLOOP20:  	dec  r19
           	brne WGLOOP20
           	dec  r18
           	brne WGLOOP19
			dec  temp
			brne WGLOOP18
			rjmp loop8
Pause7:
WGLOOP21:   ldi  r18, 100
WGLOOP22:  	ldi  r19, 10
WGLOOP23:  	dec  r19
           	brne WGLOOP23
           	dec  r18
           	brne WGLOOP22
			dec  temp
			brne WGLOOP21
			rjmp loop9
Pause8:
WGLOOP24:   ldi  r18, 100
WGLOOP25:  	ldi  r19, 10
WGLOOP26:  	dec  r19
           	brne WGLOOP26
           	dec  r18
           	brne WGLOOP25
			dec  temp
			brne WGLOOP24
			rjmp loop10
Pause9:
WGLOOP27:   ldi  r18, 100
WGLOOP28:  	ldi  r19, 10
WGLOOP29:  	dec  r19
           	brne WGLOOP29
           	dec  r18
           	brne WGLOOP28
			dec  temp
			brne WGLOOP27
			rjmp loop
