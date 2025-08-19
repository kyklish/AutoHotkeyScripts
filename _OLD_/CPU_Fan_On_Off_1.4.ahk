#Include <_COMMON_SETTINGS_>
Menu, Tray, Icon
;!!!!!!!!!!!!!!!!!!!!!!
;номера форм ввода TRxSpinEditX могут менятся после переустановки и перезагрузки винды

;WinHide -> WinShow
;WinMinimize -> WinRestore
;WinMaximize -> WinRestore
;but you can use in cross way :)

CoordMode, Pixel, Client
;SetControlDelay, 1000

delayBeforeHideWindow := 2000

WinUnHide()
{
	timeout := 1 ;seconds
	WinRestore ;or WinShow
	WinActivate
	WinWaitActive, , , %timeout%
	if (ErrorLevel)
		MsgBox,  WinWaitActive - command timed out in %timeout% seconds.
	return ErrorLevel
}

SearchImage(path)
{
	ImageSearch, , , 295, 85, 325, 115, %A_ScriptDir%\%path%
	if (ErrorLevel = 2)
		MsgBox, ImageSearch - Fail to open the image file "%A_ScriptDir%\%path%"`nOr a badly formatted option.
	else if (ErrorLevel = 1) ;Didn't find image in the specified region
		SoundBeepTwice()
	return ErrorLevel
}

ToggleCheckbox(controlName)
{
	; ControlClick, %controlName%, , , Left, 1, NA ; кликаем мышкой или чекаем непостредственно командой ниже
	Control, Check, , %controlName% ;UnCheck не работает для SpeedFan!!! только Check
	if (ErrorLevel)
		MsgBox, CheckBox - Can't toggle "%controlName%".
	return ErrorLevel
}

CheckVisibleControl(controlName, ByRef isVisible)
{
	ControlGet, isVisible, Visible, , %controlName%
	if (ErrorLevel)
		MsgBox, ControlGet - No such input field "%controlName%".
	return ErrorLevel
}

FindVisibleControl(controlName, ByRef index)
{
	Loop, 10 { ;ведем поиск первого видимого поля для ввода скорости вентилятора, ограничиваемся 10-ю первыми, 11-й уже выдает ошибку
		if (CheckVisibleControl(controlName . A_Index, isVisible))
			return ErrorLevel
		if (isVisible) {
			index := A_Index
			break
		}
	}
	return !index
	;return value = zero - finded visible input box
	;return value = non zero - didn't find or error
}

SetFanSpeed(controlName, speed)
{
	; Make blank, then paste new value.
	ControlSetText,  %controlName% ; If NewText is blank or ommited the control is made blank.
	if (ErrorLevel)
		MsgBox, SetFanSpeed - Can't SetText in %controlName%
	Control, EditPaste, %speed%, %controlName%
	if (ErrorLevel)
		MsgBox, SetFanSpeed - Can't EditPaste text in %controlName%
	return ErrorLevel ; знаю что здесь ошибка
}

;-------------------------------------------------------------------------------------
#IfWinExist, SpeedFan
+^F5:: ;CPU_Fan_On
{
	if (!WinUnHide())
		if (!SearchImage("SpeedFanCheckedBox.png")) ;проверяем сброшен или нет чекбокс
			if (!ToggleCheckbox("TJvXPCheckbox1")) ;меняем на противоположное значение чекбокс автоматического регулятора скорости вентилятора (выключаем его)
				if (!FindVisibleControl("TRxSpinEdit", index)) { ;ищем видимое поле для ввода
					;v1 ControlSetText не работает для SpeedFan!!!
					;v2 ControlFocus + Send
					;v3 ControlSend
					;v4 ControlSetText + (Control, EditPaste)
					;ControlSend, TRxSpinEdit%index%, {End}{Backspace 3}{Numpad1}{Numpad0 2}
					SetFanSpeed("TRxSpinEdit" . index, 100)
					Sleep, 3500
					;ControlSend, TRxSpinEdit%index%, {Left}{Backspace 2}{Numpad3}
					SetFanSpeed("TRxSpinEdit" . index, 30)
					Sleep, %delayBeforeHideWindow%
				}
				else 
					MsgBox, StartFan - didn't find any visible input field "TRxSpinEditXX".
	WinHide
}
return
;-------------------------------------------------------------------------------------
+^F6:: ;CPU_Fan_Off
{
	if (!WinUnhide())
			;хотел сделать проверку чекбокса правильно, но она не работает :(, вместо этого проверяем по картинке чекбокса
			;ControlGet, IsAutomaticFanSpeedEnabled, Checked, , TJvXPCheckbox1 ;не работает для SpeedFan!!!
		if (!SearchImage("SpeedFanUnCheckedBox.png"))
			if (!ToggleCheckbox("TJvXPCheckbox1")) ;включаем автоматический регулятор
				Sleep, %delayBeforeHideWindow%
	WinHide
}
return