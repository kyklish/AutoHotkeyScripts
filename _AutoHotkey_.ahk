﻿#Include <_COMMON_SETTINGS_>
Menu, Tray, Icon ;Tray icon is disabled in _COMMON_SETTINGS_.ahk, here we enable it back.

g_bAutoStart := true
g_bSkipDelay := false
;Delay to launch all the scripts (5sec is enough)
;Set it to 10sec: fix MSI Afterburner startup sequence (see in the AutoStart.csv)
g_iToolTipShowTime := 9000 ; in milliseconds

;Without delay, immediately after Windows starts, RunAs command in Reload_AsAdmin()
;   function crashes this script with error "Service is already started".
;/restart switch adds by "Reload" command.
;Note that /restart is a built-in switch (applied to AutoHotkey.exe, not to the script),
;so is not included in the array of command-line parameters, must use WinAPI.
sFullCommandLine := DllCall("GetCommandLine", "str")
bRestart := RegExMatch(sFullCommandLine, "i) /restart(?!\S)") ;i) - case-insensitive [добавил сам]
if (!bRestart) {
    ;First launch of script (manual or on Windows' start)
    Hotkey, Esc, CancelAutoStart ;Here we can change [g_bAutoStart] value.
    SoundBeep
    ShowToolTip() ; Count down each second and show it in tooltip.
    Sleep, % g_iToolTipShowTime ;Do not sleep, if script reloaded by "Reload" command.
    Hotkey, Esc, Off
}

;We need this construction to preserve params, when elevate script's rights
;If script is already elevated, Reload_As...() will do nothing
;Add [/restart] parameter to simulate Reload command behaviour.
if (g_bAutoStart)
    Reload_AsAdmin("/restart")
else
    Reload_AsAdmin("/restart -SkipAutoStart")

;If TEMP directory cleared on PC's shutdown you can use this method.
;On first launch (manual or on Windows' start) there are no TAG file in TEMP directory.
;Run startup programs with delayed start. Then create empty TAG file in TEMP directory.
;On script's reload check TAG file and run programs without delay.
; g_sFileNameSkipDelayTag := A_Temp "\AutoStart_SkipDelay_TAG.ahk"
; if (FileExist(g_sFileNameSkipDelayTag))
;     g_bSkipDelay := true
; else
;     FileAppend, , %g_sFileNameSkipDelayTag% ;Create empty TAG file

for i, sParam in A_Args {
    ; MsgBox % sParam
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

;-------------------------------------------------------------------------------

Process, Priority, , N ;Win11 launches script with Below Normal priority, fix it here
;TODO skip autostart, but allow bypassed apps (SpeedFan, f.lux, WFC)
;Global var used in CloseAutoStartPrograms()!
g_AutoStartScriptPath := A_ScriptDir "\AutoStart.ahk"
Run_ScriptAsAdmin(g_AutoStartScriptPath, g_bAutoStart ? (g_bSkipDelay ? "-SkipDelay" : "") : "-NoAutoStart")
Run_ScriptAsUser( A_ScriptDir "\Auto_ReName_MHTMLtoMHT.ahk")
; Run_ScriptAsUser( A_ScriptDir "\Clock.ahk")
; Run_ScriptAsAdmin(A_ScriptDir "\CPU_Fan_On_Off.ahk")
Run_ScriptAsAdmin(A_ScriptDir "\CPU_Freq_Cores_Manager.ahk")
Run_ScriptAsAdmin(A_ScriptDir "\Esc_Close.ahk")
Run_ScriptAsAdmin(A_ScriptDir "\HotKeys.ahk")
Run_ScriptAsUser( A_ScriptDir "\Tray_Disk_Free\Tray_Disk_Free.ahk")
Run_ScriptAsUser( A_ScriptDir "\Tray_PageFile_Usage\Tray_PageFile_Usage.ahk")
Run_ScriptAsAdmin(A_ScriptDir "\Window_Manipulation.ahk")
if (A_OSVersion = "WIN_7") {
    ; Win11 changed tray structure to XML UI, no toolbars.
    ; Old approach to tray manipulation not work (uses toolbars)!
    Run_ScriptAsUser(A_ScriptDir "\Tray_Icon_Organize.ahk") ;If run as admin - it hangs explorer.exe
}

;-------------------------------------------------------------------------------

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
    SetTimer, ShowToolTip, Off
    ToolTip
    SoundBeep
}

CloseAutoStartPrograms()
{
    global g_AutoStartScriptPath
    Run_WaitScriptAsAdmin(g_AutoStartScriptPath, "-QuitProgram")
    Sleep, 2000
    Run_WaitScriptAsAdmin(g_AutoStartScriptPath, "-KillProgram")
}

ShowToolTip()
{
    global g_iToolTipShowTime
    static iElapsedTime := 0
    iTimeLeft := (g_iToolTipShowTime - iElapsedTime) // 1000
    ToolTip, Press ESC to cancel autostart: %iTimeLeft% sec., 0, 0
    iElapsedTime += 1000
    if (iElapsedTime > g_iToolTipShowTime)
        ToolTip
    else
        SetTimer, ShowToolTip, -1000
}

;-------------------------------------------------------------------------------
^!+h:: ;Hibernate
    ; AutoHotkey [Shutdown] help:
    ; Parameter #1: Pass 1 instead of 0 to hibernate rather than suspend.
    ; Parameter #2: Pass 1 instead of 0 to suspend immediately rather than asking each application for permission.
    ; Parameter #3: Pass 1 instead of 0 to disable all wake events.
    DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
Return
^!+l:: ;Logoff
    MsgBox, % 4 + 256,, Log off?
    IfMsgBox, Yes
        Shutdown, 0 ;Logoff
Return
^!+r:: Shutdown, 6 ;Reboot
^!+s:: Shutdown, 1 ;Shutdown
;-------------------------------------------------------------------------------
^#!x:: ;Ctrl + Win + Alt + X close "AutoStart" programs
    CloseAutoStartPrograms()
Return
;-------------------------------------------------------------------------------
#!x:: ;Win + Alt + X close all scripts and NOT exit
    CloseAllScripts()
Return
;-------------------------------------------------------------------------------
#!z:: ;Win + Alt + Z reload all scripts
    CloseAllScripts()
    ;This not work, because we already with admin rights here!
    ; Reload_AsAdmin("/restart -SkipDelay")
    ;Simulate Reload command by running this script again and exit.
    ; Run, "%A_AhkPath%" /force "%A_ScriptFullPath%" /restart -SkipDelay
    Run, "%A_ScriptFullPath%" /restart -SkipDelay
ExitApp
;-------------------------------------------------------------------------------
