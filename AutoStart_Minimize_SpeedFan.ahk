#Include <_COMMON_SETTINGS_>

DetectHiddenWindows, Off

ToolTip("wait SpeedFan window...")

Loop {
    if (WinExist("ahk_exe SpeedFan.exe"))
        Break
    else
        Sleep, 1000
}

; WinMinimize, WinHide = Leaves app icon in task bar, using ControlClick
ControlClick, Minimize
ToolTip("SpeedFan minimized!")
Sleep, 1000

ToolTip(sMessage) {
    ToolTip, %A_ScriptName%: %sMessage%, 0, 0
}
