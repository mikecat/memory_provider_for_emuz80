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
	; LFSR on PIC18F47Q43 differs from one on PIC18F47Q10
SET_FSR MACRO F, K
	DW 0xEE00 | (((F) & 3) << 4) | (((K) >> D'10') & 0xF)
	DW 0xF000 | ((K) & 0x3FF)
	ENDM

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

; GPR definitions

GPR_LAST = 0x0500
ALLOCATE_GPR MACRO NAME, SIZE
NAME EQU GPR_LAST
GPR_LAST = GPR_LAST + SIZE
	ENDM

	ALLOCATE_GPR PORTA_SAVE_FOR_RAM, 1
	ALLOCATE_GPR ENTER_MANAGE_MODE_FLAG, 1
	ALLOCATE_GPR STARTUP_DELAY_COUNTER, 1
	ALLOCATE_GPR PRINT_BIN8_BUFFER, 1
	ALLOCATE_GPR PRINT_BIN8_COUNTER, 1
	ALLOCATE_GPR PRINT_PORT_STATUS_BUFFER, 1
	ALLOCATE_GPR NVM_OPERATION_BSR_BUFFER, 1

; EEPROM definitions

NVM_EEPROM_BASE EQU 0x380000

EEPROM_LAST = 0x000
ALLOCATE_EEPROM MACRO NAME, SIZE
NAME EQU EEPROM_LAST
EEPROM_LAST = EEPROM_LAST + SIZE
	ENDM

	ALLOCATE_EEPROM EEPROM_PORT_OUTPUT_OFF, 1

; conifigurations (on both GPR and EEPROM)

ALLOCATE_CONFIG MACRO GPR_NAME, EEPROM_NAME, SIZE
	ALLOCATE_GPR GPR_NAME, SIZE
	ALLOCATE_EEPROM EEPROM_NAME, SIZE
	ENDM

GPR_CONFIG_BEGIN EQU GPR_LAST
EEPROM_CONFIG_BEGIN EQU EEPROM_LAST
	ALLOCATE_CONFIG GPR_CLOCK_ENABLE, EEPROM_CLOCK_ENABLE, 1
	ALLOCATE_CONFIG GPR_CLOCK_FREQUENCY, EEPROM_CLOCK_FREQUENCY, 4
GPR_CONFIG_END EQU GPR_LAST
EEPROM_CONFIG_END EQU EEPROM_LAST

; SFR definitions

GO EQU 0
CLC2IF EQU 1
CLC3IF EQU 5
CLC5IF EQU 1
CLC6IF EQU 1
CLC7IF EQU 1
CLC2IE EQU 1
CLC3IE EQU 5
CLC5IE EQU 1
CLC6IE EQU 1
GIE EQU 7
NOT_RI EQU 2
U3EIE EQU 2
U3TXIF EQU 1
U3RXIF EQU 0
RXBIMD EQU 3
RXBKIE EQU 2
TXMTIF EQU 7
C EQU 0
Z EQU 2
PRLOCKED EQU 0
PPSLOCKED EQU 0
IVTLOCKED EQU 0
ON EQU 7
RUNOVF EQU 7

NVMCON0 EQU 0x40
NVMCON1 EQU 0x41
NVMLOCK EQU 0x42
NVMADR EQU 0x43
NVMDATL EQU 0x46

PRLOCK EQU 0xB4
DMA1PR EQU 0xB6
DMA2PR EQU 0xB7
DMA3PR EQU 0xB8
MAINPR EQU 0xBE
ISRPR EQU 0xBF

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
DMAnCON1 EQU 0xFD
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
CLCIN5PPS EQU 0x0266
CLCIN6PPS EQU 0x0267
CLCIN7PPS EQU 0x0268
U3RXPPS EQU 0x0276

U3RXB EQU 0x02C7
U3TXB EQU 0x02C9
U3CON0 EQU 0x02D1
U3CON1 EQU 0x02D2
U3CON2 EQU 0x02D3
U3BRG EQU 0x02D4
U3ERRIR EQU 0x02D8
U3ERRIE EQU 0x02D9

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
IVTBASEL EQU 0x045D
IVTBASEH EQU 0x045E
IVTBASEU EQU 0x045F

PIE6 EQU 0x04A4
PIE7 EQU 0x04A5
PIE9 EQU 0x04A7
PIE10 EQU 0x04A8
PIE11 EQU 0x04A9
PIR6 EQU 0x04B4
PIR7 EQU 0x04B5
PIR9 EQU 0x04B7
PIR10 EQU 0x04B8
PIR11 EQU 0x04B9
PIR14 EQU 0x04BC

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
STATUS EQU 0x04D8

BSR EQU 0x04E0
FSR1 EQU 0x04E1
INDF1 EQU 0x04E7
WREG EQU 0x4E8
FSR0 EQU 0x04E9
POSTINC0 EQU 0x04EE
INDF0 EQU 0x04EF
PCON0 EQU 0x4F0
TABLAT EQU 0x04F5
TBLPTR EQU 0x04F6

