#Include <_COMMON_SETTINGS_>
Menu, Tray, Icon ;Tray icon is disabled in _COMMON_SETTINGS_.ahk, here we enable it back.

; g_sFileNameSkipDelayTag := A_Temp "\AutoStart_SkipDelay_TAG.ahk"
g_bAutoStart := true
g_bSkipDelay := false

;Without delay, immediately after Windows starts, RunAs command in Reload_AsAdmin()
;   function crashes this script with error "Service is already started".
;/restart switch adds by "Reload" command.
;Note that /restart is a built-in switch (applied to AutoHotkey.exe, not to the script),
;so is not included in the array of command-line parameters, must use WinAPI.
sFullCommandLine := DllCall("GetCommandLine", "str")
MsgBox % sFullCommandLine
if not RegExMatch(sFullCommandLine, "i) /restart(?!\S)") { ;i) - case-insensitive [добавил сам]
    ;First launch of script (manual or on Windows' start)
    Hotkey, Esc, CancelAutoStart ;Here we can change [g_bAutoStart] value.
    SoundBeep
    ToolTip, Press ESC to cancel autostart., 0, 0
    Sleep, 4000 ;Do not sleep, if script reloaded by "Reload" command.
    Hotkey, Esc, Off
    ToolTip
}

;Add /restart parameter to simulate Reload command behaviour.
if (!g_bAutoStart)
    Reload_AsAdmin("/restart -SkipAutoStart")
else
    Reload_AsAdmin("/restart")

;On first launch (manual or on Windows' start) there are no TAG file in TEMP directory.
;Run startup programs with delayed start. Then create empty TAG file in TEMP directory.
;On script's reload check TAG file and run programs without delay.
; if (FileExist(g_sFileNameSkipDelayTag))
;     g_bSkipDelay := true
; else
;     FileAppend, , %g_sFileNameSkipDelayTag% ;Create empty TAG file

; MsgBox % A_Args.Length()
for n, sParam in A_Args {
    MsgBox % sParam
    if (sParam == "/restart")
        continue
    else if (sParam == "-SkipDelay")
        g_bSkipDelay := true
    else if (sParam == "-SkipAutoStart")
        g_bAutoStart := false
    else {
        MsgBox % A_ScriptName ": wrong parameter " sParam "."
        ExitApp
    }
}

;-------------------------------------------------------------------------------------

g_AutoStartScriptPath := A_ScriptDir "\AutoStartObjects.ahk"
if (g_bAutoStart)
    if (g_bSkipDelay)
        Run, "%A_AhkPath%" "%g_AutoStartScriptPath%" -SkipDelay
    else
        Run, %g_AutoStartScriptPath%
Run, %A_ScriptDir%\Auto_ReName_MHTMLtoMHT.ahk
Run, %A_ScriptDir%\Clock.ahk
;Run, %A_ScriptDir%\Change_Keyboard_Language_CTRL.ahk
;Run, %A_ScriptDir%\Change_Keyboard_Language_SHIFT.ahk
;Run, %A_ScriptDir%\Copy_Opera_To_RAM.ahk
Run, %A_ScriptDir%\CPU_Fan_On_Off.ahk
Run, %A_ScriptDir%\CPU_Freq_Cores_Manager.ahk
;Run, %A_ScriptDir%\Esc_Close.ahk
;Run, %A_ScriptDir%\Fix_Mouse_Double_Click.ahk
;Run, %A_ScriptDir%\Hide_Cursor_And_Block_Mouse_Move_GUI.ahk ; проблемы после использования скрипта, не работают нормально программы
;Run, %A_ScriptDir%\Hide_Cursor_And_Block_Mouse_Move_MouseMove.ahk
Run, %A_ScriptDir%\HotKeys.ahk
; Run, %A_ScriptDir%\Scroll_Without_Activating.ahk
Run_ScriptAsUser(A_ScriptDir "\Tray_Icon_Organize.ahk") ;If run as admin - it hangs explorer.exe
Run_ScriptAsUser(A_ScriptDir "\Tray_Icon_Click.ahk") ;If run as admin - it hangs explorer.exe
Run, %A_ScriptDir%\Window_Manipulation.ahk

;-------------------------------------------------------------------------------------
^#!x:: ;Ctrl + Win + Alt + X close "AutoStart" programs
    CloseAutoStartPrograms()
Return
;-------------------------------------------------------------------------------------
#!x:: ;Win + Alt + X close all scripts and NOT exit
    CloseAllScripts()
Return
;-------------------------------------------------------------------------------------
#!z:: ;Win + Alt + Z reload all scripts
    CloseAllScripts()
    ;This not work, because we already with admin rights here!
    ; Reload_AsAdmin("/restart -SkipDelay")
    ;Simulate Reload command by running this script again and exit.
    ; Run, "%A_AhkPath%" /force "%A_ScriptFullPath%" /restart -SkipDelay
    Run, "%A_AhkPath%" "%A_ScriptFullPath%" /restart -SkipDelay
ExitApp
;-------------------------------------------------------------------------------------

CloseAllScripts()
{
    ;----Exclude section
    WinGet, pid_studio, PID, AHK Studio
    WinGet, pid_esc_close, PID, Esc Close ;this was for separate program "Esc Close" (compiled AHK script)
    WinGet, pid_gridy, PID, Gridy ;this was for separate program "Gridy" (compiled AHK script)
    WinGet, pid_splat, PID, Splat
    pid_this := DllCall("GetCurrentProcessId") ;не закрыть самого себя
    ;----End exclude Section

    WinGet, instances, List, ahk_class AutoHotkey ;if write ahk_class AutoHotkey it will close even compiled scripts ;ExcludeTitle здесь не работает
    Loop %instances% ;%instances% returns number of elements in pseudo-array "instances"
    {
        WinGet, pid, PID, % "ahk_id " instances%A_Index% ;доступ к элементам массива по индексу, WinGet возвращает псевдо-массив! ; The built-in variable A_Index contains the number of the current loop iteration
        if((pid <> pid_this) and (pid <> pid_studio) and (pid <> pid_esc_close)and (pid <> pid_gridy) and (pid <> pid_splat)) ;не закрывать нужные скрипты
            WinClose % "ahk_id " instances%A_Index%
    }
}

CancelAutoStart()
{
    global g_bAutoStart
    g_bAutoStart := false
    ToolTip
    SoundBeep
}

CloseAutoStartPrograms()
{
    global g_AutoStartScriptPath
    Run, "%A_AhkPath%" "%g_AutoStartScriptPath%" -QuitProgram
    Sleep, 10000
    Run, "%A_AhkPath%" "%g_AutoStartScriptPath%" -KillProgram
}
