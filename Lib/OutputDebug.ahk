;One example of a debugger is DebugView, which is free and available at www.sysinternals.com.
OutputDebug(sText := "DBGVIEWCLEAR")
{
    global IsDebug
    FullCmdLine := DllCall("GetCommandLine", "Str")
    IsDebugScript := RegExMatch(FullCmdLine, "i)/debug")
    if (IsDebug OR IsDebugScript)
        OutputDebug, %sText%
}
