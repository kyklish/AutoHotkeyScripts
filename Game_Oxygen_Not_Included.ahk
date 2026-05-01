#NoEnv
#SingleInstance Force
#UseHook ; All hotkeys can't be triggered by Send command
SendMode, Input
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, OxygenNotIncluded.ico, 1, 1
Menu, Tray, Tip, OxygenNotIncluded More Hotkeys

SetDefaultMouseSpeed, 0
SetMouseDelay, 100

GroupAdd, Game, ahk_exe OxygenNotIncluded.exe

bShowTooltip := False

sHelpText := "
(
   Alt + F1 = Show Help
   Alt + F2 = Show Rocket Calculator Cheat Sheet
   Alt + F3 = Show Transit Tube Landing
Alt + Q\W\E = Door [Open \ Auto \ Lock] Button
    Alt + A = Suit Dock [Deliver Suit] Button \ Printing Pod [Choose a Blueprint] Button
    Alt + C = [PreConfigure Building Settings] Button
    Alt + Z = Suit Dock [UnDock Suit] Button
    Alt + D = [Deconstruct \ Cancel Deconstruct] Button

 ScrollLock = Toggle Tooltip [Mouse Cursor Position]
    NumpadN = Move Mouse Cursor [Numpad1-4 \ Numpad6-9]
    Numpad5 = Copy Mouse Cursor Position

Usage: move cursor over [Building] or [Tile] and press hotkey.
)"

#IfWinActive ahk_group Game
    !Q::ClickRestore(1360, 565)        ; [Open] Button
    !W::ClickRestore(1450, 565)        ; [Auto] Button
    !E::ClickRestore(1540, 565)        ; [Lock] Button
    !A::ClickRestore(1450, 865)        ; [Deliver Suit] Button \ Printing Pod [Choose a Blueprint] Button
    !Z::ClickRestore(1450, 920)        ; [UnDock Suit] Button
    !C::ClickRestore(1450, 945, False) ; [PreConfigure Building Settings] Button
    !D::ClickRestore(1670, 915)        ; [Deconstruct \ Cancel Deconstruct] Button
#If

!F1::ShowHelpWindow(sHelpText)
!F2::ShowHelpImage("OxygenNotIncludedBaseGameRocketCalculatorCheatSheet.png")
!F3::ShowHelpImage("OxygenNotIncludedTransitTubeLanding.png")
ScrollLock::ToggleTooltip()

#If bShowTooltip
    Numpad4::MouseMove, -1,  0, , R
    Numpad6::MouseMove,  1,  0, , R
    Numpad8::MouseMove,  0, -1, , R
    Numpad2::MouseMove,  0,  1, , R
    Numpad7::MouseMove, -1, -1, , R
    Numpad9::MouseMove,  1, -1, , R
    Numpad1::MouseMove, -1,  1, , R
    Numpad3::MouseMove,  1,  1, , R
    Numpad5::Clipboard := mX ", " mY
#If

!Z::Reload
!X::ExitApp

ClickRestore(Xbtn, Ybtn, bDeselect := true)
{
    Critical, On
    BlockInput, MouseMove

    ; [Click] command without XY coordinates doesn't work in this game!

    MouseGetPos, mX, mY
    Send, {Click, %mX% %mY%}           ; Click on object (Open UI)
    Send, {Click, %Xbtn% %Ybtn%}     ; Click button in UI
    If (bDeselect)
        Send, {Click, %mX% %mY% Right} ; Deselect (Close UI) and restore mouse position

    BlockInput, MouseMoveOff
    Critical, Off
}

GetData()
{
    global mX, mY, mColor
    MouseGetPos, mX, mY
    PixelGetColor, mColor, %mX%, %mY%, RGB
    ToolTip % "X:" mX ", Y:" mY ", RGB:" mColor
}

ToggleTooltip()
{
    global bShowTooltip
    If (bShowTooltip := !bShowTooltip) {
        SetTimer, GetData, 100
    } Else {
        SetTimer, GetData, Off
        ToolTip
    }
}
