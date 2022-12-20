#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

#MaxThreads 1

SetMouseDelay, 50 ; игра при любой задержке ненадежно отрабатывает нажатие на конку

GroupAdd, Game, ahk_exe EndlessSpace.exe

X := 83, Y := 24 ; первая иконка
Xoffset := 50 ; расстояние до следующей иконки в ряду


ClickAndRestore(X, Y)
{
	MouseGetPos, _X, _Y
	BlockInput, MouseMove
	MouseMove, %X%, %Y%, 0
	Click, Down
	Click, Up
	MouseMove, _X, _Y, 0
	BlockInput, MouseMoveOff
}


#IfWinNotExist, ahk_group Game
Launch_App1:: Run, steam://rungameid/208140

#IfWinNotActive, ahk_group Game
Launch_App1:: WinActivate, ahk_group Game

#IfWinActive, ahk_group Game
F1::ClickAndRestore(X + Xoffset * 0, Y) ; Empire
F2::ClickAndRestore(X + Xoffset * 1, Y) ; Research
F3::ClickAndRestore(X + Xoffset * 2, Y) ; Military
F4::ClickAndRestore(X + Xoffset * 3, Y) ; Diplomacy
F5::ClickAndRestore(X + Xoffset * 4, Y) ; Academy
^F::ClickAndRestore(1855, 1032) ; Select 'Search' box in 'Research' window.
+F::ClickAndRestore(1855, 1055) ; 'Locate' button to cycle founded technology.
 1::ClickAndRestore(1785,  980) ; Execute all planned moves of your fleet.
 2::ClickAndRestore(1778, 1032) ; Review all fleets without orders.
 3::ClickAndRestore(1855,  930) ; View bottom message.

#IfWinActive
!z::Reload
!x::ExitApp

F1:: ShowHelpWindow("
(
F1 -> Empire
F2 -> Research
F3 -> Military
F4 -> Diplomacy
F5 -> Academy
^F -> Select 'Search' box in 'Research' window.
+F -> 'Locate' button to cycle founded technology.
 1 -> Execute all planned moves of your fleet.
 2 -> Review all fleets without orders.
 3 -> View bottom message.
)")
