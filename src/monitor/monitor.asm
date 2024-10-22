;===============================================================================
; __        ____  ____   ____ ___ ____  ______  ______  
; \ \      / / /_| ___| / ___/ _ \___ \/ ___\ \/ / __ ) 
;  \ \ /\ / / '_ \___ \| |  | | | |__) \___ \\  /|  _ \ 
;   \ V  V /| (_) |__) | |__| |_| / __/ ___) /  \| |_) |
;  __\_/\_/  \___/____/ \____\___/_____|____/_/\_\____/ 
; |  \/  | ___  _ __ (_) |_ ___  _ __                   
; | |\/| |/ _ \| '_ \| | __/ _ \| '__|                  
; | |  | | (_) | | | | | || (_) | |                     
; |_|  |_|\___/|_| |_|_|\__\___/|_|                     
;                                                       
;
;-------------------------------------------------------------------------------
; Copyright (C)2014-2020 Andrew John Jacobs.
; All rights reserved.
;
; This work is made available under the terms of the Creative Commons
; Attribution-NonCommercial-ShareAlike 4.0 International license. Open the
; following URL to see the details.
;
; http://creativecommons.org/licenses/by-nc-sa/4.0/
;===============================================================================
;
; Notes:
;
;
;-------------------------------------------------------------------------------

		.include "w65c02sxb.inc"
		
;===============================================================================
; ASCII Control Characters
;-------------------------------------------------------------------------------

SOH		.equ	$01
EOT		.equ	$04
ACK		.equ	$06
BEL		.equ	$07
BS		.equ	$08
LF		.equ	$0a
CR		.equ	$0d
DC1		.equ	$11		; XON
DC3		.equ	$13		; XOFF
NAK		.equ	$15
CAN		.equ	$18
ESC		.equ	$1b
DEL		.equ	$7f

;===============================================================================
; Instruction and Mode Constants
;-------------------------------------------------------------------------------

OP_ERR		.equ	$00
OP_ADC		.equ	$02
OP_AND		.equ	$04
OP_ASL		.equ	$06
		.if	__65C02__
OP_BBR		.equ	$08
OP_BBS		.equ	$0A
		.endif
OP_BCC		.equ	$0C
OP_BCS		.equ	$0E
OP_BEQ		.equ	$10
OP_BIT		.equ	$12
OP_BMI		.equ	$14
OP_BNE		.equ	$16
OP_BPL		.equ	$18
		.if	__65C02__|__65SC02__
OP_BRA		.equ	$1A
		.endif
OP_BRK		.equ	$1C
OP_BVC		.equ	$1E
OP_BVS		.equ	$20
OP_CLC		.equ	$22
OP_CLD		.equ	$24
OP_CLI		.equ	$26
OP_CLV		.equ	$28
OP_CMP		.equ	$2A
OP_CPX		.equ	$2C
OP_CPY		.equ	$2E
OP_DEC		.equ	$30
OP_DEX		.equ	$32
OP_DEY		.equ	$34
OP_EOR		.equ	$36
OP_INC		.equ	$38
OP_INX		.equ	$3A
OP_INY		.equ	$3C
OP_JMP		.equ	$3E
OP_JSR		.equ	$40
OP_LDA		.equ	$42
OP_LDX		.equ	$44
OP_LDY		.equ	$46
OP_LSR		.equ	$48
OP_NOP		.equ	$4A
OP_ORA		.equ	$4C
OP_PHA		.equ	$4E
OP_PHP		.equ	$50
		.if	__65C02__|__65SC02__
OP_PHX		.equ	$52
OP_PHY		.equ	$54
		.endif
OP_PLA		.equ	$56
OP_PLP		.equ	$58
		.if	__65C02__|__65SC02__
OP_PLX		.equ	$5A
OP_PLY		.equ	$5C
		.endif
		.if	__65C02__
OP_RMB		.equ	$5E
		.endif
OP_ROL		.equ	$60
OP_ROR		.equ	$62
OP_RTI		.equ	$64
OP_RTS		.equ	$66
OP_SBC		.equ	$68
OP_SEC		.equ	$6A
OP_SED		.equ	$6C
OP_SEI		.equ	$6E
		.if	__65C02__
OP_SMB		.equ	$70
		.endif
OP_STA		.equ	$72
		.if	__65C02__|__65SC02__
OP_STP		.equ	$74
		.endif
OP_STX		.equ	$76
OP_STY		.equ	$78
		.if	__65C02__|__65SC02__
OP_STZ		.equ	$7A
		.endif
OP_TAX		.equ	$7C
OP_TAY		.equ	$7E
		.if	__65C02__|__65SC02__
OP_TRB		.equ	$80
OP_TSB		.equ	$82
		.endif
OP_TSX		.equ	$84
OP_TXA		.equ	$86
OP_TXS		.equ	$88
OP_TYA		.equ	$8A
		.if	__65C02__|__65SC02__
OP_WAI		.equ	$8C
		.endif

; Bit patterns for addressing modes

MB_IND		.equ	%10000000
MB_REL		.equ	%01000000
MB_BIT		.equ	%00100000

MB_IMP		.equ	%00000000
MB_ZPG		.equ	%00000001
MB_IMM		.equ	%00000010
MB_ABS		.equ	%00000011

MB_ACC		.equ	%00010000
MB_XRG		.equ	%00001000
MB_YRG		.equ	%00000100

; Addressing modes

		.if	__65C02__
MO_BIT		.equ	MB_BIT	     |MB_ZPG
MO_BRL		.equ	MB_BIT|MB_REL|MB_ZPG
		.endif
MO_ACC		.equ	       MB_ACC|MB_IMP
MO_IMP		.equ		      MB_IMP
MO_IMM		.equ		      MB_IMM
MO_REL		.equ		      MB_REL
MO_ZPG		.equ		      MB_ZPG
MO_ZPX		.equ	       MB_XRG|MB_ZPG
MO_ZPY		.equ	       MB_YRG|MB_ZPG
		.if	__65C02__|__65SC02__
MO_IZP		.equ	MB_IND	     |MB_ZPG
		.endif
MO_IZX		.equ	MB_IND|MB_XRG|MB_ZPG
MO_IZY		.equ	MB_IND|MB_YRG|MB_ZPG
MO_ABS		.equ		      MB_ABS
MO_ABX		.equ	       MB_XRG|MB_ABS
MO_ABY		.equ	       MB_YRG|MB_ABS
MO_IAB		.equ	MB_IND	     |MB_ABS
		.if	__65C02__|__65SC02__
MO_IAX		.equ	MB_IND|MB_XRG|MB_ABS
		.endif

;===============================================================================
; Macros
;-------------------------------------------------------------------------------

; The MNEM macro compresses three characters into a 16-bit value.

MNEM		.macro	CH1,CH2,CH3
		.word	((((CH3 & $1f) << 5)|(CH2 & $1f)) << 5)|(CH1 & $1f)
		.endm

;===============================================================================
; Data Areas
;-------------------------------------------------------------------------------

		.page0
		.org	$00f0

A_REG		.space	1			; Saved registers
X_REG		.space	1
Y_REG		.space	1
P_REG		.space	1
PC_REG		.space	2

CMD_LEN		.space	1			; Command buffer length
ADDR_S		.space	2
ADDR_E		.space	2

TEMP		.space	2
COUNT		.space	1

;-------------------------------------------------------------------------------

IRQV		.equ	$7e70		; Vectors
NMIV		.equ	$7e72

;===============================================================================
; UART Buffers
;-------------------------------------------------------------------------------

		.bss
		.org	$0200

CMD_SIZE	.equ	128

COMMAND		.space	CMD_SIZE	; Command buffer area

;===============================================================================
; Compressed Mnemonics
;-------------------------------------------------------------------------------

		.code
		
		jmp	RESET

