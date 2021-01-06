#Include <_COMMON_SETTINGS_>

;Sleep, 15000 ;ждем пока запустится

;Kill "Discord" processes to minimize it.
;In CMD: "taskkill /IM discord.exe" works fine
;In AHK "RunWaitCMD("taskkill /IM discord.exe")" will kill it to death
;Use "taskkill", because it will kill all "discrod.exe" processes simultaneously
;MsgBox % RunWaitCMD("taskkill /IM discord.exe")
/*
WM_CLOSE := 0x10
WM_QUIT  := 0x12
WinGet, instances, List, ahk_exe discord.exe
Loop %instances% ;%instances% returns number of elements in pseudo-array "instances"
{
	WinGet, pid, PID, % "ahk_id " instances%A_Index% ;доступ к элементам массива по индексу, WinGet возвращает псевдо-массив! ; The built-in variable A_Index contains the number of the current loop iteration
	WinClose % "ahk_id " instances%A_Index% -- close to death
	PostMessage, WM_CLOSE, , , , % "ahk_id " instances%A_Index% - close to death
}
*/

OnMessage(0x5555, "AutoStartObjectsComplete") ; Wait message from AutoStartObjects.ahk script

AutoStartObjectsComplete() ; Returning from this function quickly is often important
{	; Heavy job don't work here, because script didn't respond to windows messages here
	Run, D:\SERGEY\Options\Program Files\BAT\Minimize_Discord.bat, , Hide
	ToolTip, "%A_ScriptName%": Discord minimized, 0, 0
	Sleep, 4000 ;если выйти сразу, то ToolTip сразу же исчезнет
	ExitApp
}