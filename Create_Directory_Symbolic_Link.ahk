#Include <_COMMON_SETTINGS_>

if (A_Args.Length() != 2)
{
    MsgBox % "This script requires 2 parameters, without quotes, but it only received " A_Args.Length() "."
    ExitApp
}

;Trim Space Tab Quote and add Quote around
sLink := """" Trim(A_Args[1], " `t""") """"
sTarget := """" Trim(A_Args[2], " `t""") """"

sParams := sLink " " sTarget

Reload_AsAdmin(sParams)

;MsgBox % sParams
sCommand .= "if exist " sLink "\* (mklink /D " sTarget " " sLink ") else (echo The cursor must be on a FOLDER)"

;MsgBox % sCommand
sOut := RunWaitCMD(sCommand)
;MsgBox % sOut