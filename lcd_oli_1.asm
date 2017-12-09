;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCD mit 4bit-Interface                      ;;
;; DB4-DB7:       PD0-PD3                      ;;
;; RS:            PD4                          ;;
;; E:             PD5                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "m8def.inc"

.def temp1 = r16
.def temp2 = r17
.def temp3 = r18
 

	ldi temp1, LOW(RAMEND)		; Stack-Pointer initialisieren
	out SPL, temp1
	ldi temp1, HIGH(RAMEND)
	out SPH, temp1

	ldi temp1, 0xFF				; Port D = Ausgang
	out DDRD, temp1

	rcall lcd_init
	rcall lcd_clear

loop:
	ldi temp1, 'O'				; Zeichen anzeigen
	rcall lcd_data
	rcall delay_long
	
	ldi temp1, 'n'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 'n'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 'o'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 0b10100101
	rcall lcd_data
	rcall delay_long

	ldi temp1, 'i'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 's'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 't'
	rcall lcd_data
	rcall delay_long
	
	rcall lcd_DDhigh

	ldi temp1, 0b10100101
	rcall lcd_data
	rcall delay_long
	
	ldi temp1, 'l'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 'i'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 'e'
	rcall lcd_data
	rcall delay_long
	
	ldi temp1, 'b'
	rcall lcd_data
	rcall delay_long

	ldi temp1, 0b00100001
	rcall lcd_data
	rcall delay_long

	rcall lcd_home
	rcall lcd_clear	
	rcall delay_long

	rjmp loop




lcd_init:						; Initialisierung: muss ganz am Anfang des Programms aufgerufen werden 
	   	   push temp1
	  	   push temp2
	  	   push temp3

	   	   ldi   temp3,50			
powerupwait:
           rcall delay5ms
           dec   temp3
           brne  powerupwait
           ldi   temp1,    0b00000011   ; muss 3mal hintereinander gesendet
           out   PORTD, temp1        	; werden zur Initialisierung
           rcall lcd_enable             ; 1
           rcall delay5ms
           rcall lcd_enable             ; 2
           rcall delay5ms
           rcall lcd_enable             ; und 3!
           rcall delay5ms
           ldi   temp1,    0b00000010   ; 4bit-Modus einstellen
           out   PORTD, temp1
           rcall lcd_enable
           rcall delay5ms
           ldi   temp1,    0b00101000   ; 4 Bit, 2 Zeilen, 5x8 dots
           rcall lcd_command
           ldi   temp1,    0b00001100   ; Display on, Cursor off
           rcall lcd_command
           ldi   temp1,    0b00000100   ; inkrement, kein Scrollen
           rcall lcd_command

		   pop temp3
		   pop temp2
		   pop temp1
		   ret
 

lcd_data:								 ;sendet ein Datenbyte an das LCD
           push temp1
		   push temp2

		   mov   temp2, temp1            ; "Sicherungskopie" für
                                         ; die Übertragung des 2.Nibbles
           swap  temp1                   ; Vertauschen
           andi  temp1, 0b00001111       ; oberes Nibble auf Null setzen
           sbr   temp1, 1<<4	         ; entspricht 0b00010000
           out   PORTD, temp1        	 ; ausgeben
           rcall lcd_enable              ; Enable-Routine aufrufen
                                         ; 2. Nibble, kein swap da es schon
                                         ; an der richtigen stelle ist
           andi  temp2, 0b00001111       ; obere Hälfte auf Null setzen 
           sbr   temp2, 1<<4	         ; entspricht 0b00010000
           out   PORTD, temp2         	 ; ausgeben
           rcall lcd_enable              ; Enable-Routine aufrufen
           rcall delay50us               ; Delay-Routine aufrufen

		   pop temp2
		   pop temp1
		   ret                           

 

lcd_command:                             ; sendet einen Befehl an das LCD, wie lcd_data, nur ohne RS zu setzen
           push temp1
		   push temp2

		   mov   temp2, temp1
           swap  temp1
           andi  temp1, 0b00001111
	   	   out 	 PORTD, temp1
           rcall lcd_enable
           andi  temp2, 0b00001111
           out   PORTD, temp2
           rcall lcd_enable
           rcall delay50us

		   pop temp2
		   pop temp1
           ret
 

lcd_enable:							; erzeugt den Enable-Puls
           sbi PORTD, 5	          	; Enable high
           nop                      ; 3 Taktzyklen warten
           nop
           nop
           cbi PORTD, 5		        ; Enable wieder low
           ret                                               
 
lcd_DDhigh:
		   push temp1
		   ldi temp1, 0b11000000	;Cursor-Position auf Zeile 2, Spalte 0
		   rcall lcd_command
		   rcall delay5ms
		   pop temp1
		   ret

 
delay50us:                          	; 50us Pause nach jeder Übertragung
           push temp1

		   ldi  temp1, $42
delay50us_:
           dec  temp1
           brne delay50us_

		   pop temp1
           ret                         


delay5ms:                         	    ; 5ms Pause, längere Pause für manche Befehle
           push temp1
		   push temp2

		   ldi  temp1, $21
WGLOOP0:   ldi  temp2, $C9
WGLOOP1:   dec  temp2
           brne WGLOOP1
           dec  temp1
           brne WGLOOP0
           
		   pop temp2
		   pop temp1
		   ret
		   
		   
delay_long:								; längere Pause (bestimmen über temp1)
			push temp1
			push temp2
			push temp3

			ldi  temp1, $8				
WGLOOP2:   	ldi  temp2, $FF
WGLOOP3:   	ldi  temp3, $FF
WGLOOP4:   	dec  temp3
           	brne WGLOOP4
           	dec  temp2
           	brne WGLOOP3
			dec  temp1
			brne WGLOOP2

			pop temp3
			pop temp2
			pop temp1
			ret                         
 
lcd_clear:								; Sendet den Befehl zur Löschung des Displays
           push  temp1
           
		   ldi   temp1,    0b00000001   ; Display löschen
           rcall lcd_command
           rcall delay5ms
           
		   pop   temp1
           ret

lcd_home:								; Cursor Home
           push temp1

		   ldi   temp1,    0b00000010   ; entspricht Cursor home
           rcall lcd_command
           rcall delay5ms
           
		   pop temp1
		   ret



