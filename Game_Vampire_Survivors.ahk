#Warn
#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

SplashImage_New("VampireSurvivorsWeaponEvolutions.png")

F1::SplashImage_Toggle()
!x::ExitApp
