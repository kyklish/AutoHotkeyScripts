;SnowRunner
#NoEnv
#SingleInstance, Force

GroupAdd, SpinTires, ahk_exe SnowRunner.exe

if not WinExist("ahk_group SpinTires")
	Run, "F:\GAMES\SnowRunner\en_us\Sources\Bin\SnowRunner.exe", F:\GAMES\SnowRunner\en_us\Sources\Bin


SetKeyDelay, 100
iOffset := 18 ;Distance to move mouse cursor to shift gear inside game
SetDefaultMouseSpeed, 10 ;Max speed, that game support, below 10 - not relieble

oStates := [] ;Service variable for script logic. Contains all possible Gear States. Only for debug purpose.
oGearBox := GearBoxFactory(oStates)


#IfWinActive ahk_group SpinTires
2::Send, {w down} ;Движение (зажимает кнопку для автоматического движения). Нажать "w" для отжатия.
3::Send, {s down}
4::Refuel() ;Полностью заправить машину
+4::Refuel(true) ;Полностью заправить машину и прицеп
/*
$m:: ;Открыть карту, предварительно отключив зажатые клавиши движения
if (GetKeyState("w") or GetKeyState("s")) {
	Send, {w up} ;Not worked if combined in one Send command!
	Send, {s up}
}
Send, m
return
*/
~m:: ;Открыть карту, предварительно отключив зажатые клавиши движения. ~ - when the hotkey fires, its key's native function will not be blocked (hidden from the system).
Send, {w up} ;Not worked if combined in one Send command!
Send, {s up}
return
NumpadMult::bManualMod := !bManualMod ;Переключить режим КПП: Автомат - Ручное
/*
#If WinActive("ahk_group SpinTires") and !bManualMod ;Автоматическое перемещение рычага КПП
Numpad0::oGearBox.Reset() ;Сбросить КПП в первоначальное состояние
Numpad1::oGearBox.ShiftGear(1) ;Включить передачу в соответствии со схемой
Numpad2::oGearBox.ShiftGear(2)
Numpad3::oGearBox.ShiftGear(3)
Numpad4::oGearBox.ShiftGear(4)
Numpad5::oGearBox.ShiftGear(5)
Numpad6::oGearBox.ShiftGear(6)
Numpad7::oGearBox.ShiftGear(7)
Numpad8::oGearBox.ShiftGear(8)
Numpad9::oGearBox.ShiftGear(9)

#If WinActive("ahk_group SpinTires") and bManualMod ;Перемещение рычага КПП с помощью "крестовины"
Numpad4::ShiftGear("L")
Numpad6::ShiftGear("R")
Numpad8::ShiftGear("U")
Numpad2::ShiftGear("D")
*/
#IfWinNotActive ahk_group SpinTires
F1:: ShowHelpWindow("
(LTrim
	2          -> Зажать W, движение вперед (нажать W, для сброса).
	3          -> Зажать S, движение назад (нажать S, для сброса).
	4          -> Полностью заправить машину.
	Shift + 4  -> Полностью заправить машину + прицеп.
	NumpadMult -> Переключить режим КПП: Автомат - Ручное.
	Numpad0-9  -> Переключить КПП. (Автомат). Смотри скрипт.
	Numpad4    -> Рычаг КПП влево  (Ручное).
	Numpad6    -> Рычаг КПП вправо (Ручное).
	Numpad8    -> Рычаг КПП вверх  (Ручное).
	Numpad2    -> Рычаг КПП вниз   (Ручное).
	M          -> Открыть карту, предварительно отключив зажатые клавиши движения.
)")


#IfWinActive
!z::Reload
!x::ExitApp


ShiftGear(сDirection) {
	global iOffset
	
	Switch сDirection
	{
		Case "U": ShiftGearMouseMove(0, -iOffset)	;Up
		Case "D": ShiftGearMouseMove(0, iOffset)	;Down
		Case "L": ShiftGearMouseMove(-iOffset, 0)	;Left
		Case "R": ShiftGearMouseMove(iOffset, 0)	;Right
		Default: MsgBox, No such direction: %cDirection%
	}
}


ShiftGearMouseMove(X, Y) {
	
	Send, {LShift down}
	MouseMove, %X%, %Y%, , R
	Send, {LShift up}
}


GearBoxFactory(ByRef oStates) {
	Loop, 10
	{
		i := A_Index - 1
		oStates.InsertAt(i, new State(i))
	}
	
	;Создаем связи между возможными положениями КПП (вместо цифр можно было использовать и буквенные обозначения, как на схеме)
	;7 8      + H
	;| |      | |
	;4-5-6 -> L-A-N
	;| |      | |
	;1 2      - R
	;Достаточно явно указать "узловые" положения, куда подключаются пограничные положения
	;В данном случае это 5 и 4, к ним подсоединяются все остальные
	oStates[4].oDirections := {U: oStates[7], D: oStates[1], R: oStates[5]}
	oStates[5].oDirections := {U: oStates[8], D: oStates[2], L: oStates[4], R: oStates[6]}
	;Чтобы все остальные положения (кроме 4 и 5) знали о их связях с 4 и 5, вызываем функции, которые обойдут все уже вложенные положения и сообщат им, что они связаны с "узловым" положением рычага КПП
	oStates[4].InitLinkedStates()
	oStates[5].InitLinkedStates()
	;Теперь все положения знают свое место и возможные направления переключений в соответствии со схемой
	
	return new GearBox(oStates[5]) ;Default starting position is 5
}


class State { ;Положение рычага КПП
	iGear := -1
	oDirections := {} ;Возможные перемещения рычага КПП в данном положении (вверх, вниз, влево, вправо) и связанные с ними новые положения рычага КПП
	
	__New(iGear) {
		this.iGear := iGear
	}
	
	Shift(cDirection) { ;Передвинуть рычаг в заданном направлении
		ShiftGear(cDirection) ;Собственно передвижение
		return this.oDirections[cDirection]
	}
	
	InitLinkedStates() { ;Создаем ответные связи на этот экземпляр класса
		for cDirection, oState in this.oDirections {
			cOppositDirection := this.InvertDirection(cDirection)
			oState.oDirections[cOppositDirection] := this
		}
	}
	
	InvertDirection(cDirection) {
		Switch cDirection {
			Case "L": return "R"
			Case "R": return "L"
			Case "U": return "D"
			Case "D": return "U"
			Default: MsgBox, No such direction: %cDirection%
		}
	}
}


class GearBox { ;Коробка передач
	oCurrentState := {}
	oResetState := {}
	
	__New(oCurrentState) {
		this.oCurrentState := this.oResetState := oCurrentState
	}
	
	ExecuteShiftSequence(sDirectionSequence) { ;For example "LLU": left, left, up
		Loop, Parse, sDirectionSequence
		{
			this.oCurrentState := this.oCurrentState.Shift(A_LoopField)
		}
	}
	
	ShiftGear(iTargetGear) { ;переключить передачу
		sDirectionSequence := this.FindShiftSequence(this.oCurrentState, iTargetGear)
		this.ExecuteShiftSequence(sDirectionSequence)
	}
	
	FindShiftSequence(oSearchState, iTargetGear, iParentGear := -1, sTempSequence := "") { ;Return for example "ULD": up, left, down
		if (oState.iGear = iTargetGear)
			return
		for cDirection, oState in oSearchState.oDirections
		{
			if (iParentGear = oState.iGear)
				continue ;break infinity recursion
			if (oState.iGear = iTargetGear)
				return sTempSequence . cDirection
			sSequence := this.FindShiftSequence(oState, iTargetGear, oSearchState.iGear, sTempSequence . cDirection)
			if (sSequence != "")
				return sSequence
		}
	}
	
	Reset() { ;Reset to initial State if you loose sync in-game gearbox with script GearBox.
		this.oCurrentState := this.oResetState
	}
}


Refuel(bRefuelWithTrailer := false) {
	Send, c
	FillFullTank()
	if (bRefuelWithTrailer) { ;Дополнительно заправить прицеп
		Send, e
		FillFullTank()
	}
	Send, {Esc}
}


FillFullTank() {
	Send, {f down}
	Sleep, 1500
	Send, {f up}
}