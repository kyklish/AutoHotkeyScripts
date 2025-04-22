#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

sWinTitle := "Services: I do not use..."
sFileNameServices         := "Services.csv"
sFileNameServicesDefault := "Services_Default.csv"

sMask := GetMask("cbdhsvc")

oDB := new Database(sFileNameServices, sFileNameServicesDefault)
oDB_Default := new Database(sFileNameServicesDefault) ; Helping DB with DEFAULT values
oDB.Load()                    ;   Load file with TWEAKED values
oDB_Default.Load(false)       ;   Load file with DEFAULT values (skip checks)
oDB.Update(oDB_Default.oTabs) ; Add DEFAULT values to main DB
oDB.Save()                    ; Update file with DEFAULT values on mismatch (add new entries, remove old)

Gosub CreateGui
Gosub ButtonRefresh
Gui Show,, %sWinTitle%
GuiControl, Focus, Read&Me

!x::ExitApp
!z::Reload

CreateGui:
    sEditControlVarName := "EditInfo"
    sButtonStatus := "Status"
    oEditParams := GuiGetEditParams(oDB.oTabs)
    ; Calculations for Consolas font in Edit control
    ;  3 = Two button rows (above + below Edit control) + Tabs header
    ; 21 = Button step, 12 = Text step in Edit control
    iEditRows   := Round((oEditParams.iGroupCount + 3) * 21/12)
    iEditWidth  := Round((oEditParams.iGroupNameLen + oEditParams.iServiceNameLen + StrLen("_" sMask) + 4) * 6)
    Gui New, +LastFound
    ; Gui New, +AlwaysOnTop +LastFound ; No flickering of console window
    Gui Font, , Consolas
    Gui Add, Edit, v%sEditControlVarName% ReadOnly -Wrap r%iEditRows% w%iEditWidth%
    Gui Font, , Verdana
    Gui Add, Button, yp x+m Section Default, Read&Me
    Gui Add, Button, yp x+m, Check &Safe
    Gui Add, Button, yp x+m, Check &Moderate
    Gui Add, Button, yp x+m, &Check All
    Gui Add, Button, yp x+m, &UnCheck All
    Gui Add, Tab3, xs vCurrentTab, % GuiGetTabNames(oDB.oTabs)
    Gui Margin, , 0 ; Too many buttons, make them compact
    For sTab, oTab in oDB.oTabs {
        Gui Tab, %sTab%
        For _, sGroup in GetOrderedNamesInArray(oTab.oGroups) {
            ; Control var names in this loop must have two-char suffix.
            ;   See GuiGetGroupName(), GuiSetCheckBoxAll().
            sBtnOptions := A_Index == 1 ? "Section" : "xs"
            Gui Add, Button, %sBtnOptions% gButtonStatus v%sGroup%bt, %sButtonStatus%
            Gui Add, CheckBox, gCheckBox v%sGroup%cb yp+5 x+m, % oTab.oGroups[sGroup].sDescr
        }
    }
    Gui Tab
    Gui Margin, , 5
    Gui Add, Button, Section, &Apply
    Gui Add, Button, ys, Sto&p
    Gui Add, Button, ys, &Refresh
    Gui Add, Button, ys, &Edit CSV
    Gui Add, Button, ys, &Sort CSV
    Gui Add, Button, ys, Reload
    Gui Add, Button, ys, E&xit
Return

ButtonExit:
GuiClose:
GuiEscape:
ExitApp

ButtonRefresh:
    sRunningServices := GetRunningServices()
    GuiShowRunningServices(sRunningServices, oDB.oTabs)
    GuiUpdateCheckBoxes(oDB.oTabs)
    WinActivate ; RunWaitCMD() in different functions deactivate window
Return

