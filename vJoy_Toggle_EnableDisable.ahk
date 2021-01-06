Reload_AsAdmin()


; To include an actual quote-character inside a literal string, specify two consecutive quotes as shown twice in this example:
; "She said, ""An apple a day.""".
sDevcon := """D:\SERGEY\Options\Program Files\BAT\devcon.exe"""
sDevice := """root\VID_1234&PID_BEAD&REV_0218""" ; vJoy deviceID


sStatus := vJoy(sDevice, "status")
if sStatus contains Driver is running.
	vJoy(sDevice, "disable")
else if sStatus contains Device is disabled.
	vJoy(sDevice, "enable")
else if sStatus contains No matching devices found.
	MsgBox, %sStatus%
else
	MsgBox, Unknown error:`n`n%sStatus%.


DevCon(sCommand, sDevice) ; Console Device Manager
{
	global sDevcon
	if sCommand in disable,enable,status ; Avoid spaces in list.
		return RunWaitCMD(sDevcon " " sCommand " " sDevice)
	else
		MsgBox, Wrong command for devcon.exe
}


vJoy(sDevice, sCommand)
{
	if(sCommand != "status")
		ToolTip % Format("Trying {:U} device.", sCommand)
	return DevCon(sCommand, sDevice)
}