#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

GroupAdd, TotalWar, ahk_exe medieval2.exe
GroupAdd, TotalWar, ahk_exe kingdoms.exe

#IfWinActive, ahk_group TotalWar
+F1::
Send ``
Sleep 100
Send give_trait this Cheat{Enter}
Sleep 100
Send ``
return

#IfWinNotActive, ahk_group TotalWar
F1:: ShowHelpWindow("
(LTrim
	Shift + F1 - Make any character the best.
	...          First you must select character
	...          outside of city.
)")

#IfWinActive
!z::Reload
!x::ExitApp