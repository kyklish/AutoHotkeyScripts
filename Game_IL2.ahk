#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

#Include <JoyAxis2MouseCursor>
WatchJoystick := Func("JoyAxis2MouseCursor").Bind("V", "U", 1.0)
SetTimer, %WatchJoystick%, 10

!z:: Reload
!x:: ExitApp