MNEMONICS:
		MNEM    '?','?','?'
		MNEM    'A','D','C'
		MNEM    'A','N','D'
		MNEM    'A','S','L'
		MNEM    'B','B','R'
		MNEM    'B','B','S'
		MNEM    'B','C','C'
		MNEM    'B','C','S'
		MNEM    'B','E','Q'
		MNEM    'B','I','T'
		MNEM    'B','M','I'
		MNEM    'B','N','E'
		MNEM    'B','P','L'
		MNEM    'B','R','A'
		MNEM    'B','R','K'
		MNEM    'B','V','C'
		MNEM    'B','V','S'
		MNEM    'C','L','C'
		MNEM    'C','L','D'
		MNEM    'C','L','I'
		MNEM    'C','L','V'
		MNEM    'C','M','P'
		MNEM    'C','P','X'
		MNEM    'C','P','Y'
		MNEM    'D','E','C'
		MNEM    'D','E','X'
		MNEM    'D','E','Y'
		MNEM    'E','O','R'
		MNEM    'I','N','C'
		MNEM    'I','N','X'
		MNEM    'I','N','Y'
		MNEM    'J','M','P'
		MNEM    'J','S','R'
		MNEM    'L','D','A'
		MNEM    'L','D','X'
		MNEM    'L','D','Y'
		MNEM    'L','S','R'
		MNEM    'N','O','P'
		MNEM    'O','R','A'
		MNEM    'P','H','A'
		MNEM    'P','H','P'
		MNEM    'P','H','X'
		MNEM    'P','H','Y'
		MNEM    'P','L','A'
		MNEM    'P','L','P'
		MNEM    'P','L','X'
		MNEM    'P','L','Y'
		MNEM    'R','M','B'
		MNEM    'R','O','L'
		MNEM    'R','O','R'
		MNEM    'R','T','I'
		MNEM    'R','T','S'
		MNEM    'S','B','C'
		MNEM    'S','E','C'
		MNEM    'S','E','D'
		MNEM    'S','E','I'
		MNEM    'S','M','B'
		MNEM    'S','T','A'
		MNEM    'S','T','P'
		MNEM    'S','T','X'
		MNEM    'S','T','Y'
		MNEM    'S','T','Z'
		MNEM    'T','A','X'
		MNEM    'T','A','Y'
		MNEM    'T','R','B'
		MNEM    'T','S','B'
		MNEM    'T','S','X'
		MNEM    'T','X','A'
		MNEM    'T','X','S'
		MNEM    'T','Y','A'
		MNEM    'W','A','I'

;===============================================================================
; Power On Reset
;-------------------------------------------------------------------------------

RESET:
		sei
		cld			; Ensure binary mode

		ldx	#$ff		; Reset the stack
		txs

		repeat			; Setup vectors
		 lda	VECTORS,x
		 sta	IRQV,x
		 inx
		 cpx	#4
		until eq

		jsr	NewLine
		ldx	#TTL_STR
		jsr	ShowString
		jsr	NewLine

		repeat
		 brk	#0		; And enter monitor
		forever

;-------------------------------------------------------------------------------

VECTORS:	.word	IRQ		; Default vectors
		.word	NMI

;===============================================================================
; Entry Point
;-------------------------------------------------------------------------------

BRK:
		pla			; Pull off saved registers
		sta	Y_REG
		pla
		sta	X_REG
		pla
		sta	A_REG
		pla
		sta	P_REG
		sec			; Move PC back to BRK
		pla
		sbc	#2
		sta	PC_REG+0
		pla
		sbc	#0
		sta	PC_REG+1

	;	cli			; Allow interrupts

;===============================================================================
; Show Registers
;-------------------------------------------------------------------------------

ShowRegisters:
		jsr	NewLine
		ldx	#PC_STR		; Display the PC
		jsr	ShowString
		lda	PC_REG+1
		jsr	ShowHex2
		lda	PC_REG+0
		jsr	ShowHex2

		tsx
		jsr	DumpRegisters

;===============================================================================
; Command Line
;-------------------------------------------------------------------------------

NewCommand:
		.if	__65C02__|__65SC02__
		stz	CMD_LEN		; Mark the buffer as empty
		.else
		lda	#0		; Mark the buffer as empty
		sta	CMD_LEN
		.endif

RptCommand:
		jsr	NewLine		; Move cursor to next line
		lda	#'.'		; And output the prompt
		jsr	UartTx

		ldx	#0		; Output prepared command
		repeat
		 cpx	CMD_LEN		; Any saved characters to display?
		 break	cs		; No
		 lda	COMMAND,x	; Yes, print from the buffer
		 jsr	UartTx
		 inx
		forever

		lda	#DC1		; Send XON
		jsr	UartTx
		repeat
		 jsr	UartRx		; Wait for some user input
		 sta	COMMAND,x

		 cmp	#CR		; End of input?
		 break eq
		 cmp	#LF		; Ignore LF
		 continue eq

		 cmp 	#ESC		; Cancel input?
		 if 	eq
		  beq	NewCommand	; Yes
		 endif

		 cmp	#DEL		; Turn a delete
		 if 	eq
		  lda	#BS		; .. into a backspace
		 endif

		 cmp	#BS		; Handle backspace
		 if 	eq
		  cpx   #0
		  if 	ne
		   pha
		   jsr	UartTx
		   jsr	Space
		   pla
		   jsr	UartTx
		   dex
		  endif
		  continue
		 endif

		 cmp	#' '		; Beep if non-printable
		 if 	cc
		  lda	#BEL
		  jsr	UartTx
		  continue
		 endif

		 jsr	UartTx		; Otherwise echo to screen
		 inx			; And bump counter
		forever

		stx	CMD_LEN		; Save the command length
		lda	#DC3		; Send XOFF
		jsr	UartTx

		ldx	#0		; Set character offset to start
		jsr	SkipSpaces	; And get first character
		bcs	NewCommand

		cmp	#CR		; Empty line?
		beq	NewCommand	; Yes

;===============================================================================
; 'D' - Disassemble Memory
;-------------------------------------------------------------------------------

		cmp	#'D'
		if	eq
		 jsr	GetWord
		 if	cc
		  jsr	SetStartAddr
		  jsr	SetEndAddr
		  jsr	GetWord
		  if	cc
		   jsr	SetEndAddr
		  else
		   inc	ADDR_E+1
		  endif

		  repeat
		   jsr	NewLine		; Print the memory address
		   lda	ADDR_S+1
		   jsr	ShowHex2
		   lda	ADDR_S+0
		   jsr	ShowHex2

		   jsr	Disassemble
		   jsr	BumpAddr
		   break cs
		   jsr	CheckEnd
		  until	cs
		  jmp	NewCommand
		 endif
		 jmp	Error
		endif

;===============================================================================
; 'F' - Fill
;-------------------------------------------------------------------------------

		cmp	#'F'
		if	eq
		 jsr	GetWord		; Extract start address
		 if cc
		  jsr	SetStartAddr
		  jsr	GetWord		; Extract end address
		  bcs	.FillFail
		  jsr	SetEndAddr
		  jsr	GetByte		; Extract fill byte
		  bcs	.FillFail

		  repeat
		   ldy	#0		; Perform the fill
		   lda	TEMP+0
		   sta 	(ADDR_S),y

		   iny
		   tya
		   jsr	BumpAddr	; Until the end
		   break cs
		   jsr	CheckEnd
		  until cs
		 else
.FillFail:	  jmp	Error
		 endif
		 jmp	NewCommand
		endif

;===============================================================================
; 'G' - Go
;-------------------------------------------------------------------------------

		cmp	#'G'
		if	eq
		 jsr	GetWord		; Extract start address
		 if cc
		  lda	TEMP+1
		  pha
		  lda	TEMP+0
		  pha
		 else
		  lda	PC_REG+1	; Push the target address
		  pha
		  lda	PC_REG+0
		  pha
		 endif

		 lda	#DC1		; Send XON
		 jsr	UartTx

		 lda	P_REG		; And status flags
		 pha
		 lda	A_REG		; Reload A, X and Y
		 ldx	X_REG
		 ldy	Y_REG
		 rti			; Then go to code
		endif

;===============================================================================
; 'M' - Show Memory
;-------------------------------------------------------------------------------

		cmp	#'M'
		if	eq
		 jsr	GetWord		; Extract start address
		 if	cc
		  jsr	SetStartAddr
		  jsr	SetEndAddr
		  jsr	GetWord		; Extract end address
		  if	cc
		   jsr	SetEndAddr
		  else
		   inc	ADDR_E+1	; Or default to start + 256
		  endif

		  repeat
		   jsr	NewLine		; Print the memory address
		   lda	ADDR_S+1
		   jsr	ShowHex2
		   lda	ADDR_S+0
		   jsr	ShowHex2

		   ldy	#0		; Dump 16 bytes of data
		   repeat
		    jsr	Space
		    lda	(ADDR_S),Y
		    iny
		    jsr	ShowHex2
		    cpy #16
		   until eq

		   jsr	Space		; Then show as characters
		   jsr	Bar
		   ldy	#0
		   repeat
		    lda	(ADDR_S),Y
		    iny
		    jsr	IsPrintable
		    if 	cc
		     lda #'.'
		    endif
		    jsr	UartTx
		    cpy	#16
		   until eq
		   jsr	Bar

		   tya
		   jsr	BumpAddr
		   break cs
		   jsr	CheckEnd
		  until	cs
		  jmp	NewCommand
		 endif
		 jmp	Error
		endif

;===============================================================================
; 'R' - Show Registers
;-------------------------------------------------------------------------------

		cmp	#'R'
		if	eq
		 jmp	ShowRegisters
		endif

