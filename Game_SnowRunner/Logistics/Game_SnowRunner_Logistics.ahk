; SnowRunner Logistics
; + added
; * changed
; - deleted
; ! bug fixed

; v1.0.0 - 2022-12-25
;  + Initial release.

; I destroy windows "Building", "Cargo", "Job" on purpose, don't want clean up
;   controls from previous use, create new windows with fresh empty controls.
;   It's little longer, but when all Buildings and Jobs will be added to Database
;   they become useless.
; Possible problem: transparent windows "Building" and "Job" overlaps "Main"
;   window. On wrong [sTransColor] "Main" window may become un-clickable. Change
;   color or set "Building" and "Job" windows' size to 1080x1080.

#Warn
#NoEnv
#SingleInstance Force
SetBatchLines -1
SetWorkingDir %A_ScriptDir%

sWinTitle := "SnowRunner Logistics"
Menu, Tray, Icon, SnowRunner.ico, 1, 1
Menu, Tray, Tip, %sWinTitle%

sGame := "Snowrunner.exe"
GroupAdd, Script, %sWinTitle% ahk_exe AutoHotkey.exe
GroupAdd, Game, ahk_exe %sGame%

;================================== DEBUG ======================================

; Run script with mock data. [Database.csv] and [UserProgress.csv] are intact.
TEST_DATA := False
; TEST_DATA := True

;================================ Settings =====================================

; Default region on start script
global sDefaultRegion := "MICHIGAN"
; Main window width
global W := 1920 ; 1750 minimum width
; How far can be mouse cursor from building to detect LMB click on building on map
global iRadiusDetection := 15
; Cargo icon size
global iIconSize := 20
; Text size job's cargo number, building's name
global iFontSizeCargo := 12
; Text size job's name
global iFontSizeJob := 8
; Text color
global sFontColor := "Yellow" ; "Red" looks good.
; Background color, which makes transparent (one window overlays another window).
;"sTransColor" must be not equal "sFontColor"! Color name: standard from HTML.
;"Green" color works well, other colors may not work properly, not tested.
global sTransColor := "Green"
; Number of job's, cargo's rows in GUI
global iGuiRowNum := 9 ; If bigger then 9, "Cargo" and "Job" windows must be higher

;=============================== Variables =====================================

; Database: jobs, buildings, regions, maps, etc...
global oDB := {}
; Database is modified (user add new Building or new Job)
global bDBModified := False
; FileNames
global oFileName := { sDB: "Database.csv", sUP: "UserProgress.csv" }
; Current cargo types in selected (clicked) building
global oSelectedCargoTypes := []
; Current jobs and their cargos icons with position showed on screen
global oJobsCargosOnScreen := []
; GUI of parent windows "Building" and "Job", which used by child window "Cargo"
;   and button "Destination" logic to manipulate on them (hide, show).
; Push to array when call child GUI, pop when return to parent GUI.
global oParentGUI := []
; Window "Cargo" and button "Destination" in "Building" and "Job" windows:
;   Save button's control, that create child window (we concatenate "Edit" string
;     to it and got [Edit] result control in parent window where we will save
;     result from child window).
global sButtonResultControl := ""
; Control's variable name (prefix for other controls in same window) in "Building"
;   and "Job" windows
global sCrgBtnVarName := "CargoBtn"
global sDstBtnVarName := "DestinationBtn"
; Control's variable name (prefix) in "Cargo" window
global sCargoCrgVarName := "JobCrgDetail"
; Save\restore "Show Buildings" checkbox value from "Main" window during temporary
;   modifications by child windows.
global bPreDestinationShowBuildingsCheckbox := False
global oPreDestinationSelectedCargoTypes := []

sHelpText := "
(
Hotkeys:
     F1 -> Show help window.
     F2 -> Show legend window.
     F3 -> Show\Hide main window.
      / -> Make selected job complete.
    Del -> LMB click (for bad mouse with double click).
Alt + X ->   Exit Script (Save User Progress).
Alt + Z -> Reload Script (Save User Progress).

Keywords:
- ""Building"": cargo source (Town Storage, Warehouse, etc...).
- ""Job"": cargo destination (any place on map).

Usage:
- ListView on right side shows ""Jobs"" in current ""Region"". Click on checkbox to
  ""Accept"" job.
- Check [Show Buildings] to show ""Buildings'"" cargo icons on map. Click on first
  cargo icon to select ""Building"". You can click directly on map to select ""Building""
  without showing it's cargo icons.
- Cargo icons appear on map in places (accepted jobs), where you can deliver cargo
  from selected ""Building"".
- Deliver cargo to desired place. Click on cargo icon to decrement it quantity.
  When cargo quantity of all cargos in accepted job reduces to zero, job automatically
  marked as ""Completed"".
- Click on empty space to select ALL cargo types and show all accepted jobs. Click
  [Clear Cargo Types] button to deselect cargo types and hide all icons on map.

Update:
- You can add missed ""Jobs"" and ""Buildings"" via GUI.
- In set Destination\Position mode you can click on first cargo icon to get it's X:Y
  position (set same coordinates for same places: different jobs point out to same place).
- All other stuff must be edited directly in """ oFileName.sDB """.

Info:
- On start keyboard focus is on [Region] control. This allows ""Region"" to be quickly
  selected by typing the first few characters of it's name.
- Top left corner of cargo icon (or first cargo icon in group of icons) is X:Y
  coordinates of center of ""Building"" or ""Job"" saved in """ oFileName.sDB """.
- Reset job: make it complete, then accept it.
- Check [Show All Jobs] to show ALL jobs, uncheck - to show only accepted jobs.
- Check [Show Empty Cargo] to show cargo types with zero quantity.

Bugs:
- Script can't handle very fast ""Region"" change.
)"

;============================= Initialization ==================================

oDB := New Database()
If (TEST_DATA) {
    oFileName.sDB := SubStr(oFileName.sDB, 1, -4) "_TEST.csv"
    oFileName.sUP := SubStr(oFileName.sUP, 1, -4) "_TEST.csv"
    oDB.SaveLoad(oFileName)
}
Else
    oDB.Load(oFileName)

Gosub CreateMainGui
RegionChanged() ; Populate [Main] GUI with data

If (TEST_DATA) {
    GuiControl, Main:, ShowAllJobs, 1
    ShowAllJobs()
}
Return

;================================= Hotkeys =====================================

F3:: ToggleMainWindow()

#IfWinActive ahk_group Script
    F1:: ShowHelpText(sHelpText)
    F2:: ShowLegend()
    Delete::
        Click
        Sleep 250 ; Prevent multi-clicks by bad mouse
    Return
    !x:: Gosub MainGuiClose
    !z:: Gosub MainGuiReload
#If

ToggleMainWindow() {
    global sWinTitle
    If (WinActive("ahk_group Script")) {
        Gui HelpText:Destroy
        Gui Legend:Destroy
        Gui CargoIcons:Hide
        Gui Main:Hide
        ; WinMinimize %sWinTitle%
        WinActivate ahk_group Game
    } Else {
        Gui Main:Show
        ; Set the window to be the last found window for WinExist().
        ; The window is not created if it does not already exist.
        Gui CargoIcons:+LastFoundExist
        If (WinExist())
            Gui CargoIcons:Show
        WinActivate %sWinTitle%
        ; WinRestore %sWinTitle% ; Some graphic glitch on restore
    }
}

;======================= GUI: "SnowRunner Logistics" ===========================

CreateMainGui:
    ; Make "Always On Top" to show window on top of the Windows TaskBar.
    ; If the window is bigger then the desktop size it appears with an upward
    ; shift of a dozen pixels. Fix this by showing it in top left corner.
    WLV  := W - 1090 ; w660 ; ListView     (gJobToggle)
    WCT  := W - 1350 ; w400 ; Text         (vCargoTypes)
    WDDL := 125             ; DropDownList (Region)
    WMN  := 160             ; Text         (vMapName)
    ; Use monospace font for controls to align CheckBoxes
    sControlFont := "Consolas"
    sListFont    := "Verdana"
    Gui Main:New, -Caption +AlwaysOnTop +LastFound
    Gui Font,, %sControlFont%
    Gui Margin, 0, 0
    Gui Add, Picture, w540 h540    gMapClick vMapPicture1 Section
    Gui Add, Picture, wp   hp   ys gMapClick vMapPicture2
    Gui Add, Picture, wp   hp   xs gMapClick vMapPicture3 Section
    Gui Add, Picture, wp   hp   ys gMapClick vMapPicture4
    Gui Margin, 6, 6
    Gui Add, Text, ym w40 Section, &Region:
    Gui Add, DropDownList, ym  w%WDDL% gRegionChanged vRegion, % oDB.GetRegionsDDL(sDefaultRegion)
    Gui Add, Button,   ym, &Clear Cargo Types
    Gui Add, Text,     ym, Cargo Types:
    Gui Add, Text, x+m ym w%WCT% 0x200 vCargoTypes ; 0x200 == "Single Line" option
    Gui Add, Text, xs w40, Maps:
    Gui Add, Text,     x+m yp  w%WMN% Border vMapName1
    Gui Add, Text,     x+0 yp  wp     Border vMapName2
    Gui Add, Checkbox, x+m yp         gShowBuildings     vShowBuildings, &Show Buildings
    Gui Add, Checkbox, x+m yp         gShowAllJobs       vShowAllJobs, Show &All Jobs
    Gui Add, Checkbox, x+m yp Checked gHideCompletedJobs vHideCompletedJobs, &Hide Completed Jobs
    Gui Add, Text,   xs+46 y+2 w%WMN% Border vMapName3
    Gui Add, Text,     x+0 yp  wp     Border vMapName4
    Gui Add, Checkbox, x+m yp Checked gShowJobNames      vShowJobNames, Show Job &Names
    Gui Add, Checkbox, x+m yp         gShowEmptyCargo    vShowEmptyCargo, Show &Empty Cargo
    Gui Font,, %sListFont%
    ; AutoHotKey Help: "Window and Control Styles"
    ; +LV0x4000  == Show tooltips
    ; +LV0x10000 == Prevent flickering
    ; -LV0x10    == Prevent the user reorder column headers
    ;  CountN    == This is not a limit: rows beyond the count can still be added.
    ;               Allocate memory only once rather than each time a row is added,
    ;                 which greatly improves row-adding performance.
    ; Must be in sync with LV_Add() and JobToggle()!
    Gui Add, ListView, xs w%WLV% h975 +Report +Checked +Grid -Multi +LV0x4000 +LV0x10000 -LV0x10 +AltSubmit Count100 gJobToggle vJobListView, Status|Job Type|Job Name|Cargo
    Gui Font,, %sControlFont%
    Gui Add, Button, Section, Add &Building
    Gui Add, Button, ys, Add &Job
    Gui Add, Button, ys, Edit CSV
    Gui Add, Button, ys, Sort CSV
    Gui Add, Button, ys, Reset User Progress
    Gui Add, Button, ys gMainGuiReload, Reload
    Gui Add, Button, ys gMainGuiClose, E&xit
    Gui Add, Text,   ys, Default Region:
    Gui Add, DropDownList, ys+1 w%WDDL% gDefaultRegionChanged vDefaultRegion, % oDB.GetRegionsDDL(sDefaultRegion)
    Gui Show, x0 y0 w%W% h1080, %sWinTitle%
    WinGetPos, iMainX, iMainY ; For child window with cargo icons
    ; Uni == Unidirectional sort. This prevents a second click on the same column
    ; from reversing the sort direction.
    LV_ModifyAllColOptions("Uni")
