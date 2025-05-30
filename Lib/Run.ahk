﻿; While the RunAs feature is in effect, Run and RunWait will not able to launch documents,
; URLs, or system verbs. In other words, the file to be launched must be an executable file.

; The "Secondary Logon" service must be set to manual or automatic for this command to work
; (the OS should automatically start it upon demand if set to manual).

; Built-in Administrator OR Task Scheduler variants:
; 1. Built-in Administrator account (enable it)
;    "_AutoHotkey_.ahk" launched by shortcut from Start Menu (not elevated)
;    Elevate on demand with Administrator account (RunAs command)
;    Elevated programs saves their settings in Administrator account (BAD)
;    Can drop elevation, can elevate (GOOD)
; 2. Task Scheduler
;    "_AutoHotkey_.ahk" launched by task (elevated)
;    Drop elevation on demand with AdvancedRun from NirSoft
;    Programs saves their settings in user account (GOOD)
;    Can drop elevation, can't elevate (BAD)

; Elevated RunAs never drops elevation, when you run app under same account!
;   Script(Administrator [Elevated]) ==> App(User [NOT Elevated]) is OK
;   Script(User [Elevated]) ==> App(User [Elevated]) NOT OK
; SOLUTION: use AdvancedRun from NirSoft to drop elevation.
;   Script(User [Elevated]) ==> AdvancedRun(User [Elevated]) ==> App(User [NOT Elevated]) is OK

; AdvancedRun - Run Mode:
;   Run .EXE File
;   ShellExecute - Open the specified file, folder, or URL with the default program
;   Command Prompt - Execute command or batch file of Windows Command Prompt (cmd.exe)
;   PowerShell Command - Execute the specified PowerShell Command
;   PowerShell Script File - Run the specified PowerShell script (.ps1 file)


