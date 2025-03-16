ToolTip(sMessage, iDisplayTime := 1000, bIsModal := false, X := "", Y := "", iNum := 20)
{
    CoordMode, ToolTip, Screen
    ToolTip, % sMessage, % X, % Y, %iNum%
    if (bIsModal) {
        Sleep, %iDisplayTime%
        RemoveToolTip(iNum)
    } else {
        RmToolTip := Func("RemoveToolTip").Bind(iNum)
        SetTimer, %RmToolTip%, -%iDisplayTime%
    }
}

RemoveToolTip(iNum := 20)
{
    ToolTip, , , , %iNum%
}

; Original version
/*
ToolTip(sMessage, iDisplayTime := 1, bIsModal := false, X := "", Y := "")
{
    ToolTip, % sMessage, % X, % Y
    if (bIsModal) {
        Sleep, %iDisplayTime%000
        Gosub, RemoveToolTip
    } else {
        SetTimer, RemoveToolTip, -%iDisplayTime%000
    }
    return

    RemoveToolTip:
    ToolTip
    return
}
*/
