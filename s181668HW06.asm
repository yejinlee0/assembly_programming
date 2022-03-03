TITLE
;(�ܵ�)20181668 �̿���
;Program Descriprion: Square
;Input: string
;Output: string
INCLUDE irvine32.inc

.data
outbuf BYTE 2048 DUP(0)
rnum BYTE 0;���� ������ ����
numbertwo DWORD 2
Single_Buf__ BYTE ?
Byte_Read__ DWORD ?
Check__ DWORD ?
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
rflg DWORD 0;read flag
iflg BYTE 0;integer flag
IntArr DWORD 46 DUP(0)
CR BYTE 0Dh
LF BYTE 0Ah
SPACE_ BYTE 20h;' '
BAR_ BYTE 2Dh;'-'
TAB_ BYTE 09h;'	'
cnt DWORD 0;�迭 ������ ����
arrbuf BYTE 1024 DUP(0)
num DWORD 0;outbuf ���� ����
filestr BYTE 2048 DUP(0)

.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

A_LINE:
	call Read_a_Line
	cmp rflg, 0;cr Ȥ�� lf�� ���� ���
	je THEEND

	cmp iflg, 0;���ڸ� �ϳ��� ���� ���� ���
	je THEEND
	
	call Print_a_Line
	INVOKE WriteFile , stdoutHandle, OFFSET CR, 1, 0, 0
	INVOKE WriteFile , stdoutHandle, OFFSET LF, 1, 0, 0

	mov rflg, 0
	mov iflg, 0

	mov rnum, 0
	mov cnt, 0
	mov num, 0

	jmp A_LINE

	THEEND:
exit
main ENDP

Read_a_Line PROC
	call INITIAL_F
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
	je Read_End ; if read nothing, return

	mov bl, Single_Buf__ ; load the char
 
 	cmp bl, CR
	je Read_Loop

	cmp bl, LF
	je Read_End

	xor eax, eax
	mov al, bl
	call IsDigit
	jnz NEQNUM

	mov iflg, 1;���� ��� 1�� �Է��� ���� ���

	NEQNUM:

	mov [edx], bl

	inc edx
	mov rflg,1
	inc rnum

	jmp Read_Loop

  Read_End:

	cmp iflg, 0 ; ���ڸ� ���� ���� ���
	je Only_space

	cmp rflg, 0;�ƹ� �͵� ���� ���� ���
	je Only_space

	mov BYTE PTR [edx], 0 ;append 0 at the end

	GOMAKEARR:
		call Make_Array

	Only_space:
	ret
Read_a_Line ENDP

 Make_Array PROC
	mov cnt, 0

	mov edx, OFFSET filestr ;edx���� read_a_line���� �Է� ���� ���ڿ�

	call INITIAL_A ;initialize IntArr
	mov ebx, OFFSET IntArr;ebx���� �迭�� �ּ�
  	call INITIAL_B ;initialize arrbuf
	xor ecx, ecx
 Check_Loop :

	xor eax, eax

	mov eax, [edx]

	cmp eax, 0 ; ���ڿ� ��
	je	Arr_End
	
	cmp al, SPACE_
	je increase_edx ; space �̸� ����
	
	cmp al, TAB_
	je increase_edx ; tab �̸� ����

	call INITIAL_B
	mov esi, OFFSET arrbuf

	xor ecx, ecx ; buffer size
	
one_int :
	mov [esi], al

	inc ecx
	
	inc edx ; '-' or ���ڸ� ó���� �а��� �������ڸ� �б� ���ؼ�

	xor eax, eax
	mov eax, [edx]
	
	cmp al, SPACE_ ; ������ ��
	je make_one_int

	cmp al, TAB_ ; ������ ��
	je make_one_int
	
	cmp eax, 0 ; ���ڿ��� ��
	je make_one_and_end

	inc esi
	jmp one_int	

make_one_int:
	push edx

	mov edx, OFFSET arrbuf
	call ParseInteger32

	mov [ebx], eax

	add ebx, TYPE IntArr

	inc cnt
	pop edx
	jmp Check_Loop
 
 make_one_and_end:
	push edx

	mov edx, OFFSET arrbuf
	call ParseInteger32
	
	mov [ebx], eax

	inc cnt
	pop edx
 jmp Arr_End

 increase_edx:
	inc edx
	jmp Check_Loop
	
  Arr_End:
	call Do_Mul

	ret
 Make_Array ENDP

 Do_Mul PROC
	mov esi, OFFSET IntArr

	call INITIAL_O ; initialize outbuf
	mov edi, OFFSET outbuf

	mov ecx, cnt ; cnt = �迭 ������ ����
	L1:
	push ecx

	xor eax, eax
	xor ebx, ebx
	mov eax, [esi]
	mov Check__, eax ; Check__ = �迭 ����

	imul eax, eax

	push edx
	push eax

	mov eax, Check__
	cdq
	idiv numbertwo

	pop eax
	cmp edx, 0
	je go_on

	neg eax ; Check__ �� Ȧ���� ���

	go_on:
	pop edx

	mov [esi], eax

	call IntToStr

	add esi, TYPE IntArr
	inc edi

	pop ecx
	loop L1

	mov BYTE PTR [edi], 0 ; outbuf �������� 0 ����

	ret
 Do_Mul ENDP
 
