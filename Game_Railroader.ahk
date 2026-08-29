#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

CoordMode, Mouse, Client

SetDefaultMouseSpeed, 0
SetKeyDelay, 50, 50
SetMouseDelay, 50

GroupAdd, Game, ahk_exe Railroader.exe

#IfWinActive, ahk_group Game
    !1::SetControlMode("Manual")
    !2::SetControlMode("AE Road")
    !3::SetControlMode("AE Yard")
    !4::SetControlMode("AE Waypoint")
    +F1::Teleport("Sylva")
    +F2::Teleport("Dillsboro")
    +F3::Teleport("Wilmot")
    +F4::Teleport("East Whittier")
    +F5::Teleport("Whittier")
    +F6::Teleport("Connelly")
    +F7::Teleport("Ela")
    +F8::Teleport("Bryson")
    +F9::Teleport("Walker")
    ; +F::Teleport("")
    F4::Send, ^t ; Jump to Mouse
    G:: Send, ^g ; Auto Engineer Waypoint Select
    O:: SendEvent, q ; Lean Left
    P:: SendEvent, e ; Lean Right
#If

!S::Suspend
!Z::Reload
!X::ExitApp

SetControlMode(sMode)
{
    BlockInput, MouseMove
    MouseGetPos, _X, _Y
    Click, 60 690 ; 720p
    ; Click, 60 1050 ; 1080p
    Switch sMode
    {
    Case "Manual":
        Click, Relative 0 -110
    Case "AE Road":
        Click, Relative 0 -82
    Case "AE Yard":
        Click, Relative 0 -54
    Case "AE Waypoint":
        Click, Relative 0 -26
    Default:
        MsgBox % A_ThisFunc " [" sMode "] wrong input parameter."
    }
    MouseMove, _X, _Y
    BlockInput, MouseMoveOff
}

Teleport(sPlace)
{
    Send, ``
    Sleep, 250
    Send, /tp{Space}
    Send, "%sPlace%"
    Send, {Enter}
    Sleep, 250
    Send, ``
}
