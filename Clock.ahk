#Include <_COMMON_SETTINGS_>

#Persistent

; Prefixes in variable's name:
; s - string
; t - time

sHourSound := "Casio F-91W Hour Chime.wav"
sHalfHourSound := "Casio F-91W Half Hour Chime.wav"


tTime := SubStr(A_Now, 1, 10) ;Skip minutes and seconds. YYYYMMDDHH24MISS format. If only a partial string is given (e.g. 200403), any remaining element that has been omitted will be supplied with the default values.
tTime += 1, Hours
tTime -= A_Now, Seconds
tDiffToNextHour := tTime
tDiffToNextHalfHour := tDiffToNextHour + (tDiffToNextHour < 1800 ? 1800 : -1800)
SetTimer, InitHourClock, -%tDiffToNextHour%000 ;negative period - run once
SetTimer, InitHalfHourClock, -%tDiffToNextHalfHour%000


InitHourClock()
{
	SetTimer, HourBeep, 3600000
	HourBeep()
}

InitHalfHourClock()
{
	SetTimer, HalfHourBeep, 3600000
	HalfHourBeep()
}

HourBeep()
{
	global sHourSound
	SoundPlay, %sHourSound%, Wait
}

HalfHourBeep()
{
	global sHalfHourSound
	SoundPlay, %sHalfHourSound%, Wait
}