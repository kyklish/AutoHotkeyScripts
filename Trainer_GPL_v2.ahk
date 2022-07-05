#Include <_COMMON_SETTINGS_>
#Include <JoyPOV2Key_v2>

Menu, Tray, Icon

;Reload_AsAdmin()

GEM := "ahk_exe GEMP2.exe"
Folder := "GPL ahk_exe explorer.exe"

;IfWinExist, %Folder%
	WinClose, %Folder%

IfWinNotExist, %GEM%
	Run, "E:\GAMES\GPLSecrets\GEM+\GEMP2.exe", E:\GAMES\GPLSecrets\GEM+

SendMode, Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetMouseDelay, 50 ; Sets the delay that will occur after each mouse movement or click.
SetDefaultMouseSpeed, 0 ; Sets the mouse speed that will be used if unspecified in Click and MouseMove/Click/Drag.

SetTitleMatchMode, RegEx
GroupAdd, GPL, ahk_exe i)\\GPL\w{3}\.exe$

JoyNumber = 1

Hotkey, IfWinNotActive, ahk_group GPL
Hotkey, F1, Help

lX := 30	; left "Red" icon
lY := 473
rX := 610	; right "Green" icon
rY := lY

oJoyPOV2Key := Func("JoyPOV2Key").Bind(, new PovDown, new PovLeft, new PovRight, JoyNumber)
; UP: | DOWN: reset car to track | LEFT: back | RIGHT: forward
SetTimer, WatchPOV, 10
return

;==============================================================================================
;Joystick POV to Keyboard and Mouse

WatchPOV:
if WinActive("ahk_group GPL") {
	oJoyPOV2Key.Call()
}	
return

class PovLeft
{
	Down()
	{
		Send, {Esc}{Enter}
	}
}

class PovRight
{
	Down()
	{
		global rX, rY
		Click, %rX%, %rY%
	}
}

class PovDown
{
	Down()
	{
		Send, +r
	}
}

;==============================================================================================

Help()
{
	ShowHelpWindow("
	(LTrim
		POV Left         -> Go back in menu.
		POV Right        -> Click 'Green' icon in menu.
		POV Down         -> Reset car to track.
	)")
}

;==============================================================================================

#IfWinNotActive, ahk_group GPL
!z:: Reload
!x::
WinClose, % GEM
ExitApp
