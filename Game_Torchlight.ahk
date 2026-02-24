#NoEnv
#SingleInstance, Force
#UseHook
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

GroupAdd, Game, ahk_exe Torchlight.exe
GroupAdd, Game, ahk_exe Torchlight2.exe

#IfWinActive, ahk_group Game

    *E::
        While GetKeyState("E", "P") {
            Click
            Sleep 150
        }
    Return

    *WheelUp::Send z
    *WheelDown::Send x

#IfWinNotActive, ahk_group Game

    F1:: ShowHelpWindow("
    (LTrim
        E                 -> Auto-Click LMB
        WheelUp/WheelDown -> Z/X (Heal/Mana)
        F12               -> Un-press modifier keys
    )")

#IfWinActive

F12::
    Send {Alt Up}
    Send {Ctrl Up}
    Send {Shift Up}
    Send {Win Up}
Return

!Z:: Reload
!X:: ExitApp
