#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, Game, ahk_exe Subnautica.exe

SpamPeriod := 250


ToggleKey(Key, ByRef KeyNotDown)
{
	KeyNotDown := !KeyNotDown
	if (KeyNotDown)
		Send {%Key% down}
	else
		Send {%Key% up}
	return KeyNotDown
}


#IfWinNotExist, ahk_group Game
Launch_App1:: Run, steam://rungameid/264710
;Launch_App1:: Run, %A_StartMenu%\Programs\Steam\Subnautica.url

#IfWinNotActive, ahk_group Game
Launch_App1:: WinActivate, ahk_group Game

#IfWinActive, ahk_group Game
; Toggle hold [W], [LMB] or [RMB] key/button
CapsLock:: Wstatus := ToggleKey("w", Wstatus)
t::      LMBstatus := ToggleKey("LButton", LMBstatus)
g::      RMBstatus := ToggleKey("RButton", RMBstatus)

; Spam LMB
z::
if (SpamClick != SpamPeriod)
	SpamClick := SpamPeriod
else
	SpamClick := "Off"
SetTimer, SendLMB, %SpamClick%
return

SendLMB:
Click
return

; Spam RMB
x::
while GetKeyState("x","P") {
	Send {RButton}
	Sleep %SpamPeriod%
}
return

#IfWinActive
!z::Reload
!x::ExitApp

#IfWinNotActive, ahk_group Game
F1:: ShowHelpWindow("
(
Caps Lock -> Toggle [W]   (auto drive\swim\walk).
        T -> Toggle [LMB] (PRAWN Suit drilling/grappling).
        G -> Toggle [RMB] (useful for many tool).
        Z -> Toggle spam [LMB] (harvesting).
        X -> Holding key will spam RMB (knife, move items in storage).
)")
