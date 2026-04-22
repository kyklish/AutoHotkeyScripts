ShowHelpImage(ByRef sImageFile := "", sGuiName := "")
{
    static bToggle := False
    sGuiName := "HelpImage" sGuiName

    If (bToggle := !bToggle) {
        CreateMouseClickTransGui(sGuiName)
        Gui Margin, 0, 0
        Gui, %sGuiName%: Add, Picture, , %sImageFile%
        Gui, %sGuiName%: Show, NoActivate
    }
    Else
        Gui, %sGuiName%: Destroy
}
