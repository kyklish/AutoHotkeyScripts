#Include <_COMMON_SETTINGS_>

SendMode Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetKeyDelay, 50, 10 ; чтобы работало в играх, нужно использовать задержки при нажатиях (only Event mode)


#IfWinActive, ahk_class CabinetWClass
Backspace::
ControlGet renameStatus, Visible, , Edit1, A
ControlGetFocus focussed, A
if(renameStatus != 1 && (focussed = "DirectUIHWND3" || focussed = "SysTreeView321")) {
	Send {Alt Down}{Up}{Alt Up}
} else {
	Send {Backspace}
}
#IfWinActive