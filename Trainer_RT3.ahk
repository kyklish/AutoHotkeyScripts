#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

GroupAdd, RT3, ahk_exe RT3.exe

if not WinExist("ahk_group RT3")
	Run, "E:\GAMES\Railroad Tycoon 3\RT3.exe", E:\GAMES\Railroad Tycoon 3

#IfWinNotActive, ahk_group RT3
F1:: ShowHelpWindow("
(LTrim
	Numpad0 - Поезда никогда не разбиваются.
	Numpad1 - Все локомотивы.
)")

#IfWinActive, ahk_group RT3
Numpad0:: SendCheat("safety first") ;поезда никогда нe разбиваются
Numpad1:: SendCheat("trains are in my blood") ;все локомотивы

SendCheat(sCheat)
{	;если не ставить запятую или вставить пробел после запятой - не работает в RT3
	Send,.%sCheat%
	Sleep, 100
	Send {Enter}
}

#IfWinActive
!z:: Reload
!x:: ExitApp