RunAs(bAdmin, sExePath, sParams := "", sWorkingDir := "", sWinOptions := "", bWait := false)
{
    ;=============================== CONFIG ====================================

    ; bDebug := true
    ; IF TRUE  ==> Set login and password in "Credentials.csv": Admin and User
    ; IF FALSE ==> Set login and password in "Credentials.csv": Admin and User (real password not needed here!)
    bBuiltInAdmin := false
    sAdvancedRun := A_ScriptDir "\AdvancedRun.exe"

    ;===========================================================================

    oCrd := GetCredentials(bAdmin)
    ; Expand paths with environement variables (%SystemRoot% ==> C:\Windows)
    sExePath := ExpandEnvVars(sExePath)
    sParams := ExpandEnvVars(sParams)
    if (bBuiltInAdmin) {  ; Built-in Administrator variant
        RunAs, % oCrd.sLogin, % oCrd.sPassword
        if (bWait)
            RunWait, "%sExePath%" %sParams%, %sWorkingDir%, %sWinOptions%, iPID
        else
            Run, "%sExePath%" %sParams%, %sWorkingDir%, %sWinOptions%, iPID
        RunAs ; revert RunAs value
    } else {                ; Task Scheduler variant
        if (bAdmin) {
            if (!A_IsAdmin) {
                TODO_MsgBox1(A_ThisFunc)
                ExitApp
            } else
                ; We can't elevate, so this is valid only when caller is elevated too
                if (bWait)
                    RunWait, "%sExePath%" %sParams%, %sWorkingDir%, %sWinOptions%, iPID
                else
                    Run, "%sExePath%" %sParams%, %sWorkingDir%, %sWinOptions%, iPID
        } else {            ; Use AdvancedRun to drop elevation
            if (bWait) {
                TODO_MsgBox2(A_ThisFunc)
                ExitApp
            }
            if (!FileExist(sAdvancedRun)) {
                MsgBox_Err(A_ThisFunc, "AdvancedRun not found.`n`n" sAdvancedRun)
                return
            }
            SplitPath, sExePath,,, sExtension
            if (sExtension = "exe") {
                ; Look [AdvancedRun.chm] for help
                ; /RunAs 9 == Run process as "Another logged-in user" (must have at least one running process)
                ; /RunAs 9 == No password needed!
                Switch sWinOptions {
                    Case "Hide": iWindowState := 0
                    Case "Min" : iWindowState := 2
                    Case "Max" : iWindowState := 3
                    Default    : iWindowState := 1
                }
                sWindowState := "/WindowState " iWindowState
                sCfg := "/Clear " sWindowState " /ParseVarCommandLine 1 /UseSearchPath 1 /RunAsUserName """ oCrd.sLogin """ /RunAs 9 /Run"
                ; If you want to specify a value contains double quotes (""),
                ;   you should enclose the value with single quotes ('').
                ;   Example: /CommandLine '"my first param" "my second param"'
                Run, "%sAdvancedRun%" %sCfg% /EXEFilename "%sExePath%" /CommandLine '%sParams%' /StartDirectory "%sWorkingDir%"
                if (bDebug)
                    MsgBox "%sAdvancedRun%" %sCfg% /EXEFilename "%sExePath%" /CommandLine '%sParams%' /StartDirectory "%sWorkingDir%"
            } else
                TODO_MsgBox_AdvRunErr(A_ThisFunc, sExePath)
        }
    }

    ; TODO do I need this???
    ; if (sWinOptions != "Min") {
    ;     WinWait, ahk_exe %sExePath%, , 1 ;0 = 0.5 seconds timeout
    ;     WinActivate, ahk_exe %sExePath%
    ; }

    return iPID
}

Run_As(bAdmin, sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
    return RunAs(bAdmin, sExePath, sParams, sWorkingDir, sWinOptions)
}

Run_AsAdmin(sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
    return RunAs(true, sExePath, sParams, sWorkingDir, sWinOptions)
}

Run_AsUser(sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
    return RunAs(false, sExePath, sParams, sWorkingDir, sWinOptions)
}

; Unused
/*
Run_AsUserToggle(sExePath, sParams := "", sWorkingDir := "", sWinOptions := "", iClose := 1)
{
    crd := GetCredentials(false)
    SplitPath, sExePath, sFileName
    Process, Exist, %sFileName%
    if (!ErrorLevel) ;if process not exist
        RunAs(crd.sLogin, crd.sPassword, sExePath, sParams, sWorkingDir, sWinOptions)
    else if (iClose == 1)
        PostMessage, 0x112, 0xF060,,, ahk_exe %sFileName% ;0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE - Alt+F4 or clicking the window's close button in it's title bar
    else if (iClose == 2)
        WinClose, ahk_exe %sFileName% ;WM_CLOSE - forceful method of closing
    else if (iClose == 3)
        WinKill, ahk_exe %sFileName% ;terminating process
    else
        throw Exception("Wrong parameter iClose", , iClose)
}
*/

;-------------------------------------------------------------------------------

RunScriptAs(bAdmin, sScriptFullPath, sParams := "", bWait := false)
{
    ; Read comment on top of the script! (We need A_AhkPath here!!!)
    sParams = "%sScriptFullPath%" %sParams%
    ; sParams := """" sScriptFullPath """ " sParams
    return RunAs(bAdmin, A_AhkPath, sParams, , , bWait)
}

Run_ScriptAsAdmin(sScriptFullPath, sParams := "")
{
    return RunScriptAs(true, sScriptFullPath, sParams)
}

Run_ScriptAsUser(sScriptFullPath, sParams := "")
{
    return RunScriptAs(false, sScriptFullPath, sParams)
}

;-------------------------------------------------------------------------------

Run_WaitScriptAs(bAdmin, sScriptFullPath, sParams := "")
{
    return RunScriptAs(bAdmin, sScriptFullPath, sParams, true)
}

Run_WaitScriptAsAdmin(sScriptFullPath, sParams := "")
{
    return RunScriptAs(true, sScriptFullPath, sParams, true)
}

Run_WaitScriptAsUser(sScriptFullPath, sParams := "")
{
    return RunScriptAs(false, sScriptFullPath, sParams, true)
}

;-------------------------------------------------------------------------------

MsgBox_Err(sThisFunc, sText) {
    MsgBox,, % A_ScriptName " ==> .\Lib\Run.ahk", % sThisFunc "(...)`n`n" sText
}

TODO_MsgBox1(sThisFunc) {
    sText := "
(
Built-in Administrator account disabled!
Can't elevate process.
Exit script.

Solution (TODO):
    1. Run from elevated script.
    2. Send window message to [_Autohotkey_.ahk]. (explicit exploit???)
    3. Make /RunOnce task in Task Scheduler for elevated rights:
        - https://ss64.com/nt/schtasks.html
    4. Disable UAC.
)"
    MsgBox_Err(sThisFunc, sText)
}

TODO_MsgBox2(sThisFunc) {
    sText := "
(
Built-in Administrator account disabled!
Can't drop elevation with RunWait command.
Exit script.
)"
    MsgBox_Err(sThisFunc, sText)
}

TODO_MsgBox_AdvRunErr(sThisFunc, sExePath) {
    sText := "
(
AdvancedRun expects .EXE file.

Run Mode:
    Run .EXE File
    ShellExecute - Open the specified file, folder, or URL with the default program
    Command Prompt - Execute command or batch file of Windows Command Prompt (cmd.exe)
    PowerShell Command - Execute the specified PowerShell Command
    PowerShell Script File - Run the specified PowerShell script (.ps1 file)

Create modified function to set different [Run Mode]

File passed:
)"
    sText := sText " " sExePath
    MsgBox_Err(sThisFunc, sText)
}
