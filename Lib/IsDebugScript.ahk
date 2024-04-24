; if (!IsDebugScript()) ; Example:
;     Reload_AsAdmin()  ; On debugging reload script will break it, don't reload

IsDebugScript()
{
    FullCmdLine := DllCall("GetCommandLine", "Str")
    if(RegExMatch(FullCmdLine, "i)/debug"))
        Return true
    else
        Return false
}
