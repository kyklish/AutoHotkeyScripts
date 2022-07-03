#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, Frostpunk, ahk_exe Frostpunk.exe

if not WinExist("ahk_group Frostpunk")
	Run, "F:\GAMES\Frostpunk\Frostpunk.exe", F:\GAMES\Frostpunk

;Reload_AsAdmin()

; Script will click on Scout icon (top right side of screen) when underlying title becomes red.
; Scout Timer
Period := 5000 ; Period of scanning Scout icons
PeriodAfterClick := Period * 3 ; Period after click was made, to get more time
; Buttons in dialog window of Building
;	Coordinates of NONE button and offsets of columns selected to be universal
;	for all offsets of NONE button and to be able use X coordinate for Automation
;	buttons
noneX := 1490 ; NONE button for "Workers" in most tall dialog window
noneY := 716
colOffsetX := 138 ; offset to last column of buttons (MAX)
rowOffsetY := 40  ; offset to second row of buttons NONE...MAX
; Detect is dialog window small or tall
dlgWndColor := 0xB1B1B1 ; white line "WORKFORCE" like detector
dlgWndVariation := 20 ; color variation
; Correction
offsetButtonsY := 150 ; global buttons' position offset (small or tall dialog window)


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
	ColorScout := 0xB2 ; цвет надписи (красная) под иконкой скаута, когда он бездействует, используем только красный канал цвета
	X := 1905 ; координаты первой иконки (нижняя правая часть)
	Y := 210
	dY := 100 ; шаг иконок скаутов по вертикали
	N := 2 ; проверяем первые N иконок
	isClicked := false
	
	Loop {
		tX := X
		tY := Y + dY * (A_Index - 1) ; перебираем иконки с шагом dY
		PixelGetColor, Color, %tX%, %tY%, RGB
		ColorR := Color >> 16 ; get only Red channel
		Diff := Abs(ColorR - ColorScout) ; цвет немного меняется +-1: от 0xB1 до 0xB3
		if (Diff < 2) { ; если цвет красного канала отличается меньше чем на 2
			;ToolTip("ColorR " Format("0x{:X}", ColorR) "`nX" tX "`nY" tY)
			Click, Right ; сбросить, если что-то выбрано
			Sleep, 250
			Click(tX - 30, tY - 40) ; click on center of Scout icon
			Sleep, 500
			Click(1555, 510) ; click on "Explore" button
			Sleep, 250
			MouseMove, 1385, 745 ; move to button in appeared dialog window
			isClicked := true
			Break
		}
	} Until A_Index = N
	
	return isClicked
}


Click(X, Y, ClickCount := 1)
{
	Click, %X%, %Y%, %ClickCount% ; by default Left button
}


ClickRestore(X, Y, ClickCount := 1)
{
	MouseGetPos, _X, _Y
	Click, %X%, %Y%, %ClickCount% ; by default Left button
	MouseMove, _X, _Y
}


isSmallWindow()
{
	; Dialog window has three types of description:
	;	small - no additional stuff
	;	big - there description of some things that you can build
	;	little bigger - there description of produced resources
	global noneX, dlgWndColor, dlgWndVariation
	X := noneX
	bigY := 631 ; WORKFORCE line in "big" dialog window
	lbigY := 642 ; WORKFORCE line in "little bigger" dialog window
	isSmall := false
	
	PixelSearch, , , %X%, %bigY%, %X%, %bigY%, %dlgWndColor%, %dlgWndVariation%, Fast
	if (ErrorLevel) { ; not "big"
		PixelSearch, , , %X%, %lbigY%, %X%, %lbigY%, %dlgWndColor%, %dlgWndVariation%, Fast
		if (ErrorLevel) { ; not "little bigger"
			isSmall := true
		}
	}
	
	return isSmall
}


FixButtonCoordY(ByRef Y)
{
	global offsetButtonsY
	if (isSmallWindow())
		Y -= offsetButtonsY
}


SetWorkForce(typeOfWorker, isMax)
{
	global noneX, noneY, colOffsetX, rowOffsetY
	X := noneX
	Y := noneY
	
	FixButtonCoordY(Y)
	
	if (isMax)
		X += colOffsetX
	
	Switch typeOfWorker { ; by default comparison is not case sensitive
		Case "W": ; no need to do anything
		Case "E": Y += rowOffsetY ; Engineers is second row
		Case "A": Y += rowOffsetY * 2 ; Automations is second row
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