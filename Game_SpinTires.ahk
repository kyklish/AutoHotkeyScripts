;SpinTires
#NoEnv
SendMode Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetKeyDelay, 50, 50 ; чтобы работало в играх, нужно использовать задержки при нажатиях (only Event mode)

SetTimer, WatchAxis, 5

WatchAxis:
GetKeyState, JoyX, JoyX  ; Get position of X axis.
GetKeyState, JoyY, JoyY  ; Get position of Y axis.
KeyToHoldDownPrev = %KeyToHoldDown%  ; Prev now holds the key that was down before (if any).

if JoyX > 55
	KeyToHoldDown = Right
else if JoyX < 45
	KeyToHoldDown = Left
else if JoyY > 55
	KeyToHoldDown = ;Down
else if JoyY < 45
	KeyToHoldDown = ;Up
else
	KeyToHoldDown =

if KeyToHoldDown = %KeyToHoldDownPrev%  ; The correct key is already down (or no key is needed).
	return  ; Do nothing.

; Otherwise, release the previous key and press down the new key:
;SetKeyDelay -1  ; Avoid delays between keystrokes.
if KeyToHoldDownPrev   ; There is a previous key to release.
	Send, {%KeyToHoldDownPrev% up}  ; Release it.
if KeyToHoldDown   ; There is a key to press down.
	Send, {%KeyToHoldDown% down}  ; Press it down.
return


Joy8::
Send {Up down}
SetTimer, WaitForButtonUp8, 10
return

WaitForButtonUp8:
if GetKeyState("Joy8")  ; The button is still, down, so keep waiting.
	return
; Otherwise, the button has been released.
Send {Up up}
SetTimer, WaitForButtonUp8, off
return

Joy7::
Send {Down down}
SetTimer, WaitForButtonUp7, 10
return

WaitForButtonUp7:
if GetKeyState("Joy7")  ; The button is still, down, so keep waiting.
	return
; Otherwise, the button has been released.
Send {Down up}
SetTimer, WaitForButtonUp7, off
return

Joy1::Send t
Joy2::Send f
Joy3::Send q
Joy4::Send 2
Joy5::Send e
Joy9::Send 1
