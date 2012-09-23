;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 3rd Edition>
; by ���Ʊ�, http://www.win32asm.com.cn
; Edited by Excalibur, Support Unicode, Get the point
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _CmdLine.asm
; �����в���������ͨ���ӳ���
; ���ܣ�
; _argc ---> �������в�����������ͳ��
; _argv ---> ȡĳ�������в���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
CHAR_BLANK	equ	20h	;����ո�
CHAR_DELI	equ	'"'	;����ָ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ȡ�����в������� (arg count)
; ���������ض����ڵ��� 1, ���� 1 Ϊ��ǰִ���ļ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argc		proc	uses ebx esi edi
		local	@dwArgc

		mov	@dwArgc,0
		invoke	GetCommandLine
		mov	esi,eax
		cld
_argc_loop:
;********************************************************************
; ���Բ���֮��Ŀո�
;********************************************************************
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argc_end
			cmp	ax,CHAR_BLANK
			jz	_argc_loop
		else
			lodsb
			or	al,al
			jz	_argc_end
			cmp	al,CHAR_BLANK
			jz	_argc_loop
		endif
;********************************************************************
; һ��������ʼ
;********************************************************************
		ifdef	UNICODE
			dec	esi
			dec	esi
		else
			dec	esi
		endif
		inc	@dwArgc
_argc_loop1:
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argc_end
			cmp	ax,CHAR_BLANK
			jz	_argc_loop		;��������
			cmp	ax,CHAR_DELI
			jnz	_argc_loop1		;���������������
		else
			lodsb
			or	al,al
			jz	_argc_end
			cmp	al,CHAR_BLANK
			jz	_argc_loop		;��������
			cmp	al,CHAR_DELI
			jnz	_argc_loop1		;���������������
		endif
;********************************************************************
; ���һ�������е�һ�����пո�,���� " " ����
;********************************************************************
		@@:
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argc_end
			cmp	ax,CHAR_DELI
			jnz	@B
			jmp	_argc_loop1
		else
			lodsb
			or	al,al
			jz	_argc_end
			cmp	al,CHAR_DELI
			jnz	@B
			jmp	_argc_loop1
		endif
_argc_end:
		mov	eax,@dwArgc
		ret

_argc		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ȡָ��λ�õ������в���
;  argv 0 = ִ���ļ���
;  argv 1 = ����1 ...
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argv		proc	uses ebx esi edi _dwArgv,_lpReturn,_dwSize
		local	@dwArgv,@dwFlag

		inc	_dwArgv
		mov	@dwArgv,0
		mov	edi,_lpReturn

		invoke	GetCommandLine
		mov	esi,eax
		cld
_argv_loop:
;********************************************************************
; ���Բ���֮��Ŀո�
;********************************************************************
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argv_end
			cmp	ax,CHAR_BLANK
			jz	_argv_loop
		else
			lodsb
			or	al,al
			jz	_argv_end
			cmp	al,CHAR_BLANK
			jz	_argv_loop
		endif
;********************************************************************
; һ��������ʼ
; �����Ҫ��Ĳ�������,��ʼ���Ƶ����ػ�����
;********************************************************************
		ifdef	UNICODE
			dec	esi
			dec	esi
		else
			dec	esi
		endif
		inc	@dwArgv
		mov	@dwFlag,FALSE
		mov	eax,_dwArgv
		cmp	eax,@dwArgv
		jnz	@F
		mov	@dwFlag,TRUE
		@@:
_argv_loop1:
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argv_end
			cmp	ax,CHAR_BLANK
			jz	_argv_loop		;��������
			cmp	ax,CHAR_DELI
			jz	_argv_loop2
			cmp	_dwSize,2
			jle	@F
			cmp	@dwFlag,TRUE
			jne	@F
			stosw
			dec	_dwSize
			dec	_dwSize
		else
			lodsb
			or	al,al
			jz	_argv_end
			cmp	al,CHAR_BLANK
			jz	_argv_loop		;��������
			cmp	al,CHAR_DELI
			jz	_argv_loop2
			cmp	_dwSize,1
			jle	@F
			cmp	@dwFlag,TRUE
			jne	@F
			stosb
			dec	_dwSize
		endif
		@@:
		jmp	_argv_loop1		;���������������

_argv_loop2:
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argv_end
			cmp	ax,CHAR_DELI
			jz	_argv_loop1
			cmp	_dwSize,2
			jle	@F
			cmp	@dwFlag,TRUE
			jne	@F
			stosw
			dec	_dwSize
			dec	_dwSize
		else
			lodsb
			or	al,al
			jz	_argv_end
			cmp	al,CHAR_DELI
			jz	_argv_loop1
			cmp	_dwSize,1
			jle	@F
			cmp	@dwFlag,TRUE
			jne	@F
			stosb
			dec	_dwSize
		endif
		@@:
		jmp	_argv_loop2
_argv_end:
		xor	eax,eax
		ifdef	UNICODE
			stosw
		else
			stosb
		endif
		ret

_argv		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����ָ��λ�õ������в�����ַ
;  argp 0 = ִ���ļ���
;  argp 1 = ����1 ...
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argp		proc	uses ebx esi edi _dwArgp
		local	@dwArgp

		xor	eax,eax
		mov	@dwArgp,eax
		mov	ecx,_dwArgp
		inc	ecx
		invoke	GetCommandLine
		mov	esi,eax
		cld
_argp_loop:
;********************************************************************
; ���Բ���֮��Ŀո�
;********************************************************************
		ifdef	UNICODE
			lodsw
			or	ax,ax
			jz	_argp_end
			cmp	ax,CHAR_BLANK
			jz	_argp_loop
		else
			lodsb
			or	al,al
			jz	_argp_end
			cmp	al,CHAR_BLANK
			jz	_argp_loop
		endif
;********************************************************************
; һ��������ʼ
;********************************************************************
		ifdef	UNICODE
			dec	esi
			dec	esi
		else
			dec	esi
		endif
		inc	@dwArgp
		.if	ecx ==	@dwArgp
			jmp	_argp_end
		.endif
;********************************************************************
; ��ȡ�ַ�
;********************************************************************
		ifdef	UNICODE
			.while	TRUE
				lodsw
				cmp	ax,CHAR_BLANK
				jz	_argp_loop
				.if	ax ==	CHAR_DELI
					inc	eax
					.while	ax
						.break	.if ax == CHAR_DELI
						lodsw
					.endw
				.endif
				.break	.if ax == NULL
			.endw
		else
			.while	TRUE
				lodsb
				cmp	al,CHAR_BLANK
				jz	_argp_loop
				.if	al ==	CHAR_DELI
					inc	eax
					.while	al
						.break	.if al == CHAR_DELI
						lodsb
					.endw
				.endif
				.break	.if al == NULL
			.endw
		endif
;********************************************************************
; ����
;********************************************************************
_argp_end:
		ifdef	UNICODE
			.if	ax
				mov	eax,esi
			.else
				xor	eax,eax
			.endif
		else
			.if	al
				mov	eax,esi
			.else
				xor	eax,eax
			.endif

		endif
		ret

_argp		endp
