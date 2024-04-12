#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

;!!! Configure FastStone Capture make ScreenShots by PrintScreen key, and save BMP files to R:\ with file name prefix "FastStoneCapture"
imageMagick := "E:\GAMES\ImageMagick\magick.exe"
scrDir := "R:" ; directory with ScreenShots from FastStone Capture
scrExt := "bmp" ; ScreenShot file extension
fileNamePrefix := "FastStoneCapture" ; file name prefix of ScreenShot file, it used to identify newly created picture
logFile :=scrDir "\MouseCoord.txt" ; log file with info about mouse click and screenshot
DefaultDirs := scrDir "\" ; output path for FindClick() function
PictureSizeImageMagick := 40
PictureSizeFindClick := 10

Insert:: ExitApp
!Insert:: Reload

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

ScrollLock:: ToggleTooltip()

^Numpad5:: FindClick(">" GetProcessName())
Numpad5:: FastStoneCaptureScreenShot()

; Make ScreenShot, Crop by ImageMagick, Save with X_Y in file name
FastStoneCaptureScreenShot()
{
	GetData()
	ToolTip

	if FileExist(imageMagick) {
		; picture parameters and parameters for ImageMagick
		pW := PictureSizeImageMagick ; width of crop zone
		pH := pW ; height -//-
		pX := mX - pW // 2 ; integer division (//) -> produce integer result
		pY := mY - pH // 2 ; XY -> upper left corner of crop zone

		FileDelete, %scrDir%\%fileNamePrefix%*.%scrExt%
		processName := GetProcessName()
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

	FileAppend, % mX . ", " . mY . ", " . mColor . "`n", %logFile%
	Clipboard := mX . ", " . mY . ", " . mColor
}

GetData()
{
	global mX, mY, mColor
	MouseGetPos, mX, mY
	PixelGetColor, mColor, %mX%, %mY%, RGB
	ToolTip % "X:" mX ", Y:" mY ", RGB:" mColor
}

GetProcessName()
{
	WinGet, processName, ProcessName, A
	return SubStr(processName, 1, -4) ; delete ".exe"
}

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
		FileAppend, % X1CL ", " Y1CL ", " X2CL ", " Y2CL . "`n", %logFile%
		Clipboard := X1CL ", " Y1CL ", " X2CL ", " Y2CL
	}
}

StopDrawRect()
{
	global LButton_Held := false
}

ToggleTooltip()
{
	static ToggleTooltip := False
	if (ToggleTooltip := !ToggleToolTip) {
		SetTimer, GetData, 100
	} else {
		SetTimer, GetData, Off
		ToolTip
	}
}

F1:: ShowHelpWindow("
(
Launch 'FastStone Capture' to save pictures
 Scroll Lock     -> Toggle show tooltip with info
 Numpad 2 4 6 8  -> Move cursor by one pixel orthogonally
 Numpad 1 3 7 9  -> Move cursor by one pixel diagonally
 Numpad 5        -> 'FastStone Capture' save coord, color, pic
^Numpad 5        -> 'FindClick()' save pic for ImageSearch
 Numpad 0 + Drag -> Draw rectangle, save to clipboard 'X1, Y1, X2, Y2'
     +LMB + Drag -> Draw rectangle, save to clipboard 'X1, Y1, X2, Y2'
!Insert          -> Reload Script
 Insert          ->   Exit Script

BUTTONS THAT LOOKS DIFFERENT WHEN THE MOUSE HOVERS
To work around this issue you need to check the box that says “Allow Offset” in
  the screenshot creator GUI. When you use this setting, the magnification box
  will move relative to where it was left when the script was last paused. This
  means you can pause the script, move the mouse, and then unpause the script so
  that the magnification area will not be right underneath the mouse, and you will
  be able to magnify the button as it looks without the mouse hovering over it.
)")
