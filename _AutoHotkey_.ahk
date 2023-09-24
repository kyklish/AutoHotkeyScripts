#Include <_COMMON_SETTINGS_>
Menu, Tray, Icon ;Tray icon is disabled in _COMMON_SETTINGS_.ahk, here we enable it back.

;Without delay, immediately after Windows starts, RunAs command in Reload_AsAdmin() function crashes this script with error "Service is already started".
;/restart switch adds by "Reload" command.
;Note that /restart is a built-in switch (applied to AutoHotkey.exe, not to the script),
;so is not included in the array of command-line parameters, must use WinAPI.
sFullCommandLine := DllCall("GetCommandLine", "str")
if not RegExMatch(sFullCommandLine, "i) /restart(?!\S)") ;i) - case-insensitive [добавил сам]
	Sleep, 4000 ;Do not sleep, if script reloaded by "Reload" command.
	;Sleep, 15000 ;Do not sleep, if script reloaded by "Reload" command.

Reload_AsAdmin()

;-------------------------------------------------------------------------------------

;Run, %A_ScriptDir%\Always_On_Top.ahk ; поглотил Hotkeys.ahk
Run, %A_ScriptDir%\Auto_ReName_MHTMLtoMHT.ahk
Run, %A_ScriptDir%\AutoStartObjects.ahk
Run, %A_ScriptDir%\Clock.ahk
;Run, %A_ScriptDir%\Change_Keyboard_Language_CTRL.ahk
;Run, %A_ScriptDir%\Change_Keyboard_Language_SHIFT.ahk
;Run, %A_ScriptDir%\Copy_Opera_To_RAM.ahk
Run, %A_ScriptDir%\CPU_Fan_On_Off.ahk
Run, %A_ScriptDir%\CPU_Freq_Cores_Manager.ahk
;Run, %A_ScriptDir%\Esc_Close.ahk
;Run, %A_ScriptDir%\Explorer_Hotkeys.ahk
;Run, %A_ScriptDir%\Fix_Mouse_Double_Click.ahk
;Run, %A_ScriptDir%\Hide_Cursor_And_Block_Mouse_Move_GUI.ahk ; проблемы после использования скрипта, не работают нормально программы
;Run, %A_ScriptDir%\Hide_Cursor_And_Block_Mouse_Move_MouseMove.ahk
Run, %A_ScriptDir%\HotKeys.ahk
; Run, %A_ScriptDir%\Scroll_Without_Activating.ahk
; Run, %A_ScriptDir%\Slow_Down_Mouse.ahk
Run_ScriptAsUser(A_ScriptDir "\Tray_Icon_Organize.ahk") ;If run as admin - it hangs explorer.exe
Run_ScriptAsUser(A_ScriptDir "\Tray_Icon_Click.ahk") ;If run as admin - it hangs explorer.exe
Run, %A_ScriptDir%\Window_Manipulation.ahk

;-------------------------------------------------------------------------------------
#!x:: ;Win + Alt + X close all scripts and NOT exit
CloseAllScripts()
;ExitApp
Return
;-------------------------------------------------------------------------------------
#!z:: ;Win + Alt + Z reload all scripts
CloseAllScripts()
Reload
Return
;-------------------------------------------------------------------------------------

CloseAllScripts()
{
	;----Exclude section
	WinGet, pid_studio, PID, AHK Studio
	WinGet, pid_esc_close, PID, Esc Close ;this was for separate program "Esc Close" (compiled AHK script)
	WinGet, pid_splat, PID, Splat
	pid_this := DllCall("GetCurrentProcessId") ;не закрыть самого себя
	;----End exclude Section
	
	WinGet, instances, List, ahk_class AutoHotkey ;if write ahk_class AutoHotkey it will close even compiled scripts ;ExcludeTitle здесь не работает
	Loop %instances% ;%instances% returns number of elements in pseudo-array "instances"
	{
		WinGet, pid, PID, % "ahk_id " instances%A_Index% ;доступ к элементам массива по индексу, WinGet возвращает псевдо-массив! ; The built-in variable A_Index contains the number of the current loop iteration
		if((pid <> pid_this) and (pid <> pid_studio) and (pid <> pid_esc_close) and (pid <> pid_splat)) ;не закрывать нужные скрипты
			WinClose % "ahk_id " instances%A_Index%
	}
}
