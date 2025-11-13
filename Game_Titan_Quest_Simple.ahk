#NoEnv
#SingleInstance, Force
#UseHook
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

GroupAdd, Game, ahk_exe Grim Dawn.exe
GroupAdd, Game, ahk_exe TQ.exe

#IfWinActive, ahk_group Game

    *W::
        Send {Shift Up}
        While GetKeyState("W", "P") {
            Click
            Sleep 150
        }
    Return


    S::
        Send {Shift Down}
        While GetKeyState(A_ThisHotkey, "P") {
            Click
            Sleep 150
        }
        Send {Shift Up}
    Return

#IfWinActive

F12::
    Send {Alt Up}
    Send {Ctrl Up}
    Send {Shift Up}
    Send {Win Up}
Return

F1:: ShowHelpWindow("
(LTrim
    W     -> Auto-Click LMB
    S     -> Auto-Click LMB with Shift (Stationary Attack) key down
    F12   -> Un-press modifier keys
)")

!Z:: Reload
!X:: ExitApp
