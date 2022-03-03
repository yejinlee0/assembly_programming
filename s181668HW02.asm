TITLE
;Author: Lee Ye Jin(20181668) 
;Program Description: formula calculation
;Input: CSE3030_PHW02_2019.inc
;Output: WriteInt
INCLUDE irvine32.inc
.data
INCLUDE CSE3030_PHW02_2019.inc
.code
main PROC
	mov		eax, x1
	mov		edx, x3
	add		edx, eax	;edx=x1+x3
	add		eax, edx	;eax=2x1+x3
	mov		ebx, x2
	add		eax, ebx	;eax=2x1+x2+x3
	add		ebx, ebx
	add		eax, ebx	;eax=2x1+3x2+x3
	mov		ebx, x2
	add		eax, eax
	add		eax, eax
	add		eax, eax
	add		eax, eax	;eax=32x1+48x2+16x3
	sub		eax, ebx	;eax=32x1+47x2+16x3
	add		eax, edx	;eax=33x1+47x2+17x3
	add		edx, edx
	add		eax, edx	;eax=35x1+47x2+19x3
	mov		edx, x1
	add		eax, edx	;eax=36x1+47x2+19x3
	add		edx, edx
	add		eax, edx	;eax=38x1+47x2+19x3
	call	WriteInt
	exit
main ENDP
END main