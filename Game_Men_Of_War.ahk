#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

SetMouseDelay, 15 ; меньше 15 игра не успевает надежно отрабатывать клики

Xpri := 315, Xsec := 410 ; основное и дополнительное оружие
Ypri := 1055 ;


!x:: ExitApp
!z:: Reload

#IfWinActive, ahk_exe mow.exe
+x::PressIconOnAmmoExchange(361) ; взять всю амуницию в окне обмена
^x::PressIconOnAmmoExchange(426) ; отдать -//-

Numpad1::SelectWeapon(Xsec, 1)
Numpad2::SelectWeapon(Xsec, 2)
Numpad3::SelectWeapon(Xsec, 3)
Numpad4::SelectWeapon(Xpri, 1)
Numpad5::SelectWeapon(Xpri, 2)
Numpad6::SelectWeapon(Xpri, 3)

Delete::SwitchPrimarySecondaryWeapon()

q::ClickAndRestore(1800, 1050) ; Repair

SelectWeapon(X, i)
{
	global Ypri
	Y := [1010, 965, 915] ; иконки, которые появляются после нажатия на основную иконку оружия
	if (1 <= i and i <= Y.Length()) {
		Y := Y[i]
		MouseGetPos, _X, _Y
		Click, %X%, %Ypri% ; основная иконка оружия
		Click, %X%, %Y%
		MouseMove, _X, _Y
	}
}

PressIconOnAmmoExchange(X, Y := 83)
{
	ClickAndRestore(X, Y)
	Sleep, 100
	Send, {Escape} ; если зажата клавиша Shift, то Esc не закроет меню с инвентарем, полезная фича, можно несколько раз нажимать Shift+X, перекидывая всю амуницию
}

ClickAndRestore(X, Y, ClickCount := 1)
{
	MouseGetPos, _X, _Y
	BlockInput, MouseMove
	Click, %X%, %Y%, %ClickCount% ; by default Left button
	MouseMove, _X, _Y
	BlockInput, MouseMoveOff
}

SwitchPrimarySecondaryWeapon()
{
	global Xpri, Xsec, Ypri
	static flag
	if (flag := !flag) {
		ClickAndRestore(Xpri, Ypri, 2)
	} else {
		ClickAndRestore(Xsec, Ypri, 2)
	}
}
