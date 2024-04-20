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
      B -> Quick UPGRADE any VEHICLE
Alt + Z -> Reload Script
      X -> Exit Script

Usage:
    - open VEHICLES MANAGEMENT window
    - point mouse cursor on VEHICLE icon
    - press hotkey (default [B]) to upgrade vehicle
    - wait until VEHICLES MANAGEMENT window opens again
    - press hotkey (default [B]) to upgrade next vehicle, repeat

Tip:
    - make the camera view from above (top view) so there is less miss-clicks
      at the vehicles. When the camera is looking at an angle, the car may be
      hidden behind a building.
    - tooltip will appear in top left corner on error (if can't find image on
      screen). Reload script to remove it or upgrade another VEHICLE.

Pitfall:
    - UPGRADE icon in VEHICLE window changes it's colors and shape when VEHICLE
      assigned to building! SIC! It's difficult to make picture that match all
      icon's variants.

Set proper User Interface Scale ratio to [uiScale] variable, default 100%.
If the script blocks input, press Ctrl+Alt+Del to restore it.
)"

;@AHK++AlignAssignmentOn
global bSendInput := true
global uiScale    := 100 ; <==== Set game's User Interface Scale factor [80 or 100].
global oClientPos := {} ; Game's window client position
;@AHK++AlignAssignmentOff

GroupAdd, Game, ahk_exe Captain of Industry.exe

#IfWinActive ahk_group Game
    B:: UpgradeVehicle(250, 500) ; <==== Set hotkey, by default it's [B].
#If
F1:: ShowHelpWindow(helpText)
!Z:: Reload
!X:: ExitApp

UpgradeVehicle(delay, waitCameraMovement)
{
    ToolTip ; Hide the tooltip if it was shown when an error occurred

    WinGet, winId, ID, ahk_group Game
    oClientPos := WinGetClientPos(winId)

    Critical, On
    BlockInput, On
    ; Save position of VEHICLE icon in VEHICLES MANAGEMENT window
    MouseGetPos, _x, _y
    ; Click VEHICLE icon in VEHICLES MANAGEMENT window and wait for camera movement
    Click(_x, _y, , delay)
    Send("Esc") ; Close VEHICLES MANAGEMENT window
    Sleep, % waitCameraMovement
    ; Click on VEHICLE in the center of screen: opens VEHICLE window
    Click(oClientPos.w / 2, oClientPos.h / 2, , delay)
    ; Click UPGRADE icon in VEHICLE window
    ; Using black color in images like alpha channel.
    ClickImage("*2 *TransBlack CaptainOfIndustryUpgradeIcon", uiScale, delay / 2)
    ; Open VEHICLES MANAGEMENT window: returns to start position
    ClickImage("*2 *TransBlack CaptainOfIndustryVehiclesManagementIcon", uiScale, delay)
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

WinGetClientPos(WinId)
{
    VarSetCapacity(RECT, 16, 0)
    DllCall("user32\GetClientRect", Ptr,WinId, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,WinId, Ptr,&RECT)
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
