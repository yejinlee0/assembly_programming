TITLE
;Author: Lee Ye Jin(20181668)
;Program Descriprion: strange house of bugs
;Input: ReadDec
;Output: WriteDec
INCLUDE irvine32.inc
.data
entr BYTE "Enter R: ",0
entc BYTE "Enter C: ",0
arr DWORD 0,1,1,1,1,1,1,1,1,1,1
.code
main PROC
	mov edx, OFFSET entr
	call WriteString

	call ReadDec ; eax= R
	mov ecx, eax
	inc ecx

	L1:
	push ecx

	mov esi, OFFSET arr
	mov edi, OFFSET arr

	add esi, TYPE arr

	add edi, TYPE arr
	add edi, TYPE arr

	mov ecx, LENGTHOF arr
	dec ecx

	L2:
	mov eax, [esi]
	add [edi], eax

	add esi, TYPE arr
	add edi, TYPE arr
	loop L2

	pop ecx
	loop L1

	mov edx, OFFSET entc
	call WriteString
	call ReadDec ; eax=C

	mov esi, OFFSET arr
	mov ecx, eax
	
	L3:
	add esi, TYPE arr
	loop L3

	mov eax, [esi]
	call WriteDec
	call Crlf

exit
main ENDP
END main