;===============================================================================
; 'S' - S19 Record Loader
;-------------------------------------------------------------------------------

		cmp	#'S'
		if	eq
		 jsr	NextChar
		 cmp	#'1'		; Data record?
		 if 	eq
		  jsr	GetByte		; Extract length
		  bcs	.S19Fail
		  sta	ADDR_E+0
		  jsr	GetWord		; Extract address
		  bcs	.S19Fail
		  jsr	SetStartAddr
		  dec	ADDR_E+0	; Reduce count
		  dec	ADDR_E+0
		  dec	ADDR_E+0

		  ldy	#0
		  sty	ADDR_E+1
		  repeat
		   jsr	GetByte		; Extract data byte
		   bcs	.S19Fail
		   ldy	ADDR_E+1	; And save
		   lda	TEMP+0
		   sta	(ADDR_S),y
		   inc	ADDR_E+1
		   dec	ADDR_E+0	; Until line processed
		  until eq
		 else
		  cmp	#'9'
		  if 	eq
		   jsr	GetByte		; Extract length
		   bcs	.S19Fail
		   jsr	GetWord		; Extract start address
		   bcs	.S19Fail
		   lda	TEMP+0		; Copy to PC
		   sta	PC_REG+0
		   lda	TEMP+1
		   sta 	PC_REG+1
		  else
.S19Fail:	   jmp	Error
		  endif
		 endif
		 jmp	NewCommand
		endif

;===============================================================================
; 'T' - Trace
;-------------------------------------------------------------------------------

		cmp	#'T'
		if eq
		 jsr	GetWord		; Extract start address
		 if cc
		  ldy	TEMP+0		; And overwrite PC
		  sty	PC_REG+0
		  ldy	TEMP+1
		  sty	PC_REG+1
		 endif

		 cmp	#','
		 sec
		 if eq
		  jsr	GetWord		; Extract count
		 endif
		 if cs
		  ldy	#1		; Default one step
		  sty	TEMP+0
		  dey
		  sty	TEMP+1
		 endif

Trace:
		 jsr	NewLine		; Show the current PC
		 lda	PC_REG+1
		 sta	ADDR_S+1
		 jsr	ShowHex2
		 lda	PC_REG+0
		 sta	ADDR_S+0
		 jsr	ShowHex2

		 jsr	Disassemble	; Disassembly opcode
		 repeat
		  cpx	#16		; .. justify output
		  break cs
		  jsr	Space
		  inx
		 forever
		 tsx
		 jsr	DumpRegisters	; .. and show registers

		 lda	#<A_REG		; Assume accumulator is target
		 sta	ADDR_S+0
		 lda	#>A_REG
		 sta	ADDR_S+1

		 ldy	#0
		 lda	(PC_REG),y	; Fetch the next opcode
		 inc	PC_REG+0	; .. and bump PC
		 if eq
		  inc	PC_REG+1
		 endif
		 tax
		 lda	MODES,X		; Extract address type
		 and	#MB_ABS
		 cmp	#MB_ZPG		; Zero page?
		 if eq
		  lda	(PC_REG),y
		  sta	ADDR_S+0
		  sty	ADDR_S+1
		  inc 	PC_REG+0
		  if eq
		   inc	PC_REG+1
		  endif
		 else
		  cmp	#MB_ABS		; Absolute ?
		  if eq
		   lda	(PC_REG),y
		   sta	ADDR_S+0
		   inc 	PC_REG+0
		   if eq
		    inc	PC_REG+1
		   endif
		   lda	(PC_REG),y
		   sta	ADDR_S+1
		   inc 	PC_REG+0
		   if eq
		    inc	PC_REG+1
		   endif
		  else
		   cmp	#MB_IMM		; Immediate?
		   if eq
		    lda	PC_REG+0
		    sta	ADDR_S+0
		    lda	PC_REG+1
		    sta	ADDR_S+1
		    inc PC_REG+0
		    if eq
		     inc PC_REG+1
		    endif
		   endif
		  endif
		 endif

		 lda	#MB_XRG		; Handle X index
		 and	MODES,x
		 if ne
		  clc
		  lda	X_REG
		  adc	ADDR_S+0
		  sta	ADDR_S+0
		  if cs
		   inc	ADDR_S+1
		  endif

		  lda	#MO_ZPX		; Force wrap around for ZPG,X
		  cmp	MODES,x
		  if eq
		   sty	ADDR_S+1
		  endif

		  lda	#MO_IZX		; .. and (ZPG,X)
		  cmp	MODES,x
		  if eq
		   sty	ADDR_S+1
		  endif
		 endif

		 lda	#MB_IND		; Handle indirection
		 and 	MODES,x
		 if ne
		  lda	(ADDR_S),y	; Fetch low byte of target
		  pha

		.if	__65C02__|__65SC02__
		  cpx	#$6C		; JMP (abs)?
		  if ne
		   cpx	#$7C		; or JMP (abs,X)?
		  endif
		  if eq
		   inc	ADDR_S+0	; 65C02 increments properly
		   if eq
		    inc ADDR_S+1
		   endif
		  else
		   inc	ADDR_S+0	; Otherwise just the low byte
		  endif
		.else
		  inc	ADDR_S+0	; 6502 bumps just the low byte
		.endif

		  lda	(ADDR_S),y	; Fetch high byte of target
		  sta	ADDR_S+1	; And save indirect address
		  pla
		  sta	ADDR_S+0
		 endif

		 lda	#MB_YRG		; Handle Y index
		 and	MODES,x
		 if ne
		  clc
		  lda	Y_REG
		  adc	ADDR_S+0
		  sta	ADDR_S+0
		  if cs
		   inc	ADDR_S+1
		  endif

		  lda	#MB_ZPG		; Restrict to zero page
		  and	MODES,x
		  if ne
		   ldy	ADDR_S+1
		  endif
		 endif

		 lda	#MB_REL		; Relative address?
		 and	MODES,x
		 if ne
		  lda	(PC_REG),y
		  if mi
		   dey
		  endif
		  inc	PC_REG+0
		  if eq
		   inc	PC_REG+1
		  endif
		  clc
		  adc	PC_REG+0
		  sta	ADDR_E+0
		  tya
		  adc	PC_REG+1
		  sta	ADDR_E+1
		 endif

		 ldy	OPCODES,x	; Recover the opcode index
		 lda	EMULATE+1,y
		 pha
		 lda	EMULATE+0,y
		 pha
		 ldy	#0
		 lda	P_REG		; Restore status flags
		 pha
		 lda	A_REG		; .. and A
		 plp
		 rts			; Go to emulation code

EMULATE:
		.word	EM_ERR-1
		.word	EM_ADC-1
		.word	EM_AND-1
		.word	EM_ASL-1
		.word	EM_BBR-1
		.word	EM_BBS-1
		.word	EM_BCC-1
		.word	EM_BCS-1
		.word	EM_BEQ-1
		.word	EM_BIT-1
		.word	EM_BMI-1
		.word	EM_BNE-1
		.word	EM_BPL-1
		.word	EM_BRA-1
		.word	EM_BRK-1
		.word	EM_BVC-1
		.word	EM_BVS-1
		.word	EM_CLC-1
		.word	EM_CLD-1
		.word	EM_CLI-1
		.word	EM_CLV-1
		.word	EM_CMP-1
		.word	EM_CPX-1
		.word	EM_CPY-1
		.word	EM_DEC-1
		.word	EM_DEX-1
		.word	EM_DEY-1
		.word	EM_EOR-1
		.word	EM_INC-1
		.word	EM_INX-1
		.word	EM_INY-1
		.word	EM_JMP-1
		.word	EM_JSR-1
		.word	EM_LDA-1
		.word	EM_LDX-1
		.word	EM_LDY-1
		.word	EM_LSR-1
		.word	EM_NOP-1
		.word	EM_ORA-1
		.word	EM_PHA-1
		.word	EM_PHP-1
		.word	EM_PHX-1
		.word	EM_PHY-1
		.word	EM_PLA-1
		.word	EM_PLP-1
		.word	EM_PLX-1
		.word	EM_PLY-1
		.word	EM_RMB-1
		.word	EM_ROL-1
		.word	EM_ROR-1
		.word	EM_RTI-1
		.word	EM_RTS-1
		.word	EM_SBC-1
		.word	EM_SEC-1
		.word	EM_SED-1
		.word	EM_SEI-1
		.word	EM_SMB-1
		.word	EM_STA-1
		.word	EM_STP-1
		.word	EM_STX-1
		.word	EM_STY-1
		.word	EM_STZ-1
		.word	EM_TAX-1
		.word	EM_TAY-1
		.word	EM_TRB-1
		.word	EM_TSB-1
		.word	EM_TSX-1
		.word	EM_TXA-1
		.word	EM_TXS-1
		.word	EM_TYA-1
		.word	EM_WAI-1