Return

MainGuiEscape:
    ; 0 == All rows in ListView
    LV_Modify(0, "-Focus")
    LV_Modify(0, "-Select")
Return

MainGuiClose:
    ; Save user progress only on Exit/Reload.
    ; Save on every change require more code all over the script:
    ;   in CargoClick(), on make Job Complete event, on Accept Job event.
    oDB.SaveUserProgress(oFileName.sUP)
ExitApp

MainGuiReload:
    oDB.SaveUserProgress(oFileName.sUP)
    Reload
Return

; Main:Picture - Find building under cursor, Show job's icons
MapClick() {
    GuiControl, Main:, ShowAllJobs, 0 ; Un-check "Show All Jobs" checkbox
    GuiControl, Main:, ShowBuildings, 0 ; Uncheck "Show Buildings" checkbox
    oBuilding := oDB.GetBuildingUnderCursor(GetRegion())
    oSelectedCargoTypes := oBuilding.oCargoTypes
    If (oSelectedCargoTypes)
        GuiControl, Main:, CargoTypes, % ArrayToCSV(oSelectedCargoTypes)
    Else
        SelectAllCargoTypes()
    CargoIconsUpdate(oSelectedCargoTypes)
}

; Main:DropDownList - Update whole [Main] GUI, De-select building
RegionChanged() {
    sRegion := GetRegion()
    oMaps := oDB.GetMaps(sRegion)
    Loop 4 {
        ; Update GUI map pictures
        If (oMaps[A_Index]) {
            sPictureName := ".\Maps\" sRegion "\" oMaps[A_Index] ".png"
            GuiControl,, MapPicture%A_Index%, *w540 *h540 %sPictureName%
            GuiControl, Show, MapPicture%A_Index%
        } Else {
            GuiControl, Hide, MapPicture%A_Index%
        }
        ; Update GUI "Maps" names
        If (oMaps[A_Index]) {
            GuiControl,, MapName%A_Index%, % A_Index ": " oMaps[A_Index]
        } Else {
            GuiControl,, MapName%A_Index%
        }
    }

    LV_ReLoadJobs(sRegion)

    ; Select all cargo types to show all "Accepted" jobs
    SelectAllCargoTypes()
    CargoIconsUpdate(oSelectedCargoTypes)
}

; Main:ListView-Checkbox
JobToggle() {
    ; Every checkbox change in ListView generates events: user manually
    ;   checks\unchecks job's line, script programmatically check\uncheck line,
    ;   script add "checked" line to ListView.
    ; If we check, that fields in oJob already has proper values, return from
    ;   function immediately, because it will executed "heavy" functions many
    ;   time and waste CPU time.
    If (A_GuiEvent == "I") { ; I == Item changed
        LV_Status := ErrorLevel ; Functions below changes ErrorLevel, save it immediately
        ; Case insensitive search: both "C" and "c" are covered
        ; "C"\"c" == Checked\UnChecked Event
        If (InStr(LV_Status, "c")) {
            sRegion := GetRegion()
            oJobInfo := LV_GetJobInfo(A_EventInfo)
            oJob := oDB.GetJob(sRegion, oJobInfo.sType, oJobInfo.sName)
            If (InStr(LV_Status, "C", True)) { ; Checked
                If (oJob.isCompleted) {
                    MsgBox(A_Gui, "Q", "Reset 'Completed' job?")
                    IfMsgBox Yes
                    {
                        oJob := oDB.CopyJob(sRegion, oJobInfo.sType, oJobInfo.sName, True)
                        oJob.isAccepted := True
                        oJob.isCompleted := False
                        oDB.AddJob(sRegion, oJob) ; Overwrite in oDB.oJobs
                    } Else {
                        LV_Modify(A_EventInfo, "-Check")
                        Return
                    }
                } Else {
                    If (oJob.isAccepted)
                        Return ; Nothing to change
                    oJob.isAccepted := True
                    oJob.isCompleted := False
                }
            }
            bSkipCargoIconsUpdate := False
            If (InStr(LV_Status, "c", True)) { ; UnChecked
                If (GetJobCargoCount(oJob) == 0) {
                    If (!oJob.isAccepted && oJob.isCompleted)
                        Return ; Nothing to change
                    oJob.isAccepted := False
                    oJob.isCompleted := True
                    ; When we decrement job's cargo count to zero, CargoClick()
                    ; will un-check row in ListView and code flow come here and
                    ; we got "race condition" (who faster calls CargoIconsUpdate():
                    ; here or in CargoClick() or interrupt in middle). This will
                    ; show cargo icons twice on screen. So, not update here.
                    bSkipCargoIconsUpdate := True
                } Else {
                    If (!oJob.isAccepted && !oJob.isCompleted)
                        Return ; Nothing to change
                    oRefJob := oDB.GetJob(sRegion, oJobInfo.sType, oJobInfo.sName, True)
                    If (!oJob.isCompleted && GetJobCargoCount(oJob) != GetJobCargoCount(oRefJob)) {
                        MsgBox(A_Gui, "Q", "Un-Check modified job?")
                        IfMsgBox No
                        {
                            LV_Modify(A_EventInfo, "Check")
                            Return
                        }
                    }
                    oJob.isAccepted := False
                    oJob.isCompleted := False
                }
            }
            LV_UpdateRow(A_EventInfo, oJob)
            LV_AutoWidth()
            If (bSkipCargoIconsUpdate)
                Return
            CargoIconsUpdate(oSelectedCargoTypes)
        }
    } Else If (A_GuiEvent == "K") { ; K == Pressed a key in ListView
        ; cKey := Chr(A_EventInfo) ; Only A-Z keys on most keyboard layouts.
        cKey := GetKeyName(Format("vk{:x}", A_EventInfo)) ; Localized keys
        ; StringUpper cKey, cKey
        ; Don't use letters. ListView automatically selects row, that starts
        ; with same letter (searching by 1st column).
        If (cKey == "/") {
            iRowNum := LV_GetNext() ; Selected row
            If (iRowNum) {
                oJobInfo := LV_GetJobInfo(iRowNum)
                oJob := oDB.GetJob(GetRegion(), oJobInfo.sType, oJobInfo.sName)
                If (!oJob.isCompleted) {
                    CompleteJob(oJob)
                    ; UnChecking row inside this func [JobToggle()] will not
                    ; trigger event "UnCheck" for this func. AutoHotKey design
                    ; for preventing infinite event's loop?
                    LV_UpdateRow(iRowNum, oJob)
                    LV_AutoWidth()
                    CargoIconsUpdate(oSelectedCargoTypes)
                }
            }
        }
    }
}

DefaultRegionChanged:
    GuiControlGet, sDefaultRegion, Main:, DefaultRegion
Return

MainButtonClearCargoTypes:
    oSelectedCargoTypes := []
    GuiControl, Main:, CargoTypes
    ; [Show All Jobs] needs ALL cargo types, uncheck it
    GuiControl, Main:, ShowAllJobs, 0
    CargoIconsUpdate(oSelectedCargoTypes)
Return

MainButtonEditCSV:
    MsgBox("Main", "W", ""
        . "Usage:`n"
        . "1. Edit main database file.`n"
        . "2. Reload script to read changes.`n"
        . "3. Press [Sort CSV] button to sort main database file.")
    Run % oFileName.sDB
Return

MainButtonSortCSV:
    bDBModified := true ; force saving main database file
    oDB.Save(oFileName)
    Reload
Return

MainButtonResetUserProgress:
    MsgBox(A_Gui, "Q", "Reset User Progress?`n`nDelete [" oFileName.sUP "] file.")
    IfMsgBox Yes
    {
        FileDelete % oFileName.sUP
        Reload
    }
Return

; Main:Checkbox
HideCompletedJobs() {
    sRegion := GetRegion()
    LV_ReLoadJobs(sRegion)
}

; Main:Checkbox
ShowAllJobs() {
    SelectAllCargoTypes()
    GuiControl, Main:, ShowBuildings, 0
    CargoIconsUpdate(oSelectedCargoTypes)
}

