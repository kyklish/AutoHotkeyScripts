; Game always capture mouse moves and wheel moves!!!
; Can't block it with [BlockInput, MouseMove]!!!
; Mouse moves during gear shifting will interfere with script logic :(

#Warn
#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%

; Although a value of 1 is allowed, it is not recommended because it would
; prevent new hotkeys from launching whenever the script is displaying a message
; box or other dialog. It would also prevent timers from running whenever another
; thread is sleeping or waiting.
; REASON: Don't allow fire any other hotkey if current hotkey is in action!
; Ignore them and don't buffer them.
#MaxThreads, 1

Menu, Tray, Icon, SnowRunner.ico, 1, 1
Menu, Tray, Tip, SnowRunner Helper

GroupAdd, SpinTires, ahk_exe SnowRunner.exe

iOffset := 15 ;Distance to move mouse cursor to shift gear inside game
SetKeyDelay, 50 ;Влияет на переключение передач и на скорость поворота камеры
SetKeyDelay,, 100 ;Reliably key pressure detection by game
SetDefaultMouseSpeed, 10 ;Max speed, that game support, below 10 - not reliable

oStates := [] ;Service variable for script logic. Contains all possible Gear States. Only for debug purpose.
oGearBox := GearBoxFactory(oStates)

sPressed := wPressed := false
bLegacyMode    := false ; Switch gears by mouse moves
bManualMode    := false ; Switch gears UP/DOWN/LEFT/RIGHT
bSimpleGearBox := false ; Early game GearBox (LOW/AUTO/REVERSE)
iGear := 5 ; [Auto] Current gear in new GearBox (switch by mouse wheel)

#IfWinActive ahk_group SpinTires
    F1:: ShowHelpWindow("
    (
Disable ScrollNavigator!!!
Change [Clutch Pedal] to [Right Shift] in the game settings.
Change [Winch] to [Left Shift] in the game settings. (Its much better!)
For NEW GearBox: assign [Gear] to [Numpad] keys according to scheme in the game settings.
For LEGACY GearBox: do not assign any keys to [Numpad].
A4Tech Keyboard: switch numeric keyboard to mouse move (Camera, RMB, Mouse Wheel).
    Simple/Advanced GearBox mismatch:
        - can't switch from A to H/L+ press TAB
        - can't switch from A to L press TAB
[GAME]
    2           -> Lock W down, move  forward (press W to unlock)
    !2          -> Lock S down, move backward (press S to unlock)
    RAlt        -> Mouse Middle Button (Down/Up)
    RCtrl       -> Mouse Right Click
    4           -> Full Truck Refuel
    !4          -> Full Truck Refuel + Trailer
    T           -> Time Fast Forward [Skip Night]
    , and .     -> Turn Camera (Left/Right)
    / and ;     -> Mouse Wheel Up / Mouse Wheel Down
[GEARBOX]
    CapsLock    -> Switch GearBox (Legacy [NUMPAD] / New [MOUSE WHEEL])
    Numpad*     -> Toggle GearBox Mode: Auto/Manual
    Numpad0     -> Reset GearBox State in script to AUTO gear (sync GearBox)
    NumpadEnter -> Show Current GearBox Status
    RMB         -> Switch Gear (Low Gear / Auto Gear) [ONLY IN AUTO GEARBOX MODE]
[LEGACY GEARBOX]
    Numpad1-9         -> Switch Gear (Auto)
    RMB   + QAZ/EDC   -> Switch Gear (Auto)
    Space + QAZ/EDC   -> Switch Gear (Auto)
    Numpad4           -> Move Gear Stick Left  (Manual)
    Numpad6           -> Move Gear Stick Right (Manual)
    Numpad8           -> Move Gear Stick Up    (Manual)
    Numpad2           -> Move Gear Stick Down  (Manual)
    Numpad0 & Numpad4 -> Move Gear Stick Left  (Manual) [WITHOUT RESTRICTION AND SOUND]
    Numpad0 & Numpad6 -> Move Gear Stick Right (Manual) [WITHOUT RESTRICTION AND SOUND]
    Numpad0 & Numpad8 -> Move Gear Stick Up    (Manual) [WITHOUT RESTRICTION AND SOUND]
    Numpad0 & Numpad2 -> Move Gear Stick Down  (Manual) [WITHOUT RESTRICTION AND SOUND]
[NEW GEARBOX]
    Tab         -> Toggle GearBox: Simple (A L R) /Advanced (H A L- L L+ R)
    WheelUp     -> Switch Gear Up   (hold CTRL to zoom)
    WheelDown   -> Switch Gear Down (hold CTRL to zoom)
[SCRIPT]
    !``          -> Make Window BorderLess
    !1          -> Stretch Window to Screen Size
    !C          -> Suspend
    !Z          -> Reload
    !X          -> ExitApp
[GEAR SCHEME in GearBox]
    7 8      + H
    | |      | |
    4-5-6 -> L-A-N
    | |      | |
    1 2      - R
    )")
    UnlockKeys: ; Unlock [W] & [S] keys.
        Send, {w up} ;Not worked if combined in one Send command!
        Send, {s up}
        sPressed := false
        wPressed := false
    return
    2:: ; Lock [W] down. Press [W] to unlock.
        Send, {s up}
        Send, {w down}
        sPressed := false
        wPressed := true
    return
    ; [1] & [3] is used in game to switch LOAD/UNLOAD menu
    !2:: ; Lock [S] down. Press [S] to unlock.
        Send, {w up}
        Send, {s down}
        sPressed := true
        wPressed := false
    return
    4:: Refuel() ; Full Truck Refuel.
    !4:: Refuel(true) ; Full Truck Refuel + Trailer.
    ; Do not use [~] with [Space]!
    ; It will break [Space] as prefix in hotkeys below!
    Space:: ; Full stop on handbrake
        Gosub, UnlockKeys
        Send, {Space}
    return
    B:: ; Full stop on engine stop
        Gosub, UnlockKeys
        Send, {b}
    return
    M::
        Gosub, UnlockKeys
        Send, m
    return
    T::
        SetKeyDelay, 200
        Gosub, m
        Send, ttt ; Time fast forward
        Send, m   ; Close map
    return
    ~S:: Send, {w up} ; Braking during [W] locking
    ~S Up::
        if (wPressed)
            Send, {w down}
        sPressed := false
    return
    ~W:: Send, {s up} ; Braking during [S] locking
    ~W Up::
        if (sPressed)
            Send, {s down}
        wPressed := false
    return
    ,:: ; Camera turn
        SetKeyDelay,, -1 ; Smooth camera movement
        While, GetKeyState(",", "P")
            Send, {,}
    return
    .:: ; Camera turn
        SetKeyDelay,, -1
        While, GetKeyState(".", "P")
            Send, {.}
    return
    `;:: Send, {WheelUp}
    /:: Send, {WheelDown}
    RAlt:: Send, {MButton down}
    RAlt Up:: Send, {MButton up}
    ; RCtrl:: Send, {RButton down}
    ; RCtrl Up:: Send, {RButton up}
    RCtrl:: Click Right

    Tab::     bSimpleGearBox := !bSimpleGearBox
    CapsLock::   bLegacyMode := !bLegacyMode ; Toggle GearBox: Legacy/New
    NumpadMult:: bManualMode := !bManualMode ; Toggle GearBox Mode: Auto/Manual
    ; Reset GearBox internal state to AUTO Gear
    Numpad0::
        oGearBox.Reset()
        iGear := 5
        Send {Numpad%iGear%}
    return

    NumpadEnter::
        sCurrentStatus := ""
        if (bLegacyMode) {
            sCurrentStatus .= "[CapsLock]`tLEGACY (NUMPAD KEYS)`n"
            sCurrentStatus .= "[Numpad*]`t" (bManualMode ? "MANUAL" : "AUTO") "`n"
            sCurrentStatus .= "[Key]`t`tGEAR: " oGearBox.oCurrentState.iGear
        }
        else {
            sCurrentStatus .= "[CapsLock]`tNEW (MOUSE WHEEL)`n"
            sCurrentStatus .= "[Tab]`t`t" (bSimpleGearBox ? "SIMPLE (Low/Auto)" : "ADVANCED (High/Low-/Low+/Auto)") "`n"
            sCurrentStatus .= "[Wheel]`t`tGEAR: " iGear
        }
        ToolTip(sCurrentStatus, 2)
    return

    !`:: Borderless("ahk_group SpinTires")
    !1:: WinMove, ahk_group SpinTires,, 0, 0, A_ScreenWidth, A_ScreenHeight

#If WinActive("ahk_group SpinTires") and !bLegacyMode
    WheelUp::
        if (GetKeyState("Ctrl"))
            Return
        ; Game always detects mouse movement and wheel movement!
        ; Reverse wheel movement to restore current zoom.
        Send {WheelDown}
        if (bSimpleGearBox) {
            Switch iGear {
            ; R => L => A => WrongGearSound
            Case 2: iGear := 4
            Case 4: iGear := 5
            Case 5: oGearBox.WrongGearSound()
            }
        } else {
            Switch iGear {
            ; A => H
            Case 5: iGear := 8
            ; R => L+
            Case 2: iGear := 7
            ; L- => L => L+ => H => WrongGearSound
            Case 1: iGear := 4
            Case 4: iGear := 7
            Case 7: iGear := 8
            Case 8: oGearBox.WrongGearSound()
            }
        }
        Send {Numpad%iGear%}
    return
    WheelDown::
        if (GetKeyState("Ctrl"))
            return
        ; Game always detects mouse movement and wheel movement!
        ; Reverse wheel movement to restore current zoom.
        Send {WheelUp}
        if (bSimpleGearBox) {
            Switch iGear {
            ; A => L => R => WrongGearSound
            Case 5: iGear := 4
            Case 4: iGear := 2
            Case 2: oGearBox.WrongGearSound()
            }
        } else {
            Switch iGear {
            ; A => L+
            Case 5: iGear := 7
            ; H => L+ => L => L- => R => WrongGearSound
            Case 8: iGear := 7
            Case 7: iGear := 4
            Case 4: iGear := 1
            Case 1: iGear := 2
            Case 2: oGearBox.WrongGearSound()
            }
        }
        Send {Numpad%iGear%}
    return
    ; Disable ScrollNavigator to fix Right Mouse Button behaviour
    ~RButton::
        if (iGear == 5)
            iGear := 4
        else
            iGear := 5
        Send {Numpad%iGear%}
    return

#If WinActive("ahk_group SpinTires") and bLegacyMode
    ; Move gear stick without restriction and sound
    Numpad0 & Numpad4:: ShiftGear("L")
    Numpad0 & Numpad6:: ShiftGear("R")
    Numpad0 & Numpad8:: ShiftGear("U")
    Numpad0 & Numpad2:: ShiftGear("D")

#If WinActive("ahk_group SpinTires") and bLegacyMode and !bManualMode
    ; Automatically move gear stick
    Numpad1:: oGearBox.ShiftGear(1)
    Numpad2:: oGearBox.ShiftGear(2)
    Numpad3:: oGearBox.ShiftGear(3)
    Numpad4:: oGearBox.ShiftGear(4)
    Numpad5:: oGearBox.ShiftGear(5)
    Numpad6:: oGearBox.ShiftGear(6)
    Numpad7:: oGearBox.ShiftGear(7)
    Numpad8:: oGearBox.ShiftGear(8)
    Numpad9:: oGearBox.ShiftGear(9)

    ~RButton::
        ; Do not interfere with Right Click on Map
        if (GetKeyState("W") || GetKeyState("S")) {
            if (oGearBox.oCurrentState.iGear == 5)
                oGearBox.ShiftGear(4)
            else
                oGearBox.ShiftGear(5)
        }
    return

    ; GEARS FOR LEFT HAND [SPACE & RMB PREFIX]

    ; Prefix key [Space] loses its native function.
    ; Fix it with explicit SEND in [Space] hotkey above.
    ; In this mode [Space] fires on release.
    Space & Q:: oGearBox.ShiftGear(7) ; L+
    Space & A:: oGearBox.ShiftGear(4) ; L
    Space & Z:: oGearBox.ShiftGear(1) ; L-
    Space & E:: oGearBox.ShiftGear(8) ; H
    Space & D:: oGearBox.ShiftGear(5) ; A
    Space & C:: oGearBox.ShiftGear(2) ; R

    ; Prefix key [RButton] loses its native function. Fix it with [~].
    ~RButton & Q:: oGearBox.ShiftGear(7) ; L+
    ~RButton & A:: oGearBox.ShiftGear(4) ; L
    ~RButton & Z:: oGearBox.ShiftGear(1) ; L-
    ~RButton & E:: oGearBox.ShiftGear(8) ; H
    ~RButton & D:: oGearBox.ShiftGear(5) ; A
    ~RButton & C:: oGearBox.ShiftGear(2) ; R

#If WinActive("ahk_group SpinTires") and bLegacyMode and bManualMode
    ; Manually move gear stick Up/Down/Left/Right
    Numpad4:: oGearBox.ShiftGearManual("L")
    Numpad6:: oGearBox.ShiftGearManual("R")
    Numpad8:: oGearBox.ShiftGearManual("U")
    Numpad2:: oGearBox.ShiftGearManual("D")

#IfWinActive
!Z:: Reload
!X:: ExitApp
!C::
    Suspend ; Must be first command!
    SuspendToolTip()
return

Borderless(WinTitle) {
    static bToggle := false
    WinExist(WinTitle) ; set Last Found Window
    if (bToggle := !bToggle)
        WinSet, Style, -0xC40000 ; WS_BORDER + WS_DLGFRAME + WS_SIZEBOX
    else
        WinSet, Style, +0xC40000
    WinMinimize ; Force redraw (fix aesthetical issues).
    WinRestore
    WinActivate
}

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
    Case "U": ShiftGearMouseMove(0, -iOffset) ;Up
    Case "D": ShiftGearMouseMove(0, iOffset)  ;Down
    Case "L": ShiftGearMouseMove(-iOffset, 0) ;Left
    Case "R": ShiftGearMouseMove(iOffset, 0)  ;Right
    Default: MsgBox, No such direction: %cDirection%
    }
}

ShiftGearMouseMove(X, Y) {
    Send, {RShift down}
    MouseMove, %X%, %Y%, , R
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

    ; Move gear stick in specified direction
    Shift(cDirection) {
        ShiftGear(cDirection)
        return this.oDirections[cDirection]
    }

    InitLinkedStates() { ;Создаем ответные связи на этот экземпляр класса
        for cDirection, oState in this.oDirections {
            cOppositeDirection := this.InvertDirection(cDirection)
            oState.oDirections[cOppositeDirection] := this
        }
    }

    InvertDirection(cDirection) {
        Switch cDirection
        {
        Case "L": return "R"
        Case "R": return "L"
        Case "U": return "D"
        Case "D": return "U"
        Default: MsgBox, No such direction: %cDirection%
        }
    }
}

class GearBox {
    oCurrentState := {}
    oResetState := {}

    __New(oCurrentState) {
        this.oCurrentState := this.oResetState := oCurrentState
        this.OutputDebugCurrentGear()
    }

    ; Example input: "LLU" (left -> left -> up)
    ExecuteShiftSequence(sDirectionSequence) {
        Loop, Parse, sDirectionSequence
        {
            this.oCurrentState := this.oCurrentState.Shift(A_LoopField)
            this.OutputDebugCurrentGear()
        }
    }

    ShiftGear(iTargetGear) {
        sDirectionSequence := this.FindShiftSequence(this.oCurrentState, iTargetGear)
        if (sDirectionSequence)
            this.ExecuteShiftSequence(sDirectionSequence)
        else
            this.WrongGearSound()
    }

    ShiftGearManual(cDirection) {
        ; oDirections содержит связь для данного направления перемещения рычага КПП
        if (IsObject(this.oCurrentState.oDirections[cDirection]))
            this.ExecuteShiftSequence(cDirection)
        else ;You can't shift in that direction
            this.WrongGearSound()
    }

    ; Example result: "ULD" (up -> left -> down)
    FindShiftSequence(oSearchState, iTargetGear, iParentGear := -1, sTempSequence := "") {
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

    ; Reset to initial State if you loose sync in-game gearbox with script GearBox.
    Reset() {
        this.oCurrentState := this.oResetState
        this.OutputDebugCurrentGear()
    }

    WrongGearSound() {
        Random, i, 0, 5
        SoundPlay, SnowRunnerShift%i%.mp3, Wait ;Wait until play finish
        SoundPlay, StopPlayback.mp3 ;Release allocated codecs
        this.OutputDebugCurrentGear(true)
    }

    OutputDebugCurrentGear(bWrongGear := false) {
        msg := "Gear Position: "
        if (bWrongGear)
            msg .= "Пиздец блять!"
        else
            msg .= this.oCurrentState.iGear
        OutputDebug, % msg "`n"
    }
}

Refuel(bRefuelWithTrailer := false) {
    Send, c
    Sleep, 250
    FillFullTank()
    if (bRefuelWithTrailer) {
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

ShowHelpWindow(ByRef str := "") {
    static bToggle := false
    iCharWidth := 9 ; char width by default
    iPadding := 10 ; padding from window's border by default
    iWidth := 0

    if (bToggle := !bToggle) {
        Loop, Parse, str, `n, `r
            if (iWidth < StrLen(A_LoopField))
                iWidth := StrLen(A_LoopField)
        iWidth := iWidth * iCharWidth + 2 * iPadding
        Progress, zh0 b2 c0 w%iWidth%, %str%, , , Consolas
    }
    else
        Progress, Off
}

ToolTip(sMessage, iDisplayTime := 1) {
    CoordMode, ToolTip, Client
    ToolTip, % sMessage, 0, 0
    Sleep, %iDisplayTime%000
    ToolTip
}
