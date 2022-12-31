; Military Formation Helper (Lite version of Northgard Trainer)

; Changelog
;  + added
;  * changed
;  - deleted
;  ! bug fixed
;
; v1.0.0
;  + Initial release

#NoEnv
#SingleInstance Force
#UseHook ; All hotkeys can't be triggered by Send command
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, DuneSpiceWars.ico, 1, 1
Menu, Tray, Tip, Dune - Spice Wars (Military Formation Helper)

#Include <SearchOverlay>

; By default all [CoordMode] are relative to [Screen], but ToolTip somehow did not obey default value.
; For clarity set them explicitly.
CoordMode,   Mouse, Screen
CoordMode, ToolTip, Screen

SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetKeyDelay, -1, 25

; Send() wrapper function settings: TRUE = SendInput, FALSE = SendEvent
global bSendInput := true
global SendInputDelay := -1
global SendInputPressDuration := 25

global dlDefault := 50 ; default sleep delay to wait some game reaction: show menu, select units, some mouse move, some send keys, etc...
global dl := dlDefault ; this variable used in script, [dlDefault] and [dlSlow] are hardcoded settings for it

global bSlowMode := false ; slow down mouse speed for debug purpose
global mouseSpeedSlow := 25 ; mouse speed on 'Slow Mode'
global dlSlow := 500 ; sleep delay to wait some game reaction on 'Slow Mode'

global isDebug = IsDebugScript()

if (!isDebug) ; on Debug reload script will break debugging
    Reload_AsAdmin() ; for BlockInput we need admin rights

GroupAdd, Game, ahk_exe D4X.exe

helpText := "
(
BlockInput (to prevent mouse move interfere with user input) need admin rights!
    If script block input by mistake, press [Ctrl + Alt + Del] to unblock.

                                [CIVILIAN]
                       Not work, when icon is shaking
                        C = Deploy Idle Harvester
                        V = Resolve Investigated POI
                        B = Trade Request

                                 [SCRIPT]
                                 F1 = Show Help
                        LeftAlt + Z =  Reload Script
                        LeftAlt + X =    Exit Script
                        LeftAlt + C = Suspend Script

                                  [DEBUG]
            'Overlay' shows 'ImageSearch' and 'PixelGetColor' areas.
             Hotkeys not designed to use, when 'Overlay' is on screen.
            'Slow Mode':
                * decrease mouse move speed.
                * increase sleep delay between game actions.

                           Alt + F1 = Toggle 'Slow Mode'
                          Ctrl + F1 = Toggle 'Overlay'
                         Shift + F1 = Toggle 'Send Mode'

                                [MILITARY]
          CapsLock + RMB + Drag = Make Military Formation (UnitsByType)

                        [MILITARY FORMATION HELPER]
          Move 'Melee' units on START DOT and 'Ranged' units on END DOT.

           'Melee' means all units assigned to in-game '1' hotkey.
          'Ranged' means all units assigned to in-game '2' hotkey.
)"

;-------------------------------------------------------------
;--------------------- MILITARY VARIABLE ---------------------
;-------------------------------------------------------------

; Any ToolTip, which appear on screen (from any AutoHotKey script) will break this script functionality.
; Game will be "switching", taskbar may appear, cursor will move outside of game window, etc...

; Click and hold [modifierKey & RightMouseButton], where you want place head of formation and drag where you want place end of formation.
; Release [RightMouseButton]. Your units will go on places, marked by yellow dots.
; Release [modifierKey] before release [RightMouseButton] will cancel formation mode.
; Dots - points on screen, where each type of military units will be send.
; Dots - points on screen, where GUI window (circle) will be shown to help user see future unit's positions.
global period := 100 ; period of calculation dots positions
global idMelee := "Melee"  ; can be any word or even number, script uses it like ID
global idRanged := "Ranged" ; can be any word or even number, script uses it like ID
; Distance between units (unit order are set in unitOrder[] array)
; 0 - position will be on start point (if scale is 1)
; 1 - position will be on end point (if scale is 1)
; unitDistN - N is number of units and dots
global meleeHotkey  := "1" ; assign WarChief units to this in-game hotkey (select big units and press Ctrl+0)
global rangedHotkey := "2" ; assign WarChief units to this in-game hotkey (select big units and press Ctrl+0)
global unitDist  := [0, 1] ; length of this array must be in sync with unitOrder[] array length
global unitOrder := [idMelee, idRanged]
global scale := 1 ; Scale all distances in unitDist[] (each value is multiply by [scale]): <1 less sensitive, ==1 linear, >1 more sensitive.
global d := 20 ; gui dot diameter
global r := d // 2 ; gui dot radius
global dotNum := unitDist.Length() ; number of dots
global dotX := [] ; coordinates of dots
global dotY := [] ; coordinates of dots
global dotColor := "Lime" ; [HTML color names] in AutoHotKey.chm
global x0, y0 ; Start point - coordinates of mouse, when you click [modifierKey & RightMouseButton].
global x1, y1 ; End point - current mouse coordinates (when you drag mouse after click).
global hypotenuse ; distance between Start point and End point

