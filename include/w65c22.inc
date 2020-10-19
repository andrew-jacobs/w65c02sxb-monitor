;===============================================================================
; WDC W65C22 Versatile Interface Adapter (VIA) Definitions
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

VIA_ORB		.equ	$00
VIA_IRB		.equ	$00
VIA_ORA		.equ	$01
VIA_IRA		.equ	$01
VIA_DDRB	.equ	$02
VIA_DDRA	.equ	$03
VIA_T1CL	.equ	$04
VIA_T1CH	.equ	$05
VIA_T1LL	.equ	$06
VIA_T1LH	.equ	$07
VIA_T2CL	.equ	$08
VIA_T2CH	.equ	$09
VIA_SR		.equ	$0a
VIA_ACR		.equ	$0b
VIA_PCR		.equ	$0c
VIA_IFR		.equ	$0d
VIA_IER		.equ	$0e
VIA_ORAN	.equ	$0f
VIA_IRAN	.equ	$0f

; ACR Register Bits

VIA_ACR_T1C1	.equ	$80
VIA_ACR_T1C0	.equ	$40
VIA_ACR_T2C	.equ	$20
VIA_ACR_SRC2	.equ	$10
VIA_ACR_SRC1	.equ	$08
VIA_ACR_SRC0	.equ	$04
VIA_ACR_PA	.equ	$02
VIA_ACR_PB	.equ	$01

; PCR Register Bits

VIA_PCR_CB2C2	.equ	$80
VIA_PCR_CB2C1	.equ	$40
VIA_PCR_CB2C0	.equ	$20
VIA_PCR_CB1C	.equ	$10
VIA_PCR_CA2C2	.equ	$08
VIA_PCR_CA2C1	.equ	$04
VIA_PCR_CA2C0	.equ	$02
VIA_PCR_CA1C	.equ	$01

; IFR Register Bits

VIA_IFR_IRQ	.equ	$80
VIA_IFR_T1	.equ	$40
VIA_IFR_T2	.equ	$20
VIA_IFR_CB1	.equ	$10
VIA_IFR_CB2	.equ	$08
VIA_IFR_SR	.equ	$04
VIA_IFR_CA1	.equ	$02
VIA_IFR_CA2	.equ	$01

; IER Register Bits

VIA_IER_SET	.equ	$80
VIA_IER_T1	.equ	$40
VIA_IER_T2	.equ	$20
VIA_IER_CB1	.equ	$10
VIA_IER_CB2	.equ	$08
VIA_IER_SR	.equ	$04
VIA_IER_CA1	.equ	$02
VIA_IER_CA2	.equ	$01
