@ECHO OFF
CD /D "%~dp0"

:: Compress with MPRESS
SET COMPILER=%SOFT_AHK%\Compiler
"%COMPILER%\Ahk2Exe.exe" ^
    /in "Services.ahk" ^
    /icon "Services.ico" ^
    /base "%COMPILER%\Unicode 64-bit.bin" ^
    /compress 1
