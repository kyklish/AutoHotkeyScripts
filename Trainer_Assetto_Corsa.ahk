#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

CM_FullName := "E:\GAMES\Assetto Corsa\Content Manager.exe"
SplitPath, CM_FullName, CM_FileName, CM_Dir
Content_Manager := "ahk_exe " CM_FileName

FP_FullName := A_ProgramFiles "\FreePIE\FreePIE.exe"
SplitPath, FP_FullName, FP_FileName, FP_Dir
FreePIE := "ahk_exe " FP_FileName

AssettoCorsa := "ahk_exe acs.exe" ; x64 version of game
Folder := "Assetto Corsa ahk_exe explorer.exe" ; folder on desktop with shortcuts to game, tools, this script, etc

GroupAdd, AC, %AssettoCorsa%

GroupAdd, Result, Hotlap %Content_Manager%
GroupAdd, Result, Cancelled %Content_Manager%
GroupAdd, Result, Quick Race %Content_Manager%

; ---------------Start Apps---------------

;if (WinExist(Folder))
	WinClose, %Folder%

if (!WinExist(Content_Manager)) {
	Run, %CM_FullName%, %CM_Dir%
	WinWait, %Content_Manager%, , 5
	if (ErrorLevel)
		MsgBox, Content Manager won't start in 5 seconds.
	WinActivate
}

Reload_AsAdmin() ; run "Content Manager" before this (regular rights) and "FreePIE" after (admin rights)

if (!WinExist(FreePIE)) {
	Run, %FP_FullName% "E:\GAMES\Assetto Corsa.py" /run /t, %FP_Dir%, Min, FP_PID
	WinWait, %FreePIE%, , 5
	if (ErrorLevel)
		MsgBox, FreePIE won't start in 5 seconds.
}

; ----------------------------------------

CoordMode, Mouse, Screen
SetTimer, Wait_AC_Start, 500


Toggle_Block_Mouse:
ScrollLock::					; Hotkey, change to your liking
If (BlockMouse := !BlockMouse) {   ; Toggle the BlockMouse variable and check if it is TRUE or FALSE
	MouseMove 0, 0, 0	          ; Move the cursor to the top left corner
	BlockInput MouseMove          ; Freeze the mouse cursor
} Else {                           ; If unblock: 
	BlockInput MouseMoveOff       ; allow the mouse cursor to move
	MouseMove A_ScreenWidth/2, A_ScreenHeight/2, 0 ; move it to the center of the screen
}
Return


3:: ; 3 - I assign this key in Content Manager for exiting game
Send, {3 down} ; Close game, it reacts only this way
Sleep, 50
Send, {3 up}
WinWaitClose, %AssettoCorsa%, , 5
if (ErrorLevel)
	Reload
if (BlockMouse)
	Gosub, Toggle_Block_Mouse
WinWait, ahk_group Result, , 5 ; Close result window
if (!ErrorLevel)
	WinClose
SetTimer, Wait_AC_Start, On
return


Wait_AC_Start:
if (WinExist(AssettoCorsa)){
	if (!BlockMouse){
		Sleep, 3000
		Gosub, Toggle_Block_Mouse
		SetTimer, Wait_AC_Start, Off
	}
}
return


#IfWinNotExist, ahk_group AC
F1:: ShowHelpWindow("
(LTrim
	Use this script, only when play with vJoy.
	Automatically blocks mouse movement, when game runs.
	3 -> Exit game and unblock mouse movement.
)")


!z:: Reload
!x::
;if (WinExist(Content_Manager))
	WinClose, Content Manager %Content_Manager% ; only WinTitle, any other methods (HWND, PID, EXE) not work :(
;if (WinExist(FreePIE))
	WinClose, FreePIE %FreePIE% ; only WinTitle, any other methods (HWND, PID, EXE) not work :(
ExitApp
