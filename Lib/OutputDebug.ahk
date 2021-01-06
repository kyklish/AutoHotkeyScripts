;One example of a debugger is DebugView, which is free and available at www.sysinternals.com.
OutputDebug(sText := "DBGVIEWCLEAR")
{
	global IsDebug
	if IsDebug
		OutputDebug, %sText%
}