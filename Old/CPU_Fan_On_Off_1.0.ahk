#Include <_COMMON_SETTINGS_>

;-------------------------------------------------------------------------------------
+^F5:: ;CPU_Fan_On
CoordMode, Pixel, Screen
ImageSearch, FoundX, FoundY, 0, 0, 1920, 1080, %A_ScriptDir%\SpeedFanIconSearch.png
If ErrorLevel = 0
{
	Click, %FoundX%, %FoundY% Left, 2
	Sleep, 400
	WinActivate, SpeedFan
	Sleep, 333
	IfWinActive, SpeedFan
	{
		Sleep, 300
		CoordMode, Pixel, Window
		ImageSearch, FoundX, FoundY, 300, 110, 330, 140, %A_ScriptDir%\SpeedFanCheckedBox.png
		If ErrorLevel = 0
		{
			ControlClick, TJvXPCheckbox1, SpeedFan,, Left, 1,  x8 y14 NA
			Sleep, 100
			ControlClick, TRxSpinEdit10, SpeedFan,, Left, 1,  x23 y10 NA
			Sleep, 100
			Send, {End}
			Sleep, 100
			Send, {Backspace 3}
			Sleep, 100
			Send, {Numpad9}
			Sleep, 100
			Send, {Numpad0}
			Sleep, 4000
			Send, {Left}
			Sleep, 100
			Send, {Backspace}
			Sleep, 100
			Send, {Numpad3}
			Sleep, 3000
		}
		else
			SoundBeepTwice()
		WinMinimizeAll
		Sleep, 333
	}
}
else
	SoundBeepTwice()
Return
;-------------------------------------------------------------------------------------
+^F6:: ;CPU_Fan_Off
CoordMode, Pixel, Screen
ImageSearch, FoundX, FoundY, 0, 0, 1920, 1080, %A_ScriptDir%\SpeedFanIconSearch.png
If ErrorLevel = 0
{
	Click, %FoundX%, %FoundY% Left, 2
	Sleep, 400
	WinActivate, SpeedFan
	Sleep, 333
	IfWinActive, SpeedFan
	{
		ControlClick, TJvXPCheckbox1, SpeedFan, ahk_class TForm1, Left, 1, NA
		Sleep, 2000
		WinMinimize
		;WinMinimizeAll
		Sleep, 333
	}
	else
		SoundBeepTwice()
}
else
	SoundBeepTwice()
Return