#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
CoordMode, Mouse, Screen

GroupAdd, Opera, ahk_exe opera.exe

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
^F2 -> Save + Prev. Tab (save favorite then ^F2 to remove)
^F3 -> Click + Close (remove from favorite)
)")

LWin::Click Middle

F2:: ;Save
Send {RButton}
Sleep 400
MouseGetPos, _X, _Y
MouseMove 10, 40, , R
Send {LButton}
Sleep 1500
Send {Enter}
MouseMove, %_X%, %_Y%
return

F3:: ;Save + Close
Gosub F2
Sleep 500
Send ^w
return

+F2:: ;Click + Save
Send {LButton}
Sleep 750
Gosub F2
return

+F3:: ;Click + Save + Close
Send {LButton}
Sleep 750
Gosub F3
return

^F1:: ;Save + Prev. Tab
Gosub F2
Sleep 500
Send ^+{Tab}
return

^F2:: ;Click + Close
Send {LButton}
Sleep 500
Send ^w
return