ButtonReadMe:
    sStr := ""
    sStr .= "Some registry keys needs SYSTEM rights to change them.`n`n"
    sStr .= "[Services.cmd]: run compiled version of this script with SYSTEM rights.`n"
    sStr .= "[" sFileNameServicesDefault "]: original startup values of the services.`n"
    sStr .= "[" sFileNameServicesDefault "]: creates on first start of the script.`n`n"
    sStr .= "Modify [" sFileNameServices "]:`n - add new`n - del old`n - edit`n - reorder TABs/GROUPs`n"
    sStr .= "Sort & Update [" sFileNameServices "] + [" sFileNameServicesDefault "]:`n - press button [Sort CSV]`n`n"
    sStr .= "[Stop] button:`n - stop checked services`n"
    sStr .= "[Apply] button:`n - stop checked services`n - set startup value of all services accordingly to checkboxes value`n"
    sStr .= "[Status] button:`n - show CurrentStartup:Startup:Status:Service`n"
    sStr .= "[Refresh] button:`n - refresh info about running services and checkboxes value`n"
    sStr .= "[CheckBox]:`n - show associated GROUP name`n"
    ; MsgBox(A_DefaultGui, "I", sStr)
    GuiShowText(sStr)
Return

ButtonReload:
    Reload
Return

ButtonEditCSV:
    Run Notepad.exe %sFileNameServices%
Return

ButtonSortCSV:
    oDB.Save(true)
Return

ButtonApply:
    GuiApply(oDB.oTabs)
    Gosub ButtonRefresh
Return

ButtonStop:
    GuiApply(oDB.oTabs, false)
    Gosub ButtonRefresh
Return

; Stop services, set startup type
GuiApply(oTabs, bSetStartupType := true) {
    If (!A_IsAdmin) {
        MsgBox(A_DefaultGui, "E", "Need admin rights")
        Return
    }
    Gui Submit, NoHide
    sRunningServices := GetRunningServices()
    For _, oTab in oTabs
        For sGroup, oGroup in oTab.oGroups {
            GuiControlGet, bChecked, , %sGroup%cb
            For _, oService in oGroup.oServices {
                sStr := ""
                If (bChecked) {
                    If (IsServiceRunning(sRunningServices, oService.sName)) {
                        sStr .= " Stop:" oService.sName "`n"
                        StopService(oService.sName)
                    }
                    If (bSetStartupType) {
                        sStr .= "  Set:" oService.sName ":" oService.iStartup "`n"
                        SetStartupType(oService.sName, oService.iStartup)
                    }
                } Else {
                    ; DO NOT START services.
                    ; Most of them do not start on Windows startup.
                    ; If (!IsServiceRunning(sRunningServices, oService.sName)) {
                    ;     sStr .= "Start:" oService.sName "`n"
                    ;     StartService(oService.sName)
                    ; }
                    If (bSetStartupType) {
                        SetStartupType(oService.sName, oService.iStartupDefault)
                        sStr .= "  Set:" oService.sName ":" oService.iStartupDefault "`n"
                    }
                }
                GuiShowText(sStr)
            }
        }
}

ButtonCheckSafe:
    GuiSetCheckBoxProfile(oDB.oTabs, 1)
Return

ButtonCheckModerate:
    GuiSetCheckBoxProfile(oDB.oTabs, 2)
Return

ButtonCheckAll:
    GuiSetCheckBoxAll(oDB.oTabs, 1)
Return

ButtonUnCheckAll:
    GuiSetCheckBoxAll(oDB.oTabs, 0)
Return

ButtonStatus:
    sRunningServices := GetRunningServices()
    sStr := ""
    ; [A_GuiControl] is equal to the variable name in the [Gui Add, Button] command
    sGroup := GuiGetGroupName(A_GuiControl)
    For _, oService in oDB.oTabs[GuiGetCurrentTab(oDB.oTabs)].oGroups[sGroup].oServices {
        sStr .= GuiGetStatusLine(sRunningServices, oService.sName, oService.iStartup) "`n"
        If (IsServiceExist(oService.sName "_" sMask))
            sStr .= GuiGetStatusLine(sRunningServices, oService.sName "_" sMask, oService.iStartup) "`n"
    }
    GuiShowText(sStr)
    WinActivate ; RunWaitCMD() in different functions deactivate window
Return

