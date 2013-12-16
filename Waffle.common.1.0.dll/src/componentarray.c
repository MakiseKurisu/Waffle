﻿#include "..\common.h"

LIBRARY_EXPORT HMODULE WINAPI WaffleLoadComponent(
    _In_    LPCTSTR lpszComponent
    )
{
    HMODULE hComponent = GetModuleHandle(lpszComponent);
    if (hComponent)
    {
        return hComponent;
    }

    TCHAR szComponent[MAX_PATH];
    wsprintf(szComponent, TEXT("%s\\%s\\%s\\%s"), lpstProcessSetting->szComponentDirectory, lpstProcessSetting->szComponent, WAFFLE_PORT_MACHINE_STRING, lpszComponent);
    hComponent = LoadLibrary(szComponent);
    LPCOMPONENTINIT ComponentInit = (LPCOMPONENTINIT) WaffleGetProcAddress(hComponent, TEXT("ComponentInit"));
    if (!ComponentInit)
    {
        FreeLibrary(hComponent);
        return NULL;
    }
    else
    {
        WaffleAddComponent(lpszComponent);
        ComponentInit(lpstProcessSetting);  //should respect the return value
    }
    return hComponent;
}

LIBRARY_EXPORT VOID WINAPI WaffleAddComponent(
    _In_    LPCTSTR lpszComponent
    )
{
    WAFFLE_COMPONENT_ARRAY stNewComponent;
    RtlZeroMemory(&stNewComponent, sizeof(WAFFLE_COMPONENT_ARRAY));
    stNewComponent.hSource = GetModuleHandle(lpszComponent);
    if (stNewComponent.hSource)
    {
        stNewComponent.lpszComponent = lpszComponent;
        stNewComponent.hSourceEnd = (SIZE_T) stNewComponent.hSource + WaffleGetImageSize(stNewComponent.hSource);
    }
    else
    {
        return;
    }

    if (!lpstProcessSetting->lpstComponent)
    {
        lpstProcessSetting->lpstComponent = (LPWAFFLE_COMPONENT_ARRAY) GlobalAlloc(GPTR, sizeof(WAFFLE_COMPONENT_ARRAY));
        if (!lpstProcessSetting->lpstComponent)
        {
            MessageBox(0, TEXT("FIXME:Unable to allocate memory to create component array"), 0, 0);
            ExitProcess(0);
        }
    }
    else
    {
        int i;
        for (i = lpstProcessSetting->lpstComponent[0].dwBehind; i >= 0; i--)
        {
            lpstProcessSetting->lpstComponent[i].dwBehind++;
        }
        lpstProcessSetting->lpstComponent = (LPWAFFLE_COMPONENT_ARRAY) GlobalReAlloc(lpstProcessSetting->lpstComponent, sizeof(WAFFLE_COMPONENT_ARRAY) * (lpstProcessSetting->lpstComponent[0].dwBehind + 1), GHND);
        if (!lpstProcessSetting->lpstComponent)
        {
            MessageBox(0, TEXT("FIXME:Unable to add elements in component array"), 0, 0);
            ExitProcess(0);
        }
    }

    RtlMoveMemory(&lpstProcessSetting->lpstComponent[lpstProcessSetting->lpstComponent[0].dwBehind], &stNewComponent, sizeof(WAFFLE_COMPONENT_ARRAY));
}

LIBRARY_EXPORT int WINAPI WaffleFindComponent(
    _In_    LPVOID lpMemory
    )
{
    int i;
    for (i = lpstProcessSetting->lpstComponent[0].dwBehind; i >= 0; i--)
    {
        if (((SIZE_T) lpMemory >= (SIZE_T) lpstProcessSetting->lpstComponent[i].hSource) && ((SIZE_T) lpMemory <= lpstProcessSetting->lpstComponent[i].hSourceEnd))
        {
            return i;
        }
    }
    return -1;
}