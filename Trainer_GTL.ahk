#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

SendMode, Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetKeyDelay, 50, 25 ; чтобы работало в играх, нужно использовать задержки при нажатиях (only Event mode)
SetMouseDelay, 50 ; Sets the delay that will occur after each mouse movement or click.
SetDefaultMouseSpeed, 0 ; Sets the mouse speed that will be used if unspecified in Click and MouseMove/Click/Drag.

GroupAdd, GTL, ahk_exe GTL.exe

JoyNumber = 2
JoyPrefix = %JoyNumber%Joy
JoyMultiplier = 0.2 ; Mouse cursor speed.
JoyThreshold = 5 ; Dead zone for RStick. A perfect joystick could use a value of 1.
MouseWheelNumber = 8 ; How many lines will be scrolled.
MouseWheelDelay = 25 ; Delay during sequental sending Mouse Wheel keys.

; Calculate the axis displacements that are needed to start moving the mouse cursor:
JoyThresholdUpper := 50 + JoyThreshold ; 50 - is a center, Min-Max = 0-100
JoyThresholdLower := 50 - JoyThreshold

Hotkey, IfWinNotActive, ahk_group GTL
Hotkey, F1, Help
Hotkey, IfWinNotExist, ahk_group GTL
Hotkey, %JoyPrefix%8, LaunchGTL
Hotkey, IfWinActive, ahk_group GTL
Hotkey, %JoyPrefix%4, Y
Hotkey, %JoyPrefix%5, LBumper
Hotkey, %JoyPrefix%6, RBumper
Hotkey, %JoyPrefix%7, Select
Hotkey, %JoyPrefix%8, Start

lX := 50		; left "Back" icon
lY := 1015
rX := 1560	; right "Forward" icon
rY := 900
mX := 315		; center of menu with cars and tracks
mY := 460

#Include <JoyAxis2MouseCursor>
WatchJoystick := Func("JoyAxis2MouseCursor").Bind("V", "U", JoyMultiplier, JoyThreshold, JoyNumber)
SetTimer, %WatchJoystick%, 10
SetTimer, WatchPOV, 10
return

;==============================================================================================
;Joystick POV to Keyboard and Mouse

WatchPOV:
if WinActive("ahk_group GTL") {
	GetKeyState, POV, %JoyNumber%JoyPOV  ; Get position of the POV control.
	KeyToSendPrev = %KeyToSend%  ; Prev now holds the key that was down before (if any).
	
	; Some joysticks might have a smooth/continous POV rather than one in fixed increments.
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
		ClickAndMoveToMenuCenter(lX, lY)	; back
	else if KeyToSend = Right
		ClickAndMoveToMenuCenter(rX, rY)	; forward
	else if KeyToSend = Up
		Send, ``						; XD! mod - on/off
	else if KeyToSend = Down
		Send, e						; reset car to track
}
return

ClickAndMoveToMenuCenter(X, Y)
{
	global mX, mY
	Click, %X%, %Y%
	MouseMove, %mX%, %mY%
}

;==============================================================================================

LaunchGTL:
Run, "E:\GAMES\GT Legends\GTL.exe", E:\GAMES\GT Legends
return


Select: ;exit race or practice
Send {Esc}{Enter}		;exit to box
Click, %lX%, %lY%		;exit to main menu
CLick, 1535, 560		;confirm exit
MouseMove, %mX%, %mY%	;move cursor to center of left menu with cars and tracks
return


Start: ;restart
Send {Esc}{Up}{Up}{Enter}
return


Y: ;click mouse left button
Click
return


LBumper:
Loop, %MouseWheelNumber% {
	Send {WheelUp}
	Sleep, %MouseWheelDelay% ; I not understand why SetKeyDelay not working for this Loop :(
}
return


RBumper:
Loop, %MouseWheelNumber% {
	Send {WheelDown}
	Sleep, %MouseWheelDelay% ; Without this Sleep, scroll to N lines will not work
}
return


Help()
{
	ShowHelpWindow("
	(LTrim
		Select (LButton) -> Exit race or practice.
		Start (RButton)  -> Restart race.
		POV Left         -> Click 'Back' icon in menu.
		POV Right        -> Click 'Forward' icon in menu.
		POV Up           -> XD! mod on/off.
		POV Down         -> Reset car to track.
		RStick           -> Move mouse cursor.
		Y                -> Click mouse LButton.
		LRBumper         -> Mouse wheel up and down respectively.
	)")
}

;==============================================================================================

#IfWinNotActive, ahk_group GTL
!z:: Reload
!x:: ExitApp