; Main:Checkbox
ShowBuildings() {
    CargoIconsUpdate(oSelectedCargoTypes)
}

; Main:Checkbox
ShowJobNames() {
    GuiControl, Main:, ShowBuildings, 0 ; Uncheck "Show Buildings" checkbox
    CargoIconsUpdate(oSelectedCargoTypes)
}

; Main:Checkbox
ShowEmptyCargo() {
    CargoIconsUpdate(oSelectedCargoTypes)
}

;========================== GUI: "Main" ListView ===============================

LV_AddJobs(sRegion) {
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    oJobsByRegion := oDB.GetJobs(sRegion)
    For sType, oJobsByType in oJobsByRegion
        For sName, oJob in oJobsByType {
            If (GetHideCompletedJobs() && oJob.isCompleted)
                Continue
            LV_Add(oJob.isAccepted ? "Check" : ""
                , GetJobStatusString(oJob)
                , sType
                , sName
                , GetJobCargoString(oJob))
        }
    LV_AutoWidth()
    Gui %_DefaultGui%:Default
}

LV_ModifyAllColOptions(sOptions) {
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    Loop % LV_GetCount("Column") {
        ; AutoHdr == Adjusts the column's width to fit its contents and the column's
        ; header text, whichever is wider.
        LV_ModifyCol(A_Index, sOptions)
    }
    Gui %_DefaultGui%:Default
}

LV_AutoWidth() {
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    LV_ModifyAllColOptions("AutoHdr")
    Gui %_DefaultGui%:Default
}

LV_GetRowNumber(oJob) {
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    i := ""
    Loop % LV_GetCount() {
        LV_GetText(sStatus, A_Index)
        If (sStatus != "Accepted")
            Continue
        LV_GetText(sType, A_Index, 2)
        LV_GetText(sName, A_Index, 3)
        ; sName fails quicker then sType, put it in first place
        If (sName == oJob.sName && sType == oJob.sType) {
            i := A_Index
            Break
        }
    }
    Gui %_DefaultGui%:Default
    Return i
}

LV_GetJobInfo(iRowNum) {
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    LV_GetText(sType, iRowNum, 2) ; 2nd column: "Job Type"
    LV_GetText(sName, iRowNum, 3) ; 3rd column: "Job Name"
    Gui %_DefaultGui%:Default
    Return { sType: sType, sName: sName }
}

; Delete all rows in the ListView. Add jobs in region.
LV_ReLoadJobs(sRegion) {
    global JobListView
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    ; Disable redraw for better performance on adding big number of rows
    GuiControl, -Redraw, JobListView
    LV_Delete()
    LV_AddJobs(sRegion)
    GuiControl, +Redraw, JobListView
    Gui %_DefaultGui%:Default
}

LV_UpdateRow(iRowNum, oJob) {
    _DefaultGui := A_DefaultGui
    Gui Main:Default
    sCargo := GetJobCargoString(oJob)
    sCheck := GetJobCargoCount(oJob) == 0 ? "-Check" : ""
    LV_Modify(iRowNum, "Col1", GetJobStatusString(oJob)) ; 1st column: "Status"
    LV_Modify(iRowNum, "Col4", sCargo)                   ; 4th column: "Cargo"
    LV_Modify(iRowNum, sCheck) ; Modify last, will generate ListView event
    Gui %_DefaultGui%:Default
}

;===================== GUI: "Cargo Icons" Buildings ============================

ShowBuildingsCargoIcons(bMakeMouseClickTransparent := True) {
    global iMainX, iMainY
    oJobsCargosOnScreen := []
    oBuildings := oDB.GetBuildings(GetRegion())

    ; GuiControl, Delete == Not yet implemented! This sub-command does not yet exist.
    ; As a workaround destroy and recreate the entire window via Gui Destroy.
    ; Lexikos Example (transparent overlay window above another window):
    ; Added Styles
    ;   WS_CHILD = 0x40000000 -- Must be added for correct child window behaviour.
    ; Removed styles:
    ;   WS_POPUP = 0x80000000 -- Must be removed for child windows.
    ;   WS_CAPTION = 0xC00000 -- GUI behaves oddly if you use -Caption post-creation.
    ; Gui CargoIcons:New, +0x40000000 -0x80C00000 +LastFound +OwnerMain
    ; +E0x20 makes GUI mouse-click transparent.
    Gui CargoIcons:New, -Caption +LastFound +OwnerMain ; New == Destroy existing [CargoIcons] window with [Jobs]
    ; When we add destination to new job, allow click on building's cargo icon
    If (bMakeMouseClickTransparent)
        Gui +E0x20
    Gui Color, %sTransColor%
    WinSet, TransColor, %sTransColor%
    Gui Margin, 0, 0
    Gui Font, c%sFontColor% s%iFontSizeCargo% w1000
    For _, oBuilding in oBuildings {
        X := oBuilding.x
        Y := oBuilding.y
        For sCargoType in oBuilding.oCargoTypes {
            Gui Add, Picture, x%X% y%Y% w%iIconSize% h%iIconSize%, .\Cargo\%sCargoType%.png
            X += iIconSize
        }
        X := oBuilding.x
        Y := oBuilding.y + iIconSize
        sType := oBuilding.sType
        Gui Add, Text, x%X% y%Y%, %sType%
    }
    Gui Show, x%iMainX% y%iMainY% w%W% h1080 NA ; Shows the window without activating it.
}

;======================== GUI: "Cargo Icons" Jobs ==============================

; Show cargo icons from "Accepted" jobs or ALL jobs
ShowJobsCargoIcons(oCargoTypes) {
    If (!oCargoTypes.Count()) {
        Gui CargoIcons:Destroy
        Return
    }

    global iMainX, iMainY
    oJobsCargosOnScreen := []
    bShowAllJobs := GetShowAllJobsCheckbox()
    bShowEmptyCargo := GetShowEmptyCargoCheckbox()
    oJobs := oDB.GetJobList(GetRegion(), bShowAllJobs) ; By default "Accepted" jobs only.
    sCargoTypesCSV := ArrayToCSV(oCargoTypes)

    ; GuiControl, Delete == Not yet implemented! This sub-command does not yet exist.
    ; As a workaround destroy and recreate the entire window via Gui Destroy.
    ; Lexikos Example (transparent overlay window above another window):
    ; Added Styles
    ;   WS_CHILD = 0x40000000 -- Must be added for correct child window behaviour.
    ; Removed styles:
    ;   WS_POPUP = 0x80000000 -- Must be removed for child windows.
    ;   WS_CAPTION = 0xC00000 -- GUI behaves oddly if you use -Caption post-creation.
    ; Gui CargoIcons:New, +0x40000000 -0x80C00000 +LastFound +OwnerMain
    Gui CargoIcons:New, -Caption +LastFound +OwnerMain
    Gui Color, %sTransColor%
    WinSet, TransColor, %sTransColor%
    Gui Margin, 0, 0
    Gui Font, c%sFontColor% s%iFontSizeCargo% w1000
    For _, oJob in oJobs {
        For _, oPosition in oJob.oPositions {
            bShowName := False
            ; If we have icons on same position from other jobs, shift to the right
            iIconsOnScreen := GetIconCountOnScreen(oPosition.x, oPosition.y)
            X := oPosition.x + iIconSize * iIconsOnScreen
            Y := oPosition.y
            For sCargoType, iQuantity in oPosition.oCargo {
                If sCargoType in %sCargoTypesCSV%
                {
                    If (iQuantity || bShowEmptyCargo) {
                        bShowName := True ; Show names, only when we show icons
                        Gui Add, Picture, x%X% y%Y% w%iIconSize% h%iIconSize% +HwndIconId gCargoClick, % GetCargoFileName(sCargoType)
                        Gui Add, Text, w%iIconSize% Center, %iQuantity%
                        ; Save {IconId: Job, Cargo, Type, X, Y} to know,
                        ; which cargo quantity decrement on mouse click,
                        ; which line in ListView modify with new quantity value
                        ; where put icons from other jobs, if place not empty
                        oJobsCargosOnScreen[iconId] := { 0:""
                            , oJob: oJob
                            , oCargo: oPosition.oCargo
                            , sCargoType: sCargoType
                            , x: oPosition.x
                            , y: oPosition.y }
                        X += iIconSize
                    }
                }
            }
            If (bShowName && GetShowJobNamesCheckbox()) {
                iFontSizeJob := 8
                X := oPosition.x + iIconSize * iIconsOnScreen
                Y := oPosition.y - iFontSizeJob - Round(iFontSizeJob / 1.5)
                Gui Font, s%iFontSizeJob% w1 q3 ; W == Boldness, Q3 == NONANTIALIASED_QUALITY
                Gui Add, Text, x%X% y%Y%, % oJob.sName
                Gui Font, s%iFontSizeCargo% w1000
            }
        }
    }
    Gui Show, x%iMainX% y%iMainY% w%W% h1080 NA ; Shows the window without activating it.
}

; CargoIcons:Picture - Decrement cargo quantity, Auto-complete job
CargoClick() {
    If (GetShowAllJobsCheckbox()) ; Prevent mouse click on icon, if we show ALL jobs icons
        Return
    ; 1 == Determine OutputVarControl from topmost child window.
    ; 2 == Stores the control's HWND in OutputVarControl rather than the control's ClassNN.
    ; 3 == 1 + 2.
    MouseGetPos,,,, iconId, 3
    oJob := oJobsCargosOnScreen[iconId].oJob
    oCargo := oJobsCargosOnScreen[iconId].oCargo
    sCargoType := oJobsCargosOnScreen[iconId].sCargoType
    oCargo[sCargoType]--
    iRowNum := LV_GetRowNumber(oJob)
    If (!iRowNum) {
        Gui Hide
        MsgBox("Main", "E", "Clicked 'Job' not found in ListView!`n`n"
            . "Database is OK.`nListView is outdated.`n`nRestart script.")
        Gui Show
        Return
    }
    ; This will "Un-Check" job with zero cargo quantity.
    ; It will trigger "Un-Checked" event message and call JobToggle().
    ; JobToggle() will modify oJob (isAccepted, isCompleted) and set in ListView
    ;   1st column "Status" for us
    LV_UpdateRow(iRowNum, oJob)
    LV_AutoWidth()
    CargoIconsUpdate(oSelectedCargoTypes)
}