;-------------------------------------------------------------------------------

EM_CLC:
		 clc
		 jmp	SaveP

EM_CLD:
		 cld
		 jmp	SaveP

EM_CLI:
		 cli
		 jmp	SaveP

EM_CLV:
		 clv
		 jmp	SaveP

EM_SEC:
		 sec
		 jmp	SaveP

EM_SED:
		 sed
		 jmp	SaveP

EM_SEI:
		 sei
		 jmp	SaveP

;-------------------------------------------------------------------------------

EM_ADC:
		 adc 	(ADDR_S),y
		 jmp	SaveAP

EM_SBC:
		 sbc 	(ADDR_S),y
		 jmp	SaveAP

;-------------------------------------------------------------------------------

EM_CPX:
		 lda	X_REG
		 .byte	$2c		; BIT trick

EM_CPY:
		 lda	Y_REG

EM_CMP:
		 cmp	(ADDR_S),y
		 jmp	SaveP

;-------------------------------------------------------------------------------

EM_AND:
		 and	(ADDR_S),y
		 jmp	SaveAP

EM_EOR:
		 eor	(ADDR_S),y
		 jmp	SaveAP

EM_ORA:
		 ora	(ADDR_S),y
		 jmp	SaveAP

EM_BIT:
		.if 	__65C02__|__65SC02__
		 cpx	#$89		; Immediate does not affect NV
		 if ne
		  pha
		  lda	(ADDR_S),y	; Extract NV bits from value
		  eor	P_REG
		  and	#$c0
		  eor	P_REG
		  sta	P_REG
		  pla
		 endif
		.endif
		 and	(ADDR_S),y	; Handle Z flag
		 php
		 pla
		 eor	P_REG
		 and	#$02
		 eor	P_REG
		 sta	P_REG
		 jmp	SaveNone

;-------------------------------------------------------------------------------

EM_ASL:
		 lda	(ADDR_S),y
		 asl	a
		 sta	(ADDR_S),y
		 jmp	SaveP

EM_LSR:
		 lda	(ADDR_S),y
		 lsr	a
		 sta	(ADDR_S),y
		 jmp	SaveP

EM_ROL:
		 lda	(ADDR_S),y
		 rol	a
		 sta	(ADDR_S),y
		 jmp	SaveP

EM_ROR:
		 lda	(ADDR_S),y
		 ror	a
		 sta	(ADDR_S),y
		 jmp	SaveP

;-------------------------------------------------------------------------------

EM_DEC:
		 lda	(ADDR_S),y
		 tax
		 dex
		 txa
		 sta	(ADDR_S),y
		 jmp	SaveP

EM_DEX:
		 dec 	X_REG
		 jmp	SaveP

EM_DEY:
		 dec	Y_REG
		 jmp	SaveP

EM_INC:
		 lda	(ADDR_S),y
		 tax
		 inx
		 txa
		 sta	(ADDR_S),y
		 jmp	SaveP

EM_INX:
		 inc	X_REG
		 jmp	SaveP

EM_INY:
		 inc	Y_REG
		 jmp	SaveP

;-------------------------------------------------------------------------------

EM_BCC:
		 bcc	EM_BRA
		 jmp	SaveNone

EM_BCS:
		 bcs	EM_BRA
		 jmp	SaveNone

EM_BEQ:
		 beq	EM_BRA
		 jmp	SaveNone

EM_BMI:
		 bmi	EM_BRA
		 jmp	SaveNone

EM_BNE:
		 bne	EM_BRA
		 jmp	SaveNone

EM_BPL:
		 bpl	EM_BRA
		 jmp	SaveNone

EM_BRA:
		 lda	ADDR_E+0
		 sta	PC_REG+0
		 lda	ADDR_E+1
		 sta	PC_REG+1
		 jmp	SaveNone

EM_BVC:
		 bvc	EM_BRA
		 jmp	SaveNone

EM_BVS:
		 bvs	EM_BRA
		 jmp	SaveNone

;-------------------------------------------------------------------------------

EM_JSR:
		 lda	PC_REG+0	; Back up
		 if eq
		  dec 	PC_REG+1
		 endif
		 dec	PC_REG+0
		 lda	PC_REG+1	; And push PC
		 pha
		 lda	PC_REG+0
		 pha

EM_JMP:
		 lda	ADDR_S+0	; Set PC to target address
		 sta 	PC_REG+0
		 lda	ADDR_S+1
		 sta	PC_REG+1
		 jmp	SaveNone

;-------------------------------------------------------------------------------

EM_LDA:
		 lda	(ADDR_S),y
		 jmp	SaveAP

EM_LDX:
		 lda	(ADDR_S),y
		 sta	X_REG
		 jmp	SaveP

EM_LDY:
		 lda	(ADDR_S),y
		 sta	Y_REG
		 jmp	SaveP

EM_STA:
		 sta 	(ADDR_S),y
		 jmp	SaveNone

EM_STX:
		 lda	X_REG
		 JMP	EM_STA

EM_STY:
		 lda 	Y_REG
		 jmp	EM_STA

EM_STZ:
		 lda	#0
		 jmp	EM_STA

;-------------------------------------------------------------------------------

EM_PHA:
		 pha
		 jmp	SaveNone

EM_PHP:
		 lda	P_REG
		 pha
		 jmp	SaveNone

EM_PHX:
		 lda	X_REG
		 pha
		 jmp	SaveNone

EM_PHY:
		 lda	Y_REG
		 pha
		 jmp	SaveNone

EM_PLA:
		 pla
		 jmp	SaveAP

EM_PLP:
		 pla
		 ora	#$30
		 sta	P_REG
		 jmp	SaveNone

EM_PLX:
		 pla
		 sta	X_REG
		 jmp	SaveP

EM_PLY:
		 pla
		 sta	Y_REG
		 jmp	SaveP

;-------------------------------------------------------------------------------

EM_NOP:
		 jmp	SaveNone

;-------------------------------------------------------------------------------

EM_BRK:
		 php
		 pla
		 ora	#(1<<2)		; Set interrupt disable bit
		 pha
		 lda	PC_REG+1	; Push instruction address
		 pha
		 lda	PC_REG+0
		 pha
		 lda	$fffe		; Load vector address
		 sta	PC_REG+0
		 lda	$ffff
		 sta	PC_REG+1
		 jmp 	SaveNone

EM_RTI:
		 pla
		 sta	PC_REG+0
		 pla
		 sta	PC_REG+1
		 pla
		 ora	#$30
		 sta	P_REG
		 jmp	SaveNone

EM_RTS:
		 pla
		 sta	PC_REG+0
		 pla
		 sta	PC_REG+1
		 inc	PC_REG+0
		 if eq
		  inc	PC_REG+1
		 endif
		 jmp	SaveNone

EM_STP:
		 jmp	SaveNone

EM_WAI:
		 jmp	SaveNone

;-------------------------------------------------------------------------------

EM_TAX:
		 lda	A_REG
		 sta	X_REG
		 jmp	SaveP

EM_TAY:
		 lda	A_REG
		 sta	Y_REG
		 jmp	SaveP

EM_TSX:
		 tsx
		 stx	X_REG
		 jmp	SaveP

EM_TXA:
		 lda	X_REG
		 jmp	SaveAP

EM_TXS:
		 ldx	X_REG
		 txs
		 jmp	SaveNone

EM_TYA:
		 lda	Y_REG
		 jmp	SaveAP

;-------------------------------------------------------------------------------

EM_BBR:
		 txa			; Get bit number
		 and	#$70
		 lsr	a
		 lsr	a
		 lsr	a
		 lsr	a
		 tax
		 lda	BITS,x		; Map to bit mask
		 and	(ADDR_S),y	; And test value
		 bne	SaveNone
		 jmp	EM_BRA

EM_BBS:
		 txa			; Get bit number
		 and	#$70
		 lsr	a
		 lsr	a
		 lsr	a
		 lsr	a
		 tax
		 lda	BITS,x		; Map to bit mask
		 and	(ADDR_S),y	; And test value
		 beq	SaveNone
		 jmp	EM_BRA

EM_RMB:
		 txa			; Get bit number
		 and	#$70
		 lsr	a
		 lsr	a
		 lsr	a
		 lsr	a
		 tax
		 lda	MASK,x		; Map to bit mask
		 and	(ADDR_S),y
		 sta	(ADDR_S),y
	 	 jmp	SaveNone

EM_SMB:
		 txa			; Get bit number
		 and	#$70
		 lsr	a
		 lsr	a
		 lsr	a
		 lsr	a
		 tax
		 lda	BITS,x		; Map to bit mask
		 ora	(ADDR_S),y
		 sta	(ADDR_S),y
		 jmp	SaveNone

