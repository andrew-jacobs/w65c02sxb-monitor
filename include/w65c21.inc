;===============================================================================
; WDC W65C21 Peripheral Interface Adapter (PIA) Definitions
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

;===============================================================================
; Peripheral Registers
;-------------------------------------------------------------------------------

PIA_ORA		.equ	0		; When CRA.DDRA = 1
PIA_DDRA	.equ	0		; When CRA.DDRA = 0
PIA_CRA		.equ	1
PIA_ORB		.equ	2		; When CRB.DDRB = 1
PIA_DDRA	.equ	2		; When CRB.DDRB = 0
PIA_CRB		.equ	3

; CRA Register Bits

PIA_CRA_IRQA1	.equ	$80
PIA_CRA_IRQA2	.equ	$40
PIA_CRA_CA22	.equ	$20
PIA_CRA_CA21	.equ	$10
PIA_CRA_CA20	.equ	$08
PIA_CRA_DDRA	.equ	$04
PIA_CRA_CA11	.equ	$02
PIA_CRA_CA10	.equ	$01

; CRB Register Bits

PIA_CRB_IRQB1	.equ	$80
PIA_CRB_IRQB2	.equ	$40
PIA_CRB_CB22	.equ	$20
PIA_CRB_CB21	.equ	$10
PIA_CRB_CB20	.equ	$08
PIA_CRB_DDRB	.equ	$04
PIA_CRB_CB11	.equ	$02
PIA_CRB_CB10	.equ	$01
