#Include <_COMMON_SETTINGS_>

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

SetTimer, WatchPOV, 10
return

;==============================================================================================
;Joystick POV to Keyboard and Mouse

WatchPOV:
if WinActive("ahk_group GPL") {
	GetKeyState, POV, %JoyNumber%JoyPOV  ; Get position of the POV control.
	KeyToSendPrev = %KeyToSend%  ; Prev now holds the key that was down before (if any).
	
	; Some joysticks might have a smooth/continuos POV rather than one in fixed increments.
	; To support them all, use a range:
	if POV < 0   ; No angle to report
		KeyToSend =
	else if POV > 31500                 ; 315 to 360 degrees: Forward
		KeyToSend = Up
	else if POV between 0 and 4500      ; 0 to 45 degrees: Forward
		KeyToSend = Up
	else if POV between 4501 and 13500  ; 45 to 135 degrees: Right
		KeyToSend = Right
	else if POV between 13501 and 22500 ; 135 to 225 degrees: Down
		KeyToSend = Down
	else                                ; 225 to 315 degrees: Left
		KeyToSend = Left
	
	if KeyToSend = %KeyToSendPrev%  ; The correct key is already down (or no key is needed).
		return  ; Do nothing.
	
	if KeyToSend = Left
		Send, {Esc}{Enter}		; back
	else if KeyToSend = Right
		Click, %rX%, %rY%		; forward
	;else if KeyToSend = Up
		;Send, 				; 
	else if KeyToSend = Down
		Send, +r				; reset car to track
}
return

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
WinClose, %GEM%
ExitApp