EM_TRB:
		 pha
		 and	(ADDR_S),Y
		 php
		 pla
		 eor	P_REG
		 and	#1<<1
		 eor	P_REG
		 sta	P_REG
		 pla
		 eor	#$ff
		 and	(ADDR_S),y
		 sta	(ADDR_S),y
		 jmp	SaveNone

EM_TSB:
		 pha
		 and	(ADDR_S),Y
		 php
		 pla
		 eor	P_REG
		 and	#1<<1
		 eor	P_REG
		 sta	P_REG
		 pla
		 ora	(ADDR_S),y
		 sta	(ADDR_S),y
		 jmp	SaveNone

;-------------------------------------------------------------------------------

SaveAP:
		 sta	A_REG		; Save the updated A
SaveP:
		 php			; Save the updated flags
		 pla
		 sta	P_REG
SaveNone:
		 lda	TEMP+0		; Repeat as instructed
		 if eq
		  dec	TEMP+1
		 endif
		 dec	TEMP+0

		 lda	TEMP+0
		 ora	TEMP+1
		 if ne
		  jmp	Trace
		 endif

EM_ERR:
		 jmp	NewCommand
		endif

;===============================================================================
; 'W' - Write Memory
;-------------------------------------------------------------------------------

		cmp	#'W'
		if	eq
		 jsr	GetWord		; Get the target address
		 if	cc
		  jsr	SetStartAddr	; Copy to start address
		  jsr	GetByte		; Get the value
		  if	cc
		   ldy	#0		; Write to memory
		   lda	TEMP+0
		   sta	(ADDR_S),Y
		   lda	#1		; Increment address
		   jsr	BumpAddr
		   lda	#'W'		; Create prompt for next byte
		   jmp	SetPrompt
		  endif
		 endif
		 jmp	Error		; Handle syntax errors
		endif

;===============================================================================
; '?' - Display Help
;-------------------------------------------------------------------------------

		cmp	#'?'
		if	eq
		 ldx	#HLP_STR
		else
Error:		 ldx	#ERR_STR
		endif
		jsr	ShowString
		jmp	NewCommand

;===============================================================================
;-------------------------------------------------------------------------------

SetStartAddr:
		lda	TEMP+0
		sta	ADDR_S+0
		lda	TEMP+1
		sta	ADDR_S+1
		rts

SetEndAddr:
		lda	TEMP+0
		sta	ADDR_E+0
		lda	TEMP+1
		sta	ADDR_E+1
		rts

BumpAddr:
		clc
		adc	ADDR_S+0
		sta	ADDR_S+0
		lda	#0
		adc	ADDR_S+1
		sta	ADDR_S+1
		rts

CheckEnd:
		lda	ADDR_S+1
		cmp	ADDR_E+1
		if 	cs
		 if 	eq
		  lda	ADDR_S+0
		  cmp	ADDR_E+0
		 endif
		endif
		rts

; Create a prompt string in the command buffer for the command in A using the
; current value of the starting address.

SetPrompt:
		ldx	#0		; Clear buffer and add command letter
		jsr	AppendChar
		lda	#' '		; Then a space
		jsr	AppendChar

		lda	ADDR_S+1	; Followed by the address
		jsr	AppendHex2
		lda	ADDR_S+0
		jsr	AppendHex2
		lda	#' '		; And another space
		jsr	AppendChar
		jmp	RptCommand	; Then output it

; Convert the byte in A into hexadecimal digits and append to the command buffer.

AppendHex2:
		pha
		lsr	a
		lsr	a
		lsr	a
		lsr	a
		jsr	AppendHex
		pla
AppendHex:
		jsr	ToHex

; Append the character in A to the command buffer to create the next prompt
; string.

AppendChar:
		sta	COMMAND,x
		inx
		stx	CMD_LEN
		rts

;===============================================================================
; Parsing Utilities
;-------------------------------------------------------------------------------

; Get the next characater from the command buffer indicated by the X register
; and convert it to UPPER case. If the carry is set then the end of the buffer
; has been reached.

NextChar:
		cpx	CMD_LEN		; Reached end of buffer>
		if 	cs
		 lda	#0
		 rts			; Yes, return with C=1
		endif
		lda	COMMAND,X	; No, fetch a character
		inx

; Convert the character in A to upper case.

ToUpper:
		cmp	#'a'		; Between 'a'
		if 	cs
		 cmp	#'z'+1		; .. and 'z'?
		 if 	cc
		  and	#$5f		; Yes, convert
		 endif
		endif
		clc			; Ensure C=0
		rts

; Fetch the next characters from the command buffer ignoring spaces.

SkipSpaces:
		repeat
		 jsr	NextChar	; Fetch a character?
		 break 	cs		; Reached the end?
		 cmp	#' '		; A space to ignore?
		 clc
		until 	ne
		rts			; Done

; Parse a word from the command buffer and store it in TEMP. Return if the
; carry set if there is a syntax error.

GetWord:
		ldy	#4		; Set maximim number of nybbles
		bne	GetByte+2

; Parse a word from the command buffer and store it in TEMP. Return if the
; carry set if there is a syntax error.

GetByte:
		ldy	#2		; Set maximum number of nybble
		sty	COUNT

		.if	__65C02__|__65SC02__
		stz	TEMP+0		; Clear conversion area
		stz	TEMP+1
		.else
		ldy	#0
		sty	TEMP+0		; Clear conversion area
		sty	TEMP+1
		.endif

		jsr	SkipSpaces	; Fetch first character
		jsr	GetNybble	; And try to convert
		if	cs
		 rts			; Syntax error
		endif
		repeat
		 asl	TEMP+0		; Fold into the result
		 rol	TEMP+1
		 asl	TEMP+0
		 rol	TEMP+1
		 asl	TEMP+0
		 rol	TEMP+1
		 asl	TEMP+0
		 rol	TEMP+1
		 ora	TEMP+0
		 sta	TEMP+0

		 dec	COUNT		; Reach maximum length?
		 break	eq

		 jsr	NextChar	; Try for another nybble
		 jsr	GetNybble
		until 	cs
		clc			; Conversion sucessfull
		rts

; Try to parse a nybble from the command line. If not a valid hex digit then
; return with the carry set.

GetNybble:
		jsr	IsHex		; Got a hex digit?
		if	cs
		 cmp	#'A'		; Handle letters
		 if	cs
		  sbc	#7
		 endif
		 and	#$0f		; Strip out nybble
		 clc			; Done
		 rts
		endif
		sec			; Set carry -- not hex
		rts

; Return with the carry set of the character in A is a digit or 'A' thru 'F'.

IsHex:
		cmp	#'9'+1
		if 	cc
		 cmp	#'0'
		 rts
		endif
		cmp	#'F'+1
		if	cc
		 cmp	#'A'
		 rts
		endif
		clc
		rts

; Return with the carry set of the character in A is not printable.

IsPrintable:
		cmp	#' '
		if	cs
		 cmp	#DEL
		 if	CC
		  sec
		  rts
		 endif
		endif
		clc
		rts

;===============================================================================
; Register Dump
;-------------------------------------------------------------------------------

; Dump all the save registers and the SP which is passed in X

DumpRegisters:
		txa			; Save SP
		pha

		ldx	#A_STR		; Display A
		jsr	ShowString
		lda	A_REG
		jsr	ShowHex2

		ldx	#X_STR		; Display X
		jsr	ShowString
		lda	X_REG
		jsr	ShowHex2

		ldx	#Y_STR		; Display Y
		jsr	ShowString
		lda	Y_REG
		jsr	ShowHex2

		ldx	#P_STR		; Display P
		jsr	ShowString
		ldx	#7
		repeat
		 ldy	#'.'
		 lda	BITS,x
		 bit	P_REG
		 if	ne
		  ldy	FLAG,x
		 endif
		 tya
		 jsr	UartTx
		 dex
		until mi

		ldx	#SP_STR		; Display SP
		jsr	ShowString
		pla
		jmp	ShowHex2

;===============================================================================
; Disassembly
;-------------------------------------------------------------------------------

Disassemble:
		lda	TEMP+0		; Save temporary area
		pha
		lda	TEMP+1
		pha

		jsr	Space
		ldy	#0		; Fetch the opcode
		lda	(ADDR_S),y
		tax
		jsr	ShowHex2	; .. and display it

		jsr	Space
		lda	MODES,x		; Fetch the mode
		pha			; And save some copies
		pha
		and	#MB_REL|MB_ABS	; Show second byte if relative,
		if	ne		; .. zero page, immediate or absolute
		 iny
		 lda	(ADDR_S),y
		 jsr	ShowHex2
		else
		 jsr	Space2
		endif

		jsr	Space
		pla			; Show third byte
		.if	__65C02__
		cmp	#MO_BRL		; .. if bit relative
		beq	.Skip
		.endif
		and	#MB_ABS		; .. or absolute
		cmp	#MB_ABS
		if	eq