CheckBox() {
    sStr := GuiGetGroupName(A_GuiControl)
    GuiShowText(sStr)
}

;===============================================================================

GuiGetCurrentTab(oTabs) {
    global CurrentTab
    Gui Submit, NoHide
    Return CurrentTab
}

GuiGetTabNames(oTabs) {
    sStr := ""
    For _, sTab in GetOrderedNamesInArray(oTabs)
        sStr .= sTab "|"
    Return SubStr(sStr, 1, -1)
}

; All control var names must us two char suffix
GuiGetGroupName(sControlVarName) {
    ; See Gui Add, Button
    ; Example: GroupBt ==> Group
    Return SubStr(sControlVarName, 1, -2)
}

; Longest Group Name, Longest Service Name, Biggest Group Count
GuiGetEditParams(oTabs) {
    oEditParams := { iGroupCount: 0, iGroupNameLen: 0, iServiceNameLen: 0 }
    For _, oTab in oTabs {
        If (oEditParams.iGroupCount < oTab.oGroups.Count())
            oEditParams.iGroupCount := oTab.oGroups.Count()
        For sGroup, oGroup in oTab.oGroups {
            If (oEditParams.iGroupNameLen < StrLen(sGroup))
                oEditParams.iGroupNameLen := StrLen(sGroup)
            For _, oService in oGroup.oServices
                If (oEditParams.iServiceNameLen < StrLen(oService.sName))
                    oEditParams.iServiceNameLen := StrLen(oService.sName)
        }
    }
    Return oEditParams
}

GuiSetCheckBoxProfile(oTabs, iProfile) {
    For _, oTab in oTabs
        For sGroup, oGroup in oTab.oGroups {
            If (oGroup.iProfile <= iProfile)
                GuiSetCheckBox(sGroup, 1)
            Else
                GuiSetCheckBox(sGroup, 0)
        }
}

GuiSetCheckBox(sGroup, iValue) {
    GuiControl, , %sGroup%cb, %iValue%
}

GuiSetCheckBoxAll(oTabs, iValue) {
    For _, oTab in oTabs
        For sGroup, _ in oTab.oGroups
            GuiSetCheckBox(sGroup, iValue)
}

GuiUpdateCheckBoxes(oTabs) {
    For _, oTab in oTabs
        For sGroup, oGroup in oTab.oGroups {
            iCheckedValue := 1
            For _, oService in oGroup.oServices {
                iStartupCurrent := GetStartupType(oService.sName, true)
                If (iStartupCurrent != oService.iStartup) {
                    iCheckedValue := 0
                    Break
                }
            }
            GuiSetCheckBox(sGroup, iCheckedValue)
        }
}

GuiShowRunningServices(sRunningServices, oTabs) {
    global sMask
    sStr := ""
    oEditParams := GuiGetEditParams(oTabs)
    ; Tabulator not reliable in Edit control, use Format()
    ; First string with LEFT alignment, padding with spaces
    sFormatStr := "{:-" oEditParams.iGroupNameLen "} {}"
    sStr .= Format(sFormatStr, "Mask:" sMask, "RUNNING SERVICES") "`n`n"
    sStr .= Format(sFormatStr, "GROUP (CheckBox)","[2:Auto 3:Manual 4:Disabled] : Name") "`n`n"
    For _, oTab in oTabs
        For sGroup, oGroup in oTab.oGroups
            For _, oService in oGroup.oServices {
                If (IsServiceRunning(sRunningServices, oService.sName))
                    sStr .= Format(sFormatStr, sGroup, GetStartupType(oService.sName) " : " oService.sName) "`n"
                If (IsServiceExist(oService.sName "_" sMask))
                    If (IsServiceRunning(sRunningServices, oService.sName "_" sMask))
                        sStr .= Format(sFormatStr, sGroup, GetStartupType(oService.sName "_" sMask) " : " oService.sName "_" sMask) "`n"
            }
    GuiShowText(sStr)
}

GuiShowText(sStr := "") {
    global sEditControlVarName
    GuiControl, Text, %sEditControlVarName%, %sStr%
}

