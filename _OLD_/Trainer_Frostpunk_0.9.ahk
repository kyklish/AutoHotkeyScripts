#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, Frostpunk, ahk_exe Frostpunk.exe

if not WinExist("ahk_group Frostpunk")
	Run, "F:\GAMES\Frostpunk\Frostpunk.exe", F:\GAMES\Frostpunk

;Reload_AsAdmin()

; Scout Timer
Period := 5000 ; Period of scanning Scout icons
PeriodAfterClick := Period * 3 ; Period after click was made, to get more time
; Buttons in dialog window of Building
;	Coordinates of NONE button and offsets of columns choosed to be universal
;	for all offsets of NONE button and to be able use X coordinate for Automation
;	buttons
noneX := 1490 ; NONE button for "Workers" in most tall dialog window
noneY := 716
colOffsetX := 138 ; offset to last column of buttons (MAX)
rowOffsetY := 40  ; offset to second row of buttons NONE...MAX
; Detect is dialog window small or tall
dlgWndColor := 0xB1B1B1 ; white line "workers" like detector
dlgWndVariation := 20 ; color variation
; Correction
offsetButtonsY := 150 ; global buttons' position offset (small or tall dialog window)


#IfWinActive, ahk_group Frostpunk
4::Research()
F1::SetMaxWorkers()
F2::SetMaxEngineers()
F3::SetNoneWorkers()
F4::SetNoneEngineers()
Numpad7::SetNoneWorkForce()
Numpad8::HaltOperation()
Numpad9::SetOnAutomation()

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
	X := 1905 ; координаты первой иконки (нижнаяя правая часть)
	Y := 210
	N := 2 ; проверяем первые N иконок
	Result := false
	
	Loop {
		tX := X
		tY := Y + 100 * (A_Index - 1) ; расстояние по оси Y между иконками ожидающих скаутов равно 100 пикселей
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
			Result := true
			Break
		}
	} Until A_Index = N
	
	return Result
}


Click(X, Y, ClickCount := 1)
{
	Click, %X%, %Y%, %ClickCount% ; by default Left button
}


ClickRestore(X, Y, ClickCount := 1)
{
	MouseGetPos, _X, _Y
	Click, %X%, %Y%, %ClickCount% ; by default Left button
	;MouseMove, _X, _Y
}


isSmallWindow()
{
	; dialog window has two sizes, find out which is it
	global noneX, dlgWndColor, dlgWndVariation
	X := noneX
	isSmall := false
	
	PixelSearch, , , %X%, 631, %X%, 631, %dlgWndColor%, %dlgWndVariation%, Fast
	if (ErrorLevel) {
		PixelSearch, , , %X%, 642, %X%, 642, %dlgWndColor%, %dlgWndVariation%, Fast
		if (ErrorLevel) {
			isSmall := true
		}
	}
	
	return isSmall
}


FixButtonCoordY(ByRef Y)
{
	global offsetButtonsY
	if (isSmallWindow)
		Y -= offsetButtonsY
}


SetWorkForce(isWorker, isMax)
{
	global noneX, noneY, colOffsetX, rowOffsetY
	X := noneX
	Y := noneY
	dX := colOffsetX
	dY := rowOffsetY
	
	FixButtonCoordY(Y)
	
	if (isWorker) {
		if (isMax)
			X += dX
	}
	else
		if (isMax) {
			X += dX
			Y += dY
		}
	else
		Y += dY
	
	ClickRestore(X, Y)
}


SetAutomationWorkForce(isOn)
{
	global noneX, noneY, colOffsetX, rowOffsetY
	X := noneX
	Y := noneY + rowOffsetY * 2 ; Automation is third row
	
	FixButtonCoordY(Y)
	
	if (isOn)
		X += colOffsetX
	
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
SetMaxWorkers() {
	SendClick()
	SetWorkForce(true, true)
	SendEsc()
}
SetMaxEngineers() {
	SendClick()
	SetWorkForce(false, true)
	SendEsc()
}
SetNoneWorkers() {
	SendClick()
	SetWorkForce(true, false)
	SendEsc()
}
SetNoneEngineers() {
	SendClick()
	SetWorkForce(false, false)
	SendEsc()
}
SetNoneWorkForce() {
	SendClick()
	SetWorkForce(true, false)
	SetWorkForce(false, false)
	SendEsc()
}
HaltOperation() {
	SendClick()
	ClickRestore(1766, 133)
	SendEsc()
}
SetOnAutomation() {
	SendClick()
	SetAutomationWorkForce(true)
	SendEsc()
}

Research()
{
	X1 := 1550, Y1 := 600, X2 := 1610, Y2 := 780
	NSV := "*100" ; number of shades of variation 
	Click
	Sleep, 250
	ImageSearch, X, Y, %X1%, %Y1%, %X2%, %Y2%, %NSV% FrostpunkStartResearch.png
	if (ErrorLevel) {
		ImageSearch, X, Y, %X1%, %Y1%, %X2%, %Y2%, %NSV% FrostpunkUpgradeTechnology.png
	}
	if (!ErrorLevel)
		ClickRestore(X, Y)
	else
		SoundBeep
	;SendEsc()
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
	Num7 -> Set NONE Workers and Engineers
	Num8 -> Halt Operation (Start/Stop Work in Building)
	Num9 -> Set ON Automation in Building
)")


!z:: Reload
!x:: ExitApp