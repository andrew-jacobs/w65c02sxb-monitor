;===============================================================================
; WDC W65C02SXB System Definitions
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
;-------------------------------------------------------------------------------

		.include "w65c02.inc"
		.include "w65c22.inc"
		.include "w65c51.inc"

;===============================================================================
; Configuration
;-------------------------------------------------------------------------------

FOSC		.equ	8000000		; Oscillator speed (8MHz)

;===============================================================================
; Peripherals
;-------------------------------------------------------------------------------

ACIA		.equ	$7f80
PIA		.equ	$7fa0
VIA1		.equ	$7fc0
VIA2		.equ	$7fe0		; Connected to FTDI 245

VIA2_IRB	.equ	VIA2+VIA_IRB
VIA2_ORB	.equ	VIA2+VIA_ORB
VIA2_ORA	.equ	VIA2+VIA_ORA
VIA2_IRA	.equ	VIA2+VIA_IRA
VIA2_DDRB	.equ	VIA2+VIA_DDRB
VIA2_DDRA	.equ	VIA2+VIA_DDRA

;===============================================================================
; Utility Routines
;-------------------------------------------------------------------------------