IntToStr PROC
;���� �迭�� ���ڿ��� �ٲٴ� �Լ�
	push eax
	push ebx
	push edx
	push esi

	mov esi, eax ; save eax
	;esi �� ���� ������ ���� ���� eax�� ������ ���� ����

	test eax, 80000000h; If eax is negative, make it positive
	jz P1;������ ����� ����̴�.
	
	neg eax

	P1:

	;������ ���ڿ��� ��ȯ�Ѵ�. �� ���� �ϳ��� ���ÿ� ����
	;123�� push 3,2,1 10���� ���� ������ ��� �̿�

	xor ecx, ecx
	;ecx�� ���ڿ��� ������
	;example: 123->"1230" ecx=3 , -123->"-1230" ecx=4

	mov ebx, 10
	;ebx�� ���� ����

	ConvLoop:

	cdq
	;edx�� eax�� ��ȣ ��Ʈ�� Ȯ���Ѵ�. ���� edx eax �̿�

	div ebx
	;edx eax �� ebx�� �����µ� ���� eax, �������� edx�� ����

	or dx, 0030h
	;�������� �ƽ�Ű ĳ���ͷ� ��ȯ
	;dx�� 16��Ʈ �̰� 0000 0000 0011 0000
	;or�� �Ѵ� 0�� ��츸 ����� 0�̴�.

	push dx
	;���ÿ� �ϴ� �����ص�

	inc ecx
	;������ ����

	cmp eax, 0;���� 0�� ���� ������ ����� ��
	jnz ConvLoop;ConvLoop�� ������ ���� ����̹Ƿ� �ݺ�

	mov ebx, ecx

	test esi, 80000000h ; add '-' if negative
	;esi�� ������ �� ������ ������ ����Ǿ� ����

	jz P2;������ ������ ����� ���

	mov BYTE PTR [edi], '-'
	inc edi
	inc ebx

	;ebx�� ������ ���� ����Ǿ� ���� ecx

	P2:

	RevLoop:
	;������ ó��
	pop ax
	mov [edi], al
	inc edi
	loop RevLoop

	mov al, SPACE_
	mov [edi], al
	;�������� space�� �ٿ���
	
	add num, ebx
	inc num

	pop esi
	pop edx
	pop ebx
	pop eax

	ret
IntToStr ENDP

INITIAL_F PROC
	push ecx
	push edx
	mov edx, OFFSET filestr
	mov ecx, LENGTHOF filestr
	L2:
		mov BYTE PTR [edx], 0
		add edx, TYPE filestr
	loop L2
	pop edx
	pop ecx
	ret
INITIAL_F ENDP

INITIAL_A PROC
	push ecx
	push edx
	mov edx, OFFSET IntArr
	mov ecx, LENGTHOF IntArr
	L3:
		mov DWORD PTR [edx], 0
		add edx, TYPE IntArr
	loop L3
	pop edx
	pop ecx
	ret
INITIAL_A ENDP

INITIAL_B PROC
	push ecx
	push edx
	mov edx, OFFSET arrbuf
	mov ecx, LENGTHOF arrbuf
	L4:
		mov BYTE PTR [edx], 0;initialize arrbuf
		add edx, TYPE arrbuf
	loop L4
	pop edx
	pop ecx
	ret
INITIAL_B ENDP 

INITIAL_O PROC
	push ecx
	push edx
	mov edx, OFFSET outbuf
	mov ecx, LENGTHOF outbuf
	L5:
		mov BYTE PTR [edx], 0
		add edx, TYPE outbuf
	loop L5
	pop edx
	pop ecx
	ret
INITIAL_O ENDP

Print_a_Line PROC
	mov edx, OFFSET outbuf
	mov ecx, num
	dec ecx
	INVOKE WriteFile , stdoutHandle, edx, ecx, 0, 0
	xor ecx, ecx
	call INITIAL_O
	ret
Print_a_Line ENDP
END main