;===============================================================================
;
; Change this to what ever you need.

;-------------------------------------------------------------------------------

		.include "w65c02sxb.inc"
		
;===============================================================================
; ASCII Control Characters
;-------------------------------------------------------------------------------

LF		.equ	$0a
CR		.equ	$0d

;===============================================================================
; Data Areas
;-------------------------------------------------------------------------------

		.page0
		.org	$00
		
PTR		.space	2

		.bss
		.org	$0280

; More storage space here if need

;===============================================================================
; Application code
;-------------------------------------------------------------------------------

		.code
		
; Assemble to fixed memory address -- Makes the listing much easier to read. No
; ?? bytes for relocatable addresses that are patched by the linker.

		.org	$0300
		
		; Your code here -- this is an example
		
		lda	#<MESSAGE	; Print a message
		ldx	#>MESSAGE
		jsr	Print
		
		brk			; Go back to the monitor
		
Print:
		sta	PTR+0		; Save the string address
		stx	PTR+1
		ldy	#0
		repeat
		 lda 	(PTR),y		; Fetch a character
		 break	eq		; Break from loop if zero
		 jsr	UartTx		; Otherwise print it
		 iny			; And try the next byte
		forever
		rts			; Done
		
MESSAGE:	.byte 	CR,LF,"Oh brave new world that has such people in it"
		.byte	CR,LF,0

;===============================================================================
; UART I/O
;-------------------------------------------------------------------------------

; Inserts the byte in A into the transmit buffer. If the buffer is full then
; wait until some space is available. Registers are preserved.

UartTx:
		pha
                phx
		tax
		
                lda     #$01        	; Wait until there is space for data
		repeat
		 bit    VIA2_IRB
                until eq
		
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
		repeat
		 bit    VIA2_IRB
                until eq

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

		.end