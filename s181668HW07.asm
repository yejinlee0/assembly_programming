TITLE
;(�ܵ�)20181668 �̿���
;Program Descriprion: Working Time
;Input: string
;Output: integer
INCLUDE irvine32.inc

.data
firststr BYTE 5 DUP(0)	;�Է¹��� ���ڿ��� ù ����

cnt DWORD 0;�迭 ������ ����
arrbuf BYTE 5 DUP(0)
Single_Buf__ BYTE ?
testcase_Buf BYTE 5 DUP(0)
Byte_Read__ DWORD ?

stdinHandle HANDLE ?
stdoutHandle HANDLE ?

taskstr BYTE 100 DUP(0)
taskarr DWORD 32 DUP(0)
taskn DWORD 0

daystr BYTE 100 DUP(0)
dayarr DWORD 32 DUP(0)
dayn DWORD 0

CR BYTE 0Dh
LF BYTE 0Ah

SPACE_ BYTE 20h;' '

testc DWORD 0

resultn SDWORD -1
resultstr BYTE 100 DUP(0)

num DWORD 0
tflg BYTE 0

.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

	call Read_testcase	;�׽�Ʈ ���̽� ������ ����

	cmp testc, 0
		je THEEND

	mov ecx, testc
	mainL:
	push ecx

	call do_task	;task�� ���� ���ڿ� �Է�

	mov edx, OFFSET taskstr
	mov ebx, OFFSET taskarr

	call Make_Array	;task�� ���� ���� �迭

	mov esi, OFFSET taskarr

	call bubblesort	;�������� ����

	mov num, 0	;�迭 ���� ���� �ʱ�ȭ

	call do_day	;day�� ���� ���ڿ� �Է�

	mov edx, OFFSET daystr
	mov ebx, OFFSET dayarr

	call Make_Array	;day�� ���� ���� �迭

	mov esi, OFFSET dayarr

	call bubblesort	;�������� ����

	xor eax, eax
	mov eax, taskn

	cmp eax, dayn	;taskn>dayn �� ��� -1 ���
	jg skipwt

	call workingtime	;����� ���� �� ����

	skipwt:
	call IntToStr	;��������� ���ҷ� �ϴ� ���ڿ� ����
	
	call do_ini	;�ʱ�ȭ

	pop ecx
	loop mainL

	call printstr	;��� ���ڿ� ���

	THEEND:

exit
main ENDP


Read_testcase PROC

	mov edx, OFFSET testcase_Buf
	xor ecx, ecx ; reset counter

	Read_T :
	
	pushad
	INVOKE ReadFile , stdinHandle, OFFSET Single_Buf__, 1, OFFSET Byte_Read__, 0
	popad
	
	cmp DWORD PTR Byte_Read__, 0 ;�ƹ��͵� �� ���� ���
	je Read_T_End ; if read nothing, return

	mov bl, Single_Buf__
	cmp bl, CR
		je Read_T ; if CR, read once more

	cmp bl, LF
		je Make_T ; End of line detected, return

	mov tflg, 1
	mov [edx], bl ; move the char to input buf
	inc edx ; ++1 buf pointer
	inc ecx ; ++1 char counter
	jmp Read_T ; go to start to read the next line

	Make_T:
	cmp tflg, 0 ; ���ڸ� �ϳ��� ���� ��� tflg=1 �̴�.
		je Read_T_End

	mov edx, OFFSET testcase_Buf
	call ParseDecimal32

	mov testc, eax

	Read_T_End:
	
	ret
Read_testcase ENDP

do_task PROC

	mov edx, OFFSET taskstr
	call Read_a_Line
	xor eax, eax
	mov eax, num
	mov taskn, eax

	ret
do_task ENDP

do_day PROC

	mov edx, OFFSET daystr
	call Read_a_Line
	xor eax, eax
	mov eax, num
	mov dayn, eax

	ret
do_day ENDP

