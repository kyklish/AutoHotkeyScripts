;DO NOT use Tabs in string!!! In editor 1 tab =  4 spaces, but in window 1 tab == 8 spaces.

ShowHelpWindow(ByRef str := "")
{
	static bToggle
	iCharWidth := 9 ;ширина символа по умолчанию
	iPadding := 10 ;отступ текста от края окна, которое делает AutoHotkey
	
	if (bToggle := !bToggle) {
		Loop, Parse, str, `n, `r
			if (width < StrLen(A_LoopField))
				width := StrLen(A_LoopField)
		width := width * iCharWidth + 2 * iPadding
		Progress, zh0 b2 c0 w%width%, %str%, , , Consolas
	}
	else
		Progress, Off
}