;================================ GUI: Code ====================================

; Show Job's or Building's Cargo Icons
CargoIconsUpdate(oCargoTypes) {
    _DefaultGui := A_DefaultGui

    If (GetShowBuildingsCheckbox())
        ShowBuildingsCargoIcons()
    Else
        ShowJobsCargoIcons(oCargoTypes)

    Gui %_DefaultGui%:Default
}

GetHideCompletedJobs() {
    GuiControlGet, HideCompletedJobs, Main:
    Return HideCompletedJobs
}

GetRegion() {
    GuiControlGet, Region, Main:
    Return Region
}

GetShowAllJobsCheckbox() {
    GuiControlGet, ShowAllJobs, Main:
    Return ShowAllJobs
}

GetShowBuildingsCheckbox() {
    GuiControlGet, ShowBuildings, Main:
    Return ShowBuildings
}

GetShowEmptyCargoCheckbox() {
    GuiControlGet, ShowEmptyCargo, Main:
    Return ShowEmptyCargo
}

GetShowJobNamesCheckbox() {
    GuiControlGet, ShowJobNames, Main:
    Return ShowJobNames
}

GuiControlFocus(sGui, sControlVarName) {
    Gui %sGui%:+LastFound
    WinGet, hGui, ID
    GuiControlGet, hBtn, %sGui%:Hwnd, %sControlVarName%
    PushBtnSetFocus(hGui, hBtn)
}

PushBtnSetFocus(hGui, hBtn) {
    ; WM_NEXTDLGCTL = 0x0028
    ; wParam
    ; If lParam is TRUE, this parameter identifies the control that receives the focus.
    ; If lParam is FALSE, this parameter indicates whether the next or previous control
    ;   with the WS_TABSTOP style receives the focus.
    ; If wParam is zero, the next control receives the focus.
    ; If wParam not zero, the previous control with the WS_TABSTOP style receives the focus.
    ; lParam
    ; The low-order word indicates how the system uses wParam.
    ; If lParam is TRUE, wParam is a handle associated with the control that receives the focus.
    ; If lParam is FALSE, wParam is a flag that indicates whether the next or previous
    ;   control with the WS_TABSTOP style receives the focus.
    SendMessage, 0x0028, hBtn, True,, ahk_id %hGui%
}

SelectAllCargoTypes() {
    oSelectedCargoTypes := oDB.oCargoTypes ; Select ALL cargo types
    GuiControl, Main:, CargoTypes, ALL
}

; Destroy GUI and show "Main" GUI
DestroyChildWindow(sGui) {
    global sWinTitle
    Gui %sGui%:Destroy
    sParentGUI := ShowParentWindow()

    If (sParentGUI == "Main") {
        CargoIconsUpdate(oSelectedCargoTypes)
        WinActivate %sWinTitle%
    } Else
        WinActivate Add %sParentGUI%
    Return sParentGUI
}

ShowParentWindow() {
    sParentGUI := oParentGUI.Pop()
    Gui %sParentGUI%:Show
    Return sParentGUI
}

;================================= Job: Code ===================================

CompleteJob(oJob) {
    For _, oPosition in oJob.oPositions
        For sType in oPosition.oCargo
            oPosition.oCargo[sType] := 0
    oJob.isAccepted := False
    oJob.isCompleted := True
}

GetJobCargoCount(oJob) {
    iSum := 0
    For _, oPosition in oJob.oPositions
        For _, iQuantity in oPosition.oCargo
            iSum += iQuantity
    Return iSum
}

GetJobCargoString(oJob) {
    str := ""
    oCargoSum := {}
    For _, oPosition in oJob.oPositions
        For sCargoType, iQuantity in oPosition.oCargo
            oCargoSum[sCargoType] := (oCargoSum[sCargoType] ? oCargoSum[sCargoType] : 0) + iQuantity
    For sCargoType, iQuantity in oCargoSum
        str .= sCargoType ":" iQuantity ","
    Return RTrim(str, ",")
}

GetJobStatusString(oJob) {
    Return oJob.isAccepted ? "Accepted" : oJob.isCompleted ? "✓Completed" : "🚫Blocked"
}

GetJobInfoMsg(sRegion, sType, sName) {
    sMsg :=     "Job's info:`n"
    If (sRegion)
        sMsg .= "  Region:`t" sRegion "`n"
    sMsg .=     "  Type:`t" sType "`n"
    sMsg .=     "  Name:`t" sName
    Return sMsg
}

