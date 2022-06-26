#Include <_COMMON_SETTINGS_>
Menu, Tray, Icon

; Similar functionality to keyboard's built-in feature [A4tech V-Track Wireless 7200N]
; On double press [Num Lock] digital keyboard controls mouse move
; Third example from manual (SetTimer)
; Example #3: Detection of single, double, and triple-presses of a hotkey.
; This allows a hotkey to perform a different operation depending on how many times you press it:

; SendMode, Event
; SetKeyDelay, 50, 50
timerKeyPressPeriod := 400 ; Milliseconds. Measure interval for counting key presses
timerMouseWheelPeriod := 50 ; Period of mouse wheel scroll. Smaller is faster
isTimerMouseWheelRunning := false
; MOUSE MOVE SETTINGS AND VARIABLES
SetDefaultMouseSpeed, 0 ; Instant mouse move
D := 5 ; Mouse move relative distance. Bigger is faster mouse move.
timerMouseMovePeriod := 10
isTimerMouseMoveRunning := false
mouseMoveHotkeys := ["*Numpad1", "*Numpad2", "*Numpad3", "*Numpad4", "*Numpad6", "*Numpad7", "*Numpad8", "*Numpad9"]
; Create hotkeys for mouse move
for _, keyName in mouseMoveHotkeys
	Hotkey, % keyName , StartMouseMoveTimer

;-------------------------------------------------------------------------------------

; Disable hotkeys on script's start. Must be called after mouse move hotkey's creation!
HotkeyToggle()

; * modifier: fire the hotkey even if extra modifiers (Ctrl, Shift, any button, etc) are being held down.
*Numpad5::Click, 2 ; Double click LMB
*Numpad0::Click, Left
*NumpadDot::Click, Middle
*NumpadEnter::Click, Right
*NumpadAdd::GoSub, StartMouseWheelTimer
*NumpadSub::GoSub, StartMouseWheelTimer
*NumpadMult::Send, {Browser_Forward}
*NumpadDiv::Send, {Browser_Back}

F1::ShowHelp()

!x::ExitApp
!z::Reload

;-------------------------------------------------------------------------------------

; $ before HotKey
; This is usually only necessary if the script uses the Send command to send the keys that comprise
; the hotkey itself, which might otherwise cause it to trigger itself. The $ prefix forces the keyboard
; hook to be used to implement this hotkey, which as a side-effect prevents the Send command from
; triggering it. The $ prefix is equivalent to having specified #UseHook somewhere above the definition
; of this hotkey.
; [v1.1.06+]: #InputLevel and SendLevel provide additional control over which hotkeys and hotstrings
; are triggered by the Send command.

;-------------------------------------------------------------------------------------

; $~NumLock:: ;~ modificator: do not disable default key behavior
$NumLock:: ; override key, do not change keyboard's num lock state
	if (key_presses > 0) ; [KeyPresses] timer already started, so we log the [key_presses] instead.
	{
		key_presses += 1
		if (key_presses = 3)
		{
			GoSub, KeyPresses ; Do the job on triple press without waiting timer's end
		}
	}
	else ; Otherwise, this is the first press of a new series. Set count to 1 and start the timer:
	{
		key_presses = 1
		SetTimer, KeyPresses, %timerKeyPressPeriod% ; Wait for more presses within a [timerKeyPressPeriod] millisecond window.
	}
return

;-------------------------------------------------------------------------------------

KeyPresses:
	SetTimer, , Off
	if key_presses = 1 ; The key was pressed once.
	{
		Send {NumLock}
	}
	else if key_presses = 2 ; The key was pressed twice.
	{
		HotkeyToggle()
	}
	else if key_presses = 3 ; The key was pressed triple.
	{

	}
	; Regardless of which action above was triggered, reset the count to prepare for the next series of presses:
	key_presses = 0
return

;-------------------------------------------------------------------------------------

StartMouseMoveTimer:
	if (!isTimerMouseMoveRunning) {
		isTimerMouseMoveRunning := true
		SetTimer, MouseMoveTimer, % timerMouseMovePeriod
		GoSub, MouseMoveTimer ; Don't wait timer execution, execute now
	}
return

;-------------------------------------------------------------------------------------

MouseMoveTimer:
	Critical, On
	if (!MouseMoveKeyPressed()) {
		SetTimer, ,Off
		isTimerMouseMoveRunning := false
	} else {
		dX := dY := 0
		if (GetKeyState("Numpad1", "P")) {
			dX += -D
			dY += D
		}
		if (GetKeyState("Numpad2", "P")) {
			dY += D
		}
		if (GetKeyState("Numpad3", "P")) {
			dX += D
			dY += D
		}
		if (GetKeyState("Numpad4", "P")) {
			dX += -D
		}
		if (GetKeyState("Numpad6", "P")) {
			dX += D
		}
		if (GetKeyState("Numpad7", "P")) {
			dX += -D
			dY += -D
		}
		if (GetKeyState("Numpad8", "P")) {
			dY += -D
		}
		if (GetKeyState("Numpad9", "P")) {
			dX += D
			dY += -D
		}
		MouseMove, % dX, % dY, ,R
	}
	Critical, Off
return

;-------------------------------------------------------------------------------------

StartMouseWheelTimer:
	if (!isTimerMouseWheelRunning) {
		isTimerMouseWheelRunning := true
		SetTimer, MouseWheelTimer, % timerMouseWheelPeriod
		GoSub, MouseWheelTimer ; Don't wait timer execution, execute now
	}
return

;-------------------------------------------------------------------------------------

MouseWheelTimer:
	Critical, On
	if (!GetKeyState("NumpadAdd", "P") AND !GetKeyState("NumpadSub", "P")) {
		SetTimer, , Off
		isTimerMouseWheelRunning := false
	} else {
		if (GetKeyState("NumpadAdd", "P")) {
			Click, WheelDown
		} else {
			if (GetKeyState("NumpadSub", "P")) {
				Click, WheelUp
			}
		}
	}
	Critical, Off
return

;-------------------------------------------------------------------------------------

; Return [true], if any hotkey for mouse move is pressed by user
MouseMoveKeyPressed() {
	global mouseMoveHotkeys
	for _, keyName in mouseMoveHotkeys {
		; Remove wildcard [*] before hotkey name
		if (GetKeyState(StrReplace(keyName, "*"), "P"))
			return true
	}
	return false
}

;-------------------------------------------------------------------------------------

; Toggle all hotkeys
HotkeyToggle() {
	global mouseMoveHotkeys
	for _, keyName in mouseMoveHotkeys
		Hotkey, % keyName, Toggle
	Hotkey, *Numpad5, Toggle
	Hotkey, *Numpad0, Toggle
	Hotkey, *NumpadDot, Toggle
	Hotkey, *NumpadEnter, Toggle
	Hotkey, *NumpadAdd, Toggle
	Hotkey, *NumpadSub, Toggle
	Hotkey, *NumpadMult, Toggle
	Hotkey, *NumpadDiv, Toggle
}

;-------------------------------------------------------------------------------------

ShowHelp()
{
	static toggle
	if (toggle := !toggle)
		SplashImage, A4Tech_V-Track_Wireless_7200N.jpg, B
	else
		SplashImage, OFF
}

;-------------------------------------------------------------------------------------
