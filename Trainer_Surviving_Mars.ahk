#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, SM, ahk_exe MarsSteam.exe

; Set game settings: windowed mode,  1280x720

; No trailing back slashes
sSourceModFolder := "F:\Setup\Paradox\STUFF\Surviving Mars\Mods\Regular\Expanded Cheat Menu\Layout\Fixer\_LAYOUT_\Kyklish - Layout Capture Mod"
sTargetModFolder := A_AppData . "\Surviving Mars\Mods\Kyklish - Layout Capture Mod"

#IfWinNotExist, ahk_group SM
Launch_App1:: Run, "F:\GAMES\Surviving Mars Green Planet\MarsSteam.exe", F:\GAMES\Surviving Mars Green Planet

#IfWinNotActive, ahk_group SM
Launch_Media::
Launch_App1:: WinActivate, ahk_group SM

#IfWinActive, ahk_group SM
; Load first savegame file
Launch_App1::
Click, 800, 400
Sleep, 500
Click, 100, 145
Sleep, 500
Send, 1
return

; Restart
Launch_Media::
Send, ^!r
Sleep, 250
Send, {Enter}
return

#IfWinActive
F1:: ShowHelpWindow("
(LTrim
	Button  [My Computer]  -> Start game. | WinActivate. | Load first savegame from main menu.
	Button  [Media Player] -> Restart game. | WinActivate.
	Button  [Calculator]   -> Show lua errors from newest log file.
	Button ^[Calculator]   -> Copy mod's folder to game.
)")

^Launch_App2::
MsgBox, 4, , Copy mod's folder to game?
IfMsgBox No
    return
CopyModFolderToGame()
return

;Show errors from newest log file.
Launch_App2::
if (bWindowOnScreen) {
	bWindowOnScreen := false
	ShowHelpWindow()
	return
}
sFileList := ""
Loop, Files, %A_AppData%\Surviving Mars\logs\MarsSteam.exe-*.log
	sFileList .= A_LoopFilePath "`n"
Sort, sFileList, R ;now first line is newest log file
Loop, Parse, sFileList, `n
{
	sFile := A_LoopField
	break
}
sErrors := ""
Loop, Read, % sFile
{
	if (InStr(A_LoopReadLine, "Error loading AppData/Mods/Kyklish"))
		sErrors .= A_LoopReadLine "`n"
}
sErrors := SubStr(sErrors, 1, -1) ;delete last "`n"
if (sErrors) {
	bWindowOnScreen := true
	ShowHelpWindow(sErrors)
}
return

!z::Reload
!x::ExitApp

CopyModFolderToGame() {
	global sSourceModFolder
	global sTargetModFolder
	
	FileCreateDir, % sTargetModFolder
	Loop, Files, %sSourceModFolder%\*.*, F
	{
		if (A_LoopFileName == ".gitignore" or A_LoopFileName == "metadata.lua.txt")
			continue
		FileCopy, % A_LoopFilePath, % sTargetModFolder, 1
	}
	Loop, Files, %sSourceModFolder%\*.*, D
	{
		if (A_LoopFileName == ".git" or A_LoopFileName == "AppData" or A_LoopFileName == "Comment")
			continue
		FileCopyDir, % A_LoopFilePath, % sTargetModFolder . "\" . A_LoopFileName, 1
	}
	SoundBeepTwice()
}
