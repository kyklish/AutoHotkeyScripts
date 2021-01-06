#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

;Reload_AsAdmin()

;SetKeyDelay, 10
;SetMouseDelay, 50

sLeftClickKey := "q"
sMoveAttackKey := "LCtrl"
sStationaryAttackKey := "LShift"
iTimeIdleKeyboard := 200
iTimerDelay := 250

; {HotKey: "FuncName", ...}; () - becase we use variables, inside object initialization
oTimers := {(sMoveAttackKey): "MoveAttack", (sStationaryAttackKey): "StationaryAttack"}

GroupAdd, TQ, ahk_exe TQ.exe

if not WinExist("ahk_group TQ")
	Run, "F:\GAMES\Titan Quest - Anniversary Edition\TQ.exe" /dx11, F:\GAMES\Titan Quest - Anniversary Edition\

;Make Hotkeys from 0 to 9
Hotkey, IfWinActive, ahk_group TQ
Loop, 10
	Hotkey, % A_Index - 1, UseSkill

HotKey, % sLeftClickKey, LeftClick

;Make Hotkeys from oTimers object
for sKeyName, sTimerLabel in oTimers {
	oHotKeyFunc := Func("EnableTimer").bind(sTimerLabel)
	Hotkey, % sKeyName, % oHotKeyFunc
	SetTimer, % sTimerLabel, % iTimerDelay
	SetTimer, % sTimerLabel, Off
}

UseSkill() {
	;key := 30 + A_ThisHotkey
	;Send, {vk%key% Down}
	;SendEvent, {vk34 Down}
	;Sleep, 250
	;Send, {vk%key% Up}
	;SendEvent, {vk34 Up}
	Send, %A_ThisHotkey%
	Sleep, 250
	Click
}

EnableTimer(sTargetTimerLabel := "") {
	global oTimers
	for key, sTimerLabel in oTimers {
		if (sTimerLabel == sTargetTimerLabel)
			SetTimer, % sTimerLabel, On
		else
			SetTimer, % sTimerLabel, Off
	}
	ToolTip
}

Click() {
	Click
	Sleep, 250
}

LeftClick() {
	EnableTimer() ;Disable all timers
	Click
}

MoveAttack() {
	;ToolTip, % A_ThisFunc
	Click
}

StationaryAttack() {
	return
	;ToolTip, % A_ThisFunc
	Send, {vkA0 Down} ;Shift Down
	Click()
	Send, {vkA0 Up}
}
/*
StopTimersIfAnyKeyPressed:
if (A_TimeIdleKeyboard < iTimeIdleKeyboard && A_TickCount - iTimeClick > iTimeIdleKeyboard + 50)
	bAnyKeyPressed := true
else
	bAnyKeyPressed := false
return
*/

s::
Click, Right
Sleep, 250
return

#IfWinActive
F1:: ShowHelpWindow("
(LTrim
	Q     -> ВЫКЛ. все; автоклик левой кнопкой мыши
	Ctrl  -> ВКЛ. авто движение и атака
	Shift -> ВКЛ. авто атака на месте
)")

!z:: Reload
!x:: ExitApp