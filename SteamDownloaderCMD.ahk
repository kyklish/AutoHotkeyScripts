#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

GroupAdd, Browser, ahk_exe msedge.exe
GroupAdd, Browser, ahk_exe opera.exe

OnExit("CloseSteamCMD")

#IfWinActive ahk_group Browser
    CapsLock::SteamWorkshopDownloader(784150) ; Workers & Resources: Soviet Republic
#If

!L::
    If (WinExist("SteamCMD")) {
        WinActivate
        WinMove, 0, 0,
        Send, login anonymous{Enter}
        WinActivate, ahk_group Browser
    } Else
        MsgBox % "[SteamCMD] window not found."
Return

CloseSteamCMD(ExitReason, ExitCode)
{
    If ExitReason not in Reload
    {
        If (WinExist("SteamCMD")) {
            WinActivate
            Send, exit{Enter}
        }
    }
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
Launch [SteamCMD]. Press hotkey to login anonymously. Script will do:
    - login in [SteamCMD]
    - move window to top-left corner
    - activate browser window
On exit script closes [SteamCMD].

Press hotkey for chosen game. Script will do:
    - copy [Steam Workshop ID] number from URL
    - close current tab in browser
    - paste command to [SteamCMD]
    - activate [Total Commander]

      !L = [SteamCMD] anonymous login
CapsLock = [Workers and Resources: Soviet Republic]

Cleaning SteamCMD Download History MANUALLY:
    1. Delete your account directory:
        .\steamcmd\userdata\<your account name>
    2. Delete all files and directories in:
        .\steamcmd\steamapps\workshop
)")
