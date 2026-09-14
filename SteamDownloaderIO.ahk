#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

SendMode, Event
SetKeyDelay, 50, 10
GroupAdd, Browser, ahk_exe msedge.exe
GroupAdd, Browser, ahk_exe opera.exe

#IfWinActive ahk_group Browser
    CapsLock::
        Send, ^{vk4C} ; Ctrl+L
        sClipboardPrev := A_Clipboard ; Backup original content
        A_Clipboard := "" ; Empty the clipboard for ClipWait command!
        Send, ^{vk43} ; Ctrl+C
        ClipWait, 2
        If (ErrorLevel) {
            MsgBox, The attempt to copy text onto the clipboard failed.
            Return
        }
        sCopiedText := Trim(A_Clipboard) ; URL
        Send, ^{vk54} ; Ctrl+T - Open New Tab
        ; Fastest method to enter URL is paste from clipboard.
        ; SendInput works very slow in URL input field, don't know why.
        Send, ^{vk4C} ; Ctrl+L
        A_Clipboard := "https://steamworkshopdownloader.io/"
        Send, ^{vk56} ; Ctrl+V
        Send, {Enter}
        Sleep, 1000 ; Wait for SteamWorkshopDownloader page loading.
        A_Clipboard := sCopiedText ; URL
        Send, {Tab 8}^{vk56}{Enter} ; Ctrl+V
        A_Clipboard := sClipboardPrev ; Restore original content
    Return
#If

!Z::Reload
!X::ExitApp

!F1:: ShowHelpWindow("
(
CapsLock = Open in new tab prepared URL for [SteamWorkshopDownloader.IO]
)")
