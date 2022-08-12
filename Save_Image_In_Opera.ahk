#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

GroupAdd, Opera, ahk_exe opera.exe

timeout := 4 ; seconds to wait window
ttDisplayTime := 4000 ; milliseconds to show ToolTip

!x:: ExitApp
!z:: Reload

#IfWinActive ahk_group Opera
F1:: ShowHelpWindow("
(
Win -> MButton
 F2 -> Save
 F3 -> Save + Close
+F2 -> Click + Save
+F3 -> Click + Save + Close
^F2 -> Save + Prev. Tab (save favorite then ^F3 to remove)
^F3 -> Click + Close (remove from favorite)
)")

LWin::Click Middle

F2:: ;Save
Save:
MouseGetPos, X, Y
Send {RButton}
; Wait context menu
Loop {
	PixelGetColor, color, % X + 10, % Y + 40, RGB
	if (color == 0x161B1F)
		break
	if (A_TimeSinceThisHotkey > timeout * 1000) {
		ToolTip("Context menu timeout (" timeout " sec)", ttDisplayTime) ; milliseconds
		return
	}
	Sleep 50
}
; Click 'Save image as...'
MouseMove 10, 40, , R
Send {LButton}
MouseMove, %X%, %Y%
; Wait 'Save As' window
WinWaitActive, Save As, , %timeout%
if (ErrorLevel) {
	ToolTip("'Save As' window timeout (" timeout " sec)", ttDisplayTime) ; milliseconds
	return
}
; Press 'Save' button
Send {Enter}
return

F3:: ;Save + Close
SaveClose:
Gosub Save
Sleep 300 ; Wait download notification disappear
Send ^w
return

+F2:: ;Click + Save
Send {LButton}
Sleep 500
Gosub Save
return

+F3:: ;Click + Save + Close
Send {LButton}
Sleep 750
Gosub SaveClose
return

^F2:: ;Save + Prev. Tab
Gosub Save
Sleep 200
Send ^+{Tab}
Send {Ctrl Up} ; If user keep pressing Ctrl, Opera will show preview of all tabs. Force key up.
return

^F3:: ;Click + Close
Send {LButton}
Sleep 500
Send ^w
return