; program code

	ORG 0

	; load configuration from EEPROM to GPR
	MOVLB 0
	MOVLW LOW(NVM_EEPROM_BASE | EEPROM_CONFIG_BEGIN)
	MOVWF NVMADR, B
	MOVLW HIGH(NVM_EEPROM_BASE | EEPROM_CONFIG_BEGIN)
	MOVWF NVMADR + 1, B
	MOVLW UPPER(NVM_EEPROM_BASE | EEPROM_CONFIG_BEGIN)
	MOVWF NVMADR + 2, B
	MOVLW B'00000001' ; Read and Post Increment
	MOVWF NVMCON1, B
	MOVLW GPR_CONFIG_END - GPR_CONFIG_BEGIN
	SET_FSR 0, GPR_CONFIG_BEGIN
LOAD_CONFIG_LOOP
	BSF NVMCON0, GO, B
	MOVFF NVMDATL, POSTINC0
	ADDLW -1
	BNZ LOAD_CONFIG_LOOP
	; replace 0xFF with default values
	; default value for GPR_CLOCK_ENABLE is ON (not zero)
	; 0xFF can be seen as ON, so no change is required
	COMF GPR_CLOCK_FREQUENCY, W, A
	BNZ CONFIG_CLOCK_FREQUENCY_ALREADY_SET
	MOVLW 0x02 ;2.5MHz (2,500,000Hz), BCD
	MOVWF GPR_CLOCK_FREQUENCY, A
	MOVLW 0x50
	MOVWF GPR_CLOCK_FREQUENCY + 1, A
	CLRF GPR_CLOCK_FREQUENCY + 2, A
	CLRF GPR_CLOCK_FREQUENCY + 3, A
CONFIG_CLOCK_FREQUENCY_ALREADY_SET

	; port settings
	MOVLB 4
	; set RA4 (WAIT) to output
	BCF TRISA, 4, B
	; set RA3 (CLK) to output (if clock is enabled)
	TSTFSZ GPR_CLOCK_ENABLE, A
	BCF TRISA, 3, B
	; RB0-RB7 (A0-A7) : in (default)
	; RC0-RC7 (D0-D7) ; in (default)
	; RD0-RD7 (A8-A15) : in (default)
	; RE1(RESET), RE2(INT) : out / the other REx : in
	MOVLW B'11111001'
	MOVWF TRISE, B
	; no analog
	CLRF ANSELA, B
	CLRF ANSELB, B
	CLRF ANSELC, B
	CLRF ANSELD, B
	CLRF ANSELE, B
	; enable weak pull-up for inputs except for RA7 (RXD: external pull-up exists)
	MOVLW B'01111111'
	MOVWF WPUA, B
	MOVLW B'11111111'
	MOVWF WPUB, B
	MOVWF WPUC, B
	MOVWF WPUD, B
	MOVWF WPUE, B
	; use TTL input
	CLRF INLVLA, B
	CLRF INLVLB, B
	CLRF INLVLC, B
	CLRF INLVLD, B
	CLRF INLVLE, B
	; no Slew Rate Control
	CLRF SLRCONA, B
	CLRF SLRCONB, B
	CLRF SLRCONC, B
	CLRF SLRCOND, B
	CLRF SLRCONE, B

	; for peripheral pin settings
	MOVLB 2
	; give control of RA3 (CLK) to LATA
	CLRF RA3PPS, B

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

	; wait for a while to avoid UART desync due to reset
	CLRF STARTUP_DELAY_COUNTER, A
STARTUP_DELAY_LOOP1
	MOVLW 0
STARTUP_DELAY_LOOP2
	ADDLW 1
	BNC STARTUP_DELAY_LOOP2
	MOVLW 12
	ADDWF STARTUP_DELAY_COUNTER, F, A
	BNC STARTUP_DELAY_LOOP1

	; judge if we should enter management mode
	BTFSS PCON0, NOT_RI, A
	BRA RESET_INSTRUCTION_EXECUTED
	; reset is not caused by RESET instructon
	CLRF ENTER_MANAGE_MODE_FLAG, A
	; RA7/RA7 check
	COMF PORTA, W, A
	ANDLW B'11000000'
	BTFSS STATUS, Z, A
	SETF ENTER_MANAGE_MODE_FLAG, A ; enter management mode if RA7 = LOW or RA6 = LOW
	; external input check
	MOVF PORTB, W, A
	ANDWF PORTC, W, A
	ANDWF PORTD, W, A
	XORLW 0xFF
	BTFSS STATUS, Z, A
	SETF ENTER_MANAGE_MODE_FLAG, A ; enter management mode if external drive to low detected
