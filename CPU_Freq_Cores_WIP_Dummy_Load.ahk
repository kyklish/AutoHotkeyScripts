#SingleInstance, Force

code := "
(LTrim
    #NoTrayIcon
    #Persistent
    SetBatchLines, -1
    while (true)
{}
)"

w::
    DetectHiddenWindows On
    DummyLoadPID := ExecScript(code, false)
    Sleep, 10000
    WinClose, ahk_pid %DummyLoadPID%
return

!x::ExitApp
!z::Reload
