DetectHiddenWindows, On

TARGET_SCHEME := "d740827b-295c-4564-b160-6c98ca38069c" ;GUID того плана энергосбережения, которого будем "мучать" (заранее нужно создать новый Power Scheme в Windows на базе Balanced Power Scheme и к примеру назвать его "CustomFreqAHK", чтобы не портить Balanced план, добавить в автозагрузку комманду установки Balanced плана)

/*
GetCPUCurrentClockSpeed()
{
    sWQLQuery := "Select CurrentClockSpeed From Win32_Processor"
    oWMI := ComObjGet("winmgmts:")
    oQueryEnum := oWMI.ExecQuery(sWQLQuery)._NewEnum()
    if (oQueryEnum[oCPU])
        return oCPU.CurrentClockSpeed
}
*/

GetCPUData(Name)
{
    sWQLQuery := "Select " Name " From Win32_Processor"
    oWMI := ComObjGet("winmgmts:")
    oQueryEnum := oWMI.ExecQuery(sWQLQuery)._NewEnum()
    if (oQueryEnum[oCPU])
        return oCPU[Name]
}

GetCPUCurrentClockSpeed()
{
    return GetCPUData("CurrentClockSpeed")
}

GetCPUNumberOfCores()
{
    return GetCPUData("NumberOfCores")
}

SetMaxProcessorState(Value, Mode)
{
    global TARGET_SCHEME
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC")) ;for strings: logical equal (=), case-sensitive-equal (==) ;for digits both are logical equal
    {
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR PROCTHROTTLEMAX %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
    else
        throw Exception("Bad Value or Mode", -1)
}

SetMinProcessorState(Value, Mode)
{
    global TARGET_SCHEME
    if ((0 <= Value && Value <= 100) && (Mode = "AC" || Mode = "DC")) ;for strings: logical equal (=), case-sensitive-equal (==) ;for digits both are logical equal
    {
        RunWait, %ComSpec% /c powercfg -set%Mode%valueindex %TARGET_SCHEME% SUB_PROCESSOR PROCTHROTTLEMIN %Value%,, Hide
        RunWait, %ComSpec% /c powercfg -setactive %TARGET_SCHEME%,, Hide
    }
    else
        throw Exception("Bad Value or Mode", -1)
}

CreateAssocArray(m)
{
    obj := {}
    len := m.Length() / 2
    Loop, % len {
        i := A_Index * 2 - 1
        obj[m[i]] := m[i + 1]
        obj[m[i + 1]] := m[i]
        obj[A_Index + 100] := [m[i], m[i + 1]]
    }
    return obj
}

obj := CreateAssocArray([1, 0.8, 31, 1.0, 34, 1.3])

;MsgBox % obj[31] " " obj[1.3] " " obj[101][2]

StartDummyLoad()
{
    Code := "
    (LTrim
        #NoTrayIcon
        #Persistent
        SetBatchLines, -1
        while (true)
    {}
    )"
    return ExecScript(Code, false)
}

FindProcessorState(StartPosition := 0, DummyLoadStartPosition := 95)
{
    ;WMI not detect Intel Turbo Boost frequency :(
    Loop, 100 {
        if (A_Index < StartPosition)
            Continue
        SetMaxProcessorState(A_Index, "AC")
        SetMinProcessorState(A_Index, "AC")
        ;if (A_Index >= DummyLoadStartPosition && !Load) {
        ;Load := true
        ;DummyLoadPID := StartDummyLoad()
        ;}
        Freq := GetCPUCurrentClockSpeed()
        if (Freq != FreqPrev) {
            FreqPrev := Freq
            ;sToolTip .= Format("{:3i}% -> {:4i}MHz`n", A_Index, Freq)
            sToolTip .= A_Index "% -> " Freq "MHz`n"
            ;sToolTip .= A_Index "% -> " Round(Freq / 1000, 1) "GHz`n"
            sResult .= A_Index "," Round(Freq / 1000, 1) ","
        }
        ToolTip % "CPU State = " A_Index "%`n" sToolTip
    }
    ;WinClose, ahk_pid %DummyLoadPID%
    SetMinProcessorState(0, "AC")
    Clipboard := "[" SubStr(sResult, 1, -1) "]" ; trim last comma
}

FindProcessorState(9)
MsgBox Done

!x:: ExitApp
!z:: Reload
