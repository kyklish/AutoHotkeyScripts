#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()


;!!! Configure FastStone Capture make ScreenShots by PrintScreen key, and save BMP files to R:\ with file name prefix "FastStoneCapture"
imageMagick := "E:\GAMES\ImageMagick\magick.exe"
scrDir := "R:" ; directory with ScreenShots from FastStone Capture
scrExt := "bmp" ; ScreenShot file extension
fileNamePrefix := "FastStoneCapture" ; file name prefix of ScreenShot file, it used to identify newly created picture

Insert:: ; make ScreenShot with FastStone Capture, crop it with ImageMagick and save with coordinates X_Y in file name
GetData()
ToolTip ; remove tooltip

/* This is verion for FRAPS
if FileExist(imageMagick) {
	; picture parameters and parameters for ImageMagick
	pW := 40 ; width of crop zone
	pH := pW ; height -//-
	pX := mX - pW // 2 ; integer division (//) -> produce integer result
	pY := mY - pH // 2 ; XY -> upper left corner of crop zone
	
	FileDelete, %scrDir%\*.%scrExt%
	WinGet, processName, ProcessName, A
	processName := SubStr(processName, 1, -4) ; delete ".exe"
	Send, {PrintScreen} ; configure FRAPS make ScreenShots by PrintScreen key, and save BMP files to R:\
	Loop, 10 ; wait 10*100ms for file with ScreenShot
	{
		Sleep, 100
		if FileExist(scrDir . processName . "*." . scrExt) {
			Loop, Files, %scrDir%\%processName%*.%scrExt%
			{
				newFileName := scrDir . "\" . SubStr(A_LoopFileName, 1, -4) . " " . mX . "_" . mY . ".png" ; important to use different image type, than source
				command = %A_ComSpec% /c %imageMagick% "%A_LoopFileLongPath%[%pW%x%pH%+%pX%+%pY%]" "%newFileName%" ; crop picture, while loading, convert and save with new name
				;ToolTip % command . "`n" . processName, 0, 0
				RunWait, %command%,, Hide
				FileDelete, %A_LoopFileLongPath%
			}
			break
		}
	}
}
*/

if FileExist(imageMagick) {
	; picture parameters and parameters for ImageMagick
	pW := 40 ; width of crop zone
	pH := pW ; height -//-
	pX := mX - pW // 2 ; integer division (//) -> produce integer result
	pY := mY - pH // 2 ; XY -> upper left corner of crop zone
	
	FileDelete, %scrDir%\%fileNamePrefix%*.%scrExt%
	WinGet, processName, ProcessName, A
	processName := SubStr(processName, 1, -4) ; delete ".exe"
	Send, {PrintScreen} ; configure FastStone Capture make ScreenShots by PrintScreen key, and save BMP files to R:\
	Loop, 10 ; wait 10*100ms for file with ScreenShot
	{
		Sleep, 100
		if FileExist(scrDir . "\" . fileNamePrefix . "*." . scrExt) {
			Loop, Files, %scrDir%\%fileNamePrefix%*.%scrExt%
			{
				newFileName := scrDir . "\" . processName . "-" . SubStr(A_LoopFileName, 1, -4) . " " . mX . "_" . mY . ".png" ; important to use different image type, than source
				command = %A_ComSpec% /c %imageMagick% "%A_LoopFileLongPath%[%pW%x%pH%+%pX%+%pY%]" "%newFileName%" ; crop picture, while loading, convert and save with new name
				;ToolTip % command . "`n" . processName, 0, 0
				RunWait, %command%,, Hide
				FileDelete, %A_LoopFileLongPath%
			}
			break
		}
	}
}

FileAppend, % mX . ", " . mY . ", " . mColor . "`n", R:\MouseCoord.txt ; or %A_ScriptFullPath%
Clipboard := mX . ", " . mY
return


ScrollLock::
if (ToggleTooltip := !ToggleToolTip) {
	SetTimer, UpdateTooltip, 250
} else {
	SetTimer, UpdateToolTip, Off
	ToolTip
}
return


UpdateTooltip:
GetData()
return


GetData()
{
	global mX, mY, mColor
	MouseGetPos, mX, mY
	PixelGetColor, mColor, %mX%, %mY%, RGB
	ToolTip % mX ", " mY ", " mColor
}


;Left::MouseMove, -1, 0, , R
;Right::MouseMove, 1, 0, , R
;Up::MouseMove, 0, -1, , R
;Down::MouseMove, 0, 1, , R

Numpad4::MouseMove, -1, 0, , R
Numpad6::MouseMove, 1, 0, , R
Numpad8::MouseMove, 0, -1, , R
Numpad2::MouseMove, 0, 1, , R
Numpad5::GoTo Insert

F1:: ShowHelpWindow("
(
Launch 'FastStone Capture' to save pictures
Insert         -> Save coord, color, pic
Scroll Lock    -> Toggle show tooltip with info
Numpad 2 4 6 8 -> Move cursor by one pixel
Numpad 5       -> Save coord, color, pic
)")


!x:: ExitApp
!z:: Reload