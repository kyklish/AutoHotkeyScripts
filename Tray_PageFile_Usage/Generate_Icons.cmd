@ECHO OFF
CD /D "%~dp0"

SET out=ICONS
IF NOT EXIST "%out%" MKDIR "%out%"

ECHO Generating icons from 00 to 99 in "%out%" folder...
FOR /L %%i IN  (0,1,9)  DO CALL :GenerateIcon 0%%i
FOR /L %%i IN (10,1,99) DO CALL :GenerateIcon  %%i

GOTO :EOF

:GenerateIcon
ECHO Icon %1
magick ^
 -background Black  -fill OrangeRed  -font Courier-New-Bold ^
 -size 16x16  -pointsize 16  -gravity center ^
 label:%1  %out%\%1.ico
EXIT /B
