; Make "base point" in bottom-left corner. There is GUI controls for engine.
; Also this allows freely change resolution of the game.

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

iClientWidth  := 0
iClientHeight := 0
GetClientSize(WinExist("ahk_group Game"), iClientWidth, iClientHeight)
oPlaces := ["Alarka Jct","Hemingway","Bryson", "Ela","Whittier","East Whittier"]
iPlaceIndex := oPlaces.Length() ; Starting "place-in-game" in [oPlaces] array

#IfWinActive, ahk_group Game
    !1::SetControlMode("Manual")
    !2::SetControlMode("AE Road")
    !3::SetControlMode("AE Yard")
    !4::SetControlMode("AE Waypoint")
    ; Places from West to East (Places from "early game" to "late game")
    ; Hint to remember: split whole railroad to two parts: EAST and WEST
    ; EAST LINE: from "Sylva" to "Hemingway" = from F12 to F5
    ; WEST LINE: from "Alarka" trough "Alarka Jct" to "Andrews" = from +F12 to +F5
    F12::Teleport("Sylva")
    F11::Teleport("Dillsboro")
    F10::Teleport("Wilmot")
    F9:: Teleport("East Whittier")
    F8:: Teleport("Whittier")
    !F8:: Teleport("Connelly") ; Alt = Alternative route near "Whittier"
    F7:: Teleport("Ela")
    F6:: Teleport("Bryson")
    !F6:: Teleport("Walker")   ; Alt = Alternative route near "Bryson"
    F5:: Teleport("Hemingway")
    +F12:: Teleport("Alarka")
    +F11:: Teleport("Cochran")
    +F10:: Teleport("Alarka Jct")
    PgDn::TeleportDirection("Left")
    PgUp::TeleportDirection("Right")
    ; In-game hotkey changes direction only in "Manual Control Mode".
    ; Use mouse click to change direction, this works for all "Control Modes".
    ; !Q::SendEvent, ^[ ; Direction R
    ; !E::SendEvent, ^] ; Direction F
    !Q::Click(140, iClientHeight - 65) ; Direction: R
    !E::Click(200, iClientHeight - 65) ; Direction: F
    ; [R] = move any control forward (apply brake, release throttle)
    ; [F] = move any control backward (release brake, apply full throttle)
    ; !R::SendEvent, {= 10} ; Zero Throttle
    ; !F::SendEvent, {- 10} ; Full Throttle
    !R::   Click(250, iClientHeight - 65) ; Simplified Controls + Road + Waypoint: Full Brake
    !F::   Click(420, iClientHeight - 65) ; Simplified Controls + Road + Waypoint: Full Throttle
    Space::Click(340, iClientHeight - 65) ; Simplified Controls: Neutral
    !A::SendEvent, 9  ; Camera Follow Tail
    !D::SendEvent, 0  ; Camera Follow Head
    !S::SendEvent, +9 ; Camera Jump to Tail
    !W::SendEvent, +0 ; Camera Jump to Head
    F4::Send, ^t ; Jump to Mouse
    F:: Send, ^f ; Place Flare
    G:: Send, ^g ; Auto Engineer Waypoint Select
    O:: SendEvent, q ; Lean Left
    P:: SendEvent, e ; Lean Right
#If

!C::Suspend
!Z::Reload
!X::ExitApp

Click(X := "", Y := "")
{
    If ((X and !Y) or (!X and Y)) {
        ToolTip % A_ThisFunc "(X, Y) - undefined X or Y parameter"
        Return
    }
    BlockInput, MouseMove
    MouseGetPos, _X, _Y
    Click %X% %Y%
    MouseMove, _X, _Y
    BlockInput, MouseMoveOff
}

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

!F1:: ShowHelpWindow("
(
Reload script on game's window size change to redetect its dimensions.
Suspend script while typing text.

EAST LINE: from [Hemingway] to [Sylva]
WEST LINE: from [Andrews] to [Alarka] trough [Alarka Jct]
ALT key modifier for alternative route near station

TELEPORTATION
        F5 .. F12 = Teleport to EAST LINE
Shift + F5 .. F12 = Teleport to WEST LINE
         Alt + F6 = Teleport to [Walker] alternative route near [Whittier]
         Alt + F8 = Teleport to [Connelly] alternative route near [Bryson]
      PgUp && PgDn = Teleport to right/left location

ENGINE CONTROLS
Alt + 1 .. 4 = Set [Control Mode] of the engine
 Alt + Q && E = Set [Direction]
 Alt + R && F = Set [Full Brake] && [Full Throttle]
       Space = Set [Neutral]

ENGINE CAMERA
Alt + A && D = Camera [Follow Tail && Head]
Alt + S && W = Camera [Jump to Tail && Head]
      O && P = Camera [Lean Left && Right]

MISC
F4 = Jump to Mouse
 F = Place Flare
 G = Auto Engineer Waypoint Select

SCRIPT
Alt + C = Suspend
Alt + Z = Reload
Alt + X = Exit
)")