GuiGetStatusLine(sRunningServices, sName, iStartup) {
    iStartupCurrent := GetStartupType(sName)
    sState := GetState(sRunningServices, sName)
    Return iStartupCurrent ":" iStartup ":" sState ":" sName
}

;===============================================================================

GetOrderedNamesInArray(oObjs) {
    oNewObj := {}
    For sName, oObj in oObjs
        oNewObj[oObj.iIndex] := sName
    Return oNewObj
}

;===============================================================================

IsServiceExist(sName) {
    GetStartupType(sName)
    Return !ErrorLevel
}

IsServiceRunning(sRunningServices, sName) {
    global sMask
    Return RegExMatch(sRunningServices, "\b" sName "\b") || RegExMatch(sRunningServices, "\b" sName "_" sMask "\b")
}

; Service: cbdhsvc_XXXXX. Input: cbdhsvc
GetMask(sServiceNameWithoutMask) {
    ; FOR /F "usebackq tokens=3 delims=_" %S IN (`SC QUERY ^| FIND /I "SERVICE_NAME: cbdhsvc"`) DO @ECHO %S
    sResult := RunWaitCMD("FOR /F ""usebackq tokens=3 delims=_"" %S IN (``SC QUERY ^| FIND /I ""SERVICE_NAME: " sServiceNameWithoutMask """``) DO @ECHO %S")
    Return Trim(sResult, " `t`r`n")
}

GetStartupType(sServiceName, bShowMsgBoxOnError := false) {
    RegRead, sStart, HKLM\SYSTEM\CurrentControlSet\Services\%sServiceName%, Start
    If (ErrorLevel && bShowMsgBoxOnError)
        MsgBox(A_DefaultGui, "W", sServiceName ": NO REG ENTRY")
    Return sStart
}

SetStartupType(sServiceName, iStart) {
    RegWrite, REG_DWORD, HKLM\SYSTEM\CurrentControlSet\Services\%sServiceName%, Start, %iStart%
    If (ErrorLevel)
        MsgBox(A_DefaultGui, "E", sServiceName ": CAN'T WRITE (NEED ADMIN RIGHTS)")
}

GetRunningServices() {
    ; FOR /F "usebackq tokens=2" %S IN (`SC QUERY ^| FIND /I "SERVICE_NAME"`) DO @ECHO %S
    sResult := RunWaitCMD("FOR /F ""usebackq tokens=2"" %S IN (``SC QUERY ^| FIND /I ""SERVICE_NAME""``) DO @ECHO %S")
    sResult := StrReplace(sResult, "`r")
    Return Trim(sResult)
}

GetState(sRunningServices, sServiceName) {
    ; ^| escape pipe char. It has special meaning during parsing commands.
    ; FOR /F "usebackq tokens=4" %S IN (`SC QUERY SERVICE_NAME ^| FIND /I "STATE"`) DO @ECHO %S
    ; sResult := RunWaitCMD("FOR /F ""usebackq tokens=4"" %S IN (``SC QUERY " sServiceName " ^| FIND /I ""STATE""``) DO @ECHO %S")
    ; Return Trim(sResult, " `t`r`n")
    Return RegExMatch(sRunningServices, "\b" sServiceName "\b") ? "RUNNING" : "STOPPED"
}

StartService(sServiceName) {
    global sMask
    RunWaitCMD("sc start " sServiceName)
    If (IsServiceExist(sServiceName "_" sMask))
        RunWaitCMD("sc start " sServiceName "_" sMask)
}

StopService(sServiceName) {
    global sMask
    RunWaitCMD("sc stop " sServiceName)
    If (IsServiceExist(sServiceName "_" sMask))
        RunWaitCMD("sc stop " sServiceName "_" sMask)
}

;===============================================================================

RunWaitCMD(commands) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObjCreate("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(A_ComSpec " /Q /K echo off")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}

class Database {
    oTabs := {}
    bIsModified := false
    sAllServices := ""
    sFileName        := sFileName        ; File with tweaked services values
    sFileNameDefault := sFileNameDefault ; File with default services values

    __New(sFileName, sFileNameDefault := "") {
        this.sFileName := sFileName
        this.sFileNameDefault := sFileNameDefault
    }

    ; If database has empty group show its name
    ShowWarningOnEmptyGroup() {
        For _, oTab in this.oTabs
            For sGroup, oGroup in oTab.oGroups
                If (!IsObject(oGroup.oServices))
                    MsgBox(A_DefaultGui, "W", "[" sGroup "] group is EMPTY!")
    }

    ; If database has duplicate services show its name
    ShowWarningOnServiceDuplicate() {
        sSkipService := ""
        For _, oTab in this.oTabs
            For sGroup, oGroup in oTab.oGroups
                For _, oService in oGroup.oServices {
                    ; Try search second occurrence && Skip if we already showed message
                    sNeedle := "\b" oService.sName "\b"
                    iFoundPos       := RegExMatch(this.sAllServices, sNeedle)
                    iSecondFoundPos := RegExMatch(this.sAllServices, sNeedle, , iFoundPos + StrLen(oService.sName))
                    If (iSecondFoundPos && !RegExMatch(sSkipService, sNeedle)) {
                        sSkipService .= oService.sName "`n"
                        MsgBox(A_DefaultGui, "W", "The service [" oService.sName "] has DUPLICATES!")
                    }
                }
    }

    Load(bCheckCsvMistakes := true) {
        this.ReadCSV(this.sFileName)
        If (bCheckCsvMistakes) {
            this.ShowWarningOnEmptyGroup()
            this.ShowWarningOnServiceDuplicate()
        }
    }

    Save(bSortCSV := false) {
        If (bSortCSV) {
            ; Data in Database always sorted. Just overwrite CSV to sort it.
            ; Add new services in any place in CSV file.
            ; Read it and save it to [sFileName].
            ; Now we have sorted CSV file.
            this.WriteCSV(this.sFileName,       false) ; Save TWEAKED services values
            this.WriteCSV(this.sFileNameDefault, true) ; Save DEFAULT services values
        } Else
            If (this.bIsModified) {
                this.WriteCSV(this.sFileNameDefault)
                this.bIsModified := false
            }
    }

    ReadCSV(sFileName) { ; Sync any changes with WriteCSV()
        this.sAllServices := ""
        iGroupIndex := 1
        iTabIndex := 1
        Loop, Read, %sFileName%
        {
            sLine := Trim(A_LoopReadLine)
            If (sLine == "" || SubStr(sLine, 1, 1) == ";")
                Continue ; Skip empty lines and comments
            oCSV := []
            Loop, Parse, sLine, CSV, %A_Space%%A_Tab%
                oCSV.Push(Trim(A_LoopField))

            Switch oCSV[1] {
            Case "TAB":
                oCSV.RemoveAt(1, 1) ; Remove first element in linear array
                sTab := oCSV[1]
                this.oTabs[sTab] := {}
                this.oTabs[sTab].oGroups := {}
                this.oTabs[sTab].iIndex := iTabIndex++
            Case "GROUP":
                oCSV.RemoveAt(1, 1) ; Remove first element in linear array
                ;@AHK++AlignAssignmentOn
                iProfile := oCSV[1]
                sTab     := oCSV[2]
                sGroup   := oCSV[3]
                sDescr   := oCSV[4]
                ;@AHK++AlignAssignmentOff
                ; If object is not exist create it
                If (!IsObject(this.oTabs[sTab].oGroups[sGroup]))
                    this.oTabs[sTab].oGroups[sGroup] := {}
                this.oTabs[sTab].oGroups[sGroup].iIndex   := iGroupIndex++
                this.oTabs[sTab].oGroups[sGroup].iProfile := iProfile
                this.oTabs[sTab].oGroups[sGroup].sDescr   := sDescr
            Case "SERVICE":
                bIsFound := false
                oCSV.RemoveAt(1, 1) ; Remove first element in linear array
                ;@AHK++AlignAssignmentOn
                sGroup   := oCSV[1]
                iStartup := oCSV[2]
                sName    := oCSV[3]
                ;@AHK++AlignAssignmentOff
                this.sAllServices .= sName "`n"
                oService := { sName: sName, iStartup: iStartup }
                For _, oTab in this.oTabs
                    ; Iterate through all GROUPs to find GROUP that exist.
                    ; It must be created at this time.
                    If (IsObject(oTab.oGroups[sGroup])) {
                        bIsFound := true
                        ; If object is not exist create it
                        If (!IsObject(oTab.oGroups[sGroup].oServices))
                            oTab.oGroups[sGroup].oServices := []

                        oTab.oGroups[sGroup].oServices.Push(oService)
                    }
                If (!bIsFound)
                    MsgBox(A_Gui, "E", sFileName "`n`nLine " A_Index ": Group name not found [" oCSV[1] "]")
            Default:
                MsgBox(A_Gui, "E", sFileName "`n`nLine " A_Index ": Wrong keyword [" oCSV[1] "]")
            }
        }
    }

    WriteCSV(sFileName, bWriteStartupDefault := true) { ; Sync any changes with ReadCSV()
        oFile := FileOpen(sFileName, "w `n")
        oFile.WriteLine(";CSV v1.0")

        oFile.WriteLine()
        oFile.WriteLine(";,TabName: unique single word + no numbers + used as variable name and as key in associative array")
        oFile.WriteLine(";TAB,TabName")
        For _, sTab in GetOrderedNamesInArray(this.oTabs)
            oFile.WriteLine("TAB," sTab)

        oFIle.WriteLine()
        oFile.WriteLine(";,Profile: 1=Safe,GroupName: unique single word + used as key in associative array")
        oFile.WriteLine(";GROUP,Profile,TabName,GroupName,Description")
        For _, sTab in GetOrderedNamesInArray(this.oTabs)
            For _, sGroup in GetOrderedNamesInArray(this.oTabs[sTab].oGroups)
                oFile.WriteLine("GROUP," this.oTabs[sTab].oGroups[sGroup].iProfile "," Format("{:U}", sTab) "," sGroup "," this.oTabs[sTab].oGroups[sGroup].sDescr)

        oFIle.WriteLine()
        oFile.WriteLine(";SERVICE,GroupName,StartupType,ServiceName")
        For _, sTab in GetOrderedNamesInArray(this.oTabs)
            For _, sGroup in GetOrderedNamesInArray(this.oTabs[sTab].oGroups)
                For _, oService in this.oTabs[sTab].oGroups[sGroup].oServices
                    oFile.WriteLine("SERVICE," sGroup "," (bWriteStartupDefault ? oService.iStartupDefault : oService.iStartup) "," oService.sName)

        oFile.Close()
    }

    Update(oTabsO) {
        ; Insert new entries.
        For sTab, oTab in this.oTabs {
            For sGroup, oGroup in oTab.oGroups {
                For i, oService in oGroup.oServices {
                    iStartupDefault := ""

                    For sTabO, oTabO in oTabsO
                        For sGroupO, oGroupO in oTabO.oGroups
                            For _, oServiceO in oGroupO.oServices
                                If (oServiceO.sName = oService.sName)
                                    iStartupDefault := oServiceO.iStartup

                    If (iStartupDefault)
                        oService.iStartupDefault := iStartupDefault
                    Else {
                        oService.iStartupDefault := GetStartupType(oService.sName)
                        this.bIsModified := true
                    }
                }
            }
        }
    }
}

MsgBox(sGui, cType, sText) {
    If (sGui)
        Gui %sGui%:+OwnDialogs
    Switch cType {
    Case "E":
        iOptions := 0x10
        sTitle := "Error"
    Case "I":
        iOptions := 0x40
        sTitle := "Info"
    Case "Q":
        iOptions := 0x124
        sTitle := "Question"
    Case "W":
        iOptions := 0x30
        sTitle := "Warning"
    Default:
        MsgBox(sGui, "E", "MsgBox(): Wrong param cType:" cType)
    }
    MsgBox % iOptions, % sTitle, % sText
}
