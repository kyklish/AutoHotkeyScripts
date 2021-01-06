#SingleInstance force

;Adjust volume by scrolling the mouse wheel over the taskbar.
#If MouseIsOver("ahk_class Shell_TrayWnd")
WheelUp::Send {Volume_Up}
WheelDown::Send {Volume_Down}
NumpadAdd::
if (doubleup := !doubleup) {
	Hotkey, WheelUp, DoubleUp
	Hotkey, WheelDown, DoubleDown
}
else {
	Hotkey, WheelUp, WheelUp
	Hotkey, WheelDown, WheelDown
}
return

DoubleUp:
Send {Volume_Up 2}
return

DoubleDown:
Send {Volume_Down 2}
return

MouseIsOver(WinTitle) {
	MouseGetPos,,, Win
	return WinExist(WinTitle . " ahk_id " . Win)
}