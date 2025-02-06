#Include <_COMMON_SETTINGS_>
#Persistent

;Rename MHTML to MHT in %oTargetDir% every %iPeriod% milliseconds

;-------------------------------------------------------------------------------------

oTargetDir := []
oTargetDir.Push(ExpandEnvVars("R:"))
oTargetDir.Push(ExpandEnvVars("R:\MSE"))
oTargetDir.Push(ExpandEnvVars("%SOFT%\ПАПА"))
oTargetDir.Push(ExpandEnvVars("%UserProfile%\Desktop"))
oTargetDir.Push(ExpandEnvVars("%UserProfile%\Documents"))
oTargetDir.Push(ExpandEnvVars("%UserProfile%\Downloads"))

iPeriod := 1000

SetTimer, AutoReName, %iPeriod%

AutoReName:
    For i, sTargetDir in oTargetDir
        FileMove, %sTargetDir%\*.mhtml, %sTargetDir%\*.mht
return
