#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
CoordMode, Mouse, Screen

GroupAdd, Browser, ahk_exe opera.exe

#IfWinActive ahk_group Browser
F1:: ;Save picture
Send {RButton}
Sleep 400
MouseGetPos, _X, _Y
MouseMove 10, 40, , R
Send {LButton}
Sleep 1500
Send {Enter}
MouseMove, %_X%, %_Y%
return

F2:: ;Save picture and close tab
Gosub F1
Sleep 500
Send ^w
return

+F1:: ;Click + Save
Send {LButton}
Sleep 750
Gosub F1
return

+F2:: ;Click + Save + Close
Send {LButton}
Sleep 750
Gosub F2
return

^F1:: ;Save + Go to prev tab
Gosub F1
Sleep 500
Send ^+{Tab}
return

^F2:: ;Click + Close
Send {LButton}
Sleep 500
Send ^w
return

!x:: ExitApp
!z:: Reload
