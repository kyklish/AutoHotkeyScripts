; Overwrite all files in "VIDEO" folder with blank video files.
; Put video files in "VIDEO" folder and run script.

#Warn
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

sFileTypes := ["avi", "bik", "mp4"]

For _, ext in sFileTypes {
    Loop, Files, .\video\*.%ext%, FR
    {
        FileCopy, blank.%ext%, %A_LoopFilePath%, 1
    }
}

MsgBox, Done
