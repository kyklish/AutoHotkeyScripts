; Expand paths with environment variables (%SystemRoot% ==> C:\Windows)
ExpandEnvVars(sPath)
{
    VarSetCapacity(sDest, 2000)
    DllCall("ExpandEnvironmentStrings", "str", sPath, "str", sDest, int, 1999, "Cdecl int")
    return sDest
}
