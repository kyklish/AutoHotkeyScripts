#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

SetKeyDelay, 50, 50
SetMouseDelay, 150

GroupAdd, Game, ahk_exe SOVIET64.exe   ; Steam
GroupAdd, Game, ahk_exe SOVIET64_G.exe ; GOG

#IfWinActive, ahk_group Game
    ; Demolish building under cursor
    CapsLock::SendEvent, 2{Click}{Enter}{Esc} ; Assign [Demolish] to [2] hotkey in game
    ; Sell transport under cursor + Demolish building under cursor
    +CapsLock::SendEvent, {Click}{Del}{Enter}
#If

!Z::Reload
!X::ExitApp
