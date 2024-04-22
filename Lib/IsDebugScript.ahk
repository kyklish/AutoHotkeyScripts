IsDebugScript()
{
    FullCmdLine := DllCall("GetCommandLine", "Str")
    if(RegExMatch(FullCmdLine, "i)/debug"))
        Return true
    else
        Return false
}
