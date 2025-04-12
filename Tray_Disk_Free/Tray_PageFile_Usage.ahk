#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

g_iPeriod := 10000 ; Update interval
g_sPageFileName := PageFileName()

SetTimer, TrayIcon, % g_iPeriod
TrayIcon()

PageFileName() {
    ; DO NOT USE DOUBLE QUOTES INSIDE [FOR] PARENTHESIS FOR SwapAdd COMMAND
    ; FOR /F "usebackq tokens=2 delims='" %S IN (`%SOFT%\ImDisk\Tools\swapadd.exe`) DO @ECHO %S
    sName := RunWaitCMD("FOR /F ""usebackq tokens=2 delims='"" %S IN (``%SOFT%\ImDisk\Tools\swapadd.exe``) DO @ECHO %S")
    Return Trim(sName, " `t`r`n")
}

; Result in MB
PageFileSize() {
    ; DO NOT USE DOUBLE QUOTES INSIDE [FOR] PARENTHESIS FOR SwapAdd COMMAND
    ; FOR /F "usebackq tokens=4" %S IN (`%SOFT%\ImDisk\Tools\swapadd.exe ^| FIND /I "SwapFile"`) DO @ECHO %S
    iSize := RunWaitCMD("FOR /F ""usebackq tokens=4"" %S IN (``%SOFT%\ImDisk\Tools\swapadd.exe ^| FIND /I ""SwapFile""``) DO @ECHO %S")
    Return Trim(iSize, " `t`r`n")
}

; Result in %
PageFileUsage() {
    ; DO NOT USE DOUBLE QUOTES INSIDE [FOR] PARENTHESIS FOR SwapAdd COMMAND
    ; FOR /F "usebackq tokens=2 delims=(%" %S IN (`%SOFT%\ImDisk\Tools\swapadd.exe`) DO @ECHO %S
    iUsage := RunWaitCMD("FOR /F ""usebackq tokens=2 delims=(%"" %S IN (``%SOFT%\ImDisk\Tools\swapadd.exe``) DO @ECHO %S")
    Return Trim(iUsage, " `t`r`n")
}

TrayIcon() {
    global g_sPageFileName
    static iSizePrev := ""
    static iUsagePrev := ""

    iUsage := PageFileUsage()
    If (iUsage != iUsagePrev) {
        iUsagePrev := iUsage
        ; 100% does not fit into ICON, changed into 99%.
        iUsage := (iUsage == 100) ? 99 : iUsage
        sUsage := Format("{:02}", iUsage) ; Two digits with zero padding.
        Menu, Tray, Icon, ICONS\%sUsage%.ico
    }

    iSize := PageFileSize()
    If (iSize != iSizePrev) {
        iSizePrev := iSize
        Menu, Tray, Tip, % A_ScriptName "`n" g_sPageFileName "`nSize: " iSize "MB`nUsage: " iUsage "%"
    }
}

RunWaitCMD(commands) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObjCreate("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(A_ComSpec " /Q /K echo off")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}
