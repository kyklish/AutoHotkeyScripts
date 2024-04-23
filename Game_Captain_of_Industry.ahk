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
      , -> Quick DELETE any VEHICLE.
      . -> Quick UPGRADE any VEHICLE.
      Q -> Quick EXPLORE on WORLD MAP.
Alt + C -> Suspend Script.
Alt + Z -> Reload Script.
      X -> Exit Script.

Usage (DELETE/UPGRADE VEHICLE):
    - open VEHICLES MANAGEMENT window.
    - point mouse cursor on VEHICLE icon.
    - press hotkey to upgrade vehicle.
    - wait until VEHICLES MANAGEMENT window opens again.
    - press hotkey to upgrade next vehicle, repeat.

Usage (EXPLORE):
    - WORLD MAP must be closed
    - press hotkey

Tips:
    - make the camera view from above (top view) so there is less miss-clicks
      at the vehicles. When the camera is looking at an angle, the car may be
      hidden behind a building.
    - increase delay between manipulations [dlOperation] and [dlCameraMove] for
      better reliability.
    - reload the script to remove tooltip with error.

Pitfalls:
    - UPGRADE icon in VEHICLE window changes it's colors and shape when VEHICLE
      assigned to building. It's difficult to make picture that match all icon's
      variants.

Set proper User Interface Scale ratio to [uiScale] variable, default 100%.
BlockInput (to prevent mouse move interfere with user input) needs admin rights.
If the script blocks input by mistake, press [Ctrl + Alt + Del] to unblock.
You can run script without admin rights, but then don't move mouse, while script
moves it.
)"

;@AHK++AlignAssignmentOn
global bSendInput := true
uiScale           := 80 ; User Interface Scale [tested 80%, 100%, 120%]
dlOperation       := 300 ; Delay between operations: open window, click, etc
dlCameraMove      := 500 ; Delay to wait camera movement to VEHICLE
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

if (!IsDebugScript()) ; On Debug reload script will break debugging
    Reload_AsAdmin() ; For BlockInput we need admin rights

GroupAdd, Game, ahk_exe Captain of Industry.exe

#IfWinActive ahk_group Game ; <==== Main hotkeys.
    ,:: MakeManipulation(Func("ClickVehicleOrderIcon").Bind( "Delete", dlOperation, dlCameraMove))
    .:: MakeManipulation(Func("ClickVehicleOrderIcon").Bind("Upgrade", dlOperation, dlCameraMove))
    /:: MakeManipulation(Func("ExploreUnknownLocation").Bind(dlOperation))
    `;:: MouseGetPos, xBtn, yBtn ; Save position of DESCRIPTION BUTTON in BLUEPRINTS window
    ':: MakeManipulation(Func("BlueprintDescription").Bind("Copy", xBtn, yBtn, dlOperation))
    \:: MakeManipulation(Func("BlueprintDescription").Bind("PasteSave", xBtn, yBtn, dlOperation))
    +\:: MakeManipulation(Func("BlueprintDescription").Bind("PasteEdit", xBtn, yBtn, dlOperation))
#If
F1:: ShowHelpWindow(helpText)
!C:: Suspend
!Z:: Reload
!X:: ExitApp

;-------------------------------------------------------------
;------------------------- GAME CODE -------------------------
;-------------------------------------------------------------

MakeManipulation(oBoundFunc)
{
    clSz := WinGetClientSize()

    Critical, On
    KeyWait, %A_ThisHotkey%
    BlockInput, On
    MouseGetPos, _x, _y

    %oBoundFunc%(clSz)
    ; oBoundFunc.Call(clSZ)

    MouseMove, % _x, % _y
    BlockInput, Off
    Critical, Off
}

ClickVehicleOrderIcon(order, dlOperation, dlCameraMove, clSz)
{
    ; Click VEHICLE icon in VEHICLES MANAGEMENT window and wait for camera movement
    Click(_x, _y, , dlOperation)
    Send("Esc", dlCameraMove) ; Close VEHICLES MANAGEMENT window
    ; Click on VEHICLE in the center of the screen: opens VEHICLE window
    Click(clSz.w / 2, clSz.h / 2, , dlOperation)
    ; Find bottom left corner of VEHICLE window
    ; 2 shades of variation. Using black color in images like alpha channel.
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryBottomLine.png", clSz)
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

ExploreUnknownLocation(dlOperation, clSz)
{
    Send("Tab", dlOperation) ; Open WORLD MAP and zoom out
    Send("Click WheelDown 15", dlOperation) ; Minimum 10 notches to zoom out WORLD MAP
    ; Find and click on UNKNOWN LOCATION ICON
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryUnknownLocationIcon.png", clSz)
    Click(x, y, , dlOperation)
    ; Find bottom left corner of UNKNOWN LOCATION window
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryBottomLine.png", clSz)
    Click(x + oULI.x, y - oULI.y, , dlOperation) ; Click EXPLORE button
    Send("Esc", dlOperation) ; Close UNKNOWN LOCATION window
    Send("Tab") ; Close WORLD MAP
}

BlueprintDescription(operation, xBtn, yBtn, dlOperation, clSz)
{
    if (!xBtn or !yBtn) {
        MsgBox % "Unknown position of the DESCRIPTION BUTTON in BLUEPRINTS window.`n`nLook help [F1]."
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
    Case "PasteEdit": ; Do not close window, user will edit text
        SendRaw("^v") ; Paste
    Case "PasteSave":
        SendRaw("^v", dlOperation) ; Paste
        ; Find top left corner of APPLY CHANGES button
        ImageSearch(x, y, "CaptainOfIndustryApplyButton.png", clSz)
        ; Click APPLY CHANGES button
        Click(x + 10, y + 10, , dlOperation) ; Add offset of image size (10x10)
    Default:
        MsgBox % A_ThisFunc "() - No such operation for blueprint: " operation
    }
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

IsDebugScript()
{
    FullCmdLine := DllCall("GetCommandLine", "Str")
    if(RegExMatch(FullCmdLine, "i)/debug"))
        Return true
    else
        Return false
}
