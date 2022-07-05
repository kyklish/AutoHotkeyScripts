;!!!!!!!!!!! For normal work need: DetectHiddenWindows, On !!!!!!!!!!!! and #Persistent if no hotkeys or hotstrings

OSD(sText, iDisplayTime := 750, iNum := 10)
{
	#Persistent
	Progress, %iNum%:Hide Y600 W1000 b zh0 cwFFFFFF FM50 CT00BB00,, %sText%, AutoHotKeyProgressBar, Backlash BRK
	WinSet, TransColor, FFFFFF 255, AutoHotKeyProgressBar
	Progress, %iNum%:Show
	RmOSD := Func("RemoveOSD").Bind(iNum)
	SetTimer, %RmOSD%, -%iDisplayTime%
}

RemoveOSD(iNum)
{
	Progress, %iNum%:Off
}


; Original version
/*
OSD(sText, iDisplayTime := 750)
{
	#Persistent
	; BorderLess, no ProgressBar, font size 25, color text 009900
	Progress, Hide Y600 W1000 b zh0 cwFFFFFF FM50 CT00BB00,, %sText%, AutoHotKeyProgressBar, Backlash BRK
	WinSet, TransColor, FFFFFF 255, AutoHotKeyProgressBar
	Progress, Show
	SetTimer, RemoveOSD, -%iDisplayTime%
	Return
	
	RemoveOSD:
	Progress, Off
	Return
}
*/
