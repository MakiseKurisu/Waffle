		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
includelib	kernel32.lib

include		Unicode.inc
include		Strings.mac
UNICODE		equ	TRUE
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
		.data?
hStdIn		dd	?	;����̨������
hStdOut		dd	?	;����̨������
dwBytesRead	dd	?
dwBytesWrite	dd	?
dwOutPut	dd	?
		.const
sz0Dh		db	0dh
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		CmdLine.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetStdHandle,STD_INPUT_HANDLE
		mov	hStdIn,eax
		invoke	GetStdHandle,STD_OUTPUT_HANDLE
		mov	hStdOut,eax
lop:
		invoke	WriteFile,hStdOut,addr sz0Dh,1,addr dwBytesWrite,NULL
		invoke	WriteFile,hStdOut,$CTA0('����'),4,addr dwBytesWrite,NULL
		invoke	Sleep,1000
		invoke	WriteFile,hStdOut,addr sz0Dh,1,addr dwBytesWrite,NULL
		invoke	WriteFile,hStdOut,$CTA0('����'),4,addr dwBytesWrite,NULL
		invoke	Sleep,1000
		jmp	lop
		invoke	Sleep,5000
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start