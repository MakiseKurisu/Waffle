USE_HOOK_DISPATCHER	equ	1
		.const
bOriginalCode	db	90h,90h,90h,90h,90h,8Bh,0FFh
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_HotPatching	proc	uses ebx edi esi,_lpszDllName,_lpszProc,_lpNew,_lplpOri
		local	@hDll,@lpOldProc
		local	@OldProtect

;********************************************************************
;�������
;********************************************************************
		.if	!(_lpszDllName && _lpszProc && _lpNew)
			mov	eax,ERROR_INVALID_ADDRESS
			ret
		.endif
;********************************************************************
;��ú�����ַ
;********************************************************************
		invoke	GetModuleHandle,_lpszDllName
		.if	!eax
			mov	eax,ERROR_INVALID_NAME
			ret
		.else
			mov	@hDll,eax
		.endif

		invoke	GetProcAddress,eax,_lpszProc
		.if	!eax
			mov	eax,ERROR_INVALID_FUNCTION
			ret
		.else
			mov	@lpOldProc,eax
			mov	ebx,_lplpOri
			mov	[ebx],eax
			add	dword ptr [ebx],2	;����ֵ�Ѿ��ƹ��˺���ͷ��
		.endif
;********************************************************************
;�ж��Ƿ����Hot-Patching
;
;C2 XXXX	retn	XXXX		Addr-8
;90		nop			Addr-5
;90		nop
;90		nop
;90		nop
;90		nop
;8BFF		mov	edi,edi		Addr
;55		push	ebp		Addr+1
;8BEC		mov	ebp,esp		Addr+3
;********************************************************************
;bOriginalCode	db	90h,90h,90h,90h,90h,8Bh,0FFh
		mov	eax,@lpOldProc
		lea	esi,[eax-5]
		mov	edi,offset bOriginalCode
		mov	ecx,sizeof bOriginalCode
		cld
		repe	cmpsb
		.if	!ZERO?
			mov	eax,ERROR_NOT_SUPPORTED
			ret
		.endif
;********************************************************************
;�޸ķ�ҳ��������:R E->RWE
;********************************************************************
		mov	eax,@lpOldProc
		lea	edi,[eax-5]
		invoke	VirtualProtect,edi,7,PAGE_EXECUTE_READWRITE,addr @OldProtect
		.if	!eax
			mov	eax,ERROR_ACCESS_DENIED
			ret
		.endif
;********************************************************************
;д��Զ����ת
;bJmpFar	db	0E9h
;bCallNear	db	0E8h
;********************************************************************
ifdef		USE_HOOK_DISPATCHER
		mov	eax,0E8h
else
		mov	eax,0E9h
endif
		cld
		stosb
;********************************************************************
;����Jmp��ƫ��
;********************************************************************
		mov	eax,_lpNew
		sub	eax,edi
		sub	eax,4
		cld
		stosd
;********************************************************************
;д�����ת
;bJmpShort		db	0EBh,0F9h
;********************************************************************
		mov	word ptr [edi],0F9EBh
;********************************************************************
;�ָ���ҳ��������:RWE->R E
;********************************************************************
		mov	eax,@lpOldProc
		lea	edi,[eax-5]
		mov	ebx,@OldProtect
		invoke	VirtualProtect,edi,7,ebx,addr @OldProtect
		.if	!eax
			mov	eax,ERROR_CALL_NOT_IMPLEMENTED
			ret
		.endif

		mov	eax,ERROR_SUCCESS
		ret

_HotPatching	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_UnPatching	proc	uses ebx edi esi,_lpszDllName,_lpszProc
		local	@hDll,@lpOldProc
		local	@OldProtect

;********************************************************************
;�������
;********************************************************************
		.if	!(_lpszDllName && _lpszProc)
			mov	eax,ERROR_INVALID_ADDRESS
			ret
		.endif
;********************************************************************
;��ú�����ַ
;********************************************************************
		invoke	GetModuleHandle,_lpszDllName
		.if	!eax
			mov	eax,ERROR_INVALID_NAME
			ret
		.else
			mov	@hDll,eax
		.endif

		invoke	GetProcAddress,eax,_lpszProc
		.if	!eax
			mov	eax,ERROR_INVALID_FUNCTION
			ret
		.else
			mov	@lpOldProc,eax
		.endif
;********************************************************************
;�޸ķ�ҳ��������:R E->RWE
;********************************************************************
		invoke	VirtualProtect,@lpOldProc,2,PAGE_EXECUTE_READWRITE,addr @OldProtect
		.if	!eax
			mov	eax,ERROR_ACCESS_DENIED
			ret
		.endif
;********************************************************************
;�⹳
;********************************************************************
		mov	ebx,@lpOldProc
		mov	word ptr [ebx],0FF8Bh
;********************************************************************
;�ָ���ҳ��������:RWE->R E
;********************************************************************
		mov	edx,@OldProtect
		invoke	VirtualProtect,@lpOldProc,2,edx,addr @OldProtect
		.if	!eax
			mov	eax,ERROR_CALL_NOT_IMPLEMENTED
			ret
		.endif

		mov	eax,ERROR_SUCCESS
		ret

_UnPatching	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Dispatcher	proc
; ��ջʾ��	ebp=����ʱ��esp
;[ebp]		ԭ����EBP
;[ebp+4]	Hook����ѹ��ĺ�����ַ
;[ebp+8]	ԭ���õ�ַ
;[ebp+12]	ԭ���õĵ�һ������
;[ebp+16]	ԭ���õĵڶ�������
;[ebp+20]	ԭ���õĵ���������
;[ebp+24]	ԭ���õĵ��ĸ�����
		
		push	ebp
		mov	ebp,esp		
		
		;push	_P4
		push	[ebp+24]
		push	0
		push	[ebp+16]
		;push	_P1
		push	[ebp+12]
		call	lpMessageBoxA
		
		pop	ebp
		add	esp,4+4+4*4	;Hook���õ�ַ+ԭ���õ�ַ+����
		push	[esp-4-4*4]	;ѹ��ԭ���õ�ַ
		ret
_Dispatcher	endp