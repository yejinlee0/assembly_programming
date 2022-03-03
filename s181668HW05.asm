TITLE
;Author: Lee Ye Jin(20181668)
;Program Descriprion: string repetition
;Input: number, string
;Output: string
INCLUDE irvine32.inc

.data
Single_Buf__ BYTE ?
Byte_Read__ DWORD ?
Check__ DWORD ?
stdinHandle HANDLE ?
stdoutHandle HANDLE ?

CR BYTE 0Dh
LF BYTE 0Ah

rflg DWORD 0
pflg DWORD 0
num DWORD 0
filestr BYTE ?

.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

A_LINE:
	call Read_a_Line
	cmp rflg, 0
	je THEEND
	call Print_a_Line
	cmp pflg, 0
	je THEEND
	mov Byte_Read__, 0
	mov rflg, 0
	mov pflg, 0
	jmp A_LINE

THEEND:
exit
main ENDP

Read_a_Line PROC
	xor ecx, ecx
	mov edx, OFFSET filestr
 Read_Loop :
	push eax
	push ecx
	push edx
	INVOKE ReadFile , stdinHandle, OFFSET Single_Buf__, 1, OFFSET Byte_Read__, 0
	pop edx
	pop ecx
	pop eax

	cmp DWORD PTR Byte_Read__, 0 ; check # of chars read
	je	Read_End ; if read nothing, return

	mov bl, Single_Buf__ ; load the char
	cmp bl, CR
	je Read_Loop

	cmp bl, LF
	je Read_End

	mov [edx], bl

	inc edx
	inc ecx
	mov rflg,1

	jmp Read_Loop

  Read_End:
	mov BYTE PTR [edx], 0 ;append 0 at the end
	ret
 Read_a_Line ENDP

 Print_a_Line PROC
	xor eax, eax
	mov edx, OFFSET filestr
	mov al, BYTE PTR [filestr]

	mov num, eax
	sub num, 48

	call IsDigit
	jnz P_END

	inc edx
	inc edx
	mov pflg, 1

 nRepeat:
	mov ecx, num
	L1:
	push eax
	push ecx
	push edx
	INVOKE WriteFile , stdoutHandle, edx, 1, 0, 0
	pop edx
	pop ecx
	pop eax
	loop L1

	inc edx
	cmp BYTE PTR [edx], 0
	jne nRepeat

	INVOKE WriteFile , stdoutHandle, OFFSET CR, 1, 0, 0
	INVOKE WriteFile , stdoutHandle, OFFSET LF, 1, 0, 0

 P_END:
	ret
 Print_a_Line ENDP
 END main