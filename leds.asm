.include "m8def.inc"         ; Definitionsdatei für den Prozessortyp einbinden
 
         ldi r16, 0xFF       ; lade Arbeitsregister r16 mit der Konstanten 0xFF
         out DDRB, r16       ; Inhalt von r16 ins IO-Register DDRB ausgeben
 
         ldi r16, 0b11111100 ; 0b11111100 in r16 laden
         out PORTB, r16      ; r16 ins IO-Register PORTB ausgeben
 
ende:    rjmp ende           ; Sprung zur Marke "ende" -> Endlosschleife 
