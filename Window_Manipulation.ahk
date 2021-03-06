﻿#Include <_COMMON_SETTINGS_>

;======================================================================
;Передвигаем окна с зажатой клавишей Win + левая мышь
;======================================================================
#LButton::
CoordMode, Mouse
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetClass, EWD_Win_Class, ahk_id %EWD_MouseWin%
If EWD_Win_Class = ProgMan
	Return
WinGet, State, MinMax, ahk_id %EWD_MouseWin%
If State = 1
{
	SplashImage,, W160 H27 B1 FM8 WM400 CT000080,, Окно максимизировано,, Calibri
	SetTimer, Remove_Splash, 600
	Return
	
	Remove_Splash:
	SetTimer, Remove_Splash, Off
	SplashImage, Off
	Return
}
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
SetTimer, EWD_WatchMouse, 10
Return

EWD_WatchMouse:
EWD_Work = 1
GetKeyState, EWD_LButtonState, LButton, P
If EWD_LButtonState = U
{
	SetTimer, EWD_WatchMouse, off
	EWD_Work =
	Return
}
GetKeyState, EWD_EscapeState, Escape, P
If EWD_EscapeState = D
{
	SetTimer, EWD_WatchMouse, off
	EWD_Work =
	WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
	Return
}
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX
EWD_MouseStartY := EWD_MouseY
Return


;======================================================================
;Изменяем размер окон правой кнопкой мыши с зажатой клавишей Win
;======================================================================
LWin & RButton::
CoordMode, Mouse ; Switch to screen/absolute coordinates.
MouseGetPos, SWM_MouseStartX, SWM_MouseStartY, SWM_MouseWin
WinGetPos, SWM_WinX, SWM_WinY, SWM_WinW, SWM_WinH, ahk_id %SWM_MouseWin%
WinGetClass, SWM_Win_Class, ahk_id %SWM_MouseWin%
If SWM_Win_Class = ProgMan
	Return
WinGet, State, MinMax, ahk_id %SWM_MouseWin%
If State = 1
{
	SplashImage,, W160 H26 B1 FM8 WM400 CT000080,, Окно максимизировано,, Calibri
	SetTimer, Remove_Splash, 600
	Return
}
GetKeyState, SMW_LCtrlState, LCtrl
if SMW_LCtrlState=D
{
	WinClose, ahk_id %SWM_MouseWin%
	return
}
SWM_ResizeTypeX=0
SWM_ResizeTypeY=0
if (SWM_MouseStartX < SWM_WinX+SWM_WinW/2)
	SWM_ResizeTypeX=1
if (SWM_MouseStartY < SWM_WinY+SWM_WinH/2)
	SWM_ResizeTypeY=1
SetTimer, SWM_WatchMouse_Resize, 10
return

SWM_WatchMouse_Move:
GetKeyState, SMW_LButtonState, LButton, P
if SMW_LButtonState = U
{
	SetTimer, SWM_WatchMouse_Move, off
	return
}
Gosub SWM_GetMouseAndWindowPos
SWM_WinX += %SWM_DeltaX%
SWM_WinY += %SWM_DeltaY%
SetWinDelay, -1
WinMove, ahk_id %SWM_MouseWin%,, %SWM_WinX%, %SWM_WinY%
return

SWM_WatchMouse_Resize:
GetKeyState, SMW_RButtonState, RButton, P
if SMW_RButtonState = U
{
	SetTimer, SWM_WatchMouse_Resize, off
	return
}
Gosub SWM_GetMouseAndWindowPos
if SWM_ResizeTypeX
{
	SWM_WinX += %SWM_DeltaX%
	SWM_WinW -= %SWM_DeltaX%
}
else
	SWM_WinW += %SWM_DeltaX%
if SWM_ResizeTypeY
{
	SWM_WinY += %SWM_DeltaY%
	SWM_WinH -= %SWM_DeltaY%
}
else
	SWM_WinH += %SWM_DeltaY%
SetWinDelay, -1
WinMove, ahk_id %SWM_MouseWin%,, %SWM_WinX%, %SWM_WinY%, %SWM_WinW%, %SWM_WinH%
return

SWM_GetMouseAndWindowPos:
CoordMode, Mouse
MouseGetPos, SWM_MouseX, SWM_MouseY
SWM_DeltaX = %SWM_MouseX%
SWM_DeltaX -= %SWM_MouseStartX%
SWM_DeltaY = %SWM_MouseY%
SWM_DeltaY -= %SWM_MouseStartY%
SWM_MouseStartX = %SWM_MouseX%
SWM_MouseStartY = %SWM_MouseY%
WinGetPos, SWM_WinX, SWM_WinY, SWM_WinW, SWM_WinH, ahk_id %SWM_MouseWin%
return