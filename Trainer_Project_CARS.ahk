#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, ProjectCARS, ahk_exe pCARS.exe
GroupAdd, ProjectCARS, ahk_exe pCARS64.exe

SendMode, Event
SetKeyDelay, 150
SetMouseDelay, 25

sFolder := "Project CARS" ; folder on desktop with shortcuts to game, tools, this script, etc
if(WinExist(sFolder))
	WinClose, %sFolder%

;==============================================================================================

;Joystick POV to Arrows - Ремапим POV в стрелочки
#Include <JoyPOV2Key> ; <- See comments in JoyPOV2Key function
SetTimer, JoyPOV2Key, 10

;Joystic VU axises to Mouse Cursor
#Include <JoyAxis2MouseCursor>
WatchJoystick := Func("JoyAxis2MouseCursor").Bind("V", "U", 0.5)
SetTimer, %WatchJoystick%, 10

;==============================================================================================

#IfWinActive, ahk_group ProjectCARS
Joy1::						;A
if GetKeyState("Joy7")
	Send, {Enter}{Left 2}{Enter}	;Confirm car selection and start event
else if GetKeyState("Joy8")
	Send, {Esc}				;Send 'Esc'
else
	Send, {Enter}				;Send 'Enter'
return

Joy4::						;Y
if GetKeyState("Joy7")
	Send, {Right 2}{Enter}{Down}{Enter}{Left 2}{Enter} ;On <Time Attack> screen select next car and start event
else
	Send, {Enter}{Down}{Enter}	;Select menu and confirm
return

Joy8::						;Start (RButton) ;Exit game, when you are in menu
if GetKeyState("Joy7") {
	Click, 1902, 15 ;кликаем крестик в правом верхнем углу (exit from any main menu screen)
	Send, {Enter}
}
return

#IfWinNotExist, ahk_group ProjectCARS
;Joy8:: Run, "E:\Games\Project CARS\pCARS64.exe" -novr -novid, E:\Games\Project CARS	;Start (RButton)
Joy8:: Run, "E:\Games\Project CARS\pCARS.exe" -novr -novid, E:\Games\Project CARS	;Start (RButton)

#IfWinNotActive, ahk_group ProjectCARS
F1:: ShowHelpWindow("
(LTrim
	RStick          -> Mouse cursor.
	POV             -> Keyboard arrows.
	Start (RButton) -> Start game (pCARS.exe).
	Start + Select  -> Exit game, from main menu.
	A               -> {Enter}
	A + Start       -> {Esc}
	Y               -> Select menu and confirm (useful for restart event or exit).
	A + Select      -> Confirm car selection and start event (on any event).
	Y + Select      -> On <Time Attack> screen select next car and start event.
)")

#IfWinActive
!x:: ExitApp
!z:: Reload