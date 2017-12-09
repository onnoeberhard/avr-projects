.include "m8def.inc"
 
         ldi r16, 0xFF
         out DDRD, r16       ; Port B ist Ausgang
                             
         ldi r16, 0x00
         out DDRB, r16       ; Port D ist Eingang
                             
 
         ldi r16, 0xFF
         out PORTD, r16      ; PORTB auf 0xFF setzen -> alle LEDs aus
 		 
loop:    sbic PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b11001111        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16

 		 sbi PINB, 0

loop2:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10010010        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop3:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop2           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10000110        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop4:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop3           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10001101        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop5:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop4           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10100100        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop6:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop5           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10100000        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop7:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop6           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b11001110        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop8:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop7           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10000000        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

loop9:   sbis PINB, 0        ; "skip if bit cleared", nächsten Befehl überspringen,
                             ; wenn Bit 0 im IO-Register PIND =0 (Taste 0 gedrückt)
         rjmp loop8           ; Sprung zu "loop:" -> Endlosschleife
 
         ldi r16, 0b10000100        ; Bit 3 im IO-Register PORTB auf 0 setzen -> 4. LED an
		 out PORTD, r16
		 sbi PINB, 0

ende:    rjmp ende           ; Endlosschleife 
