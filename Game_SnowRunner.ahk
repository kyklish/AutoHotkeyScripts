;SnowRunner
#Warn
#NoEnv
#SingleInstance, Force
#UseHook
SetBatchLines, -1

GroupAdd, SpinTires, ahk_exe SnowRunner.exe

iOffset := 20 ;Distance to move mouse cursor to shift gear inside game
SetKeyDelay, 50 ;Влияет на переключение передач и на скорость поворота камеры
SetKeyDelay,, 100 ;Reliably key pressure detection by game
SetDefaultMouseSpeed, 10 ;Max speed, that game support, below 10 - not reliable

oStates := [] ;Service variable for script logic. Contains all possible Gear States. Only for debug purpose.
oGearBox := GearBoxFactory(oStates)

sPressed := wPressed := bManualMod := false

#IfWinActive ahk_group SpinTires
    F1:: ShowHelpWindow("
    (LTrim
        Eng keyboard language required during play!!!
        In game change [Clutch Pedal] to [R.Shift].
        Switch numeric keyboard to mouse move: camera, RMB, mouse wheel.
        2          -> Зажать W, движение вперед (нажать W, для отжатия).
        3          -> Зажать S, движение назад (нажать S, для отжатия).
        LShift     -> Временно отжать зажатую клавишу, и после отпускания нажать.
        RCtrl      -> Mouse Right Click
        4          -> Полностью заправить машину.
        Shift + 4  -> Полностью заправить машину + прицеп.
        Numpad*    -> Переключить режим КПП: Автомат - Ручное.
        Numpad0    -> Сбросить состояние КПП в центральное положение.
        Numpad1-9  -> Переключить КПП. (Автомат).
        Numpad4    -> Рычаг КПП влево  (Ручное).
        Numpad6    -> Рычаг КПП вправо (Ручное).
        Numpad8    -> Рычаг КПП вверх  (Ручное).
        Numpad2    -> Рычаг КПП вниз   (Ручное).
        M          -> Открыть карту, предварительно отключив зажатые клавиши движения.
        N          -> Пропустить ночь.
        , and .    -> Поворот камеры
        ; and /    -> Mouse Wheel Up, Mouse Wheel Down
        !c         -> Suspend
        !z         -> Reload
        !x         -> ExitApp
        Схема КПП:
        7 8      + H
        | |      | |
        4-5-6 -> L-A-N
        | |      | |
        1 2      - R
    )")
    2:: ;Движение (зажимает кнопку для автоматического движения). Нажать "w" для отжатия.
        Send, {s up}
        Send, {w down}
        sPressed := false
        wPressed := true
    return
    3::
        Send, {w up}
        Send, {s down}
        sPressed := true
        wPressed := false
    return
    LShift:: ;Временно отжать зажатую клавишу
        Send, {w up}
        Send, {s up}
    return
    LShift Up::
    if (wPressed)
        Send, {w down}
    if (sPressed)
        Send, {s down}
    return
    4:: Refuel() ;Полностью заправить машину
    +4:: Refuel(true) ;Полностью заправить машину и прицеп
    ~Space:: ;Полная остановка при включении стояночного тормоза
    ~M:: ;Открыть карту, предварительно отключив зажатые клавиши движения. ~ - when the hotkey fires, its key's native function will not be blocked (hidden from the system).
        Send, {w up} ;Not worked if combined in one Send command!
        Send, {s up}
        sPressed := false
        wPressed := false
    return
    N::
        Gosub, ~M
        Send, m   ; Show map
        Send, ttt ; Time fast forward
        Send, m   ; Close map
    return
    ~S:: Send, {w up} ;Торможение во время зажатой кнопки W
    ~S Up::
    if (wPressed)
        Send, {w down}
    sPressed := false
    return
    ~W:: Send, {s up} ;Торможение во время зажатой кнопки S
    ~W Up::
    if (sPressed)
        Send, {s down}
    wPressed := false
    return
    ,:: ;Поворот камеры
    SetKeyDelay,, -1 ; Smooth camera movement
    While, GetKeyState(",", "P")
        Send, {,}
    return
    .::
    SetKeyDelay,, -1
    While, GetKeyState(".", "P")
        Send, {.}
    return
    `;:: Send, {WheelUp}
    /:: Send, {WheelDown}
    RCtrl::Click Right

    NumpadMult:: bManualMod := !bManualMod ;Переключить режим КПП: Автомат - Ручное
    Numpad0:: oGearBox.Reset() ;Сбросить КПП в первоначальное состояние

#If WinActive("ahk_group SpinTires") and !bManualMod ;Автоматическое перемещение рычага КПП
    Numpad1:: oGearBox.ShiftGear(1) ;Включить передачу в соответствии со схемой
    Numpad2:: oGearBox.ShiftGear(2)
    Numpad3:: oGearBox.ShiftGear(3)
    Numpad4:: oGearBox.ShiftGear(4)
    Numpad5:: oGearBox.ShiftGear(5)
    Numpad6:: oGearBox.ShiftGear(6)
    Numpad7:: oGearBox.ShiftGear(7)
    Numpad8:: oGearBox.ShiftGear(8)
    Numpad9:: oGearBox.ShiftGear(9)

#If WinActive("ahk_group SpinTires") and bManualMod ;Перемещение рычага КПП с помощью "крестовины"
    ; Numpad4:: ShiftGear("L")
    ; Numpad6:: ShiftGear("R")
    ; Numpad8:: ShiftGear("U")
    ; Numpad2:: ShiftGear("D")
    Numpad4:: oGearBox.ShiftGearManual("L")
    Numpad6:: oGearBox.ShiftGearManual("R")
    Numpad8:: oGearBox.ShiftGearManual("U")
    Numpad2:: oGearBox.ShiftGearManual("D")

#IfWinActive
!z::Reload
!x::ExitApp
!c::
    Suspend ; Must be first command!
    SuspendToolTip()
return

SuspendToolTip() {
    static bToggle := false
    if (bToggle := !bToggle)
        ToolTip, SnowRunner Helper SUSPENDED, 0, 0
    else
        ToolTip
}

ShiftGear(cDirection) {
    global iOffset

    Switch cDirection
    {
    Case "U": ShiftGearMouseMove(0, -iOffset)	;Up
    Case "D": ShiftGearMouseMove(0, iOffset)	;Down
    Case "L": ShiftGearMouseMove(-iOffset, 0)	;Left
    Case "R": ShiftGearMouseMove(iOffset, 0)	;Right
    Default: MsgBox, No such direction: %cDirection%
    }
}

ShiftGearMouseMove(X, Y) {
    ; Send, {LShift down}
    Send, {RShift down}
    MouseMove, %X%, %Y%, , R
    ; Send, {LShift up}
    Send, {RShift up}
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
            cOppositeDirection := this.InvertDirection(cDirection)
            oState.oDirections[cOppositeDirection] := this
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
        this.OutputDebugCurrentGear()
    }

    ExecuteShiftSequence(sDirectionSequence) { ;For example "LLU": left, left, up
        Loop, Parse, sDirectionSequence
        {
            this.oCurrentState := this.oCurrentState.Shift(A_LoopField)
            this.OutputDebugCurrentGear()
        }
    }

    ShiftGear(iTargetGear) { ;переключить передачу
        sDirectionSequence := this.FindShiftSequence(this.oCurrentState, iTargetGear)
        if (sDirectionSequence)
            this.ExecuteShiftSequence(sDirectionSequence)
        else
            this.WrongGearSound()
    }

    ShiftGearManual(cDirection) { ;переключить передачу вручную
        if (IsObject(this.oCurrentState.oDirections[cDirection])) ;oDirections содержит связь для данного направления перемещения рычага КПП
            this.ExecuteShiftSequence(cDirection)
        else ;You can't shift in that direction
            this.WrongGearSound()
    }

    FindShiftSequence(oSearchState, iTargetGear, iParentGear := -1, sTempSequence := "") { ;Return for example "ULD": up, left, down
        if (oSearchState.iGear = iTargetGear)
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
        this.OutputDebugCurrentGear()
    }

    WrongGearSound() {
        Random, i, 0, 5
        SoundPlay, ShowRunnerShift%i%.mp3, Wait ;Wait until play finish
        SoundPlay, StopPlayback.mp3 ;Release allocated codecs
        this.OutputDebugCurrentGear(true)
    }

    OutputDebugCurrentGear(bWrongGear := false) {
        msg := "Gear Position: "
        if (bWrongGear)
            msg .= "Пиздец блять!"
        else
            msg .= this.oCurrentState.iGear
        OutputDebug, % msg
    }
}

Refuel(bRefuelWithTrailer := false) {
    Send, c
    Sleep, 250
    FillFullTank()
    if (bRefuelWithTrailer) { ;Дополнительно заправить прицеп
        Send, e
        FillFullTank()
    }
    Send, {Esc}
}

FillFullTank() {
    Send, {f down}
    Sleep, 1750
    Send, {f up}
}
