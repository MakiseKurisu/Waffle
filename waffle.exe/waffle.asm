		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
UNICODE		equ	TRUE

include		windows.inc
includelib	kernel32.lib
includelib	user32.lib

include		Console.inc
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
		.data?
hStdIn		dd	?	;����̨������
hStdOut		dd	?	;����̨������
hStdErr		dd	?	;����̨������
dwBytesRead	dd	?
dwBytesWrite	dd	?

uszBuf		dw	MAX_PATH dup (?)
		.const
uszTitle	dw	"Waffle v0.10",0
uszTest		dw	"ABC",0
uszTest2	dw	"DEF",0
uszFmt		dw	"%08X",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_CmdLine.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	_SetConsole,addr uszTitle
		invoke	_argc
		mov	ebx,eax
		invoke	wsprintf,addr uszBuf,addr uszFmt,eax
		invoke	lstrlen,addr uszBuf
		Coutn	uszBuf,eax
		Creturn
		.while	ebx
			dec	ebx
			invoke	_argv,ebx,addr uszBuf,sizeof uszBuf
			invoke	lstrlen,addr uszBuf
			Coutn	uszBuf,eax
			Creturn
		.endw
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start