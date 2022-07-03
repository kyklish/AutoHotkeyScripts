#Include <_COMMON_SETTINGS_>

; The first parameter is always 0x71 (SPI_SETMOUSESPEED).
; The third parameter is the speed (range is 1-20, 10 is default).

Browser_Home::
DllCall("SystemParametersInfo", UInt, 0x71, UInt, 0, UInt, 3, UInt, 0)
KeyWait Browser_Home ; This prevents keyboard auto-repeat from doing the DllCall repeatedly.
return

Browser_Home up::DllCall("SystemParametersInfo", UInt, 0x71, UInt, 0, UInt, 10, UInt, 0)