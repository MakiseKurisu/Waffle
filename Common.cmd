call	:%*
goto	ExitProcess
:StartUp
set	Machine=%1
if	"%1" == ""	(
	set	Machine=I386
	)

echo	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo	%Project% %Machine% version
echo	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

pushd	%~dp0

set	OUTPUT_PATH=%~dp0..\WaffleNightly
set	SDK=%OUTPUT_PATH%\SDK
if	"%Machine%" == "I386"	(
	set	MinGW=D:\mingw32\i686-w64-mingw32
	set	libgcc=D:\mingw32\lib\gcc\i686-w64-mingw32\4.8.1\libgcc.a
	)
if	"%Machine%" == "AMD64"	(
	set	MinGW=D:\mingw64\x86_64-w64-mingw32
	set	libgcc=D:\mingw64\lib\gcc\x86_64-w64-mingw32\4.8.1\libgcc.a
	)

set	path=%MinGW%\..\bin;%windir%\System32;%~dp0
set	include=%MinGW%\..\include;%MinGW%\include;%SDK%\include
set	C_INCLUDE_PATH=%include%
set	lib=%MinGW%\..\lib;%MinGW%\lib;%SDK%\lib\%Machine%
set	LIBRARY_PATH=%lib%
goto	ExitProcess
:ChangeDirectory
echo	===============================================================================
echo	Build	%1
echo	===============================================================================
cd	%1
goto	ExitProcess
:Compile
echo	gcc	%1
gcc	-O3 -c -Wall -Wextra -fno-stack-check -fno-stack-protector -mno-stack-arg-probe %1
goto	ExitProcess
:CleanUp
del	*.o 2>nul
cd	..
goto	ExitProcess
:ExitProcess