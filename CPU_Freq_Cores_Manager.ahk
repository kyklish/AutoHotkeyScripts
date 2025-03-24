#Include <_COMMON_SETTINGS_>
;-------------------------------------------------------------------------------
;ALL INFO ABOUT POWER PLANS HERE ==> "Install\System\CPU Parking\_INFO_"
;-------------------------------------------------------------------------------
;Windows 11: Core Parking disabled in default power plans.
;   When Core Parking disabled all cores are always active.
;   Your CPU can't gain maximum Turbo frequency, because it needs single active core!
;-------------------------------------------------------------------------------
;TODO Directly set CPU frequency (Only in Win11)
;   SUB_PROCESSOR 75b0ae3f-bce0-45a7-8c89-c9611c25e100 Maximum processor frequency (in MHz)
;   SUB_PROCESSOR 75b0ae3f-bce0-45a7-8c89-c9611c25e101 Maximum processor frequency for Processor Power Efficiency Class 1 (in MHz)
;-------------------------------------------------------------------------------
;Добавить в автозагрузку команду установки Balanced плана (опционально)
;Ну будем портить Balanced Power Scheme, создадим новый на его базе
;   POWERCFG /DUPLICATESCHEME 381b4222-f694-41f0-9685-ff5bb260df2e FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF
;   POWERCFG /CHANGENAME FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF "AHK" "Balanced power plan for AHK: CPU_Freq_Cores_Manager"
;-------------------------------------------------------------------------------
;GUID of the target power plan
TARGET_SCHEME := "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
;GUID alias of the current power plan
;TARGET_SCHEME := "SCHEME_CURRENT"
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
        ;Strings: logical equal (=), case-sensitive-equal (==)
        ;Digits both are logical equal
        if (value = needle)
            return index
    if !(IsObject(haystack))
        throw Exception("Bad haystack!", -1, haystack)
    return 0
}
;-------------------------------------------------------------------------------
PowerWriteMaxProcessorStateValueIndex(ByRef Value, ByRef Mode)
{
    global TARGET_SCHEME
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC"))
    {
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
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR %PROCCORESMIN% %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
}
;-------------------------------------------------------------------------------
;"Install\System\CPU Parking\_INFO_\ReadMe.rar\Processor State Freq Test.txt"
;CPU P-State [%] and corresponding CPU Frequency [GHz] (found manually)
ArrayCPUStateInPercent := [ 30,  31,  34,  40,  46,  53,  56,  62,  68,  71,  78,  84,  90,  93,  99, 100]
ArrayCPUFreq :=           [0.8, 1.0, 1.1, 1.3, 1.5, 1.7, 1.8, 2.0, 2.2, 2.3, 2.5, 2.7, 2.9, 3.0, 3.2, 3.6]
WriteProcessorStateSetting(ByRef Index)
{
    global ArrayCPUStateInPercent
    global ArrayCPUFreq
    CPUState := ArrayCPUStateInPercent[Index]
    PowerWriteMaxProcessorStateValueIndex(CPUState, "AC") ;Line
    ; PowerWriteMaxProcessorStateValueIndex(CPUState, "DC") ;Battery
    OSD(ArrayCPUFreq[Index] . "GHz")
}
;-------------------------------------------------------------------------------
ArrayCPUCoresInPercent := [25, 50, 75, 100] ;количество работающих ядер процессора в %
WriteProcessorCoresSetting(ByRef Index)
{
    global ArrayCPUCoresInPercent
    CPUCores := ArrayCPUCoresInPercent[Index]
    PowerWriteCoreParkingMaxCoresValueIndex(CPUCores, "AC")
    ; PowerWriteCoreParkingMaxCoresValueIndex(CPUCores, "DC")
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
SetCPUFreqInGHz(ByRef Freq) ;Frequency in x.x [GHz]
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
        ; PowerWriteCoreParkingMinCoresValueIndex(100, "DC")
        OSD("Core Parking Disabled")
    }
    else {
        CPUParkingEnabled := true
        PowerWriteCoreParkingMinCoresValueIndex(0, "AC")
        ; PowerWriteCoreParkingMinCoresValueIndex(0, "DC")
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
        ; PowerWriteMinProcessorStateValueIndex(100, "DC")
        OSD("C-State Disabled")
    }
    else {
        CPUCStateEnabled := true
        PowerWriteMinProcessorStateValueIndex(0, "AC")
        ; PowerWriteMinProcessorStateValueIndex(0, "DC")
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

NumpadDot & NumpadSub:: StepCPUFreq(-DeltaP) ;уменьшаем частоту CPU
NumpadDot & NumpadAdd:: StepCPUFreq(+DeltaP) ;увеличиваем частоту CPU
NumpadDot & NumpadDiv::  StepCPUCores(-DeltaC) ;уменьшаем количество работающих ядер CPU
NumpadDot & NumpadMult:: StepCPUCores(+DeltaC) ;увеличиваем количество работающих ядер CPU

NumpadDot & Numpad7:: SetActivePowerScheme("a1841308-3541-4fab-bc81-f71556f20b4a", "Power Saver PS")
NumpadDot & Numpad8:: SetActivePowerScheme("381b4222-f694-41f0-9685-ff5bb260df2e", "Balanced PS")
NumpadDot & Numpad9:: SetActivePowerScheme("8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c", "High Performance PS")
NumpadDot & Numpad1:: SetCPUFreqInGHz(1.0)
NumpadDot & Numpad2:: SetCPUFreqInGHz(2.0)
NumpadDot & Numpad3:: SetCPUFreqInGHz(3.0)
NumpadDot & Numpad4:: SetCPUFreqInGHz(2.5)
NumpadDot & Numpad5:: RestoreMaxFreqCores() ;восстановить максимальные значения частоты и количества работающих ядер
NumpadDot & Numpad6:: ToggleCPUParking()
NumpadDot & Numpad0:: ShowCustomFreqAHKInfo()
NumpadDot & NumpadEnter:: ToggleCPUCState()

;Есть два варианта реализации прозрачной работы клавиши-модификатора:
;   ~NumpadDot & NumKEY: Func()
;       добавить [~] везде тильду перед NumpadDot для прозрачной работы клавиши
;       NumpadDot НЕ БЛОКИРУЕТСЯ при любом ее нажатии
;       одиночное нажатие на NumpadDot срабатывает на НАЖАТИЕ клавиши
;       системное автоповторение при длительном нажатии РАБОТАЕТ
;   $NumpadDot:: Send {NumpadDot}
;       явно отсылать событие нажатия на клавишу для ее прозрачной работы
;       NumpadDot БЛОКИРУЕТСЯ при срабатывании комбинации клавиш
;       одиночное нажатие на NumpadDot срабатывает на ОТПУСКАНИЕ клавиши
;       системное автоповторения при длительном нажатии НЕ РАБОТАЕТ

$NumpadDot:: Send {NumpadDot} ;для прозрачной работы клавиши, иначе NumpadDot не будет работать как точка при наборе текста, NumpadDot блокируется при срабатывании комбинации клавиш, есть один минус - срабатывает только на отпускание клавиши, соответственно нет автоповторения при длительном нажатии
