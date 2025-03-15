#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

g_sPath := A_Temp ; Any path contained by the drive
g_iPeriod := 1000 ; Update interval

Menu, Tray, Tip, %A_ScriptName%`n%g_sPath%
TrayIconTimer := Func("TrayIcon").Bind(g_sPath)
SetTimer, % TrayIconTimer, % g_iPeriod

; Free disk space of the drive which contains the specified path.
; Result as a percentage: two digits with zero padding.
; 100% does not fit into ICON, changed into 99%.
DriveSpaceFree(sPath) {
    DriveGet, iCapacity, Capacity, % sPath
    DriveSpaceFree, iFree, % sPath
    iFree := Round(100 * iFree / iCapacity)
    iFree := (iFree == 100) ? 99 : iFree
    sFree := Format("{:02}", iFree)
    Return sFree
}

TrayIcon(sPath) {
    static sFreePrev := ""
    sFree := DriveSpaceFree(sPath)
    If (sFree != sFreePrev) {
        sFreePrev := sFree
        Menu, Tray, Icon, ICONS\%sFree%.ico
    }
}
