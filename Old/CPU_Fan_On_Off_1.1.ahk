#Include <_COMMON_SETTINGS_>

;!!!!!!!!!!!!!!!!!!!!!!
;номера форм ввода TRxSpinEditX могут менятся после переустановки и перезагрузки винды

;WinHide -> WinShow
;WinMinimize -> WinRestore
;WinMaximize -> WinRestore
;but you can use in cross way :)

delayBeforeHideWindow := 500
;-------------------------------------------------------------------------------------
#IfWinExist, SpeedFan
+^F5:: ;CPU_Fan_On
	WinRestore ;or WinShow
	WinActivate
	WinWaitActive
	CoordMode, Pixel, Client
	ImageSearch, , , 295, 85, 325, 115, %A_ScriptDir%\SpeedFanCheckedBox.png
	if (ErrorLevel = 0)
	{
		ControlClick, TJvXPCheckbox1, , , Left, 1, NA
		ControlGet, IsVisible, Visible, , TRxSpinEdit6 ;!!!!!номера форм ввода TRxSpinEditX могут менятся после переустановки и перезагрузки винды
		if IsVisible
			ControlClick, TRxSpinEdit6, , , Left, 1, NA
		else
			ControlClick, TRxSpinEdit10, , , Left, 1, NA
		Send, {End}{Backspace 3}{Numpad1}{Numpad0 2}
		Sleep, 3000
		Send, {Left}{Backspace 2}{Numpad3}
	}
	else
		SoundBeepTwice()
	Sleep, %delayBeforeHideWindow%
	WinHide
return
;-------------------------------------------------------------------------------------
+^F6:: ;CPU_Fan_Off
	WinRestore ;or WinShow
	WinActivate
	WinWaitActive
		;хотел сделать проверку чекбокса правильно, но она не работает :(
		;вместо этого проверяем по картинке чекбокса
		;ControlGet, IsAutomaticFanSpeedEnabled, Checked, , TJvXPCheckbox1
	CoordMode, Pixel, Client
	ImageSearch, , , 295, 85, 325, 115, %A_ScriptDir%\SpeedFanUnCheckedBox.png
	if (ErrorLevel = 0)
		ControlClick, TJvXPCheckbox1, , , Left, 1, NA
	else
		SoundBeepTwice()
	Sleep, %delayBeforeHideWindow%
	WinHide
return
#IfWinExist
;-------------------------------------------------------------------------------------