.Skip:		 iny
		 lda	(ADDR_S),y
		 jsr	ShowHex2
		else
		 jsr	Space2
		endif

		iny			; Save the byte count
		sty	COUNT

		jsr	Space
		ldy	#0		; Fetch the opcode
		lda	(ADDR_S),y
		tax
		lda	OPCODES,x
		tax
		lda	MNEMONICS+1,x
		sta	TEMP
		lda	MNEMONICS+0,x
		jsr	ExtractLetter
		jsr	ExtractLetter
		jsr	ExtractLetter
		jsr	Space
		ldx	#4

		.if	__65C02__
		pla
		pha
		and	#MB_BIT
		if	ne
		 ldy	#0
		 lda	(ADDR_S),y
		 and	#$70
		 lsr	a
		 lsr	a
		 lsr	a
		 lsr	a
		 ora	#'0'
		 jsr	UartTx
		 lda	#','
		 jsr	UartTx
		 inx
		 inx
		endif
		.endif

		pla			; Indirect mode?
		pha
		if	mi
		 lda	#'('
		 jsr	UartTx
		 inx
		endif

		pla			; Has an address?
		pha
		and	#MB_ABS
		if	ne
		 pha
		 cmp	#MB_IMM		; Immediate?
		 if	eq
		  lda	#'#'
		  jsr	UartTx
		  inx
		 endif
		 lda	#'$'
		 jsr	UartTx
		 inx
		 pla
		 cmp	#MB_ABS		; Absolute?
		 if	eq
		  ldy	#2
		  lda	(ADDR_S),y	; Show hi byte
		  jsr	ShowHex2
		  inx
		  inx
		 endif
		 ldy	#1
		 lda	(ADDR_S),y	; Then lo byte
		 jsr	ShowHex2
		 inx
		 inx
		endif

		.if	__65C02__
		pla
		pha
		and	#MB_BIT|MB_REL
		cmp	#MB_BIT|MB_REL
		if	eq
		 lda	#','
		 jsr	UartTx
		 inx
		endif
		.endif

		pla
		pha
		tay
		and	#MB_REL
		if	ne
		 lda	#'$'
		 jsr	UartTx
		 inx
		 tya
		 ldy	#1
		 and	#MB_BIT
		 if	ne
		  iny
		 endif

		 sec			; Word out address of next
		 tya			; .. instruction
		 adc	ADDR_S+0
		 sta	TEMP+0
		 lda	#0
		 adc	ADDR_S+1
		 sta	TEMP+1

		 clc			; Fetch offset
		 lda	(ADDR_S),y	; Work out lo byte
		 adc	TEMP+0
		 pha			; And save
		 lda	(ADDR_S),y
		 and	#$80
		 if	mi
		  lda	#$ff
		 endif
		 adc	TEMP+1		; Work out hi byte
		 jsr	ShowHex2	; And show result
		 inx
		 inx
		 pla
		 jsr	ShowHex2
		 inx
		 inx
		endif

		pla
		pha
		and	#MB_ACC
		if 	ne
		 lda	#'A'
		 jsr	UartTx
		 inx
		endif

		pla
		pha
		and	#MB_XRG
		if 	ne
		 lda	#','
		 jsr	UartTx
		 lda	#'X'
		 jsr	UartTx
		 inx
		 inx
		endif

		pla
		pha
		if	mi
		 lda	#')'
		 jsr	UartTx
		 inx
		endif

		pla
		and	#MB_YRG
		if 	ne
		 lda	#','
		 jsr	UartTx
		 lda	#'Y'
		 jsr	UartTx
		 inx
		 inx
		endif

		pla			; Restore temporary area
		sta	TEMP+1
		pla
		sta	TEMP+0

		lda	COUNT		; Return the number of bytes
		rts

ExtractLetter:
		pha
		and	#$1f
		ora	#'@'
		cmp	#$5f
		if	eq
		 lda	#'?'
		endif
		jsr	UartTx
		pla
		lsr	TEMP
		ror	a
		lsr	TEMP
		ror	a
		lsr	TEMP
		ror	a
		lsr	TEMP
		ror	a
		lsr	TEMP
		ror	a
		rts

;===============================================================================
; Display Utilities
;-------------------------------------------------------------------------------

; Display the byte in A as two hexadecimal digits. The values in A & Y are
; destroyed.

ShowHex2:
		pha			; Save a copy of the value
		lsr	a		; Shift down the hi nybble
		lsr	a
		lsr	a
		lsr	a
		jsr	ShowHex		; Convert and display
		pla			; Pull back value and ...

; Display the lo nybble of A as a hexadecimal digit. The values in A & Y are
; destroyed.

ShowHex:
		jsr	ToHex		; Convert to printable character
		jmp	UartTx		; And display.

; Convert the lo nybble of A to a hexadecimal digit.

ToHex		and	#$0f		; Isolate the lo nybble
		sed			; Convert to ASCII using BCD
		clc
		adc	#$90
		adc	#$40
		cld
		rts			; Done

;-------------------------------------------------------------------------------

; Output two spaces.

Space2:
		jsr	Space		; Print one space then drop into ..

; Output a single space. The values in A & Y are destroyed.

Space:
		lda	#' '
		jmp	UartTx

; Output a vertical bar character.

Bar:
		lda	#'|'
		jmp	UartTx

; Output a new line

NewLine:
		lda	#CR
		jsr	UartTx
		lda	#LF
		jmp	UartTx

;===============================================================================
; Strings
;-------------------------------------------------------------------------------

; Output the string in the string table starting at the offset in X until a
; null byte is reached.

ShowString:
		repeat
		 lda	STRINGS,x	; Fetch the next character
		 break	eq		; Reached the end?
		 jsr	UartTx		; No, display it
		 inx			; Bump the index
		forever
		rts			; Done.

STRINGS:
TTL_STR		.equ	.-STRINGS
		.byte	CR,LF,"W65C02SXB"
		.byte	" [20.10]",0
PC_STR		.equ	.-STRINGS
		.byte	"PC=",0
SP_STR		.equ	.-STRINGS
		.byte	" SP=",0
P_STR		.equ	.-STRINGS
		.byte	" P=",0
A_STR		.equ	.-STRINGS
		.byte	" A=",0
X_STR		.equ	.-STRINGS
		.byte	" X=",0
Y_STR		.equ	.-STRINGS
		.byte	" Y=",0
ERR_STR		.equ	.-STRINGS
		.byte	CR,LF,"?",0
HLP_STR		.equ	.-STRINGS
		.byte 	CR,LF,"D xxxx yyyy\t\tDisassemble"
		.byte	CR,LF,"F xxxx yyyy bb\t\tFill Memory"
		.byte	CR,LF,"G [xxxx]\t\tGoto"
		.byte	CR,LF,"M xxxx yyyy\t\tDisplay Memory"
		.byte	CR,LF,"R\t\t\tDisplay Registers"
		.byte	CR,LF,"S...\t\t\tS19 Load"
		.byte	CR,LF,"T [xxxx][,cccc]\t\tTrace"
		.byte	CR,LF,"W xxxx yy\t\tWrite Memory"
		.byte 	0

FLAG		.byte	"CZID11VN"
BITS		.byte	$01,$02,$04,$08,$10,$20,$40,$80
MASK		.byte	$fe,$fd,$fb,$f7,$ef,$df,$bf,$7f

;===============================================================================
; Instruction Lookup Tables
;-------------------------------------------------------------------------------

		.align	256

		.if	__6502__