Read_a_Line PROC
	push edx
	
	call ini_f
	mov edx, OFFSET firststr
	xor ecx, ecx
firstnum:

	pushad
	INVOKE ReadFile , stdinHandle, OFFSET Single_Buf__, 1, OFFSET Byte_Read__, 0
	popad

	mov bl, Single_Buf__

	cmp bl, SPACE_
		je savefirstnum ; if SPACE, read once more

	mov [edx], bl
	inc edx
	inc ecx

	jmp firstnum

savefirstnum:
	xor eax, eax
	mov edx, OFFSET firststr
	call ParseDecimal32
	mov num, eax

	pop edx
 ;space���� ���� ����

	xor ecx, ecx ; reset counter

	Read_Loop :
	
	pushad
	INVOKE ReadFile ,  stdinHandle, OFFSET Single_Buf__, 1, OFFSET Byte_Read__, 0
	popad

	
	cmp DWORD PTR Byte_Read__, 0 ;�ƹ��͵� �� ���� ���
	je Read_End ; if read nothing, return

	mov bl, Single_Buf__ ; load the char

	cmp bl, CR
		je Read_Loop ; if CR, read once more

	cmp bl, LF
		je Read_End ; End of line detected, return

	mov [edx], bl ; move the char to input buf
	inc edx ; ++1 buf pointer
	inc ecx ; ++1 char counter
	jmp Read_Loop ; go to start to read the next line

	Read_End:
	mov BYTE PTR [edx], 0 ; append 0 at the end

	ret
Read_a_Line ENDP

Make_Array PROC
	mov cnt, 0
	xor ecx, ecx

 Check_Loop :

	xor eax, eax

	mov al, [edx]

	cmp eax, 0 ; ���ڿ� ��
	je	Arr_End
	
	cmp al, SPACE_
	je increase_edx ; space �̸� ����

	call IniArrBuf
	mov esi, OFFSET arrbuf

	xor ecx, ecx ; buffer size
	
one_int :
	mov [esi], al

	inc ecx
	
	inc edx ; '-' or ���ڸ� ó���� �а��� �������ڸ� �б� ���ؼ�

	xor eax, eax
	mov al, [edx]
	
	cmp al, SPACE_ ; ������ ��
	je make_one_int
	
	cmp eax, 0 ; ���ڿ��� ��
	je make_one_and_end

	inc esi
	jmp one_int	

make_one_int:
	push edx

	mov edx, OFFSET arrbuf
	call ParseDecimal32

	mov [ebx], eax

	add ebx, TYPE DWORD

	inc cnt
	pop edx

	jmp Check_Loop
 
 make_one_and_end:
	push edx

	mov edx, OFFSET arrbuf
	call ParseDecimal32
	
	mov [ebx], eax

	inc cnt
	pop edx
 jmp Arr_End

 increase_edx:
	inc edx
	jmp Check_Loop
	
  Arr_End:
	ret
Make_Array ENDP

bubblesort PROC
	mov ebx, esi
	mov ecx, cnt

	cmp ecx, 1	;1���� ��쿡�� ������ �ʿ䰡 ����.
		je B4

	dec ecx

	B1:
	push ecx
	mov esi, ebx

	B2:
	mov eax, [esi]
	cmp [esi+4], eax
	jg B3
	xchg eax, [esi+4]
	mov [esi], eax

	B3:
	add esi, 4
	loop B2

	pop ecx
	loop B1

	B4:
	ret
bubblesort ENDP

IniArrBuf PROC USES ecx edx

	mov edx, OFFSET arrbuf
	mov ecx, LENGTHOF arrbuf
	L1:
		mov BYTE PTR [edx], 0;initialize arrbuf
		add edx, TYPE arrbuf
	loop L1

	ret
IniArrBuf ENDP

