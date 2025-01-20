﻿#Include <_COMMON_SETTINGS_>

;Automatically rename all MHTML files to MHT in %TargetDir% every %Period% milliseconds

#Persistent ;see help to understand why it's needed here
;-------------------------------------------------------------------------------------
oTargetDir := []
oTargetDir.Push("R:")
oTargetDir.Push("F:\GAMES\ПАПА")
oTargetDir.Push("C:\Users\Fixer\Documents\")
oTargetDir.Push("C:\Users\Fixer\Downloads")

iPeriod := 1000

SetTimer, AutoReName, %iPeriod%

AutoReName:
For i, sTargetDir in oTargetDir
	FileMove, %sTargetDir%\*.mhtml, %sTargetDir%\*.mht
return
