#Include <_COMMON_SETTINGS_>

;!!!!!!!!!!!!!!!!!!!!!!
;номера форм ввода TRxSpinEditX могут менятся после переустановки и перезагрузки винды

;WinHide -> WinShow
;WinMinimize -> WinRestore
;WinMaximize -> WinRestore
;but you can use in cross way :)

CoordMode, Pixel, Client

delayBeforeHideWindow := 2000

;-------------------------------------------------------------------------------------
#IfWinExist, SpeedFan
+^F5:: ;CPU_Fan_On
{
	WinRestore ;or WinShow
	WinActivate
	WinWaitActive
	ImageSearch, , , 295, 85, 325, 115, %A_ScriptDir%\SpeedFanCheckedBox.png
	if (ErrorLevel = 2)
		MsgBox, ImageSearch - Fail to open the image file`nOr a badly formatted option.
	else if (ErrorLevel = 1) ;Didn't find image in the specified region
		SoundBeepTwice()
	else {
		Control, Check, , TJvXPCheckbox1 ;UnCheck не работает для SpeedFan!!! только Check
		if (ErrorLevel)
			MsgBox, Can't toggle "TJvXPCheckbox1".
		else {
			Loop, 10 { ;ведем поиск первого видимого поля для ввода скорости вентилятора, ограничиваемся 10-ю первыми
				ControlGet, isVisible, Visible, , TRxSpinEdit%A_Index%
				if (ErrorLevel) {
					MsgBox, ControlGet - No such input field "TRxSpinEdit%A_Index%".
					WinHide
					return
				}
				if (isVisible) {
					index := A_Index
					break
				}
			}
			if (!isVisible)
				MsgBox, Didn't find any visible input field "TRxSpinEditXX".
			else {		
				;Либо ControlFocus + Send или просто ControlSend ;ControlSetText не работает для SpeedFan!!!
				ControlSend, TRxSpinEdit%index%, {End}{Backspace 3}{Numpad1}{Numpad0 2}
				Sleep, 3500
				ControlSend, TRxSpinEdit%index%, {Left}{Backspace 2}{Numpad3}
				Sleep, %delayBeforeHideWindow%
			}
		}
	}
	WinHide
}
return
;-------------------------------------------------------------------------------------
+^F6:: ;CPU_Fan_Off
{
	WinRestore ;or WinShow
	WinActivate
	WinWaitActive
		;хотел сделать проверку чекбокса правильно, но она не работает :(, вместо этого проверяем по картинке чекбокса
		;ControlGet, IsAutomaticFanSpeedEnabled, Checked, , TJvXPCheckbox1 ;не работает для SpeedFan!!!
	ImageSearch, , , 295, 85, 325, 115, %A_ScriptDir%\SpeedFanUnCheckedBox.png
	if (ErrorLevel = 2)
		MsgBox, ImageSearch - Fail to open the image file`nOr a badly formatted option.
	else if (ErrorLevel = 1)
		SoundBeepTwice() ;Didn't find image in the specified region
	else {
		Control, Check, , TJvXPCheckbox1 ;UnCheck не работает для SpeedFan!!! только Check
		if (ErrorLevel)
			MsgBox, Can't toggle "TJvXPCheckbox1".
		else 
			Sleep, %delayBeforeHideWindow%
	}
	WinHide
}
return
#IfWinExist
;-------------------------------------------------------------------------------------