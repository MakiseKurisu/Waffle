		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
stStartUp	STARTUPINFO	<?>
stProcessInfo	PROCESS_INFORMATION	<?>
lpLoadLibrary	dd	?
lpDllName	dd	?
szInjectDllFull	db	MAX_PATH dup (?)
szTargetFull	db	MAX_PATH dup (?)

		.const
szErrOpen	db	'ע��ʧ��,�޷���Զ���߳�',0
szSuccess	db	'ע��ɹ�',0
szDllKernel	db	'Kernel32.dll',0
szLoadLibrary	db	'LoadLibraryA',0
szInjectDll	db	'\Hooker.dll',0
szTarget	db	'\Target.exe',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
;********************************************************************
; ׼����������ȡdll��ȫ·���ļ�������ȡLoadLibrary������ַ��
;********************************************************************
		invoke	GetCurrentDirectory,MAX_PATH,addr szInjectDllFull
		invoke	lstrcat,addr szInjectDllFull,addr szInjectDll
		
		invoke	GetCurrentDirectory,MAX_PATH,addr szTargetFull
		invoke	lstrcat,addr szTargetFull,addr szTarget
		
		invoke	GetModuleHandle,addr szDllKernel
		invoke	GetProcAddress,eax,offset szLoadLibrary
		mov	lpLoadLibrary,eax
;********************************************************************
; ��������
;********************************************************************
		invoke	GetStartupInfo,addr stStartUp
		invoke	CreateProcess,NULL,addr szTargetFull,NULL,NULL,FALSE,CREATE_SUSPENDED,0,NULL,addr stStartUp,addr stProcessInfo
		.if	eax
;********************************************************************
; �ڽ����з���ռ䲢��DLL�ļ���������ȥ��Ȼ�󴴽�һ��LoadLibrary�߳�
;********************************************************************
			invoke	VirtualAllocEx,stProcessInfo.hProcess,NULL,MAX_PATH,MEM_COMMIT,PAGE_READWRITE
			.if	eax
				mov	lpDllName,eax
				invoke	WriteProcessMemory,stProcessInfo.hProcess,eax,offset szInjectDllFull,MAX_PATH,NULL
				invoke	CreateRemoteThread,stProcessInfo.hProcess,NULL,0,lpLoadLibrary,lpDllName,0,NULL
				invoke	CloseHandle,eax
			.endif
			invoke	MessageBox,NULL,addr szSuccess,NULL,NULL
			invoke	ResumeThread,stProcessInfo.hThread
			invoke	CloseHandle,stProcessInfo.hProcess
		.else
			invoke	MessageBox,NULL,addr szErrOpen,NULL,MB_OK or MB_ICONWARNING
		.endif
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
