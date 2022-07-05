#NoEnv
#SingleInstance Force
#NoTrayIcon
SetWorkingDir %A_ScriptDir%

Random index, 0.5, 3.4 ;float
index := Round(index) ;int
SoundPlay Sneeze_%index%.wav, Wait
