.include "m8def.inc"

.def temp = r16

         ldi temp, LOW(RAMEND)             ; LOW-Byte der obersten RAM-Adresse
         out SPL, temp
         ldi temp, HIGH(RAMEND)            ; HIGH-Byte der obersten RAM-Adresse
         out SPH, temp

         rcall sub1                        ; sub1 aufrufen

loop:    rjmp loop


sub1:
                                           ; hier k�nnten ein paar Befehle stehen
         rcall sub2                        ; sub2 aufrufen
                                           ; hier k�nnten auch Befehle stehen
         ret                               ; wieder zur�ck

sub2:
                                           ; hier stehen normalerweise die Befehle,
                                           ; die in sub2 ausgef�hrt werden sollen
         ret                               ; wieder zur�ck
