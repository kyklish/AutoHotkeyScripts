﻿#Include <_COMMON_SETTINGS_>

;!!!!!!!!!!!!!!!!!!!!!!
;номера форм ввода TRxSpinEditX могут изменяться после переустановки и перезагрузки Windows

;из-за специфики приложения SpeedFan этими командами невозможно добиться надежного вызова окна и его исчезновения в трей
;WinHide -> WinShow
;WinMinimize -> WinRestore
;WinMaximize -> WinRestore
;but you can use in cross way :)
;поэтому приходится использовать TrayIcon_Button(), она работает только из под ограниченных прав, иначе вешает эксплорер
;но все последующие команды нужно выполнять с админ правами

#SingleInstance Off
;CoordMode, Pixel, Client
;SetControlDelay, 1000

;delayBeforeShowWindow := 0
delayBeforeHideWindow := 1500
checkboxColor := 0x20A040 ; RGB цвет зеленой галочки чекбокса

Main()


Main() {
	if (A_IsAdmin) {
		WinExist("SpeedFan") ; setting The "Last Found" Window for all others commands
		HotKey, IfWinExist, SpeedFan
		HotKey, +^F5, HotKey_StartFan
		HotKey, +^F6, HotKey_StopFan
		HotKey, +^F7, HotKey_StartStopFan
	} else {
		if (A_Args.Length() == 0) {
			Reload_AsAdmin()
		} else {
			if (A_Args.Length() == 1) {
				sParam := A_Args[1]
				if (sParam = "unhide") {
					; TrayIcon_Functions work only in user mode!!! with admin rights it's hangs Explorer.exe!!!
					TrayIcon_Button("speedfan.exe", "L", true) ; double click tray icon of SpeedFan
				} else {
					MsgBox, Wrong parameter "%sParam%", must be "UnHide".
					ExitApp, 1
				}
			} else {
				MsgBox, Must be one parameter, when run with restricted rights.
				ExitApp, 1
			}
		}
		ExitApp
	}
}


WinActivate()
{
	timeout := 1 ;seconds
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


SearchPixel(colorID, soundOnMatch := false)
{
	PixelSearch, , , 313, 100, 313, 100, %colorID%, ,Fast RGB
	if (ErrorLevel = 2)
		MsgBox, %A_ThisFunc%: PixelSearch - Fail to search.
	else if ((ErrorLevel = 1 && !soundOnMatch) || (ErrorLevel = 0 && soundOnMatch))
		SoundBeepTwice() ; в одном случае нам нужен звук при неуспешном поиске, в другом случае при успешном
	return ErrorLevel ; ErrorLevel == 1 - didn't find pixel
}


ToggleCheckbox(name)
{
	Control, Check, , %name% ;UnCheck не работает для SpeedFan!!! только Check
	if (ErrorLevel)
		MsgBox, %A_ThisFunc%: CheckBox - Can't toggle "%name%".
	return ErrorLevel
}


MinimizeWindow()
{
	name := "TJvXPButton2"
	ControlClick, %name%
	if (ErrorLevel)
		MsgBox, %A_ThisFunc%: Button - Can't click "Minimize" button "%name%".
	return ErrorLevel
}


CheckVisibleControl(name, ByRef isVisible)
{
	ControlGet, isVisible, Visible, , %name%
	if (ErrorLevel)
		MsgBox, %A_ThisFunc%: ControlGet - No such input field "%name%".
	return ErrorLevel
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
	;return value = zero - found visible input box
	;return value = non zero - didn't find or error
}


StartFan() ;CPU_Fan_On
{
	global delayBeforeHideWindow, checkboxColor
	if (!WinActivate())
		;if (!SearchImage("SpeedFanCheckedBox.png")) ;проверяем сброшен или нет чекбокс
		if (!SearchPixel(checkboxColor)) ;пиксель галочки чекбокса найден
			if (!ToggleCheckbox("TJvXPCheckbox1")) ;меняем на противоположное значение чекбокс автоматического регулятора скорости вентилятора (выключаем его)
				if (!FindVisibleControl("TRxSpinEdit", index)) { ;ищем видимое поле для ввода
					;Либо ControlFocus + Send или просто ControlSend ;ControlSetText не работает для SpeedFan!!!
					ControlSend, TRxSpinEdit%index%, {End}{Backspace 3}{Numpad1}{Numpad0 2}
					Sleep, 3500
					ControlSend, TRxSpinEdit%index%, {Left}{Backspace 2}{Numpad3}
					Sleep, %delayBeforeHideWindow%
				}
	MinimizeWindow()
}


StopFan() ;CPU_Fan_Off
{
	global delayBeforeHideWindow, checkboxColor
	if (!WinActivate())
		;хотел сделать проверку чекбокса правильно, но она не работает :(, вместо этого проверяем по картинке чекбокса
		;ControlGet, IsAutomaticFanSpeedEnabled, Checked, , TJvXPCheckbox1 ;не работает для SpeedFan!!!
		;if (!SearchImage("SpeedFanUnCheckedBox.png")) ;галочка сброшена
		if (SearchPixel(checkboxColor, true) = 1) ;пиксель галочки чекбокса не найден
			if (!ToggleCheckbox("TJvXPCheckbox1")) ;включаем автоматический регулятор
				Sleep, %delayBeforeHideWindow%
	MinimizeWindow()
}


StartStopFan() ;CPU_Fan_On then CPU_Fan_Off for HWiNFO32 if it not show "CPU Fan RPM" icon
{
	global delayBeforeHideWindow, checkboxColor
	if (!WinActivate())
		if (!SearchPixel(checkboxColor)) ;пиксель галочки чекбокса найден
			if (!ToggleCheckbox("TJvXPCheckbox1")) ;меняем на противоположное значение чекбокс автоматического регулятора скорости вентилятора (выключаем его)
				if (!FindVisibleControl("TRxSpinEdit", index)) { ;ищем видимое поле для ввода
					ControlSend, TRxSpinEdit%index%, {End}{Backspace 3}{Numpad1}{Numpad0 2}
					Sleep, 1000
					if (!ToggleCheckbox("TJvXPCheckbox1")) ;включаем автоматический регулятор
						Sleep, %delayBeforeHideWindow%
				}
	MinimizeWindow()
}


HotKey_StartFan()
{
	WinMinimizeAll ;WinMinimizeAll() <-- this func add delay before UnHide window
	if (!Run_WaitScriptAsUser(A_ScriptFullPath, "UnHide"))
		StartFan()
	WinMinimizeAllUndo
}


HotKey_StopFan()
{
	WinMinimizeAll ;WinMinimizeAll()
	if (!Run_WaitScriptAsUser(A_ScriptFullPath, "UnHide"))
		StopFan()
	WinMinimizeAllUndo
}


HotKey_StartStopFan()
{
	WinMinimizeAll ;WinMinimizeAll()
	if (!Run_WaitScriptAsUser(A_ScriptFullPath, "UnHide"))
		StartStopFan()
	WinMinimizeAllUndo
}

/*
WinMinimizeAll()
{
	global delayBeforeShowWindow
	WinMinimizeAll
	Sleep %delayBeforeShowWindow%
}
*/
