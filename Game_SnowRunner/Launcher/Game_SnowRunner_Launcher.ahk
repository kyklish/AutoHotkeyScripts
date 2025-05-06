; Faster load to Main Menu and Continue play.
; On epilepsy warning loose and then gain focus of the game's window.
; Then press [Esc] key to skip Sabre/Havok logos.
; Then press [Enter] twice to enter Main Menu and select Continue.

#Warn
#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

Menu, Tray, Icon, Icon.ico, 1, 1
Menu, Tray, Tip, SnowRunner Launcher

GroupAdd, SpinTires, ahk_exe SnowRunner.exe

iPicSz := 40 ; Size of the "BlackSquare.png" in pixels

bLaunchScripts := true

;===================== READ PARAMS FROM SCRIPT'S FILE NAME =====================

; NoScripts
if RegExMatch(A_ScriptName, "NoScripts")
    bLaunchScripts := false

;===============================================================================

OutputDebug("HOLD [ESC] TO ABORT LAUNCH SEQUENCE")
SetTimer, Abort, 100

;===============================================================================

If (bLaunchScripts) {
    OutputDebug("Run Helper script...")
    Run, ..\Helper\Game_SnowRunner.ahk
    OutputDebug("Run Logistics scripts...")
    Run, ..\Logistics\Game_SnowRunner_Logistics.ahk
    OutputDebug("WinWait...")
    WinWait, SnowRunner Logistics
    Sleep 1000 ; Waits for slow GUI initialization
    WinActivate
    OutputDebug("WinWaitActive...")
    WinWaitActive
    Send {F3} ; Hide "SnowRunner Logistics" window
}

;===============================================================================

sSnowRunner := "E:\UNPROTECTED\GAMES\SnowRunner_-_Premium_Edition\Sources\Bin\SnowRunner.exe"
SplitPath, sSnowRunner, , sWorkingDir
If (!WinExist("ahk_group SpinTires")) {
    OutputDebug("Run SnowRunner...")
    Run, %sSnowRunner%, %sWorkingDir%
    OutputDebug("WinWait...")
    WinWait, ahk_group SpinTires
    WinActivate
    OutputDebug("WinWaitActive...")
    WinWaitActive
} Else {
    MsgBox % "Game is running..."
    ExitApp
}

;===============================================================================

OutputDebug("Wait epilepsy message...")
WinGetPos, X, Y, iWidth, iHeight
X1 :=  iWidth // 2 - iPicSz // 2
Y1 := iHeight // 2 - iPicSz // 2
X2 := X1 + iPicSz
Y2 := Y1 + iPicSz
CoordMode, Pixel, Window ; Match ImageSearch with WinGetPos result
Loop {
    Sleep 1000
    ; Search in the center of the window
    ImageSearch, _X, _Y, % X1, % Y1, % X2, % Y2, BlackSquare.png
    If (ErrorLevel == 2) {
        MsgBox % "Can't open image to search."
        ExitApp
    }
    If (ErrorLevel == 1) {
        OutputDebug("ImageSearch: black square not found (CENTER of the window)...")
        Break
    }
    OutputDebug("ImageSearch: black square found (CENTER of the window)...")
}

;===============================================================================

OutputDebug("Show/Destroy GUI window to loose/gain game's window focus...")
If (WinActive()) {
    Gui, New
    Gui, Add, Text,, Window closed automatically
    Gui, Show
    Sleep 1000
    Gui, Destroy
} Else
    ExitApp

;===============================================================================

WinActivate
OutputDebug("WinWaitActive...")
WinWaitActive
OutputDebug("Press [Esc] to skip intro...")
CoordMode, Pixel, Client ; skip window's border and title bar
Loop {
    Sleep 1000
    If (WinActive()) {
        Send {Esc}
        OutputDebug("==> [ESC]")
    }
    Else
        ExitApp
    ; Search in the top left corner
    ImageSearch, _X, _Y, % 0, % 0, % iPicSz, % iPicSz, BlackSquare.png
    If (ErrorLevel == 1) {
        OutputDebug("ImageSearch: black square not found (TOP LEFT CORNER)...")
        Break
    }
    OutputDebug("ImageSearch: black square found (TOP LEFT CORNER)...")
}

;===============================================================================

OutputDebug("Press [Enter] to enter Main Menu and press [Continue]...")
Loop 5 {
    Sleep 1000
    If (WinActive()) {
        Send {Enter}
        OutputDebug("==> [ENTER]")
    }
    Else
        ExitApp
}

;===============================================================================

OutputDebug("Exit...")
ExitApp

;===============================================================================

Abort() {
    If (GetKeyState("Esc", "P"))
        ExitApp
}

OutputDebug(sText) {
    global iPicSz
    static sStr := ""
    sStr .= sText "`n"
    CoordMode, ToolTip, Client
    ToolTip % sStr, % iPicSz, 0
    OutputDebug % sText "`n"
}
