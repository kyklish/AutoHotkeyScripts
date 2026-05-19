#NoEnv
#NoTrayIcon
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; Suspend / Resume process with active window. Hide / Show window.
; Visible window with suspended process became unusable and breaks Windows hotkey
;   [Ctrl+D]: minimize windows but not restore them afterwards. Hiding window
;   will fix this.

iPID := 0 ; System Idle Process has PID 0, does not have window

; [PsSuspend64.exe] set working directory otherwise app will not execute
sPsSuspendCmd := "CD /D ""%SOFT%\NirLauncher\Sysinternals"" & PsSuspend64.exe"

; A comma-separated list of processes' names that be excluded from suspending
; Any spaces or tabs around the delimiting commas are significant, meaning that
;   they are part of the match string.
; Example: "app1.exe,app2.exe" [NO SPACES OR TABS]!!!
sBlackList := "Code.exe"

OnExit("ExitFunc")

; This is workaround for AHK++ formatter that don't recognize [Pause] as label.
; And it makes automatic hotkey sync with ExitFunc().
Hotkey, Pause, SuspendResumeApp
Return

SuspendResumeApp:
    If (iPID) {
        sResult := Resume(sProcessName)
        ; Counterpart for [WinHide], look comments below why its commented out
        ; WinShow, ahk_pid %iPID%

        ; Counterpart for [WinMinimize]
        WinRestore, ahk_pid %iPID%

        WinActivate, ahk_pid %iPID%
        Gosub, ShowToolTip
        iPID := 0
    }
    Else {
        WinGet, iPID, PID, A ; A (Active Window)
        WinGet, sProcessName, ProcessName, ahk_pid %iPID%
        WinGet, sProcessPath, ProcessPath, ahk_pid %iPID%
        WinGetTitle, sTitle, ahk_pid %iPID%
        If sProcessName in %sBlackList%
        {
            sResult := "PROCESS IS EXCLUDED`n`n"
            iPID := 0
        }
        Else
            If (RegExMatch(sProcessPath, "i)^C:")) { ; i) Case-Insensitive
                sResult := "SKIPPING ALL PROCESSES FROM DISK [C:]`n`n"
                iPID := 0
            } Else {
                ; [WinHide] does not hide intensive CPU apps, needs workaround:
                ;   minimize/restore all apps with [Win+D] OS hotkey.
                ; WinHide, ahk_pid %iPID%
                ; Send, #d ; Minimize all apps
                ; Sleep, 100
                ; Send, #d ;  Restore all apps

                ; This works fine now
                WinMinimize, ahk_pid %iPID%

                sResult := Suspend(sProcessName)
            }
        Gosub, ShowToolTip
    }
Return

ShowToolTip:
    ToolTip(sResult "" sProcessName "`n" sProcessPath "`n" sTitle, 3000, , 0, 0)
Return

ExitFunc()
{
    global iPID
    If (iPID)
        Gosub, SuspendResumeApp
}

Resume(sProcessName_or_iPID)
{
    global sPsSuspendCmd
    Return RunWaitCMD_Hide(sPsSuspendCmd " -r """ sProcessName_or_iPID """")
}

Suspend(sProcessName_or_iPID)
{
    global sPsSuspendCmd
    Return RunWaitCMD_Hide(sPsSuspendCmd " """ sProcessName_or_iPID """")
}
