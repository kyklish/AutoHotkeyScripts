; Captain of Industry Helper
; Supported User Interface Scale 80 or 100% [uiScale] variable

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
      B -> Quick UPGRADE any VEHICLE.
Alt + Z -> Reload Script.
      X -> Exit Script.

Usage:
    - open VEHICLES MANAGEMENT window.
    - point mouse cursor on VEHICLE icon.
    - press hotkey (default [B]) to upgrade vehicle.
    - wait until VEHICLES MANAGEMENT window opens again.
    - press hotkey (default [B]) to upgrade next vehicle, repeat.

Tips:
    - make the camera view from above (top view) so there is less miss-clicks
      at the vehicles. When the camera is looking at an angle, the car may be
      hidden behind a building.
    - script did not find icons in game and show tooltips with errors: try
      increase delay between manipulations [dlOperation] and [dlCameraMove].
    - reload the script to remove error's tooltip or upgrade another VEHICLE.

Pitfalls:
    - UPGRADE icon in VEHICLE window changes it's colors and shape when VEHICLE
      assigned to building! SIC! It's difficult to make picture that match all
      icon's variants.
    - UI scale changes icon's size. For different scale you must create another
      pictures.

Set proper User Interface Scale ratio to [uiScale] variable, default 100%.
BlockInput (to prevent mouse move interfere with user input) needs admin rights!
If the script blocks input by mistake, press [Ctrl + Alt + Del] to unblock.
You can run script without admin rights, but then don't move mouse, while script
moves it.
)"

;@AHK++AlignAssignmentOn
global bSendInput := true
global oClientPos := {}  ; Game's window client position
global uiScale    := 80  ; User Interface Scale [80 or 100]
dlOperation       := 300 ; Delay between operations: open window, click, etc
dlCameraMove      := 500 ; Delay to wait camera movement to VEHICLE
;@AHK++AlignAssignmentOff

if (!IsDebugScript()) ; On Debug reload script will break debugging
    Reload_AsAdmin() ; For BlockInput we need admin rights

GroupAdd, Game, ahk_exe Captain of Industry.exe

#IfWinActive ahk_group Game
    B:: UpgradeVehicle(dlOperation, dlCameraMove) ; <==== Main hotkey [B].
#If
F1:: ShowHelpWindow(helpText)
!Z:: Reload
!X:: ExitApp

UpgradeVehicle(dlOperation, dlCameraMove)
{
    ToolTip ; Hide the tooltip if it was shown when an error occurred

    hWnd := WinExist("ahk_group Game")
    oClientPos := WinGetClientPos(hWnd)

    Critical, On
    BlockInput, On
    ; Save position of VEHICLE icon in VEHICLES MANAGEMENT window
    MouseGetPos, _x, _y
    ; Click VEHICLE icon in VEHICLES MANAGEMENT window and wait for camera movement
    Click(_x, _y, , dlOperation)
    Send("Esc") ; Close VEHICLES MANAGEMENT window
    Sleep, % dlCameraMove
    ; Click on VEHICLE in the center of the screen: opens VEHICLE window
    Click(oClientPos.w / 2, oClientPos.h / 2, , dlOperation)
    ; Click UPGRADE icon in VEHICLE window
    ; Using black color in images like alpha channel.
    ClickImage("*2 *TransBlack CaptainOfIndustryUpgradeIcon", uiScale, dlOperation / 2)
    ; Open VEHICLES MANAGEMENT window: returns to start position
    ClickImage("*2 *TransBlack CaptainOfIndustryVehiclesManagementIcon", uiScale, dlOperation)
    ; Restore position on VEHICLE icon in VEHICLES MANAGEMENT window
    MouseMove, % _x, % _y

    BlockInput, Off
    Critical, Off
}

ClickImage(imageFile, uiScale, delay)
{
    imageFile := imageFile . uiScale . ".png"
    ImageSearch, x, y, 0, 0, % oClientPos.w, % oClientPos.h, % imageFile
    if (ErrorLevel) {
        ToolTip, % A_ThisFunc . "() - can't find image: " . imageFile, 0, 0
        Return false
    }
    Click(x + 5, y + 5, , delay) ; Click on center of image (picture 10x10)
    Return true
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
