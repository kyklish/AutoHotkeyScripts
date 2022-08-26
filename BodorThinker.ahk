#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

;GroupAdd, Bodor, ahk_exe BodorThinker3.0.exe
;Only main window has dash before program name (some small windows has just program name in title).
;Main window title pattern: FileName.ncex - BodorThinker3.0
GroupAdd, Bodor, - BodorThinker3.0

if not WinExist("ahk_group Bodor") {
	Run, "C:\Program Files\BodorThinker3.0\Bin\BodorThinker3.0.exe", C:\Program Files\BodorThinker3.0\Bin
	WinWaitActive, BodorThinker3.0, , 20
	if (ErrorLevel)
		MsgBox, WinWait timed out.
	else
		Send {Enter}
}

global _X, _Y

!z::Reload
!x::ExitApp

#IfWinActive ahk_group Bodor
; Head Move
Numpad4:: Press(1500, 315)
Numpad6:: Press(1610, 315)
Numpad2:: Press(1555, 370)
Numpad8:: Press(1555, 260)
; Move Mode
Numpad5:: Press(1555, 315) ; Rapid
Numpad0:: Press(1525, 490) ; Zero
Numpad7:: Press(1480, 445) ; Backward
Numpad3:: Press(1600, 445) ; Step/Jog
Numpad9:: Press(1720, 445) ; Forward
Numpad1:: ; Set Origin
	Press(1455, 490)
	Sleep, 250
	Send {Enter}
return
; Nest
!1:: Press( 75, 930) ; Parts
!2:: Press(165, 930) ; Plates
!3:: Press(245, 930) ; Nest Result

Press(X, Y) {
	Critical, On
	MouseGetPos, _X, _Y
	MouseMove, X, Y
	Click Down
	while (GetKeyState(A_ThisHotkey, "P"))
		Sleep, 10
	Click Up
	MouseMove, _X, _Y
}

#IfWinNotActive ahk_group Bodor
F1:: ShowHelpWindow("
(LTrim
	All keys are Numpad!
	2, 4, 6, 8 -> Move laser head
	5          -> Low/Rapid
	1          -> Set Origin
	7          -> Backward
	9          -> Forward
	3          -> Step/Jog
	0          -> Set Origin
	!1         -> Nest Parts
	!2         -> Nest Plates
	!3         -> Nest Result
)")
