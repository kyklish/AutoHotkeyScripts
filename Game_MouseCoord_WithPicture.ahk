#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()


;!!! Configure FastStone Capture make ScreenShots by PrintScreen key, and save BMP files to R:\ with file name prefix "FastStoneCapture"
imageMagick := "E:\GAMES\ImageMagick\magick.exe"
scrDir := "R:" ; directory with ScreenShots from FastStone Capture
scrExt := "bmp" ; ScreenShot file extension
fileNamePrefix := "FastStoneCapture" ; file name prefix of ScreenShot file, it used to identify newly created picture

Numpad5:: ; make ScreenShot with FastStone Capture, crop it with ImageMagick and save with coordinates X_Y in file name
GetData()
ToolTip ; remove tooltip

/* This is version for FRAPS
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
Clipboard := mX . ", " . mY . ", " . mColor
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


;Left:: MouseMove, -1,  0, , R
;Right::MouseMove,  1,  0, , R
;Up::   MouseMove,  0, -1, , R
;Down:: MouseMove,  0,  1, , R


Numpad4::MouseMove, -1,  0, , R
Numpad6::MouseMove,  1,  0, , R
Numpad8::MouseMove,  0, -1, , R
Numpad2::MouseMove,  0,  1, , R
Numpad7::MouseMove, -1, -1, , R
Numpad9::MouseMove,  1, -1, , R
Numpad1::MouseMove, -1,  1, , R
Numpad3::MouseMove,  1,  1, , R


 Numpad0::
+LButton:: StartDrawRect()
 Numpad0 Up::
+LButton Up:: StopDrawRect()


StartDrawRect()
{
	global LButton_Held
	id := "MouseCoord"
	if (!LButton_Held)
	{
		LButton_Held := true
		MouseGetPos, X1CL, Y1CL
		JEE_ClientToScreen(WinExist("A"), X1CL, Y1CL, X1SC, Y1SC)
		Loop {
			MouseGetPos, X2CL, Y2CL
			JEE_ClientToScreen(WinExist("A"), X2CL, Y2CL, X2SC, Y2SC)
			DrawRectangle(X1SC, Y1SC, X2SC, Y2SC, id)
			ToolTip, % "X1:" X1CL " Y1:" Y1CL " X2:" X2CL " Y2:" Y2CL
			if (LButton_Held == false)
				break
		}
		DestroyRectangle(id)
		ToolTip
		FileAppend, % X1CL ", " Y1CL ", " X2CL ", " Y2CL . "`n", R:\MouseCoord.txt ; or %A_ScriptFullPath%
		Clipboard := X1CL ", " Y1CL ", " X2CL ", " Y2CL
	}
}


StopDrawRect()
{
	global LButton_Held := false
}


F1:: ShowHelpWindow("
(
Launch 'FastStone Capture' to save pictures
Scroll Lock     -> Toggle show tooltip with info
Numpad 2 4 6 8  -> Move cursor by one pixel orthogonally
Numpad 1 3 7 9  -> Move cursor by one pixel diagonally
Numpad 5        -> Save coord, color, pic
Numpad 0 + Drag -> Draw rectangle, save to clipboard
    +LMB + Drag -> Draw rectangle, save to clipboard
!Insert         -> Reload Script
 Insert         -> Exit Script
)")


Insert:: ExitApp
!Insert:: Reload
