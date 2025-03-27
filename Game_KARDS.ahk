#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
SendMode Event
SetMouseDelay, 50 ;delay after every click-down and click-up of the mouse
SetDefaultMouseSpeed, 1

GroupAdd, KARDS, ahk_exe kards-Win64-Shipping.exe

; KARDS - The WWII Card Game
If not WinExist("ahk_group KARDS")
    Run, "C:\Games\KARDS\default\game\kards.exe", C:\Games\KARDS\default\game

#IfWinActive, ahk_group KARDS
    Space:: ClickRestore(1790, 695) ; END TURN button
    !s:: Suspend

#IfWinNotActive, ahk_group KARDS
    F1:: ShowHelpWindow("
    (LTrim
        Space -> END TURN
        !S -> Suspend Script
    )")

    !z:: Reload
    !x:: ExitApp
#If

ClickRestore(X, Y, ClickCount := 1)
{
    MouseGetPos, Xprev, Yprev
    Click, %X%, %Y%, %ClickCount% ; by default Left button
    MouseMove, Xprev, Yprev
}
