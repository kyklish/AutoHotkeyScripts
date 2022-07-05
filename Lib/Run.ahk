RunAs(sLogin, sPassword, sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
	RunAs, %sLogin%, %sPassword%
	Run, "%sExePath%" %sParams%, %sWorkingDir%, %sWinOptions%, iPID
	RunAs ; revert RunAs value
	
	WinWait, ahk_exe %sExePath%, , 1 ;0 = 0.5 seconds timeout
	WinActivate, ahk_exe %sExePath%
	return iPID
}


Run_As(bAdmin, sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
	crd := GetCredentials(bAdmin)
	return RunAs(crd.sLogin, crd.sPassword, sExePath, sParams, sWorkingDir, sWinOptions)
}


Run_AsAdmin(sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
	crd := GetCredentials(true)
	return RunAs(crd.sLogin, crd.sPassword, sExePath, sParams, sWorkingDir, sWinOptions)
}


Run_AsUser(sExePath, sParams := "", sWorkingDir := "", sWinOptions := "")
{
	crd := GetCredentials(false)
	return RunAs(crd.sLogin, crd.sPassword, sExePath, sParams, sWorkingDir, sWinOptions)
}


Run_AsUserToggle(sExePath, sParams := "", sWorkingDir := "", sWinOptions := "", iClose := 1)
{
	crd := GetCredentials(false)
	SplitPath, sExePath, sFileName
	Process, Exist, %sFileName%
	if (!ErrorLevel) ;if process not exist
		RunAs(crd.sLogin, crd.sPassword, sExePath, sParams, sWorkingDir, sWinOptions)
	else if (iClose == 1)
		PostMessage, 0x112, 0xF060,,, ahk_exe %sFileName% ;0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE - Alt+F4 or clicking the window's close button in it's title bar
	else if (iClose == 2)
		WinClose, ahk_exe %sFileName% ;WM_CLOSE - forceful method of closing
	else if (iClose == 3)
		WinKill, ahk_exe %sFileName% ;terminating process
	else
		throw Exception("Wrong parameter iClose", , iClose)
}
;-----------------------------------------------------------

RunScriptAs(sLogin, sPassword, sScriptFullPath, sParams := "")
{
	RunAs, %sLogin%, %sPassword%
	Run, "%A_AhkPath%" "%sScriptFullPath%" %sParams%, , , iPID
	RunAs
	return iPID
}


Run_ScriptAs(bAdmin, sScriptFullPath, sParams := "")
{
	crd := GetCredentials(bAdmin)
	return RunScriptAs(crd.sLogin, crd.sPassword, sScriptFullPath, sParams)
}


Run_ScriptAsAdmin(sScriptFullPath, sParams := "")
{
	crd := GetCredentials(true)
	return RunScriptAs(crd.sLogin, crd.sPassword, sScriptFullPath, sParams)
}


Run_ScriptAsUser(sScriptFullPath, sParams := "")
{
	crd := GetCredentials(false)
	return RunScriptAs(crd.sLogin, crd.sPassword, sScriptFullPath, sParams)
}

;-----------------------------------------------------------

RunWaitScriptAs(sLogin, sPassword, sScriptFullPath, sParams := "")
{
	RunAs, %sLogin%, %sPassword%
	RunWait, "%A_AhkPath%" "%sScriptFullPath%" %sParams%
	RunAs
	return ErrorLevel ;RunWait sets ErrorLevel to the program's exit code (a signed 32-bit integer).
}


Run_WaitScriptAs(bAdmin, sScriptFullPath, sParams := "")
{
	crd := GetCredentials(bAdmin)
	return RunWaitScriptAs(crd.sLogin, crd.sPassword, sScriptFullPath, sParams)
}


Run_WaitScriptAsAdmin(sScriptFullPath, sParams := "")
{
	crd := GetCredentials(true)
	return RunWaitScriptAs(crd.sLogin, crd.sPassword, sScriptFullPath, sParams)
}


Run_WaitScriptAsUser(sScriptFullPath, sParams := "")
{
	crd := GetCredentials(false)
	return RunWaitScriptAs(crd.sLogin, crd.sPassword, sScriptFullPath, sParams)
}