;   x
; ------*x1,y1
; |    /
; |   /
;y|  /hypotenuse
; | /
; |/ <-- A angle
; * x0,y0

CheckMilitarySettings()
CreateDots()
overlay := new SearchOverlay()

;-------------------------------------------------------------
;--------------------- MILITARY HOTKEYS ----------------------
;-------------------------------------------------------------

; Hotkey combination A&B will screen A key
; $ modifier = will not trigger hotkey itself
; ~ modifier = will not screen default action of key

#IfWinActive ahk_group Game
; Modifier key ("CapsLock" in this hotkey) of RButton (RightMouseButton) must be in sync with [modifierKey] variable
; It implements "cancel formation" logic in CalculateDots() when user release [modifierKey]
global modifierKey := "CapsLock"
CapsLock & RButton::DragBegin()
CapsLock & RButton Up::DragEnd()

;-------------------------------------------------------------
;--------------------- CIVILIAN HOTKEYS ----------------------
;-------------------------------------------------------------

C::DeployIdleHarvester()
V::ResolveInvestigatedPOI()
B::TradeRequest()

;-------------------------------------------------------------
;---------------------- GENERAL HOTKEYS ----------------------
;-------------------------------------------------------------

^F1::overlay.ToggleOverlay()
!F1::ToggleSlowMode()
+F1::ToggleSendMode()

#If
F1::ShowHelpText(helpText)
<!Z::Reload
<!X::ExitApp
<!C::
    Suspend
    if (toggleSuspend := !toggleSuspend)
        ShowToolTip("Script SUSPEND", 0, 0)
    else
        ShowToolTip()
return

;-------------------------------------------------------------
;----------------------- CIVILIAN CODE -----------------------
;-------------------------------------------------------------

DeployIdleHarvester()
{
    ImageSearch, x, y, 455, 40, 1110, 90, DuneSpiceWarsHarvesterIdle.png ; PopUpIcons
    if (ErrorLevel) {
        if (isDebug)
            ShowToolTip(A_ThisFunc "(DuneSpiceWarsHarvesterIdle.png) - can't find image.", 0, 0)
        return
    }
    Critical, On
    BlockInput, On
    MouseGetPos, _x, _y
    Click(x + 10, y + 10, , dl) ; click in icon's center (add offset)
    Click(425, 990) ; Press [Deploy] button
    MouseMove(_x, _y)
    BlockInput, Off
    Critical, Off
}

ResolveInvestigatedPOI()
{
    ImageSearch, x, y, 455, 40, 1110, 90, DuneSpiceWarsInvestigationDone.png ; PopUpIcons
    if (ErrorLevel) {
        if (isDebug)
            ShowToolTip(A_ThisFunc "(DuneSpiceWarsInvestigationDone.png) - can't find image.", 0, 0)
        return
    }
    Critical, On
    BlockInput, On
    MouseGetPos, _x, _y
    Click(x + 10, y + 10, , dl) ; click in icon's center (add offset)
    Click(255, 1005) ; Press  left [Resolve] button
    Click(565, 1005) ; Press right [Resolve] button
    MouseMove(_x, _y)
    BlockInput, Off
    Critical, Off
}

TradeRequest()
{
    ImageSearch, x, y, 455, 40, 1110, 90, DuneSpiceWarsTradeRequest.png ; PopUpIcons
    if (ErrorLevel) {
        if (isDebug)
            ShowToolTip(A_ThisFunc "(DuneSpiceWarsTradeRequest.png) - can't find image.", 0, 0)
        return
    }
    Critical, On
    BlockInput, On
    MouseGetPos, _x, _y
    Click(x + 10, y + 10, , dl) ; click in icon's center (add offset)
    MouseMove(_x, _y)
    BlockInput, Off
    Critical, Off
}

;-------------------------------------------------------------
;------------------ MILITARY FORMATION CODE ------------------
;-------------------------------------------------------------

