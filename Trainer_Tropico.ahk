#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon


;TROPICO
SendMode, Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetKeyDelay, 50, 50 ; чтобы работало в играх, нужно использовать задержки при нажатиях (only Event mode)

#IfWinActive, ahk_exe Tropico.exe
Numpad0:: Send muchopesos
#IfWinActive

!z:: Reload
!x:: ExitApp