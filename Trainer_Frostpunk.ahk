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
; Ориентироваться нужно по номеру строки, т.к. в зависимости от здания и принятых законов Workers, Engineers, Children and Automation могут отсутствовать
F1::SetWork(1) ; 1st row - Workers MAX
F2::SetWork(2) ; 2nd row - Engineers MAX
F3::SetWork(3) ; 3rd row - Children MAX
F4::SetWork(4) ; 4th row - Automation ON
+F1::SetWork(1, false) ; 1st row - Workers NONE
+F2::SetWork(2, false) ; 2nd row - Engineers NONE
+F3::SetWork(3, false) ; 3rd row - Children NONE
+F4::SetWork(4, false) ; 4th row - Automation OFF
Numpad7::SetNoneWorkForce()
Numpad8::HaltOperation() ; Disable Building

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
	NSV := 35 ; number of shades of variation
	
	ImageSearch, , Y, %X1%, %Y1%, %X2%, %Y2%, *%NSV% *TransBlack FrostpunkWorkForce.png
	if (ErrorLevel) { ; not found
		ImageSearch, , Y, %X1%, %Y1%, %X2%, %Y2%, *%NSV% *TransBlack FrostpunkWorkForceWorkshop.png
		if (ErrorLevel) { ; not found
			Y := 0
			SoundBeep
		}
	}
	
	return Y
}


; find Y coordinate for first line of buttons "NONE ... MAX"
FindButtonCoordY()
{
	global YnoneOffset
	return FindWorkforceLineY() + YnoneOffset
}


SetWorkForce(NumRow, isMax)
{
	global Xnone, XcolOffset, YrowOffset
	X := Xnone
	Y := FindButtonCoordY()
	
	if (isMax)
		X += XcolOffset
	
	if (NumRow < 1 or 4 < NumRow)
		MsgBox, Wrong number of button's row: NumRow = %NumRow%
	Y += YrowOffset * (NumRow - 1) ; если первая строка, то смещение не нужно, X&Y уже указывают на кнопку первой строки
	
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


SetWork(NumRow, isMax := true) {
	SendClick()
	SetWorkForce(NumRow, isMax)
	SendEsc()
}


SetNoneWorkForce() {
	SendClick()
	Loop, 4 ; всего 4 вида рабочих
		SetWorkForce(A_Index, false)
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
	NSV := 50 ; number of shades of variation
	
	Click
	Sleep, 250
	
	ImageSearch, X, Y, %X1%, %Y1%, %X2%, %Y2%, *%NSV% *TransBlack FrostpunkStartResearch.png
	if (ErrorLevel) { ; not found "FrostpunkStartResearch.png"
		ImageSearch, X, Y, %X1%, %Y1%, %X2%, %Y2%, *%NSV% *TransBlack FrostpunkUpgradeTechnology.png
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