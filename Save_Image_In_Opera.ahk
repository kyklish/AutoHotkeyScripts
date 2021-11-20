#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
CoordMode, Mouse, Screen

F1:: ;Save picture
Send {RButton}
Sleep 300
MouseGetPos, _X, _Y
MouseMove 10, 40, , R
Send {LButton}
Sleep 1250
Send {Enter}
MouseMove, %_X%, %_Y%
return

F2:: ;Save picture and close tab
Gosub F1
Sleep 500
Send ^w
return

!x:: ExitApp
!z:: Reload
