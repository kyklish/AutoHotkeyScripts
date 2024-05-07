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
; v2.9.0
;  + New hotkeys to cycle left/right on on/auto/off import/export buttons in buildings
; v2.8.0
;  + New hotkey to quick delete storage with product under cursor
; v2.7.0
;  - Delete/upgrade/navigate vehicle on mine control tower (not working) because
;    building always points out to first vehicle, not cycle them like vehicle
;    management window!
; v2.6.2
;  + New hotkey to send vehicle near mine control tower
;  ! Statistics window was not open when recipes window was scrolled down
;  ! Wrong hotkey in help text
;  ! Not reliable click on vehicle order icon
; v2.6.1
;  ! Fix typo in help message
; v2.6.0
;  + New hotkey to show vehicles management window
;  + New hotkey to show statistics
;  + New hotkey to delete/upgrade vehicle on mine control tower
; v2.5.2
;  * Smaller location icons
;  ! Fix green location not explored
; v2.5.1
;  ! Copy blueprint description
;  ! Stop on defeat battle result
; v2.5.0
;  + Explore unknown location with green icon
; v2.4.0
;  + Close battle result on victory before exploration
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
SetMouseDelay, 25
SetKeyDelay, -1, 25

helpText := "
(
Set USER INTERFACE SCALE ratio to [uiScale] variable in the script (default 100%)!

          F1 -> Show help (when game not on screen).
   Ctrl + F1 -> Show help (in-game).
          F7 -> WORLD MAP: quick EXPLORE unknown location (first GREY then GREEN).
          F8 -> WORLD MAP: quick EXPLORE location with enemy.
          F9 -> VEHICLE:   quick DELETE.
         F10 -> VEHICLE:   quick UPGRADE.
     Alt + C -> BLUEPRINT:  copy description text.
     Alt + V -> BLUEPRINT: paste description text and save it.
     Alt + B -> BLUEPRINT: paste description text.
         F12 -> BLUEPRINT: save position of DESCRIPTION BUTTON.
   Space + Q -> Show VEHICLES MANAGEMENT window.
   Space + W -> Show RECIPES window.
   Space + E -> Show STATISTICS window for product under cursor.
 Shift + Del -> STORAGE: quick delete product using Unity.
   Shift + - -> BUILDING: cycle left  ON/AUTO/OFF buttons (IMPORT/EXPORT).
   Shift + = -> BUILDING: cycle right ON/AUTO/OFF buttons (IMPORT/EXPORT).
Ctrl + Enter -> Unblock mouse input (if it was blocked by mistake).
     Alt + S -> Suspend Script (disable all hotkeys).
     Alt + Z ->  Reload Script.
     Alt + X ->    Exit Script.

Useful tips:
    - maximum zoom in for better performance when using VEHICLES DELETE/UPGRADE.
    - tilt camera to top view (the script assumes that vehicle/building will be
      placed in the center of the screen when camera moves to it) to prevent
      miss-clicks at the vehicle/building. When the camera is looking at an
      angle, vehicle may be hidden behind a building or have an offset in up
      direction on big camera angles.
    - increase delay between manipulations [dlOperation] and [dlCameraMove] for
      better reliability.
    - reload the script to remove tooltip with error.

Usage VEHICLE DELETE/UPGRADE:
    - set game on pause
    - open VEHICLES MANAGEMENT window.
    - point mouse cursor on VEHICLE icon.
    - press hotkey to upgrade/delete vehicle.
    - wait until VEHICLES MANAGEMENT window opens again.
    - press hotkey to upgrade/delete next vehicle, repeat.

Usage WORLD MAP EXPLORE/BATTLE:
    - WORLD MAP must be closed.
    - press hotkey to explore/battle (automatically close victory result before
      explore/battle).

Usage BLUEPRINT COPY/PASTE:
    - put mouse cursor on DESCRIPTION BUTTON and press hotkey to save it's
      position (it has different position for FILE and FOLDER!).
    - put mouse cursor over desired blueprint and press desired hotkey.

Usage STORAGE WITH PRODUCT DELETE:
    - using DEMOLISH tool mark storages to delete (activates QUICK REMOVE button).
    - point mouse cursor on storage building.
    - press hotkey to quickly remove product with UNITY.

Usage BUILDING ON/OFF IMPORT/EXPORT:
    - point mouse cursor on building.
    - press hotkey to quickly cycle between ON/AUTO/OFF buttons.
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
    , xDelete:    39 * uiScale // 100
    , xRecover:   89 * uiScale // 100
    , xNavigate: 139 * uiScale // 100
    , xUpgrade:  189 * uiScale // 100 }
; VEHICLE WINDOW ORDERS ICONS ROW (39x39): relative to bottom left corner of VEHICLE WINDOW
global oOIR := { 0:0
    , y: 114 * uiScale // 100 }
; EXPLORE/BATTLE BUTTON: relative to bottom left corner of UNKNOWN LOCATION WINDOW and BATTLE WINDOW
global oEBB  := { 0:0
    , x: 123 * uiScale // 100
    , y:  26 * uiScale // 100 }
; BACK BUTTON: relative to top left corner of GREEN or RED line in BATTLE RESULT WINDOW
global oBB  := { 0:0
    , x: 200 * uiScale // 100
    , y: 160 * uiScale // 100 }

GroupAdd, Game, ahk_exe Captain of Industry.exe

#IfWinActive, ahk_group Game ; <==== Main hotkeys.
    $Space:: Send("Space") ; Unblock modifier [Space] key
    Space & Q:: MakeManipulation(Func("VehicleManagement").Bind(dlOperation)) ; Show VEHICLES MANAGEMENT window
    Space & W:: Send("o") ; Open RECIPES window
    Space & E:: MakeManipulation(Func("Statistics").Bind(dlOperation)) ; Show STATISTICS window
    F7::        MakeManipulation(Func("ExploreLocation").Bind("Unknown", dlOperation))
    F8::        MakeManipulation(Func("ExploreLocation").Bind("Enemy", dlOperation))
    F9::        MakeManipulation(Func("VehicleOrder").Bind( "Delete", dlOperation, dlCameraMove))
    F10::       MakeManipulation(Func("VehicleOrder").Bind("Upgrade", dlOperation, dlCameraMove))
    !C::        MakeManipulation(Func("BlueprintDescription").Bind("Copy", xBtn, yBtn, dlOperation))
    !V::        MakeManipulation(Func("BlueprintDescription").Bind("PasteSave", xBtn, yBtn, dlOperation))
    !B::        MakeManipulation(Func("BlueprintDescription").Bind("Paste", xBtn, yBtn, dlOperation))
    +Del::      MakeManipulation(Func("StorageWithProductDelete").Bind(dlOperation))
    +-::        MakeManipulation(Func("BuildingCycleOnAutoOffBtn").Bind("Left", dlOperation))
    ++::        MakeManipulation(Func("BuildingCycleOnAutoOffBtn").Bind("Right", dlOperation))
    F12::       DscrBtnSavePos(xBtn, yBtn) ; Save position of DESCRIPTION BUTTON in BLUEPRINTS window
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

Statistics(dlOperation, clSz)
{
    Click( , , "Right", dlOperation) ; Click on product under cursor to show RECIPES
    ; Search top left corner of the STATISTICS button (disable error, because
    ; button may be not visible)
    ImageSearch(x, y, "CaptainOfIndustryButtonBlack.png", clSz, false)
    if (ErrorLevel) {
        ; RECIPES window lags or was scrolled down before, STATISTICS icon not
        ; visible.
        ; Mouse [WheelUp] command will be received by window under cursor, so
        ; move cursor to the center of the screen with delay.
        ; Delay will handle the case of a lagged window.
        MouseMove(clSz.w / 2, clSz.h / 2, dlOperation)
        Send("Click WheelUp 50", dlOperation) ; Minimum 30 notches to scroll RECIPES window
        ; Search top left corner of the STATISTICS button
        ImageSearch(x, y, "CaptainOfIndustryButtonBlack.png", clSz)
        if (ErrorLevel)
            Return
    }
    ; Click on STATISTICS button
    Click(x + 10, y + 10, , dlOperation) ; Add offset equal to image size (10x10)
}

VehicleManagement(dlOperation, clSz)
{
    ; Delay important here! Game read cursor position with delay. If it moves
    ; instantly, game accept click and after delay read position which will be
    ; restored instantly.
    Click(oVMI.x, oVMI.y, , dlOperation) ; Show VEHICLES MANAGEMENT window
}

VehicleOrder(order, dlOperation, dlCameraMove, clSz)
{
    ; Click VEHICLE icon under cursor in VEHICLES MANAGEMENT window or
    ; MINE CONTROL TOWER window
    Click( , , , dlOperation)
    ; Close VEHICLES MANAGEMENT window or MINE CONTROL TOWER window and wait for
    ; camera movement
    Send("Esc", dlCameraMove)
    ; Click on VEHICLE in the center of the screen: opens VEHICLE window
    Click(clSz.w / 2, clSz.h / 2, , dlOperation)
    ; Find bottom left corner of VEHICLE window
    ; 2 shades of variation. Using black color in images like alpha channel.
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryLineBottom.png", clSz)
    if (ErrorLevel)
        Return
    Switch order {
    Case "Upgrade":
        ; Click UPGRADE icon in VEHICLE window
        Click(x + oOIC.xUpgrade, y - oOIR.y, , dlOperation)
    Case "Recover":
        ; Click RECOVER icon in VEHICLE window
        Click(x + oOIC.xRecover, y - oOIR.y, , dlOperation)
    Case "Navigate":
        ; Click NAVIGATE icon in VEHICLE window
        Click(x + oOIC.xNavigate, y - oOIR.y, , dlOperation)
    Case "Delete":
        ; Click DELETE icon in VEHICLE window
        Click(x + oOIC.xDelete, y - oOIR.y, , dlOperation)
    Default:
        MsgBox % A_ThisFunc "() - No such order for vehicle: " order
    }
    ; Open VEHICLES MANAGEMENT window: returns to start position
    Click(oVMI.x, oVMI.y, , dlOperation)
}

BattleCloseVictoryResult(dlOperation, clSz)
{
    ImageSearch(x, y, "CaptainOfIndustryBattleDefeat.png", clSz, false)
    if (!ErrorLevel) ; Defeat result was found
        Return true
    ImageSearch(x, y, "CaptainOfIndustryBattleVictory.png", clSz, false)
    if (!ErrorLevel) ; Victory result was found
        Click(x + oBB.x, y + oBB.y, , dlOperation) ; Click BACK button
}

ExploreLocation(operation, dlOperation, clSz)
{
    Send("Tab", dlOperation) ; Open WORLD MAP
    bDefeat := BattleCloseVictoryResult(dlOperation, clSz)
    if (bDefeat)
        ; Exit immediately and do nothing.
        ; User must see defeat result or he/she will endlessly send ship into
        ; battle without knowing, that his/her ship can't win.
        Return
    Send("Click WheelDown 15", dlOperation) ; Minimum 10 notches to zoom out WORLD MAP
    ; Find and click on LOCATION ICON
    Switch operation {
    Case "Enemy":
        ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryLocationWithEnemyIcon.png", clSz)
    Case "Unknown":
        ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryLocationUnknownIconGrey.png", clSz, false)
        if (ErrorLevel) ; There are no grey unknown locations, search green
            ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryLocationUnknownIconGreen.png", clSz)
    Default:
        ToolTip, % A_ThisFunc "() - No such operation: " operation
    }
    if (ErrorLevel)
        Return
    Click(x, y, , dlOperation)
    ; Find bottom left corner of LOCATION window
    ImageSearch(x, y, "*2 *TransBlack CaptainOfIndustryLineBottom.png", clSz)
    if (ErrorLevel)
        Return
    Click(x + oEBB.x, y - oEBB.y, , dlOperation) ; Click EXPLORE/BATTLE button
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
    ; Move mouse to DESCRIPTION button and wait. Why? Because if description
    ; tooltip from BLUEPRINT covers DESCRIPTION button [Click()] function moves
    ; cursor instantly and clicks on tooltip instead of button! So MOVE, WAIT
    ; tooltip from description to disappear, CLICK on button. This scenario is
    ; for COPY operation.
    MouseMove(xBtn, yBtn, dlOperation) ; Move to DESCRIPTION button
    Click( , , , dlOperation) ; Click DESCRIPTION button
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
        ; Search top left corner of APPLY CHANGES button
        ImageSearch(x, y, "CaptainOfIndustryButtonYellow.png", clSz)
        if (ErrorLevel)
            Return
        ; Click APPLY CHANGES button
        Click(x + 10, y + 10, , dlOperation) ; Add offset equal to image size (10x10)
    Default:
        ToolTip, % A_ThisFunc "() - No such operation: " operation
    }
}

DscrBtnSavePos(ByRef xBtn, ByRef yBtn)
{
    ToolTip ; Hide tooltip [if it was showed by BlueprintDescription()]
    MouseGetPos, xBtn, yBtn
}

StorageWithProductDelete(dlOperation, clSz)
{
    ; When you try delete storage with product it will not deconstruct, but
    ; instead it queue deconstruction and remove assigned product (which enable
    ; QUICK REMOVE button) additionally set KEEP EMPTY status.
    Click( , , , dlOperation) ; Click building under cursor to open it's window
    ; Search top left corner of the first black button (it will be QUICK REMOVE with Unity)
    ImageSearch(x, y, "CaptainOfIndustryButtonBlack.png", clSz)
    if (ErrorLevel)
        Return
    ; Click on QUICK REMOVE button
    Click(x + 10, y + 10, , dlOperation) ; Add offset equal to image size (10x10)
    Send("Esc") ; Close window
}

BuildingCycleOnAutoOffBtn(direction, dlOperation, clSz, bRecursiveCall := false)
{
    ; There are two ON/OFF buttons combinations: one for IMPORT and second for
    ; EXPORT. Use recursive call to search second one and exit if it was not found.
    ; Do not click on recursive call, it useless and adds delay.
    if (!bRecursiveCall)
        Click( , , , dlOperation) ; Click building under cursor to open it's window
    Switch direction {
    Case "Left":
        ; Around buttons ON/AUTO/OFF may be black line, but on scaling UI to 80%
        ; it may disappear, so use black color as alpha channel.
        ; Search grey/red combination of the ON/OFF BUTTONS (storage)
        ImageSearch(x, y, "*TransBlack CaptainOfIndustryButtonOnOffRed.png", clSz, false)
        if (ErrorLevel) {
            ; Search combination of the ON/AUTO BUTTONS (building)
            ImageSearch(x, y, "*TransBlack CaptainOfIndustryButtonOnOffAutoL.png", clSz, false)
            if (ErrorLevel)
                Return
        }
        ; Click on ON or AUTO BUTTON to cycle left
        ; Left side of picture, so don't need offset for X
        Click(x, y + 4, , dlOperation) ; Add offset equal to image height (4)
        if (!bRecursiveCall)
            BuildingCycleOnAutoOffBtn(direction, dlOperation, clSz, true)
    Case "Right":
        ; Search green/grey combination of the ON/OFF BUTTONS (storage)
        ImageSearch(x, y, "*TransBlack CaptainOfIndustryButtonOnOffGreen.png", clSz, false)
        if (ErrorLevel) {
            ; Search combination of the AUTO/OFF BUTTONS (building)
            ImageSearch(x, y, "*TransBlack CaptainOfIndustryButtonOnOffAutoR.png", clSz, false)
            if (ErrorLevel)
                Return
        }
        ; Click on AUTO or OFF BUTTON to cycle right
        ; Right side of picture, add offset to X and Y
        Click(x + 9, y + 4, , dlOperation) ; Add offset equal to image size (9x4)
        if (!bRecursiveCall)
            BuildingCycleOnAutoOffBtn(direction, dlOperation, clSz, true)
    Default:
        ToolTip, % A_ThisFunc "() - No such operation: " operation
    }
    Send("Esc") ; Close window
}

;-------------------------------------------------------------
;----------------------- GENERAL CODE ------------------------
;-------------------------------------------------------------

ImageSearch(ByRef x, ByRef y, imageFile, wndSize, bShowError := true)
{
    ImageSearch, x, y, 0, 0, % wndSize.w, % wndSize.h, % imageFile
    if (ErrorLevel && bShowError) {
        ToolTip, % A_ThisFunc . "() - can't find image: " . imageFile, 0, 0
        SoundBeep
    }
}

Click(x := "", y := "", whichButton := "", delay := -1)
{
    if ((x and !y) or (!x and y)) {
        ToolTip, % A_ThisFunc "(X, Y) - undefined X or Y parameter", 0, 0
        Return
    }
    if (bSendInput)
        SendInput, {Click %x% %y% %whichButton%}
    else
        SendEvent, {Click %x% %y% %whichButton%}
    if (delay != -1)
        Sleep, %delay%
}

MouseMove(x := "", y := "", delay := -1)
{
    if (!x or !y) {
        ToolTip, % A_ThisFunc "(X, Y) - undefined X or Y parameter", 0, 0
        Return
    }
    MouseMove, %x%, %y%
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
    ; iCharWidth := 9 ; char width by default
    iCharWidth := 7 ; char width [fs10]
    iPadding := 10 ; text margin from the edge of the window

    if (bToggle := !bToggle) {
        Loop, Parse, str, `n, `r
            if (width < StrLen(A_LoopField))
                width := StrLen(A_LoopField)
        width := width * iCharWidth + 2 * iPadding
        Progress, fs10 zh0 b2 c0 w%width%, %str%, , , Consolas
    }
    else
        Progress, Off
}
