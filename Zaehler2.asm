.include "m8def.inc"			; auf widerholten Tastendruck an D0 Ausgabe auf LED-Display an B von 1-9 (Z�hler)
 
.def key_old   = r3
.def key_now   = r4
 
.def temp1     = r17
.def temp2     = r18
 
.equ key_pin   = PIND
.equ key_port  = PORTD
.equ key_ddr   = DDRD
 
.equ led_port  = PORTB
.equ led_ddr   = DDRB
.equ LED       = 0
 
	ldi r16, LOW(RAMEND)		; Stack-Pointer initialisieren
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16 


      ldi  temp1, 1<<LED
      out  led_ddr, temp1         ; den Led Port auf Ausgang
 
      ldi  temp1, $00             ; den Key Port auf Eingang schalten
      out  key_ddr, temp1
      ldi  temp1, $FF             ; die Pullup Widerst�nde aktivieren
      out  key_port, temp1
 
      mov  key_old, temp1         ; bisher war kein Taster gedr�ckt

start:	
	  push r16
	  ldi r16, 0b00111111	;0
	  out led_ddr, r16
	  pop r16

	  rcall loop
	  
	  push r16
	  ldi r16, 0b00110000	;1
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01101101	;2
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01111001	;3
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01110010	;4
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01011011	;5
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01011111	;6
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b00110001	;7
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01111111	;8
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  push r16
	  ldi r16, 0b01111011	;9
	  out led_ddr, r16
	  pop r16

	  rcall loop

	  rjmp start
 
loop:
      in   key_now, key_pin       ; den jetzigen Zustand der Taster holen
      mov  temp1, key_now         ; und in temp1 sichern
      eor  key_now, key_old       ; mit dem vorhergehenden Zustand XOR
      mov  key_old, temp1         ; und den jetzigen Zustand für den nächsten
                                  ; Schleifendurchlauf als alten Zustand merken
 
      breq loop                   ; Das Ergebnis des XOR auswerten:
                                  ; wenn keine Taste gedrückt war -> neuer Schleifendurchlauf
 
      and  temp1, key_now         ; War das ein 1->0 Übergang, wurde der Taster also
                                  ; gedrückt (in key_now steht das Ergebnis vom XOR)
      brne loop                   ;
 
      ldi  temp1, $FF             ; ein bisschen warten ...
wait1:
      ldi  temp2, $FF
wait2:
      dec  temp2
      brne wait2
      dec  temp1
      brne wait1
                                  ; ... und nachsehen, ob die Taste immer noch gedrückt ist
      in   temp1, key_pin
      and  temp1, key_now
      brne loop
 	 
	  ret	
 	  
	  
      
 
 

