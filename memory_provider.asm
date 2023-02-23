; PIC18F47Q43

; ports (EMUZ80)
; RD0-RD7 : A8-A15
; RB0-RB7 : A0-A7
; RC0-RC7 : D0-D7
; RA0     : IOREQ
; RA1     : MREQ
; RA2     : RFSH
; RA3     : CLK
; RA4     : WAIT
; RA5     : RD
; RE0     : WR
; RE1     : RESET
; RE2     : INT
; RA6     : TXD (UART)
; RA7     : RXD (UART)

	; gpasm doesn't seem supporting PIC18F47Q43 :(
	; selecting some similar device
	LIST P=PIC18F46Q10

; device configurations

	; use 64MHz internal oscillator, external oscillator not enabled
	__CONFIG 0x300000, 0x8C
	; no Fail-Safe Clock Monitor, no clock switch 
	__CONFIG 0x300001, 0xD7
	; Brown-out Reset Enable, use interrupt vector, Power-up Timer 1ms, use MCLR
	__CONFIG 0x300002, 0xF9
	; no Extended Instruction Set, use LVP, Brown-out Reset 2.85V (max)
	__CONFIG 0x300003, 0xFC
	; no WDT
	__CONFIG 0x300004, 0x9F
	; WDT setting (don't care because WDT is not used)
	__CONFIG 0x300005, 0xFF
	; no debug, no Storage Area Flash, no Boot Block
	__CONFIG 0x300006, 0xFF
	; no write protection
	__CONFIG 0x300007, 0xFF
	; reserved
	__CONFIG 0x300008, 0xFF
	; no code protection
	__CONFIG 0x300009, 0xFF

; register definitions

CLC2IF EQU 1
CLC3IF EQU 5
CLC5IF EQU 1
CLC6IF EQU 1
CLC2IE EQU 1
CLC3IE EQU 5
CLC5IE EQU 1
CLC6IE EQU 1
GIE EQU 7

PRLOCK EQU 0xB4
DMA1PR EQU 0xB6

CLCSELECT EQU 0xD5
CLCnCON EQU 0xD6
CLCnPOL EQU 0xD7
CLCnSEL0 EQU 0xD8
CLCnSEL1 EQU 0xD9
CLCnSEL2 EQU 0xDA
CLCnSEL3 EQU 0xDB
CLCnGLS0 EQU 0xDC
CLCnGLS1 EQU 0xDD
CLCnGLS2 EQU 0xDE
CLCnGLS3 EQU 0xDF

DMASELECT EQU 0xE8
DMAnDCNT EQU 0xEA
DMAnDSZ EQU 0xEE
DMAnDSA EQU 0xF0
DMAnSCNT EQU 0xF2
DMAnSSZ EQU 0xF7
DMAnSSA EQU 0xF9
DMAnCON0 EQU 0xFC
DMAnSIRQ EQU 0xFF

PPSLOCK EQU 0x0200
RA3PPS EQU 0x0204
RA4PPS EQU 0x0205
RA6PPS EQU 0x0207
CLCIN0PPS EQU 0x0261
CLCIN1PPS EQU 0x0262
CLCIN2PPS EQU 0x0263
CLCIN3PPS EQU 0x0264
CLCIN4PPS EQU 0x0265
CLCIN6PPS EQU 0x0267
CLCIN7PPS EQU 0x0268
U3RXPPS EQU 0x0276

U2TXB EQU 0x02B6
U2CON0 EQU 0x02BE
U2CON1 EQU 0x02BF

U3RXB EQU 0x02C7
U3TXB EQU 0x02C9
U3CON0 EQU 0x02D1
U3CON1 EQU 0x02D2
U3CON2 EQU 0x02D3
U3BRG EQU 0x02D4

ANSELA EQU 0x0400
WPUA EQU 0x0401
SLRCONA EQU 0x0403
INLVLA EQU 0x0404
ANSELB EQU 0x0408
WPUB EQU 0x0409
SLRCONB EQU 0x040B
INLVLB EQU 0x040C
ANSELC EQU 0x0410
WPUC EQU 0x0411
SLRCONC EQU 0x0413
INLVLC EQU 0x0414
ANSELD EQU 0x0418
WPUD EQU 0x0419
SLRCOND EQU 0x041B
INLVLD EQU 0x041C
ANSELE EQU 0x0420
WPUE EQU 0x0421
SLRCONE EQU 0x0423
INLVLE EQU 0x0424

NCO1INC EQU 0x0443

IVTLOCK EQU 0x0459
INTBASEL EQU 0x045D
INTBASEH EQU 0x045E
INTBASEU EQU 0x045F

PIE6 EQU 0x04A4
PIE7 EQU 0x04A5
PIE10 EQU 0x04A8
PIE11 EQU 0x04A9
PIR6 EQU 0x04B4
PIR7 EQU 0x04B5
PIR9 EQU 0x04B7
PIR10 EQU 0x04B8
PIR11 EQU 0x04B9

LATA EQU 0x04BE
LATC EQU 0x04C0
LATE EQU 0x04C2
TRISA EQU 0x04C6
TRISB EQU 0x04C7
TRISC EQU 0x04C8
TRISE EQU 0x04CA
PORTA EQU 0x04CE
PORTB EQU 0x04CF
PORTC EQU 0x04D0
PORTD EQU 0x04D1
PORTE EQU 0x04D2

INTCON0 EQU 0x04D6

FSR0 EQU 0x04E9
POSTINC0 EQU 0x04EE
INDF0 EQU 0x04EF
TABLAT EQU 0x04F5
TBLPTR EQU 0x04F6

; program code

	ORG 0

	; port settings
	MOVLB 4
	; RA3 (CLK), RA4 (WAIT), RA6 (TXD) : out / the other RAx : in
	MOVLW B'10100111'
	MOVWF TRISA
	; RB0-RB7 (A0-A7) : in (default)
	; RC0-RC7 (D0-D7) ; in (default)
	; RD0-RD7 (A8-A15) : in (default)
	; RE1(RESET), RE2(INT) : out / the other REx : in
	MOVLW B'11111001'
	MOVWF TRISE
	; no analog
	CLRF ANSELA
	CLRF ANSELB
	CLRF ANSELC
	CLRF ANSELD
	CLRF ANSELE
	; enable weak pull-up for inputs except for RA7 (RXD: external pull-up exists)
	MOVLW B'01111111'
	MOVWF WPUA
	MOVLW B'11111111'
	MOVWF WPUB
	MOVWF WPUC
	MOVWF WPUD
	MOVWF WPUE
	; use TTL input
	CLRF INLVLA
	CLRF INLVLB
	CLRF INLVLC
	CLRF INLVLD
	CLRF INLVLE
	; no Slew Rate Control
	CLRF SLRCONA
	CLRF SLRCONB
	CLRF SLRCONC
	CLRF SLRCOND
	CLRF SLRCONE

	; for peripheral pin settings
	MOVLB 2
	; give control of RA3 (CLK) to LATA
	CLRF RA3PPS

	; Z80 reset
	; RESET = 0
	BCF LATE, 1, A
	; give 3 clocks
	MOVLW B'00000011'
	BCF LATA, 3, A
Z80_RESET_LOOP1
	ADDLW B'01000000'
	BNC Z80_RESET_LOOP1
	BSF LATA, 3, A
Z80_RESET_LOOP2
	ADDLW B'01000000'
	BNC Z80_RESET_LOOP2
	BCF LATA, 3, A
	ADDLW -1
	BNZ Z80_RESET_LOOP1

	; peripheral pin settings
	; CLCx Input 1 = RA0 (IOREQ)
	MOVLW B'00000000'
	MOVWF CLCIN0PPS
	; CLCx Input 2 = RA1 (MREQ)
	MOVLW B'00000001'
	MOVWF CLCIN1PPS
	; CLCx Input 3 = RD7 (A15)
	MOVLW B'00011111'
	MOVWF CLCIN2PPS
	; CLCx Input 4 = RD6 (A14)
	MOVLW B'00011110'
	MOVWF CLCIN3PPS
	; CLCx Input 5 = RA2 (RFSH)
	MOVLW B'00000010'
	MOVWF CLCIN4PPS
	; CLCx Input 7 = RD5 (A13)
	MOVLW B'00011101'
	MOVWF CLCIN6PPS
	; CLCx Input 8 = RD4 (A12)
	MOVLW B'00011100'
	MOVWF CLCIN7PPS
	; UART3 Receive = RA7 (RXD)
	MOVLW B'00000111'
	MOVWF U3RXPPS
	; NCO1 = RA3 (CLK)
	MOVLW 0x3F
	MOVWF RA3PPS
	; UART3 TX = RA6 (TXD)
	MOVLW 0x26
	MOVWF RA6PPS
	; CLC1OUT = RA4 (WAIT)
	MOVLW 0x01
	MOVWF RA4PPS
	; lock settings
	MOVLW 0x55
	MOVWF PPSLOCK
	MOVLW 0xAA
	MOVWF PPSLOCK
	BSF PPSLOCK, 0

	; configure UART
	; 9600bps with 64MHz clock : U3BRG = 415.67
	MOVLW 0xA0
	MOVWF U3BRG
	MOVLW 0x01
	MOVWF U3BRG + 1
	; don't stop on RX overflow
	BSF U3CON2, 7
	; enable TX, enable RX, Asynchronous 8-bit, no pality
	MOVLW B'00110000'
	MOVWF U3CON0
	; enable serial port
	BSF U3CON1, 7

	; UART2: use as CLC1 reset signal
	; high speed, enable TX, Asynchronous 7-bit
	MOVLW B'10100001'
	MOVWF U2CON0
	; enable serial port
	BSF U2CON1, 7

	; configure CLC
	; reminder : IN0 = IOREQ, IN1 = MREQ, IN4 = RFSH
	; reminder : IN2 = A15, IN3 = A14, IN6 = A13, IN7 = A12
	; reminder : OR + select negated input + reverse output polarity = AND
	MOVLB 0
	; CLC1 : switch to LOW when one of detection signals becomes HIGH
	CLRF CLCSELECT
	; Data 1 = CLC8
	MOVLW D'58'
	MOVWF CLCnSEL0
	; Data 2 = U2TX
	MOVLW D'60'
	MOVWF CLCnSEL1
	; Data 3 = Data 4 = CRC3 (0)
	MOVLW D'54'
	MOVWF CLCnSEL2
	MOVWF CLCnSEL3
	; Gate 1 (CLK) = Data 1
	MOVLW  B'00000010'
	MOVWF CLCnGLS0
	; Gate 2 (D) = const 1
	CLRF CLCnGLS1
	; Gate 3 (RESET) = ~Data 2
	MOVLW  B'00000100'
	MOVWF CLCnGLS2
	; Gate 4 (SET) = const 0
	CLRF CLCnGLS3
	; invert output
	MOVLW B'10000010'
	MOVWF CLCnPOL
	; enable, no interrupts, 1-input D-FF
	MOVLW B'10000100'
	MOVWF CLCnCON
	; CLC2 : detect ROM access (RFSH = 1, MREQ = 0, A15 = 0)
	INCF CLCSELECT, F
	; Data 1 = IN4 (RFSH)
	MOVLW D'4'
	MOVWF CLCnSEL0
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1
	; Data 3 = IN2 (A15)
	MOVLW D'2'
	MOVWF CLCnSEL2
	; Data 4 = CLC4 (0)
	MOVLW D'54'
	MOVWF CLCnSEL3
	; Gate 1 = Data 1 & ~Data 2 & ~Data 3
	MOVLW B'00101001'
	MOVWF CLCnGLS0
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON
	; CLC3 : detect RAM access (RFSH = 1, MREQ = 0, CRC7 = 1)
	INCF CLCSELECT, F
	; Data 1 = IN4 (RFSH)
	MOVLW D'4'
	MOVWF CLCnSEL0
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1
	; Data 3 = CLC7
	MOVLW D'57'
	MOVWF CLCnSEL2
	; Data 4 = CLC4 (0)
	MOVLW D'54'
	MOVWF CLCnSEL3
	; Gate 1 = Data 1 & ~Data 2 & Data 3
	MOVLW B'00011001'
	MOVWF CLCnGLS0
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON
	; CLC4 : don't use (interrupt flag is on the same register with UART3)
	INCF CLCSELECT, F
	; Data 1 = Data 2 = Data 3 = Data 4 = CLC4 (0)
	MOVLW D'54'
	MOVWF CLCnSEL0
	MOVWF CLCnSEL1
	MOVWF CLCnSEL2
	MOVWF CLCnSEL3
	; Gate 1 = Gate 2 = Gate 3 = Gate 4 = const 0
	CLRF CLCnGLS0
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; CLC5 : detect REGISTER access (RFSH = 1, MREQ = 0, A15 = 1, A14 = 1)
	INCF CLCSELECT, F
	; Data 1 = IN4 (RFSH)
	MOVLW D'4'
	MOVWF CLCnSEL0
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1
	; Data 3 = IN2 (A15)
	MOVLW D'2'
	MOVWF CLCnSEL2
	; Data 4 = IN3 (A14)
	MOVLW D'3'
	MOVWF CLCnSEL3
	; Gate 1 = Data 1 & ~Data 2 & Data 3 & Data 4
	MOVLW B'01011001'
	MOVWF CLCnGLS0
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON
	; CLC6 : detect I/O access (IOREQ = 0)
	INCF CLCSELECT, F
	; Data 1 = IN0 (IOREQ)
	CLRF CLCnSEL0
	; Data 2 = Data 3 = Data 4 = CLC4 (0)
	MOVLW D'54'
	MOVWF CLCnSEL1
	MOVWF CLCnSEL2
	MOVWF CLCnSEL3
	; Gate 1 = ~Data 1
	MOVLW B'00000010'
	MOVWF CLCnGLS0
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON
	; CLC7 : helper for detect RAM access (A15 = 1, A14 = 0, A13 = 0, A12 = 0)
	INCF CLCSELECT, F
	; Data 1 = IN2 (A15)
	MOVLW D'2'
	MOVWF CLCnSEL0
	; Data 2 = IN3 (A14)
	MOVLW D'3'
	MOVWF CLCnSEL1
	; Data 3 = IN6 (A13)
	MOVLW D'6'
	MOVWF CLCnSEL2
	; Data 4 = IN7 (A12)
	MOVLW D'7'
	MOVWF CLCnSEL3
	; Gate 1 = Data 1 & ~Data 2 & ~Data 3 & ~Data 4
	MOVLW B'10101001'
	MOVWF CLCnGLS0
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL
	; enable, no interrupts, 4-input AND
	MOVLW B'10000010'
	MOVWF CLCnCON
	; CLC8 : merge access detections
	INCF CLCSELECT, F
	; Data 1 = CLC2
	MOVLW D'52'
	MOVWF CLCnSEL0
	; Data 2 = CLC3
	MOVLW D'53'
	MOVWF CLCnSEL1
	; Data 3 = CLC5
	MOVLW D'55'
	MOVWF CLCnSEL2
	; Data 4 = CLC6
	MOVLW D'56'
	MOVWF CLCnSEL3
	; Gate 1 (CLK) = Data 1 | Data 2 | Data 3 | Data 4
	MOVLW  B'10101010'
	MOVWF CLCnGLS0
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1
	CLRF CLCnGLS2
	CLRF CLCnGLS3
	; don't invert output
	MOVLW B'00001110'
	MOVWF CLCnPOL
	; enable, interrupt on negative edge, 4-input AND
	MOVLW B'10001010'
	MOVWF CLCnCON

	; configure DMA
	; DMA1 : Move TRISB to TRISC on CLC8 interrupt
	;        (stop emitting data on rising edge of MREQ/IOREQ)
	CLRF DMASELECT
	; Source Address = TRISB
	MOVLW LOW(TRISB)
	MOVWF DMAnSSA
	MOVLW HIGH(TRISB)
	MOVWF DMAnSSA + 1
	MOVLW UPPER(TRISB)
	MOVWF DMAnSSA + 2
	; Destination Address = TRISC
	MOVLW LOW(TRISC)
	MOVWF DMAnDSA
	MOVLW HIGH(TRISC)
	MOVWF DMAnDSA + 1
	MOVLW UPPER(TRISC)
	MOVWF DMAnDSA + 2
	; Source/Destination Message Size = Source/Destination Count = 1
	MOVLW 0x01
	MOVWF DMAnSSZ
	MOVWF DMAnSCNT
	MOVWF DMAnDSZ
	MOVWF DMAnDCNT
	; Start Trigger = CLC8
	MOVLW 0x79
	MOVWF DMAnSIRQ
	; enable DMA, enable Hardware Start Trigger
	MOVLW B'11000000'
	MOVWF DMAnCON0
	; give higher priority to DMA1
	MOVLW D'6'
	MOVWF DMA1PR

	; lock priority
	MOVLW 0x55
	MOVWF PRLOCK
	MOVLW 0xAA
	MOVWF PRLOCK
	BSF PRLOCK, 0

	; configure interrupts
	MOVLB 4
	; clear CLC2, 3, 5, 6 interrupt flags
	BCF PIR6, CLC2IF
	BCF PIR7, CLC3IF
	BCF PIR10, CLC5IF
	BCF PIR11, CLC6IF
	; enable CLC2, 3, 5, 6 interrupts
	BSF PIE6, CLC2IE
	BSF PIE7, CLC3IE
	BSF PIE10, CLC5IE
	BSF PIE11, CLC6IE
	; set interrupt vector location
	MOVLW LOW(INTERRUPT_VECTOR)
	MOVWF INTBASEL
	MOVLW HIGH(INTERRUPT_VECTOR)
	MOVWF INTBASEH
	MOVLW UPPER(INTERRUPT_VECTOR)
	MOVWF INTBASEU
	; lock interrupt vector location
	MOVLW 0x55
	MOVWF IVTLOCK
	MOVLW 0xAA
	MOVWF IVTLOCK
	BSF IVTLOCK, 0

	; prepare for queries
	; set ROM table upper address
	MOVLW UPPER(ROM_DATA)
	MOVWF TBLPTR + 2
	; set bank to 2 for accessing UART
	MOVLB 2
	; reset WAIT
	SETF U2TXB

	; enable global interrupts
	BSF INTCON0, GIE, A

	; release Z80 reset
	BSF LATE, 1, A

	; configure NCO1
	; overflow_freq = (clock_freq * increment) / (1 << 20)
	; output_freq = overflow_freq / 2
	; increment = (output_freq * 2) * (1 << 20) / clock_freq
	; output_freq = 2.5MHz, clock_freq = 64MHz -> increment = 81920.0 (0x14000)
	MOVLW LOW(NCO1INC)
	MOVWF FSR0, A
	MOVLW HIGH(NCO1INC)
	MOVWF FSR0 + 1, A
	CLRF POSTINC0, A ; NCO1INC
	MOVLW 0x40
	MOVWF POSTINC0, A ; NCO1INC + 1
	MOVLW 0x01
	MOVWF POSTINC0, A ; NCO1INC + 2
	; enable NCO1
	BSF INDF0, 7, A ; NCO1CON

	; just wait for interrupts
NOTHING_TO_DO
	BRA NOTHING_TO_DO

; ROM access handler
	ORG ($ + 3) & ~3
INTERRUPT_HANDLER_CLC2
	; check RD
	BTFSC PORTA, 5, A
	BRA INTERRUPT_HANDLER_CLC2_WRITE
	; read operation
	; read ROM and output to the port
	MOVFF PORTB, TBLPTR
	MOVFF PORTD, TBLPTR + 1
	TBLRD*
	MOVFF TABLAT, LATC
	CLRF TRISC, A
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR6, CLC2IF, A
	; done
	RETFIE 1
INTERRUPT_HANDLER_CLC2_WRITE
	; write operation
	; do nothing because this is ROM
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR6, CLC2IF, A
	; done
	RETFIE 1

; RAM access handler
	ORG ($ + 3) & ~3
INTERRUPT_HANDLER_CLC3
	; set address (use RAM 0x1000 - 0x1FFF (Bank 16 - Bank 31))
	; the most significant 2 bits of FSR1H will be ignored
	; switching address between interrupt trigger and interrupt handling may enable
	; access to RAM 0x3000 - 0x3FFF, but this region is unimplemented and should be useless
	MOVFF PORTB, FSR0
	MOVF PORTD, W, A
	IORLW 0x10
	MOVWF FSR0 + 1, A
	; check RD
	BTFSC PORTA, 5, A
	BRA INTERRUPT_HANDLER_CLC3_WRITE
	; read operation
	; read RAM and output to the port
	MOVFF INDF0, LATC
	CLRF TRISC, A
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR7, CLC3IF, A
	; done
	RETFIE 1
INTERRUPT_HANDLER_CLC3_WRITE
	; write operation
	MOVFF PORTC, INDF0
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR7, CLC3IF, A
	; done
	RETFIE 1

; REGISTER access handler
	ORG ($ + 3) & ~3
INTERRUPT_HANDLER_CLC5
	; check high address
	MOVF PORTD, W, A
	XORLW 0xE0
	BNZ INTERRUPT_HANDLER_CLC5_UNDEFINED
	; check low address
	MOVF PORTB, W, A
	BZ INTERRUPT_HANDLER_CLC5_E000
	ADDLW -1
	BZ INTERRUPT_HANDLER_CLC5_E001
	; no matching address
INTERRUPT_HANDLER_CLC5_UNDEFINED
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1

INTERRUPT_HANDLER_CLC5_E000
	; UART data register
	; check RD
	BTFSC PORTA, 5, A
	BRA INTERRUPT_HANDLER_CLC5_E000_WRITE
	; read operation
	; read REGISTER and output to the port
	MOVFF U3RXB, LATC
	CLRF TRISC, A
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1
INTERRUPT_HANDLER_CLC5_E000_WRITE
	; write operation
	MOVFF PORTC, U3TXB
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1

INTERRUPT_HANDLER_CLC5_E001
	; UART control register
	; check RD
	BTFSC PORTA, 5, A
	BRA INTERRUPT_HANDLER_CLC5_E001_WRITE
	; read operation
	; read REGISTER and output to the port
	MOVFF PIR9, LATC
	CLRF TRISC, A
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1
INTERRUPT_HANDLER_CLC5_E001_WRITE
	; write operation
	; do nothing
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1

; I/O access handler
	ORG ($ + 3) & ~3
INTERRUPT_HANDLER_CLC6
	; currently nothing to do
	; reset WAIT
	SETF U2TXB
	; clear interrupt flag
	BCF PIR11, CLC6IF, A
	; done
	RETFIE 1

; interrupt vectors
	ORG 0x10000 - 0x100
INTERRUPT_VECTOR
	ORG INTERRUPT_VECTOR + 2 * 0x31
	DW INTERRUPT_HANDLER_CLC2 >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x3D
	DW INTERRUPT_HANDLER_CLC3 >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x51
	DW INTERRUPT_HANDLER_CLC5 >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x59
	DW INTERRUPT_HANDLER_CLC6 >> 2

; ROM data
	ORG 0x10000
ROM_DATA
	DB 0x18, 0xFE ; A: JR A

	END