RESET_INSTRUCTION_EXECUTED
	BSF PCON0, NOT_RI, A

	; peripheral pin settings
	; CLCx Input 1 = RA0 (IOREQ)
	MOVLW B'00000000'
	MOVWF CLCIN0PPS, B
	; CLCx Input 2 = RA1 (MREQ)
	MOVLW B'00000001'
	MOVWF CLCIN1PPS, B
	; CLCx Input 3 = RD7 (A15)
	MOVLW B'00011111'
	MOVWF CLCIN2PPS, B
	; CLCx Input 4 = RD6 (A14)
	MOVLW B'00011110'
	MOVWF CLCIN3PPS, B
	; CLCx Input 5 = RA2 (RFSH)
	MOVLW B'00000010'
	MOVWF CLCIN4PPS, B
	; CLCx Input 6 = RA5 (RD)
	MOVLW B'00000101'
	MOVWF CLCIN5PPS, B
	; CLCx Input 7 = RD5 (A13)
	MOVLW B'00011101'
	MOVWF CLCIN6PPS, B
	; CLCx Input 8 = RD4 (A12)
	MOVLW B'00011100'
	MOVWF CLCIN7PPS, B
	; UART3 Receive = RA7 (RXD)
	MOVLW B'00000111'
	MOVWF U3RXPPS, B
	; NCO1 = RA3 (CLK)
	MOVLW 0x3F
	MOVWF RA3PPS, B
	; UART3 TX = RA6 (TXD)
	MOVLW 0x26
	MOVWF RA6PPS, B
	; CLC1OUT = RA4 (WAIT)
	MOVLW 0x01
	MOVWF RA4PPS, B
	; lock settings
	MOVLW 0x55
	MOVWF PPSLOCK, B
	MOVLW 0xAA
	MOVWF PPSLOCK, B
	BSF PPSLOCK, PPSLOCKED, B

	; configure UART
	; 9600bps with 64MHz clock : U3BRG = 415.67
	MOVLW 0xA0
	MOVWF U3BRG, B
	MOVLW 0x01
	MOVWF U3BRG + 1, B
	; don't stop on RX overflow
	BSF U3CON2, RUNOVF, B
	; enable break interrupt
	BSF U3CON1, RXBIMD, B
	BSF U3ERRIE, RXBKIE, B
	; enable TX, enable RX, Asynchronous 8-bit, no pality
	MOVLW B'00110000'
	MOVWF U3CON0, B
	; enable serial port
	BSF U3CON1, ON, B
	; enable RA6 (TXD) output
	BCF TRISA, 6, A

	; configure CLC
	; reminder : IN0 = IOREQ, IN1 = MREQ, IN4 = RFSH, IN5 = RD
	; reminder : IN2 = A15, IN3 = A14, IN6 = A13, IN7 = A12
	; reminder : OR + select negated input + reverse output polarity = AND
	MOVLB 0
	; CLC1 : switch to LOW when one of detection signals becomes HIGH
	CLRF CLCSELECT, B
	; Data 1 = CLC2
	MOVLW D'52'
	MOVWF CLCnSEL0, B
	; Data 2 = CLC3
	MOVLW D'53'
	MOVWF CLCnSEL1, B
	; Data 3 = CLC5
	MOVLW D'55'
	MOVWF CLCnSEL2, B
	; Data 4 = CLC6
	MOVLW D'56'
	MOVWF CLCnSEL3, B
	; Gate 1 (CLK) = Data 1 | Data 2 | Data 3 | Data 4
	MOVLW  B'10101010'
	MOVWF CLCnGLS0, B
	; Gate 2 (D) = const 1
	CLRF CLCnGLS1, B
	; Gate 3 (RESET) = Const 1
	CLRF CLCnGLS2, B
	; Gate 4 (SET) = const 0
	CLRF CLCnGLS3, B
	; invert output
	MOVLW B'10000110'
	MOVWF CLCnPOL, B
	; enable, no interrupts, 1-input D-FF
	MOVLW B'10000100'
	MOVWF CLCnCON, B
	; CLC2 : detect ROM access (RD = 0, MREQ = 0, A15 = 0, A14 = 0)
	INCF CLCSELECT, F, B
	; Data 1 = IN5 (RD)
	MOVLW D'5'
	MOVWF CLCnSEL0, B
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1, B
	; Data 3 = IN2 (A15)
	MOVLW D'2'
	MOVWF CLCnSEL2, B
	; Data 4 = IN3 (A14)
	MOVLW D'3'
	MOVWF CLCnSEL3, B
	; Gate 1 = ~Data 1 & ~Data 2 & ~Data 3 & ~Data 4
	MOVLW B'10101010'
	MOVWF CLCnGLS0, B
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1, B
	CLRF CLCnGLS2, B
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL, B
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON, B
	; CLC3 : detect RAM access (RFSH = 1, MREQ = 0, CLC4 = 1)
	INCF CLCSELECT, F, B
	; Data 1 = IN4 (RFSH)
	MOVLW D'4'
	MOVWF CLCnSEL0, B
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1, B
	; Data 3 = CLC4
	MOVLW D'54'
	MOVWF CLCnSEL2, B
	; Data 4 = TMR6 (don't care)
	MOVLW D'24'
	MOVWF CLCnSEL3, B
	; Gate 1 = Data 1 & ~Data 2 & Data 3
	MOVLW B'00011001'
	MOVWF CLCnGLS0, B
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1, B
	CLRF CLCnGLS2, B
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL, B
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON, B
	; CLC4 : helper for detect RAM access (A15 = 1, A14 = 0, A13 = 0, A12 = 0)
	INCF CLCSELECT, F, B
	; Data 1 = IN2 (A15)
	MOVLW D'2'
	MOVWF CLCnSEL0, B
	; Data 2 = IN3 (A14)
	MOVLW D'3'
	MOVWF CLCnSEL1, B
	; Data 3 = IN6 (A13)
	MOVLW D'6'
	MOVWF CLCnSEL2, B
	; Data 4 = IN7 (A12)
	MOVLW D'7'
	MOVWF CLCnSEL3, B
	; Gate 1 = Data 1 & ~Data 2 & ~Data 3 & ~Data 4
	MOVLW B'10101001'
	MOVWF CLCnGLS0, B
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1, B
	CLRF CLCnGLS2, B
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL, B
	; enable, no interrupts, 4-input AND
	MOVLW B'10000010'
	MOVWF CLCnCON, B
	; CLC5 : detect REGISTER access (RFSH = 1, MREQ = 0, A15 = 1, A14 = 1)
	INCF CLCSELECT, F, B
	; Data 1 = IN4 (RFSH)
	MOVLW D'4'
	MOVWF CLCnSEL0, B
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1, B
	; Data 3 = IN2 (A15)
	MOVLW D'2'
	MOVWF CLCnSEL2, B
	; Data 4 = IN3 (A14)
	MOVLW D'3'
	MOVWF CLCnSEL3, B
	; Gate 1 = Data 1 & ~Data 2 & Data 3 & Data 4
	MOVLW B'01011001'
	MOVWF CLCnGLS0, B
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1, B
	CLRF CLCnGLS2, B
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL, B
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON, B
	; CLC6 : detect I/O access (IOREQ = 0)
	INCF CLCSELECT, F, B
	; Data 1 = IN0 (IOREQ)
	CLRF CLCnSEL0, B
	; Data 2 = Data 3 = Data 4 = TMR6 (don't care)
	MOVLW D'24'
	MOVWF CLCnSEL1, B
	MOVWF CLCnSEL2, B
	MOVWF CLCnSEL3, B
	; Gate 1 = ~Data 1
	MOVLW B'00000010'
	MOVWF CLCnGLS0, B
	; Gate 2 = Gate 3 = Gate 4 = const 1
	CLRF CLCnGLS1, B
	CLRF CLCnGLS2, B
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001111'
	MOVWF CLCnPOL, B
	; enable, interrupt on rising edge, 4-input AND
	MOVLW B'10010010'
	MOVWF CLCnCON, B
	; CLC7 : detect ROM or RAM read (CLC2 = 1 OR (CLC3 = 1, RD = 0))
	INCF CLCSELECT, F, B
	; Data 1 = CLC2
	MOVLW D'52'
	MOVWF CLCnSEL0, B
	; Data 2 = CLC3
	MOVLW D'53'
	MOVWF CLCnSEL1, B
	; Data 3 = IN5 (RD)
	MOVLW D'5'
	MOVWF CLCnSEL2, B
	; Data 4 = TMR6 (don't care)
	MOVLW D'24'
	MOVWF CLCnSEL3, B
	; Gate 1 = Data 1
	MOVLW B'00000010'
	MOVWF CLCnGLS0, B
	; Gate 2 = const 1
	CLRF CLCnGLS1, B
	; Gate 3 = Data 2 & ~Data 3
	MOVLW B'00100100'
	MOVWF CLCnGLS2, B
	; Gate 4 = const 1
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001110'
	MOVWF CLCnPOL, B
	; enable, interrupt on positive edge, AND-OR
	MOVLW B'10010000'
	MOVWF CLCnCON, B
	; CLC8 : access request (((RD = 0 OR RFSH = 1), MREQ = 0) OR IOREQ = 0)
	INCF CLCSELECT, F, B
	; Data 1 = IN4 (RFSH)
	MOVLW D'4'
	MOVWF CLCnSEL0, B
	; Data 2 = IN1 (MREQ)
	MOVLW D'1'
	MOVWF CLCnSEL1, B
	; Data 3 = IN0 (IOREQ)
	CLRF CLCnSEL2, B
	; Data 4 = IN5 (RD)
	MOVLW D'5'
	MOVWF CLCnSEL3, B
	; Gate 1 = Data 1 | ~Data 4
	MOVLW  B'01000010'
	MOVWF CLCnGLS0, B
	; Gate 2 = ~Data 2
	MOVLW  B'00000100'
	MOVWF CLCnGLS1, B
	; Gate 3 = ~Data 3
	MOVLW  B'00010000'
	MOVWF CLCnGLS2, B
	; Gate 4 = const 1
	CLRF CLCnGLS3, B
	; don't invert output
	MOVLW B'00001000'
	MOVWF CLCnPOL, B
	; enable, interrupt on negative edge, AND-OR
	MOVLW B'10001000'
	MOVWF CLCnCON, B
	; select CLC1
	CLRF CLCSELECT, B

	; enter management mode according to the flag
	TSTFSZ ENTER_MANAGE_MODE_FLAG, A
	GOTO MANAGE_MODE_INIT

	; set EEPROM data for stop emitting data
	MOVLW LOW(NVM_EEPROM_BASE | EEPROM_PORT_OUTPUT_OFF)
	MOVWF NVMADR, B
	MOVLW HIGH(NVM_EEPROM_BASE | EEPROM_PORT_OUTPUT_OFF)
	MOVWF NVMADR + 1, B
	MOVLW UPPER(NVM_EEPROM_BASE | EEPROM_PORT_OUTPUT_OFF)
	MOVWF NVMADR + 2, B
	CLRF NVMCON1, B
	BSF NVMCON0, GO, B
	COMF NVMDATL, W, B
	BZ EEPROM_FOR_PORT_OFF_OK ; don't write because data is already 0xFF
	MOVLW 0xFF
	MOVWF NVMDATL, B
	MOVLW 0x03
	MOVWF NVMCON1, B
	CALL NVM_OPERATION
EEPROM_FOR_PORT_OFF_OK

	; configure DMA
	; DMA1 : Move EEPROM_PORT_OUTPUT_OFF to TRISC on CLC8 interrupt
	;        (stop emitting data on rising edge of MREQ/IOREQ)
	CLRF DMASELECT, B
	; Source Address = EEPROM_PORT_OUTPUT_OFF
	MOVLW LOW(EEPROM_PORT_OUTPUT_OFF)
	MOVWF DMAnSSA, B
	MOVLW HIGH(EEPROM_PORT_OUTPUT_OFF)
	MOVWF DMAnSSA + 1, B
	CLRF DMAnSSA + 2, B
	; Destination Address = TRISC
	MOVLW LOW(TRISC)
	MOVWF DMAnDSA, B
	MOVLW HIGH(TRISC)
	MOVWF DMAnDSA + 1, B
	; Source = Data EEPROM
	MOVLW B'00011000'
	MOVWF DMAnCON1, B
	; Source/Destination Message Size = Source/Destination Count = 1
	MOVLW 0x01
	MOVWF DMAnSSZ, B
	MOVWF DMAnSCNT, B
	MOVWF DMAnDSZ, B
	MOVWF DMAnDCNT, B
	; Start Trigger = CLC8
	MOVLW 0x79
	MOVWF DMAnSIRQ, B
	; enable DMA, enable Hardware Start Trigger
	MOVLW B'11000000'
	MOVWF DMAnCON0, B
	; DMA2 : Move IVTBASEL to TRISC on CLC7 interrupt
	;        (start emitting data on ROM or RAM read access)
	;        (don't use EEPROM as source because PORTA read shoudn't be too early)
	INCF DMASELECT, F, B
	; Source Address = IVTBASEL
	MOVLW LOW(IVTBASEL)
	MOVWF DMAnSSA, B
	MOVLW HIGH(IVTBASEL)
	MOVWF DMAnSSA + 1, B
	MOVLW UPPER(IVTBASEL)
	MOVWF DMAnSSA + 2, B
	; Destination Address = TRISC
	MOVLW LOW(TRISC)
	MOVWF DMAnDSA, B
	MOVLW HIGH(TRISC)
	MOVWF DMAnDSA + 1, B
	; Source/Destination Message Size = Source/Destination Count = 1
	MOVLW 0x01
	MOVWF DMAnSSZ, B
	MOVWF DMAnSCNT, B
	MOVWF DMAnDSZ, B
	MOVWF DMAnDCNT, B
	; Start Trigger = CLC7
	MOVLW 0x71
	MOVWF DMAnSIRQ, B
	; enable DMA, enable Hardware Start Trigger
	MOVLW B'11000000'
	MOVWF DMAnCON0, B
	; DMA3 : Move PORTA to PORTA_SAVE_FOR_RAM on CLC3 interrupt
	;        (save RAM RD status)
	INCF DMASELECT, F, B
	; Source Address = PORTA
	MOVLW LOW(PORTA)
	MOVWF DMAnSSA, B
	MOVLW HIGH(PORTA)
	MOVWF DMAnSSA + 1, B
	MOVLW UPPER(PORTA)
	MOVWF DMAnSSA + 2, B
	; Destination Address = PORTA_SAVE_FOR_RAM
	MOVLW LOW(PORTA_SAVE_FOR_RAM)
	MOVWF DMAnDSA, B
	MOVLW HIGH(PORTA_SAVE_FOR_RAM)
	MOVWF DMAnDSA + 1, B
	; Source/Destination Message Size = Source/Destination Count = 1
	MOVLW 0x01
	MOVWF DMAnSSZ, B
	MOVWF DMAnSCNT, B
	MOVWF DMAnDSZ, B
	MOVWF DMAnDCNT, B
	; Start Trigger = CLC3
	MOVLW 0x3D
	MOVWF DMAnSIRQ, B
	; enable DMA, enable Hardware Start Trigger
	MOVLW B'11000000'
	MOVWF DMAnCON0, B

	; configure priority
	MOVLW D'4'
	MOVWF DMA1PR, B
	MOVLW D'5'
	MOVWF DMA2PR, B
	MOVLW D'6'
	MOVWF DMA3PR, B
	MOVLW D'7'
	MOVWF MAINPR, B
	MOVWF ISRPR, B
	; lock priority
	MOVLW 0x55
	MOVWF PRLOCK, B
	MOVLW 0xAA
	MOVWF PRLOCK, B
	BSF PRLOCK, PRLOCKED, B

	; configure interrupts
	MOVLB 4
	; clear CLC2, 3, 5, 6 interrupt flags
	BCF PIR6, CLC2IF, B
	BCF PIR7, CLC3IF, B
	BCF PIR10, CLC5IF, B
	BCF PIR11, CLC6IF, B
	; enable CLC2, 3, 5, 6 interrupts
	BSF PIE6, CLC2IE, B
	BSF PIE7, CLC3IE, B
	BSF PIE10, CLC5IE, B
	BSF PIE11, CLC6IE, B
	; enable UART3 break (error) interrupt
	BSF PIE9, U3EIE, B
	; set interrupt vector location
	MOVLW LOW(INTERRUPT_VECTOR)
	MOVWF IVTBASEL, B
	MOVLW HIGH(INTERRUPT_VECTOR)
	MOVWF IVTBASEH, B
	MOVLW UPPER(INTERRUPT_VECTOR)
	MOVWF IVTBASEU, B
	; lock interrupt vector location
	MOVLW 0x55
	MOVWF IVTLOCK, B
	MOVLW 0xAA
	MOVWF IVTLOCK, B
	BSF IVTLOCK, IVTLOCKED, B

	; prepare for queries
	; set ROM table upper address
	MOVLW UPPER(ROM_DATA)
	MOVWF TBLPTR + 2, B
	; give access to CLC1 via INDF1
	SET_FSR 1, CLCnPOL
	; set bank to 2 for accessing UART
	MOVLB 2

	; release WAIT reset
	BCF INDF1, 2, A

	; enable global interrupts
	BSF INTCON0, GIE, A

	; release Z80 reset
	BSF LATE, 1, A

	; configure NCO1
	; overflow_freq = (clock_freq * increment) / (1 << 20)
	; output_freq = overflow_freq / 2
	; increment = (output_freq * 2) * (1 << 20) / clock_freq
	; output_freq = 2.5MHz, clock_freq = 64MHz -> increment = 81920.0 (0x14000)
	SET_FSR 0, NCO1INC
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
	; read ROM and output to the port
	MOVFF PORTB, TBLPTR
	MOVFF PORTD, TBLPTR + 1
	TBLRD*
	MOVFF TABLAT, LATC
	; reset WAIT
	BSF INDF1, 2, A
	BCF INDF1, 2, A
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
	MOVLW 0x10
	MOVFF PORTB, FSR0
	IORWF PORTD, W, A
	MOVWF FSR0 + 1, A
	; read data to write
	MOVF PORTC, W, A
	; read RAM and output to the port
	MOVFF INDF0, LATC
	; reset WAIT
	BSF INDF1, 2, A
	BCF INDF1, 2, A
	; clear interrupt flag
	BCF PIR7, CLC3IF, A
	; write to RAM if this is not read operation
	BTFSC PORTA_SAVE_FOR_RAM, 5, A
	MOVWF INDF0, A
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
	BSF INDF1, 2, A
	BCF INDF1, 2, A
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
	BSF INDF1, 2, A
	BCF INDF1, 2, A
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1
INTERRUPT_HANDLER_CLC5_E000_WRITE
	; write operation
	MOVFF PORTC, U3TXB
	; reset WAIT
	BSF INDF1, 2, A
	BCF INDF1, 2, A
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
	BSF INDF1, 2, A
	BCF INDF1, 2, A
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1
INTERRUPT_HANDLER_CLC5_E001_WRITE
	; write operation
	; do nothing
	; reset WAIT
	BSF INDF1, 2, A
	BCF INDF1, 2, A
	; clear interrupt flag
	BCF PIR10, CLC5IF, A
	; done
	RETFIE 1

; I/O access handler
	ORG ($ + 3) & ~3
INTERRUPT_HANDLER_CLC6
	; currently nothing to do
	; reset WAIT
	BSF INDF1, 2, A
	BCF INDF1, 2, A
	; clear interrupt flag
	BCF PIR11, CLC6IF, A
	; done
	RETFIE 1

; UART3 error handler
	ORG ($ + 3) & ~3
INTERRUPT_HANDLER_U3E
	; enter manage mode
	SETF ENTER_MANAGE_MODE_FLAG, A
	RESET
	RETFIE 1 ; won't come here, for just in case

; manage mode programs

; perform NVM access (write) with unlock sequence, then wait while GO is 1
; modifies W register
NVM_OPERATION
	MOVF BSR, W, A
	ANDLW 0x3F
	BTFSC INTCON0, GIE, A
	IORLW 0x80
	MOVWF NVM_OPERATION_BSR_BUFFER, A
	MOVLB 0
	BCF INTCON0, GIE, A
	MOVLW 0x55
	MOVWF NVMLOCK, B
	MOVLW 0xAA
	MOVWF NVMLOCK, B
	BSF NVMCON0, GO, B
NVM_OPERATION_GO_WAIT
	BTFSC NVMCON0, GO, B
	BRA NVM_OPERATION_GO_WAIT
	BTFSC NVM_OPERATION_BSR_BUFFER, 7, A
	BSF INTCON0, GIE, A
	MOVFF NVM_OPERATION_BSR_BUFFER, BSR
	RETURN

; send a byte in W register to UART3
PUT_CHAR
	BTFSS PIR9, U3TXIF, A
	BRA PUT_CHAR
	MOVFF WREG, U3TXB
	RETURN

; send bytes pointed at by TBLPTR to UART3, terminated by 0x00 byte
; TBLPTR data will be modified
PUT_STRING_FROM_TABLE_LOOP ; call NOT this label
	BTFSS PIR9, U3TXIF, A
	BRA PUT_STRING_FROM_TABLE_LOOP
	MOVFF TABLAT, U3TXB
PUT_STRING_FROM_TABLE ; call this label
	TBLRD*+
	TSTFSZ TABLAT, A
	BRA PUT_STRING_FROM_TABLE_LOOP
	RETURN

; set TBLPTR and print string
; W register will be modified
SET_TBLPTR_PUT_STRING MACRO ADDRESS
	MOVLW LOW(ADDRESS)
	MOVWF TBLPTR, A
	MOVLW HIGH(ADDRESS)
	MOVWF TBLPTR + 1, A
	MOVLW UPPER(ADDRESS)
	MOVWF TBLPTR + 2, A
	CALL PUT_STRING_FROM_TABLE
	ENDM

; read one byte from UART3 and store to W
; wait until receiving one byte
GET_CHAR
	BTFSS PIR9, U3RXIF, A
	BRA GET_CHAR
	MOVFF U3ERRIR, WREG
	ANDLW B'00001000'
	BNZ GET_CHAR_FRAME_ERROR
	MOVFF U3RXB, WREG
	RETURN
GET_CHAR_FRAME_ERROR
	; frame error detected, ignore data
	MOVFF U3RXB, WREG
	BRA GET_CHAR

; print number in register W
; modifies W
PRINT_BIN8
	MOVWF PRINT_BIN8_BUFFER, A
	CLRF PRINT_BIN8_COUNTER, A
PRINT_BIN8_LOOP
	RLCF PRINT_BIN8_BUFFER, F, A
	MOVLW '0'
	BTFSC STATUS, C, A
	ADDLW 1
	CALL PUT_CHAR
	MOVLW B'00100000'
	ADDWF PRINT_BIN8_COUNTER, F, A
	BNC PRINT_BIN8_LOOP
	RETURN

; print status of PORTD, PORTB, and PORTC
PRINT_PORT_STATUS
	MOVLW 'D'
	RCALL PRINT_PORT_STATUS_SUB
	MOVF PORTD, W, A
	CALL PRINT_BIN8
	MOVLW ' '
	CALL PUT_CHAR
	MOVLW 'B'
	RCALL PRINT_PORT_STATUS_SUB
	MOVF PORTB, W, A
	CALL PRINT_BIN8
	MOVLW ' '
	CALL PUT_CHAR
	MOVLW 'C'
	RCALL PRINT_PORT_STATUS_SUB
	MOVF PORTC, W, A
	CALL PRINT_BIN8
	MOVLW '\r'
	CALL PUT_CHAR
	MOVLW '\n'
	CALL PUT_CHAR
	RETURN
PRINT_PORT_STATUS_SUB
	MOVWF PRINT_PORT_STATUS_BUFFER, A
	SET_TBLPTR_PUT_STRING PORT_MESSAGE
	MOVF PRINT_PORT_STATUS_BUFFER, W, A
	CALL PUT_CHAR
	MOVLW ':'
	GOTO PUT_CHAR

MANAGE_MODE_INIT
	SET_TBLPTR_PUT_STRING TITLE_MESSAGE
MANAGE_MODE_MAIN_LOOP
	SET_TBLPTR_PUT_STRING ASK_COMMAND_MESSAGE
MANAGE_MODE_MAIN_LOOP_GET_COMMAND
	CALL GET_CHAR
	ADDLW -'s'
	BZ START_Z80
	ADDLW 's' - 'p'
	BZ PRINT_PORT_STATUS_MENU
	ADDLW 'p' - 'c'
	BZ CONFIG_MENU
	ADDLW 'c' - '?'
	BZ SHOW_HELP
	BRA MANAGE_MODE_MAIN_LOOP_GET_COMMAND

START_Z80
	; external input check
	MOVF PORTB, W, A
	ANDWF PORTC, W, A
	ANDWF PORTD, W, A
	XORLW 0xFF
	BZ START_Z80_NO_EXTERNAL_INPUT
	CALL PRINT_PORT_STATUS
	SET_TBLPTR_PUT_STRING EXTERNAL_INPUT_CONFIRM_MESSAGE
START_Z80_EXTERNAL_INPUT_CONFIRM
	CALL GET_CHAR
	ADDLW -'y'
	BZ START_Z80_NO_EXTERNAL_INPUT
	ADDLW 'y' - 'n'
	BZ MANAGE_MODE_MAIN_LOOP
	BRA START_Z80_EXTERNAL_INPUT_CONFIRM
START_Z80_NO_EXTERNAL_INPUT
	SET_TBLPTR_PUT_STRING STARTING_Z80_MESSAGE
	CLRF ENTER_MANAGE_MODE_FLAG, A
	MOVLB HIGH(U3ERRIR)
START_Z80_WAIT_SEND_END
	BTFSS U3ERRIR, TXMTIF, B
	BRA START_Z80_WAIT_SEND_END
	RESET
	GOTO MANAGE_MODE_MAIN_LOOP ; won't come here, for just in case

PRINT_PORT_STATUS_MENU
	CALL PRINT_PORT_STATUS
	GOTO MANAGE_MODE_MAIN_LOOP

SHOW_HELP
	SET_TBLPTR_PUT_STRING HELP_MESSAGE
	GOTO MANAGE_MODE_MAIN_LOOP

CONFIG_MENU
	; print current configurations
	SET_TBLPTR_PUT_STRING CLOCK_ENABLE_MESSAGE
	MOVF GPR_CLOCK_ENABLE, W, A
	BNZ CONFIG_MENU_CLOCK_ENABLE_ON
	SET_TBLPTR_PUT_STRING CLOCK_OFF_MESSAGE
	BRA CONFIG_MENU_CLOCK_ENABLE_END
CONFIG_MENU_CLOCK_ENABLE_ON
	MOVLW 'O'
	CALL PUT_CHAR
	MOVLW 'N'
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_ENABLE_END
	SET_TBLPTR_PUT_STRING CLOCK_FREQUENCY_MESSAGE
	MOVF GPR_CLOCK_FREQUENCY, W, A
	ANDLW 0xF0
	BNZ CONFIG_MENU_CLOCK_FREQUENCY_8
	TSTFSZ GPR_CLOCK_FREQUENCY, A
	BRA CONFIG_MENU_CLOCK_FREQUENCY_7
	MOVF GPR_CLOCK_FREQUENCY + 1, W, A
	ANDLW 0xF0
	BNZ CONFIG_MENU_CLOCK_FREQUENCY_6
	TSTFSZ GPR_CLOCK_FREQUENCY + 1, A
	BRA CONFIG_MENU_CLOCK_FREQUENCY_5
	MOVF GPR_CLOCK_FREQUENCY + 2, W, A
	ANDLW 0xF0
	BNZ CONFIG_MENU_CLOCK_FREQUENCY_4
	TSTFSZ GPR_CLOCK_FREQUENCY + 2, A
	BRA CONFIG_MENU_CLOCK_FREQUENCY_3
	MOVF GPR_CLOCK_FREQUENCY + 3, W, A
	ANDLW 0xF0
	BNZ CONFIG_MENU_CLOCK_FREQUENCY_2
	BRA CONFIG_MENU_CLOCK_FREQUENCY_1
CONFIG_MENU_CLOCK_FREQUENCY_8
	SWAPF GPR_CLOCK_FREQUENCY, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_7
	MOVF GPR_CLOCK_FREQUENCY, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
	MOVLW ','
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_6
	SWAPF GPR_CLOCK_FREQUENCY + 1, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_5
	MOVF GPR_CLOCK_FREQUENCY + 1, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_4
	SWAPF GPR_CLOCK_FREQUENCY + 2, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
	MOVLW ','
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_3
	MOVF GPR_CLOCK_FREQUENCY + 2, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_2
	SWAPF GPR_CLOCK_FREQUENCY + 3, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
CONFIG_MENU_CLOCK_FREQUENCY_1
	MOVF GPR_CLOCK_FREQUENCY + 3, W, A
	ANDLW 0x0F
	ADDLW '0'
	CALL PUT_CHAR
	MOVLW ' '
	CALL PUT_CHAR
	MOVLW 'H'
	CALL PUT_CHAR
	MOVLW 'z'
	CALL PUT_CHAR
	MOVLW '\n'
	CALL PUT_CHAR
	; let the user choose which configuration to edit
	SET_TBLPTR_PUT_STRING ASK_CONFIG_TO_EDIT_MESSAGE
CONFIG_TO_EDIT_SELECT_LOOP
	CALL GET_CHAR
	ADDLW -'0'
	BZ CONFIG_EXIT_EDIT_MENU
	ADDLW -1
	BZ CONFIG_EDIT_CLOCK_ENABLE
	ADDLW -1
	BZ CONFIG_EDIT_CLOCK_FREQUENCY
	BRA CONFIG_TO_EDIT_SELECT_LOOP
CONFIG_EXIT_EDIT_MENU
	BRA MANAGE_MODE_MAIN_LOOP
	; edit clock enable configuration
CONFIG_EDIT_CLOCK_ENABLE
	BRA CONFIG_TO_EDIT_SELECT_LOOP ; not implemented
	; edit clock frequency configuration
CONFIG_EDIT_CLOCK_FREQUENCY
	BRA CONFIG_TO_EDIT_SELECT_LOOP ; not implemented

; string length for DA must be multiple of 2 except for the final line
; or extra NUL byte will be added

TITLE_MESSAGE
	DA "\r\nMemory Provider for Z80 0.4.1+dev\r"
	DA "\nCopyright (C) 2023,2025 MikeCAT\r\n"
	DA "Licensed under The MIT License. https://opensource.org/license/mit/\r\n\0"

ASK_COMMAND_MESSAGE
	DA "\r\ncommand? (s/p/c/?)\r\n\r\n\0"

STARTING_Z80_MESSAGE
	DA "starting Z80...\r\n\0"

HELP_MESSAGE
	DA "s : start Z80 operation       p : show address/data port status\r"
	DA "\nc : view/edit configuration   ? : show command list\r\n\0"

PORT_MESSAGE
	DA "PORT\0"

EXTERNAL_INPUT_CONFIRM_MESSAGE
	DA "External input detected on address/data port(s).\r\n"
	DA "Start Z80 operation anyway? (y/n)\r\n\0"

CLOCK_ENABLE_MESSAGE
	DA "1. clock output    : \0"

CLOCK_FREQUENCY_MESSAGE
	DA "\r\n2. clock frequency : \0"

CLOCK_OFF_MESSAGE
	DA "OFF (Hi-Z)\0"

ASK_CONFIG_TO_EDIT_MESSAGE
	DA "\r\nconfiguration to edit (0: don't edit)? (0/1/2)\r\n\0"

; interrupt vectors
; (also used for PORTC open, place at address multiple of 0x100)
	ORG 0x10000 - 0x100
INTERRUPT_VECTOR
	ORG INTERRUPT_VECTOR + 2 * 0x31
	DW INTERRUPT_HANDLER_CLC2 >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x3D
	DW INTERRUPT_HANDLER_CLC3 >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x4A
	DW INTERRUPT_HANDLER_U3E >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x51
	DW INTERRUPT_HANDLER_CLC5 >> 2
	ORG INTERRUPT_VECTOR + 2 * 0x59
	DW INTERRUPT_HANDLER_CLC6 >> 2

; ROM data
	ORG 0x10000
ROM_DATA
	;   LD   HL, 8100H
	;   LD   SP, HL
	DB 0x21, 0x00, 0x81, 0xF9
	; LOOP:
	;   INC  (HL)
	;   PUSH BC
	;   POP  BC
	;   JR   LOOP
	DB 0x34, 0xC5, 0xC1, 0x18, 0xFB

	END
