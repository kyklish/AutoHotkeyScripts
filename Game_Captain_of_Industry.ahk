; Captain of Industry Helper
; Tested User Interface Scale 80, 100, 120% [uiScale] variable
; UI very unstable, icons changes their shape and color!!!
; Use ImageSearch and PixelSearch as your last tool!!!

; Changelog
;  + added
;  * changed
;  - deleted
;  ! bug fixed
;
; v2.3.2
;  + Tooltip on script's suspend
; v2.3.1
;  * Make global hotkey to unblock mouse
; v2.3.0
;  + Explore location with enemy
;  * Change hotkeys
; v2.2.3
;  + New hotkey for help text
;  * Help text
;  ! Fix not working hotkeys
; v2.2.2
;  + New hotkey to unblock mouse input
;  * Change hotkeys
;  * Don't block keyboard input, only mouse
; v2.2.1
;  * Help text
; v2.2.0
;  + Add Copy/PasteEdit/PasteSave blueprint description
; v2.1.0
;  + Add world map exploration
;  * Change hotkeys
; v2.0.1
;  * Change hotkey
;  + New hotkey to suspend script
; v2.0.0
;  * Search methods
; v1.0.0
;  + Initial release

#NoEnv
#SingleInstance Force
#UseHook ; All hotkeys can't be triggered by Send command
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, CaptainOfIndustry.ico, 1, 1
Menu, Tray, Tip, Captain of Industry Helper

; By default all [CoordMode] are relative to [Screen], change it to [Client].
CoordMode,   Pixel, Client
CoordMode,   Mouse, Client
CoordMode, ToolTip, Client

SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetKeyDelay, -1, 25

helpText := "
(
Set your [User Interface Scale] ratio to [uiScale] variable, default 100%!

          F1 -> Show help (when game not on screen).
   Ctrl + F1 -> Show help.
          F7 -> WORLD MAP: quick EXPLORE unknown location.
          F8 -> WORLD MAP: quick EXPLORE location with enemy.
          F9 -> VEHICLE:   quick DELETE.
         F10 -> VEHICLE:   quick UPGRADE.
     Alt + C -> BLUEPRINT:  copy description text.
     Alt + V -> BLUEPRINT: paste description text and save it.
     Alt + B -> BLUEPRINT: paste description text.
         F12 -> BLUEPRINT: save position of DESCRIPTION BUTTON.
Ctrl + Enter -> Unblock mouse input (if it was blocked by mistake).
     Alt + S -> Suspend Script (disable all hotkeys).
     Alt + Z ->  Reload Script.
     Alt + X ->    Exit Script.

Usage VEHICLE DELETE/UPGRADE:
    - maximum zoom in for better performance.
    - tilt camera to top view (vehicle will be placed in the center of screen).
    - open VEHICLES MANAGEMENT window.
    - point mouse cursor on VEHICLE icon.
    - press hotkey to upgrade/delete vehicle.
    - wait until VEHICLES MANAGEMENT window opens again.
    - press hotkey to upgrade/delete next vehicle, repeat.

Usage WORLD MAP EXPLORE/BATTLE:
    - WORLD MAP must be closed.
    - press hotkey to explore/battle.

Usage BLUEPRINT COPY/PASTE:
    - put mouse cursor on DESCRIPTION BUTTON and press hotkey to save it's
      position (it has different position for FILE and FOLDER!).
    - put mouse cursor over desired blueprint and press desired hotkey.

Tips:
    - make the camera view from above (top view) so there is less miss-clicks
      at the vehicles. When the camera is looking at an angle, the car may be
      hidden behind a building or just have offset on big camera angles.
    - increase delay between manipulations [dlOperation] and [dlCameraMove] for
      better reliability.
    - reload the script to remove tooltip with error.
)"

;@AHK++AlignAssignmentOn
uiScale           := 100 ; User Interface Scale [tested 80%, 100%, 120%]
dlOperation       := 300 ; Delay between operations: open window, click, etc
dlCameraMove      := 500 ; Delay to wait camera movement to VEHICLE
global bSendInput := true
xBtn              := "" ; Position of DESCRIPTION BUTTON in BLUEPRINTS window
yBtn              := "" ; Position of DESCRIPTION BUTTON in BLUEPRINTS window
;@AHK++AlignAssignmentOff

