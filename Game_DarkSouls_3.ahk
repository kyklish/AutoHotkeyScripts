#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; Used with [SendEvent] commands below
SetKeyDelay, 100, 50

; Game does not run with this command
; Run, "E:\UNPROTECTED\GAMES\Dark_Souls_III_-_Game_of_the_Year_Edition\DARK SOULS III\Game\DarkSoulsIII.exe", "E:\UNPROTECTED\GAMES\Dark_Souls_III_-_Game_of_the_Year_Edition\DARK SOULS III\Game"
; Sleep, 20000
Run, "E:\UNPROTECTED\GAMES\Dark_Souls_III_-_Game_of_the_Year_Edition_Trainer\DS3Tool_v1.3.2.exe", "E:\UNPROTECTED\GAMES\Dark_Souls_III_-_Game_of_the_Year_Edition_Trainer"
Run, "E:\UNPROTECTED\GAMES\Dark_Souls_III_-_Game_of_the_Year_Edition_Trainer\Dark Souls III v1.03-v1.15 Plus 28 Trainer Ctrl+Shift+Home.exe", "E:\UNPROTECTED\GAMES\Dark_Souls_III_-_Game_of_the_Year_Edition_Trainer"
Sleep, 1000

; SOMETIME THIS COMMANDS DOES NOT MOVE WINDOWS, DON'T KNOW WHY
; WinMove, ahk_exe DarkSoulsIII.exe, , 0, 0
; [DS3Tool] used as overlay info about targeted enemy
WinMove, DS3Tool, , 970, 0 ; Game running in 720p. Top-Right corner of the game.
WinMove, FLiNG's Trainer, , 1410, 512 ; Bottom-Right corner of the monitor.
Sleep, 1000

; [DS3Tool] show only stats and resists (hides debug stuff)
WinActivate, DS3Tool
Send, {Tab 27}{Enter} ; [Toggle Resists]
Send,   +{Tab}{Enter} ; [Toggle Stats/Full]
Sleep, 1000

WinActivate, ahk_exe DarkSoulsIII.exe

OnExit("CloseTools")

XInput_Init()
SetTimer, GamePad, 100

CloseTools(ExitReason, ExitCode)
{
    WinClose, F? ; This is [DS3Tool] title when game does not running
    WinClose, DS3Tool
    WinClose, FLiNG's Trainer
}

; Use [LEFT BUMPER] + [A] to set lock on target
GamePad:
    Loop, 4 {
        If State := XInput_GetState(A_Index - 1) {
            If (State.wButtons & XINPUT_GAMEPAD_LEFT_SHOULDER && State.wButtons & XINPUT_GAMEPAD_A)
                SendEvent q ; [Q] = Lock Target
        }
    }
Return

; [FLiNG's Trainer] ==> [Save Location] ==> [NumpadDot] remap it to [NumpadEnter]
; Fixes [CPU_Freq_Cores_Manager.ahk] exclusive [NumpadDot] hotkey capture
NumpadEnter::NumpadDot

; [DS3Tool] window has strange behaviour.
; Do some [WinActivate] to hide [DS3Tool] window below game's window.
; Additionally this adds smooth [LosslessScaling] usage.
+F1::
    WinActivate, DS3Tool
    WinSet, AlwaysOnTop, Toggle, DS3Tool
    WinActivate, ahk_exe DarkSoulsIII.exe
Return

; Quit game using in-game menu (press [E] to confirm quit or add in to the end of the [SendEvent] command)
+F4::SendEvent {Esc}{Left}e+{Left}e{Left}
; Quit game using [DS3Tool]. GAME SHOWS WARNING ON NEXT SAVE LOAD! UNSAFE???
; +F4::
;     WinActivate, DS3Tool
;     Send,         {Enter} ; [Toggle Stats/Full]
;     Send,  {Tab 2}{Enter} ; [Instant Quitout]
;     Send, +{Tab 2}{Enter} ; [Toggle Stats/Full]
; Return

!Z::Reload
!X::ExitApp

!F1:: ShowHelpWindow("
(
Launching [FLiNG's Trainer] and [DS3Tool].
Closing them on script's exit.

GamePad:
 [LB] + [A] = Lock on target

Keyboard:
 Shift + F1 = [DS3Tool] toggle AlwaysOnTop
 Shift + F4 = Quit game using in-game menu
NumpadEnter = [FLiNG's Trainer] [Save Location]
)")
