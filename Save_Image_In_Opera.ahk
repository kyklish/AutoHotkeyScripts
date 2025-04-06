#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

GroupAdd, Opera, ahk_exe opera.exe

iTimeout := 4 ; seconds to wait window
ttDisplayTime := 4000 ; milliseconds to show ToolTip

!x:: ExitApp
!z:: Reload

#IfWinActive ahk_group Opera
    F1:: ShowHelpWindow("
(
Win -> MButton
 F2 -> Save
 F3 -> Save + Close
+F2 -> Click + Save
+F3 -> Click + Save + Close
^F2 -> Save + Prev. Tab (save favorite then ^F3 to remove)
^F3 -> Click + Close (remove from favorite)
)")

    LWin::Click Middle

    F2:: ;Save
    Save:
        MouseGetPos, X, Y
        Send {RButton}
        ; Wait context menu
        Loop {
            PixelGetColor, iColor, % X + 10, % Y + 40, RGB
            If (iColor == 0x161B1F or iColor == 0x171B1F) ; Win7 or Win11
                break
            If (A_TimeSinceThisHotkey > iTimeout * 1000) {
                ToolTip("Context menu timeout (" iTimeout " sec)", ttDisplayTime) ; milliseconds
                Return
            }
            Sleep 50
        }
        ; Click 'Save image as...'
        MouseMove 10, 40, , R
        Send {LButton}
        MouseMove, %X%, %Y%
        ; Wait 'Save As' window
        WinWaitActive, Save As, , %iTimeout%
        If (ErrorLevel) {
            ToolTip("'Save As' window timeout (" iTimeout " sec)", ttDisplayTime) ; milliseconds
            Return
        }
        ; Press 'Save' button
        Send {Enter}
    Return

    F3:: ;Save + Close
    SaveClose:
        Gosub Save
        Sleep 300 ; Wait download notification disappear
        Send ^w
    Return

    +F2:: ;Click + Save
        Send {LButton}
        Sleep 500
        Gosub Save
    Return

    +F3:: ;Click + Save + Close
        Send {LButton}
        Sleep 750
        Gosub SaveClose
    Return

    ^F2:: ;Save + Prev. Tab
        Gosub Save
        Sleep 200
        Send ^+{Tab}
        Send {Ctrl Up} ; If user keep pressing Ctrl, Opera will show preview of all tabs. Force key up.
    Return

    ^F3:: ;Click + Close
        Send {LButton}
        Sleep 500
        Send ^w
    Return
#If
