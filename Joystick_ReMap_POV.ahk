#Persistent  ; Keep this script running until the user explicitly exits it.
SetTimer, WatchPOV, 5
return

WatchPOV:
GetKeyState, POV, JoyPOV  ; Get position of the POV control.
KeyToHoldDownPrev = %KeyToHoldDown%  ; Prev now holds the key that was down before (if any).

; Some joysticks might have a smooth/continuos POV rather than one in fixed increments.
; To support them all, use a range:
if POV < 0   ; No angle to report
    KeyToHoldDown =
else if POV > 31500                 ; 315 to 360 degrees: Forward
    KeyToHoldDown = Up
else if POV between 0 and 4500      ; 0 to 45 degrees: Forward
    KeyToHoldDown = Up
else if POV between 4501 and 13500  ; 45 to 135 degrees: Right
    KeyToHoldDown = Right
else if POV between 13501 and 22500 ; 135 to 225 degrees: Down
    KeyToHoldDown = Down
else                                ; 225 to 315 degrees: Left
    KeyToHoldDown = Left

if KeyToHoldDown = %KeyToHoldDownPrev%  ; The correct key is already down (or no key is needed).
    return  ; Do nothing.

; Otherwise, release the previous key and press down the new key:
SetKeyDelay -1  ; Avoid delays between keystrokes.
if KeyToHoldDownPrev   ; There is a previous key to release.
    Send, {%KeyToHoldDownPrev% up}  ; Release it.
if KeyToHoldDown   ; There is a key to press down.
    Send, {%KeyToHoldDown% down}  ; Press it down.
return
