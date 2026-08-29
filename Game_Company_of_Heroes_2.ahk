#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

GroupAdd, Game, ahk_exe RelicCoH.exe
GroupAdd, Game, ahk_exe RelicCoH2.exe
GroupAdd, Game, ahk_exe RelicCoH3.exe

#IfWinActive, ahk_group Game
    ; GAME: stretch game's window to Screen Size / HD Size.
    ^!1::        WinMove, ahk_group Game,, 0, 0, A_ScreenWidth, A_ScreenHeight
    ^!2::        WinMove, ahk_group Game,, (A_ScreenWidth - 1280) // 2, (A_ScreenHeight - 720) // 2, 1280, 720
#IfWinActive, ahk_exe RelicCoH2.exe
    ; ARROWs to WASD
    +W::Up
    +A::Left
    +S::Down
    +D::Right
    ; Select all infantry and vehicles
    +Q::^.
    +E::^/
    ; Select next idle infantry and vehicle
    +R::!.
    +F::!/
#If

!Z::Reload
!X::ExitApp
