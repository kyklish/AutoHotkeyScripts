#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

GroupAdd, Browser, ahk_exe msedge.exe
GroupAdd, Browser, ahk_exe opera.exe

; [SteamCMD] launched from shortcut will have just it's name in windows's title
; [SteamCMD] launched by [Run] command will have full path in windows's title
SetTitleMatchMode, 2 ; Search WinTitle anywhere inside window's title

sSteamCmdFullPath := "%SOFT%\SteamCMD\SteamCMD.exe"
sSteamCmdFullPath := ExpandEnvVars(sSteamCmdFullPath)
sSteamCmdDir := ""
SplitPath, sSteamCmdFullPath, , sSteamCmdDir

If (!WinExist("SteamCMD")) {
    Run, %sSteamCmdFullPath%, %sSteamCmdDir%
    WinWait, SteamCMD, , 3
    If (ErrorLevel)
        MsgBox, WinWait timed out.
    Else
        LoginSteamCMD()
}

OnExit("ExitSteamCMD")

#IfWinActive ahk_group Browser
    CapsLock::SteamWorkshopDownloader(784150) ; Workers & Resources: Soviet Republic
#If

!L::LoginSteamCMD()

CleanUpSteamCMD()
{
    ; Cleaning SteamCMD Download History MANUALLY:
    ; 1. Delete your account directory:
    ;     .\steamcmd\userdata\<your account name>
    ; 2. Delete all files and directories in:
    ;     .\steamcmd\steamapps\workshop

    global sSteamCmdDir
    ; FileRemoveDir, %sSteamCmdDir%\SteamApps\Workshop, 1
    ; FileRemoveDir, %sSteamCmdDir%\UserData, 1
    FileRecycle, %sSteamCmdDir%\SteamApps\Workshop
    FileRecycle, %sSteamCmdDir%\UserData
}

CloseSteamCMD()
{
    If (WinExist("SteamCMD")) {
        WinActivate
        Send, exit{Enter}
    }
}

ExitSteamCMD(ExitReason, ExitCode)
{
    If ExitReason not in Reload
    {
        CloseSteamCMD()
        WinWaitClose, SteamCMD
        CleanUpSteamCMD()
    }
}

LoginSteamCMD()
{
    If (WinExist("SteamCMD")) {
        WinActivate
        WinMove, 0, 0,
        Send, login anonymous{Enter}
        WinActivate, ahk_group Browser
    } Else
        MsgBox % "[SteamCMD] window not found."
}

SteamWorkshopDownloader(iAppID)
{
    If (!RegExMatch(iAppID, "\d{6}")) {
        MsgBox % "This is not [Steam App ID] number: " iAppID
        Return
    }

    SendEvent, ^{vk4C} ; Ctrl+L
    sClipboardPrev := A_Clipboard ; Backup original content
    A_Clipboard := "" ; Empty the clipboard for ClipWait command!
    SendEvent, ^{vk43} ; Ctrl+C
    ClipWait, 2
    If (ErrorLevel) {
        MsgBox % "The attempt to copy text onto the clipboard failed."
        Return
    }

    sCopiedText := Trim(A_Clipboard) ; URL
    RegExMatch(sCopiedText, "\d{10}$", iSteamWorkshopID)

    If (!iSteamWorkshopID) {
        MsgBox % "Can't find 10-digit [Steam Workshop ID] number at the end of the URL: " sCopiedText
        Return
    }

    SendEvent, ^w ; Close browser tab
    WinActivate, SteamCMD
    Send, workshop_download_item %iAppID% %iSteamWorkshopID%{Enter}
    WinActivate, Total Commander
    A_Clipboard := sClipboardPrev ; Restore original content
}

!Z::Reload
!X::ExitApp

!F1:: ShowHelpWindow("
(
On launch script will do:
    - run [SteamCMD]
    - login in [SteamCMD]
    - move window to top-left corner
    - activate browser window
On exit script will do:
    - exit [SteamCMD]
    - clean up history in [SteamCMD] folder

Press hotkey for chosen game, script will do:
    - copy [Steam Workshop ID] number from URL
    - close current tab in browser
    - paste command to [SteamCMD]
    - activate [Total Commander]

      !L = [SteamCMD] anonymous login
CapsLock = [Workers and Resources: Soviet Republic]
)")
