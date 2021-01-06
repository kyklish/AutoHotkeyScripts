#Include <_COMMON_SETTINGS_>

;Automaticaly rename all MHTML files to MHT in %TargetDir% every %Period% milliseconds

#Persistent ;see help to understand why it's needed here
;-------------------------------------------------------------------------------------
oTargetDir := []
oTargetDir.Push("R:")
oTargetDir.Push("F:\GAMES\ПАПА")

iPeriod := 1000

SetTimer, AutoReName, %iPeriod%

AutoReName:
For i, sTargetDir in oTargetDir
	FileMove, %sTargetDir%\*.mhtml, %sTargetDir%\*.mht
return