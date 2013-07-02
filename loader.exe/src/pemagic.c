#define  UNICODE
#include <windows.h>
#include "..\loader.h"

#include <stdio.h>

WORD WINAPI GetPEMagic(LPVOID lpFile)
{
    WORD Magic = 0;
    if (((PIMAGE_DOS_HEADER)lpFile)->e_magic == IMAGE_DOS_SIGNATURE)                            //���ȳ��ֵ���DOS�ļ���־
    {
        PIMAGE_NT_HEADERS lpNtHeader = lpFile + ((PIMAGE_DOS_HEADER)lpFile)->e_lfanew;
        if (lpNtHeader->Signature == IMAGE_NT_SIGNATURE)                                        //��DOSͷ������PE�ļ�ͷ����λ��
        {
            if (lpNtHeader->FileHeader.Characteristics & IMAGE_FILE_DLL)
                printf("[0004]This file is a dll.\n");
                //DLL�ļ�
            else
                Magic = lpNtHeader->OptionalHeader.Magic;
        }
        else
            printf("[0003]This PE file is targeting another platform.\n");
            //DOS��OS/2��PE�ļ�
    }
    else
        printf("[0002]This is not a legal PE file.\n");
        //�����ļ�����
    
    return Magic;
}