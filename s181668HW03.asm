TITLE
;Author: Lee Ye Jin(20181668)
;Program Descriprion: multiplication table
;Input: ReadDec
;Output: WriteDec
INCLUDE irvine32.inc
.data
dgt BYTE "Enter a digit(2~9): ",0
mtp	BYTE " * ",0
eql	BYTE " = ",0
num WORD 0
n	BYTE 1
tmp BYTE 0
.code
main PROC
	mov edx, OFFSET dgt
	call WriteString
	call ReadDec
	mov num, ax
	mov tmp, al
	mov ecx, 9

	L1:
	mov al, tmp
	call WriteDec
	mov edx, OFFSET mtp ;*
	call WriteString
	mov al, n
	call WriteDec
	mov edx, OFFSET eql ;=
	call WriteString
	mov ax, num
	call WriteDec
	mov ah, 0
	mov al, tmp
	add num, ax
	inc n
	call Crlf
	loop L1
exit
main ENDP
END main