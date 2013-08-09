#ifndef  UNICODE
#define  UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif
#include "..\..\common.h"
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma GCC diagnostic ignored "-Wunused-parameter"

#if (WAFFLE_PORT_MACHINE == WAFFLE_PORT_MACHINE_I386)
LIBRARY_EXPORT BOOL WINAPI WaffleInlineDetour(
    _In_    LPBYTE  lpFunction
    )
{
    LPBYTE lpHotpatch = lpFunction - 5;
    LPBYTE Signature = (LPBYTE)"\x90\x90\x90\x90\x90\x8B\xFF";
    int i;
    for (i = 0; i < 7; i++)
    {
        if (lpHotpatch[i] != Signature[i])
        {
            return FALSE;
        }
    }

    DWORD flOldProtect;
    VirtualProtect(lpHotpatch, 7, PAGE_EXECUTE_READWRITE, &flOldProtect);

    lpHotpatch[0] = 0xE8;    //call
    *(LPDWORD) &lpHotpatch[1] = (DWORD) WaffleInlineHandler - (DWORD) lpFunction;
    *(LPWORD) &lpHotpatch[5] = 0xF9EB;    //jmp $-7

    FlushInstructionCache(GetCurrentProcess(), lpHotpatch, 7);
    VirtualProtect(lpHotpatch, 7, flOldProtect, &flOldProtect);

    return TRUE;
}
#else
LIBRARY_EXPORT BOOL WINAPI WaffleInlineDetour(
    _In_    LPBYTE  lpFunction
    )
{
    return FALSE;
}
#endif

LIBRARY_EXPORT NOINLINE LPVOID WINAPI WaffleGetCallersAddress(
    _Out_   LPVOID *CallersCaller
    )
{
#if     defined(__GNUC__)
    LPVOID ReturnAddress = __builtin_return_address(0);
#endif

#if     defined(_MSC_VER)
#if     WAFFLE_PORT_MACHINE == WAFFLE_PORT_MACHINE_I386
    LPVOID FramePointer = (&CallersCaller)[-2];
    LPVOID ReturnAddress = ((LPVOID *) (FramePointer))[1];
#elif   WAFFLE_PORT_MACHINE == WAFFLE_PORT_MACHINE_AMD64
    LPVOID ReturnAddress = (&CallersCaller)[-1];
#endif
#endif

    if (CallersCaller)
    {
        *CallersCaller = ReturnAddress;
    }

    return ReturnAddress;
}

#pragma GCC push_options
#pragma GCC optimize ("O0")
#pragma optimize("", off)
//Using cdecl so there is no code to clean the stack in the epilogue
LIBRARY_EXPORT VOID __cdecl WaffleInlineHandler(
    _In_    SIZE_T *lpReserved
    )
{
    // ebp-c Argc0
    // ebp-8 CallerReturnAddress <== (&lpReserved)[0]
    // ebp-4 HotpatchReturnAddress <== (&lpReserved)[-1]
    // ebp   EBP <== (&lpReserved)[-2]
    // ebp+4 EBX <== (&lpReserved)[-3] GCC pushes ebx, so we have to leave the space for it
    // ebp+8 local variable <== (&lpReserved)[-4] This variable will be overwritten once we called a function. Treat it like treating EAX.

    (&lpReserved)[-4] = (SIZE_T *) WaffleFindDetourAddress((SIZE_T *) (&lpReserved)[-1], (SIZE_T *) (&lpReserved)[0]);
    if ((&lpReserved)[-4])
    {
        (&lpReserved)[-1] = (&lpReserved)[-4];
        return;
    }
    else
    {
        (&lpReserved)[-1] = (SIZE_T *) ((SIZE_T) (&lpReserved)[-1] + 2); //HotpatchReturnAddress += 2
        return;
    }
}
#pragma optimize("", on)
#pragma GCC pop_options