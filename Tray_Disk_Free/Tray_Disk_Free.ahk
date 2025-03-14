#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

g_sDrive := A_Temp

Menu, Tray, Tip, %A_ScriptName%`n%g_sDrive%
SetTimer, TrayIcon, 1000

; Drive free space (percent) with TEMP folder (two digits with zero padding)
DriveSpaceFree() {
    global g_sDrive
    DriveGet, iCapacity, Capacity, % g_sDrive
    DriveSpaceFree, iFree, % g_sDrive
    sFree := Round(100 * iFree / iCapacity)
    sFree := Format("{:02}", sFree)
    Return sFree
}

TrayIcon() {
    static sFreePrev := ""
    sFree := DriveSpaceFree()
    If (sFree != sFreePrev) {
        sFreePrev := sFree
        Menu, Tray, Icon, ICONS\%sFree%.ico
    }
}
