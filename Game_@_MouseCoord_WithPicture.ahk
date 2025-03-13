#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

if (!IsDebugScript()) ; on Debug reload script will break debugging
    Reload_AsAdmin()

;@AHK++AlignAssignmentOn
; Configure FastStone Capture make ScreenShots by PrintScreen key,
; and save BMP files to R:\ with file name prefix "FastStoneCapture".
imageMagick        := "E:\GAMES\ImageMagick\magick.exe"
scrDir             := "R:" ; directory with ScreenShots from FastStone Capture
scrExt             := "bmp" ; ScreenShot file extension
fileNamePrefix     := "FastStoneCapture" ; file name prefix of ScreenShot file, it used to identify newly created picture
logFile            := scrDir "\MouseCoord.txt" ; log file with info about mouse click and screenshot
picSizeImageMagick := 40
LButton_Held       := false
;@AHK++AlignAssignmentOff
mX := mY := mColor := 0

Insert:: ExitApp
!Insert:: Reload

;Left:: MouseMove, -1,  0, , R
;Right::MouseMove,  1,  0, , R
;Up::   MouseMove,  0, -1, , R
;Down:: MouseMove,  0,  1, , R

Numpad4::MouseMove, -1,  0, , R
Numpad6::MouseMove,  1,  0, , R
Numpad8::MouseMove,  0, -1, , R
Numpad2::MouseMove,  0,  1, , R
Numpad7::MouseMove, -1, -1, , R
Numpad9::MouseMove,  1, -1, , R
Numpad1::MouseMove, -1,  1, , R
Numpad3::MouseMove,  1,  1, , R

; Numpad0::
+LButton:: StartDrawRect()
; Numpad0 Up::
+LButton Up:: StopDrawRect()

ScrollLock:: ToggleTooltip()

Numpad5:: FindClick(">" GetProcessName())
^Numpad5:: FastStoneCaptureScreenShot()

; Make ScreenShot, Crop by ImageMagick, Save with X_Y in file name
FastStoneCaptureScreenShot()
{
    global imageMagick
    global scrDir
    global scrExt
    global fileNamePrefix
    global logFile
    global picSizeImageMagick
    global mX, mY, mColor

    GetData(false)

    if FileExist(imageMagick) {
        ; picture parameters and parameters for ImageMagick
        pW := picSizeImageMagick ; width of crop zone
        pH := pW ; height -//-
        pX := mX - pW // 2 ; integer division (//) -> produce integer result
        pY := mY - pH // 2 ; XY -> upper left corner of crop zone

        fileName := scrDir . "\" . fileNamePrefix . "*." . scrExt
        FileDelete, %fileName%
        processName := GetProcessName()
        Send, {PrintScreen} ; configure FastStone Capture make ScreenShots by PrintScreen key, and save BMP files to R:\
        Loop, 10 ; wait 10*100ms for file with ScreenShot
        {
            Sleep, 100
            if FileExist(fileName) {
                Loop, Files, %fileName%
                {
                    name := SubStr(A_LoopFileName, 1, -4) ; remove extension
                    name := StrReplace(name, "FastStoneCapture-") ; cleanup
                    ; important to use different image type, than source
                    ext := ".png"
                    newFileName := scrDir . "\" . processName . "-" . name . " " . mX . "_" . mY . ext
                    ; crop picture, while loading, convert and save with new name
                    command = %A_ComSpec% /c %imageMagick% "%A_LoopFileLongPath%[%pW%x%pH%+%pX%+%pY%]" "%newFileName%"
                    ToolTip % command . "`n" . processName, 0, 0
                    RunWait, %command%,, Hide
                    FileDelete, %A_LoopFileLongPath%
                }
                break
            }
        }
    }

    FileAppend, % mX . ", " . mY . ", " . mColor . "`n", %logFile%
    Clipboard := mX . ", " . mY . ", " . mColor
}

GetData(bShowTooltip := true)
{
    global mX, mY, mColor
    MouseGetPos, mX, mY
    PixelGetColor, mColor, %mX%, %mY%, RGB
    if (bShowTooltip)
        ToolTip % "X:" mX ", Y:" mY ", RGB:" mColor
}

GetProcessName()
{
    WinGet, processName, ProcessName, A
    return SubStr(processName, 1, -4) ; delete ".exe"
}

StartDrawRect()
{
    global LButton_Held
    id := "MouseCoord"
    if (!LButton_Held)
    {
        LButton_Held := true
        MouseGetPos, X1CL, Y1CL
        JEE_ClientToScreen(WinExist("A"), X1CL, Y1CL, X1SC, Y1SC)
        Loop {
            MouseGetPos, X2CL, Y2CL
            JEE_ClientToScreen(WinExist("A"), X2CL, Y2CL, X2SC, Y2SC)
            DrawRectangle(X1SC, Y1SC, X2SC, Y2SC, id)
            ; ToolTip, % "X1:" X1CL " Y1:" Y1CL " X2:" X2CL " Y2:" Y2CL
            ToolTip, % "X1:" X1CL " Y1:" Y1CL " X2:" X2CL " Y2:" Y2CL " W: " X2CL - X1CL " H: " Y2CL - Y1CL
            if (LButton_Held == false)
                break
        }
        DestroyRectangle(id)
        ToolTip
        FileAppend, % X1CL ", " Y1CL ", " X2CL ", " Y2CL . "`n", %logFile%
        Clipboard := X1CL ", " Y1CL ", " X2CL ", " Y2CL
    }
}

StopDrawRect()
{
    global LButton_Held := false
}

ToggleTooltip()
{
    static bToggle := False
    if (bToggle := !bToggle) {
        SetTimer, GetData, 100
    } else {
        SetTimer, GetData, Off
        ToolTip
    }
}

F1:: ShowHelpWindow("
(
Launch 'FastStone Capture' to save pictures
 Scroll Lock     -> Toggle show tooltip with info
 Numpad 2 4 6 8  -> Move cursor by one pixel orthogonally
 Numpad 1 3 7 9  -> Move cursor by one pixel diagonally
 Numpad 5        -> 'FindClick()' save pic for ImageSearch
^Numpad 5        -> 'FastStone Capture' save coord, color, pic
 Numpad 0 + Drag -> Draw rectangle, save to clipboard 'X1, Y1, X2, Y2' (Disabled)
     +LMB + Drag -> Draw rectangle, save to clipboard 'X1, Y1, X2, Y2'
!Insert          -> Reload Script
 Insert          ->   Exit Script

BUTTONS THAT LOOKS DIFFERENT WHEN THE MOUSE HOVERS
To work around this issue you need to check the box that says “Allow Offset” in
  the screenshot creator GUI. When you use this setting, the magnification box
  will move relative to where it was left when the script was last paused. This
  means you can pause the script, move the mouse, and then unpause the script so
  that the magnification area will not be right underneath the mouse, and you will
  be able to magnify the button as it looks without the mouse hovering over it.
)")
