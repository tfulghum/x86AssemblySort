@echo off
cls

set EXE_NAME=selection_sort
del %EXE_NAME%.exe
del %EXE_NAME%.obj
del %EXE_NAME%.lst
del %EXE_NAME%.ilk
del %EXE_NAME%.pdb

set DRIVE_LETTER=%1:
set PATH=%DRIVE_LETTER%\Assembly\bin;c:\Windows
set INCLUDE=%DRIVE_LETTER%\Assembly\include
set LIB_DIRS=%DRIVE_LETTER%\Assembly\lib
set LIBS=str_utils.obj

ml -Zi -c -coff -Fl selection_sort.asm
ml -Zi -c -coff -Fl sort.asm
link /libpath:%LIB_DIRS% sort.obj selection_sort.obj %LIBS% io.obj kernel32.lib /debug /out:%EXE_NAME%.exe /subsystem:console /entry:start
%EXE_NAME% <strings.txt
