#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

Reload_AsAdmin()

;В начале игры дают 7ь слотов для растений + лопата
;После увеличивают до 8и + лопата -> ширина иконки уменьшается
is8Slots := true

GroupAdd, PvZ, Plants vs. Zombies
Xcard := [] ; координаты по X карточек растений (top of the screen)
Ycard := 45
Hotkey, IfWinActive, ahk_group PvZ
Loop, 9 {
	if is8Slots ; 8 пиктограмм растений начинающихся с координаты 120 с шагом 54 пикселей + Лопата на 8ой позиции
		Xcard[A_Index] := 120 + 54 * (A_Index - 1)
	else        ; 7 пиктограмм растений начинающихся с координаты 120 с шагом 60 пикселей + Лопата на 8ой позиции
		Xcard[A_Index] := 120 + 60 * (A_Index - 1)
	Hotkey, %A_Index%, PlantPlantUnderCursor ; keys from 1 to 9
}
SetTimer, ClickObjects, 2000 ; if too small, it will click object several times; перед кликом, будет сброшен текущий выбор цветка


!x:: ExitApp
!z:: Reload


#IfWinActive, ahk_group PvZ
0::FindFirstPlantInLineAndPlantItUnderCursor()
-::
if (toggle := !toggle) {
	SetTimer ClickObjects, Off
	CoordMode, ToolTip, Client
	ToolTip, OFF, 0, 0
} else {
	SetTimer ClickObjects, On
	ToolTip
}
return
q:: ClickOnColor(0xFEFE48) ;Gold Coin - Very diffucult find out Color

#IfWinNotActive, ahk_group PvZ
F1:: ShowHelpWindow("
(
1-9 -> Карточки растений в верхнем ряду.
  0 -> Выбор первого растения в бегущем ряду
       пиктограмм растений вверху экрана и
       его посадка под курсором.
  - -> Вкл\Отлк авто клика по солнышкам и монеткам.
  q -> Попытатся авто-кликнуть золотую монету.
)")


ClickObjects:
if (WinActive("ahk_group PvZ"))
{
	SetTimer, , Off
	ClickOnColor(0xFEF601) ;Sun
	ClickOnColor(0xB4B4B4) ;Silver Coin - Produce false clicks in menu (or 0xCACACA)
	SetTimer, , On
}
return


ClickOnColor(ColorID)
{
	ToolTip("Search: " ColorID, 10000)
	Loop {
		PixelSearch, X, Y, 35, 88, 750, 580, %ColorID%, , Fast RGB
		if (!ErrorLevel) {
			Click, Right ; сбросить цветок, который купил, иначе он будет посажен на месте солнышка
			ClickRestore(X, Y)
			;SoundBeep
			;ToolTip(X ", " Y)
		}
		else
			break
		Sleep, 500 ; чтобы часто не кликало объект, которое уже кликнули, но оно еще в полете в Top Left или Top Down угол
	}
	RemoveToolTip()
}


ClickRestore(X, Y, ClickCount := 1)
{
	MouseGetPos, _X, _Y
	Click, %X%, %Y%, %ClickCount% ; by default Left button
	MouseMove, _X, _Y
}


ClickRestoreClick(X, Y)
{
	ClickRestore(X, Y)
	Click
}


PlantPlantUnderCursor() ; посадить растение
{
	global Xcard, Ycard
	i := A_ThisHotkey
	if (1 <= i and i <= Xcard.Length())
		ClickRestoreClick(Xcard[i], Ycard)
}


FindFirstPlantInLineAndPlantItUnderCursor() ; выбор первого растения в бегущем ряду пиктограмм растений вверху экрана и его посадка под курсором
{
	PixelSearch, X, Y, 100, 10, 600, 10, 0xAABA99, , Fast RGB
	if (!ErrorLevel) {
		ClickRestoreClick(X, Y)
		;ClickRestoreClick(X + 20, Y + 35) ; целимся в центр иконки, Optional
		;ToolTip(X ", " Y)
	}
}