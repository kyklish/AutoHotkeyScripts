#Include <_COMMON_SETTINGS_>

sOperaPath := "D:\SERGEY\Options\Program Files\Opera"
sOperaRamPath := "R:\TEMP\Opera"

if (!FileExist(sOperaPath)) {
	MsgBox, Opera directory not exist at this path:`n"%sOperaPath%"
	ExitApp
}

if (FileExist(sOperaRamPath))
	ExitApp

; Changing the icon will not unhide the tray icon if it was previously hidden by means such as #NoTrayIcon, 
; to do that, use Menu, Tray, Icon (with no parameters).
Menu, Tray, Icon, D:\SERGEY\Options\Program Files\Opera\launcher.exe
Menu, Tray, Icon

FileCopyDir, %sOperaPath%, %sOperaRamPath%