OPCODES:
		.byte	OP_BRK,OP_ORA,OP_ERR,OP_ERR,OP_ERR,OP_ORA,OP_ASL,OP_ERR ; 0
		.byte	OP_PHP,OP_ORA,OP_ASL,OP_ERR,OP_ERR,OP_ORA,OP_ASL,OP_ERR
		.byte	OP_BPL,OP_ORA,OP_ERR,OP_ERR,OP_ERR,OP_ORA,OP_ASL,OP_ERR ; 1
		.byte	OP_CLC,OP_ORA,OP_INC,OP_ERR,OP_ERR,OP_ORA,OP_ASL,OP_ERR
		.byte	OP_JSR,OP_AND,OP_ERR,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_ERR ; 2
		.byte	OP_PLP,OP_AND,OP_ROL,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_ERR
		.byte	OP_BMI,OP_AND,OP_ERR,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_ERR ; 3
		.byte	OP_SEC,OP_AND,OP_DEC,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_ERR
		.byte	OP_RTI,OP_EOR,OP_ERR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_ERR ; 4
		.byte	OP_PHA,OP_EOR,OP_LSR,OP_ERR,OP_JMP,OP_EOR,OP_LSR,OP_ERR
		.byte	OP_BVC,OP_EOR,OP_ERR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_ERR ; 5
		.byte	OP_CLI,OP_EOR,OP_ERR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_ERR
		.byte	OP_RTS,OP_ADC,OP_ERR,OP_ERR,OP_ERR,OP_ADC,OP_ROR,OP_ERR ; 6
		.byte	OP_PLA,OP_ADC,OP_ROR,OP_ERR,OP_JMP,OP_ADC,OP_ROR,OP_ERR
		.byte	OP_BVS,OP_ADC,OP_ERR,OP_ERR,OP_ERR,OP_ADC,OP_ROR,OP_ERR ; 7
		.byte	OP_SEI,OP_ADC,OP_ERR,OP_ERR,OP_ERR,OP_ADC,OP_ROR,OP_ERR
		.byte	OP_ERR,OP_STA,OP_ERR,OP_ERR,OP_STY,OP_STA,OP_STX,OP_ERR ; 8
		.byte	OP_DEY,OP_BIT,OP_TXA,OP_ERR,OP_STY,OP_STA,OP_STX,OP_ERR
		.byte	OP_BCC,OP_STA,OP_ERR,OP_ERR,OP_STY,OP_STA,OP_STX,OP_ERR ; 9
		.byte	OP_TYA,OP_STA,OP_TXS,OP_ERR,OP_ERR,OP_STA,OP_ERR,OP_ERR
		.byte	OP_LDY,OP_LDA,OP_LDX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_ERR ; A
		.byte	OP_TAY,OP_LDA,OP_TAX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_ERR
		.byte	OP_BCS,OP_LDA,OP_ERR,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_ERR ; B
		.byte	OP_CLV,OP_LDA,OP_TSX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_ERR
		.byte	OP_CPY,OP_CMP,OP_ERR,OP_ERR,OP_CPY,OP_CMP,OP_DEC,OP_ERR ; C
		.byte	OP_INY,OP_CMP,OP_DEX,OP_ERR,OP_CPY,OP_CMP,OP_DEC,OP_ERR
		.byte	OP_BNE,OP_CMP,OP_ERR,OP_ERR,OP_ERR,OP_CMP,OP_DEC,OP_ERR ; D
		.byte	OP_CLD,OP_CMP,OP_ERR,OP_ERR,OP_ERR,OP_CMP,OP_DEC,OP_ERR
		.byte	OP_CPX,OP_SBC,OP_ERR,OP_ERR,OP_CPX,OP_SBC,OP_INC,OP_ERR ; E
		.byte	OP_INX,OP_SBC,OP_NOP,OP_ERR,OP_CPX,OP_SBC,OP_INC,OP_ERR
		.byte	OP_BEQ,OP_SBC,OP_ERR,OP_ERR,OP_ERR,OP_SBC,OP_INC,OP_ERR ; F
		.byte	OP_SED,OP_SBC,OP_ERR,OP_ERR,OP_ERR,OP_SBC,OP_INC,OP_ERR

MODES:
		.byte	MO_IMM,MO_IZX,MO_IMM,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_IMP ; 0
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; 1
		.byte	MO_IMP,MO_ABY,MO_ACC,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_ABS,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; 2
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPX,MO_IMP ; 3
		.byte	MO_IMP,MO_ABY,MO_ACC,MO_IMP,MO_ABX,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_IMP ; 4
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; 5
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_IMP ; 6
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_IAB,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; 7
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; 8
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPY,MO_IMP ; 9
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_IMP,MO_IMP
		.byte	MO_IMM,MO_IZX,MO_IMM,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; A
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPY,MO_IMP ; B
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_ABY,MO_IMP
		.byte	MO_IMM,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; C
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; D
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMM,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; E
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IMP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; F
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.endif

;-------------------------------------------------------------------------------

		.if	__65C02__
OPCODES:
		.byte	OP_BRK,OP_ORA,OP_ERR,OP_ERR,OP_TSB,OP_ORA,OP_ASL,OP_RMB ; 0
		.byte	OP_PHP,OP_ORA,OP_ASL,OP_ERR,OP_TSB,OP_ORA,OP_ASL,OP_BBR
		.byte	OP_BPL,OP_ORA,OP_ORA,OP_ERR,OP_TRB,OP_ORA,OP_ASL,OP_RMB ; 1
		.byte	OP_CLC,OP_ORA,OP_INC,OP_ERR,OP_TRB,OP_ORA,OP_ASL,OP_BBR
		.byte	OP_JSR,OP_AND,OP_ERR,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_RMB ; 2
		.byte	OP_PLP,OP_AND,OP_ROL,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_BBR
		.byte	OP_BMI,OP_AND,OP_AND,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_RMB ; 3
		.byte	OP_SEC,OP_AND,OP_DEC,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_BBR
		.byte	OP_RTI,OP_EOR,OP_ERR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_RMB ; 4
		.byte	OP_PHA,OP_EOR,OP_LSR,OP_ERR,OP_JMP,OP_EOR,OP_LSR,OP_BBR
		.byte	OP_BVC,OP_EOR,OP_EOR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_RMB ; 5
		.byte	OP_CLI,OP_EOR,OP_PHY,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_BBR
		.byte	OP_RTS,OP_ADC,OP_ERR,OP_ERR,OP_STZ,OP_ADC,OP_ROR,OP_RMB ; 6
		.byte	OP_PLA,OP_ADC,OP_ROR,OP_ERR,OP_JMP,OP_ADC,OP_ROR,OP_BBR
		.byte	OP_BVS,OP_ADC,OP_ADC,OP_ERR,OP_STZ,OP_ADC,OP_ROR,OP_RMB ; 7
		.byte	OP_SEI,OP_ADC,OP_PLY,OP_ERR,OP_JMP,OP_ADC,OP_ROR,OP_BBR
		.byte	OP_BRA,OP_STA,OP_ERR,OP_ERR,OP_STY,OP_STA,OP_STX,OP_SMB ; 8
		.byte	OP_DEY,OP_BIT,OP_TXA,OP_ERR,OP_STY,OP_STA,OP_STX,OP_BBS
		.byte	OP_BCC,OP_STA,OP_STA,OP_ERR,OP_STY,OP_STA,OP_STX,OP_SMB ; 9
		.byte	OP_TYA,OP_STA,OP_TXS,OP_ERR,OP_STZ,OP_STA,OP_STZ,OP_BBS
		.byte	OP_LDY,OP_LDA,OP_LDX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_SMB ; A
		.byte	OP_TAY,OP_LDA,OP_TAX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_BBS
		.byte	OP_BCS,OP_LDA,OP_LDA,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_SMB ; B
		.byte	OP_CLV,OP_LDA,OP_TSX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_BBS
		.byte	OP_CPY,OP_CMP,OP_ERR,OP_ERR,OP_CPY,OP_CMP,OP_DEC,OP_SMB ; C
		.byte	OP_INY,OP_CMP,OP_DEX,OP_WAI,OP_CPY,OP_CMP,OP_DEC,OP_BBS
		.byte	OP_BNE,OP_CMP,OP_CMP,OP_ERR,OP_ERR,OP_CMP,OP_DEC,OP_SMB ; D
		.byte	OP_CLD,OP_CMP,OP_PHX,OP_STP,OP_ERR,OP_CMP,OP_DEC,OP_BBS
		.byte	OP_CPX,OP_SBC,OP_ERR,OP_ERR,OP_CPX,OP_SBC,OP_INC,OP_SMB ; E
		.byte	OP_INX,OP_SBC,OP_NOP,OP_ERR,OP_CPX,OP_SBC,OP_INC,OP_BBS
		.byte	OP_BEQ,OP_SBC,OP_SBC,OP_ERR,OP_ERR,OP_SBC,OP_INC,OP_SMB ; F
		.byte	OP_SED,OP_SBC,OP_PLX,OP_ERR,OP_ERR,OP_SBC,OP_INC,OP_BBS