GetIconCountOnScreen(X, Y) {
    iCount := 0
    For _, oIcon in oJobsCargosOnScreen
        If (oIcon.x == X && oIcon.y == Y)
            iCount++
    Return iCount
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

;================================= Util Code ===================================

ArrayToCSV(oArray) {
    str := ""
    For key, val in oArray {
        ; Linear
        If (key == A_Index) ; ["val1", "val2"]
            str .= val ","
        Else If (val == "")      ; {key1: "", key2: ""}
            str .= key ","
        Else                ; {key1: "val1", key2: "val2"}
            str .= key "," val ","
    }
    Return RTrim(str, ",")

    ; Example:
    ; str := ""
    ; str .= ArrayToCSV(["val1","val2"]) "`n"           ; => "val1,val2"
    ; str .= ArrayToCSV({key1:"",key2:""}) "`n"         ; => "key1,key2"
    ; str .= ArrayToCSV({key1:"val1",key2:"val2"}) "`n" ; => "key1,val1,key2,val2"
    ; str .= ArrayToCSV({0:"",key1:"",key2:""}) "`n"         ; => "key1,key2"
    ; str .= ArrayToCSV({0:"",key1:"val1",key2:"val2"}) "`n" ; => "key1,val1,key2,val2"
    ; MsgBox % str
}

;["Val1", "Val2"] => {Val1: "", Val2: ""}
ArrayToObj(oLinearArray) {
    obj := {}
    For _, val in oLinearArray
        obj[val] := ""
    Return obj
}

;["Key", "Value"] => {Key: Value}
CreateAssocArray(oLinearArray) {
    obj := {}
    i := 1
    Loop {
        obj[oLinearArray[i]] := oLinearArray[i + 1]
        i += 2
    } Until i > oLinearArray.Length()
    Return obj
}

GetCargoFileName(sCargoType) {
    Return ".\Cargo\" sCargoType ".png"
}

;==================== GUI: "Add Building" & "Add Job" ==========================

; Button "Destination" in "Building" or "Job" window is clicked
; ButtonDestination() & ButtonDestinationFinish(): Enable & Disable this hotkeys
#If, InStr(sButtonResultControl, "Destination")
    Left::  MouseMove, -1,  0, , R
    Right:: MouseMove,  1,  0, , R
    Up::    MouseMove,  0, -1, , R
    Down::  MouseMove,  0,  1, , R

    Enter::
    Space::
    LButton::
        sControlVarNameMap := sCargoFileName := ""
        ; Lines order in this hotkey are very important! Got some "side" effects
        MouseGetPos, _X, _Y,, hWndControl, 2
        GuiControlGet, sControlVarNameMap, Main:Name, %hWndControl%
        GuiControlGet, sCargoFileName, CargoIcons:, %hWndControl%
        GuiControlGet, aCargoIconPos, CargoIcons:Pos, %hWndControl%
        sCargoFileName := SubStr(sCargoFileName, 9)
        If sCargoFileName contains % ArrayToCSV(oDB.oCargoTypes)
        {
            ; Get position from cargo icon
            _X := aCargoIconPosX
            _Y := aCargoIconPosY
            MouseMove, _X, _Y, 0
            Sleep, 500
        } Else If sControlVarNameMap not contains MapPicture
        {
            sTemp := sButtonResultControl
            ; Unlock [LButton] [Enter] [Space] to press [OK] button in popup window
            sButtonResultControl := "" ; Disable #If Hotkeys!
            ToolTipDestination(False)
            MsgBox("Main", "I", "Out of Maps' boundary!")
            sButtonResultControl := sTemp ; Enable #If Hotkeys!
            ToolTipDestination(True)
            Return
        }

        Gui CargoIcons:Hide
        Gui Main:Hide
        RestoreMainGuiState()
        sCurrentGUI := ShowParentWindow()

        ; Save result
        ButtonDestinationFinish(sCurrentGUI, sButtonResultControl, _X, _Y)

        ; Set focus to "Cargo" button
        If (sCurrentGUI == "Building")
            GuiControlFocus(sCurrentGUI, sCrgBtnVarName)
        If (sCurrentGUI == "Job") {
            ; Replace "DestinationBtn" prefix from "DestinationBtn10" with empty
            ;   string and got "index" "10"
            index := StrReplace(sButtonResultControl, sDstBtnVarName)
            GuiControlFocus(sCurrentGUI,sCrgBtnVarName . index)
        }

        ; Must be last line!
        sButtonResultControl := "" ; Disable #If Hotkeys!
    Return

    Escape::
    RButton::
        sButtonResultControl := "" ; Disable #If Hotkeys!
        ToolTipDestination(False)
        ; Hide "Child" windows.
        ; In this case "Main,CargoIcons" windows are "Child", because
        ;   "Building,Job" windows shows them on demand.
        ; Example: "Main,CargoIcons" -> "Building,Job" -> "Main,CargoIcons"
        Gui CargoIcons:Hide
        Gui Main:Hide
        RestoreMainGuiState()
        ; Show "Parent" window.
        ShowParentWindow()
    Return
#If

; Building:Button & Job:Button
ButtonCargo() {
    oParentGUI.Push(A_Gui)
    sButtonResultControl := A_GuiControl
    Gosub, CreateCargoGui
}

; Building:Button & Job:Button
ButtonDestination() {
    global sWinTitle
    oParentGUI.Push(A_Gui)
    Gui Hide
    Gui Main:Show
    SaveMainGuiState()
    GuiControl, Main:, ShowAllJobs, 1 ; Check
    ShowCargoIconsDestinationMode(A_Gui)
    WinActivate %sWinTitle% ; "Heavy" command, put it below all GUI functions!
    ToolTipDestination(True)
    ; A_GuiControl - The name of the variable associated with the GUI control
    ;   that launched the current thread.
    sButtonResultControl := A_GuiControl ; Enable #If Hotkeys!
}

ButtonDestinationFinish(sResultGui, sButtonResultControl, X, Y) {
    GuiControl, Main:, bShowAllJobs, 0
    GuiControl, %sResultGui%:, %sButtonResultControl%Edit, %X%:%Y%
    ToolTipDestination(False)
}

ToolTipDestination(bShow) {
    local
    If (bShow)
        SetTimer, DestinationToolTip, 100
    Else {
        SetTimer, DestinationToolTip, Off
        ToolTip
    }
    Return

    DestinationToolTip:
    ; MouseGetPos, X, Y
    ; ToolTip % X ":" Y "`nMove: Arrows`nSave: LMB or Space`nCancel: RMB or Esc"
    ; Return
    sControlVarNameMap := sCargoFileName := ""
    MouseGetPos, X, Y,, hWndControl, 2
    GuiControlGet, sControlVarNameMap, Main:Name, %hWndControl%
    GuiControlGet, sCargoFileName, CargoIcons:, %hWndControl%
    ; "Pos" sub-command not work here!!! Why???
    ; GuiControlGet, aCargoIconPos, CargoIcons:Pos, %hWndControl%
    If (sCargoFileName || InStr(sControlVarNameMap, "MapPicture"))
        sInfoMsg := ""
            ; . "SnapPosition: " aCargoIconPosX ":" aCargoIconPosY "`n"
            ; . "hWndControl: " hWndControl "`n"
            . "sControlVarNameMap: " sControlVarNameMap "`n"
            . "sCargoFileName: " SubStr(sCargoFileName, 9)
    Else
        sInfoMsg := "Wrong mouse position!"
    ToolTip % ""
        . X ":" Y "`n"
        . "Move: Arrows`n"
        . "Save: LMB or Space`n"
        . "Cancel: RMB or Esc`n`n"
        . sInfoMsg
    Return
}

ShowCargoIconsDestinationMode(sParentGUI) {
    oSelectedCargoTypes := oDB.oCargoTypes
    GuiControl, Main:, CargoTypes, ALL
    ; In this case "Main,CargoIcons" windows are "Child", because
    ;   "Building,Job"[ButtonDestination] windows shows them on demand.
    ; Example: "Main,CargoIcons" -> "Building,Job"[ButtonDestination] -> "Main,CargoIcons"
    If (sParentGUI == "Building") {
        GuiControl, Main:, ShowBuildings, 1
        ShowBuildingsCargoIcons(False)
    }
    If (sParentGUI == "Job") {
        GuiControl, Main:, ShowBuildings, 0
        ShowJobsCargoIcons(oSelectedCargoTypes) ; Show all not completed jobs
    }
}

SaveMainGuiState() {
    oPreDestinationSelectedCargoTypes := oSelectedCargoTypes
    bPreDestinationShowBuildingsCheckbox := GetShowBuildingsCheckbox()
    GuiControl, Main:Disable, Add &Building
    GuiControl, Main:Disable, Add &Job
    GuiControl, Main:Disable, E&xit
    GuiControl, Main:Disable, DefaultRegion
    GuiControl, Main:Disable, Re&load
    GuiControl, Main:Disable, Region
    GuiControl, Main:Disable, Reset User Progress
    ; GuiControl, Main:Disable, Show &All Jobs
    ; GuiControl, Main:Disable, Show Job &Name
}

RestoreMainGuiState() {
    oSelectedCargoTypes := oPreDestinationSelectedCargoTypes
    GuiControl, Main:, CargoTypes, % ArrayToCSV(oSelectedCargoTypes)
    GuiControl, Main:, ShowBuildings, %bPreDestinationShowBuildingsCheckbox%
    GuiControl, Main:Enable, Add &Building
    GuiControl, Main:Enable, Add &Job
    GuiControl, Main:Enable, DefaultRegion
    GuiControl, Main:Enable, E&xit
    GuiControl, Main:Enable, Re&load
    GuiControl, Main:Enable, Region
    GuiControl, Main:Enable, Reset User Progress
    ; GuiControl, Main:Enable, Show &All Jobs
    ; GuiControl, Main:Enable, Show Job &Name
}

;========================== GUI: "Add Building" ================================

MainButtonAddBuilding:
    oParentGUI.Push(A_Gui)
    Gui CargoIcons:Hide
    Gui Hide
    Gui Building:New, +LastFound
    Gui Add, Text,, Set [Position] X:Y on map. Set [Cargo Type].
    Gui Add, DropDownList, w200 vBuildingType, % oDB.GetBuildingTypesDDL()
    Gui Add, Button,       v%sDstBtnVarName% gButtonDestination Section, &Position
    Gui Add, Edit, w70  ys v%sDstBtnVarName%Edit Center ; Must fit this text: "0000:0000"
    Gui Add, Button,    xs v%sCrgBtnVarName% gButtonCargo Section, &Cargo
    Gui Add, Edit, w445 ys v%sCrgBtnVarName%Edit
    Gui Add, Button,    xm Default Section, &Save
    Gui Add, Button,    ys, Ca&ncel
    Gui Show, w515 h140, Add Building (Cargo Source)
Return

BuildingButtonCancel:
BuildingGuiEscape:
BuildingGuiClose:
    DestroyChildWindow(A_Gui)
Return

; Building:Button
BuildingButtonSave() {
    global BuildingType
    Gui Submit, NoHide ; NoHide == Fix not showing parent window after automatic hiding

    oXY := StrSplit(%sDstBtnVarName%Edit, ":")

    oCargoTypes := {}
    Loop, Parse, %sCrgBtnVarName%Edit, CSV
        ; Create associative array: { CargoType1: "",..., CargoTypeN: "" }
        oCargoTypes[A_LoopField] := ""

    If (oXY[1] && oXY[2] && oCargoTypes.Count()) {
        sRegion := GetRegion()
        oBuilding := { sType: BuildingType, x: oXY[1], y: oXY[2], oCargoTypes: oCargoTypes }
        If (oDB.IsBuildingOverlap(sRegion, oBuilding)) {
            MsgBox(A_Gui, "I", "Not Saved!`n`nNew building overlaps with another building.")
            Return
        }
        oDB.AddBuilding(sRegion, oBuilding)
        oDB.Save(oFileName)
    } Else {
        MsgBox(A_Gui, "I", "Not Saved!`n`nCargo is Empty`nPosition [X:Y] is Wrong")
        Return
    }

    DestroyChildWindow(A_Gui)
}

;============================ GUI: "Add Job" ===================================

MainButtonAddJob:
    oParentGUI.Push(A_Gui)
    Gui CargoIcons:Hide
    Gui Hide
    Gui Job:New, +LastFound
    Gui Add, Text,, &Type:
    Gui Add, Text,, &Name:
    Gui Add, DropDownList, ym w454 vJobType, % "TASKS||" oDB.GetContractsInRegionDDL()
    Gui Add, Edit, w454 vJobName
    Gui Add, Text, xm, DESTINATION (X:Y).`t`tCARGO (CargoType1:Quantity1,CargoTypeN:QuantityN).
    Loop % iGuiRowNum {
        Gui Add, Button,    xm v%sDstBtnVarName%%A_Index% gButtonDestination Section, Destination
        Gui Add, Edit, w70  ys v%sDstBtnVarName%%A_Index%Edit Center ; Must fit this text: "0000:0000"
        Gui Add, Button,    ys v%sCrgBtnVarName%%A_Index% gButtonCargo, Cargo
        Gui Add, Edit, w290 ys v%sCrgBtnVarName%%A_Index%Edit
    }
    Gui Add, Button, xm Default Section, &Save
    Gui Add, Button, ys, Ca&ncel
    Gui Show, w515 h370, Add Job (Cargo Destination)
Return

JobButtonCancel:
JobGuiEscape:
JobGuiClose:
    DestroyChildWindow(A_Gui)
Return

; Job:Button
JobButtonSave() {
    global JobType
    global JobName
    Gui Submit, NoHide ; NoHide == Fix not showing parent window after automatic hiding

    oPositions := []
    Loop % iGuiRowNum {
        oXY := StrSplit(%sDstBtnVarName%%A_Index%Edit, ":")

        oCargo := {}
        Loop, Parse, %sCrgBtnVarName%%A_Index%Edit, CSV
        {
            oTypeNum := StrSplit(A_LoopField, ":")
            If (oTypeNum[1] && oTypeNum[2])
                oCargo[oTypeNum[1]] := oTypeNum[2]
        }
        If (oXY[1] && oXY[2] && oCargo.Count())
            oPositions.Push({ x: oXY[1], y: oXY[2], oCargo: oCargo })
    }

    If (JobName && oPositions.Length()) {
        sRegion := GetRegion()
        oJob := oDB.GetJob(sRegion, JobType, JobName)
        If (oJob) {
            MsgBox(A_Gui, "Q", "Job '" JobName "' already exist. Overwrite job?")
            IfMsgBox No
            {
                Return
            }
        }
        ; It is important to create two new objects!!!
        ; Add to Working Jobs: accepted
        oJob := oDB.CreateJob(True, False, JobType, JobName, oPositions)
        oDB.AddJob(sRegion, oJob)
        oPositions := oDB.CopyPositions(oPositions)
        ; Add to Reference Jobs: not accepted
        oJob := oDB.CreateJob(False, False, JobType, JobName, oPositions)
        oDB.AddJob(sRegion, oJob, True)
        ; Save & Apply new Job
        oDB.Save(oFileName)
        LV_ReLoadJobs(sRegion)
    }
    Else {
        MsgBox(A_Gui, "I", "Not Saved!`n`n"
            . "Possible reasons:`n"
            . "  1. Name is Empty.`n"
            . "  2. Cargo is Wrong format.`n"
            . "  3. Destination [X:Y] is Wrong format.")
        Return
    }

    DestroyChildWindow(A_Gui)
}

;=============================== GUI: "Cargo" ==================================

CreateCargoGui:
    If (oParentGUI[oParentGUI.Length()] == "Building")
        ; "Building" window not accept cargo quantity, disable it's Edit control
        sDisableCargoQuantity := "+Disabled"
    Else
        sDisableCargoQuantity := ""
    Gui Hide
    Gui Cargo:New, +LastFound
    Gui Add, Text,, Type*
    Gui Add, Text, ym, Quantity
    Loop % iGuiRowNum {
        Gui Add, DropDownList, xm v%sCargoCrgVarName%%A_Index%Type Sort Section, % oDB.GetCargoTypesDDL()
        Gui Add, Edit,     w20 ys v%sCargoCrgVarName%%A_Index%Quantity Center %sDisableCargoQuantity%
    }
    Gui Add, Text, xm Section, *
    Gui Add, Text, ys w140, item can be selected by typing the first few characters of it's name.
    Gui Add, Button, xm Default, &Save
    Gui Show, w170 h345, Cargo
Return

CargoGuiEscape:
CargoGuiClose:
    DestroyChildWindow(A_Gui)
Return

; Cargo:Button
CargoButtonSave() {
    Gui Submit, NoHide ; NoHide == Fix not showing parent window after automatic hiding
    sCargo := ""
    sParentGUI := oParentGUI[oParentGUI.Length()]
    Loop % iGuiRowNum {
        sTypeVarName := sCargoCrgVarName A_Index "Type"
        sQuantityVarName := sCargoCrgVarName A_Index "Quantity"
        sType := %sTypeVarName%
        sQuantity := %sQuantityVarName%
        If (sType) {
            sCargo .= sType
            If sQuantity is Number
                sCargo .= ":" sQuantity
            Else
                If (sParentGUI == "Job") {
                    ; "Job" window waits cargos with quantity!
                    MsgBox(A_Gui, "I", "Not Saved!`n`nCargo Quantity is Wrong.")
                    Return
                }
            sCargo .= ","
        } Else {
            If (sParentGUI == "Job" && sQuantity) {
                ; "Job" window waits cargos with quantity AND type!
                MsgBox(A_Gui, "I", "Not Saved!`n`nCargo Type is Empty.")
                Return
            }
        }
    }
    sCargo := RTrim(sCargo, ",")
    ; Save result
    GuiControl, %sParentGUI%:, %sButtonResultControl%Edit, %sCargo%
    DestroyChildWindow(A_Gui)
    ; Jump focus to next control, only if we have some result
    If (sCargo)
        GuiControl, %sParentGUI%:Focus, %sButtonResultControl%Edit
    sButtonResultControl := ""
}

;============================ GUI: "Help Text" =================================

CreateMouseClickTransGui(id)
{
    ; +E0x20 makes GUI mouse-click transparent.
    Gui %id%:New, -Caption -SysMenu +AlwaysOnTop +LastFound +ToolWindow +E0x20
    WinSet TransColor, 500 ; This line is necessary to working +E0x20 !
}

ShowHelpText(sText)
{
    static bToggle := False
    sGui := "HelpText"
    If (bToggle := !bToggle) {
        CreateMouseClickTransGui(sGui)
        Gui Font, s14, Consolas
        Gui Add, Text,, % sText
        Gui Show, NoActivate
    } Else
        Gui %sGui%:Destroy
}

;============================== GUI: "Legend" ==================================

ShowLegend() {
    global iMainX, iMainY
    static bToggle := False
    sGui := "Legend"
    If (bToggle := !bToggle) {
        CreateMouseClickTransGui(sGui)
        Gui Font, s14, Consolas
        Gui Margin,, 0
        For sCargoType in oDB.oCargoTypes {
            Gui Add, Picture, x0 Section, % GetCargoFileName(sCargoType)
            Gui Add, Text, ys, % sCargoType
        }
        X := iMainX + 1080
        Gui Show, x%X% y0 NoActivate
    } Else
        Gui %sGui%:Destroy
}

;================================ Database =====================================

class Database
{
    ; 0:"" or 0:{} added for better formatting continuation sections
    ; They will generate "0" elements in DropDownList and CSV only for TEST_DATA
    oBuildings := { 0:""
        ; If use one object like Key in another object (associative array)
        ; first object's structure not visible in another object (in debugger),
        ; debugger shows address in memory. It's not practical, using linear
        ; array for complicated objects.
        , "MICHIGAN": [ { 0:""
            , sType: "Warehouse"
            , X: 475, Y: 333
            , oCargoTypes: { 0:""
                , "Bricks": ""
                , "Concrete Blocks": ""
                , "Metal Beams": ""
                , "Service Spare Parts": "" } }
        , { 0:""
            , sType: "Town Storage"
            , X: 103, Y: 237
            , oCargoTypes: { 0:""
                , "Metal Beams": "" } } ]
        , "ALASKA": []
        , "TAYMYR": [] }
    oBuildingTypes := { 0:""
        , "Abandoned Drilling Site": ""
        , "Drilling Site": ""
        , "Factory": ""
        , "Farm": ""
        , "Fuel Station": ""
        , "Log Station": ""
        , "Logistics Base": ""
        , "Lumber Mill": ""
        , "Quarry Loading Zone": ""
        , "Service Hub": ""
        , "Town Storage": ""
        , "Warehouse": "" }
    oCargoTypes := { 0:""
        , "Bricks": ""
        , "Cabin": ""
        , "Cargo Container": ""
        , "Cement": ""
        , "Concrete Blocks": ""
        , "Concrete Slabs": ""
        , "Consumables": ""
        , "Drilling Equipment": ""
        , "Drilling Spare Parts": ""
        , "Fuel": ""
        , "Large Pipe": ""
        , "Long Logs": ""
        , "Medium Logs": ""
        , "Medium Pipes": ""
        , "Metal Beams": ""
        , "Metal Rolls": ""
        , "Oil Barrels": ""
        , "Oil Rig Drill": ""
        , "Secure Container": ""
        , "Service Spare Parts": ""
        , "Small Pipes": ""
        , "Vehicle Spare Parts": ""
        , "Wooden Planks": "" }
    oContracts := { 0:""
        , "MICHIGAN": { 0:""
            , "DYSON DIESEL": ""
            , "HUSKY FORWARDING": ""
            , "STEEL RIVER TOWNSHIP": "" }
        , "ALASKA": { 0:""
            , "GR ENTERPRISE": ""
            , "BLACK BIRD": ""
            , "MORRISON MINING": "" }
        , "TAYMYR": { 0:""
            , "VORONOE 12": ""
            , "TRANSTAYMYR": ""
            , "TAIGA OIL": "" } }
    ; Region's order for DropDownList
    oRegions := ["MICHIGAN", "ALASKA", "TAYMYR", "KOLA PENINSULA", "YUKON", "WISCONSIN", "AMUR", "DON", "MAINE", "TENNESSEE", "GLADES"]
    oMaps := { 0:""
        ; Linear array: Map order for main GUI
        ; |Map1|Map2|
        ; |Map3|Map4|
        , "MICHIGAN": ["Black River", "Smithville Dam", "Island Lake", "Drummond Island"]
        , "ALASKA": ["North Port", "Mountain River", "White Valley", "Pedro Bay"]
        , "TAYMYR": ["Quarry", "Drowned Lands", "Zimnegorsk", "Rift"]
        , "KOLA PENINSULA": ["Lake Kovd", "Imandra"]
        , "YUKON": ["Flooded Foothills", "Big Salmon Peak"]
        , "WISCONSIN": ["Black Badger Lake", "Grainwoods River"]
        , "AMUR": ["Urska River", "Cosmodrome", "Northern Aegis Installation", "Chernokamensk"]
        , "DON": ["Factory Grounds", "Antonovskiy Nature Reserve"]
        , "MAINE": ["The Lowland", "Yellowrock National Forest"]
        , "TENNESSEE": ["Burning Mill"]
        , "GLADES": ["Crossroads", "The Institute", "Heartlands", "HarvestCorp"] }
    oJobs := { 0:{}  ; Job's Work Copy (User Progress saved here!)
        ; Job duplicates Name and Type in oJob!
        ; isModified == User had modify job in any way OR it was loaded from UserProgress.csv file.
        , "MICHIGAN": { 0:{}
            , "TASKS": { 0:{}
                , "Job: Bricks": { 0:{}
                    , isAccepted: False
                    , isCompleted: True
                    , isModified: True
                    , sType: "TASKS"
                    , sName: "Job: Bricks"
                    , oPositions: [ { x: 0, y: 0, oCargo: { "Bricks": 0 } }, { x: 50, y: 0, oCargo: { "Bricks": 0 } } ] } }
            , "CONTRACTS: DYSON DIESEL": { 0:{}
                , "Job: Bricks + Metal Beams": { 0:{}
                    , isAccepted: True
                    , isCompleted: False
                    , isModified: True
                    , sType: "CONTRACTS: DYSON DIESEL"
                    , sName: "Job: Bricks + Metal Beams"
                    , oPositions: [ { x: 900, y: 50, oCargo: { "Bricks": 1, "Metal Beams": 1 } }, { x: 950, y:50, oCargo: { "Bricks": 1, "Metal Beams": 1 } } ] }
                , "Job: Bricks2": { 0:{}
                    , isAccepted: False
                    , isCompleted: False
                    , isModified: False
                    , sType: "CONTRACTS: DYSON DIESEL"
                    , sName: "Job: Bricks2"
                    , oPositions: [ { x: 900, y: 100, oCargo: { "Bricks": 2 } } ] } } } }
    oRefJobs := { 0:{} ; Job's Reference Copy (User Progress NOT saved here!)
        ; Job duplicates Name and Type in oJob!
        ; isModified == FALSE for all reference jobs (Database.csv)
        , "MICHIGAN": { 0:{} ; oJobsByRegion
            , "TASKS": { 0:{} ; oJobsByType
                , "Job: Bricks": { 0:{} ; oJobs
                    , isAccepted: False
                    , isCompleted: False
                    , isModified: False
                    , sType: "TASKS"
                    , sName: "Job: Bricks"
                    , oPositions: [ { x: 0, y: 0, oCargo: { "Bricks": 1 } }, { x: 50, y: 0, oCargo: { "Bricks": 1 } } ] } }
            , "CONTRACTS: DYSON DIESEL": { 0:{}
                , "Job: Bricks + Metal Beams": { 0:{}
                    , isAccepted: False
                    , isCompleted: False
                    , isModified: False
                    , sType: "CONTRACTS: DYSON DIESEL"
                    , sName: "Job: Bricks + Metal Beams"
                    , oPositions: [ { x: 900, y: 50, oCargo: { "Bricks": 1, "Metal Beams": 1 } }, { x: 950, y:50, oCargo: { "Bricks": 1, "Metal Beams": 1 } } ] }
                , "Job: Bricks2": { 0:{}
                    , isAccepted: False
                    , isCompleted: False
                    , isModified: False
                    , sType: "CONTRACTS: DYSON DIESEL"
                    , sName: "Job: Bricks2"
                    , oPositions: [ { x: 900, y: 100, oCargo: { "Bricks": 2 } } ] } } }
        , "ALASKA": {}
        , "TAYMYR": {} }

    ResetData() {
        this.oBuildings := {}
        this.oBuildingTypes := {}
        this.oCargoTypes := {}
        this.oContracts := {}
        this.oMaps := {}
        this.oJobs := {}
        this.oRefJobs := {}
    }

    __New() {
        global TEST_DATA
        If (TEST_DATA)
            bDBModified := True
        Else
            this.ResetData()
    }

    AddBuilding(sRegion, oBuilding) {
        bDBModified := True
        If (!this.oBuildings[sRegion])
            this.oBuildings[sRegion] := []
        this.oBuildings[sRegion].Push(oBuilding)
    }

    GetBuildings(sRegion) {
        Return this.oBuildings[sRegion]
    }

    GetBuildingUnderCursor(sRegion) {
        MouseGetPos, X, Y
        For _, oBuilding in this.oBuildings[sRegion] {
            dX := Abs(oBuilding.X - X)
            dY := Abs(oBuilding.Y - Y)
            If (dX < iRadiusDetection && dY < iRadiusDetection)
                Return oBuilding
        }
    }

    IsBuildingOverlap(sRegion, oBuilding) {
        oBuildingsInRegion := this.oBuildings[sRegion]
        For _, oBuildingInRegion in oBuildingsInRegion {
            dX := Abs(oBuildingInRegion.x - oBuilding.x)
            dY := Abs(oBuildingInRegion.y - oBuilding.y)
            If (dX < iRadiusDetection * 2 && dY < iRadiusDetection * 2)
                Return True
        }
        Return False
    }

    AddJob(sRegion, oJob, bAddToRefJobs := False) {
        If (bAddToRefJobs) {
            bDBModified := True
            oJobs := this.oRefJobs
            oJob  := this.CopyJob(sRegion, oJob.sType, oJob.sName)
        }
        Else
            oJobs := this.oJobs
        ; You can't add value to nothing, only to object!
        sType := oJob.sType
        sName := oJob.sName
        If (!oJobs[sRegion])
            oJobs[sRegion] := {}
        If (!oJobs[sRegion][sType])
            oJobs[sRegion][sType] := {}
        oJobs[sRegion][sType][sName] := oJob
    }

    CopyJobsToRefJobs() {
        For sRegion, oJobsByRegion in this.oJobs
            For sType, oJobsByType in oJobsByRegion
                For sName, oJob in oJobsByType
                    this.AddJob(sRegion, oJob, True)
    }

    CreateJob(isAccepted, isCompleted, sJobType, sJobName, oPositions) {
        Return { isAccepted: isAccepted
            , isCompleted: isCompleted
            , sType: sJobType
            , sName: sJobName
            , oPositions: oPositions }
    }

    ; Get "Accepted" jobs in linear array, or all jobs in region
    GetJobList(sRegion, bAllJobs := False) {
        oJobsByRegion := this.GetJobs(sRegion)
        oAcceptedJobs := []
        For _, oJobsByType in oJobsByRegion
            For _, oJob in oJobsByType
                If (oJob.isAccepted || bAllJobs)
                    oAcceptedJobs.Push(oJob)
        Return oAcceptedJobs
    }

    GetJob(sRegion, sJobType, sJobName, bRefJob := False) {
        If (bRefJob)
            Return this.oRefJobs[sRegion][sJobType][sJobName]
        Else
            Return this.oJobs[sRegion][sJobType][sJobName]
    }

    GetJobs(sRegion) {
        Return this.oJobs[sRegion]
    }

    GetMaps(sRegion) {
        Return this.oMaps[sRegion]
    }

    GetBuildingTypesDDL() {
        sList := ""
        For sBuildingType in this.oBuildingTypes {
            sList .= sBuildingType "|"
            ; Make first region default via "||" in DropDownList
            If (A_Index == 1)
                sList .= "|"
        }
        Return RTrim(sList, "|")
    }

    GetCargoTypesDDL() {
        sList := "|" ; Make first field empty
        For sCargoType in this.oCargoTypes
            sList .= sCargoType "|"
        Return RTrim(sList, "|")
    }

    GetContractsInRegionDDL() {
        sList := ""
        For sContract in this.oContracts[GetRegion()]
            sList .= "CONTRACT: " sContract "|"
        Return RTrim(sList, "|")
    }

    GetRegionsDDL(sDefaultRegion) {
        sList := ""
        For _, sRegion in this.oRegions {
            sList .= sRegion "|"
            ; Make default region via "||" after it in DropDownList
            If (sRegion = sDefaultRegion) ; "=" is not case sensitive comparison
                sList .= "|"
        }
        Return RTrim(sList, "|")
    }

    CopyCargo(oCargo) {
        oCopyCargo := {}
        For sCargoType, iQuantity in oCargo
            oCopyCargo[sCargoType] := iQuantity
        Return oCopyCargo
    }

    CopyPositions(oPositions) {
        oCopyPositions := []
        For _, oPosition in oPositions {
            oCopyCargo := this.CopyCargo(oPosition.oCargo)
            oCopyPositions.Push({ x: oPosition.x, y: oPosition.y, oCargo: oCopyCargo })
        }
        Return oCopyPositions
    }

    CopyJob(sRegion, sJobType, sJobName, bRefJob := False) {
        oJob := this.GetJob(sRegion, sJobType, sJobName, bRefJob)
        oCopyPositions := this.CopyPositions(oJob.oPositions)
        Return this.CreateJob(oJob.isAccepted
            , oJob.isCompleted
            , sJobType
            , sJobName
            , oCopyPositions)
    }

    SetJobCompletedIfNoCargo(oJob, sErrMsg) {
        If (GetJobCargoCount(oJob) == 0) {
            If (sErrMsg && (oJob.isAccepted || !oJob.isCompleted))
                MsgBox(A_Gui, "E", sErrMsg
                    . "`n`nJob with zero cargo is Accepted or NOT Completed`n`n"
                    . GetJobInfoMsg("", oJob.sType, oJob.sName))
            oJob.isAccepted := False
            oJob.isCompleted := True
        } Else {
            If (sErrMsg && oJob.isCompleted)
                MsgBox(A_Gui, "E", sErrMsg
                    . "`n`nJob with NOT zero cargo is Completed.`n`n"
                    . GetJobInfoMsg("", oJob.sType, oJob.sName))
            oJob.isCompleted := False
        }
    }

    ; Fix possible logic errors in job's data
    SetJobsCompletedIfNoCargo(sErrMsg := "") {
        For _, oJobsByRegion in this.oJobs
            For _, oJobsByType in oJobsByRegion
                For _, oJob in oJobsByType
                    this.SetJobCompletedIfNoCargo(oJob, sErrMsg)
    }

    MarkModifiedJobs() {
        For sRegion, oJobsByRegion in this.oRefJobs
            For sType, oJobsByType in oJobsByRegion
                For sName, oRefJob in oJobsByType {
                    oJob := this.GetJob(sRegion, sType, sName)
                    If (!oJob)
                        MsgBox(A_Gui, "E", "Job from reference oRefJobs not exist in work copy oJobs.`n`n"
                            . GetJobInfoMsg(sRegion, sType, sName))
                    If (oJob.isAccepted or oJob.isCompleted
                        ; To be sure, as last check, compare cargo quantity
                        ; (if user "check" job, decrement cargo quantity and
                        ; then "uncheck" job)
                        or GetJobCargoCount(oJob) != GetJobCargoCount(oRefJob)) {
                        oJob.isModified := True
                    }
                }
    }

    WarnNotAcceptedModifiedJob() {
        For sRegion, oJobsByRegion in this.oJobs
            For sType, oJobsByType in oJobsByRegion
                For sName, oJob in oJobsByType
                    If (!oJob.isAccepted && !oJob.isCompleted) {
                        oRefJob := this.GetJob(sRegion, sType, sName, True)
                        If (GetJobCargoCount(oJob) != GetJobCargoCount(oRefJob))
                            MsgBox(A_Gui, "I", "Job from [" oFileName.sUP "] is modified but not accepted.`n`n"
                                . GetJobInfoMsg(sRegion, sType, sName))
                    }
    }

    ReadCSV(sFileName) { ; Sync any changes with WriteCSV()
        bReadUserProgress := (sFileName == oFileName.sUP) ? True : False
        Loop, Read, %sFileName%
        {
            sLine := Trim(A_LoopReadLine)
            If (sLine == "" || SubStr(sLine, 1, 1) == ";")
                Continue ; Skip empty lines and comments
            oCSV := []
            Loop, Parse, sLine, CSV, %A_Space%%A_Tab%
                oCSV.Push(Trim(A_LoopField))
            Switch oCSV[1] {
            Case "BUILDING TYPE":
                oCSV.RemoveAt(1, 1) ; Remove first element in linear array
                this.oBuildingTypes := ArrayToObj(oCSV)
            Case "CARGO TYPE":
                oCSV.RemoveAt(1, 1) ; Remove first element in linear array
                this.oCargoTypes := ArrayToObj(oCSV)
            Case "JOB TYPE":
                sRegion := oCSV[2]
                oCSV.RemoveAt(1, 2) ; Remove first 2 elements in linear array
                this.oContracts[sRegion] := ArrayToObj(oCSV)
            Case "DEFAULT REGION":
                sDefaultRegion := oCSV[2]
            Case "REGION LIST":
                oCSV.RemoveAt(1, 1) ; Remove first element in linear array
                this.oRegions := oCSV
            Case "REGION":
                sRegion := oCSV[2]
                oCSV.RemoveAt(1, 2) ; Remove first 2 elements in linear array
                this.oMaps[sRegion] := oCSV
            Case "BUILDING":
                sRegion := oCSV[2]
                sType   := oCSV[3]
                X       := oCSV[4]
                Y       := oCSV[5]
                oCSV.RemoveAt(1, 5) ; Remove first 5 elements in linear array
                oBuilding := { sType: sType, x: X, y: Y, oCargoTypes: ArrayToObj(oCSV) }
                If (!this.oBuildings[sRegion])
                    this.oBuildings[sRegion] := []
                this.oBuildings[sRegion].Push(oBuilding)
            Case "JOB":
                sRegion     := oCSV[2]
                sType       := oCSV[3]
                sName       := oCSV[4]
                isAccepted  := oCSV[5]
                isCompleted := oCSV[6]
                X           := oCSV[7]
                Y           := oCSV[8]
                oCSV.RemoveAt(1, 8) ; Remove first 8 elements in linear array
                oCargo      := CreateAssocArray(oCSV)
                oPosition   := { x: X, y: Y, oCargo: oCargo }
                oJob := this.GetJob(sRegion, sType, sName)
                If (bReadUserProgress) {
                    If (oJob)
                        ; Use isModified flag as mark, that we overwrite job from
                        ;   Database.csv by job from UserProgress.csv!
                        If (oJob.isModified)
                            ; Append position to modified Job
                            oJob.oPositions.Push(oPosition)
                        Else {
                            ; Overwrite original Job by modified Job
                            oJob := this.CreateJob(isAccepted
                                , isCompleted
                                , sType
                                , sName
                                , [oPosition])
                            oJob.isModified := True ; Jobs from User Progress always modified
                            this.oJobs[sRegion][sType][sName] := oJob
                        }
                    Else
                        MsgBox(A_Gui, "E", "Job from [" oFileName.sUP "] does not exist in [" oFileName.sDB "]`n`n"
                            . GetJobInfoMsg(sRegion, sType, sName))
                } Else {
                    ; Reference Jobs always NOT accepted and NOT completed
                    isAccepted  := False
                    isCompleted := False
                    If (oJob)
                        ; Append position to existing Job
                        oJob.oPositions.Push(oPosition)
                    Else {
                        ; Add new Job
                        oJob := this.CreateJob(isAccepted
                            , isCompleted
                            , sType
                            , sName
                            , [oPosition])
                        this.AddJob(sRegion, oJob)
                    }
                }
            Default:
                MsgBox(A_Gui, "E", sFileName "`n`nLine " A_Index ": Wrong keyword [" oCSV[1] "]")
            }
        }
    }

    WriteCSV(sFileName) { ; Sync any changes with ReadCSV()
        bWriteUserProgress := (sFileName == oFileName.sUP) ? True : False
        oFile := FileOpen(sFileName, "w `n")
        oFile.WriteLine(";CSV v1.0")
        If (bWriteUserProgress) { ; User Progress
            oFile.WriteLine(";DEFAULT REGION,Region")
            oFile.WriteLine("DEFAULT REGION," sDefaultRegion)
            oFile.WriteLine(";JOB,Region,JobType,JobName,isAccepted,isCompleted,X,Y,CargoType1,Quantity1,...,...,CargoTypeN,QuantityN")
            For sRegion, oJobsByRegion in this.oJobs
                For sType, oJobsByType in oJobsByRegion
                    For sName, oJob in oJobsByType
                        ; User Progress: Write ONLY modified Jobs
                        If (oJob.isModified)
                            For _, oPosition in oJob.oPositions
                                oFile.WriteLine("JOB,"
                                    . sRegion ","
                                    . sType ","
                                    . sName ","
                                    . oJob.isAccepted ","
                                    . oJob.isCompleted ","
                                    . oPosition.x ","
                                    . oPosition.y ","
                                    . ArrayToCSV(oPosition.oCargo))
        } Else { ; Database
            oFile.WriteLine(";BUILDING TYPE,BuildingType1,...,BuildingTypeN")
            oFile.WriteLine("BUILDING TYPE," ArrayToCSV(this.oBuildingTypes))
            oFile.WriteLine(";CARGO TYPE,CargoType1,...,CargoTypeN")
            oFile.WriteLine("CARGO TYPE," ArrayToCSV(this.oCargoTypes))
            oFile.WriteLine(";JOB TYPE,Region,JobType1,...,JobTypeN")
            For sRegion, oContractsNames in this.oContracts
                oFile.WriteLine("JOB TYPE," sRegion "," ArrayToCSV(oContractsNames))
            oFile.WriteLine(";REGION LIST,Region1,...,RegionN")
            oFile.WriteLine("REGION LIST," ArrayToCSV(this.oRegions))
            oFile.WriteLine(";REGION,Region,Map1,Map2,Map3,Map4")
            For sRegion, oMaps in this.oMaps
                oFile.WriteLine("REGION," sRegion "," ArrayToCSV(oMaps))
            oFile.WriteLine(";BUILDING,Region,BuildingType,X,Y,CargoType1,...,CargoTypeN")
            For sRegion, oBuildings in this.oBuildings
                For _, oBuilding in oBuildings
                    oFile.WriteLine("BUILDING,"
                        . sRegion ","
                        . oBuilding.sType ","
                        . oBuilding.x ","
                        . oBuilding.y ","
                        . ArrayToCSV(oBuilding.oCargoTypes))
            ; Database: Write Jobs from Reference Jobs!
            oFile.WriteLine(";JOB,Region,JobType,JobName,isAccepted,isCompleted,X,Y,CargoType1,Quantity1,...,...,CargoTypeN,QuantityN")
            For sRegion, oJobsByRegion in this.oRefJobs
                For sType, oJobsByType in oJobsByRegion
                    For sName, oJob in oJobsByType
                        For _, oPosition in oJob.oPositions {
                            oFile.WriteLine("JOB,"
                                . sRegion ","
                                . sType ","
                                . sName ","
                                . 0 "," ; oJob.isAccepted  Always Zero
                                . 0 "," ; oJob.isCompleted Always Zero
                                . oPosition.x ","
                                . oPosition.y ","
                                . ArrayToCSV(oPosition.oCargo))
                        }
        }
        oFile.Close()
    }

    CreateBackup(sFileName) {
        FileCopy, %sFileName%, % StrReplace(sFileName, ".csv", ".bak"), True
    }

    Load(oFileName) {
        this.ReadCSV(oFileName.sDB)
        this.SetJobsCompletedIfNoCargo("File: " oFileName.sDB)
        this.LoadUserProgress(oFileName.sUP)
        ; On Read\Load functions will set modified flag false positive, reset it
        bDBModified := False
    }

    ; Overwrite copy of reference jobs in oJobs from UserProgress.csv
    LoadUserProgress(sFileName) {
        this.CopyJobsToRefJobs()
        this.ReadCSV(sFileName)
        this.WarnNotAcceptedModifiedJob()
        this.SetJobsCompletedIfNoCargo("File: " sFileName)
    }

    Save(oFileName) {
        If (bDBModified) {
            bDBModified := False
            this.CreateBackup(oFileName.sDB)
            this.WriteCSV(oFileName.sDB)
        }
        this.SaveUserProgress(oFileName.sUP)
    }

    SaveUserProgress(sFileName) {
        this.MarkModifiedJobs()
        this.CreateBackup(sFileName)
        this.WriteCSV(sFileName)
    }

    ; Only for use with TEST_DATA
    SaveLoad(oFileName) {
        this.Save(oFileName)
        this.ResetData()
        this.Load(oFileName)
    }
}

TODO(sText, bModal := False)
{
    sMsg := A_LineNumber ":TODO: " sText
    If (bModal)
        MsgBox % sMsg
    Else {
        ToolTip % sMsg
        SetTimer DisableToolTip, -4000
    }
    Return

    DisableToolTip:
    ToolTip
    Return
}
