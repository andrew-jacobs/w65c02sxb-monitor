;===============================================================================
; __        ____  ____   ____ ___ ____  ______  ______  
; \ \      / / /_| ___| / ___/ _ \___ \/ ___\ \/ / __ ) 
;  \ \ /\ / / '_ \___ \| |  | | | |__) \___ \\  /|  _ \ 
;   \ V  V /| (_) |__) | |__| |_| / __/ ___) /  \| |_) |
;    \_/\_/  \___/____/ \____\___/_____|____/_/\_\____/ 
;
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
		.include "w65c21.inc"
		.include "w65c22.inc"
		.include "w65c51.inc"

;===============================================================================
; Configuration
;-------------------------------------------------------------------------------

FOSC		.equ	8000000		; Oscillator speed (8MHz)

;===============================================================================
; Peripherals
;-------------------------------------------------------------------------------

ACIA1		.equ	$7f80
PIA1		.equ	$7fa0
VIA1		.equ	$7fc0
VIA2		.equ	$7fe0		; Connected to FTDI 245

ACIA1_DATA	.equ	ACIA1+ACIA_DATA
ACIA1_SR	.equ	ACIA1+ACIA_SR
ACIA1_CMD	.equ	ACIA1+ACIA_CMD
ACIA1_CR	.equ	ACIA1+ACIA_CR

PIA1_ORA	.equ	PIA1+PIA_ORA
PIA1_DDRA	.equ	PIA1+PIA_DDRA
PIA1_CRA	.equ	PIA1+PIA_CRA
PIA1_ORB	.equ	PIA1+PIA_ORB
PIA1_DDRB	.equ	PIA1+PIA_DDRB
PIA1_CRB	.equ	PIA1+PIA_CRB

VIA1_IRB	.equ	VIA1+VIA_IRB
VIA1_ORB	.equ	VIA1+VIA_ORB
VIA1_ORA	.equ	VIA1+VIA_ORA
VIA1_IRA	.equ	VIA1+VIA_IRA
VIA1_DDRB	.equ	VIA1+VIA_DDRB
VIA1_DDRA	.equ	VIA1+VIA_DDRA
VIA1_T1CL	.equ	VIA1+VIA_T1CL
VIA1_T1CH	.equ	VIA1+VIA_T1CH
VIA1_T1LL	.equ	VIA1+VIA_T1LL
VIA1_T1LH	.equ	VIA1+VIA_T1LH
VIA1_T2CL	.equ	VIA1+VIA_T2CL
VIA1_T2CH	.equ	VIA1+VIA_T2CH
VIA1_SR		.equ	VIA1+VIA_SR
VIA1_ACR	.equ	VIA1+VIA_ACR
VIA1_PCR	.equ	VIA1+VIA_PCR
VIA1_IFR	.equ	VIA1+VIA_IFR
VIA1_IER	.equ	VIA1+VIA_IER
VIA1_ORAN	.equ	VIA1+VIA_ORAN
VIA1_IRAN	.equ	VIA1+VIA_IRAN

VIA2_IRB	.equ	VIA2+VIA_IRB
VIA2_ORB	.equ	VIA2+VIA_ORB
VIA2_ORA	.equ	VIA2+VIA_ORA
VIA2_IRA	.equ	VIA2+VIA_IRA
VIA2_DDRB	.equ	VIA2+VIA_DDRB
VIA2_DDRA	.equ	VIA2+VIA_DDRA
VIA2_T1CL	.equ	VIA2+VIA_T1CL
VIA2_T1CH	.equ	VIA2+VIA_T1CH
VIA2_T1LL	.equ	VIA2+VIA_T1LL
VIA2_T1LH	.equ	VIA2+VIA_T1LH
VIA2_T2CL	.equ	VIA2+VIA_T2CL
VIA2_T2CH	.equ	VIA2+VIA_T2CH
VIA2_SR		.equ	VIA2+VIA_SR
VIA2_ACR	.equ	VIA2+VIA_ACR
VIA2_PCR	.equ	VIA2+VIA_PCR
VIA2_IFR	.equ	VIA2+VIA_IFR
VIA2_IER	.equ	VIA2+VIA_IER
VIA2_ORAN	.equ	VIA2+VIA_ORAN
VIA2_IRAN	.equ	VIA2+VIA_IRAN