MODES:
		.byte	MO_IMM,MO_IZX,MO_IMM,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; 0
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPG,MO_ZPX,MO_ZPX,MO_ZPG ; 1
		.byte	MO_IMP,MO_ABY,MO_ACC,MO_IMP,MO_ABS,MO_ABX,MO_ABX,MO_BRL
		.byte	MO_ABS,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; 2
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPX,MO_ZPG ; 3
		.byte	MO_IMP,MO_ABY,MO_ACC,MO_IMP,MO_ABX,MO_ABX,MO_ABX,MO_BRL
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG ; 4
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPG ; 5
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_BRL
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; 6
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_IAB,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPX,MO_ZPG ; 7
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IAX,MO_ABX,MO_ABX,MO_BRL
		.byte	MO_REL,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; 8
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPY,MO_ZPG ; 9
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_ABS,MO_ABX,MO_ABX,MO_BRL
		.byte	MO_IMM,MO_IZX,MO_IMM,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; A
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPY,MO_ZPG ; B
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_ABY,MO_BRL
		.byte	MO_IMM,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; C
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPG ; D
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_BRL
		.byte	MO_IMM,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_ZPG ; E
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_BRL
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPG ; F
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_BRL
		.endif

;-------------------------------------------------------------------------------

		.if	__65SC02__
OPCODES:
		.byte	OP_BRK,OP_ORA,OP_ERR,OP_ERR,OP_TSB,OP_ORA,OP_ASL,OP_NOP ; 0
		.byte	OP_PHP,OP_ORA,OP_ASL,OP_ERR,OP_TSB,OP_ORA,OP_ASL,OP_NOP
		.byte	OP_BPL,OP_ORA,OP_ORA,OP_ERR,OP_TRB,OP_ORA,OP_ASL,OP_NOP ; 1
		.byte	OP_CLC,OP_ORA,OP_INC,OP_ERR,OP_TRB,OP_ORA,OP_ASL,OP_NOP
		.byte	OP_JSR,OP_AND,OP_ERR,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_NOP ; 2
		.byte	OP_PLP,OP_AND,OP_ROL,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_NOP
		.byte	OP_BMI,OP_AND,OP_AND,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_NOP ; 3
		.byte	OP_SEC,OP_AND,OP_DEC,OP_ERR,OP_BIT,OP_AND,OP_ROL,OP_NOP
		.byte	OP_RTI,OP_EOR,OP_ERR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_NOP ; 4
		.byte	OP_PHA,OP_EOR,OP_LSR,OP_ERR,OP_JMP,OP_EOR,OP_LSR,OP_NOP
		.byte	OP_BVC,OP_EOR,OP_EOR,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_NOP ; 5
		.byte	OP_CLI,OP_EOR,OP_PHY,OP_ERR,OP_ERR,OP_EOR,OP_LSR,OP_NOP
		.byte	OP_RTS,OP_ADC,OP_ERR,OP_ERR,OP_STZ,OP_ADC,OP_ROR,OP_NOP ; 6
		.byte	OP_PLA,OP_ADC,OP_ROR,OP_ERR,OP_JMP,OP_ADC,OP_ROR,OP_NOP
		.byte	OP_BVS,OP_ADC,OP_ADC,OP_ERR,OP_STZ,OP_ADC,OP_ROR,OP_NOP ; 7
		.byte	OP_SEI,OP_ADC,OP_PLY,OP_ERR,OP_JMP,OP_ADC,OP_ROR,OP_NOP
		.byte	OP_BRA,OP_STA,OP_ERR,OP_ERR,OP_STY,OP_STA,OP_STX,OP_NOP ; 8
		.byte	OP_DEY,OP_BIT,OP_TXA,OP_ERR,OP_STY,OP_STA,OP_STX,OP_NOP
		.byte	OP_BCC,OP_STA,OP_STA,OP_ERR,OP_STY,OP_STA,OP_STX,OP_NOP ; 9
		.byte	OP_TYA,OP_STA,OP_TXS,OP_ERR,OP_STZ,OP_STA,OP_STZ,OP_NOP
		.byte	OP_LDY,OP_LDA,OP_LDX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_NOP ; A
		.byte	OP_TAY,OP_LDA,OP_TAX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_NOP
		.byte	OP_BCS,OP_LDA,OP_LDA,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_NOP ; B
		.byte	OP_CLV,OP_LDA,OP_TSX,OP_ERR,OP_LDY,OP_LDA,OP_LDX,OP_NOP
		.byte	OP_CPY,OP_CMP,OP_ERR,OP_ERR,OP_CPY,OP_CMP,OP_DEC,OP_NOP ; C
		.byte	OP_INY,OP_CMP,OP_DEX,OP_WAI,OP_CPY,OP_CMP,OP_DEC,OP_NOP
		.byte	OP_BNE,OP_CMP,OP_CMP,OP_ERR,OP_ERR,OP_CMP,OP_DEC,OP_NOP ; D
		.byte	OP_CLD,OP_CMP,OP_PHX,OP_STP,OP_ERR,OP_CMP,OP_DEC,OP_NOP
		.byte	OP_CPX,OP_SBC,OP_ERR,OP_ERR,OP_CPX,OP_SBC,OP_INC,OP_NOP ; E
		.byte	OP_INX,OP_SBC,OP_NOP,OP_ERR,OP_CPX,OP_SBC,OP_INC,OP_NOP
		.byte	OP_BEQ,OP_SBC,OP_SBC,OP_ERR,OP_ERR,OP_SBC,OP_INC,OP_NOP ; F
		.byte	OP_SED,OP_SBC,OP_PLX,OP_ERR,OP_ERR,OP_SBC,OP_INC,OP_NOP

MODES:
		.byte	MO_IMM,MO_IZX,MO_IMM,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; 0
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPG,MO_ZPX,MO_ZPX,MO_IMP ; 1
		.byte	MO_IMP,MO_ABY,MO_ACC,MO_IMP,MO_ABS,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_ABS,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; 2
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPX,MO_IMP ; 3
		.byte	MO_IMP,MO_ABY,MO_ACC,MO_IMP,MO_ABX,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_IMP ; 4
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; 5
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMP,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; 6
		.byte	MO_IMP,MO_IMM,MO_ACC,MO_IMP,MO_IAB,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPX,MO_IMP ; 7
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IAX,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_REL,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; 8
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPY,MO_IMP ; 9
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_ABS,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMM,MO_IZX,MO_IMM,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; A
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_ZPX,MO_ZPX,MO_ZPY,MO_IMP ; B
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_ABY,MO_IMP
		.byte	MO_IMM,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; C
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; D
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.byte	MO_IMM,MO_IZX,MO_IMP,MO_IMP,MO_ZPG,MO_ZPG,MO_ZPG,MO_IMP ; E
		.byte	MO_IMP,MO_IMM,MO_IMP,MO_IMP,MO_ABS,MO_ABS,MO_ABS,MO_IMP
		.byte	MO_REL,MO_IZY,MO_IZP,MO_IMP,MO_IMP,MO_ZPX,MO_ZPX,MO_IMP ; F
		.byte	MO_IMP,MO_ABY,MO_IMP,MO_IMP,MO_IMP,MO_ABX,MO_ABX,MO_IMP
		.endif

;===============================================================================
; IRQ Handler
;-------------------------------------------------------------------------------

; Handle interrupts.

IRQ:
		pha			; Save users registers
		phx
		
		tsx			; Check for BRK
		lda	STACK+3,X
		and	#$10
		if 	ne
		 phy
		 jmp	BRK		; Enter monitor with registers on stack
		endif

		plx
		pla
NMI:		rti			; Done

;===============================================================================
; UART I/O
;-------------------------------------------------------------------------------

; Inserts the byte in A into the transmit buffer. If the buffer is full then
; wait until some space is available. Registers are preserved.

UartTx:
		pha
                phx
		tax
		
                lda     #$01
TxWait:         bit     VIA2_IRB        ; Is there space for more data
                bne     TxWait
		
		lda	#$ff		; Make port an output
		sta	VIA2_DDRA
		stx	VIA2_ORA	; And output the character
                lda     #$04        	; Strobe WR high
		tsb	VIA2_ORB
                nop
                nop
		trb	VIA2_ORB
                plx
		pla
		rts			; Done

; Extracts the next character from the head of the RX buffer. If the buffer is
; empty then wait for some data to be placed in it by the interrupt handler.

UartRx:
                phx                     ; Save callers X
		
                lda     #$02            ; Wait until data in buffer
RxWait:         bit     VIA2_IRB
                bne     RxWait

		stz	VIA2_DDRA	; Make port all input
                lda     VIA2_IRB
                lda     #$08        	; Strobe /RD low
		trb	VIA2_ORB
		nop			; Wait for data to be available
		nop
		nop
		nop
		ldx	VIA2_IRA        ; Read it
                tsb     VIA2_ORB	; And end the strobe
		txa
                plx                     ; .. and callers X
		rts			; Done

;===============================================================================
; Vector Locations
;-------------------------------------------------------------------------------

DO_IRQ		jmp	(IRQV)
DO_NMI		jmp	(NMIV)

; Shadow Vector Area

		.org	$7efa

		.word	DO_NMI		; NMI
		.word	RESET		; RESET
		.word	DO_IRQ		; IRQ/BRK

		.END