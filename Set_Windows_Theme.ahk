#NoEnv

if (A_Args.Length() != 1) {
	MsgBox % "This script requires 1 parameter: path to *.theme file"
	ExitApp
}
if (A_IsAdmin) {
	MsgBox % "Run only as regular user, NOT admin!"
	ExitApp
}

SetWindowsTheme(A_Args[1])


SetWindowsTheme(sTheme)
{
	if (!A_IsAdmin) { ; !!!!Run only as regular user!!!!
		RunWaitCMD("rundll32.exe %SystemRoot%\system32\shell32.dll,Control_RunDLL %SystemRoot%\system32\desk.cpl desk,@Themes /Action:OpenTheme /file:""" sTheme """")
		WinWaitActive, Personalization ahk_class CabinetWClass
		WinClose
	}
}
