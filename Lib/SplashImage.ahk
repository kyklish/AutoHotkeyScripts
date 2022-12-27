; Gui Picture: AlwaysOnTop BorderLess NoActivate
SplashImage_New(sFileName, sGuiName := "") {
    sGuiName := "SplashImage" sGuiName
    Gui %sGuiName%:New, -Caption +AlwaysOnTop +LastFound
    Gui Margin, 0, 0
    Gui Add, Picture,, %sFileName%
}

SplashImage_Show(sGuiName := "") {
    sGuiName := "SplashImage" sGuiName
    Gui %sGuiName%:Show, NoActivate
}

SplashImage_Hide(sGuiName := "") {
    sGuiName := "SplashImage" sGuiName
    Gui %sGuiName%:Hide
}

SplashImage_Toggle(sGuiName := "") {
    static bToggle := False
    sGuiName := "SplashImage" sGuiName
    If (bToggle := !bToggle)
        Gui %sGuiName%:Show, NoActivate
    Else
        Gui %sGuiName%:Hide
}
