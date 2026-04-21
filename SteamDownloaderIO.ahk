#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

SendMode, Event
SetKeyDelay, 50, 10
GroupAdd, Browser, ahk_exe msedge.exe
GroupAdd, Browser, ahk_exe opera.exe

#IfWinActive ahk_group Browser
    F4::
        Send, ^{vk4C} ; Ctrl+L
        sClipboardPrev := Clipboard ; Backup original content
        Clipboard := "" ; Empty the clipboard for ClipWait command!
        Send, ^{vk43} ; Ctrl+C
        ClipWait, 2
        If (ErrorLevel) {
            MsgBox, The attempt to copy text onto the clipboard failed.
            Return
        }
        sCopiedText := Trim(Clipboard) ; URL
        Send, ^{vk54} ; Ctrl+T - Open New Tab
        ; Fastest method to enter URL is paste from clipboard.
        ; SendInput works very slow in URL input field, don't know why.
        Send, ^{vk4C} ; Ctrl+L
        Clipboard := "https://steamworkshopdownloader.io/"
        Send, ^{vk56} ; Ctrl+V
        Send, {Enter}
        Sleep, 1000 ; Wait for SteamWorkshopDownloader page loading.
        Clipboard := sCopiedText ; URL
        Send, {Tab 8}^{vk56}{Enter} ; Ctrl+V
        Clipboard := sClipboardPrev ; Restore original content
    Return
#If

!Z::Reload
!X::ExitApp
