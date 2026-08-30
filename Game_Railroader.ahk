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

GetClientSize(WinExist("ahk_group Game"), iClientWidth, iClientHeight)
iPlaceIndex := 4 ; [oPlaces] index for "East Whittier"
oPlaces := ["Bryson", "Ela","Whittier","East Whittier"]

#IfWinActive, ahk_group Game
    !1::SetControlMode("Manual")
    !2::SetControlMode("AE Road")
    !3::SetControlMode("AE Yard")
    !4::SetControlMode("AE Waypoint")
    ; Places from West to East (Places from "early game" to "late game")
    +F12::Teleport("Sylva")
    +F11::Teleport("Dillsboro")
    +F10::Teleport("Wilmot")
    +F9:: Teleport("East Whittier")
    +F8:: Teleport("Whittier")
    !F8:: Teleport("Connelly") ; Alt = Alternative route near "Whittier"
    +F7:: Teleport("Ela")
    +F6:: Teleport("Bryson")
    !F6:: Teleport("Walker")   ; Alt = Alternative route near "Bryson"
    PgDn::TeleportDirection("Left")
    PgUp::TeleportDirection("Right")
    +Q::SendEvent, ^[ ; Direction R
    +E::SendEvent, ^] ; Direction F
    !A::SendEvent, 9  ; Camera Follow Tail
    !D::SendEvent, 0  ; Camera Follow Head
    !S::SendEvent, +0 ; Camera Jump to Tail (Jump to N-1 Car)
    !W::SendEvent, +9 ; Camera Jump to Head (Jump to N+1 Car)
    F4::Send, ^t ; Jump to Mouse
    G:: Send, ^g ; Auto Engineer Waypoint Select
    O:: SendEvent, q ; Lean Left
    P:: SendEvent, e ; Lean Right
#If

!C::Suspend
!Z::Reload
!X::ExitApp

; WindowSpy.ahk (Lexikos)
GetClientSize(hWnd, ByRef w := "", ByRef h := "")
{
    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
    w := NumGet(rect, 8, "int")
    h := NumGet(rect, 12, "int")
}

SetControlMode(sMode)
{
    global iClientHeight
    BlockInput, MouseMove
    MouseGetPos, _X, _Y
    ; Locomotive UI is aligned to bottom-left corner. Calculate [Y] coordinate
    ; to be independent from window client's size.
    X := 60, Y := iClientHeight - 30
    Click, %X% %Y%   ;       [Control Mode] Button
    ; Click, 60 690  ;  720p [Control Mode] Button
    ; Click, 60 1050 ; 1080p [Control Mode] Button
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

TeleportDirection(sDirection)
{
    global iPlaceIndex
    global oPlaces
    Switch sDirection
    {
    Case "Left":
        If (iPlaceIndex > 1)
            iPlaceIndex--
    Case "Right":
        If (iPlaceIndex < oPlaces.Length())
            iPlaceIndex++
    Default:
        MsgBox % A_ThisFunc " [" sDirection "] wrong input parameter."
    }
    Teleport(oPlaces[iPlaceIndex])
}
