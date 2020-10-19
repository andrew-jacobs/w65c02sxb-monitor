;===============================================================================
; WDC W65C02 Processor Definitions
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

		.65c02

;===============================================================================
; Constants
;-------------------------------------------------------------------------------

; Status Registers Bits

N		.equ	$80
V		.equ	$40
B		.equ	$10
D		.equ	$08
I		.equ	$04
Z		.equ	$02
C		.equ	$01

; Hardware Stack Page

STACK		.equ	$0100