DragBegin()
{
    MouseGetPos, x0, y0
    ShowDot(1, x0, y0)
    SetTimer, CalculateDots, %period%
    CalculateDots() ; don't wait [period], call immediately
}

CalculateDots()
{
    Critical, On

    ; Disable timer ("cancel" formation) if user release [modifierKey]
    if (!GetKeyState(modifierKey, "P")) {
        SetTimer, , Off
        ; On release RButton DragEnd() check [hypotenuse] value
        ; Set it equal -1 to "cancel" unit's move
        hypotenuse := -1
        HideDots()
        return
    }

    MouseGetPos, x1, y1
    x := x1 - x0
    y := y1 - y0
    hypotenuse := Sqrt(x*x + y*y)
    tanA := Abs(x/y)
    denominator := Sqrt(1 + tanA*tanA)
    cosA := 1 / denominator
    sinA := tanA / denominator
    for i, k in unitDist {
        dotX[i] := Floor(hypotenuse * sinA * k * scale)
        dotY[i] := Floor(hypotenuse * cosA * k * scale)
        if (x < 0)
            dotX[i] := -dotX[i]
        if (y < 0)
            dotY[i] := -dotY[i]
        dotX[i] := x0 + dotX[i]
        dotY[i] := y0 + dotY[i]
    }
    ShowDots()

    Critical, Off
}

DragEnd()
{
    MouseGetPos, x1, y1 ; save mouse cursor original position
    SetTimer, CalculateDots, Off
    if (hypotenuse != -1) { ; "cancel formation" logic, see comments in CalculateDots()
        Critical, On
        BlockInput, On
        Click(x1, y1) ; deselect all (units, buildings, menu, etc...)
        ; "GUI Point" loop A_Index for dotX[] and dotY[] arrays
        Loop, % dotNum {
            if (unitOrder[A_Index] == idMelee) {
                Send(meleeHotkey, dl)
            }
            if (unitOrder[A_Index] == idRanged) {
                Send(rangedHotkey, dl)
            }
            Click(dotX[A_Index], dotY[A_Index], "Right", dl)
            HideDot(A_Index)
            Sleep, % dl
        }
        MouseMove(x1, y1) ; restore mouse cursor original position
        SendEvent, ^a ; [Ctrl+A] select all visible units on screen
        BlockInput, Off
        Critical, Off
        ; Send {%modifierKey% Up} ; Possibly prevents "stuck down" modifier key (read BlockInput in AutoHotKey.chm).
    }
    HideDots()
}

CreateDot(id)
{
    CreateMouseClickTransGui("Dot" . id, dotColor)
    Gui, Dot%id%: Margin, 0, 0
    WinSet, Region, 0-0 W%d% H%d% E
}

CreateDots()
{
    Loop, % dotNum
        CreateDot(A_Index) ; create outside of screen
}

ShowDot(id, x, y)
{
    Gui, Dot%id%: Show, % "W"d " H"d " X" (x - r) " Y" (y - r) " NoActivate"
}

ShowDots()
{
    Loop, % dotNum
        ShowDot(A_Index, dotX[A_Index], dotY[A_Index])
}

HideDot(id)
{
    Gui, Dot%id%: Hide
}

HideDots()
{
    Loop, % dotNum
        HideDot(A_Index)
}

DestroyDot(id)
{
    Gui, Dot%id%: Destroy
}

DestroyDots()
{
    Loop, % dotNum
        DestroyDot(A_Index)
}

;-------------------------------------------------------------
;---------------------- RECTANGLE CODE -----------------------
;-------------------------------------------------------------

CreateMouseClickTransGui(id, color := "")
{
    ; Gui, GuiName:New [, Options, Title]
    ; If [GuiName] is specified, a new GUI will be created, destroying any existing GUI with that name.
    ; Otherwise, a new unnamed and unnumbered GUI will be created.
    ; Calling [Gui, New] ensures that the script is creating a new GUI, not modifying an existing one.
    ; +E0x20 makes GUI mouse-click transparent.
    Gui, %id%: New, -Caption -SysMenu +AlwaysOnTop +LastFound +ToolWindow +E0x20
    Gui, %id%: Color, % color
    WinSet, TransColor, 500 ; This line is necessary to working +E0x20 !!!! Very complicated theme.
}

;-------------------------------------------------------------
;----------------------- GENERAL CODE ------------------------
;-------------------------------------------------------------

