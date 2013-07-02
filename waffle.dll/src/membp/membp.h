#ifndef __MEMBP_H_
#define __MEMBP_H_

#ifdef __cplusplus
extern "C" {
#endif

HMODULE WINAPI GetModuleAddressW(
  _In_  LPCWSTR lpszModule
);

HMODULE WINAPI CopyLibrary(
  _In_  HMODULE hModule
);

HMODULE WINAPI CopyLibraryEx(
  _In_  LPLIBRARY_TABLE_OBJECT stLibrary
);

LPVOID WINAPI GetFunctionAddressA(
  _In_  HMODULE hDll,
  _In_  LPCSTR lpszFuncName
);

LONG CALLBACK BreakpointHandler(
  _In_  PEXCEPTION_POINTERS ExceptionInfo
);

#ifdef __cplusplus
};
#endif

#endif /* __MEMBP_H_ */