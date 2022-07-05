#Include <_COMMON_SETTINGS_>

;-------------------------------------------------------------------------------------
ScrollLock:: ;Hide cursor only in current window
if (HideCursor := !HideCursor) {
	MouseGetPos, , , hwnd
	Gui Cursor:+Owner%hwnd%
	BlockInput MouseMove
	DllCall("ShowCursor", Int,0)
} else {
	BlockInput MouseMoveOff
	DllCall("ShowCursor", Int,1)
}
Return
;-------------------------------------------------------------------------------------