CheckMilitarySettings()
{
    err := ""
    if (unitDist.Length() != unitOrder.Length())
        err .= A_Tab . "unitDist.Length() != unitOrder.Length()`n"
    if (err) {
        str := "Error in military params:`n"
        str .= err
        str .= "Look at comments above [unitDist] and [unitOrder] declaration"
        MsgBox % str
    }
}

ShowHelpText(text)
{
    static toggle
    if (toggle := !toggle) {
        CreateMouseClickTransGui("HelpText")
        Gui, HelpText: Font, s14, Consolas
        Gui, HelpText: Add, Text, , % text
        Gui, HelpText: Show, NoActivate
    }
    else
        Gui, HelpText: Destroy
}

ShowToolTip(text := "", x := "", y := "", displayTime := -1, id := "", fontSize := "s20")
{
    ; To update tooltip's [displayTime] we need identify timer by it's label, in our case it's BoundFunc Object
    static oLabels := {} ; Object to store timer's [BoundFunc Object] 'value' by tooltip's [ID] 'key'
    idOrig := id ; Save original id
    id := "ToolTip" . id ; Add prefix to be sure, Gui window belong to tooltip
    if (text) {
        if (x == "" or y == "") {
            coordModeMousePrev := A_CoordModeMouse
            CoordMode, Mouse, Screen
            MouseGetPos, x, y
            CoordMode, Mouse, % coordModeMousePrev
        }
        ;======ToolTip Window======;
        CreateMouseClickTransGui(id)
        Gui, %id%: Margin, 0, 0
        Gui, %id%: Font, % fontSize, Consolas
        Gui, %id%: Add, Text, , % text
        Gui, %id%: Show, % "x" x " y" y " NoActivate"
        ;==========================;
        oLabel := oLabels[id] ; Get saved object of displayed tooltip to identify waiting timer to update it
        if (displayTime != -1) {
            if (oLabel == "") {
                oLabel := Func("RemoveToolTip").Bind(idOrig, oLabels)
                oLabels[id] := oLabel
            }
            SetTimer, % oLabel, % -displayTime
        } else {
            if (oLabel != "")
                SetTimer, % oLabel, Off
        }
    } else {
        Gui, %id%: Destroy
    }
}

RemoveToolTip(id := "", oLabels := "")
{
    id := "ToolTip" . id
    oLabels.Delete(id)
    Gui, %id%: Destroy
}

Send(key, delay := -1)
{
    if (bSendInput) {
        SendInput, {%key% down}
        if (SendInputPressDuration != -1)
            Sleep, %SendInputPressDuration%
        SendInput, {%key% up}
        if (SendInputDelay != -1)
            Sleep, %SendInputDelay%
    } else {
        SendEvent, {%key%}
    }
    if (delay != -1)
        Sleep, %delay%
}

SendRaw(string, delay := -1)
{
    if (bSendInput)
        SendInput, %string%
    else
        SendEvent, %string%
    if (delay != -1)
        Sleep, %delay%
}

Click(x := "", y := "", WhichButton := "", delay := -1)
{
    if ((x and !y) or (!x and y)) {
        ShowToolTip(A_ThisFunc "(X, Y) - undefined X or Y parameter", 0, 0)
        return
    }
    SetMouseSpeedSlow()
    if (bSendInput)
        SendInput, {Click %x% %y% %WhichButton%}
    else
        SendEvent, {Click %x% %y% %WhichButton%}
    if (delay != -1)
        Sleep, %delay%
}

MouseMove(x, y, speed := "")
{
    SetMouseSpeedSlow()
    MouseMove, %x%, %y%, %speed%
}

SetMouseSpeedSlow()
{
    if (bSlowMode) {
        SetMouseDelay, 10
        SetDefaultMouseSpeed, %mouseSpeedSlow%
    }
}

ToggleSlowMode()
{
    if (bSlowMode := !bSlowMode) {
        dl := dlSlow
        ShowToolTip("Slow Mode: Enabled", 0, 0, 1000)
    }
    else {
        dl := dlDefault
        ShowToolTip("Slow Mode: Disabled", 0, 0, 1000)
    }
}

ToggleSendMode()
{
    if (bSendInput := !bSendInput)
        ShowToolTip("SendMode: Input", 0, 0, 1000)
    else
        ShowToolTip("SendMode: Event", 0, 0, 1000)
}

IsDebugScript()
{
    FullCmdLine := DllCall("GetCommandLine", "Str")
    if(RegExMatch(FullCmdLine, "i)/debug"))
        return true
    else
        return false
}
