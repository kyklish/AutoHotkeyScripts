#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

;SendMode, Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetKeyDelay, -1, 50 ; чтобы работало в играх, нужно использовать задержки при нажатиях (only Event mode)

#IfWinActive, ahk_exe BF2.exe
Numpad0::
SendEvent {End}
Send aiCheats.code Thomas.Skoldenborg{Enter}
return
#IfWinActive

!z:: Reload
!x:: ExitApp
