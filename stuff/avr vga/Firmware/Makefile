PROJECT = VgaGen
DEVICE  = atmega88
F_CPU   = 20000000 # in Hz
AVRDUDE = avrdude -c pony-stk200 -P lpt1 -p $(DEVICE) -E noreset

AVRASM = C:\Programme\AVRStudio\AvrAssembler2\avrasm2 -D F_CPU=$(F_CPU) -fI

# ATmega88 LFuse:
# 0xF6 = 1 1 1 1  0 1 1 0
#	 ^ ^ \+/  \--+--/
#	 | |  |      +----- CKSEL (clock selection -> full-swing XTAL)
#	 | |  +------------ SUT (start-up timer: slowest)
#	 | +--------------- CKOUT (NO)
#	 +----------------- CLKDIV8 (NO)

# ATmega88 HFuse:
# 0xDC = 1 1 0 1  1 1 0 0
#	 ^ ^ ^ ^  ^ \---/
#	 | | | |  |   +---- BODLEVEL (require 5V)
#	 | | | |  +-------- EESAVE (preserve EEPROM on Chip Erase -> NO)
#	 | | | +----------- WDTON (watchdog timer always on -> NO)
#	 | | +------------- SPIEN (enable serial programming -> YES)
#	 | +--------------- DWEN (Debug Wire Enable -> NO)
#        +----------------- RSTDISBL (disable external reset -> NO)

# ATmega88 EFuse:
# 0xF9 = 1 1 1 1  1 0 0 1
#	 \--------/ \-/ |
#	     |       |  +-- BOOTRST (boot reset address: 0)
#	     |       +----- BOOTSZ (boot size: doesn't matter)
#	     +------------- unused

LFUSE = 0xF6
HFUSE = 0xDC
EFUSE = 0x01

all: $(PROJECT).hex

fuse:
	$(AVRDUDE) -U efuse:w:$(EFUSE):m -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

flash: $(PROJECT).hex
	$(AVRDUDE) -U flash:w:$<:i

prog:
	$(AVRDUDE) -U efuse:w:$(EFUSE):m -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m -U flash:w:$(PROJECT).hex:i

clean:
	rm -f $(PROJECT).hex $(PROJECT).lst Bild.i90

$(PROJECT).hex: $(PROJECT).a90 Bild.i90 Makefile
	$(AVRASM) $< -l $(PROJECT).lst

Bild.i90: Bild.bmp
	MakeBild < $< > $@