; VEHICLE MANAGEMENT ICON (near HEALTH and UNITY icons): absolute coordinates
global oVMI  := { 0:0
    , x: 245 * uiScale // 100
    , y:  45 * uiScale // 100 }
; VEHICLE WINDOW ORDERS ICONS COL (39x39): relative to bottom left corner of VEHICLE WINDOW
global oOIC := { 0:0
    , xDelete:   39 * uiScale // 100
    , xUpgrade: 189 * uiScale // 100 }
; VEHICLE WINDOW ORDERS ICONS ROW (39x39): relative to bottom left corner of VEHICLE WINDOW
global oOIR := { 0:0
    , y: 114 * uiScale // 100 }
; UNKNOWN LOCATION EXPLORE BUTTON: relative to bottom left corner of UNKNOWN LOCATION WINDOW
global oULI  := { 0:0
    , x: 123 * uiScale // 100
    , y:  26 * uiScale // 100 }

GroupAdd, Game, ahk_exe Captain of Industry.exe

#IfWinActive, ahk_group Game ; <==== Main hotkeys.
    F7::  MakeManipulation(Func("ExploreLocation").Bind("Unknown", dlOperation))
    F8::  MakeManipulation(Func("ExploreLocation").Bind("Enemy", dlOperation))
    F9::  MakeManipulation(Func("VehicleOrder").Bind( "Delete", dlOperation, dlCameraMove))
    F10:: MakeManipulation(Func("VehicleOrder").Bind("Upgrade", dlOperation, dlCameraMove))
    !C::  MakeManipulation(Func("BlueprintDescription").Bind("Copy", xBtn, yBtn, dlOperation))
    !V::  MakeManipulation(Func("BlueprintDescription").Bind("PasteSave", xBtn, yBtn, dlOperation))
    !B::  MakeManipulation(Func("BlueprintDescription").Bind("Paste", xBtn, yBtn, dlOperation))
    F12:: DscrBtnSavePos(xBtn, yBtn) ; Save position of DESCRIPTION BUTTON in BLUEPRINTS window
#IfWinNotActive, ahk_group Game
    F1:: ShowHelpWindow(helpText)
#If
^Enter:: BlockInput, MouseMoveOff ; Unblock mouse input (if it was blocked by mistake)
^F1:: ShowHelpWindow(helpText)
!Z:: Reload
!X:: ExitApp
!S::
    Suspend
    if (toggleSuspend := !toggleSuspend)
        ToolTip, % "Script SUSPEND", 0, 0
    else
        ToolTip
return

;-------------------------------------------------------------
;------------------------- GAME CODE -------------------------
;-------------------------------------------------------------

MakeManipulation(oBoundFunc)
{
    ; On [BlockInput On] you need wait, until user releases all modifier's keys
    ; or they become "stuck down". Example:
    ;   ^!p::
    ;   KeyWait Control  ; Wait for the key to be released.
    ;       Use one KeyWait for each of the hotkey's modifiers.
    ;   KeyWait Alt
    ;   BlockInput On
    ; MORE PROBLEMS WITH IT

    ToolTip ; Hide tooltip after ImageSearch() error
    clSz := WinGetClientSize()

    Critical, On
    BlockInput, MouseMove
    MouseGetPos, _x, _y

    %oBoundFunc%(clSz)
    ; oBoundFunc.Call(clSZ)

    MouseMove, % _x, % _y
    BlockInput, MouseMoveOff
    Critical, Off
}

VehicleOrder(order, dlOperation, dlCameraMove, clSz)
{
    ; Click VEHICLE icon in VEHICLES MANAGEMENT window and wait for camera movement
    Click(_x, _y, , dlOperation)
    Send("Esc", dlCameraMove) ; Close VEHICLES MANAGEMENT window
    ; Click on VEHICLE in the center of the screen: opens VEHICLE window
    Click(clSz.w / 2, clSz.h / 2, , dlOperation)
    ; Find bottom left corner of VEHICLE window
    ; 2 shades of variation. Using black color in images like alpha channel.
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryBottomLine.png", clSz)
    if (ErrorLevel)
        Return
    Switch order {
    Case "Upgrade":
        ; Click UPGRADE icon in VEHICLE window
        Click(x + oOIC.xUpgrade, y - oOIR.y, , dlOperation)
    Case "Delete":
        ; Click DELETE icon in VEHICLE window
        Click(x + oOIC.xDelete, y - oOIR.y, , dlOperation)
    Default:
        MsgBox % A_ThisFunc "() - No such order for vehicle: " order
    }
    ; Open VEHICLES MANAGEMENT window: returns to start position
    Click(oVMI.x, oVMI.y, , dlOperation)
}

ExploreLocation(operation, dlOperation, clSz)
{
    Send("Tab", dlOperation) ; Open WORLD MAP and zoom out
    Send("Click WheelDown 15", dlOperation) ; Minimum 10 notches to zoom out WORLD MAP
    ; Find and click on LOCATION ICON
    Switch operation {
    Case "Enemy":
        ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryLocationWithEnemyIcon.png", clSz)
    Case "Unknown":
        ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryUnknownLocationIcon.png", clSz)
    Default:
        ToolTip, % A_ThisFunc "() - No such operation: " operation
    }
    if (ErrorLevel)
        Return
    Click(x, y, , dlOperation)
    ; Find bottom left corner of LOCATION window
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryBottomLine.png", clSz)
    if (ErrorLevel)
        Return
    Click(x + oULI.x, y - oULI.y, , dlOperation) ; Click EXPLORE/BATTLE button
    Send("Esc", dlOperation) ; Close LOCATION window
    Send("Tab") ; Close WORLD MAP
}

BlueprintDescription(operation, xBtn, yBtn, dlOperation, clSz)
{
    if (!xBtn or !yBtn) {
        ToolTip, % "Unknown position of the DESCRIPTION BUTTON in BLUEPRINTS window.`n`nLook help [Ctrl + F1] for usage."
        Return
    }
    Click( , , , dlOperation) ; Click on blueprint under cursor
    Click(xBtn, yBtn, , dlOperation) ; Click DESCRIPTION button
    Click(clSz.w / 2, clSz.h / 2, , dlOperation) ; Click in the center of the screen
    SendRaw("^a", dlOperation) ; Select all
    Switch operation {
    Case "Copy":
        SendRaw("^c", dlOperation) ; Copy
        Send("Esc") ; Close UPDATE DESCRIPTION window
    Case "Paste": ; Do not close window, user will edit text
        SendRaw("^v") ; Paste
    Case "PasteSave":
        SendRaw("^v", dlOperation) ; Paste
        ; Find top left corner of APPLY CHANGES button
        ImageSearch(x, y, "CaptainOfIndustryApplyButton.png", clSz)
        if (ErrorLevel)
            Return
        ; Click APPLY CHANGES button
        Click(x + 10, y + 10, , dlOperation) ; Add offset of image size (10x10)
    Default:
        ToolTip, % A_ThisFunc "() - No such operation: " operation
    }
}

DscrBtnSavePos(ByRef xBtn, ByRef yBtn)
{
    ToolTip ; Hide tooltip [if it was showed by BlueprintDescription()]
    MouseGetPos, xBtn, yBtn
}

;-------------------------------------------------------------
;----------------------- GENERAL CODE ------------------------
;-------------------------------------------------------------

ImageSearch(ByRef x, ByRef y, imageFile, wndSize)
{
    ImageSearch, x, y, 0, 0, % wndSize.w, % wndSize.h, % imageFile
    if (ErrorLevel) {
        ToolTip, % A_ThisFunc . "() - can't find image: " . imageFile, 0, 0
        SoundBeep
    }
}

Click(x := "", y := "", whichButton := "", delay := -1)
{
    if ((x and !y) or (!x and y)) {
        ToolTip, % A_ThisFunc "(X, Y) - undefined X or Y parameter", 0, 0
        return
    }
    if (bSendInput)
        SendInput, {Click %x% %y% %whichButton%}
    else
        SendEvent, {Click %x% %y% %whichButton%}
    if (delay != -1)
        Sleep, %delay%
}

Send(key, delay := -1)
{
    if (bSendInput)
        SendInput, {%key%}
    else
        SendEvent, {%key%}
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

WinGetClientPos(hWnd)
{
    VarSetCapacity(RECT, 16, 0)
    DllCall("user32\GetClientRect", Ptr,hWnd, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&RECT)
    Win_Client_X := NumGet(&RECT, 0, "Int")
    Win_Client_Y := NumGet(&RECT, 4, "Int")
    Win_Client_W := NumGet(&RECT, 8, "Int")
    Win_Client_H := NumGet(&RECT, 12, "Int")
    Return { x: Win_Client_X, y: Win_Client_Y, w: Win_Client_W, h: Win_Client_H }
}

WinGetClientSize()
{
    hWnd := WinExist("ahk_group Game")
    oClientPos := WinGetClientPos(hWnd)
    Return { w: oClientPos.w, h: oClientPos.h }
}

ShowHelpWindow(ByRef str := "")
{
    static bToggle
    iCharWidth := 9 ;ширина символа по умолчанию
    iPadding := 10 ;отступ текста от края окна, которое делает AutoHotkey

    if (bToggle := !bToggle) {
        Loop, Parse, str, `n, `r
            if (width < StrLen(A_LoopField))
                width := StrLen(A_LoopField)
        width := width * iCharWidth + 2 * iPadding
        Progress, zh0 b2 c0 w%width%, %str%, , , Consolas
    }
    else
        Progress, Off
}
