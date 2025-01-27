#Include <_COMMON_SETTINGS_>
;-------------------------------------------------------------------------------
;Windows 11: Core Parking disabled in default power plans.
;-------------------------------------------------------------------------------
;Добавить в автозагрузку команду установки Balanced плана (опционально)
;Ну будем портить Balanced Power Scheme, создадим новый на его базе
;   POWERCFG /DUPLICATESCHEME 381b4222-f694-41f0-9685-ff5bb260df2e FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF
;   POWERCFG /CHANGENAME FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF "AHK" "Balanced power plan for AHK: CPU_Freq_Cores_Manager"
;GUID того плана энергосбережения, который будем "мучать"
TARGET_SCHEME := "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
;-------------------------------------------------------------------------------
Process, Priority,, High ;L (or Low), B (or BelowNormal), N (or Normal), A (or AboveNormal), H (or High), R (or Realtime)
;-------------------------------------------------------------------------------
OSD(text)
{
    TimeOut := 750
    #Persistent
    ; BorderLess, no ProgressBar, font size 25, color text 009900
    Progress, hide Y600 W1000 b zh0 cwFFFFFF FM50 CT00BB00,, %text%, AutoHotKeyProgressBar, Backlash BRK
    WinSet, TransColor, FFFFFF 255, AutoHotKeyProgressBar
    Progress, show
    SetTimer, RemoveToolTip, %TimeOut%
    Return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    Progress, Off
    Return
}
;-------------------------------------------------------------------------------
; Checks if a value exists in an array (similar to HasKey)
;-------------------------------------------------------------------------------
; FoundPos := HasVal(Haystack, Needle)
HasVal(ByRef haystack, ByRef needle) {
    for index, value in haystack
        if (value = needle) ;for strings: logical equal (=), case-sensitive-equal (==) ;for digits both are logical equal
            return index
    if !(IsObject(haystack))
        throw Exception("Bad haystack!", -1, haystack)
    return 0
}
;-------------------------------------------------------------------------------
PowerWriteMaxProcessorStateValueIndex(ByRef Value, ByRef Mode)
{
    global TARGET_SCHEME
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC")) ;for strings: logical equal (=), case-sensitive-equal (==) ;for digits both are logical equal
    {
        ;MsgBox % "Value is " . Value . "Mode is " . Mode . "."
        ;"D:\SERGEY\Install\Info\CPU Parking\Command Line.txt"
        ;RunWait, %ComSpec% /c powercfg -set%Mode%valueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX %Value%,, Hide
        ;RunWait, %ComSpec% /c powercfg -setactive SCHEME_CURRENT,, Hide
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR PROCTHROTTLEMAX %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
}
;-------------------------------------------------------------------------------
PowerWriteMinProcessorStateValueIndex(ByRef Value, ByRef Mode)
{
    global TARGET_SCHEME
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC"))
    {
        ;MsgBox % "Value is " . Value . "Mode is " . Mode . "."
        ;"D:\SERGEY\Install\Info\CPU Parking\Command Line.txt"
        ;RunWait, %ComSpec% /c powercfg -set%Mode%valueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN %Value%,, Hide
        ;RunWait, %ComSpec% /c powercfg -setactive SCHEME_CURRENT,, Hide
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR PROCTHROTTLEMIN %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
}
;-------------------------------------------------------------------------------
PowerWriteCoreParkingMaxCoresValueIndex(ByRef Value, ByRef Mode)
{
    global TARGET_SCHEME
    PROCCORESMAX := "ea062031-0e34-4ff1-9b6d-eb1059334028" ;GUID для парковки ядер
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC"))
    {
        ;MsgBox % "Value is " . Value . "Mode is " . Mode . "."
        ;"D:\SERGEY\Install\Info\CPU Parking\Command Line.txt"
        ;RunWait, %ComSpec% /c powercfg -set%Mode%valueindex SCHEME_CURRENT SUB_PROCESSOR %PROCCORESMAX% %Value%,, Hide
        ;RunWait, %ComSpec% /c powercfg -setactive SCHEME_CURRENT,, Hide
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR %PROCCORESMAX% %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
}
;-------------------------------------------------------------------------------
PowerWriteCoreParkingMinCoresValueIndex(ByRef Value, ByRef Mode)
{
    global TARGET_SCHEME
    PROCCORESMIN := "0cc5b647-c1df-4637-891a-dec35c318583" ;GUID для парковки ядер
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC"))
    {
        ;MsgBox % "Value is " . Value . "Mode is " . Mode . "."
        ;"D:\SERGEY\Install\Info\CPU Parking\Command Line.txt"
        ;RunWait, %ComSpec% /c powercfg -set%Mode%valueindex SCHEME_CURRENT SUB_PROCESSOR %PROCCORESMIN% %Value%,, Hide
        ;RunWait, %ComSpec% /c powercfg -setactive SCHEME_CURRENT,, Hide
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR %PROCCORESMIN% %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
}
;-------------------------------------------------------------------------------
;"D:\SERGEY\Install\Info\CPU Parking\Processor State Freq Test.txt"
ArrayCPUStateInPercent := [ 30,  31,  34,  40,  46,  53,  56,  62,  68,  71,  78,  84,  90,  93,  99, 100] ;состояние (P-state) процессора в %
ArrayCPUFreq :=           [0.8, 1.0, 1.1, 1.3, 1.5, 1.7, 1.8, 2.0, 2.2, 2.3, 2.5, 2.7, 2.9, 3.0, 3.2, 3.6] ;частота процессора (МГц) в соответствии с P-state процессора
WriteProcessorStateSetting(ByRef Index)
{
    global ArrayCPUStateInPercent
    global ArrayCPUFreq
    CPUState := ArrayCPUStateInPercent[Index]
    PowerWriteMaxProcessorStateValueIndex(CPUState, "AC") ;Line
    PowerWriteMaxProcessorStateValueIndex(CPUState, "DC") ;Battery
    OSD(ArrayCPUFreq[Index] . "GHz")
}
;-------------------------------------------------------------------------------
ArrayCPUCoresInPercent := [25, 50, 75, 100] ;количество работающих ядер процессора в %
WriteProcessorCoresSetting(ByRef Index)
{
    global ArrayCPUCoresInPercent
    CPUCores := ArrayCPUCoresInPercent[Index]
    PowerWriteCoreParkingMaxCoresValueIndex(CPUCores, "AC")
    ;PowerWriteCoreParkingMaxCoresValueIndex(CPUCores, "DC")
    if(Index = 1)
        OSD(Index . " core")
    else
        OSD(Index . " cores")
    ;Or IF-ELSE, or this one line
    ;OSD("Cores num: " . Index)
}
;-------------------------------------------------------------------------------
ModifyArrayIndex(ByRef Index, ByRef Delta, ByRef ArrayLen) ;инкремент или декремент Index на величину Delta
{
    Index += Delta
    if (Index < 1)
    {
        Index := 1
        SoundBeepTwice()
    }
    else
        if (Index > ArrayLen)
        {
            Index := ArrayLen
            SoundBeepTwice()
        }
}
;-------------------------------------------------------------------------------
ArrayLenP := ArrayCPUStateInPercent.MaxIndex()
IndexP := ArrayLenP ;индекс массива для P-state
StepCPUFreq(ByRef Delta) ;изменяем частоту ступенчато, величина ступеньки == Delta
{
    global ArrayLenP
    global IndexP
    ;static IndexP := ArrayLenP ; здесь инициализация static не работает как в Си!!! поэтому используем глобальные переменные
    ModifyArrayIndex(IndexP, Delta, ArrayLenP)
    WriteProcessorStateSetting(IndexP)
}
;-------------------------------------------------------------------------------
IsCorrectArrayIndex(ByRef Index, ByRef ArrayLen)
{
    return (1 <= Index && Index <= ArrayLen)
}
;-------------------------------------------------------------------------------
SetCPUFreqInGHz(ByRef Freq) ;Freq == frequency in x.x GHz ;непосредственно задаем частоту CPU
{
    global ArrayCPUFreq
    global ArrayLenP
    global IndexP
    Index := HasVal(ArrayCPUFreq, Freq)
    if (IsCorrectArrayIndex(Index, ArrayLenP))
    {
        IndexP := Index
        WriteProcessorStateSetting(IndexP)
    }
    else
    {
        SoundBeepTwice()
        MsgBox % "Wrong Frequency Value " . Freq . "GHz"
        ;throw Exception("Bad Frequency Value!", -1, Freq)
    }
}
;-------------------------------------------------------------------------------
ArrayLenC := ArrayCPUCoresInPercent.MaxIndex()
IndexC := ArrayLenC ;индекс массива для количества ядер
StepCPUCores(ByRef Delta) ;изменяем количество ядер ступенчато, величина ступеньки == Delta
{
    global ArrayLenC
    global IndexC
    ;static IndexC := ArrayLenC ;здесь инициализация static не работает как в Си!!! поэтому используем глобальные переменные
    ModifyArrayIndex(IndexC, Delta, ArrayLenC)
    WriteProcessorCoresSetting(IndexC)
}
;-------------------------------------------------------------------------------
CPUParkingEnabled := true
ToggleCPUParking() ;вкл/откл парковку ядер
{
    global CPUParkingEnabled
    if (CPUParkingEnabled) {
        CPUParkingEnabled := false
        PowerWriteCoreParkingMinCoresValueIndex(100, "AC")
        ;PowerWriteCoreParkingMinCoresValueIndex(100, "DC")
        OSD("Core Parking Disabled")
    }
    else {
        CPUParkingEnabled := true
        PowerWriteCoreParkingMinCoresValueIndex(0, "AC")
        ;PowerWriteCoreParkingMinCoresValueIndex(0, "DC")
        OSD("Core Parking Enabled")
    }
}
;-------------------------------------------------------------------------------
CPUCStateEnabled := true
ToggleCPUCState() ;вкл/откл C-State процессора
{
    global CPUCStateEnabled
    if (CPUCStateEnabled) {
        CPUCStateEnabled := false
        PowerWriteMinProcessorStateValueIndex(100, "AC")
        ;PowerWriteMinProcessorStateValueIndex(100, "DC")
        OSD("C-State Disabled")
    }
    else {
        CPUCStateEnabled := true
        PowerWriteMinProcessorStateValueIndex(0, "AC")
        ;PowerWriteMinProcessorStateValueIndex(0, "DC")
        OSD("C-State Enabled")
    }
}
;-------------------------------------------------------------------------------
RestoreMaxFreqCores()
{
    global CPUParkingEnabled
    global CPUCStateEnabled
    global ArrayLenP
    global ArrayLenC
    global IndexP
    global IndexC
    IndexP := ArrayLenP
    IndexC := ArrayLenC
    WriteProcessorStateSetting(ArrayLenP)
    WriteProcessorCoresSetting(ArrayLenC)
    if(!CPUParkingEnabled)
        ToggleCPUParking()
    if(!CPUCStateEnabled)
        ToggleCPUCState()
}
;-------------------------------------------------------------------------------
SetActivePowerScheme(ByRef TARGET_SCHEME, ByRef Info)
{
    RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    OSD(Info)
}
;-------------------------------------------------------------------------------
ShowCustomFreqAHKInfo() ;показать текущие настройки плана CustomFreqAHK
{
    global ArrayCPUFreq
    global CPUParkingEnabled
    global CPUCStateEnabled
    global IndexP
    global IndexC
    text := ArrayCPUFreq[IndexP] . "GHz`n" . IndexC . " "  ;`n - new line
    if(IndexC = 1)
        text := text . "core"
    else
        text := text . "cores"
    if(CPUParkingEnabled)
        text := text . "`nCore Parking Enabled"
    else
        text := text . "`nCore Parking Disabled"
    if(CPUCStateEnabled)
        text := text . "`nC-State Enabled"
    else
        text := text . "`nC-State Disabled"
    OSD(text)

    ;Or IF-ELSE, or this one line
    ;OSD(ArrayCPUFreq[IndexP] . "GHz`n" . "Cores num: " . IndexC)
}
;-------------------------------------------------------------------------------
if (A_OSVersion != "WIN_7") { ;Read comment about Windows 11 at the top
    ;FALSE: guarantee restore power plan settings to default in RestoreMaxFreqCores()!
    CPUCStateEnabled := false
    CPUParkingEnabled := false
    RestoreMaxFreqCores()
}
;-------------------------------------------------------------------------------
DeltaP := 1 ;шаг изменения значения P-state процессора
DeltaC := 1 ;шаг изменения количества ядер процессора
;-------------------------------------------------------------------------------
/*
+F8:: RestoreMaxFreqCores() ;восстановить максимальные значения частоты и количества работающих ядер
+F9:: StepCPUFreq(-DeltaP) ;уменьшаем частоту CPU
+F10:: StepCPUFreq(+DeltaP) ;увеличиваем частоту CPU
+F11:: StepCPUCores(-DeltaC) ;уменьшаем количество работающих ядер CPU
+F12:: StepCPUCores(+DeltaC) ;увеличиваем количество работающих ядер CPU

+F1:: SetActivePowerScheme("381b4222-f694-41f0-9685-ff5bb260df2e", "Balanced  PS") ;Balanced Power Scheme
+F2:: SetActivePowerScheme("a1841308-3541-4fab-bc81-f71556f20b4a", "Power Saver PS") ;Power Saver Power Scheme
+F3:: SetCPUFreqInGHz(0.8) ;непосредственно задаем частоту в ГГц
+F4:: SetCPUFreqInGHz(1.3)
+F5:: SetCPUFreqInGHz(2.0)
+F6:: SetCPUFreqInGHz(2.5)
+F7:: SetCPUFreqInGHz(3.0)
;+F7:: SetActivePowerScheme("d740827b-295c-4564-b160-6c98ca38069c", "CustomFreqAHK PS") ; незачем, т.к. при любом изменении частоты или количества ядер автоматически устанавливается CustomFreqAHK Power Scheme
+Pause:: ShowCustomFreqAHKInfo()
*/
;-------------------------------------------------------------------------------

NumpadDot & Numpad9:: RestoreMaxFreqCores() ;восстановить максимальные значения частоты и количества работающих ядер
NumpadDot & NumpadSub:: StepCPUFreq(-DeltaP) ;уменьшаем частоту CPU
NumpadDot & NumpadAdd:: StepCPUFreq(+DeltaP) ;увеличиваем частоту CPU
NumpadDot & NumpadDiv:: StepCPUCores(-DeltaC) ;уменьшаем количество работающих ядер CPU
NumpadDot & NumpadMult:: StepCPUCores(+DeltaC) ;увеличиваем количество работающих ядер CPU

NumpadDot & Numpad7:: SetActivePowerScheme("381b4222-f694-41f0-9685-ff5bb260df2e", "Balanced  PS") ;Balanced Power Scheme
NumpadDot & Numpad8:: SetActivePowerScheme("a1841308-3541-4fab-bc81-f71556f20b4a", "Power Saver PS") ;Power Saver Power Scheme
NumpadDot & Numpad1:: SetCPUFreqInGHz(0.8) ;непосредственно задаем частоту в ГГц
NumpadDot & Numpad2:: SetCPUFreqInGHz(1.3)
NumpadDot & Numpad3:: SetCPUFreqInGHz(2.0)
NumpadDot & Numpad4:: SetCPUFreqInGHz(2.5)
NumpadDot & Numpad5:: SetCPUFreqInGHz(3.0)
NumpadDot & Numpad6:: ToggleCPUParking()
NumpadDot & Numpad0:: ShowCustomFreqAHKInfo()
NumpadDot & NumpadEnter:: ToggleCPUCState()
;~NumpadDot & Numpad0:: ShowCustomFreqAHKInfo() ;тильда для прозрачной работы клавиши, NumpadDot никогда не блокируется, одиночная клавиша NumpadDot срабатывает на нажатие, работает системное автоповторение при длительном нажатии, ниже приведен альтернативный вариант со своими недостатками

$NumpadDot:: Send {NumpadDot} ;для прозрачной работы клавиши, иначе NumpadDot не будет работать как точка при наборе текста, NumpadDot блокируется при срабатывании комбинации клавиш, есть один минус - срабатывает только на отпускание клавиши, соответственно нет автоповторения при длительном нажатии
