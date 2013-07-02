#define  UNICODE
#define  _UNICODE
#include <windows.h>
#include "..\waffle.h"

int WINAPI argc()
{
    int intArg = 0;
    int i = -1;
    LPTSTR szCommandLine = GetCommandLine();
loop:
    i++;
    if (szCommandLine[i] == '\0')
        goto end;
    else if ((szCommandLine[i] == ' ') || (szCommandLine[i] == '\t'))
        goto loop;

    intArg++;
argloop:
    if (szCommandLine[i] == '\0')
        goto end;
    else if ((szCommandLine[i] == ' ') || (szCommandLine[i] == '\t'))
        goto loop;
    else if (szCommandLine[i] == '\"')
    {
        for (i++; szCommandLine[i] != '\"'; i++);
        i++;
        goto argloop;
    }
    i++;
    goto argloop;
end:
    return intArg;
}

LPCTSTR WINAPI argv(int intPosition, LPTSTR lpString, int intSize)
{
    int intArg = 0;
    BOOL FLAG;
    int i = -1, j = -1;
    LPTSTR szCommandLine = GetCommandLine();
loop:
    i++;
    if (szCommandLine[i] == '\0')
        goto end;
    else if ((szCommandLine[i] == ' ') || (szCommandLine[i] == '\t'))
        goto loop;

    intArg++;
    if (intArg == intPosition)
        FLAG = TRUE;
    else
        FLAG = FALSE;
argloop:
    if (szCommandLine[i] == '\0')
        goto end;
    else if ((szCommandLine[i] == ' ') || (szCommandLine[i] == '\t'))
        goto loop;
    else if (szCommandLine[i] == '\"')
    {
        i++;
        goto deliloop;
    }
    if ((intSize > 2) && (FLAG))
    {
        j++;
        lpString[j] = szCommandLine[i];
    }
    i++;
    goto argloop;
deliloop:
    if (szCommandLine[i] == '\0')
        goto end;
    else if (szCommandLine[i] == '\"')
    {
        i++;
        goto argloop;
    }
    if ((intSize > 2) && (FLAG))
    {
        j++;
        lpString[j] = szCommandLine[i];
    }
    i++;
    goto deliloop;
end:
    j++;
    lpString[j] = '\0';
    return 0;
}

LPCTSTR WINAPI argp(int intPosition)
{
    int intArg = 0;
    int i = -1;
    LPTSTR szCommandLine = GetCommandLine();
loop:
    i++;
    if (szCommandLine[i] == '\0')
        return NULL;
    else if ((szCommandLine[i] == ' ') || (szCommandLine[i] == '\t'))
        goto loop;

    intArg++;
    if (intArg == intPosition)
        return &szCommandLine[i];

argloop:
    if (szCommandLine[i] == '\0')
        return NULL;
    else if ((szCommandLine[i] == ' ') || (szCommandLine[i] == '\t'))
        goto loop;
    else if (szCommandLine[i] == '\"')
    {
        for (i++; szCommandLine[i] != '\"'; i++);
        i++;
        goto argloop;
    }
    i++;
    goto argloop;
}