#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

Menu, Tray, Icon, DuneImperium.ico, 1, 1
SetMouseDelay, 50 ;delay after every click-down and click-up of the mouse
SetDefaultMouseSpeed, 1

GroupAdd, GAME, ahk_exe DuneImperium.exe

#IfWinActive, ahk_group GAME
    BackSpace:: ClickRestore(1650, 1045) ; UNDO button
    Space::     ClickRestore(1760, 1035) ; CONFIRM / END TURN / REVEAL / START GAME button
#If

F1:: ShowHelpWindow("
(LTrim
    BackSpace -> Click UNDO button
    Space     -> Click CONFIRM / END TURN / REVEAL / START GAME button
)")

!Z:: Reload
!X:: ExitApp

ClickRestore(X, Y, ClickCount := 1)
{
    MouseGetPos, _X, _Y
    Click, %X%, %Y%, %ClickCount% ; by default Left button
    MouseMove, _X, _Y
}
