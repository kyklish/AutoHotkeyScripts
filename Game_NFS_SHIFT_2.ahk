﻿#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

GroupAdd, SHIFT2, ahk_exe SHIFT2U.exe

;NFS - SHIFT 2
;Для NFS Shift 2 нужен Input режим, он уже установлен в _COMMON_SETTINGS_.ahk
;Для него нету задержек нажатия кнопок, поэтому используем Sleep
;Обязательно нужно ставить $ перед горячей клавишей или объявить #UseHook, уже установлен в _COMMON_SETTINGS_.ahk
;#UseHook, On ; Turning this directive ON is equivalent to using the $ prefix in the definition of each affected hotkey.
KeyDelayLong := 600 ; минимально рабочее значение 600мс; для перехода между меню, когда игра воспроизводит анимацию
KeyDelayShort := 100 ; для перебора пунктов в одном меню
MenuDelay := 900 ; ожидание появления меню, фактически задержка будет равна KeyDelayLong+MenuDelay

;==============================================================================================

;Joystick POV to Arrows - Переназначаем POV в стрелочки
#Include <JoyPOV2Key> ; <- See comments in JoyPOV2Key function
WatchPOV := Func("JoyPOV2Key").Bind("Up", "Down", "Left", "Right")
SetTimer, %WatchPOV%, 10

;==============================================================================================

SendKey(Key, KeyDelay)
{
	Send, %Key%
	Sleep, %KeyDelay%
}

SendKeyIfAllowed(Key, IsShortDelay := false)
{
	global KeyDelayLong, KeyDelayShort, IsDisabledTimer
	if (!IsDisabledTimer) ;обрабатывать нажатие, только если работает переназначение POV в стрелочки
		if (IsShortDelay)
			SendKey(Key, KeyDelayShort)
		else
			SendKey(Key, KeyDelayLong)
}

ResetCarTuning()
{
	global MenuDelay
	SendKeyIfAllowed("{Enter}")
	Sleep, %MenuDelay%
	Loop, 4
		SendKeyIfAllowed("{Down}", true)
	;---------------------------------
	SendKeyIfAllowed("{Enter}")
	Sleep, %MenuDelay%
	SendKeyIfAllowed("c")
	SendKeyIfAllowed("{Down}")
	SendKeyIfAllowed("{Enter}")
	Loop, 2 {
		SendKeyIfAllowed("{Esc}")
		if (A_Index = 1)
			Sleep, %MenuDelay%
		else
			Sleep, 500
	}
	;---------------------------------
	Loop, 3
		SendKeyIfAllowed("{Up}", true)
	SendKeyIfAllowed("{Enter}")
	SoundBeep
}

SelectMenuAndConfirm()
{
	SendKeyIfAllowed("{Enter}")
	SendKeyIfAllowed("{Down}", true)
	SendKeyIfAllowed("{Enter}")
}

;==============================================================================================

#IfWinActive, ahk_group SHIFT2
Joy1:: SendKeyIfAllowed("{Enter}") ;A
Joy2:: SendKeyIfAllowed("{Esc}")   ;B
Joy3:: SelectMenuAndConfirm()      ;X
;Joy4:: ResetCarTuning()            ;Y ;сбросить настройки машины, чтобы убрать ошибки настроек по умолчанию
Joy6::                             ;Right Bumper ;отключение переназначения POV в стрелочки и кнопок [A] [B] [Y]
if (IsDisabledTimer := !IsDisabledTimer) {
	Loop, 2
		SoundBeep
	SetTimer, %WatchPOV%, Off
} else {
	SoundBeep
	SetTimer, %WatchPOV%, On
}
return
#IfWinNotExist, ahk_group SHIFT2
Joy8:: 	Run, "F:\GAMES\Need For Speed - SHIFT 2\SHIFT2U.exe", F:\GAMES\Need For Speed - SHIFT 2 ;Start (RButton)

;==============================================================================================

BuyOneUpgrade() ; последовательность клавиш для покупки апгрейда машины и перехода на следующий пункт меню
{
	Loop, 2 {
		SendKeyIfAllowed("{Enter}")
		SendKeyIfAllowed("{Down}", true)
	}
}

BuyUpgrades(ItemCount) ; количество указывает, сколько апгрейдов нужно купить
{
	SoundBeep
	Loop, %ItemCount%
		BuyOneUpgrade()
}

#IfWinActive, ahk_group SHIFT2
;Numpad1:: BuyUpgrades(1)
;Numpad2:: BuyUpgrades(2)
;Numpad3:: BuyUpgrades(3)
;Numpad4:: BuyUpgrades(4)
;Numpad5:: BuyUpgrades(5)
;Numpad6:: BuyUpgrades(6)
;Numpad7:: BuyUpgrades(7)

#IfWinNotActive, ahk_group SHIFT2
F1:: ShowHelpWindow("
(LTrim
	POV             -> [Стрелки]
	Start (RButton) -> Start game.
	A               -> [Enter]
	B               -> [Esc]
	X               -> Select menu and confirm.
	Y (TODO)        -> Reset car tuning - Сбросить настройки машины (если ее выбрали первый раз). Убирает ошибки настроек по умолчанию.
	...                Нажимать в 'Car Garage'->'MyCars' (когда модель машины будет загружена игрой).
	...                Скрипт подтвердит выбор машины и сделает остальную грязную работу и подаст звуковой сигнал окончания.
	Right Bumper    -> Отключение переназначения [POV] в стрелочки, кнопок [A] [B] [Y], [Numpad1-9].
	...                Обязательно во время езды, иначе может появится меню.
	Numpad1-9 (TODO)-> Покупка\продажа апгрейдов (цифра - количество).
	...                Нажимать, когда уже выделена строка для покупки любого апгрейда.
)")

!x:: ExitApp
!z:: Reload
