#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

SetMouseDelay, 10 ; если -1, то игра не успевает отрабатывать

Double_Tap_Delay := 400


!x:: ExitApp
!z:: Reload

#IfWinActive, ahk_exe FacesOfWar.exe
~F1::DoubleClickOnDoubleTap(815) ; All soldiers throw Infantry Grenade
~F2::DoubleClickOnDoubleTap(855) ; All soldiers throw Anti-Tank Grenade
~F9::DoubleClickOnDoubleTap(1125) ; призыв союзников

+1::SelectTab(1) ; выбор вкладок меню, они так и называются 1, 2, 3
+2::SelectTab(2)
+3::SelectTab(3)

+x::PressIconOnAmmoExchange(361) ; взять всю амуницию в окне обмена
^x::PressIconOnAmmoExchange(426) ; отдать -//-

Numpad1::SelectWeapon("Secondary", 1)
Numpad2::SelectWeapon("Secondary", 2)
Numpad3::SelectWeapon("Secondary", 3)
Numpad4::SelectWeapon("Primary", 1)
Numpad5::SelectWeapon("Primary", 2)
Numpad6::SelectWeapon("Primary", 3)

SelectWeapon(type, i)
{
	X := {Primary: 370, Secondary: 467}
	Y := [1010, 965, 915] ; иконки, которые появляются после нажатия на основную иконку оружия
	if (type = "Primary" or type = "Secondary") {
		X := X[type]
		if (1 <= i and i <= Y.Length()) {
			Y := Y[i]
			MouseGetPos, _X, _Y
			Click, %X%, 1060 ; основная иконка оружия
			Click, %X%, %Y%
			MouseMove, _X, _Y
		}
	}
}

PressIconOnAmmoExchange(X, Y := 83)
{
	ClickAndRestore(X, Y)
	Sleep, 100
	Send, {Escape}
}

ClickAndRestore(X, Y, ClickCount := 1)
{
	MouseGetPos, _X, _Y
	BlockInput, MouseMove
	Click, %X%, %Y%, %ClickCount% ; by default Left button
	MouseMove, _X, _Y
	BlockInput, MouseMoveOff
}

DoubleClickOnDoubleTap(X, Y := 1005)
{
	global Double_Tap_Delay
	if (A_PriorHotkey = A_ThisHotkey and A_TimeSincePriorHotkey < Double_Tap_Delay)
		ClickAndRestore(X, Y, 2)
}

SelectTab(i)
{
	X := [1810, 1840, 1870]
	Y := 918
	if (1 <= i and i <= X.Length()) {
		;ClickAndRestore(X[i], Y)
		X := X[i]
		Click, %X%, %Y%
	}
}
