#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; Used with [SendEvent] commands below
SetKeyDelay, 500, 100

GroupAdd, Game, ahk_exe Sekiro.exe
GroupAdd, Trainer, ahk_exe Sekiro Shadows Die Twice v1.02-v1.05 Plus 24 Trainer.exe

; Game does not run with this command
; If (!WinExist("ahk_group Game"))
;     Run, "E:\UNPROTECTED\GAMES\Sekiro_-_Shadows_Die_Twice_-_GOTY\Sekiro.exe", "E:\UNPROTECTED\GAMES\Sekiro_-_Shadows_Die_Twice_-_GOTY"
If (!WinExist("ahk_group Trainer"))
    Run, "E:\UNPROTECTED\GAMES\Sekiro_-_Shadows_Die_Twice_-_GOTY\Sekiro Shadows Die Twice v1.02-v1.05 Plus 24 Trainer.exe", "E:\UNPROTECTED\GAMES\Sekiro_-_Shadows_Die_Twice_-_GOTY"
Sleep, 1000

; SOMETIME THIS COMMANDS DOES NOT MOVE WINDOWS, DON'T KNOW WHY
WinMove, Sekiro: Shadows Die Twice v1.02-v1.05 Plus 24 Trainer, , 1140, 0, 780, 857 ; Top-Right corner of the monitor.
Sleep, 1000

WinActivate, ahk_group Game

OnExit("CloseTools")

XInput_Init()
SetTimer, GamePad, 100

CloseTools(ExitReason, ExitCode)
{
    WinClose, ahk_group Trainer
}

; Use [LEFT BUMPER] + [Y] to set lock on target
GamePad:
    Loop, 4 {
        If State := XInput_GetState(A_Index - 1) {
            If (State.wButtons & XINPUT_GAMEPAD_LEFT_SHOULDER && State.wButtons & XINPUT_GAMEPAD_X)
                ; Mouse clicks works unreliable
                ; Click Middle ; [MMB] = Lock Target
                ; SendEvent {Click Middle} ; [MMB] = Lock Target
                ; In game assign [O] key to [Lock Target].
                SendEvent o ; [O] = Lock Target
        }
    }
Return

#IfWinActive, ahk_group Game
    ; [FLiNG's Trainer] ==> [Stealth Mode] ==> [NumpadDot] remap it to [NumpadEnter]
    ; Fixes [CPU_Freq_Cores_Manager.ahk] exclusive [NumpadDot] hotkey capture
    NumpadEnter::NumpadDot

    ; Quit game using in-game menu (press [E] to confirm quit or add in to the end of the [SendEvent] command)
    F8::SendEvent {Esc}z{Up}e{Left}
#If

!Z::Reload
!X::ExitApp

F5:: ShowHelpWindow("
(
In game assign [O] key to [Lock Target].

Launching [FLiNG's Trainer].
Closing them on script's exit.

GamePad:
 [LB] + [X] = Lock on target

Keyboard:
         F8 = Quit game using in-game menu
NumpadEnter = [FLiNG's Trainer] [Stealth Mode]
)")
