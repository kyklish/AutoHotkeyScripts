#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, Frostpunk, ahk_exe Frostpunk.exe

if not WinExist("ahk_group Frostpunk")
	Run, "F:\GAMES\Frostpunk\Frostpunk.exe", F:\GAMES\Frostpunk

;Reload_AsAdmin()

; Script will click on Scout icon (top right side of screen) when underlyed title becomes red.
; Scout Timer
Period := 5000 ; Period of scanning Scout icons
PeriodAfterClick := Period * 3 ; Period after click was made, to get more time
; Scout Icon
ColorScout := 0xB2 ; цвет фона надписи (красный) под иконкой скаута (когда он бездействует), используем только красный канал цвета
Xscout := 1905 ; координаты пикселя правой части надписи под первой иконкой, который меняет цвет в зависимости от статуса скаута
Yscout := 210
YnextScoutIconOffset := 100 ; шаг иконок скаутов по вертикали
NumScout := 2 ; проверяем первые N иконок
; Buttons in dialog window of Building
;	Coordinates of NONE button and offsets of columns choosed to be universal for
;	all offsets of NONE button and to be able use X coordinate for Automation buttons.
Xnone := 1490 ; NONE button
YnoneOffset := 83 ; offset to first row from ----WORKERS---- line in dialog window
XcolOffset := 138 ; offset to last column of buttons (MAX) from first column of buttons (NONE)
YrowOffset := 40  ; offset (distance) to next row of buttons NONE...MAX


#IfWinActive, ahk_group Frostpunk
4::Research()
F1::SetWork("W") ; Workers Max
F2::SetWork("E") ; Engineers Max
F3::SetWork("W", false) ; Workers None
F4::SetWork("E", false) ; Engineers None
Numpad7::SetNoneWorkForce()
Numpad8::HaltOperation() ; Disable Building
Numpad9::SetWork("A") ; Automation On

`::
if (toggle := !toggle) {
	SetTimer ClickScouts, %Period%
	SoundBeepTwice()
} else {
	SetTimer ClickScouts, Off
	SoundBeep
}
return


ClickScouts:
if (WinActive("ahk_group Frostpunk"))
{
	if (ClickOnScout()) {
		SetTimer, , %PeriodAfterClick%
	} else {
		SetTimer, , %Period%
	}
}
return


ClickOnScout()
{
	global ColorScout, Xscout, Yscout, YnextScoutIconOffset, NumScout
	isClicked := false
	
	Loop, %NumScout% {
		Yicon := Yscout + YnextScoutIconOffset * (A_Index - 1) ; перебираем иконки с шагом YnextScoutIconOffset
		PixelGetColor, Color, %Xscout%, %Yicon%, RGB
		ColorR := Color >> 16 ; get only Red channel
		ColorRDiff := Abs(ColorR - ColorScout) ; цвет немного меняется +-1: от 0xB1 до 0xB3
		if (ColorRDiff < 2) { ; если цвет красного канала отличается меньше чем на 2
			;ToolTip("ColorR " Format("0x{:X}", ColorR) "`nX" tX "`nY" tY)
			Click, Right ; сбросить, если что-то выбрано
			Sleep, 250
			Click(Xscout - 30, Yicon - 40) ; click on center of Scout icon
			Sleep, 500
			Click(1555, 510) ; click on "Explore" button
			Sleep, 250
			MouseMove, 1385, 745 ; move to button in appeared dialog window
			isClicked := true
			Break
		}
	}
	
	return isClicked
}


Click(X, Y, ClickCount := 1)
{
	Click, %X%, %Y%, %ClickCount% ; by default Left button
}


ClickRestore(X, Y, ClickCount := 1)
{
	MouseGetPos, Xprev, Yprev
	Click, %X%, %Y%, %ClickCount% ; by default Left button
	MouseMove, Xprev, Yprev
}


; find ----WORKFORCE---- line coordinate Y in dialog window
FindWorkforceLineY()
{
	X1 := 1700, Y1 := 480, X2 := 1725, Y2 := 650 ; search rectangle
	NSV := "*150" ; number of shades of variation
	
	ImageSearch, , Y, %X1%, %Y1%, %X2%, %Y2%, %NSV% FrostpunkWorkForce.png
	if (ErrorLevel) { ; not found
		MsgBox, ----WORKFORCE---- line not found!
		Y := 0
	}
	
	return Y
}


; find Y coordinate for first line of buttons "NONE ... MAX"
FindButtonCoordY()
{
	global YnoneOffset
	return FindWorkforceLineY() + YnoneOffset
}


SetWorkForce(typeOfWorker, isMax)
{
	global Xnone, XcolOffset, YrowOffset
	X := Xnone
	Y := FindButtonCoordY()
	
	if (isMax)
		X += XcolOffset
	
	Switch typeOfWorker { ; by default comparision is not case sensitive
		Case "W": ; no need to do anything
		Case "E": Y += YrowOffset ; Engineers is second row
		Case "A": Y += YrowOffset * 2 ; Automations is second row
		Default: MsgBox, No such type of Worker: %typeOfWorker%
	}
	
	ClickRestore(X, Y)
}


SendClick() {
	Click
	Sleep, 250
}


SendEsc() {
	Sleep, 250
	Send, {Escape}
}


SetWork(typeOfWorker, isMax := true) {
	SendClick()
	SetWorkForce(typeOfWorker, isMax)
	SendEsc()
}


SetNoneWorkForce() {
	SendClick()
	SetWorkForce("W", false)
	SetWorkForce("E", false)
	SetWorkForce("A", false)
	SendEsc()
}


HaltOperation() {
	SendClick()
	ClickRestore(1766, 133)
	SendEsc()
}


Research()
{
	X1 := 1550, Y1 := 600, X2 := 1610, Y2 := 780 ; search rectangle
	NSV := "*100" ; number of shades of variation
	
	Click
	Sleep, 250
	
	ImageSearch, X, Y, %X1%, %Y1%, %X2%, %Y2%, %NSV% FrostpunkStartResearch.png
	if (ErrorLevel) { ; not found "FrostpunkStartResearch.png"
		ImageSearch, X, Y, %X1%, %Y1%, %X2%, %Y2%, %NSV% FrostpunkUpgradeTechnology.png
	}
	
	if (!ErrorLevel) ; found image
		ClickRestore(X, Y)
	else
		SoundBeep
}


#IfWinNotActive, ahk_group Frostpunk
F1:: ShowHelpWindow("
(LTrim
	``    -> Start/Stop auto click on waiting Scout (Stopped on start)
	**** -- Point cursor to Building/Research, then press HotKey
	4    -> Research in Technology Tree
	F1   -> Set MAX Workers
	F2   -> Set MAX Engineers
	F3   -> Set NONE Workers
	F4   -> Set NONE Engineers
	Num7 -> Set NONE Workers, Engineers, Automations
	Num8 -> Halt Operation (Start/Stop Work in Building)
	Num9 -> Set ON Automation in Building
)")


!z:: Reload
!x:: ExitApp