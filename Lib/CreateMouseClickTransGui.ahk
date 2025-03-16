; Create always on top mouse-click transparent gui.
; Gui, GuiName:New [, Options, Title]
; If [GuiName] is specified, a new GUI will be created, destroying any existing GUI with that name.
; Otherwise, a new unnamed and unnumbered GUI will be created.
; Calling [Gui, New] ensures that the script is creating a new GUI, not modifying an existing one.
; +E0x20 makes GUI mouse-click transparent.
CreateMouseClickTransGui(id := "")
{
    if (id)
        Gui, %id%: New, -Caption -SysMenu +AlwaysOnTop +LastFound +ToolWindow +E0x20
    else
        Gui,       New, -Caption -SysMenu +AlwaysOnTop +LastFound +ToolWindow +E0x20
    WinSet, TransColor, 500 ; This line is necessary to working +E0x20 !!!! Very complicated theme.
}