workingtime PROC
	mov resultn, 0
	mov esi, OFFSET taskarr
	mov edi, OFFSET dayarr

	do_check:
	xor eax, eax
	mov eax, [edi]
	xor ebx, ebx
	mov ebx, [esi]

	cmp ebx, eax
	jg check_not

	add resultn, eax

	add esi, TYPE DWORD
	xor ebx, ebx
	mov ebx, [esi]
	cmp ebx, 0
	je go_finish

	check_not:

	add edi, TYPE DWORD
	xor ebx, ebx
	mov ebx, [edi]
	cmp ebx, 0
	je cannotdo

	jmp do_check

cannotdo:
	mov resultn, -1

go_finish:

	ret
workingtime ENDP


IntToStr PROC USES eax ebx edx esi edi

	mov edx, OFFSET resultstr

	search_n:
	xor ebx, ebx
	mov bl, [edx]
	cmp bl, 0
		je makestr

	inc edx

	jmp search_n


	makestr:

	mov eax, resultn
	mov esi, eax ; save eax

	mov edi, edx
	
	test eax, 80000000h; If eax is negative, make it positive
	jz P1	;������ ���

	neg eax

	P1:

	xor ecx, ecx
	;ecx�� ���ڿ��� ������

	mov ebx, 10

	ConvLoop:

	cdq
	;edx�� eax�� ��ȣ ��Ʈ�� Ȯ��

	div ebx
	
	or dx, 0030h
	;�������� �ƽ�Ű ĳ���ͷ� ��ȯ

	push dx

	inc ecx
	;������ ����

	cmp eax, 0	;���� 0�� ���� ������ ����� ��
	jnz ConvLoop

	mov ebx, ecx

	test esi, 80000000h ; add '-' if negative

	jz P2	;������ ������ ���

	mov BYTE PTR [edi], '-'
	inc edi
	inc ebx

	P2:

	RevLoop:
	pop ax
	mov [edi], al
	inc edi
	loop RevLoop

	xor eax, eax
	mov al, SPACE_
	mov [edi],al 

	mov ecx, ebx ; save the str size in ecx

	ret
IntToStr ENDP

ini_f PROC USES ecx edx

	mov edx, OFFSET firststr
	mov ecx, LENGTHOF firststr
	L4:
		mov BYTE PTR [edx], 0;initialize firststr
		add edx, TYPE firststr
	loop L4

	ret
ini_f ENDP

do_ini PROC USES ecx edx

	mov edx, OFFSET taskarr
	mov ecx, LENGTHOF taskarr
	L2:
		mov BYTE PTR [edx], 0;initialize taskarr
		add edx, TYPE taskarr
	loop L2

	mov edx, OFFSET dayarr
	mov ecx, LENGTHOF dayarr
	L3:
		mov BYTE PTR [edx], 0;initialize dayarr
		add edx, TYPE dayarr
	loop L3
		mov edx, OFFSET taskstr
	mov ecx, LENGTHOF taskstr
	L5:
		mov BYTE PTR [edx], 0;initialize taskstr
		add edx, TYPE taskstr
	loop L5

	mov edx, OFFSET daystr
	mov ecx, LENGTHOF daystr
	L6:
		mov BYTE PTR [edx], 0;initialize daystr
		add edx, TYPE daystr
	loop L6
	mov resultn, -1

	ret
do_ini ENDP

printstr PROC
	mov edx, OFFSET resultstr
	mov ecx, LENGTHOF resultstr
	printL1:
	xor ebx, ebx
	mov bl, [edx]

	cmp bl, SPACE_
	je print_enter

	cmp bl, 0
	je print_end

	pushad
	INVOKE WriteFile , stdoutHandle, edx, 1, 0, 0
	popad

	jmp go_next

	print_enter:
	pushad
	INVOKE WriteFile , stdoutHandle, OFFSET CR, 1, 0, 0
	INVOKE WriteFile , stdoutHandle, OFFSET LF, 1, 0, 0	
	popad

	go_next:
	inc edx
	loop printL1

	print_end:
	ret
printstr ENDP

END main