TITLE
;(단독)20181668 이예진
;Program Descriprion: Square
;Input: string
;Output: string
INCLUDE irvine32.inc

.data
outbuf BYTE 2048 DUP(0)
rnum BYTE 0;읽은 글자의 개수
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
cnt DWORD 0;배열 원소의 개수
arrbuf BYTE 1024 DUP(0)
num DWORD 0;outbuf 글자 개수
filestr BYTE 2048 DUP(0)

.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

A_LINE:
	call Read_a_Line
	cmp rflg, 0;cr 혹은 lf만 읽은 경우
	je THEEND

	cmp iflg, 0;숫자를 하나도 읽지 않은 경우
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

	mov iflg, 1;숫자 적어도 1개 입력을 받은 경우

	NEQNUM:

	mov [edx], bl

	inc edx
	mov rflg,1
	inc rnum

	jmp Read_Loop

  Read_End:

	cmp iflg, 0 ; 숫자를 읽지 않은 경우
	je Only_space

	cmp rflg, 0;아무 것도 읽지 않은 경우
	je Only_space

	mov BYTE PTR [edx], 0 ;append 0 at the end

	GOMAKEARR:
		call Make_Array

	Only_space:
	ret
Read_a_Line ENDP

 Make_Array PROC
	mov cnt, 0

	mov edx, OFFSET filestr ;edx에는 read_a_line에서 입력 받은 문자열

	call INITIAL_A ;initialize IntArr
	mov ebx, OFFSET IntArr;ebx에는 배열의 주소
  	call INITIAL_B ;initialize arrbuf
	xor ecx, ecx
 Check_Loop :

	xor eax, eax

	mov eax, [edx]

	cmp eax, 0 ; 문자열 끝
	je	Arr_End
	
	cmp al, SPACE_
	je increase_edx ; space 이면 무시
	
	cmp al, TAB_
	je increase_edx ; tab 이면 무시

	call INITIAL_B
	mov esi, OFFSET arrbuf

	xor ecx, ecx ; buffer size
	
one_int :
	mov [esi], al

	inc ecx
	
	inc edx ; '-' or 숫자를 처음에 읽고나서 다음글자를 읽기 위해서

	xor eax, eax
	mov eax, [edx]
	
	cmp al, SPACE_ ; 숫자의 끝
	je make_one_int

	cmp al, TAB_ ; 숫자의 끝
	je make_one_int
	
	cmp eax, 0 ; 문자열의 끝
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

	mov ecx, cnt ; cnt = 배열 원소의 개수
	L1:
	push ecx

	xor eax, eax
	xor ebx, ebx
	mov eax, [esi]
	mov Check__, eax ; Check__ = 배열 원소

	imul eax, eax

	push edx
	push eax

	mov eax, Check__
	cdq
	idiv numbertwo

	pop eax
	cmp edx, 0
	je go_on

	neg eax ; Check__ 가 홀수인 경우

	go_on:
	pop edx

	mov [esi], eax

	call IntToStr

	add esi, TYPE IntArr
	inc edi

	pop ecx
	loop L1

	mov BYTE PTR [edi], 0 ; outbuf 마지막에 0 삽입

	ret
 Do_Mul ENDP
 
IntToStr PROC
;정수 배열을 문자열로 바꾸는 함수
	push eax
	push ebx
	push edx
	push esi

	mov esi, eax ; save eax
	;esi 는 원래 정수의 값을 저장 eax는 나누는 동안 변함

	test eax, 80000000h; If eax is negative, make it positive
	jz P1;정수가 양수인 경우이다.
	
	neg eax

	P1:

	;정수를 문자열로 변환한다. 각 문자 하나씩 스택에 저장
	;123을 push 3,2,1 10으로 나눈 나머지 방법 이용

	xor ecx, ecx
	;ecx는 문자열의 사이즈
	;example: 123->"1230" ecx=3 , -123->"-1230" ecx=4

	mov ebx, 10
	;ebx로 나눌 것임

	ConvLoop:

	cdq
	;edx에 eax의 부호 비트를 확장한다. 보통 edx eax 이용

	div ebx
	;edx eax 를 ebx로 나누는데 몫은 eax, 나머지는 edx에 저장

	or dx, 0030h
	;나머지를 아스키 캐릭터로 변환
	;dx는 16비트 이고 0000 0000 0011 0000
	;or은 둘다 0인 경우만 결과가 0이다.

	push dx
	;스택에 일단 저장해둠

	inc ecx
	;글자의 개수

	cmp eax, 0;몫이 0인 경우는 끝까지 계산한 것
	jnz ConvLoop;ConvLoop은 끝나지 않은 경우이므로 반복

	mov ebx, ecx

	test esi, 80000000h ; add '-' if negative
	;esi는 나누기 전 원래의 정수가 저장되어 있음

	jz P2;원래의 정수가 양수인 경우

	mov BYTE PTR [edi], '-'
	inc edi
	inc ebx

	;ebx에 글자의 수가 저장되어 있음 ecx

	P2:

	RevLoop:
	;마지막 처리
	pop ax
	mov [edi], al
	inc edi
	loop RevLoop

	mov al, SPACE_
	mov [edi], al
	;마지막에 space를 붙여줌
	
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