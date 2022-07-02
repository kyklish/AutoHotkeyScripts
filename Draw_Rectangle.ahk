; Draw rectangle (Not work with fullscreen applications!)
#NoEnv
SetBatchLines, -1
CoordMode, Mouse, Screen

LButton_Held = 0

Loop, 4
{
	; Original
	; Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTop
	; Gui, %A_Index%: Color, Red

	; Better variant
	; +E0x20 makes GUI mouse-click transparent
	Gui, %A_Index%: New, -Caption -SysMenu +ToolWindow +AlwaysOnTop +LastFound +E0x20
	Gui, %A_Index%: Color, Red
	WinSet, TransColor, 500 ; This line is necessary to working +E0x20 !!!! Very complicated theme.
}
Return

+LButton::
If (LButton_Held == 0)
{
	LButton_Held = 1
	MouseGetPos, Mouse_X, Mouse_Y
	Loop
	{
		MouseGetPos, Mouse_X_2, Mouse_Y_2
		If (Mouse_X_2 > Mouse_X)
		{
			Gui, 1: Show, % "x" Mouse_X " y" Mouse_Y " w" Mouse_X_2 - Mouse_X " h1 NoActivate"
			Gui, 4: Show, % "x" Mouse_X " y" Mouse_Y_2 " w" Mouse_X_2 - Mouse_X " h1 NoActivate"
		}
		Else
		{
			Gui, 1: Show, % "x" Mouse_X_2 " y" Mouse_Y " w" Mouse_X - Mouse_X_2 " h1 NoActivate"
			Gui, 4: Show, % "x" Mouse_X_2 " y" Mouse_Y_2 " w" Mouse_X - Mouse_X_2 " h1 NoActivate"
		}
		If (Mouse_Y_2 > Mouse_Y)
		{
			Gui, 2: Show, % "x" Mouse_X " y" Mouse_Y " w1 h" Mouse_Y_2 - Mouse_Y " NoActivate"
			Gui, 3: Show, % "x" Mouse_X_2 " y" Mouse_Y " w1 h" Mouse_Y_2 - Mouse_Y " NoActivate"
		}
		Else
		{
			Gui, 2: Show, % "x" Mouse_X_2 " y" Mouse_Y_2 " w1 h" Mouse_Y - Mouse_Y_2 " NoActivate"
			Gui, 3: Show, % "x" Mouse_X " y" Mouse_Y_2 " w1 h" Mouse_Y - Mouse_Y_2 " NoActivate"
		}
		ToolTip, % "Width: " Mouse_X_2 - Mouse_X " - Height: " Mouse_Y_2 - Mouse_Y
		If (LButton_Held == 0)
			Break
	}
	Loop, 4
		Gui, %A_Index%: Hide
	ToolTip
	Final_Width := Mouse_X_2 - Mouse_X
	Final_Height := Mouse_Y_2 - Mouse_Y
	If (Final_Width > 0)
		X_Coordinate := Mouse_X
	Else
	{
		Final_Width *= -1
		X_Coordinate := Mouse_X_2
	}
	If (Final_Height > 0)
		Y_Coordinate := Mouse_Y
	Else
	{
		Final_Height *= -1
		Y_Coordinate := Mouse_Y_2
	}
	;CaptureScreen(X_Coordinate ",  " Y_Coordinate ", " X_Coordinate + Final_Width ", " Y_Coordinate + Final_Height) ;я не скачивал AHK файл функции, оставил для примера
}
Return

+LButton Up::
LButton_Held = 0
Return

!x::ExitApp
!z::Reload
