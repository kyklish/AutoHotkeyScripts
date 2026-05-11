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
   Alt + F3 = Show Gas & Liquid Density
   Alt + F4 = Show Transit Tube Landing

Alt + Q\W\E = Door [Open \ Auto \ Lock] Button
    Alt + A = Printing Pod [Choose a Blueprint] Button
    Alt + A = Signal Switch [Switch Picture] Button
    Alt + A = Suit Dock [Deliver Suit] Button
    Alt + Z = Suit Dock [UnDock Suit] Button
    Alt + D = Building [Deconstruct \ Cancel Deconstruct] Button
    Alt + C = Building [PreConfigure Building Settings] Button (from <Blueprints Expanded> Mod)
    Alt + X = Tool Filter [Dig Orders] Radio Button (from <Blueprints Expanded> Mod)

 ScrollLock = Toggle Tooltip [Mouse Cursor Position]
    NumpadN = Move Mouse Cursor [Numpad1-4 \ Numpad6-9]
    Numpad5 = Copy Mouse Cursor Position

    Ctrl + Alt + Z = Reload Script
    Ctrl + Alt + X = Exit Script

Usage: move mouse cursor over object and press hotkey.
)"

#IfWinActive ahk_group Game
    !Q::ClickRestore(1360, 565)                     ; Door [Open] Button
    !W::ClickRestore(1450, 565)                     ; Door [Auto] Button
    !E::ClickRestore(1540, 565)                     ; Door [Lock] Button
    !A::ClickRestore(1450, 865)                     ; Suit Dock [Deliver Suit] Button \ Printing Pod [Choose a Blueprint] Button \ Signal Switch [Switch Picture] Button
    !Z::ClickRestore(1450, 920)                     ; Suit Dock [UnDock Suit] Button
    !C::ClickRestore(1450, 945, True, False, False) ; Building [PreConfigure Building Settings] Button (from <Blueprints Expanded> Mod)
    !D::ClickRestore(1670, 915)                     ; Building [Deconstruct \ Cancel Deconstruct] Button
    !X::ClickRestore(1883, 823, False, False, True) ; Tool Filter [Dig Orders] Radio Button (from <Blueprints Expanded> Mod)
#If

!F1::ShowHelpWindow(sHelpText)
!F2::ShowHelpImage("OxygenNotIncludedBaseGameRocketCalculatorCheatSheet.png")
!F3::ShowHelpImage("OxygenNotIncludedGasLiquidDensity.png")
!F4::ShowHelpImage("OxygenNotIncludedTransitTubeLanding.png")
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

^!Z::Reload
^!X::ExitApp

ClickRestore(Xbtn, Ybtn, bSelect := True, bDeselect := True, bRestore := True)
{
    Critical, On
    BlockInput, MouseMove

    ; [Click] command without XY coordinates doesn't work in this game!

    MouseGetPos, mX, mY
    If (bSelect)                 ; Click on object (Open UI)
        Send, {Click, %mX% %mY%}
    Send, {Click, %Xbtn% %Ybtn%} ; Click button in UI
    If (bDeselect && bRestore)   ; Deselect (Close UI) & Restore mouse position
        Send, {Click, %mX% %mY% Right}
    Else {
        If (bDeselect)           ; Deselect (Close UI)
            MsgBox % NOT IMPLEMENTED (TRY ESCAPE BUTTON)
        If (bRestore)            ; Restore mouse position
            MouseMove, mX, mY
    }

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
