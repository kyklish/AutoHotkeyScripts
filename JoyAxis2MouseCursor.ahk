;Joystick UV-axises to Mouse cursor
;
;Only a direct function call such as MyFunc() can cause a library to be auto-included.
;If the function is only called dynamically or indirectly, such as by a timer or GUI event,
;the library must be explicitly included in the script.
;
;Usage:
;	JoyAxis2MouseCursor()     ; Load function from library via first call, without this, function will not be loaded by Func(...).Bind(...)!!!
;	#Include <JoyAxis2MouseCursor> ; Use above line or this, but not both.
;
;	;Variant #1: use default axises (X, Y).
;	SetTimer, JoyAxis2MouseCursor, 10
;
;	;Variant #2: use different axises, we need Func Object to bind them to function.
;	WatchJoystick := Func("JoyAxis2MouseCursor").Bind("V", "U")
;	SetTimer, %WatchJoystick%, 10
;
;SetFormat problems:
;	In this function default JoyMultiplier values rounded to integer,
;	so values below 0.5 rounded to 0 and above 0.5 to 1. In example script this works,
;	in function SetFormat works different.
;	Я думаю, что если значение по умолчанию, то первое обращение к переменной (и присвоение ей дефолтного значения)
;	происходит после комманды SetFormat, поэтому она округлятеся.
;	Если значение передается явно в функцию, то оно присваевается переменной до комманды SetFormat и все работает как надо.
;	Поэтому я перенес SetFormat в самый конец функции, где она почему-то работает как надо.

JoyAxis2MouseCursor(AxisX := "X", AxisY := "Y", JoyMultiplier := 0.2, JoyThreshold := 5, JoyNumber := 1)
{
	;JoyMultiplier - Mouse cursor speed.
	;JoyThreshold - Dead zone. A perfect joystick could use a value of 1.
	
	; Calculate the axis displacements that are needed to start moving the mouse cursor:
	JoyThresholdUpper := 50 + JoyThreshold ; 50 - is a center, Min-Max = 0-100.
	JoyThresholdLower := 50 - JoyThreshold
	
	MouseNeedsToBeMoved := false
	;SetFormat, float, 03 ; Original position. See comments above.
	GetKeyState, X, %JoyNumber%Joy%AxisX%
	GetKeyState, Y, %JoyNumber%Joy%AxisY%
	
	if (X > JoyThresholdUpper)
	{
		MouseNeedsToBeMoved := true
		DeltaX := X - JoyThresholdUpper
	}
	else if (X < JoyThresholdLower)
	{
		MouseNeedsToBeMoved := true
		DeltaX := X - JoyThresholdLower
	}
	else
		DeltaX := 0
	
	if (Y > JoyThresholdUpper)
	{
		MouseNeedsToBeMoved := true
		DeltaY := Y - JoyThresholdUpper
	}
	else if (Y < JoyThresholdLower)
	{
		MouseNeedsToBeMoved := true
		DeltaY := Y - JoyThresholdLower
	}
	else
		DeltaY := 0

	if MouseNeedsToBeMoved
	{
		SetFormat, float, 03 ; New position. Round next math to decimals. Without all SetFormat commands function works propertly too, MouseMove accepts float values.
		SetMouseDelay, -1  ; Makes movement smoother.
		MouseMove, DeltaX * JoyMultiplier, DeltaY * JoyMultiplier, 0, R
	}
}