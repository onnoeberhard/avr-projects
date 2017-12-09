.include "m8def.inc"
 
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
 
 
      ;ldi  temp1, 1<<LED
	  ldi temp1, 0b11111111
	  out  led_ddr, temp1       ; den Led Port auf Ausgang
 
      ldi  temp1, 0x00       	; den Key Port auf Eingang schalten
      out  key_ddr, temp1
      
      mov  key_old, temp1         ; bisher war kein Taster gedrückt
 
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
 
      in   temp1, key_pin       ; den Zustand der Taster ausgeben
      
      out  led_port, temp1
 
 
      rjmp  loop


 
ende:    rjmp ende           ; Sprung zur Marke "ende" -> Endlosschleife 
