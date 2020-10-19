;===============================================================================
; WDC W65C51 Asynchronous Communications Interface Adapter (ACIA) Definitions
;-------------------------------------------------------------------------------
; Copyright (C)2020 Andrew Jacobs.
; All rights reserved.
;
; This work is made available under the terms of the Creative Commons
; Attribution-ShareAlike 4.0 International license. Open the following URL to
; see the details.
;
; https://creativecommons.org/licenses/by-sa/4.0/
;
;===============================================================================
; Notes:
;
; The 'Transmitter Data Register Empty' (TDRE) bit in the status register is
; faulty in physical W65C51 chips.
;-------------------------------------------------------------------------------

;===============================================================================
; Peripheral Registers
;-------------------------------------------------------------------------------

ACIA_DATA	.equ	0		; Transmit/Receive Register
ACIA_SR		.equ	1		; Status Register
ACIA_CMD	.equ	2		; Command Register
ACIA_CR		.equ	3		; Control Register

ACIA_SR_IRQ	.equ	1<<7		; Interrupt (IRQ)
ACIA_SR_DSRB	.equ	1<<6		; Data Set Ready (0=Ready)
ACIA_SR_DCDB	.equ	1<<5		; Data Carrier Detect (0=Detected)
ACIA_SR_TDRE	.equ	1<<4		; Tranmitter Data Register Empty
ACIA_SR_RDRF	.equ	1<<3		; Receiver Data Register Full
ACIA_SR_OVRN	.equ	1<<2		; Overrun
ACIA_SR_FE	.equ	1<<1		; Framing Error
ACIA_SR_PE	.equ	1<<0		; Parity Error

ACIA_CMD_PMC1	.equ	1<<7
ACIA_CMD_PMC0	.equ	1<<6
ACIA_CMD_PME	.equ	1<<5
ACIA_CMD_REM	.equ	1<<4
ACIA_CMD_TIC1	.equ	1<<3
ACIA_CMD_TIC0	.equ	1<<2
ACIA_CMD_IRD	.equ	1<<1
ACIA_CMD_DTR	.equ	1<<0

ACIA_CR_SBN	.equ	1<<7
ACIA_CR_WL1	.equ	1<<6
ACIA_CR_WL0	.equ	1<<5
ACIA_CR_RCS	.equ	1<<4
ACIA_CR_SBR3	.equ	1<<3
ACIA_CR_SBR2	.equ	1<<2
ACIA_CR_SBR1	.equ	1<<1
ACIA_CR_SBR0	.equ	1<<0