#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
CoordMode, ToolTip, Client

isDebug := false

GroupAdd, PvZ, Plants vs. Zombies
Xcard := [] ; координаты по X карточек растений (top of the screen)
Ycard := 45
slots := 0 ; количество карточек с растениями, нужно для определения позиции лопаты
Hotkey, IfWinActive, ahk_group PvZ
Loop, 9 {
	Hotkey, %A_Index%, PlantPlantUnderCursor ; keys from 1 to 9
}
isAutoClickAllowed := false


!x:: ExitApp
!z:: Reload


#IfWinActive, ahk_group PvZ
0::FindFirstPlantInLineAndPlantItUnderCursor()
-::ToggleAutoClick()
=::ToggleNumberOnPlant()
q:: ClickOnColor(0xFEFE48) ; Gold Coin - Very diffucult find out Color
`::PlantPlantUnderCursor(true) ; unroot plant under cursor

#IfWinNotActive, ahk_group PvZ
F1:: ShowHelpWindow("
(
1-9 -> Карточки растений в верхнем ряду.
  0 -> Выбор первого растения в бегущем ряду пиктограмм растений вверху экрана и
       его посадка под курсором.
  `` -> Выкопать цветок
  - -> Вкл\Отлк авто клика по солнышкам и монеткам (ложные срабатывания в меню).
  = -> Вкл\Откл подсказки с номером иконки растения.
  q -> Попытатся авто-кликнуть золотую монетку (сложно определить код цвета).
)")


ClickObjects:
if (WinActive("ahk_group PvZ"))
{
	SetTimer, , Off
	ClickOnColor(0xFEF601) ; Sun 12% (best color!) for big and small suns
	ClickOnColor(0xEAEAEA) ; Silver Coin 0.465%
	;ClickOnColor(0xE7E7E7) ; Silver Coin 0.465%
	;ClickOnColor(0xD1D1D1) ; Silver Coin 0.413%
	;ClickOnColor(0xBBBBBB) ; Silver Coin 0.258%
	;ClickOnColor(0xBABABA) ; Silver Coin 0.207%
	ClickOnColor(0xFEFE48) ; Gold Coin Unreliable
	ClickOnColor(0xFEFE46) ; Gold Coin Unreliable
	ClickOnColor(0xF5CD38) ; Gold Coin Unreliable
	ClickOnColor(0x150E00) ; Gold Coin Unreliable
	if (isAutoClickAllowed)
		SetTimer, , On
}
return


ClickOnColor(ColorID)
{
	global isAutoClickAllowed
	tooltipDisplayTime := 500
	;ToolTip("Search: " ColorID, tooltipDisplayTime)
	Loop {
		if (WinActive("ahk_group PvZ"))
		PixelSearch, X, Y, 40, 570, 775, 90, %ColorID%, , Fast RGB ; search is reversed from bottom to top (prevent click "flying" sun several times)
		if (!ErrorLevel & isAutoClickAllowed) { ; isAutoClickAllowed prevent infinite loop clicking if game on pause and sun is visible
			Click, Right ; сбросить цветок, который купил, иначе он будет посажен на месте солнышка
			ClickRestore(X, Y)
			;SoundBeep
			;ToolTip("Found: " ColorID . " " X ", " Y, tooltipDisplayTime)
		}
		else
			break
		Sleep, 500 ; чтобы часто не кликало объект, которое уже кликнули, но оно еще в полете в Top Left или Top Down угол
	}
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


PlantPlantUnderCursor(unRootPlant := false) ; посадить растение
{
	global Xcard, Ycard, slots
	;if (A_ThisHotkey == "``") {
	if (unRootPlant)
		i := slots + 1 ; лопата сразу после последнего растения
	else
		i := A_ThisHotkey
	if (1 <= i and i <= Xcard.Length())
		ClickRestoreClick(Xcard[i], Ycard)
}


FindFirstPlantInLineAndPlantItUnderCursor() ; выбор первого растения в бегущем ряду пиктограмм растений вверху экрана и его посадка под курсором
{
	; хорошо было бы искать и кликать нижнюю монотонную область карточки с цветком, но эту область может перекрывать голова зомби
	;PixelSearch, X, Y, 100, 10, 600, 10, 0xAABA99, , Fast RGB ; tooltips with numbers are interfere with search in top row
	PixelSearch, X, Y, 100, 21, 600, 21, 0xD0F7F9, , Fast RGB ; just below tooltip
	if (!ErrorLevel) {
		ClickRestoreClick(X, Y)
		;ClickRestoreClick(X + 20, Y + 35) ; целимся в центр иконки, Optional
	}
}

ToggleAutoClick()
{
	global isAutoClickAllowed
	if (isAutoClickAllowed := !isAutoClickAllowed) {
		FindSlotsCoordinates()
		SetTimer, ClickObjects, 1000 ; перед кликом, будет сброшен текущий выбор цветка
		ToolTip, ON, 0, 0
	} else {
		SetTimer ClickObjects, Off
		ToolTip, OFF, 0, 0
	}
}

FindSlotsCoordinates()
{
	; в начале игры дают 6ть слотов для растений + лопата
	; после увеличивают до 7и и 8и + лопата -> расстояние между иконками уменьшается
	; проверяем пиксель перед 7ой иконкой растения, если не тот цвет, значит слотов больше
	; 6ть слотов и 7мь слотов различаются только количеством иконок, шаг и размер одинаков
	; 6ть слотов определяем по большой рамке, рамка есть, значит это 6ть слотов
	global Xcard, slots
	backgroundColor := 0x6E3213 ; цвет фона вокруг иконки растения
	borderColor := 0x93451C ; цвет большой обрамляющей рамки вокруг всех иконок растений
	; 6ть слотов?
	PixelGetColor, color, 451, 21, RGB
	if (color == borderColor) {
		slots := 6
		CalculateXcard(slots)
		return
	}
	; 7мь слотов?
	PixelGetColor, color, 448, 21, RGB
	if (color == backgroundColor) {
		slots := 7
		CalculateXcard(slots)
		return
	}
	; 8мь слотов?
	PixelGetColor, color, 414, 21, RGB
	if (color == backgroundColor) {
		slots := 8
		CalculateXcard(slots)
		return
	}
	; если ничего не нашли, значит мы на уровне, когда растения сами появляются в бегущем ряду сверху
	slots := 1
	CalculateXcard(slots)
}

CalculateXcard(slots)
{
	global Xcard
	; 6 слотов растений = шаг в 59 пикселей
	; 7 слотов растений = шаг в 59 пикселей
	; 8 слотов растений = шаг в 54 пикселей
	offset := []
	offset.InsertAt(1, 530) ; для лопаты (на уровне, когда растения сами появляются в бегущем ряду сверху)
	offset.InsertAt(6, 59, 59, 54)
	Loop, 10 {
		; для 6 слотов центр первой иконки 120
		; для 7 слотов центр первой иконки 120
		; для 8 слотов центр первой иконки 115 (оптимальный вариант)
		Xcard[A_Index] := 115 + offset[slots] * (A_Index - 1)
	}
}

ToggleNumberOnPlant()
{
	global Xcard, slots, isDebug
	static toggle
	FindSlotsCoordinates()
	if (toggle := !toggle) {
		for i, X in Xcard {
			; по умолчанию используется тултип №1 (уже занят), начинаем сразу со второго
			; ширина тултипа с одной цифрой 18 пикселей (-9 чтобы поставить по центру карточки растения)
			if (isDebug)
				ToolTip, % i . " Debug", % X, 0, % i + 1 ; для отладки, левая сторона тултипа укажет X координау клика мышки при посадке растения
			else
				ToolTip, % i, % X - 9, 0, % i + 1
			if (i == slots + 1)
				break
		}
	} else {
		for i, X in Xcard
			ToolTip, , , , % i + 1
	}
}
