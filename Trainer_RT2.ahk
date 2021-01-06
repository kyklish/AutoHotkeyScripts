#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

GroupAdd, RT2, ahk_exe RT2_PLAT.exe

if not WinExist("ahk_group RT2")
	Run, "E:\GAMES\Railroad Tycoon II\RT2_PLAT.EXE", E:\GAMES\Railroad Tycoon II

SetKeyDelay, 10

#IfWinNotActive, ahk_group RT2
F1:: ShowHelpWindow("
(LTrim
	Numpad0 - Поезда никогда не разбиваются.
	Numpad1 - Все локомотивы.
	Numpad2 - Города увеличиваются в два раза.
)")

#IfWinActive, ahk_group RT2
;RT2 accept only 14 characters via SendInput, if you need more use SendEvent with delay
Numpad0:: SendCheat("nowreck") ;пoeздa никoгдa нe paзбивaютcя
Numpad1:: SendCheat("show me the trains") ;все локомотивы
Numpad2:: SendCheat("viagra") ;города увеличиваются в два раза

SendCheat(sCheat)
{
	SendEvent, {Tab}%sCheat%{Enter}
}

#IfWinActive
!z:: Reload
!x:: ExitApp