/*
if not A_IsAdmin
{
    Run, *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" ;покажет UAC запрос
    ExitApp
}
*/

Reload_AsAdmin(sParams := "")
{
    if (!A_IsAdmin) {
        Run_ScriptAsAdmin(A_ScriptFullPath, sParams)
        ExitApp
    }
}

Reload_AsUser(sParams := "")
{
    if (A_IsAdmin) {
        Run_ScriptAsUser(A_ScriptFullPath, sParams)
        ExitApp
    }
}
