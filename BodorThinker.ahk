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
; Simple Arithmetic
^Enter:: CalculateTextField()

; Simple calculation in text field, when user directly set XY and WH values of object.
; Do not use spaces between operands: '1+1' valid, '1 + 1' not valid.
CalculateTextField() {
	; BodorThinker3.0 override hotkeys very hard:
	; 1. 'Ctrl+C' copy selected object, not selected text.
	; 2. 'End' show current position of laser head in middle of screen.
	Critical, On
	Clipboard := "" ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send {Home}+{End} ; Move carret to 'Home', then 'Shift+End' to select all text.
	Send ^{Insert} ; Copy selected text.
	ClipWait, 1 ; Wait for the clipboard to contain text.
	if (ErrorLevel) {
		MsgBox, The attempt to copy text onto the clipboard failed.
		return
	}
	needleRegEx := "(?P<A>-?\d+(\.\d+)?)(?P<Op>[+\-*/])(?P<B>-?\d+(\.\d+)?)" ; '-' has special meaning inside a character class
	if (RegExMatch(Clipboard, needleRegEx, txt)) {
		Switch txtOp {
			Case "+": rs := txtA + txtB
			Case "-": rs := txtA - txtB
			Case "*": rs := txtA * txtB
			Case "/": rs := txtA / txtB
			Default: MsgBox, Wrong arithmetic operator.
		}
		rs := Format("{:.3f}", rs) ; Example: 1000.000
		rs := RTrim(rs, "0") ; Trim zeros. Example: 1000.
		rs := RTrim(rs, ".") ; After trimming zeros, trim possible dot. Example: 1000
		; ToolTip, %txtA% %txtOp% %txtB% `= %rs%
		Clipboard := rs
		Send +{Insert}
	}
}

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
	^Enter     -> Calculate text field
)")
