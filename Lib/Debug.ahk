Debug(sText)
{
	global IsDebug
	if IsDebug {
		ListVars  ; Use AutoHotkey's main window to display text with monospace font.
		WinWaitActive ahk_class AutoHotkey
		ControlSetText Edit1, %sText%
		WinWaitClose
	}
}