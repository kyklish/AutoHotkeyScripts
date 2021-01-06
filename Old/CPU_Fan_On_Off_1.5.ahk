#Include <_COMMON_SETTINGS_>

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
		MsgBox, %A_ThisFunc%: WinWaitActive - command timed out in %timeout% seconds.
	return ErrorLevel
}

SearchImage(path)
{
	ImageSearch, , , 295, 85, 325, 115, %A_ScriptDir%\%path%
	if (ErrorLevel = 2)
		MsgBox, %A_ThisFunc%: ImageSearch - Fail to open the image file "%A_ScriptDir%\%path%"`nOr a badly formatted option.
	else if (ErrorLevel = 1) ;Didn't find image in the specified region
		SoundBeepTwice()
	return ErrorLevel
}

ToggleCheckbox(name)
{
	Control, Check, , %name% ;UnCheck не работает для SpeedFan!!! только Check
	if (ErrorLevel)
		MsgBox, %A_ThisFunc%: CheckBox - Can't toggle "%name%".
	return ErrorLevel
}

CheckVisibleControl(name, ByRef isVisible)
{
	ControlGet, isVisible, Visible, , %name%
	if (ErrorLevel) {
		MsgBox, %A_ThisFunc%: ControlGet - No such input field "%name%".
		return ErrorLevel
	}
}

FindVisibleControl(name, ByRef index)
{
	Loop, 10 { ;ведем поиск первого видимого поля для ввода скорости вентилятора, ограничиваемся 10-ю первыми, 11-й уже выдает ошибку
		if (CheckVisibleControl(name . A_Index, isVisible))
			return ErrorLevel
		if (isVisible) {
			index := A_Index
			break
		}
	}
	err := !index ;error
	if (err)
		MsgBox, %A_ThisFunc%: didn't find any visible input field "%name%".
	return err
	;return value = zero - finded visible input box
	;return value = non zero - didn't find or error
}
;-------------------------------------------------------------------------------------
#IfWinExist, SpeedFan
+^F5:: ;CPU_Fan_On
{
	if (!WinUnHide())
		if (!SearchImage("SpeedFanCheckedBox.png")) ;проверяем сброшен или нет чекбокс
			if (!ToggleCheckbox("TJvXPCheckbox1")) ;меняем на противоположное значение чекбокс автоматического регулятора скорости вентилятора (выключаем его)
				if (!FindVisibleControl("TRxSpinEdit", index)) { ;ищем видимое поле для ввода
					;Либо ControlFocus + Send или просто ControlSend ;ControlSetText не работает для SpeedFan!!!
					ControlSend, TRxSpinEdit%index%, {End}{Backspace 3}{Numpad1}{Numpad0 2}
					Sleep, 3500
					ControlSend, TRxSpinEdit%index%, {Left}{Backspace 2}{Numpad3}
					Sleep, %delayBeforeHideWindow%
				}
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