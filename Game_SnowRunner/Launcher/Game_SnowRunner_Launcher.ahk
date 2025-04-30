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

;===============================================================================

OutputDebug % "Run Helper & Logistics scripts...`n"
Run, ..\Helper\Game_SnowRunner.ahk
Run, ..\Logistics\Game_SnowRunner_Logistics.ahk
OutputDebug % "WinWait...`n"
WinWait, SnowRunner Logistics
Sleep 1000
WinActivate
OutputDebug % "WinWaitActive...`n"
WinWaitActive
Send {F3} ; Hide "SnowRunner Logistics" window

;===============================================================================

sSnowRunner := "E:\UNPROTECTED\GAMES\SnowRunner_-_Premium_Edition\Sources\Bin\SnowRunner.exe"
SplitPath, sSnowRunner, , sWorkingDir
If (!WinExist("ahk_group SpinTires")) {
    OutputDebug % "Run SnowRunner...`n"
    Run, %sSnowRunner%, %sWorkingDir%
    OutputDebug % "WinWait...`n"
    WinWait, ahk_group SpinTires
    WinActivate
    OutputDebug % "WinWaitActive...`n"
    WinWaitActive
} Else {
    MsgBox % "Game is running..."
    ExitApp
}

;===============================================================================

OutputDebug % "Wait epilepsy message...`n"
WinGetPos, X, Y, iWidth, iHeight
iPicSz := 40 ; Size of the "Black.png" square
X1 :=  iWidth // 2 - iPicSz // 2
Y1 := iHeight // 2 - iPicSz // 2
X2 := X1 + iPicSz
Y2 := Y1 + iPicSz
CoordMode, Pixel, Window ; Match ImageSearch with WinGetPos result
Loop {
    Sleep 1000
    ; Search in the center of the window
    ImageSearch, _X, _Y, % X1, % Y1, % X2, % Y2, Black.png
    If (ErrorLevel == 2) {
        MsgBox % "Can't open image to search."
        ExitApp
    }
    If (ErrorLevel == 1) {
        OutputDebug % "ImageSearch: Black not found (in the CENTER of the window)...`n"
        Break
    }
    OutputDebug % "ImageSearch: Black found (in the CENTER of the window)...`n"
}

;===============================================================================

OutputDebug % "Show/Destroy GUI window to loose/gain game's window focus...`n"
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
OutputDebug % "WinWaitActive...`n"
WinWaitActive
OutputDebug % "Press [Esc] to skip intro...`n"
CoordMode, Pixel, Client ; skip window's border and title bar
Loop {
    Sleep 1000
    If (WinActive())
        Send {Esc}
    Else
        ExitApp
    ; Search in the top left corner
    ImageSearch, _X, _Y, % 0, % 0, % iPicSz, % iPicSz, Black.png
    If (ErrorLevel == 1) {
        OutputDebug % "ImageSearch: Black not found (in the TOP LEFT CORNER)...`n"
        Break
    }
    OutputDebug % "ImageSearch: Black found (in the TOP LEFT CORNER)...`n"
}

;===============================================================================

OutputDebug % "Press [Enter] to enter Main Menu and press [Continue]...`n"
Loop 5 {
    Sleep 1000
    If (WinActive())
        Send {Enter}
    Else
        ExitApp
}

;===============================================================================

OutputDebug % "Exit...`n"
ExitApp
