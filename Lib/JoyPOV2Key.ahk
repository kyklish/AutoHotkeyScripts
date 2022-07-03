;Joystick POV to key
;
;Only a direct function call such as MyFunc() can cause a library to be auto-included.
;If the function is only called dynamically or indirectly, such as by a timer or GUI event,
;the library must be explicitly included in the script.
;
;Usage:
;	SendMode, Event  ; [optional]
;	SetKeyDelay, 100 ; [optional]
;	JoyPOV2Key()     ; Load function from library via first call, without this, function will not be loaded by Func(...).Bind(...)!!!
;	#Include <JoyPOV2Key> ; Use above line or this, but not both.
;
;	;Variant #1: use default keys (Up, Down, Left, Right).
;	SetTimer, JoyPOV2Key, 10
;
;	;Variant #2: use different keys, we need Func Object to bind them to function.
;	WatchPOV := Func("JoyPOV2Key").Bind("w", "a", "s", "d", JoyNumber)
;	SetTimer, %WatchPOV%, 10


JoyPOV2Key(Up := "Up", Down := "Down", Left := "Left", Right := "Right", JoyNumber := 1)
{
	static KeyToHoldDown, KeyToHoldDownPrev
	GetKeyState, POV, %JoyNumber%JoyPOV  ; Get position of the POV control.
	KeyToHoldDownPrev := KeyToHoldDown  ; Prev now holds the key that was down before (if any).
	
	; Some joysticks might have a smooth/continous POV rather than one in fixed increments.
	; To support them all, use a range:
	if POV < 0   ; No angle to report
		KeyToHoldDown := ""
	else if POV > 31500                 ; 315 to 360 degrees: Forward
		KeyToHoldDown := Up
	else if POV between 0 and 4500      ; 0 to 45 degrees: Forward
		KeyToHoldDown := Up
	else if POV between 4501 and 13500  ; 45 to 135 degrees: Right
		KeyToHoldDown := Right
	else if POV between 13501 and 22500 ; 135 to 225 degrees: Down
		KeyToHoldDown := Down
	else                                ; 225 to 315 degrees: Left
		KeyToHoldDown := Left
	
	if (KeyToHoldDown == KeyToHoldDownPrev)  ; The correct key is already down (or no key is needed).
	{
		;if (KeyToHoldDown)
			;Send, {%KeyToHoldDown% down}  ; Auto-repeat the keystroke.
		;return
		
		return  ; Do nothing.
	}
	
	; Otherwise, release the previous key and press down the new key:
	SetKeyDelay -1  ; Avoid delays between keystrokes.
	if KeyToHoldDownPrev   ; There is a previous key to release.
		Send, {%KeyToHoldDownPrev% up}  ; Release it.
	if KeyToHoldDown   ; There is a key to press down.
		Send, {%KeyToHoldDown% down}  ; Press it down.
}